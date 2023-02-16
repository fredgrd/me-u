//
//  FriendsVC+ViewModel.swift
//  me&us
//
//  Created by Federico on 10/02/23.
//

import Foundation
import Combine
import Contacts
import PhoneNumberKit
import UIKit

class FriendsVCViewModel {
    
    enum Section: String, Hashable {
        case receivedRequests = "Received Requests"
        case sentRequests = "Sent Requests"
        case contacts = "Contacts"
    }
    
    let controller: MainController
    
    let contactStore = CNContactStore()
    var contacts = [Contact]()
    let contactsAuthorizationStatus: CurrentValueSubject<CNAuthorizationStatus, Never>
    
    let models = CurrentValueSubject<FVCCollectionModels, Never>(FVCCollectionModels())
    
    private let phoneNumberKit = PhoneNumberKit()
    
    init(controller: MainController) {
        self.controller = controller
        
        contactsAuthorizationStatus = CurrentValueSubject<CNAuthorizationStatus, Never>(CNContactStore.authorizationStatus(for: .contacts))
    }
    
    func requestContactsAccess() {
        switch contactsAuthorizationStatus.value {
        case .notDetermined:
            contactStore.requestAccess(for: .contacts) { [weak self] complete, error in
                let authStatus = CNContactStore.authorizationStatus(for: .contacts)
                self?.contactsAuthorizationStatus.send(authStatus)
            }
        case .restricted, .denied:
            guard let settingsUrl = URL(string: UIApplication.openSettingsURLString) else {
                return
            }
            
            if UIApplication.shared.canOpenURL(settingsUrl) {
                UIApplication.shared.open(settingsUrl, completionHandler: { (success) in
                    print("Settings opened: \(success)") // Prints true
                })
            }
        case .authorized:
            let authStatus = CNContactStore.authorizationStatus(for: .contacts)
            self.contactsAuthorizationStatus.send(authStatus)
        @unknown default:
            fatalError("Unknown CNAuthorizationStatus")
        }
    }

    func addContact(_ contact: Contact) async {
        let result = await controller.userAPI.createFriendRequest(withTarget: contact.number)
        switch result {
        case .success(_):
            await updateRequestsModel()
        case .failure(let error):
            switch error {
            case .userError:
                await controller.showToast(withMessage: ToastErrorMessage.Generic.rawValue)
            default:
                await controller.showToast(withMessage: ToastErrorMessage.InternalServer.rawValue)
            }
        }
    }
    
    func updateRequest(_ id: String, update: FriendRequestUpdate) async {
        let updateResult = await controller.userAPI.updateFriendRequest(withID: id, update: update)
        switch updateResult {
        case .success(let update):
            if (update == .accept) {
                let userResult = await controller.userAPI.fetchUser()
                switch userResult {
                case .success(let user):
                    controller.userManager.user.send(user)
                    await updateContactsModel()
                    await updateRequestsModel()
                case .failure(_):
                    await controller.showToast(withMessage: ToastErrorMessage.Generic.rawValue)
                }
            } else {
                await updateRequestsModel()
            }
        case .failure(_):
            await controller.showToast(withMessage: ToastErrorMessage.Generic.rawValue)
        }
    }
    
    // Fetch models
    // Friends
    // Requests
    // Contacts
    func updateContactsModel() async {
        contacts = await fetchContacts()
        
        let parseContacts = await fetchParsedContacts(contacts.map({ $0.number }))
    
        // Show who is a user
        contacts = contacts.map({ contact in
            if parseContacts.contains(contact.number) {
                var mutable = contact
                mutable.is_user = true
                return mutable
            } else {
                return contact
            }
        })
        
        // Sort to show users first
        contacts.sort(by: { $0.is_user && !$1.is_user })
        var models = models.value
        models.contacts = contacts
        self.models.send(models)
    }
    
    func updateRequestsModel() async {
        guard let user = controller.userManager.user.value else {
            fatalError("Failed to retrieve user")
        }
        
        let friendRequests = await fetchRequests()
        
        // Filter contacts
        let toNumbers = friendRequests.map({ $0.to })
        let fromNumbers = friendRequests.map({ $0.from })
        let uniqueNumbers = Set(toNumbers + fromNumbers)
        let filteredContacts = contacts.filter({ !uniqueNumbers.contains($0.number) })
        
        // Filter requests
        let received = friendRequests.filter({ $0.to == user.number })
        let sent = friendRequests.filter({ $0.from == user.number })
        
        var models = models.value
        models.receivedRequests = received
        models.sentRequests = sent
        models.contacts = filteredContacts
        self.models.send(models)
    }
    
    private func fetchContacts() async -> [Contact] {
        guard let user = controller.userManager.user.value else {
            fatalError("Failed to retrieve user")
        }
        
        let keys = [CNContactGivenNameKey, CNContactFamilyNameKey, CNContactThumbnailImageDataKey, CNContactPhoneNumbersKey] as [CNKeyDescriptor]
        
        let fetchRequest = CNContactFetchRequest(keysToFetch: keys)
        
        fetchRequest.sortOrder = .userDefault
        
        do {
            var result: [Contact] = []
            try contactStore.enumerateContacts(with: fetchRequest, usingBlock: { contact, _ in
                for number in contact.phoneNumbers {
                    guard let phoneNumber = try? phoneNumberKit.parse(number.value.stringValue) else {
                        continue
                    }
                    
                    let e164 = phoneNumberKit.format(phoneNumber, toType: .e164)
                    
                    // Do not retrieve user's number or user's friends
                    let friendNumers = user.friends.map({ $0.number })
                    guard e164 != user.number && !friendNumers.contains(e164) else {
                        continue
                    }
                    
                    result.append(Contact(name: contact.givenName, surname: contact.familyName, number: e164, imagedata: contact.thumbnailImageData))
                }
            })
   
            return result
            
        } catch {
            print("ContactsVCViewModel/fetchAllContacts error: \(error)")
            return []
        }
    }
                                
    private func fetchParsedContacts(_ contacts: [String]) async -> [String] {
        let result = await controller.userAPI.parseContacts(withContacts: contacts)
        switch result {
        case .success(let parsed):
            return parsed
        case .failure(let error):
            switch error {
            case .userError:
                break
            default:
                await controller.showToast(withMessage: ToastErrorMessage.InternalServer.rawValue)
            }
        }
        
        return []
    }
    
    private func fetchRequests() async -> [FriendRequest] {
        let result = await controller.userAPI.fetchFriendRequests()
        switch result {
        case .success(let requests):
            return requests
        case .failure(let error):
            switch error {
            case .userError:
                break
            default:
                await controller.showToast(withMessage: ToastErrorMessage.InternalServer.rawValue)
            }
        }
        
        return []
    }
}
