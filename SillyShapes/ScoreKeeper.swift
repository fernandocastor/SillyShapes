//
//  ScoreKeeper.swift
//  SillyShapes
//
//  Created by Fernando Castor on 04/02/15.
//  Copyright (c) 2015 UFPE. All rights reserved.
//

import Foundation

class ScoreKeeper : NSObject {
  
  private var scoresToKeep:UInt32 = 10 // Default is 10.
  
  private var scores:[(String,UInt32)] = [(String,UInt32)]()
  
  init(numScores:UInt32) {
    super.init()
  }
  
//  func registerScore(player:String, score:UInt32) {
//    self.scores[(player, score)] = score
//  }
  
  func leastHighScore() -> (String, UInt32)? {
    var pairs:[(String, UInt32)] = self.getScoresDescending()
    return pairs.last
  }
  
  private func remove(pair:(String, UInt32)) {
    var i = 0
    for v in self.scores {
      if (v.0 == pair.0) && (v.1 == pair.1) {
        self.scores.removeAtIndex(i)
      }
      i++
    }
  }
  
  func isFull() -> Bool {
    return UInt32(self.scores.count) == self.scoresToKeep
  }
  
  func newHighScore(player:String, score:UInt32) {
    var isNewHighScore = true
    if !self.isFull() {
      self.scores.append((player, score))
    } else if let leastHigh:(String, UInt32) = self.leastHighScore() as (String, UInt32)? {
      if (leastHigh.1 < score) {
        // If the limit of this score keeper was reached, some element
        // will have to be removed...
        self.remove(leastHigh)
        self.scores.append((player, score))
      }
    }
  }
  
  // Checks if the provided score is an existing high score
  func isHighScore(score: UInt32) -> Bool {
    var result = false
    for (k, v) in scores {
      if v == score {
        result = true
      }
    }
    return result
  }
  
  // Checks if a score should be entered among the high scores.
  func isPossibleHighScore(score:UInt32) -> Bool {
    var result = true
    if let leastHighScore = self.leastHighScore() as (String, UInt32)? {
      if self.isFull() && leastHighScore.1 > score {
        result = false
      }
    }
    return result
  }
  
  // This function returns an array of pairs. The first 
  // element of each pair is the number of a player, whereas
  // the second one is the score of that player. The player
  // with the highest score appears in the first position
  // of the array. The one with the worst score appears last.
  func getScoresDescending() -> [(String,UInt32)] {
    
    // Returns a sorted array built from the elements in pairs. 
    // The elements from this array are sorted according to the 
    // scores.
    var result = self.scores.sorted(
      {(firstItem:(String, UInt32), secondItem:(String, UInt32)) -> Bool in
        return firstItem.1 >= secondItem.1
      })
    
    return result
  }
  
  
}