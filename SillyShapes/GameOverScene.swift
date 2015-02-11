//
//  GameOverScene.swift
//  SillyShapes
//
//  Created by Fernando Castor on 04/02/15.
//  Copyright (c) 2015 UFPE. All rights reserved.
//

import SpriteKit

class GameOverScene : SKScene {
  
  let ITEM_SPACE:CGFloat = -50
  
  let BORDER_SPACE:CGFloat = 35
  
  var score:UInt32 = 0
  
  var scores:ScoreKeeper = ScoreKeeper(numScores:10)
  
  init(size:CGSize, playerWon:Bool, playerScore:UInt32, scoreKeeper:ScoreKeeper) {
    super.init(size:size)
//    let background = SKSpriteNode(imageNamed: "bg")
//    background.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame))
//    self.addChild(background)
    self.scores = scoreKeeper
    self.score = playerScore
    self.backgroundColor = UIColor.whiteColor()
    
    let scoreLabel:SKLabelNode = SKLabelNode(text: "Score: \(self.score)")
    scoreLabel.fontColor = UIColor.blackColor()
    scoreLabel.position = CGPointMake(CGRectGetMidX(self.frame), self.frame.size.height - (CGRectGetMidY(scoreLabel.frame) + BORDER_SPACE))  //CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame) + (-ITEM_SPACE))
    self.addChild(scoreLabel)
    
    placeTrophyIfHighScore(playerScore)
    
    let gameOverLabel = SKLabelNode(fontNamed: "Avenir-Black")
    gameOverLabel.fontSize = 40
    gameOverLabel.fontColor = UIColor.blackColor()
    gameOverLabel.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame))
    if playerWon {
      gameOverLabel.text = "YOU WIN"
    }
    else {
      gameOverLabel.text = "GAME OVER"
    }
    self.addChild(gameOverLabel)
    
    let playAgainLabel:SKLabelNode = SKLabelNode(text: "Tap to play again.")
    playAgainLabel.fontColor = UIColor.redColor()
    playAgainLabel.fontSize = 28
    playAgainLabel.position = CGPointMake(CGRectGetMidX(self.frame), gameOverLabel.position.y + 1.5*ITEM_SPACE)
    self.addChild(playAgainLabel)
  
    let withSoundAction = SKAction.playSoundFileNamed("gameoverSound.aiff", waitForCompletion:false)
    self.runAction(withSoundAction)
    
  }
  
  func placeTrophyIfHighScore(score:UInt32) {
    if self.scores.isHighScore(score) {
      let trophy = SKSpriteNode(imageNamed: "trophy")
      trophy.position = CGPointMake(CGRectGetMidX(self.frame), self.frame.size.height - trophy.frame.size.height - BORDER_SPACE)
      self.addChild(trophy)
    }
  }
  
  override func touchesBegan(touches: NSSet, withEvent event: UIEvent) {
    let newGameScene = GameScene(size: self.size, scoreKeeper:scores)
    self.view?.presentScene(newGameScene)
  }
  
  required init?(coder aDecoder: NSCoder) {
    super.init(coder:aDecoder)
  }
  
  
}
