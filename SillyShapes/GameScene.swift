//
//  GameScene.swift
//  SillyShapes
//
//  Created by Fernando Castor on 03/02/15.
//  Copyright (c) 2015 UFPE. All rights reserved.
//

import SpriteKit

class GameScene: SKScene, SKPhysicsContactDelegate {
  
//-----------------------------------/CONSTANTS/--------------------------------------
  let TEXT_SIZE = 20
  
  let SHOT_CATEGORY:UInt32 = 0x1 << 0
  
  // Constant numbers for the shapes have to be consecutive. Correctness of the 
  // shape selection depends on this.
  let TRIANGLE_CATEGORY:UInt32 = 0x1 << 1
  let SQUARE_CATEGORY:UInt32 = 0x1 << 2
  let PENTAGON_CATEGORY:UInt32 = 0x1 << 3
  let HEXAGON_CATEGORY:UInt32 = 0x1 << 4
  
  let BOTTOM_CATEGORY:UInt32 = 0x1 << 5
  
  var ALL_SHAPES:UInt32 = 0
  
  
  let NUMBER_OF_SHARDS = 100
  let NUMBER_OF_SHARD_STEPS = 100
  let BORDER_SPACE:CGFloat = 2
  
  let EXPLOSION_DURATION:NSTimeInterval = 1
  
  let ENDGAME_THRESHOLD:UInt32 = 5
  
  let FAST_SHAPES_START_AT = 10

  let FAST_SHAPES_END_AT = 15
  
  let PHASE_THRESHOLD:UInt32 = 10
 
  let NEW_LIFE:UInt32 = 50
  
  let NUM_SHAPES = 4

  
//-----------------------------------/VARS/--------------------------------------
  var gameOver:Bool = false
  
  var shootsStartingPosition:[NSValue:CGPoint] = [NSValue:CGPoint]()
  var shootingArea:SKSpriteNode? = .None
  
  var randomXs:[CGFloat] = [CGFloat]()
  var randomYs:[CGFloat] = [CGFloat]()
  
  var currentGravity:CGFloat = -2.0
  
  // Number of shapes not hit necessary for the game to end.
  var endGameMisses = 3
  
  var points:SKLabelNode = SKLabelNode()
  
  // No such thing as arithmetic overload.
  var shapeCounter:UInt32 = 0
  var hitCounter:UInt32 = 0
  var phaseHitCounter:UInt32 = 0
  var shotCounter:UInt32 = 0
  
  var phaseShapeCounter:UInt32 = 0
  
  var scores:ScoreKeeper = ScoreKeeper(numScores:10)
  
  var shotScale:CGFloat = 0.35
  var shotDensity:CGFloat = 2
  
  var standardShapeSize:CGFloat = 0.8
  
  // A multiplier that affects the impulse of every falling shape
  var shapeImpulseFactor:CGFloat = 1
  
  // Initially, fast shapes are only thrice as fast as regular ones.
  var fastShapeMultiplier:CGFloat = 3
  
  var consecutiveHits:UInt32 = 0
  
  var extraPointsElement = ""
  
  var slowShapesLeft = 0

  var shots:[SKSpriteNode] = [SKSpriteNode]()
  
  var phase:UInt32 = 1
  
  var lives:UInt32 = 0
  
  var enabledShapes:CGFloat = 1
  
  var hitShapes:[NSValue:UInt32] = [NSValue:UInt32]()
  
  let hitsRequired:[UInt32:UInt32] = [UInt32:UInt32]()

  
  //-----------------------------------/INITIALIZERS/--------------------------------------
  required init?(coder aDecoder:NSCoder) {
    super.init(coder:aDecoder)
  }
  
