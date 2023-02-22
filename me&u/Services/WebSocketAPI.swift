//
//  WebSocketAPI.swift
//  me&us
//
//  Created by Federico on 13/02/23.
//

import Foundation

final class WebSocketAPI: NSObject {
    
    enum SocketResultKind {
        case message
        case update
    }
    
    struct SocketResult {
        let kind: SocketResultKind
        let update: RoomUpdate?
        let message: RoomMessage?
    }
    
    var webSocket: URLSessionWebSocketTask?

    var opened: Bool = false
    
    var timer: Timer?
    
    override init() {
        // no-op
    }
    
    deinit {
        timer?.invalidate()
    }
    
    func subscribeToRoom(roomID room: String, userID user: String, completion: @escaping ((SocketResult?) -> Void)) {
        if !opened {
            openWebSocket(roomID: room, userID: user)
        }
        
        guard let webSocket = webSocket else {
            completion(nil)
            return
        }
        
        webSocket.receive { [weak self] result in
            switch result {
            case .success(let message):
                switch message {
                case .string(let messageString):
                    if let jsonData = messageString.data(using: .utf8), let roomMessage = try? JSONDecoder().decode(RoomMessage.self, from: jsonData) {
                        completion(SocketResult(kind: .message, update: nil, message: roomMessage))
                    } else if let jsonData = messageString.data(using: .utf8), let roomUpdate = try? JSONDecoder().decode(RoomUpdate.self, from: jsonData) {
                        completion(SocketResult(kind: .update, update: roomUpdate, message: nil))
                    } else {
                        completion(nil)
                    }
                    
                    self?.subscribeToRoom(roomID: room, userID: user, completion: completion)
                default:
                    completion(nil)
                }
            case .failure(_):
                completion(nil)
            }
        }
    }
    
    func sendMessage(_ message: RoomMessage) {
        guard let webSocket = webSocket else {
            return
        }
        
        guard let data = try? JSONSerialization.data(withJSONObject: ["sender": message.sender, "sender_name": message.sender_name, "sender_number": message.sender_number, "sender_thumbnail": message.sender_thumbnail,  "message": message.message, "kind": message.kind.rawValue ], options: .prettyPrinted), let string = String(data: data, encoding: .utf8) else {
            return
        }
        
        webSocket.send(URLSessionWebSocketTask.Message.string(string)) { error in
            if let error {
                print("WebSocketAPI/sendMessage error: \(error)")
            }
        }
    }
    
    func sendUpdate(_ update: RoomUpdate) {
        guard let webSocket = webSocket else {
            return
        }
        
        guard let data = try? JSONSerialization.data(withJSONObject: ["kind": update.kind.rawValue, "sender_name": update.sender_name], options: .prettyPrinted), let string = String(data: data, encoding: .utf8) else {
            return
        }
        
        webSocket.send(URLSessionWebSocketTask.Message.string(string)) { error in
            if let error {
                print("WebSocketAPI/sendMessage error: \(error)")
            }
        }
    }
    
    private func openWebSocket(roomID room: String, userID user: String) {
        if let url = URL(string: "wss://api.dinolab.one/websockets/room?room_id=\(room)&user_id=\(user)") {
            let request = URLRequest(url: url)
            let session = URLSession(configuration: .default, delegate: self, delegateQueue: nil)
            let webSocket = session.webSocketTask(with: request)
            self.webSocket = webSocket
            self.opened = true
            self.webSocket?.resume()
            self.setPingTimer()
        } else {
            webSocket = nil
        }
    }
    
    private func setPingTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 40.0, repeats: true) { [weak self] timer in
            self?.webSocket?.sendPing(pongReceiveHandler: { error in
                print("PING")
                if let error = error {
                    print("Failed with Error \(error.localizedDescription)")
                    print("PING")
                } else {
                    // no-op
                }
            })
        }
        
        timer?.fire()
    }
    
    func closeWebSocket() {
        webSocket?.cancel(with: .goingAway, reason: nil)
        webSocket = nil
        opened = false
    }
}

extension WebSocketAPI: URLSessionWebSocketDelegate {
    func urlSession(_ session: URLSession, webSocketTask: URLSessionWebSocketTask, didOpenWithProtocol protocol: String?) {
        opened = true
    }
    
    func urlSession(_ session: URLSession, didBecomeInvalidWithError error: Error?) {
        print("IVALID WITH ERROR")
    }

    
    func urlSession(_ session: URLSession, webSocketTask: URLSessionWebSocketTask, didCloseWith closeCode: URLSessionWebSocketTask.CloseCode, reason: Data?) {
        print("CLOSED")
        self.webSocket = nil
        self.opened = false
    }
}

