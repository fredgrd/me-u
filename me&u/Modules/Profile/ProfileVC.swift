//
//  ProfileVC.swift
//  me&us
//
//  Created by Federico on 16/02/23.
//

import UIKit
import Combine

class ProfileVC: UIViewController {
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    private let viewModel: ProfileVCViewModel
    
    private var bag = Set<AnyCancellable>()
    
    // Subviews
    private let headerBar = UIView()
    private let scrollView = UIScrollView()
    private let scrollViewContent = UIView()
    private let goBackButton = IconButton()
    private let userAvatarView = UIView()
    private let userAvatarLabel = UILabel()
    private let userAvatarImage = UIImageView()
    private let pickImageButton = IconButton()

    private let settingsView = UIView()
    private let settingsList = UIStackView()
    private let friendsButton = PVCSettingButton()
    private let contactButton = PVCSettingButton()
    private let signoutButton = PVCSettingButton()
    
    // Init
    init(viewModel: ProfileVCViewModel) {
        self.viewModel = viewModel
       
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        bindUI()
    }
    
    private func bindUI() {
        viewModel.controller.userManager.user.receive(on: RunLoop.main).sink { user in
            guard let user = user else {
                fatalError("Failed to retrieve user")
            }
            
            if user.avatar_url == "none" {
                self.userAvatarLabel.text = user.name.first?.uppercased() ?? ""
                self.userAvatarImage.isHidden = true
                self.userAvatarLabel.text = user.name.first?.uppercased()
            } else {
                self.userAvatarImage.isHidden = false
                self.userAvatarImage.sd_setImage(with: URL(string: user.avatar_url))
            }

            self.pickImageButton.hideSpinner()
        }.store(in: &bag)
        
        goBackButton.onClick.receive(on: RunLoop.main).sink { _ in
            self.viewModel.controller.popViewControllerToLeft()
        }.store(in: &bag)
        
        pickImageButton.onClick.receive(on: RunLoop.main).sink { button in
            if button.isSpinning {
                return
            }
            
            self.presentImagePickerOptions()
        }.store(in: &bag)
        
        friendsButton.onClick.receive(on: RunLoop.main).sink { _ in
            let manageFriendsVM = ManageFriendsVCViewModel(controller: self.viewModel.controller)
            let manageFriendsVC = ManageFriendsVC(viewModel: manageFriendsVM)
            self.present(manageFriendsVC, animated: true)
        }.store(in: &bag)
        
        signoutButton.onClick.receive(on: RunLoop.main).sink { _ in
            self.presentSignoutAlert()
        }.store(in: &bag)
    }
    
    private func imagePicker(sourceType: UIImagePickerController.SourceType) -> UIImagePickerController {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.allowsEditing = true
        imagePicker.sourceType = sourceType
        return imagePicker
    }
    
    private func presentImagePickerOptions() {
        let alertVC = UIAlertController(title: "Change your profile picture", message: "Your profile picture is visible to everyone with your phone number.", preferredStyle: .actionSheet)
        alertVC.overrideUserInterfaceStyle = .dark
        
        // Image picker fro library
        let libraryAction = UIAlertAction(title: "Choose from library", style: .default) { [weak self] action in
            guard let self = self else {
                return
            }
            
            let libraryImagePicker = self.imagePicker(sourceType: .photoLibrary)
            self.present(libraryImagePicker, animated: true)
        }
        
        // Image picker for camera
        let cameraAction = UIAlertAction(title: "Take a photo", style: .default) { [weak self] action in
            guard let self = self else {
                return
            }
            
            let cameraImagePicker = self.imagePicker(sourceType: .camera)
            self.present(cameraImagePicker, animated: true)
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        alertVC.addAction(libraryAction)
        alertVC.addAction(cameraAction)
        alertVC.addAction(cancelAction)
        self.present(alertVC, animated: true)
    }
    
    private func presentSignoutAlert() {
        let alertVC = UIAlertController(title: "Sign out", message: "You will sign out from your profile.", preferredStyle: .alert)
        alertVC.overrideUserInterfaceStyle = .dark
        
        // Image picker fro library
        let signoutAction = UIAlertAction(title: "Sign out", style: .destructive) { [weak self] action in
            guard let self = self else {
                return
            }
            
           self.viewModel.signout()
        }

        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        alertVC.addAction(signoutAction)
        alertVC.addAction(cancelAction)
        self.present(alertVC, animated: true)
    }
}

// MARK: - UIImagePickerControllerDelegate
extension ProfileVC: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        let image = info[.editedImage] as! UIImage
        
