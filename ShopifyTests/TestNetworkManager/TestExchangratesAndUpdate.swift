//
//  TestDeleteFromApi.swift
//  ShopifyTests
//
//  Created by Rawan Elsayed on 24/06/2024.
//

import XCTest
@testable import Shopify
import Alamofire

final class TestExchangratesAndUpdate: XCTestCase{
    
    var networkService : NetworkManager?
    
    override func setUpWithError() throws {
        //  networkService = NetworkManager()
    }
    
    override func tearDownWithError() throws {
        //  networkService = nil
    }
    
    func testFetchExchangeRates_Success() {
        let expectation = self.expectation(description: "Wait for API response")
        
        let urlString = "https://v6.exchangerate-api.com/v6/b8bdb1874a7d78bef8610486/latest/USD"
        
        NetworkManager.fetchExchangeRates(urlString: urlString) { data, error in
            XCTAssertNil(error, "Expected no error, but got \(String(describing: error)) instead")
            XCTAssertNotNil(data, "Expected non-nil data")
            
            if let data = data {
                do {
                    let jsonObject = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
                    XCTAssertNotNil(jsonObject, "Expected valid JSON object")
                    XCTAssertEqual(jsonObject?["result"] as? String, "success", "Expected 'result' key to be 'success'")
                } catch {
                    XCTFail("JSON deserialization failed with error: \(error)")
                }
            }
            expectation.fulfill()
        }
        
        waitForExpectations(timeout: 10, handler: nil)
    }
    
    
    func testFetchExchangeRates_Failure() {
        let expectation = self.expectation(description: "Wait for API response")
        
        let invalidUrlString = "https://invalid.url"
        
        NetworkManager.fetchExchangeRates(urlString: invalidUrlString) { data, error in
            XCTAssertNotNil(error, "Expected an error, but got nil instead")
            XCTAssertNil(data, "Expected nil data when there is an error")
            expectation.fulfill()
        }
        
        waitForExpectations(timeout: 10, handler: nil)
    }
    
    func testUpdateResource_Success() {
        let expectation = self.expectation(description: "Wait for API response")
        
        let updatedCustomer: [String: Any] = [
            "id": 12345678,
            "firstName": "Updated FirstName",
            "lastName": "Updated LastName"
        ]
        
        let jsonData = try! JSONSerialization.data(withJSONObject: updatedCustomer, options: [])
        
        MockNetworkManager.updateResource(endpoint: .customers, rootOfJson: .customer, body: jsonData, addition: "12345678.json") { data, error in
            XCTAssertNil(error, "Expected no error, but got \(String(describing: error)) instead")
            XCTAssertNotNil(data, "Expected non-nil data")
            
            if let data = data, let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                XCTAssertEqual(json["success"] as? Bool, true, "Expected success to be true")
            }
            
            expectation.fulfill()
        }
        
