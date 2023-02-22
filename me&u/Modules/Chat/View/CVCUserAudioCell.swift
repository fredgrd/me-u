//
//  CVCUserAudioCell.swift
//  me&u
//
//  Created by Federico on 21/02/23.
//

import UIKit
import AVFoundation

class CVCUserAudioCell: UICollectionViewCell {
    static let identifier = "CVCUserAudioCell"
    
    // Audioplayer
    private var audioPlayer: AVPlayer?
    private var isAudioPlaying: Bool = false
    private var audioDuration: Double = 0
    private var audioTimeLeft: Double = 0
    private var audioTimer: Timer?
    
    // Formatter
    private let formatter = DateComponentsFormatter()
    
    // Subviews
    private let bubbleView = UIView()
    private let bubbleImage = UIImageView()
    
    private var audioPlayerButton = UIButton()
    private var audioDurationLabel = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
        
        formatter.zeroFormattingBehavior = [.pad]
        formatter.allowedUnits = [.minute, .second]
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func update(_ audioUrl: String, showAvatar: Bool) {
        if showAvatar {
            bubbleImage.image = UIImage(named: "chat-bubble-rx@40pt")?.resizableImage(withCapInsets: UIEdgeInsets(top: 20, left: 24, bottom: 20, right: 24), resizingMode: .stretch)
        } else {
            bubbleImage.image = UIImage(named: "chat-bubble-rx-notail@40pt")?.resizableImage(withCapInsets: UIEdgeInsets(top: 20, left: 24, bottom: 20, right: 24), resizingMode: .stretch)
        }
        
        guard let url = URL(string: audioUrl) else {
            return
        }
        
        prepareAudioPlayer(url)
    }
}

// MARK: - Helpers
private extension CVCUserAudioCell {
    func prepareAudioPlayer(_ url: URL) {
        audioPlayer = AVPlayer(url: url)
        audioPlayer?.volume = 1
        
        Task {
            guard let duration = try? await audioPlayer?.currentItem?.asset.load(.duration).seconds else {
                return
            }
            
            audioDuration = duration
            audioTimeLeft = duration
            audioDurationLabel.text = formatter.string(from: TimeInterval(duration))
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(audioOnEnd), name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: audioPlayer?.currentItem)
    }
    
    @objc func audioOnTap() {
        guard let audioPlayer = audioPlayer else {
            return
        }
        
        if isAudioPlaying {
            audioPlayer.pause()
            audioPlayer.seek(to: CMTime.zero)
            isAudioPlaying = false
            audioPlayerButton.isSelected = false
            
            // Reset timer
            audioTimer?.invalidate()
            audioTimer = nil
            audioDurationLabel.text = formatter.string(from: TimeInterval(audioDuration))
            audioTimeLeft = audioDuration
        } else {
            audioPlayer.play()
            isAudioPlaying = true
            audioPlayerButton.isSelected = true
            
            // Timer
            audioTimer = Timer(timeInterval: 1, repeats: true, block: { [weak self] timer in
                guard let self = self else {
                    return
                }
                
                self.audioTimeLeft -= 1
                
                if self.audioTimeLeft > 0 {
                    self.audioDurationLabel.text = self.formatter.string(from: TimeInterval(self.audioTimeLeft))
                } else {
                    self.audioDurationLabel.text = self.formatter.string(from: TimeInterval(0))
                }
            })
            
            RunLoop.main.add(audioTimer!, forMode: .default)
        }
    }
    
    @objc func audioOnEnd() {
        audioPlayer?.pause()
        audioPlayer?.seek(to: CMTime.zero)
        isAudioPlaying = false
        audioPlayerButton.isSelected = false
        audioTimeLeft = audioDuration
        
        // Reset timer
        audioTimer?.invalidate()
        audioTimer = nil
        audioDurationLabel.text = formatter.string(from: TimeInterval(audioDuration))
    }
}

// MARK: - UISetup
private extension CVCUserAudioCell {
    func setupUI() {
        setupBubble()
        setupBubbleImage()
        setupAudioPlayer()
    }
    
    func setupBubble() {
        bubbleView.translatesAutoresizingMaskIntoConstraints = false
        let constraints = [
            bubbleView.topAnchor.constraint(equalTo: contentView.topAnchor),
            bubbleView.rightAnchor.constraint(equalTo: contentView.rightAnchor, constant: -12),
            bubbleView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            bubbleView.leftAnchor.constraint(greaterThanOrEqualTo: contentView.leftAnchor, constant: 60)]
        
        contentView.addSubview(bubbleView)
        NSLayoutConstraint.activate(constraints)
    }
    
    func setupBubbleImage() {
        bubbleImage.translatesAutoresizingMaskIntoConstraints = false
        let constraints = [
            bubbleImage.topAnchor.constraint(equalTo: bubbleView.topAnchor),
            bubbleImage.rightAnchor.constraint(equalTo: bubbleView.rightAnchor),
            bubbleImage.bottomAnchor.constraint(equalTo: bubbleView.bottomAnchor),
            bubbleImage.leftAnchor.constraint(equalTo: bubbleView.leftAnchor)]
        
        bubbleView.addSubview(bubbleImage)
        NSLayoutConstraint.activate(constraints)
    }
    
    func setupAudioPlayer() {
        audioPlayerButton.addTarget(self, action: #selector(audioOnTap), for: .touchUpInside)
        audioPlayerButton.setImage(UIImage(named: "play@24pt"), for: .normal)
        audioPlayerButton.setImage(UIImage(named: "stop@24pt"), for: .selected)
        audioPlayerButton.tintColor = .primaryDarkText
        audioPlayerButton.layer.cornerRadius = 15
        audioPlayerButton.backgroundColor = .white
        audioPlayerButton.translatesAutoresizingMaskIntoConstraints = false
        let buttonConstraints = [
            audioPlayerButton.leftAnchor.constraint(equalTo: bubbleView.leftAnchor, constant: 10),
            audioPlayerButton.centerYAnchor.constraint(equalTo: bubbleView.centerYAnchor),
            audioPlayerButton.heightAnchor.constraint(equalToConstant: 30),
            audioPlayerButton.widthAnchor.constraint(equalToConstant: 30)]
        
        bubbleView.addSubview(audioPlayerButton)
        NSLayoutConstraint.activate(buttonConstraints)
        
        // Label
        audioDurationLabel.font = .font(ofSize: 15, weight: .medium)
        audioDurationLabel.textColor = .white
        audioDurationLabel.textAlignment = .center
        audioDurationLabel.translatesAutoresizingMaskIntoConstraints = false
        let labelConstraints = [
            audioDurationLabel.rightAnchor.constraint(equalTo: bubbleView.rightAnchor, constant: -16),
            audioDurationLabel.leftAnchor.constraint(equalTo: audioPlayerButton.rightAnchor, constant: 10),
            audioDurationLabel.widthAnchor.constraint(equalToConstant: 45),
            audioDurationLabel.centerYAnchor.constraint(equalTo: bubbleView.centerYAnchor)]
        
        bubbleView.addSubview(audioDurationLabel)
        NSLayoutConstraint.activate(labelConstraints)
    }
}
