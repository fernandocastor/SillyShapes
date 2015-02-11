//
//  HighScoresScene.swift
//  SillyShapes
//
//  Created by Fernando Castor on 04/02/15.
//  Copyright (c) 2015 UFPE. All rights reserved.
//

import SpriteKit


class HighScoresScene : SKScene {

  let ITEM_SPACE:CGFloat = -50
  
  let BORDER_SPACE:CGFloat = 35
  
  let TEXT_FIELD_WIDTH:CGFloat = 300
  
  var score:UInt32 = 0
  
  var playerNameField:UITextField = UITextField()
  var nameOK:UIButton = UIButton()
  
  
  var enteredName:Bool = false

  var scores:ScoreKeeper = ScoreKeeper(numScores:10)
  
  var playerWon:Bool = false
  
  init(size:CGSize, playerWon:Bool, playerScore:UInt32, scoreKeeper:ScoreKeeper) {
    super.init(size:size)
    self.scores = scoreKeeper
    self.score = playerScore
    self.backgroundColor = UIColor.whiteColor()
    self.playerWon = playerWon

    
    let highScoreLabel = SKLabelNode(fontNamed: "Avenir-Black")
    highScoreLabel.fontSize = 32
    highScoreLabel.fontColor = UIColor.blackColor()
    highScoreLabel.position = CGPointMake(CGRectGetMidX(self.frame), self.frame.size.height - BORDER_SPACE*1.5 - highScoreLabel.frame.size.height)
    highScoreLabel.text = "NEW HIGH SCORE!"
    self.addChild(highScoreLabel)

    
  }
  
  override func didMoveToView(view:SKView) {
    playerNameField = UITextField(frame:CGRectMake((self.size.width - TEXT_FIELD_WIDTH)/2,BORDER_SPACE*2.5, TEXT_FIELD_WIDTH, 40))
 //   playerNameField.center = self.view!.center
    playerNameField.borderStyle = UITextBorderStyle.RoundedRect
    playerNameField.textColor = UIColor.blackColor()
    playerNameField.placeholder = "Enter your name here"
    playerNameField.clearButtonMode = UITextFieldViewMode.WhileEditing
    playerNameField.autocorrectionType = UITextAutocorrectionType.No
    self.view?.addSubview(playerNameField)
    
    nameOK = UIButton(frame:CGRectMake((self.size.width - TEXT_FIELD_WIDTH/5)/2,BORDER_SPACE*4, TEXT_FIELD_WIDTH/5, 32))
    nameOK.setTitle("OK", forState:UIControlState.Normal)
    
    nameOK.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
    nameOK.setTitleColor(UIColor.redColor(), forState: UIControlState.Highlighted)
    nameOK.backgroundColor = UIColor.blueColor()
    
    // Making the corners of the button round.
    nameOK.layer.cornerRadius = 10
    nameOK.clipsToBounds = true
    
    // programatically makes this button a trigger for events.
    nameOK.addTarget(self, action: "presentHighScores:", forControlEvents:UIControlEvents.TouchUpInside)
    
    self.view?.addSubview(nameOK)
    
    let withSoundAction = SKAction.playSoundFileNamed("gameoverSound.aiff", waitForCompletion:false)
    self.runAction(withSoundAction)
  }
  
  func presentHighScores(sender:UIButton) {
    var playerName:String = self.playerNameField.text
    if (countElements(playerName) > 14) {
      playerName = playerName[playerName.startIndex ..< advance(playerName.startIndex,14)]
    }
    self.scores.newHighScore(playerName, score: self.score)
    if (!self.enteredName) {
      self.enteredName = true
      // To hide the keyboard
      self.playerNameField.resignFirstResponder()
      let highScores = scores.getScoresDescending()
      var posY:CGFloat = self.frame.size.height - BORDER_SPACE*6
      var counter:UInt8 = 1
      for (k, v) in highScores {
        let nameLabel = SKLabelNode(fontNamed: "Courier")
        nameLabel.fontSize = 18
        nameLabel.fontColor = UIColor.blackColor()
        nameLabel.text = "\(counter). \(k)"
        nameLabel.position = CGPointMake(BORDER_SPACE + nameLabel.frame.size.width/2, posY - nameLabel.frame.size.height)

        let scoreLabel = SKLabelNode(fontNamed: "Courier")
        scoreLabel.fontSize = 18
        scoreLabel.fontColor = UIColor.blackColor()
        scoreLabel.text = "\(v)"
        scoreLabel.position = CGPointMake(self.size.width - scoreLabel.frame.size.width/2 - BORDER_SPACE, posY - scoreLabel.frame.size.height)

        
        posY = posY - nameLabel.frame.size.height - 10
        counter++
        self.addChild(nameLabel)
        self.addChild(scoreLabel)
      }
    }
  }
  
  override func touchesBegan(touches: NSSet, withEvent event: UIEvent) {
    if (enteredName) {
      self.playerNameField.removeFromSuperview()
      self.nameOK.removeFromSuperview()
      let newGameScene = GameOverScene(size: self.size, playerWon:self.playerWon, playerScore:self.score, scoreKeeper:scores)
      self.view?.presentScene(newGameScene)
    }
  }
  
  required init?(coder aDecoder: NSCoder) {
    super.init(coder:aDecoder)
  }
}