        waitForExpectations(timeout: 10, handler: nil)
    }
    
    
    
    func testUpdateResource_Failure() {
        let expectation = self.expectation(description: "Wait for API response")
        
        // Define the body of the request
        let updatedCustomer: [String: Any] = [
            "id": 12345678,
            "firstName": "Updated FirstName",
            "lastName": "Updated LastName"
        ]
        
        let jsonData = try! JSONSerialization.data(withJSONObject: updatedCustomer, options: [])
        
        NetworkManager.updateResource(endpoint: .customers, rootOfJson: .customer, body: jsonData, addition: "invalid.json") { data, error in
            XCTAssertNotNil(error, "Expected an error, but got nil instead")
            XCTAssertNil(data, "Expected nil data when there is an error")
            
            if let error = error as? AFError {
                switch error {
                case .responseValidationFailed(let reason):
                    if case .unacceptableStatusCode(let code) = reason {
                        XCTAssertTrue([400, 406, 404].contains(code), "Expected error code to be either 400, 406, or 404 but got \(code)")
                    } else {
                        XCTFail("Unexpected response validation failure reason: \(reason)")
                    }
                default:
                    XCTFail("Unexpected AFError: \(error)")
                }
            } else if let error = error as NSError? {
                XCTFail("Unexpected error domain: \(error.domain) with code \(error.code)")
            }
            
            expectation.fulfill()
        }
        
        waitForExpectations(timeout: 10, handler: nil)
    }
    
    func testUpdateResource_Failure_InvalidEndpoint() {
        let expectation = self.expectation(description: "Wait for API response")
        
        let updatedCustomer: [String: Any] = [
            "id": 12345678,
            "firstName": "Updated FirstName",
            "lastName": "Updated LastName"
        ]
        
        let jsonData = try! JSONSerialization.data(withJSONObject: updatedCustomer, options: [])
        
        MockNetworkManager.updateResource(endpoint: .order, rootOfJson: .order, body: jsonData, addition: "12345678.json") { data, error in
            XCTAssertNotNil(error, "Expected an error, but got nil instead")
            XCTAssertNil(data, "Expected nil data when there is an error")
            
            // Print the error for debugging purposes
            if let error = error as NSError? {
                XCTAssertEqual(error.code, -1, "Expected error code to be -1 for unexpected endpoint")
            } else {
                XCTFail("Unexpected error type: \(String(describing: error))")
            }
            
            expectation.fulfill()
        }
        
        waitForExpectations(timeout: 10, handler: nil)
    }
    
    func testUpdateResource_Failure_InvalidURL() {
        let expectation = self.expectation(description: "Wait for API response")
        
        let updatedCustomer: [String: Any] = [
            "id": 12345678,
            "firstName": "Updated FirstName",
            "lastName": "Updated LastName"
        ]
        
        let jsonData = try! JSONSerialization.data(withJSONObject: updatedCustomer, options: [])
        
        MockNetworkManager.updateResource(endpoint: .customers, rootOfJson: .customer, body: jsonData, addition: nil) { data, error in
            XCTAssertNotNil(error, "Expected an error, but got nil instead")
            XCTAssertNil(data, "Expected nil data when there is an error")
            
            if let error = error as NSError? {
                XCTAssertEqual(error.code, -1, "Expected error code to be -1 for invalid URL")
            } else {
                XCTFail("Unexpected error type: \(String(describing: error))")
            }
            
            expectation.fulfill()
        }
        
        waitForExpectations(timeout: 10, handler: nil)
    }
    
    func testUpdateResource_Failure_InvalidAddition() {
        let expectation = self.expectation(description: "Wait for API response")
        
        let updatedCustomer: [String: Any] = [
            "id": 12345678,
            "firstName": "Updated FirstName",
            "lastName": "Updated LastName"
        ]
        
        let jsonData = try! JSONSerialization.data(withJSONObject: updatedCustomer, options: [])
        
        MockNetworkManager.updateResource(endpoint: .customers, rootOfJson: .customer, body: jsonData, addition: "invalid.json") { data, error in
            XCTAssertNotNil(error, "Expected an error, but got nil instead")
            XCTAssertNil(data, "Expected nil data when there is an error")
            
            if let error = error as? NSError {
                XCTAssertEqual(error.code, 400, "Expected error code to be 400 for mock failure")
            } else {
                XCTFail("Unexpected error type: \(String(describing: error))")
            }
            
            expectation.fulfill()
        }
        
        waitForExpectations(timeout: 10, handler: nil)
    }
    
    func testDeleteResource_Success() {
        let expectation = self.expectation(description: "Wait for API response")
        
        // Use the mock network manager for deleteResource
        MockNetworkManager.deleteResource(endpoint: .customers, addition: "12345678.json") { data, error in
            XCTAssertNil(error, "Expected no error, but got \(String(describing: error)) instead")
            XCTAssertNotNil(data, "Expected non-nil data")
            
            // Optionally, check the contents of the response
            if let data = data, let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                XCTAssertEqual(json["success"] as? Bool, true, "Expected success to be true")
            }
            
            expectation.fulfill()
        }
        
        waitForExpectations(timeout: 10, handler: nil)
    }
    
    func testDeleteResource_Failure_InvalidEndpoint() {
        let expectation = self.expectation(description: "Wait for API response")
        
        // Use the mock network manager for deleteResource with an invalid endpoint
        MockNetworkManager.deleteResource(endpoint: .order, addition: "12345678.json") { data, error in
            XCTAssertNotNil(error, "Expected an error, but got nil instead")
            XCTAssertNil(data, "Expected nil data when there is an error")
            
            // Print the error for debugging purposes
            if let error = error as NSError? {
                XCTAssertEqual(error.code, -1, "Expected error code to be -1 for unexpected endpoint")
            } else {
                XCTFail("Unexpected error type: \(String(describing: error))")
            }
            
            expectation.fulfill()
        }
        
        waitForExpectations(timeout: 10, handler: nil)
    }
    
    func testDeleteResource_Failure_InvalidAddition() {
        let expectation = self.expectation(description: "Wait for API response")
        
        // Use the mock network manager for deleteResource with an invalid addition
        MockNetworkManager.deleteResource(endpoint: .customers, addition: "invalid.json") { data, error in
            XCTAssertNotNil(error, "Expected an error, but got nil instead")
            XCTAssertNil(data, "Expected nil data when there is an error")
            
            // Print the error for debugging purposes
            if let error = error as? NSError {
                XCTAssertEqual(error.code, 400, "Expected error code to be 400 for mock failure")
            } else {
                XCTFail("Unexpected error type: \(String(describing: error))")
            }
            
            expectation.fulfill()
        }
        
        waitForExpectations(timeout: 10, handler: nil)
    }
    
    func testDeleteResource_Failure_InvalidURL() {
        let expectation = self.expectation(description: "Wait for API response")
        
        // Use the mock network manager for deleteResource with an invalid URL
        MockNetworkManager.deleteResource(endpoint: .customers, addition: nil) { data, error in
            XCTAssertNotNil(error, "Expected an error, but got nil instead")
            XCTAssertNil(data, "Expected nil data when there is an error")
            
            // Print the error for debugging purposes
            if let error = error as NSError? {
                XCTAssertEqual(error.code, -1, "Expected error code to be -1 for invalid URL")
            } else {
                XCTFail("Unexpected error type: \(String(describing: error))")
            }
            
            expectation.fulfill()
        }
        
        waitForExpectations(timeout: 10, handler: nil)
    }
    
}


