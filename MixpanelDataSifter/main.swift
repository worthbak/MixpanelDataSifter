#!/usr/bin/swift

//
//  main.swift
//  MixpanelDataSifter
//
//  Created by David Baker on 12/13/16.
//  Copyright © 2016 redpointcollaborative.com. All rights reserved.
//

import Foundation

print("Hello, World!")

let thing = CommandLine.arguments[1]

print(CommandLine.arguments[0])

print(thing)

let currentDirectoryURL = URL(fileURLWithPath: FileManager.default.currentDirectoryPath)

if #available(OSX 10.11, *) {
  let url = URL(fileURLWithPath: CommandLine.arguments[1], relativeTo: currentDirectoryURL)
  print("script at: " + url.path)
  
  
  guard let data = try? Data(contentsOf: url, options: NSData.ReadingOptions.uncached) else {
    print("Failed to read data from file at path: \(url.absoluteString)")
    exit(1)
  }
  
  guard let stringData = String.init(data: data, encoding: String.Encoding.utf8) else {
    print("Failed to load string from data")
    exit(1)
  }
  
  //let stringArray = stringData.componentsSeparatedByCharactersInSet(NSCharacterSet.newlineCharacterSet())
  let stringArray = stringData.components(separatedBy: CharacterSet.newlines)
  
//  print(stringArray.count)
//  print(stringArray[1])
  
  
  
  // each string in this array should be valid json
  let timeSpentInts = stringArray
    .flatMap { $0.data(using: .utf8) }
    .flatMap { try? JSONSerialization.jsonObject(with: $0, options: []) as? [String: Any] }
    .flatMap { $0 }.flatMap { $0["properties"] as? [String: Any] }
    .flatMap { $0["MainFeed_time_spent_seconds"] as? Int }
  
//  print("first item: \(timeSpentInts.first!)")
  print("total count of events with time spent field: \(timeSpentInts.count)")
  
  let timeSpentTotal = timeSpentInts.reduce(0, +)
  let average = Double(timeSpentTotal) / Double(timeSpentInts.count)
  print("average: \(average)")
  print("max:\((timeSpentInts.max() ?? 0) / 60)")
}


