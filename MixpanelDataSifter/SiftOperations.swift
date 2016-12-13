//
//  SiftOperations.swift
//  MixpanelDataSifter
//
//  Created by David Baker on 12/13/16.
//  Copyright © 2016 redpointcollaborative.com. All rights reserved.
//

import Foundation

enum SiftOperation {
  case count, max, min, avg
  case avgFilter(Int)
  
  init?(_ operation: String, _ filter: Int = 0) {
    switch operation {
    case "count":
      self = .count
    case "avg":
      self = .avg
    case "min":
      self = .min
    case "max":
      self = .max
    case "avg_filter":
      self = .avgFilter(filter)
    default:
      return nil
    }
  }
  
  func operate(on array: [Any]) -> Double { // not ideal but w/e
    switch self {
    case .count:
      return Double(array.count)
    case .avg:
      guard let intArray = array as? [Int] else {
        fatalError(".avg operation can only operate on type [Int]")
      }
      return Double(intArray.reduce(0, +)) / Double(intArray.count)
    default:
      fatalError("unimplemented")
    }
  }
}
