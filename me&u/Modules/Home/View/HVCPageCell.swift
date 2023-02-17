//
//  HVCPageCell.swift
//  me&us
//
//  Created by Federico on 12/02/23.
//

import UIKit

class HVCPageCell: UICollectionViewCell {
    static let identifier = "HVCPageCell"
    
    private var userPage: UserPage?
    private var friendPage: FriendPage?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        userPage?.removeFromSuperview()
        friendPage?.removeFromSuperview()
    }
    
    func update(withKind kind: HomeVCViewModel.PageKind, friend: UserFriendDetails? = nil, in viewController: HomeVC, controller: MainController) {
        switch kind {
        case .user:
            let userPageVM = UserPageViewModel(home: viewController, controller: controller)
            userPage = UserPage(viewModel: userPageVM)
            userPage!.translatesAutoresizingMaskIntoConstraints = false
            let constraints = [
                userPage!.leftAnchor.constraint(equalTo: contentView.leftAnchor),
                userPage!.topAnchor.constraint(equalTo: contentView.topAnchor),
                userPage!.rightAnchor.constraint(equalTo: contentView.rightAnchor),
                userPage!.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)]
            
            contentView.addSubview(userPage!)
            NSLayoutConstraint.activate(constraints)
        case .friend:
            let friendPageVM = FriendPageViewModel(friend: friend!, home: viewController, controller: controller)
            friendPage = FriendPage(viewModel: friendPageVM)
            friendPage!.translatesAutoresizingMaskIntoConstraints = false
            let constraints = [
                friendPage!.leftAnchor.constraint(equalTo: contentView.leftAnchor),
                friendPage!.topAnchor.constraint(equalTo: contentView.topAnchor),
                friendPage!.rightAnchor.constraint(equalTo: contentView.rightAnchor),
                friendPage!.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)]
            
            contentView.addSubview(friendPage!)
            NSLayoutConstraint.activate(constraints)
        }
    }
    
    func willDisplay() {
        if let userPage = userPage {
            userPage.willDisplay()
        }
        
        if let friendPage = friendPage {
            friendPage.willDisplay()
        }
    }
}
