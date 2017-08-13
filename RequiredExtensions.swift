//
//  RequiredExtensions.swift
//  DemoGame
//
//  Created by Agstya  on 12/08/17.
//  Copyright © 2017 Bharat Nakum. All rights reserved.
//

import Foundation
import SceneKit
import SpriteKit


public extension Float {
    public static func random(min: Float, max: Float) -> Float {
        let r32 = Float(arc4random(type: UInt32.self)) / Float(UInt32.max)
        return (r32 * (max - min)) + min
    }
}

let UIColorList:[UIColor] = [
    UIColor.black,
    UIColor.white,
    UIColor.red,
    UIColor.limeColor(),
    UIColor.blue,
    UIColor.yellow,
    UIColor.cyan,
    UIColor.silverColor(),
    UIColor.gray,
    UIColor.maroonColor(),
    UIColor.oliveColor(),
    UIColor.brown,
    UIColor.green,
    UIColor.lightGray,
    UIColor.magenta,
    UIColor.orange,
    UIColor.purple,
    UIColor.tealColor()
]

extension UIColor {
    
    public static func random() -> UIColor {
        let maxValue = UIColorList.count
        let rand = Int(arc4random_uniform(UInt32(maxValue)))
        return UIColorList[rand]
    }
    
    public static func limeColor() -> UIColor {
        return UIColor(red: 0.0, green: 1.0, blue: 0.0, alpha: 1.0)
    }
    
    public static func silverColor() -> UIColor {
        return UIColor(red: 192/255, green: 192/255, blue: 192/255, alpha: 1.0)
    }
    
    public static func maroonColor() -> UIColor {
        return UIColor(red: 0.5, green: 0.0, blue: 0.0, alpha: 1.0)
    }
    
    public static func oliveColor() -> UIColor {
        return UIColor(red: 0.5, green: 0.5, blue: 0.0, alpha: 1.0)
    }
    
    public static func tealColor() -> UIColor {
        return UIColor(red: 0.0, green: 0.5, blue: 0.5, alpha: 1.0)
    }
    
    public static func navyColor() -> UIColor {
        return UIColor(red: 0.0, green: 0.0, blue: 128, alpha: 1.0)
    }
}

public extension Double {
    public static func random(min: Double, max: Double) -> Double {
        let r64 = Double(arc4random(type: UInt64.self)) / Double(UInt64.max)
        return (r64 * (max - min)) + min
    }
}

public func arc4random <T: ExpressibleByIntegerLiteral> (type: T.Type) -> T {
    var r: T = 0
    arc4random_buf(&r, Int(MemoryLayout<T>.size))
    return r
}

public extension Int {
    public static func random(min: Int , max: Int) -> Int {
        return Int(arc4random_uniform(UInt32(min - max + 1))) + min
    }
}

extension SCNAction {
    
    class func waitForDurationThenRemoveFromParent(duration:TimeInterval) -> SCNAction {
        let wait = SCNAction.wait(duration: duration)
        let remove = SCNAction.removeFromParentNode()
        return SCNAction.sequence([wait,remove])
    }
    
    class func waitForDurationThenRunBlock(duration:TimeInterval, block: @escaping ((SCNNode!) -> Void) ) -> SCNAction {
        let wait = SCNAction.wait(duration: duration)
        let runBlock = SCNAction.run { (node) -> Void in
            block(node)
        }
        return SCNAction.sequence([wait,runBlock])
    }
    
    class func rotateByXForever(x:CGFloat, y:CGFloat, z:CGFloat, duration:TimeInterval) -> SCNAction {
        let rotate = SCNAction.rotateBy(x: x, y: y, z: z, duration: duration)
        return SCNAction.repeatForever(rotate)
    }
    
}

public enum GameStateType {
    case Playing
    case TapToPlay
    case GameOver
}

class GameHelper {
    
    var score:Int
    var highScore:Int
    var lastScore:Int
    var lives:Int
    var state = GameStateType.TapToPlay
    
    var hudNode:SCNNode!
    var labelNode:SKLabelNode!
    
    
    static let sharedInstance = GameHelper()
    
    var sounds:[String:SCNAudioSource] = [:]
    
    private init() {
        score = 0
        lastScore = 0
        highScore = 0
        lives = 3
        let defaults = UserDefaults.standard
        score = defaults.integer(forKey: "lastScore")
        highScore = defaults.integer(forKey: "highScore")
        
        initHUD()
    }
    
    func saveState() {
        
        lastScore = score
        highScore = max(score, highScore)
        let defaults = UserDefaults.standard
        defaults.set(lastScore, forKey: "lastScore")
        defaults.set(highScore, forKey: "highScore")
        UserDefaults.standard.synchronize()
    }
    
    func getScoreString(length:Int) -> String {
        return String(format: "%0\(length)d", score)
    }
    
    func initHUD() {
        
        let skScene = SKScene(size: CGSize(width: 500, height: 100))
        skScene.backgroundColor = UIColor(white: 0.0, alpha: 0.0)
        
        labelNode = SKLabelNode(fontNamed: "Menlo-Bold")
        labelNode.fontSize = 48
        labelNode.position.y = 50
        labelNode.position.x = 250
        
        skScene.addChild(labelNode)
        
        let plane = SCNPlane(width: 5, height: 1)
        let material = SCNMaterial()
        material.lightingModel = SCNMaterial.LightingModel.constant
        material.isDoubleSided = true
        material.diffuse.contents = skScene
        plane.materials = [material]
        
        hudNode = SCNNode(geometry: plane)
        hudNode.name = "HUD"
        hudNode.rotation = SCNVector4(x: 1, y: 0, z: 0, w: 3.14159265)
    }
    
    func updateHUD() {
        let scoreFormatted = String(format: "%0\(4)d", score)
        let highScoreFormatted = String(format: "%0\(4)d", highScore)
        labelNode.text = "❤️\(lives)  😎\(highScoreFormatted) 💥\(scoreFormatted)"
    }
    
    func loadSound(name:String, fileNamed:String) {
        let sound = SCNAudioSource(fileNamed: fileNamed)
        sound?.load()
        sounds[name] = sound
    }
    
    func playSound(node:SCNNode, name:String) {
        let sound = sounds[name]
        node.runAction(SCNAction.playAudio(sound!, waitForCompletion: false))
    }
    
    func reset() {
        score = 0
        lives = 3
    }
    
    func shakeNode(node:SCNNode) {
        let left = SCNAction.move(by: SCNVector3(x: -0.2, y: 0.0, z: 0.0), duration: 0.05)
        let right = SCNAction.move(by: SCNVector3(x: 0.2, y: 0.0, z: 0.0), duration: 0.05)
        let up = SCNAction.move(by: SCNVector3(x: 0.0, y: 0.2, z: 0.0), duration: 0.05)
        let down = SCNAction.move(by: SCNVector3(x: 0.0, y: -0.2, z: 0.0), duration: 0.05)
        
        node.runAction(SCNAction.sequence([
            left, up, down, right, left, right, down, up, right, down, left, up,
            left, up, down, right, left, right, down, up, right, down, left, up]))
    }
    
    
}
