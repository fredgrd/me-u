//
//  ContactsVC.swift
//  me&us
//
//  Created by Federico on 07/02/23.
//

import UIKit
import Combine

typealias DataSource = UICollectionViewDiffableDataSource<ContactsVCViewModel.ContactSection, Contact>
typealias Snapshot = NSDiffableDataSourceSnapshot<ContactsVCViewModel.ContactSection, Contact>

class ContactsVC: UIViewController {
    
    let viewModel: ContactsVCViewModel
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    // Subscribers
    private var bag = Set<AnyCancellable>()
    
    // Subviews
    private let navigationBar = UIView()
    private let titleBar = UIView()
    private let dynamicSubtitle = DynamicLabel(staticText: "Add your ")
    private let searchBar = UIView()
    private let searchField = UITextField()
    private var contactsCollection: UICollectionView!
    private var contactsDataSource: DataSource!

    
    init(viewModel: ContactsVCViewModel) {
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
        
        Task {
            await viewModel.fetchAllContacts()
        }
        
        bindUI()
        setupDataSource()
    }
    
    private func bindUI() {
        viewModel.contacts.receive(on: DispatchQueue.main).sink { contacts in
            self.updateContactsSnapshot(contacts)
        }.store(in: &bag)
    }
    
    private func setupDataSource() {
        contactsDataSource = DataSource(collectionView: contactsCollection) { collectionView, indexPath, contact in
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: FVCContactCell.identifier, for: indexPath) as?
                    FVCContactCell else {
                fatalError("Failed to dequeue \(FVCContactCell.debugDescription())")
            }
            
            cell.update(withContact: contact)
            
            return cell
        }
        
        contactsDataSource.supplementaryViewProvider = { collectionView, kind, indexPath in
            guard kind == UICollectionView.elementKindSectionHeader else {
                return nil
            }
            
            guard let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: ContactSectionHeader.identifier, for: indexPath) as? ContactSectionHeader else {
                fatalError("Failed to dequeue \(ContactSectionHeader.debugDescription())")
            }
            
            let section = self.contactsDataSource.snapshot().sectionIdentifiers[indexPath.section]
            
            if section == .requests {
                header.update(withTitle: section.rawValue, icon: UIImage(named: "checkmark@22pt"))
            }
            
            if section == .contacts {
                header.update(withTitle: section.rawValue, icon: UIImage(named: "message-bubble@22pt"))
            }
            
            return header
        }
    }
    
    private func updateContactsSnapshot(_ contacts: [Contact]) {
        var snapshot = Snapshot()
        
//        let requests = contacts.filter({ $0.friend_request })
//        if (!requests.isEmpty) {
//            snapshot.appendSections([.requests])
//            snapshot.appendItems(requests, toSection: .requests)
//        }
//        
//        let friends = contacts.filter({ !$0.friend_request })
//        snapshot.appendSections([.contacts])
//        snapshot.appendItems(friends, toSection: .contacts)
        
        contactsDataSource.apply(snapshot)
    }
    
    private func addContact(number: String) {
        
    }
}

extension ContactsVC: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: view.frame.width, height: 55)
    }
}

// MARK: - UISetup
private extension ContactsVC {
    func setupUI() {
        view.backgroundColor = .primaryBackground
        view.layer.cornerRadius = 40
        
        setupNavigationBar()
        setupTitleBar()
        setupDynamicSubtitle()
        setupSearchBar()
        setupContactsCollection()
    }
    
    func setupNavigationBar() {
        navigationBar.backgroundColor = nil
        navigationBar.translatesAutoresizingMaskIntoConstraints = false
        let constraints = [
            navigationBar.leftAnchor.constraint(equalTo: view.leftAnchor),
            navigationBar.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            navigationBar.rightAnchor.constraint(equalTo: view.rightAnchor),
            navigationBar.heightAnchor.constraint(equalToConstant: 30)]
        
        view.addSubview(navigationBar)
        NSLayoutConstraint.activate(constraints)
        
        let dragbar = UIView()
        dragbar.layer.cornerRadius = 2.5
        dragbar.backgroundColor = .secondaryDarkText
        dragbar.translatesAutoresizingMaskIntoConstraints = false
        let dragbarConstraints = [
            dragbar.centerXAnchor.constraint(equalTo: navigationBar.centerXAnchor),
            dragbar.centerYAnchor.constraint(equalTo: navigationBar.centerYAnchor),
            dragbar.heightAnchor.constraint(equalToConstant: 5),
            dragbar.widthAnchor.constraint(equalToConstant: 34)]
        
        view.addSubview(dragbar)
        NSLayoutConstraint.activate(dragbarConstraints)
    }
    
