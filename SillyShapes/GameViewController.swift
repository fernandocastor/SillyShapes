//
//  GameViewController.swift
//  SillyShapes
//
//  Created by Fernando Castor on 03/02/15.
//  Copyright (c) 2015 UFPE. All rights reserved.
//

import UIKit
import SpriteKit

extension SKNode {
  class func unarchiveFromFile(file : NSString) -> SKNode? {
    if let path = NSBundle.mainBundle().pathForResource(file, ofType: "sks") {
      var sceneData = NSData(contentsOfFile: path, options: .DataReadingMappedIfSafe, error: nil)!
      var archiver = NSKeyedUnarchiver(forReadingWithData: sceneData)
      
      archiver.setClass(self.classForKeyedUnarchiver(), forClassName: "SKScene")
      let scene = archiver.decodeObjectForKey(NSKeyedArchiveRootObjectKey) as GameScene
      archiver.finishDecoding()
      return scene
    } else {
      return nil
    }
  }
}

class GameViewController: UIViewController {

  var scores:ScoreKeeper = ScoreKeeper(numScores: 10)
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    let skView = self.view as SKView
    // The view is refreshed lockstep with the refresh rate of
    // the screen. In theory, this should bring refresh rate to
    // 60FPS. In practice, it's not working.
    skView.frameInterval = 1
  }
  
  override func viewWillLayoutSubviews() {
    super.viewWillLayoutSubviews()
    
    let skView = self.view as SKView
    if skView.scene == nil {
      skView.showsFPS = true
  //    skView.showsNodeCount = true
      
      // Optimization which ignores the order in which nodes that share a Z coordinate
      // are rendered.
  //    skView.ignoresSiblingOrder = true
      
      let gameScene = GameScene(size:skView.bounds.size, scoreKeeper:scores)
      gameScene.scaleMode = .AspectFill
      skView.presentScene(gameScene)
    }
  }
  
  
  override func shouldAutorotate() -> Bool {
    return true
  }
  
  override func supportedInterfaceOrientations() -> Int {
    if UIDevice.currentDevice().userInterfaceIdiom == .Phone {
      return Int(UIInterfaceOrientationMask.AllButUpsideDown.rawValue)
    } else {
      return Int(UIInterfaceOrientationMask.All.rawValue)
    }
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Release any cached data, images, etc that aren't in use.
  }
  
  override func prefersStatusBarHidden() -> Bool {
    return true
  }
}
