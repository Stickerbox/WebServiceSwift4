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
        
          printUsers()
          printTestObject()
          printOtherTest()
    }
    
    // decoding a simple object
    private func printTestObject() {
        
        let config = WebServiceConfiguration<Test>(endpoint: "/bins/si1xl", resultType: Test.self)
        
        URLSession.shared.request(for: config) { result in
            
            switch result {
                
            case let .success(test):
                print("------------TEST-----------")
                print(test.a)
                
            case let .failure(error):
                print(error.message)
                
            }
            
        }
    }
    
    // getting the URLSessionDataTask so you can cancel it later
    private func printOtherTest() {
        
        let config = WebServiceConfiguration<OtherTest>(endpoint: "/bins/1c7i21", resultType: OtherTest.self)
        
        let task = URLSession.shared.requestWithTask(for: config) { result in
            
            switch result {
                
            case let .success(otherTest):
                print("------------OTHERTEST-----------")
                print(otherTest.title)
                print(otherTest.bio)
                
            case let .failure(error):
                print(error.message)
            }
        }
        
        // takes the same parameters as the .request function but you then need to manually call .resume()
        task?.resume()
        // task?.cancel()
    }
    
    // decoding an array
    private func printUsers() {
        
        let config = WebServiceConfiguration<[User]>(endpoint: "/bins/13zxmh", resultType: [User].self)
        
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

struct Test: Codable {
    let a: String
}

struct OtherTest: Codable {
    let title: String
    let bio: String
}

struct User: Codable {
    let username: String
    let password: String
}
