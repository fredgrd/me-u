//
//  AudioTestVC.swift
//  me&u
//
//  Created by Federico on 20/02/23.
//

import UIKit

class AudioTestVC: UIViewController {
    
    private let viewModel = AudioRecorderViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        viewModel.askPermission()
        
        view.backgroundColor = .white
        
        let upload = UIButton()
        upload.addTarget(self, action: #selector(onUpload), for: .touchUpInside)
        upload.backgroundColor = .yellow
        upload.frame = CGRect(x: 0, y: 0, width: 200, height: 100)
        view.addSubview(upload)
        
        let record = UIButton()
        record.addTarget(self, action: #selector(onRecord), for: .touchUpInside)
        record.backgroundColor = .green
        record.frame = CGRect(x: 0, y: 0, width: 200, height: 100)
        record.center =  CGPoint(x: view.center.x, y: view.center.y-100)
        view.addSubview(record)
        
        let pause = UIButton()
        pause.addTarget(self, action: #selector(onPause), for: .touchUpInside)
        pause.backgroundColor = .orange
        pause.frame = CGRect(x: 0, y: 0, width: 200, height: 100)
        pause.center = CGPoint(x: view.center.x, y: view.center.y)
        view.addSubview(pause)
        
        let stop = UIButton()
        stop.addTarget(self, action: #selector(onStop), for: .touchUpInside)
        stop.backgroundColor = .red
        stop.frame = CGRect(x: 0, y: 0, width: 200, height: 100)
        stop.center = CGPoint(x: view.center.x, y: view.center.y+100)
        view.addSubview(stop)
        
        let startp = UIButton()
        startp.addTarget(self, action: #selector(onStartPlaying), for: .touchUpInside)
        startp.backgroundColor = .systemPink
        startp.frame = CGRect(x: 0, y: 0, width: 200, height: 50)
        startp.center = CGPoint(x: view.center.x, y: view.center.y+250)
        view.addSubview(startp)
        
        let stopp = UIButton()
        stopp.addTarget(self, action: #selector(onStopPlaying), for: .touchUpInside)
        stopp.backgroundColor = .purple
        stopp.frame = CGRect(x: 0, y: 0, width: 200, height: 50)
        stopp.center = CGPoint(x: view.center.x, y: view.center.y+300)
        view.addSubview(stopp)
    }
    
    @objc private func onUpload() {
        Task {
            await viewModel.uploadAudio()
        }
    }
    
    @objc private func onRecord() {
        viewModel.startRecording()
    }
    
    @objc private func onPause() {
        viewModel.pauseRecording()
    }
    
    @objc private func onStop() {
        viewModel.finishRecording()
    }
    
    @objc private func onStartPlaying() {
        viewModel.startPlaying()
    }
    
    @objc private func onStopPlaying() {
        viewModel.stopPlayin()
    }
}
