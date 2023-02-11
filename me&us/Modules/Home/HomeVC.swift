//
//  HomeVC.swift
//  me&us
//
//  Created by Federico on 10/02/23.
//

import UIKit

class HomeVC: UIViewController {
    
    private let viewModel: HomeVCViewModel
    
    // Init
    required init(viewModel: HomeVCViewModel) {
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
        print("HOME VC")
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        let friendsVM = FriendsVCViewModel(controller: viewModel.controller)
        let friendsVC = FriendsVC(viewModel: friendsVM)
        friendsVC.modalTransitionStyle = .coverVertical
        self.present(friendsVC, animated: true)
    }
}

// MARK: - UISetup
private extension HomeVC {
    func setupUI() {
        view.backgroundColor = .primaryBackground
    }
}