        pickImageButton.showSpinner()
        viewModel.uploadImage(image)
        
        picker.dismiss(animated: true)
    }
}

// MARK: - UISetup
private extension ProfileVC {
    func setupUI() {
        view.backgroundColor = .primaryBackground
        
        setupHeaderBar()
        setupScrollView()
        setupUserAvatar()
        setupSettings()
    }
    
    func setupHeaderBar() {
        headerBar.backgroundColor = .primaryBackground
        headerBar.translatesAutoresizingMaskIntoConstraints = false
        let constraints = [
            headerBar.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            headerBar.rightAnchor.constraint(equalTo: view.rightAnchor),
            headerBar.leftAnchor.constraint(equalTo: view.leftAnchor),
            headerBar.heightAnchor.constraint(equalToConstant: 44)]
        
        view.addSubview(headerBar)
        NSLayoutConstraint.activate(constraints)
        
        goBackButton.image = UIImage(named: "right-arrow@24pt")
        goBackButton.tintColor = .primaryLightText
        goBackButton.backgroundColor = .secondaryBackground
        goBackButton.layer.cornerRadius = 22
        goBackButton.translatesAutoresizingMaskIntoConstraints = false
        let buttonConstraints = [
            goBackButton.rightAnchor.constraint(equalTo: headerBar.rightAnchor, constant: -16),
            goBackButton.centerYAnchor.constraint(equalTo: headerBar.centerYAnchor),
            goBackButton.heightAnchor.constraint(equalToConstant: 44),
            goBackButton.widthAnchor.constraint(equalToConstant: 44)]
        
        headerBar.addSubview(goBackButton)
        NSLayoutConstraint.activate(buttonConstraints)
    }
    
