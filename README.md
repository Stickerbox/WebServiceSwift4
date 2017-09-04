# WebServiceSwift4
A custom wrapper for the Swift 4 Codable protocol and URLSession

## To get started
All you need is to download the WebServiceConfiguration.swift file and put it somewhere in your project

https://raw.githubusercontent.com/Stickerbox/WebServiceSwift4/master/WebServiceSwift4/WebServiceConfiguration.swift

## Usage
This file allows you to create and perform web service requests very easily. For example, to perform a get request:

## Step 1.
Create an object that maps your json and conform it to Codable

        struct User: Codable {
          let firstName: String
          let lastName: String
          let bio: String
        }

## Step 2.
Create a WebServiceConfiguration, typed to your object, and pass it the endpoint

        let configuration = WebServiceConfiguration<[User]>(endpoint: "/bins/168z29")

## Step 3.
Pass this configuration to URLSession.shared.request(for: )

        URLSession.shared.request(for: configuration) { result in
            
            switch result {
                
            case let .success(users):
                users.forEach { print($0.firstName, $0.lastName, $0.bio) }
                
            case let .failure(error):
                print(error.message)
            }
        }
        
## Step 4.
Make sure in the WebServiceConfiguration.swift file that the 'main' case for the BaseURL is "https://api.myjson.com" and then run the app.

It will download the JSON, parse it to the object you typed the configuration as (in this case an array of User), and then give you the result.
In case of a failure, it's best to print the .message on the error you get as it is print useful information for debugging purposes.

# Where to go from here

In addition to this, you can also make the configuration object a var and change properties on it like the baseURL, the httpMethod, the form data or json body, or add query items.

It might be good to keep all these configurations either in the same folder for clarity, or putting the configuration as a static var on the object itself.
