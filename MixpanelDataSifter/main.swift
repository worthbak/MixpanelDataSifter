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
  let timeSpentInts = stringArray
    .flatMap { $0.data(using: .utf8) }
    .flatMap { try? JSONSerialization.jsonObject(with: $0, options: []) as? [String: Any] }
    .flatMap { $0 }
  //  .flatMap { $0["properties"] as? [String: Any] }
  //  .flatMap { $0["MainFeed_time_spent_seconds"] as? Int }
  print("total count of events with time spent field: \(timeSpentInts.count)")
} else {
  fatalError()
}



//let thing = CommandLine.arguments[1]
//
//
//
//print(CommandLine.arguments[0])
//
//print(thing)
//
//let currentDirectoryURL = URL(fileURLWithPath: FileManager.default.currentDirectoryPath)
//
//if #available(OSX 10.11, *) {
//  let url = URL(fileURLWithPath: CommandLine.arguments[1], relativeTo: currentDirectoryURL)
//  print("script at: " + url.path)
//  
//  
//  guard let data = try? Data(contentsOf: url, options: NSData.ReadingOptions.uncached) else {
//    print("Failed to read data from file at path: \(url.absoluteString)")
//    exit(1)
//  }
//  
//  guard let stringData = String.init(data: data, encoding: String.Encoding.utf8) else {
//    print("Failed to load string from data")
//    exit(1)
//  }
//  
//  //let stringArray = stringData.componentsSeparatedByCharactersInSet(NSCharacterSet.newlineCharacterSet())
//  let stringArray = stringData.components(separatedBy: CharacterSet.newlines)
//  
////  print(stringArray.count)
////  print(stringArray[1])
//  
//  
//  
//  // each string in this array should be valid json
//  let timeSpentInts = stringArray
//    .flatMap { $0.data(using: .utf8) }
//    .flatMap { try? JSONSerialization.jsonObject(with: $0, options: []) as? [String: Any] }
//    .flatMap { $0 }.flatMap { $0["properties"] as? [String: Any] }
//    .flatMap { $0["MainFeed_time_spent_seconds"] as? Int }
////    .filter { $0 > 5 } increases build time
//  
////  print("first item: \(timeSpentInts.first!)")
//  print("total count of events with time spent field: \(timeSpentInts.count)")
//  
//  let timeSpentTotal = timeSpentInts.reduce(0, +)
//  let average = Double(timeSpentTotal) / Double(timeSpentInts.count)
//  print("average: \(average)")
//  print("max:\((timeSpentInts.max() ?? 0) / 60)")
//}
//
//
