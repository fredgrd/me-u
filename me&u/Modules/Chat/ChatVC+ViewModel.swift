//
//  ChatVC+ViewModel.swift
//  me&us
//
//  Created by Federico on 12/02/23.
//

import Foundation
import AVFoundation
import Combine

class ChatVCViewModel: NSObject {
    
    enum ChatSection: Hashable {
        case chat
    }
    
    enum RecordingState {
        case startRecording
        case doneRecording
        case stopRecording
    }
    
    let controller: MainController
    
    let room: Room
    
    let messages = CurrentValueSubject<[RoomMessage], Never>([])
    
    let typing = CurrentValueSubject<RoomUpdate?, Never>(nil)
    private var typingTimer: Timer?
    
    let webSocketAPI = WebSocketAPI()
    
    // Audios
    private var audioRecorder: AVAudioRecorder?
    private var audioFilepath: URL?
    
    init(controller: MainController, room: Room) {
        self.controller = controller
        self.room = room
        super.init()
    }
    
    func fetchHistory() async {
        let result = await controller.roomAPI.fetchMessages(forRoom: room.id)
        switch result {
        case .success(let messages):
            self.messages.send(messages)
        case .failure(_):
            await controller.showToast(withMessage: ToastErrorMessage.Generic.rawValue)
        }
    }

    func subscribeToRoom() {
        guard let user = controller.userManager.user.value else {
            controller.showToast(withMessage: "Cannot connect. Retry")
            return
        }
        
        webSocketAPI.subscribeToRoom(roomID: room.id, userID: user.id) { [weak self] socketResult in
            guard let self = self, let socketResult = socketResult else {
                return
            }
            
            if socketResult.kind == .update, let update = socketResult.update {
                self.typingTimer?.invalidate()
                DispatchQueue.main.async {
                    self.typingTimer = Timer.scheduledTimer(withTimeInterval: 15, repeats: false, block: { _ in
                        self.typing.send(nil)
                    })
                }
                self.typing.send(update)
            }
            
            if socketResult.kind == .message, let message = socketResult.message {
                var messages = self.messages.value
                messages.append(message)
                self.messages.send(messages)
            }
        }
    }
    
    func closeSocket() {
        print("CLOSING SOCKET")
        webSocketAPI.closeWebSocket()
    }
    
    func sendMessage(_ message: String, kind: RoomMessageKind) async {
        guard let user = controller.userManager.user.value else {
            fatalError("Failed to retrieve user")
        }
        
        // Form RoomMessage
        let message = RoomMessage(id: UUID().uuidString, sender: user.id, sender_name: user.name, sender_number: user.number, sender_thumbnail: user.avatar_url, message: message, kind: kind, timestamp: Date.now.ISO8601Format())
        
        // Socket
        webSocketAPI.sendMessage(message)
        
        var messages = messages.value
        messages.append(message)
        self.messages.send(messages)
    }
    
    func sendUpdate(_ kind: RoomUpdateKind = .typing) async {
        guard let user = controller.userManager.user.value else {
            fatalError("Failed to retrieve user")
        }
        
        let update = RoomUpdate(kind: kind, sender_name: user.name)
        
        webSocketAPI.sendUpdate(update)
    }
    
   
}

// MARK: - Texting
extension ChatVCViewModel {
    func sendText(_ text: String) {
        Task {
            await sendMessage(text, kind: .text)
        }
    }
}

// MARK: - Recording
extension ChatVCViewModel {
    func startRecordingSession() {
        let recordingSession = AVAudioSession.sharedInstance()
        do {
            try recordingSession.setCategory(.playAndRecord, mode: .default)
            try recordingSession.setActive(true)
        } catch {
            controller.showToast(withMessage: "Recorder error")
        }

        let path = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        audioFilepath = path.appending(path: "\(UUID().uuidString).m4a")

        let settings = [
            AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
            AVSampleRateKey: 12000,
            AVNumberOfChannelsKey: 1,
            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
        ]
        
        do {
            guard let filepath = audioFilepath else {
                return
            }

            audioRecorder = try AVAudioRecorder(url: filepath, settings: settings)
            audioRecorder!.prepareToRecord()
            audioRecorder!.record()
        } catch {
            controller.showToast(withMessage: "Recorder error")
        }
    }
    
    func completeRecordingSession() {
        audioRecorder?.stop()
        
        guard let filepath = audioFilepath, let audioData = try? Data(contentsOf: filepath) else {
            return
        }
        
        Task {
            let result = await controller.roomAPI.uploadAudio(audioData)
            switch result {
            case .success(let audioUrl):
                await sendMessage(audioUrl, kind: .audio)
            case .failure(_):
                await controller.showToast(withMessage: "Audio upload error")
            }
        }
                
        audioRecorder = nil
        audioFilepath = nil
    }
    
    func resetRecordingSession() {
        audioRecorder?.stop()
        audioRecorder = nil
        audioFilepath = nil
    }
}

// MARK: - Media uploading
extension ChatVCViewModel {
    func uploadImage(_ data: Data) {
        print("Upload image")
        Task {
            let result = await controller.roomAPI.uploadImage(data)
            switch result {
            case .success(let imageUrl):
                print("SUCCESS")
                await sendMessage(imageUrl, kind: .image)
            case .failure(let error):
                print("FAILURE", error)
                await controller.showToast(withMessage: "Image upload error")
            }
        }
    }
}
