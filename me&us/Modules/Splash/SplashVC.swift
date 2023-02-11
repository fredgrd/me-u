//
//  SplashVC.swift
//  me&us
//
//  Created by Federico on 02/02/23.
//

import UIKit

class SplashVC: UIViewController {
    
    private let viewModel: SplashVCViewModel
    
    init(viewModel: SplashVCViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .init(hex: "#FCF6EF")
        
        print("VIEW DID LOAD")
        
        viewModel.fetchUser()
    }
    
    // Check for token, if no token go to 
}
