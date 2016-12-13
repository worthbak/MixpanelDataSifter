#!/usr/bin/swift

//
//  main.swift
//  MixpanelDataSifter
//
//  Created by David Baker on 12/13/16.
//  Copyright © 2016 redpointcollaborative.com. All rights reserved.
//

import Foundation

// expected format 
// ./sifter <api_key> <event_name> <from_date> <to_date> <requested_operation>
// requested_operation options: count, avg, max, avg_filter <int>

func printTotals(_ array: [Int]) {
  let timeSpentTotal = array.reduce(0, +)
  let average = Double(timeSpentTotal) / Double(array.count)
  print("average: \(average)")
  print("max:\((array.max() ?? 0) / 60) minutes")
}

if #available(OSX 10.11, *) {
  if CommandLine.arguments.count > 1, CommandLine.arguments[1] == "--help" {
    print("expected format")
    print("./sifter <api_key> <event_name> <from_date> <to_date> <requested_operation>")
    print("requested_operation options: count, avg, max, avg_filter <int>")
    exit(EXIT_SUCCESS)
  }
  
  guard CommandLine.arguments.count >= 5 else {
    print("improper arguments passed in. Enter --help for help")
    exit(EXIT_FAILURE)
  }
  
  let apiKey = CommandLine.arguments[1]
  let eventName = CommandLine.arguments[2]
  let fromDate = CommandLine.arguments[3]
  let toDate = CommandLine.arguments[4]
  
  let requestedOp: SiftOperation?
  if CommandLine.arguments.count >= 6 {
    requestedOp = SiftOperation.init(CommandLine.arguments[5]) // TODO filter op
  }
  
  guard let mpRequest = URLRequest(apiKey, eventName, fromDate, toDate) else {
    print("could not create url request")
    exit(EXIT_FAILURE)
  }
  
  func synchronousDataTask(with urlRequest: URLRequest) -> (Data?, URLResponse?, Error?) {
    var data: Data?, response: URLResponse?, error: Error?
    
    let semaphore = DispatchSemaphore(value: 0)
    
    URLSession.shared.dataTask(with: urlRequest) {
      data = $0; response = $1; error = $2
      semaphore.signal()
      }.resume()
    
    semaphore.wait()
    
    return (data, response, error)
  }
  
  let (data, _, _) = synchronousDataTask(with: mpRequest)
  
  guard let realData = data else {
    print("Failed to fetch data")
    exit(1)
  }
  
  guard let stringData = String.init(data: realData, encoding: String.Encoding.utf8) else {
    print("Failed to load string from data")
    exit(1)
  }
  
  let stringArray = stringData.components(separatedBy: CharacterSet.newlines)
  let allEventProperties = stringArray
    .flatMap { $0.data(using: .utf8) }
    .flatMap { try? JSONSerialization.jsonObject(with: $0, options: []) as? [String: Any] }
    .flatMap { $0 }
    .flatMap { $0["properties"] as? [String: Any] }
  
  let allUserIDs = allEventProperties.flatMap { $0["userID"] as? Int }
  let uniqueUserIDs = Set(allUserIDs)
  
  print("total events count: \(allEventProperties.count)")
  print("events per user: \(allEventProperties.count / uniqueUserIDs.count)")
  
  printTotals(allEventProperties
    .flatMap { $0["MainFeed_time_spent_seconds"] as? Int }
    .filter { $0 > 5 }
  )
  
  print("\n\n")
  
  let superUserIDs = [28542, 33972, 34583, 54387, 60518, 62421, 128104, 144563, 149035, 149820, 177653, 187280, 192685, 207188, 242509, 250372, 252572, 260893, 265554, 268691, 303556, 326996, 333364, 334990, 338013, 352384, 353468, 382547, 389872, 394193, 394989, 397706, 410783, 415391, 417520, 417588, 418043, 418916, 420310, 422898, 423569, 423965, 425868, 430986, 432789, 433013, 436421, 437184, 458571, 464232]
  
  let superUserEvents = allEventProperties.filter {
    properties in
    guard let userID = properties["userID"] as? Int else { return false }
    return superUserIDs.contains(userID)
  }
  
  print("super user events count: \(superUserEvents.count)")
  print("events per super user: \( superUserEvents.count / superUserIDs.count )")
  
  printTotals(superUserEvents
    .flatMap { $0["MainFeed_time_spent_seconds"] as? Int }
    .filter { $0 > 5 }
  )
  
  //  .flatMap { $0["MainFeed_time_spent_seconds"] as? Int }
//  print("total count of events with time spent field: \(timeSpentInts.count)")
} else {
  fatalError()
}
