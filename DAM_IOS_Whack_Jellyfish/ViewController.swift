//
//  ViewController.swift
//  DAM_IOS_Whack_Jellyfish
//
//  Created by raul.ramirez on 13/02/2020.
//  Copyright © 2020 Raul Ramirez. All rights reserved.
//

import UIKit
import ARKit
import Each

class ViewController: UIViewController {

    @IBOutlet weak var mSceneview: ARSCNView!
    @IBOutlet weak var mTemp: UILabel!
    @IBOutlet weak var mPlay: UIButton!
    @IBOutlet weak var mRestart: UIButton!
    let configuration = ARWorldTrackingConfiguration()
    
    var temp = Each(1).seconds
    var counter = 10
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    
        self.mSceneview.debugOptions = [.showWorldOrigin]
        self.mSceneview.session.run(configuration)
        self.mSceneview.autoenablesDefaultLighting = true
        
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        
        self.mSceneview.addGestureRecognizer(tapGestureRecognizer)
        
        self.mRestart.isEnabled = false
    }
    
    @IBAction func playAction(_ sender: Any) {
        AppData.enemiesCounter = 0
        self.addNode()
        self.setTime()
        
        self.mPlay.isEnabled = false
    }
    
    func addNode(){
        AppData.indexEnemy = Int.random(in: 0 ..< AppData.enemies.count)
        let enemyScene = SCNScene(named: AppData.enemies[AppData.indexEnemy])
        let enemy = enemyScene?.rootNode.childNode(withName: AppData.nameEnemies[AppData.indexEnemy], recursively: false)
        
        let x = self.randomNumbers(first: -1, second: 1)
        let y = self.randomNumbers(first: -1, second: 1)
        let z = self.randomNumbers(first: -1, second: 1)
        
        enemy?.position = SCNVector3(x, y, z)
        enemy?.name = AppData.name
        self.scaleEnemy(node: enemy!)
        
        self.mSceneview.scene.rootNode.addChildNode(enemy!)
    }
    
    @objc func handleTap(sender: UITapGestureRecognizer){
        let sceneViewTappedOn = sender.view as! SCNView
        let touchCoordinates = sender.location(in: sceneViewTappedOn)
        let hitTest = sceneViewTappedOn.hitTest(touchCoordinates)
        
        if !hitTest.isEmpty{
            let node = hitTest.first!.node
            if AppData.name == node.name{
                AppData.enemiesCounter += 1
                print(AppData.enemies)
                if node.animationKeys.isEmpty, node.name != nil{
                    SCNTransaction.begin()
                    self.animateEnemy(node: node)
                    SCNTransaction.completionBlock = {
                        node.removeFromParentNode()
                        self.addNode()
                        self.restartTime()
                    }
                    SCNTransaction.commit()
                }
            }
        }
    }
    
    func scaleEnemy(node: SCNNode){
        if AppData.indexEnemy != 0{
            node.scale = SCNVector3(0.4, 0.4, 0.4)
        }else{
            node.scale = SCNVector3(0.2, 0.2, 0.2)
        }
    }
    
    func animateEnemy(node: SCNNode){
        let spin = CABasicAnimation(keyPath: "position")
        spin.fromValue = node.presentation.position
        
        if AppData.indexEnemy != 0{
            spin.toValue = SCNVector3(node.presentation.position.x, node.presentation.position.y - 0.5 , node.presentation.position.z - 0.2)
            spin.duration = 0.1
            spin.autoreverses = true
            spin.repeatCount = 3

        }else{
            spin.toValue = SCNVector3(node.presentation.position.x - 0.2, node.presentation.position.y - 0.2 , node.presentation.position.z - 0.2)
            spin.duration = 0.1
            spin.autoreverses = true
            spin.repeatCount = 5
        }
        
        node.addAnimation(spin, forKey: "position")
    }
    
    func randomNumbers(first: CGFloat, second: CGFloat) -> CGFloat{
        return CGFloat(arc4random()) / CGFloat(UINT32_MAX) * abs(first - second) + min(first, second)
    }
    
    func setTime(){
        self.temp.perform{ () -> NextStep in
            self.counter -= 1
            self.mTemp.text = String(self.counter)
            
            if self.counter <= 0{
                if AppData.enemiesCounter <= 0{
                    self.mTemp.text = "HAS PERDIDO :("
                    self.removeEnemies()
                    self.mRestart.isEnabled = true
                    return .stop
                }else{
                    self.mTemp.text = "ENEMIGOS: \(AppData.enemiesCounter)"
                    self.mRestart.isEnabled = true
                    self.removeEnemies()
                }
            }
            
            return .continue
        }
    }
    
    func restartTime(){
        self.counter = 10
        self.mTemp.text = "JUGAR"
    }
    
    @IBAction func restartAction(_ sender: Any) {
        self.removeEnemies()
        AppData.enemiesCounter = 0
        self.mPlay.isEnabled = true
        self.mRestart.isEnabled = false
        
        self.restartTime()
    }
    
    func removeEnemies(){
        self.mSceneview.scene.rootNode.enumerateHierarchy({ (node, _) in
            if node.name == AppData.name{
                node.removeFromParentNode()
            }
        })
    }
}

struct AppData {
    static let name: String = "enemy"
    static var enemiesCounter: Int = 0
    static let enemies: [String] = ["art.scnassets/Jellyfish.scn", "art.scnassets/basketball_DAE.scn"]
    static let nameEnemies: [String] = ["Sphere", "BasketballBall"]
    static var indexEnemy: Int = -1
}

