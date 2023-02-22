//
//  AudioRecorder+ViewModel.swift
//  me&u
//
//  Created by Federico on 20/02/23.
//

import Foundation
import AVFoundation
import Combine

class AudioRecorderViewModel: NSObject {
    var audioRecorder: AVAudioRecorder?
    var audioPlayer: AVAudioPlayer!
    
    var filename: URL?
    
    struct AudioResponse: Codable {
        let audio_url: String
    }
    
    override init() {
        super.init()
    }
    
    func askPermission() {
        AVAudioSession.sharedInstance().requestRecordPermission { bool in
            print("PERMISSION", bool)
        }
    }
    
    
    func startRecording() {
        if let audioRecorder = audioRecorder {
            audioRecorder.prepareToRecord()
            audioRecorder.record()
            return
        }
        
        print("WORKING 1")
        let recordingSession = AVAudioSession.sharedInstance()
        do {
            try recordingSession.setCategory(.playAndRecord, mode: .default)
            try recordingSession.setActive(true)
        } catch {
            print("Can not setup the Recording")
        }
        print("WORKING 2")
        let path = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        filename = path.appending(path: "\(UUID().uuidString).m4a")
        print("WORKING 3")
        let settings = [
            AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
            AVSampleRateKey: 12000,
            AVNumberOfChannelsKey: 1,
            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
        ]
        print("WORKING 4")
        do {
            // See Apple API reference for details of settings
            audioRecorder = try AVAudioRecorder(url: filename!, settings: settings)
            audioRecorder!.delegate = self
            audioRecorder!.prepareToRecord()
            audioRecorder!.record()
            print("WORKING 5")
        } catch {
//            finishRecording()
            print("Error recording")
        }
        print("WORKING 6")
    }
    
    func pauseRecording(){
        audioRecorder?.pause()
//        isRecording = false
    }
    
    func finishRecording() {
        audioRecorder?.stop()
        audioRecorder = nil
    }
    
    func startPlaying() {
        let playSession = AVAudioSession.sharedInstance()
        
        do {
            try playSession.overrideOutputAudioPort(AVAudioSession.PortOverride.speaker)
        } catch {
            print("Playing failed in Device")
        }
        
        do {
            audioPlayer = try AVAudioPlayer(contentsOf : filename!)
            
            audioPlayer!.prepareToPlay()
            audioPlayer!.play()
        } catch {
            print("Playing Failed")
        }
    }
    
    func stopPlayin() {
        audioPlayer?.stop()
    }
    
    func uploadAudio(paramName: String = "audiofile") async {
        let url = URL(string: "https://api.dinolab.one/room/audio-upload")
        // generate boundary string using a unique per-app string
        let boundary = UUID().uuidString
        
//        let session = URLSession.shared
        
        // Set the URLRequest to POST and to the specified URL
        var urlRequest = URLRequest(url: url!)
        urlRequest.httpMethod = "POST"
        
        urlRequest.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")

        guard let audioData = try? Data(contentsOf: filename!) else { return }

        var data = Data()
        
        data.append("\r\n--\(boundary)\r\n".data(using: .utf8)!)
        data.append("Content-Disposition: form-data; name=\"\(paramName)\"; filename=\"audio\"\r\n".data(using: .utf8)!)
        data.append("Content-Type: image/png\r\n\r\n".data(using: .utf8)!)
        data.append(audioData)
        
        data.append("\r\n--\(boundary)--\r\n".data(using: .utf8)!)
        
        urlRequest.httpBody = data
        
        do {
            let (responseData, response) = try await URLSession.shared.data(for: urlRequest)
            guard let response = response as? HTTPURLResponse else {
                print("NO RESPONSE")
                return
            }
            
            print("responsedata", responseData)
            
            if (response.statusCode == 200) {
                guard let audio = try? JSONDecoder().decode(AudioResponse.self, from: responseData) else {
                    print("BAD RESPONSE")
                    return
                }
                
                print("SUCCESS", audio)
                return
            } else if (response.statusCode == 400) {
                print("400")
                return
            } else {
                print("ELSE ERROR")
                return
            }
        } catch {
            print("UPLOAD ERROR")
        }
    }
}

extension AudioRecorderViewModel: AVAudioRecorderDelegate {
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        print("Finished recording")
    }
    
    func audioRecorderEncodeErrorDidOccur(_ recorder: AVAudioRecorder, error: Error?) {
        print("ERROR", error)
    }
}
