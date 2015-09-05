import UIKit
import SpriteKit

class GameViewController: UIViewController {
    var PlayerFirstName : String = ""
    var PlayerLastName : String = ""
    var UserName : String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the scene and start the game
        let scene = GameScene(size: view.bounds.size)
        scene.PlayerFirstName = PlayerFirstName
        scene.PlayerLastName = PlayerLastName
        scene.UserName = UserName
        let skView = view as! SKView
        skView.showsFPS = false
        skView.showsNodeCount = false
        skView.ignoresSiblingOrder = true
        scene.scaleMode = .ResizeFill
        skView.presentScene(scene)
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
}