    func setupTitleBar() {
        titleBar.translatesAutoresizingMaskIntoConstraints = false
        let constraints = [
            titleBar.leftAnchor.constraint(equalTo: view.leftAnchor),
            titleBar.topAnchor.constraint(equalTo: navigationBar.bottomAnchor),
            titleBar.rightAnchor.constraint(equalTo: view.rightAnchor),
            titleBar.heightAnchor.constraint(equalToConstant: 50)]
        
        view.addSubview(titleBar)
        NSLayoutConstraint.activate(constraints)
        
        let titleLabel = UILabel()
        titleLabel.font = .font(ofSize: 21, weight: .bold)
        titleLabel.textColor = .primaryText
        titleLabel.textAlignment = .center
        titleLabel.text = "Pick your best friends"
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        let titleConstraints = [
            titleLabel.leftAnchor.constraint(equalTo: titleBar.leftAnchor, constant: 16),
            titleLabel.rightAnchor.constraint(equalTo: titleBar.rightAnchor, constant: -16),
            titleLabel.centerYAnchor.constraint(equalTo: titleBar.centerYAnchor)]
        
        titleBar.addSubview(titleLabel)
        NSLayoutConstraint.activate(titleConstraints)
        
    }
    
    func setupDynamicSubtitle() {
        dynamicSubtitle.setDynamicText("best 🙋‍♂️")
        dynamicSubtitle.translatesAutoresizingMaskIntoConstraints = false
        let constraints = [
            dynamicSubtitle.topAnchor.constraint(equalTo: titleBar.bottomAnchor),
            dynamicSubtitle.centerXAnchor.constraint(equalTo: view.centerXAnchor)]
        
        view.addSubview(dynamicSubtitle)
        NSLayoutConstraint.activate(constraints)
        
        // Animate
        let values = ["siblings 👧👦", "special 😉","bro 😎", "❤️", "sis 😎", "🐶", "best 🙋‍♂️"]
        var count = 0
        _ = Timer.scheduledTimer(withTimeInterval: 5, repeats: true) { _ in
            self.dynamicSubtitle.animateChange(withText: values[count])
            count = count + 1 >= values.count ? 0 : count + 1
        }
    }
    
    func setupSearchBar() {
        searchBar.layer.cornerRadius = 17
        searchBar.backgroundColor = .secondaryBackground
        searchBar.translatesAutoresizingMaskIntoConstraints = false
        let barConstraints = [
            searchBar.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 16),
            searchBar.topAnchor.constraint(equalTo: dynamicSubtitle.bottomAnchor, constant: 25),
            searchBar.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -16),
            searchBar.heightAnchor.constraint(equalToConstant: 50)]
        
        view.addSubview(searchBar)
        NSLayoutConstraint.activate(barConstraints)
        
        searchField.font = .font(ofSize: 17, weight: .semibold)
        searchField.textColor = .primaryText
        searchField.textAlignment = .center
        searchField.attributedPlaceholder = NSAttributedString(string: "Add a new friend", attributes: [.font: UIFont.font(ofSize: 17, weight: .semibold), .foregroundColor: UIColor.primaryText])
        searchField.translatesAutoresizingMaskIntoConstraints = false
        let fieldConstraints = [
            searchField.leftAnchor.constraint(equalTo: searchBar.leftAnchor, constant: 12),
            searchField.topAnchor.constraint(equalTo: searchBar.topAnchor),
            searchField.rightAnchor.constraint(equalTo: searchBar.rightAnchor, constant: -12),
            searchField.bottomAnchor.constraint(equalTo: searchBar.bottomAnchor)]
        
        searchBar.addSubview(searchField)
        NSLayoutConstraint.activate(fieldConstraints)
    }
    
    func setupContactsCollection() {
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: view.frame.width, height: 75)
        layout.scrollDirection = .vertical
        layout.minimumLineSpacing = 0
  
        contactsCollection = UICollectionView(frame: .zero, collectionViewLayout: layout)
        contactsCollection.delegate = self
        contactsCollection.register(FVCContactCell.self, forCellWithReuseIdentifier: FVCContactCell.identifier)
        contactsCollection.register(ContactSectionHeader.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: ContactSectionHeader.identifier)
        contactsCollection.backgroundColor = .primaryBackground
        contactsCollection.translatesAutoresizingMaskIntoConstraints = false
        let constraints = [
            contactsCollection.leftAnchor.constraint(equalTo: view.leftAnchor),
            contactsCollection.topAnchor.constraint(equalTo: searchBar.bottomAnchor, constant: 2),
            contactsCollection.rightAnchor.constraint(equalTo: view.rightAnchor),
            contactsCollection.bottomAnchor.constraint(equalTo: view.bottomAnchor)]
        
        view.addSubview(contactsCollection)
        NSLayoutConstraint.activate(constraints)
    }
}
