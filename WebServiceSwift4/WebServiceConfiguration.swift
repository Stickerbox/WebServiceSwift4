//
//  WebServiceConfiguration.swift
//  WebServiceSwift4
//
//  Created by Jordan Dixon on 03/09/2017.
//  Copyright © 2017 Jordan Dixon. All rights reserved.
//

import Foundation

enum BaseURL: String {
    case main = "https://api.myjson.com"
}

extension URLSession {
    
    // Two functions since you may want the URLSesionDataTask to cancel the request later, but I don't like the .resume() thing, so I created a seperate function that does it so you don't have to call .resume() everywhere, UNLESS you specifically call requestWithTask.
    func requestWithTask<T>(for config: WebServiceConfiguration<T>, completion: @escaping (WebServiceResult<T>) -> Void) -> URLSessionDataTask? {
        
        guard let url = URL(string: config.baseURL.rawValue + config.endpoint) else { completion(.failure(.invalidRequest)); return nil }
        
        var request = URLRequest(url: url)
        request.method = config.method
        
        if let queryParameters = config.queryParameters {
            queryParameters.forEach { request.addValue($0.value, forHTTPHeaderField: $0.key) }
        }
        
        return dataTask(with: request) { (data, response, error) in
            
            guard error == nil, let data = data else { completion(.failure(.invalidResponse)); return }
            
            do {
                let test = try JSONDecoder().decode(config.resultType, from: data)
                completion(.success(test))
            } catch {
                completion(.failure(.unableToDecode))
            }
            
        }
    }
    
    func request<T>(for config: WebServiceConfiguration<T>, completion: @escaping (WebServiceResult<T>) -> Void) {
        requestWithTask(for: config, completion: completion)?.resume()
    }
    
}

// The main configuration that you pass to the request function on URLSession

struct WebServiceConfiguration<T: Codable> {
    
    var baseURL: BaseURL
    let endpoint: String
    let method: URLRequest.Request
    let resultType: T.Type
    var queryParameters: [String: String]?
    var body: [String: Any]?
    
    init(endpoint: String, method: URLRequest.Request, resultType: T.Type) {
        self.baseURL = .main
        self.endpoint = endpoint
        self.method = method
        self.resultType = resultType
    }
    
    init(endpoint: String, resultType: T.Type) {
        self.baseURL = .main
        self.endpoint = endpoint
        self.method = .get
        self.resultType = resultType
    }
    
    mutating func appendQueryParameter(key: String, value: String) {
        
        if var queryParameters = self.queryParameters {
            queryParameters[key] = value
            self.queryParameters = queryParameters
        } else {
            let queryParameters = [key: value]
            self.queryParameters = queryParameters
        }
    }
    
}

// The result

enum WebServiceResult<T: Codable> {
    case success(T)
    case failure(WebServiceError)
}

// All the possible errors

enum WebServiceError {
    case invalidResponse
    case invalidRequest
    case unableToDecode
    
    var message: String {
        
        switch self {
            
        case .invalidResponse:
            return "The response was invalid"
        case .invalidRequest:
            return "The request you constructed was invalid"
        case .unableToDecode:
            return "The returned data was incompatible with the Codable type you provided"
        }
    }
}

// Just for type safety

extension URLRequest {
    
    enum Request: String {
        case get = "GET"
        case post = "POST"
    }
    
    var method: Request {
        get {
            return Request(rawValue: self.httpMethod ?? "GET") ?? .get
        }
        set {
            self.httpMethod = method.rawValue
        }
    }
    
}
