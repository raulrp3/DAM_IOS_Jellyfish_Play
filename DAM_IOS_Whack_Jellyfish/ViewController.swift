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
        AppData.enemies = 0
        self.addNode()
        self.setTime()
        
        self.mPlay.isEnabled = false
    }
    
    func addNode(){
        let jellyScene = SCNScene(named: "art.scnassets/Jellyfish.scn")
        let jellyfish = jellyScene?.rootNode.childNode(withName: "Sphere", recursively: false)
        
        let x = self.randomNumbers(first: -1, second: 1)
        let y = self.randomNumbers(first: -1, second: 1)
        let z = self.randomNumbers(first: -1, second: 1)
        
        jellyfish?.position = SCNVector3(x, y, z)
        jellyfish?.name = AppData.name
        jellyfish?.scale = SCNVector3(0.2, 0.2, 0.2)
        
        self.mSceneview.scene.rootNode.addChildNode(jellyfish!)
    }
    
    @objc func handleTap(sender: UITapGestureRecognizer){
        let sceneViewTappedOn = sender.view as! SCNView
        let touchCoordinates = sender.location(in: sceneViewTappedOn)
        let hitTest = sceneViewTappedOn.hitTest(touchCoordinates)
        
        if !hitTest.isEmpty{
            let node = hitTest.first!.node
            if AppData.name == node.name{
                AppData.enemies += 1
                print(AppData.enemies)
                if node.animationKeys.isEmpty, node.name != nil{
                    SCNTransaction.begin()
                    self.animateJellyfish(node: node)
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
    
    func animateJellyfish(node: SCNNode){
        let spin = CABasicAnimation(keyPath: "position")
        spin.fromValue = node.presentation.position
        spin.toValue = SCNVector3(node.presentation.position.x - 0.2, node.presentation.position.y - 0.2 , node.presentation.position.z - 0.2)
        spin.duration = 0.1
        spin.autoreverses = true
        spin.repeatCount = 5
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
                if AppData.enemies <= 0{
                    self.mTemp.text = "HAS PERDIDO :("
                    self.removeEnemies()
                    self.mRestart.isEnabled = true
                    return .stop
                }else{
                    self.mTemp.text = "ENEMIGOS: \(AppData.enemies)"
                    self.mRestart.isEnabled = true
                    self.removeEnemies()
                }
            }
            
            return .continue
        }
    }
    
    func restartTime(){
        self.counter = 10
        self.mTemp.text = String(self.counter)
    }
    
    @IBAction func restartAction(_ sender: Any) {
        self.removeEnemies()
        AppData.enemies = 0
        self.addNode()
        
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
    static var enemies: Int = 0
}