  init(size: CGSize, scoreKeeper:ScoreKeeper) {
    super.init(size:size)

    self.scores = scoreKeeper
    
    self.ALL_SHAPES = TRIANGLE_CATEGORY | SQUARE_CATEGORY | PENTAGON_CATEGORY | HEXAGON_CATEGORY
    self.hitsRequired = [TRIANGLE_CATEGORY:1, SQUARE_CATEGORY:2, PENTAGON_CATEGORY:3, HEXAGON_CATEGORY:4]
    
    
    // Initializes randomXs and randomYs for explosions.
    for i in 0...(NUMBER_OF_SHARDS-1) {
      randomXs.append(self.random())
      randomYs.append(self.random())
    }
    
    self.physicsWorld.gravity = CGVectorMake(0, currentGravity)
    self.physicsWorld.contactDelegate = self
    //  let backgroundImage = SKSpriteNode(imageNamed: "bg")
    //  backgroundImage.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame))
    //  self.addChild(backgroundImage)
    self.backgroundColor = UIColor.whiteColor()
    
    self.shootingArea = SKSpriteNode(imageNamed: "shootingArea")
    // In the following, we're safe to use the "!" operator since we're sure that
    // there is .Some shootingArea
    self.shootingArea!.position = CGPointMake(self.shootingArea!.frame.size.width/2, self.shootingArea!.frame.size.height/2)
    self.shootingArea!.alpha = 0.3
    self.addChild(self.shootingArea!)

    self.lives = self.ENDGAME_THRESHOLD
    
    points = SKLabelNode(text: "Hits: 0  Lives:\(self.lives)")
    points.position = CGPointMake(points.frame.size.width/2 + BORDER_SPACE,
      self.frame.size.height - points.frame.size.height - BORDER_SPACE)
    points.fontColor = UIColor.blackColor()
    points.fontSize = 16
    points.fontName = "Courier"
    
    // Represents the bottom part of the screen
    let bottomRect = CGRectMake(self.frame.origin.x, self.frame.origin.y, self.frame.size.width, 1)
    let bottom = SKNode()
    bottom.physicsBody = SKPhysicsBody(edgeLoopFromRect: bottomRect)
    self.addChild(bottom)
    bottom.physicsBody?.categoryBitMask = BOTTOM_CATEGORY

    
    self.addChild(points)
  }
  
//-----------------------------------/METHODS/--------------------------------------
  override func touchesBegan(touches: NSSet, withEvent event: UIEvent) {
    for touch: AnyObject in touches {
      
      // Let's register the first point of the shot. Its overall will be
      // dictated by the first (touchesBegan) and last (touchesEnded) points.
      let theTouch = touch as UITouch
      let location:CGPoint = theTouch.locationInNode(self)
      if let shootingA = self.shootingArea as SKSpriteNode? {
        
        // The touch was located within the shooting area. This must be true for the
        // end touch as well.
        if location.x <= shootingA.frame.size.width && location.y <= shootingA.frame.size.height {
          let key:NSValue = NSValue(nonretainedObject: theTouch)
          self.shootsStartingPosition[key] = location
        }
      }
    }
  }

  func selectShape() -> (String, UInt32) {
    let raffle = random() * self.enabledShapes
    // We shift by 0x2 because the shape masks start at 1.
    var selectedCategory = 0x2 << UInt32(floor(raffle))
    println("\(selectedCategory)")
    
    if (selectedCategory == self.SQUARE_CATEGORY) {
      NSLog("Square.")
      return ("square", self.SQUARE_CATEGORY)
    } else if (selectedCategory == self.PENTAGON_CATEGORY) {
      NSLog("Square.")
      return ("pentagon", self.PENTAGON_CATEGORY)
    }else if (selectedCategory == self.HEXAGON_CATEGORY) {
      NSLog("Square.")
      return ("hexagon", self.HEXAGON_CATEGORY)
    } else {
      NSLog("Triangle.")
      return ("triangle", self.TRIANGLE_CATEGORY)
    }
    
  }
  
  func createShape() {
    let raffle = random()

    //There's a 3% chance that, at any given moment, a new shape will appear.
    if (raffle <= 0.03 && !gameOver) {
      
      var selectedShape:(String, UInt32) = self.selectShape()
      
      let newShape = SKSpriteNode(imageNamed: selectedShape.0)
      newShape.physicsBody = SKPhysicsBody(rectangleOfSize: newShape.frame.size)
      newShape.physicsBody?.categoryBitMask = selectedShape.1//self.TRIANGLE_CATEGORY

      newShape.setScale(max(self.standardShapeSize * self.random(), 0.35))
      var randomX = random(min:newShape.frame.size.width/2, max:self.frame.size.width - newShape.frame.size.width/2)
      newShape.position = CGPointMake(randomX, self.frame.size.height + newShape.frame.size.width)
      
      self.addChild(newShape)
      
      newShape.physicsBody?.friction = 0
      newShape.physicsBody?.restitution = 0
      newShape.physicsBody?.linearDamping = 0
      
      newShape.physicsBody?.dynamic = true
      
      // This bitmask is used to identify whether the shape physics body came into
      // contact with some other physics body.
      newShape.physicsBody?.contactTestBitMask = BOTTOM_CATEGORY

      self.phaseShapeCounter++
      
      slowShapesLeft++
      var impulse:CGFloat = 0
      if (slowShapesLeft < FAST_SHAPES_START_AT) {
        impulse = -self.shapeImpulseFactor * random()/2
        newShape.physicsBody?.applyImpulse(CGVectorMake(0, impulse))
  //      NSLog("SLOW: \(impulse)")
      } else if (slowShapesLeft >= FAST_SHAPES_START_AT && slowShapesLeft <= FAST_SHAPES_END_AT){
        impulse = -self.fastShapeMultiplier * self.shapeImpulseFactor * random()///2
        newShape.physicsBody?.applyImpulse(CGVectorMake(0, impulse))
  //      NSLog("FAST: \(impulse)")
      }
      else {
  //      NSLog("RESET")
        slowShapesLeft = 0
      }
    }
  }
  