class MockNetworkManager {
    
    static func updateResource(endpoint: Endpoint, rootOfJson: Root, body: Data, addition: String? = "", completion: @escaping (Data?, Error?) -> Void) {
        let mockSuccessResponseData = "{\"success\": true}".data(using: .utf8)!
        
        let mockFailureError = NSError(domain: "com.shopify.test", code: 400, userInfo: [NSLocalizedDescriptionKey: "Request failed: bad request (400)"])
        
        switch (endpoint, addition) {
        case (.customers, "12345678.json"):
            completion(mockSuccessResponseData, nil)
        case (.customers, "invalid.json"):
            completion(nil, mockFailureError)
        default:
            completion(nil, NSError(domain: "com.shopify.test", code: -1, userInfo: [NSLocalizedDescriptionKey: "Unexpected endpoint and addition combination"]))
        }
    }
    
    static func deleteResource(endpoint: Endpoint, addition: String? = "", completion: @escaping (Data?, Error?) -> Void) {
        let mockSuccessResponseData = "{\"success\": true}".data(using: .utf8)!
        
        let mockFailureError = NSError(domain: "com.shopify.test", code: 400, userInfo: [NSLocalizedDescriptionKey: "Request failed: bad request (400)"])
        
        switch (endpoint, addition) {
        case (.customers, "12345678.json"):
            completion(mockSuccessResponseData, nil)
        case (.customers, "invalid.json"):
            completion(nil, mockFailureError)
        default:
            completion(nil, NSError(domain: "com.shopify.test", code: -1, userInfo: [NSLocalizedDescriptionKey: "Unexpected endpoint and addition combination"]))
        }
    }
}



