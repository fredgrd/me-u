//
//  ContactsVC+ViewModel.swift
//  me&us
//
//  Created by Federico on 07/02/23.
//

import Foundation
import Contacts
import Combine
import PhoneNumberKit

class ContactsVCViewModel {
    
    var controller: MainController?
    
    enum ContactSection: String, Hashable {
        case requests = "Sent Requests"
        case contacts = "Contacts"
    }
    
    private let userAPI = UserAPI()
    
    private(set) var contacts = CurrentValueSubject<[Contact], Never>([])
    
    private let phoneNumberKit = PhoneNumberKit()
    
    func fetchAllContacts() async {
        let store = CNContactStore()
        
        let keys = [CNContactGivenNameKey, CNContactFamilyNameKey, CNContactThumbnailImageDataKey, CNContactPhoneNumbersKey] as [CNKeyDescriptor]
        
        let fetchRequest = CNContactFetchRequest(keysToFetch: keys)
        
        fetchRequest.sortOrder = .userDefault
        
        do {
            var result: [Contact] = []
            try store.enumerateContacts(with: fetchRequest, usingBlock: { contact, _ in
                for number in contact.phoneNumbers {
                    guard let phoneNumber = try? phoneNumberKit.parse(number.value.stringValue) else {
                        continue
                    }
                    
                    let e164 = phoneNumberKit.format(phoneNumber, toType: .e164)
                    result.append(Contact(name: contact.givenName, surname: contact.familyName, number: e164, imagedata: contact.thumbnailImageData))
                }
            })
   
            await filterContacts(result)
            
        } catch {
            print("ContactsVCViewModel/fetchAllContacts error: \(error)")
        }
    }
    
    func filterContacts(_ contacts: [Contact]) async {
//        let reducedContacts = contacts.map { ReducedContact(id: $0.id, number: $0.number)}
//        let result = await userAPI.filterContacts(withContacts: reducedContacts)
//
//        switch result {
//        case .success(let filtered):
//            let updated = contacts.map { value in
//                if let one = filtered.first(where: { $0.number == value.number }) {
//                    var mutable = value
//                    mutable.is_user = one.is_user
//                    mutable.friend_request = one.friend_request
//                    return mutable
//                } else {
//                    return value
//                }
//            }
//
//            self.contacts.send(updated)
//        case .failure(let error):
//            switch error {
//            case .userError:
//                await controller?.showToast(withMessage: "Invalid code")
//            default:
//                await controller?.showToast(withMessage: "Internal server error")
//            }
//        }
    }
    
    func addContact(withNumber number: String) async {
        let result = await userAPI.createFriendRequest(withTarget: number)
        switch result {
        case .success(let request):
            print(request)
            if let contactIndex = contacts.value.firstIndex(where: { $0.number == request.to }) {
                var update = contacts.value
                print("CONTACT INDEX", contactIndex)
//                update[contactIndex].friend_request = true
                
                contacts.send(update)
            }
        case .failure(let error):
            switch error {
            case .userError:
                await controller?.showToast(withMessage: "Invalid code")
            default:
                await controller?.showToast(withMessage: "Internal server error")
            }
        }
    }
}
