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

class FriendsVCViewModel {
    
    enum Section: String, Hashable {
        case receivedRequests = "Received Requests"
        case sentRequests = "Sent Requests"
        case contacts = "Contacts"
    }
    
    let controller: MainController
    
    let contactStore = CNContactStore()
    var contacts = [Contact]()
    
    let models = CurrentValueSubject<FVCCollectionModels, Never>(FVCCollectionModels())
    
    private let phoneNumberKit = PhoneNumberKit()
    
    init(controller: MainController) {
        self.controller = controller
    }
    
    func addContact(_ contact: Contact) async {
        let result = await controller.userAPI.createFriendRequest(withTarget: contact.number)
        switch result {
        case .success(let request):
            let filteredContacts = contacts.filter({ $0.number != contact.number })
            
            // Filter requests
            var models = models.value
            models.sentRequests.append(request)
            models.contacts = filteredContacts
            self.models.send(models)
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
        
    }
    
    // Fetch models
    // Friends
    // Requests
    // Contacts
    func updateContactsModel() async {
        print("Updating contacts model")
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
        print("Done updating contacts model")
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