  // This function is invoked everytime the screen is refreshed. Things that
  // happen regularly or at random intervals should be started here.
  override func update(currentTime: NSTimeInterval) {
    self.createShape()
    
    if self.phaseShapeCounter >= PHASE_THRESHOLD {
      self.phase++
      self.changePhase(self.phase)
    }

    // Checks if a streak of consecutive hits was interrupted
    self.shots = self.shots.filter({(s:SKSpriteNode) -> Bool in
      if s.position.x > self.size.width
        || s.position.y > self.size.height
        || s.position.y < 0 {
          // The shot left the screen. This means that it must
          // be removed from the screen and that a streak of
          // consecutive hits was broken.
          self.consecutiveHits = 0
          s.removeFromParent()
          return false
      }
      return true
    })

  }
  
  func changePhase(newPhase:UInt32) {
    self.shapeImpulseFactor += CGFloat(newPhase) * 2
    self.phaseShapeCounter = 0
    var newPhaseLabel:SKLabelNode = SKLabelNode(text:"NÍVEL \(newPhase)")
    newPhaseLabel.fontSize = 36
    newPhaseLabel.fontColor = UIColor.redColor()
    newPhaseLabel.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame))
    self.addChild(newPhaseLabel)
    let fadeInAction = SKAction.fadeInWithDuration(EXPLOSION_DURATION)
    let fadeOutAction = SKAction.fadeInWithDuration(EXPLOSION_DURATION)
    newPhaseLabel.runAction(SKAction.sequence([fadeInAction, fadeOutAction, SKAction.removeFromParent()]))
    
    if (self.enabledShapes <= CGFloat(self.NUM_SHAPES)) {
      if (newPhase % 2 == 0) {
        self.enabledShapes++
      }
    }
  }
  
  override func touchesEnded(touches: NSSet, withEvent event: UIEvent) {
    for touch: AnyObject in touches {
      let theTouch = touch as UITouch
      let endLocation:CGPoint = theTouch.locationInNode(self)
      let key:NSValue = NSValue(nonretainedObject: theTouch)
      
      if let shootingA = self.shootingArea as SKSpriteNode? {
        
        // The touch was located within the shooting area. This must be true for the
        // end touch as well.
        if endLocation.x <= (shootingA.frame.size.width * 1.5) && endLocation.y <= (shootingA.frame.size.height * 1.5) {
          if let startLocation = self.shootsStartingPosition[key] as CGPoint? {
            // Now add a shoot to the screen.
            let shot = SKSpriteNode(imageNamed: "ball")
            shot.position = endLocation
            shot.setScale(self.shotScale)
            
            self.addChild(shot)
            self.shots.append(shot)
            shot.physicsBody = SKPhysicsBody(circleOfRadius: shot.frame.size.width/2)
            
            shot.physicsBody?.categoryBitMask = SHOT_CATEGORY
            shot.physicsBody?.friction = 0
            shot.physicsBody?.linearDamping = 0
            shot.physicsBody?.allowsRotation = false
            shot.physicsBody?.density = self.shotDensity
            shot.physicsBody?.dynamic = true
            
            // This bitmask is used to identify whether the ball physics body came into
            // contact with some other physics body.
            shot.physicsBody?.contactTestBitMask = ALL_SHAPES | BOTTOM_CATEGORY
            
            // Initially, no restitution for the shoots. They do not ricochet.
            shot.physicsBody?.restitution = 0
            
            let vecX = (endLocation.x - startLocation.x) > 0 ? (endLocation.x - startLocation.x) : 0
            let vecY = (endLocation.y - startLocation.y > 0) ? (endLocation.y - startLocation.y) : 0
            shot.physicsBody?.applyImpulse(CGVectorMake(sqrt(vecX)/3, sqrt(vecY)/3))
            let withSoundAction = SKAction.playSoundFileNamed("shotSound.aiff", waitForCompletion:false)
            self.runAction(withSoundAction)

            self.shotCounter++
            self.updatePoints()
          }
        }
      }
    }
  }
  
  func checkGameOver() {
    if self.lives <= 0 {
      self.gameOver = true
      
      if self.scores.isPossibleHighScore(self.hitCounter) {
        let highScoresScene = HighScoresScene(size:self.frame.size, playerWon:false, playerScore:self.hitCounter, scoreKeeper:self.scores)
        self.view?.presentScene(highScoresScene)
      }
      else {
        let gameOverScene = GameOverScene(size: self.frame.size, playerWon: false, playerScore:self.hitCounter, scoreKeeper:self.scores)
        self.view?.presentScene(gameOverScene)
      }
    }
  }
  
  func updatePoints() {
    // # of hits, # of shapes that reached the bottom, # of balls that did not hit.
    self.points.text = "Pts:\(self.hitCounter) Vidas:\(self.lives)"// \(extraPointsElement)"
    points.position = CGPointMake(points.frame.size.width/2 + BORDER_SPACE,
      self.frame.size.height - points.frame.size.height - BORDER_SPACE)
  }
  
  // This is the method that handles collisions.
  func didBeginContact(contact:SKPhysicsContact) {
    var firstBody = contact.bodyA
    var secondBody = contact.bodyB
    
    if (firstBody.categoryBitMask >= secondBody.categoryBitMask) {
      firstBody = contact.bodyB
      secondBody = contact.bodyA
    }
    if firstBody.categoryBitMask == SHOT_CATEGORY && (secondBody.categoryBitMask & self.ALL_SHAPES > 0) {
      self.bookkeepCollidingBodies(firstBody, secondBody: secondBody, shapeCategory: secondBody.categoryBitMask)
    }
/*    if firstBody.categoryBitMask == SHOT_CATEGORY && secondBody.categoryBitMask == SQUARE_CATEGORY {
      self.bookkeepCollidingBodies(firstBody, secondBody: secondBody, shapeCategory: self.SQUARE_CATEGORY)
    }
*/
    if firstBody.categoryBitMask == SHOT_CATEGORY && (secondBody.categoryBitMask == BOTTOM_CATEGORY) {
      if let firstNode = firstBody.node as SKNode? {
        firstNode.removeFromParent()
      }
    }
    if (firstBody.categoryBitMask & self.ALL_SHAPES > 0) && secondBody.categoryBitMask == BOTTOM_CATEGORY {
      // Only update the shapeCounter when the shape hits the bottom of the screen.
      if let firstNode = firstBody.node as SKNode? {
        firstNode.removeFromParent()
        self.shapeCounter++
        self.lives--
        self.updatePoints()
        self.checkGameOver()
      }
    }
  }
  
  func bookkeepCollidingBodies(firstBody:SKPhysicsBody, secondBody:SKPhysicsBody, shapeCategory:UInt32) {
    if let secondNode = secondBody.node as SKNode? {
      if let firstNode = firstBody.node as SKNode? {
        var key:NSValue = NSValue(nonretainedObject: secondNode)
        if let shotsLeft:UInt32 = self.hitShapes[key] {
          if (shotsLeft == 1) {
            self.createExplosion(secondNode.position, shapeCategory:shapeCategory, numShards:self.NUMBER_OF_SHARDS, numSteps:self.NUMBER_OF_SHARD_STEPS)
            secondNode.removeFromParent()
            firstNode.removeFromParent()
            var reinitPhaseHitCounter:Bool = false
            // The next increase in the hit counter will result in the player wining
            // an extra life.
            if (self.phaseHitCounter < self.NEW_LIFE && (self.phaseHitCounter + 1 + self.consecutiveHits) >= self.NEW_LIFE) {
              self.lives++
              reinitPhaseHitCounter = true
            }
            self.hitCounter++
            self.hitCounter += self.consecutiveHits
            
            if (reinitPhaseHitCounter) {
              self.phaseHitCounter = 0
            }
            else {
              self.phaseHitCounter += self.consecutiveHits
              self.phaseHitCounter++
            }
            consecutiveHits++
            self.updatePoints()
          }
          else {
            self.hitShapes[key] = shotsLeft - 1
            self.createExplosion(secondNode.position, shapeCategory:shapeCategory, numShards:self.NUMBER_OF_SHARDS/3, numSteps:self.NUMBER_OF_SHARD_STEPS/3)
            let withSoundAction = SKAction.playSoundFileNamed("hitSound.aiff", waitForCompletion:false)
            self.runAction(withSoundAction)
          }
        } else if self.hitsRequired[shapeCategory] == 1 {
          self.createExplosion(secondNode.position, shapeCategory:shapeCategory, numShards:self.NUMBER_OF_SHARDS, numSteps:self.NUMBER_OF_SHARD_STEPS)
          secondNode.removeFromParent()
          firstNode.removeFromParent()
          var reinitPhaseHitCounter:Bool = false
          // The next increase in the hit counter will result in the player wining
          // an extra life.
          if (self.phaseHitCounter < self.NEW_LIFE && (self.phaseHitCounter + 1 + self.consecutiveHits) >= self.NEW_LIFE) {
            self.lives++
            reinitPhaseHitCounter = true
          }
          self.hitCounter++
          self.hitCounter += self.consecutiveHits
          
          if (reinitPhaseHitCounter) {
            self.phaseHitCounter = 0
          }
          else {
            self.phaseHitCounter += self.consecutiveHits
            self.phaseHitCounter++
          }
          consecutiveHits++
          self.updatePoints()
        }else {
          if let hitsReq = self.hitsRequired[shapeCategory] {
            self.hitShapes[key] = hitsReq - 1
            self.createExplosion(secondNode.position, shapeCategory:shapeCategory, numShards:self.NUMBER_OF_SHARDS/3, numSteps:self.NUMBER_OF_SHARD_STEPS/3)
            let withSoundAction = SKAction.playSoundFileNamed("hitSound.aiff", waitForCompletion:false)
            self.runAction(withSoundAction)
          }
        }
      }
    }
  }
  
  
  
  private func explosionShape(shapeCategory:UInt32) -> String {
    var result:String = ""//"explosiontriangle"
    if (shapeCategory == self.TRIANGLE_CATEGORY) {
      result = "explosiontriangle"
    } else if (shapeCategory == self.SQUARE_CATEGORY) {
      result = "explosionsquare"
    }
    else if (shapeCategory == self.PENTAGON_CATEGORY){
      result = "explosionpentagon"
    } else if (shapeCategory == self.HEXAGON_CATEGORY) {
      result = "explosionhexagon"
    }
    return result
  }
  
  /*
  * The numShards parameter must be smaller than or equal to NUMBER_OF_SHARDS.
  * Analogously, numSteps must be smaller than or equal to NUMBER_OF_SHARD_STEPS.
  */
  func createExplosion(position:CGPoint, shapeCategory:UInt32, numShards:Int, numSteps:Int) {
    var shard:SKSpriteNode
    
    for i in 0 ... (numShards - 1) {

      var explosionShape:String = self.explosionShape(shapeCategory)
      shard = SKSpriteNode(imageNamed:"\(explosionShape)\((i%2==0) ? 1 : 2)")
      shard.setScale(0.5)
      shard.position = position
      self.addChild(shard)
      // The only reason for the physical body is to make the
      // shards fall.
      shard.physicsBody = SKPhysicsBody()
      
      let fadeAction = SKAction.fadeOutWithDuration(EXPLOSION_DURATION)
      let stepDuration = (EXPLOSION_DURATION/Double(numSteps))
      let stepAction = SKAction.moveBy(CGVectorMake(randomXs[i] * 2, randomYs[i] * 2), duration:stepDuration)
      let removeAction = SKAction.removeFromParent()
      let moveAction = SKAction.repeatAction(stepAction, count:numSteps)
      let moveAndFadeAction = SKAction.group([moveAction, fadeAction])
      let seqAction = SKAction.sequence([moveAndFadeAction, removeAction])
      shard.runAction(seqAction)
    }
    self.runAction(SKAction.playSoundFileNamed("explosionSound.aiff", waitForCompletion:false))
  }
  
  func random() -> CGFloat {
    return CGFloat(Float(arc4random()) / 0xFFFFFFFF)
  }
  
  func random(#min: CGFloat, max: CGFloat) -> CGFloat {
    return random() * (max - min) + min
  }
}