    func setupScrollView() {
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        let scrollConstraints = [
            scrollView.topAnchor.constraint(equalTo: headerBar.bottomAnchor),
            scrollView.rightAnchor.constraint(equalTo: view.rightAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            scrollView.leftAnchor.constraint(equalTo: view.leftAnchor)]
        
        view.addSubview(scrollView)
        NSLayoutConstraint.activate(scrollConstraints)
        
        scrollViewContent.translatesAutoresizingMaskIntoConstraints = false
        let contentConstraints = [
            scrollViewContent.topAnchor.constraint(equalTo: scrollView.topAnchor),
            scrollViewContent.rightAnchor.constraint(equalTo: scrollView.rightAnchor),
            scrollViewContent.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            scrollViewContent.leftAnchor.constraint(equalTo: scrollView.leftAnchor),
            scrollViewContent.widthAnchor.constraint(equalTo: scrollView.widthAnchor)]
        
        scrollView.addSubview(scrollViewContent)
        NSLayoutConstraint.activate(contentConstraints)
    }
    
    func setupUserAvatar() {
        userAvatarView.layer.cornerRadius = 50
        userAvatarView.backgroundColor = .secondaryBackground
        userAvatarView.translatesAutoresizingMaskIntoConstraints = false
        let constraints = [
            userAvatarView.topAnchor.constraint(equalTo: scrollViewContent.topAnchor, constant: 25),
            userAvatarView.centerXAnchor.constraint(equalTo: scrollViewContent.centerXAnchor),
            userAvatarView.heightAnchor.constraint(equalToConstant: 120),
            userAvatarView.widthAnchor.constraint(equalToConstant: 120)]
        
        scrollViewContent.addSubview(userAvatarView)
        NSLayoutConstraint.activate(constraints)
        
        // Label
        userAvatarLabel.font = .font(ofSize: 70, weight: .semibold)
        userAvatarLabel.textColor = .primaryLightText
        userAvatarLabel.translatesAutoresizingMaskIntoConstraints = false
        let labelConstraints = [
            userAvatarLabel.centerXAnchor.constraint(equalTo: userAvatarView.centerXAnchor),
            userAvatarLabel.centerYAnchor.constraint(equalTo: userAvatarView.centerYAnchor)]
        
        userAvatarView.addSubview(userAvatarLabel)
        NSLayoutConstraint.activate(labelConstraints)
       
        userAvatarImage.layer.cornerRadius = 50
        userAvatarImage.contentMode = .scaleAspectFill
        userAvatarImage.layer.masksToBounds = true
        userAvatarImage.translatesAutoresizingMaskIntoConstraints = false
        let imageConstraints = [
            userAvatarImage.topAnchor.constraint(equalTo: userAvatarView.topAnchor),
            userAvatarImage.rightAnchor.constraint(equalTo: userAvatarView.rightAnchor),
            userAvatarImage.bottomAnchor.constraint(equalTo: userAvatarView.bottomAnchor),
            userAvatarImage.leftAnchor.constraint(equalTo: userAvatarView.leftAnchor)]
        
        userAvatarView.addSubview(userAvatarImage)
        NSLayoutConstraint.activate(imageConstraints)
        

        pickImageButton.spinnerColor = .primaryDarkText
        pickImageButton.layer.cornerRadius = 15
        pickImageButton.backgroundColor = .primaryHighlight
        pickImageButton.image = UIImage(named: "plus@15pt")
        pickImageButton.tintColor = .primaryDarkText
        pickImageButton.translatesAutoresizingMaskIntoConstraints = false
        let buttonConstraints = [
            pickImageButton.rightAnchor.constraint(equalTo: userAvatarView.rightAnchor),
            pickImageButton.bottomAnchor.constraint(equalTo: userAvatarView.bottomAnchor),
            pickImageButton.heightAnchor.constraint(equalToConstant: 30),
            pickImageButton.widthAnchor.constraint(equalToConstant: 30)]
        
        userAvatarView.addSubview(pickImageButton)
        NSLayoutConstraint.activate(buttonConstraints)
    }
    
    private func setupSettings() {
        settingsView.layer.cornerRadius = 17
        settingsView.backgroundColor = .secondaryBackground
        settingsView.translatesAutoresizingMaskIntoConstraints = false
        let viewConstraints = [
            settingsView.topAnchor.constraint(equalTo: userAvatarView.bottomAnchor, constant: 20),
            settingsView.rightAnchor.constraint(equalTo: scrollViewContent.rightAnchor, constant: -16),
            settingsView.bottomAnchor.constraint(equalTo: scrollViewContent.bottomAnchor),
            settingsView.leftAnchor.constraint(equalTo: scrollViewContent.leftAnchor, constant: 16)]
        
        scrollViewContent.addSubview(settingsView)
        NSLayoutConstraint.activate(viewConstraints)
        
        // Friends
        friendsButton.title = "Friends"
        friendsButton.image = UIImage(named: "hearth@18pt")
        friendsButton.translatesAutoresizingMaskIntoConstraints = false
        let friendsConstraints = [
            friendsButton.topAnchor.constraint(equalTo: settingsView.topAnchor),
            friendsButton.rightAnchor.constraint(equalTo: settingsView.rightAnchor),
            friendsButton.leftAnchor.constraint(equalTo: settingsView.leftAnchor),
            friendsButton.heightAnchor.constraint(equalToConstant: 70)]
        
        settingsView.addSubview(friendsButton)
        NSLayoutConstraint.activate(friendsConstraints)
        
        // Contact
        contactButton.title = "Contact us"
        contactButton.image = UIImage(named: "message-bubble@18pt")
        contactButton.translatesAutoresizingMaskIntoConstraints = false
        let contactConstraints = [
            contactButton.topAnchor.constraint(equalTo: friendsButton.bottomAnchor),
            contactButton.rightAnchor.constraint(equalTo: settingsView.rightAnchor),
            contactButton.leftAnchor.constraint(equalTo: settingsView.leftAnchor),
            contactButton.heightAnchor.constraint(equalToConstant: 70)]
        
        settingsView.addSubview(contactButton)
        NSLayoutConstraint.activate(contactConstraints)
        
        // Friends
        signoutButton.title = "Sign out"
        signoutButton.image = UIImage(named: "trash@18pt")
        signoutButton.translatesAutoresizingMaskIntoConstraints = false
        let signoutConstraints = [
            signoutButton.topAnchor.constraint(equalTo: contactButton.bottomAnchor),
            signoutButton.rightAnchor.constraint(equalTo: settingsView.rightAnchor),
            signoutButton.bottomAnchor.constraint(equalTo: settingsView.bottomAnchor),
            signoutButton.leftAnchor.constraint(equalTo: settingsView.leftAnchor),
            signoutButton.heightAnchor.constraint(equalToConstant: 70)]
        
        settingsView.addSubview(signoutButton)
        NSLayoutConstraint.activate(signoutConstraints)
    }
}
