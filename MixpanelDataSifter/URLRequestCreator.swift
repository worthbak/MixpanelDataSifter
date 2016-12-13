//
//  URLRequestCreator.swift
//  MixpanelDataSifter
//
//  Created by David Baker on 12/13/16.
//  Copyright © 2016 redpointcollaborative.com. All rights reserved.
//

import Foundation

extension URLRequest {
  
  /*
   let url = URL(string: "http://www.example.com/")!
   var request = URLRequest(url: url)
   request.httpMethod = "POST"
   request.setValue("Basic \(base64LoginString)", forHTTPHeaderField: "Authorization")
 */
  
  init?(_ apiKey: String, _ eventName: String, _ fromDate: String, _ toDate: String) {
    
    if #available(OSX 10.11, *) {
      guard var urlComponents = URLComponents(string: "https://data.mixpanel.com/api/2.0/export/") else {
        print("could not init url components")
        return nil
      }
      urlComponents.queryItems = [URLQueryItem(name: "event", value: "[\"\(eventName)\"]"),
                                  URLQueryItem(name: "from_date", value: fromDate),
                                  URLQueryItem(name: "to_date", value: toDate)]
      
      guard let url = urlComponents.url else {
        print("could not init final url: \(urlComponents)")
        return nil
      }
      self.init(url: url)
      
      httpMethod = "GET"
      
      // set auth
      let loginString = "\(apiKey):"
      guard let loginData = loginString.data(using: String.Encoding.utf8) else {
        print("could not init auth data")
        return nil
      }
      let base64LoginString = loginData.base64EncodedString()
      setValue("Basic \(base64LoginString)", forHTTPHeaderField: "Authorization")
    } else {
      return nil
    }
  }
  
}
