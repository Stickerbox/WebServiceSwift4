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
    
    @discardableResult
    func request<T>(for config: WebServiceConfiguration<T>, completion: @escaping (WebServiceResult<T>) -> Void) -> URLSessionDataTask? {
        
        guard let request = generateRequest(from: config) else {
            completion(.failure(.invalidRequest))
            return nil
        }
        
        let task = dataTask(with: request) { (data, response, error) in
            
            guard error == nil, let data = data else {
                completion(.failure(.invalidResponse(error)))
                return
            }
            
            do {
                let test = try JSONDecoder().decode(config.resultType, from: data)
                completion(.success(test))
            } catch let error {
                completion(.failure(.unableToDecode(error)))
            }
            
        }
        
        task.resume()
        
        return task
    }
    
    private func generateRequest<T>(from config: WebServiceConfiguration<T>) -> URLRequest? {
        
        guard var url = URL(string: config.baseURL.rawValue + config.endpoint) else { return nil }
        
        // add config query parameters
        var queryItems = [URLQueryItem]()
        if let queryParameters = config.queryParameters {
            queryItems.append(contentsOf: queryParameters)
        }
        
        // add any query params
        if !queryItems.isEmpty {
            var components = URLComponents(url: url, resolvingAgainstBaseURL: true)!
            components.queryItems = queryItems
            url = components.url!
        }
        
        var request = URLRequest(url: url)
        request.method = config.method
        
        if let requestJSONBody = config.jsonBody {
            let data = try! JSONSerialization.data(withJSONObject: requestJSONBody, options: [])
            request.httpBody = data
            request.setValue(ContentTypeJSON, forHTTPHeaderField: ContentTypeHttpHeader)
        }
        
        return request
    }
    
}

// The main configuration that you pass to the request function on URLSession

struct WebServiceConfiguration<C: Codable> {
    
    var baseURL: BaseURL
    let endpoint: String
    let method: URLRequest.Request
    let resultType: C.Type
    var queryParameters: [URLQueryItem]?
    var jsonBody: AnyObject?
    var formBody: [String: String]?
    
    init(endpoint: String, method: URLRequest.Request, resultType: C.Type) {
        self.baseURL = .main
        self.endpoint = endpoint
        self.method = method
        self.resultType = resultType
    }
    
    init(endpoint: String, resultType: C.Type) {
        self.baseURL = .main
        self.endpoint = endpoint
        self.method = .get
        self.resultType = resultType
    }
    
    mutating func appendQueryParameter(key: String, value: String) {
        self.queryParameters?.append(URLQueryItem(name: key, value: value))
    }
    
}

// MARK: Result

enum WebServiceResult<R: Codable> {
    case success(R)
    case failure(WebServiceError)
}

// MARK: Errors

enum WebServiceError: Error {
    case invalidResponse(Error?)
    case invalidRequest
    case unableToDecode(Error?)
    case unableToEncode(Error?)
    
    var message: String {
        
        switch self {
            
        case let .invalidResponse(error):
            return "The response was invalid: \(error?.localizedDescription ?? "no message")"
        case .invalidRequest:
            return "The request you constructed was invalid"
        case let .unableToDecode(error):
            return "Unable to decode: \(error?.localizedDescription ?? "no message")"
        case let .unableToEncode(error):
            return "Unable to encode: \(error?.localizedDescription ?? "no message")"
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

private let ContentTypeHttpHeader = "Content-Type"
fileprivate let ContentTypeForm = "application/x-www-form-urlencoded"
fileprivate let ContentTypeJSON = "application/json"
fileprivate let ContentTypeMultipartForm = "multipart/form-data"
