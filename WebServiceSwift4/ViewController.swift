//
//  ViewController.swift
//  WebServiceSwift4
//
//  Created by Jordan Dixon on 27/08/2017.
//  Copyright © 2017 Jordan Dixon. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        printTestObject()
        printUsers()
    }
    
    // decoding a simple object
    private func printTestObject() {
        
        let config = WebServiceConfiguration<SimpleObject>(endpoint: "/bins/1hc1kp")
        
        URLSession.shared.request(for: config) { result in
            
            switch result {
                
            case let .success(simpleObject):
                print("------------SIMPLEOBJECT-----------")
                print(simpleObject.firstName)
                
            case let .failure(error):
                print(error.message)
                
            }
            
        }
    }
    
    // decoding an array
    private func printUsers() {
        
        let config = WebServiceConfiguration<[User]>(endpoint: "/bins/13zxmh")
        
        URLSession.shared.request(for: config) { result in
            
            switch result {
                
            case let .success(users):
                print("------------USER ARRAY-----------")
                users.forEach { print($0.username, $0.password) }
                
            case let .failure(error):
                print(error.message)
            }
        }
    }
}



// Data Structures

struct SimpleObject: Codable {
    let firstName: String
}

struct User: Codable {
    let username: String
    let password: String
}
