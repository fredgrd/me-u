//
//  ViewController.swift
//  me&us
//
//  Created by Federico on 02/02/23.
//

import UIKit

struct Number: Codable {
    let number: String
}

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        view.backgroundColor = .red
        
        let button = UIButton(frame: CGRect(x: 100, y: 100, width: 200, height: 200))
        button.backgroundColor = .white
        button.addTarget(self, action: #selector(onClick), for: .touchUpInside)
        view.addSubview(button)
    }
    
    @objc private func onClick() {
        let authService = AuthAPI()
        
        Task {
//            await authService.startVerification()
            do {
                let number = Number(number: "+393478842092")
                guard let url = URL(string: "https://api.dinolab.one/auth/start"), let data = try? JSONEncoder().encode(number) else {
                    return
                }
                
                print("DATA", data)
                
                var request = URLRequest(url: url)
                request.httpMethod = "POST"
                request.httpBody = data
                request.addValue("application/json", forHTTPHeaderField: "Content-Type")
                request.addValue("application/json", forHTTPHeaderField: "Accept")
            
                let (dataresponse, response) = try await URLSession.shared.data(for: request)
                print("DATA", dataresponse, String(decoding: dataresponse, as: UTF8.self))
                let castedResponse = response as? HTTPURLResponse
                print("RESPONSE", castedResponse?.statusCode, castedResponse)
                
                
////                let (data, response) = try await URLSession.shared.data(from: url)
////
////
////
////
//
//                var request = URLRequest(url: url)
//                request.httpMethod = "POST"
//
//                let (data, response) = try await URLSession.shared.u
            } catch {
                print("ERROR", error)
            }
            
        }
       
    }
}

