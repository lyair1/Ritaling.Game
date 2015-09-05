import SpriteKit
import Parse
import AudioToolbox

class GameScene: SKScene {
    var DEBUGMODE = 0 // Set 1 if you're in debug mode
    var GameIndex = -1 // Starting game indes
    var timerValue = 0
    
    // input parameters
    var PlayerFirstName = ""
    var PlayerLastName = ""
    var UserName = ""
    
    // UIKit component
    var playerNameLabel = UILabel(frame: CGRectMake(20, 80, 300, 30))
    var medLable = UILabel()
    var medSwitch = UISwitch()
    var label = UILabel(frame: CGRectMake(5, 20, 200, 100))
    var CurrentAngleTimer : NSTimer = NSTimer()
    var timeLabel = UILabel(frame: CGRectMake(2, 45, 400, 20))
    var scoreLabel = UILabel(frame: CGRectMake(20, 75, 200, 100))
    var scoreLabelValue = UILabel(frame: CGRectMake(20, 120, 120, 100))
    let circle = SKSpriteNode(imageNamed: "circle")
    let arrow = SKSpriteNode(imageNamed: ArrowImagesCollection.Refresh.rawValue)
    
    // Game parameters
    var clockWise = 1
    var difficulty = 4.0
    var finalDifficulty : Double = -1
    var strikes :[Double] = []
    var baseDifJump = 3
    var difJump = 0
    var ArrowIndex = 0
    var score = 0
    var highScore = 0
    var playing = false
    var timerRun = false
    var startingTime : Double = 0.0
    var nodePosition = CGPoint(x: 0 , y: 0)
    var nodeWidthHight : CGFloat = 250
    
    override func didMoveToView(view: SKView) {
        GetPlayerHighScore()
        GetGameIndexFromDBAndStartGame()
        difJump = baseDifJump
        
        medSwitch = UISwitch(frame: CGRectMake(120, self.view!.frame.height - 50, 0, 0))
        medLable = UILabel(frame: CGRectMake(20, self.view!.frame.height - 50, 100, 20))
        medLable.text = "On Med?"
        self.view?.addSubview(medLable)
        self.view?.addSubview(medSwitch)
        
        // 2
        backgroundColor = SKColor.whiteColor()
        circle.size = CGSizeMake(nodeWidthHight, nodeWidthHight)
        // 3
        nodePosition = CGPoint(x: size.width/2 , y: size.height/6 + nodeWidthHight/2)
        circle.position = nodePosition
        // 4
        addChild(circle)
        
        
        if DEBUGMODE == 1{
            self.view?.addSubview(label)
        }
        
        // Locate score Label
        scoreLabel.center.x = view.center.x
        scoreLabel.text = "Score"
        scoreLabelValue.center.x = scoreLabel.center.x
        scoreLabel.font = UIFont(name: "Helvetica", size: 15)
        scoreLabelValue.font = UIFont(name: "Helvetica", size: 50)
        scoreLabel.textAlignment = NSTextAlignment.Center
        scoreLabelValue.textAlignment = NSTextAlignment.Center
        self.view?.addSubview(scoreLabel)
        self.view?.addSubview(scoreLabelValue)
        
        playerNameLabel.center.x = view.center.x
        playerNameLabel.text = PlayerFirstName + " " + PlayerLastName
        playerNameLabel.font = UIFont(name: "Helvetica", size: 20)
        playerNameLabel.textAlignment = NSTextAlignment.Center
        self.view?.addSubview(playerNameLabel)
        
        self.view?.addSubview(timeLabel)
    }
    
    // Add arrow UIView
    func addArrow() {
        arrow.size = CGSizeMake(nodeWidthHight, nodeWidthHight)
        // 3
        arrow.position = nodePosition
        
        arrow.physicsBody = nil

        // Add the monster to the scene
        addChild(arrow)
    }
    
    // Player touched screen
    override func touchesBegan(touches: Set<NSObject>, withEvent event: UIEvent) {
        if timerRun == false{
            CurrentAngleTimer = NSTimer.scheduledTimerWithTimeInterval(0.1, target: self, selector: Selector("SetAngelAndTimeFromTimer"), userInfo: nil, repeats: true)
            timerRun = true
            startingTime = CACurrentMediaTime()
            medSwitch.hidden = true
            medLable.hidden = true
        }
        
        if GameIndex == -1{
            // Havn't got the game index yet
            return
        }
        
        if (IsInRightPosition(ArrowIndex) || playing == false){
            if playing == false{
                ArrowIndex = 3
                playing = true
                UpdateScoreLabel()
                NextMove()
                playing = true
                medSwitch.enabled = false
            }else{
                score++
                DBPlayerTap()
                UpdateScoreLabel()
                NextMove();
            }
        }else{
            DBPlayerTap()
            PaneltyScore()
            NextMove()
        }
    }
    
    // Set panelty parameters when the users tap was in the wrong position
    func PaneltyScore(){
        AudioServicesPlayAlertSound(SystemSoundID(kSystemSoundID_Vibrate))
        if score > 0{
           score--
        }
        
        UpdateScoreLabel(paintRed : true)
        
        if strikes.count < 5 && difficulty < 2{
            strikes.append(difficulty)
        }
        
        if strikes.count == 5{
            var count : Double = 0
            for item in strikes{
                count += item
            }
            
            
            // Once final difficulty is being set this will be the static difficulty
            finalDifficulty = Double(count/5)
            let maxDiff = 0.8
            if finalDifficulty < maxDiff {
                finalDifficulty = maxDiff
            }
        }
        
        if difficulty < 1.5{
            difficulty += 0.2
        }else if difficulty < 4{
            difficulty += 0.1
        }
        difJump = baseDifJump
       
    }
    
    // Set the parameters for next move
    func NextMove(){
        var dif = difficulty
        if finalDifficulty > 0{
            dif = finalDifficulty
            difficulty = finalDifficulty
        }
        clockWise = clockWise * -1
        
        
        if difJump == 0{
            // adjust difficulty
            if difficulty > 1{
                difficulty -= 0.2
            }else if difficulty > 0.2 {
                difficulty -= 0.05
            }
            difJump = baseDifJump
        }else{
            difJump--
        }
        
        arrow.removeAllActions()
        
        var nextArrowIndex = Int(arc4random_uniform(4))
        while nextArrowIndex == ArrowIndex{
            nextArrowIndex = Int(arc4random_uniform(4))
        }
        ArrowIndex = nextArrowIndex
        
        let actionMove = SKAction.rotateByAngle(CGFloat(Double(clockWise) * 2 * M_PI), duration: NSTimeInterval(dif))
        
        arrow.texture = SKTexture(imageNamed: GetArrowImagePictureFromNumber(ArrowIndex))
        
        let finishAction = SKAction.runBlock({
            let actionMove = SKAction.rotateByAngle(CGFloat(Double(self.clockWise) * 2 * M_PI * 10), duration: NSTimeInterval(self.difficulty * 10))
            self.arrow.runAction(SKAction.sequence([actionMove]))
            //self.PaneltyScore()
        })
        
        arrow.runAction(SKAction.sequence([actionMove,finishAction]))
    }
    
    // Get the absolute double value
    func absDoubleValue(input1: Double, input2: Double) -> Double{
        var subValue = Double(input1 - input2)
        if subValue < 0 {
            return Double(-1*subValue)
        }
        
        return Double(subValue)
    }
    
    // Update the score label for the player
    func UpdateScoreLabel(paintRed : Bool = false){
        if paintRed == true{
            scoreLabelValue.textColor = UIColor.redColor()
        }else{
            scoreLabelValue.textColor = UIColor.blackColor()
        }
        
        scoreLabelValue.text = score.description
        if score > highScore {
            highScore = score
        }
    }
    
    // Player pressed the screen on the wrong position
    func PlayerFailed(){
        DBGameOver()
        RestartGameState()
        UpdateScoreLabel()
    }
    
    // the player tap on the screen, do what you need
    func DBPlayerTap(){
        var parseObject = PFObject(className:"Taps")
        parseObject["gameIndex"] = GameIndex
        parseObject["score"] = score
        parseObject["difficulty"] = difficulty
        parseObject["playerName"] = UserName
        parseObject["valid"] = IsInRightPosition(ArrowIndex)
        parseObject["angel"] = GetRealAngel(Double(arrow.zRotation))
        parseObject["arrowColor"] = GetArrowImagePictureFromNumber(ArrowIndex)
        parseObject["tapColor"] = GetArrowImagePictureFromNumber(GetArrowIndexFromAngle(GetRealAngel(Double(arrow.zRotation))))
        parseObject["timeStamp"] = CACurrentMediaTime() - startingTime
        parseObject["onMed"] = medSwitch.on
        parseObject.saveInBackgroundWithBlock {
            (success: Bool, error: NSError?) -> Void in
            if (success) {
                // The object has been saved.
            } else {
                // There was a problem, check error.description
            }
        }
    }
    
    // Set game parameters in the db
    func DBGameOver(){
        DBPlayerTap()
        var parseObject = PFObject(className:"GameScore")
        parseObject["score"] = score
        parseObject["playerName"] = UserName
        parseObject.saveInBackgroundWithBlock {
            (success: Bool, error: NSError?) -> Void in
            if (success) {
                // The object has been saved.
            } else {
                // There was a problem, check error.description
            }
        }
    }
    
    // Restart the game state parameters
    func RestartGameState(){
        playing = false
        arrow.removeAllActions()
        arrow.texture = SKTexture(imageNamed: ArrowImagesCollection.Refresh.rawValue)
        arrow.zRotation = 0
        clockWise = 1
        difficulty = 4.0
        baseDifJump = 3
        difJump = 0
        ArrowIndex = 0
        score = 0
        timerValue = 0
    }
    
    // Set the angel and time from the timer on the label
    func SetAngelAndTimeFromTimer(){
        label.text = GetRealAngel(Double(arrow.zRotation)).description
        timerValue++
        timeLabel.text = Double(timerValue/10).description + " Seconds"
    }
    
    // Get the real angel from rad to deg
    func GetRealAngel(angle: Double) -> Double{
        var realZRotation = angle
        while realZRotation < 0 {
            realZRotation += 2 * M_PI
        }
        
        while realZRotation > 2 * M_PI{
            realZRotation -= 2 * M_PI
        }
        
        //println("Angel: \(realZRotation)")
        return realZRotation
    }
    
    // Check if the arrow in his color section
    func IsInRightPosition(ind: Int) -> Bool{
        return GetArrowIndexFromAngle(GetRealAngel(Double(arrow.zRotation))) == ind
    }
    
    // Get the arrow index from the current position of the arrow
    func GetArrowIndexFromAngle(angle : Double) -> Int{
        if angle > (1/8) * M_PI * 2 && angle < (3/8) * M_PI * 2 {
            return 0
        }
        
        if angle > (3/8) * M_PI * 2 && angle < (5/8) * M_PI * 2{
            return 1
        }
        
        if (angle > 0 && angle < (1/8) * M_PI * 2) || angle > (7/8) * M_PI * 2{
            return 2
        }
        
        return 3
    }
    
    // Transfer arrow number to asset
    func GetArrowImagePictureFromNumber(ind : Int) -> String{
        switch ind{
        case 0:
            return ArrowImagesCollection.Blue.rawValue
        case 1:
            return ArrowImagesCollection.Green.rawValue
        case 2:
            return ArrowImagesCollection.Red.rawValue
        default:
            return ArrowImagesCollection.Yellow.rawValue
        }
    }
    
    // Get the game index for the current player and set the new log number for the next index
    func GetGameIndexFromDBAndStartGame(){
        if GameIndex == -1 {
            var query = PFQuery(className:"GameScore")
            query.whereKey("playerName", equalTo:UserName)
            query.findObjectsInBackgroundWithBlock {
                (objects: [AnyObject]?, error: NSError?) -> Void in
                
                if error == nil {
                    // The find succeeded.
                    println("Successfully retrieved \(objects!.count) scores.")
                    // Do something with the found objects
                    self.GameIndex = objects!.count
                    // Show the start arrow
                    self.addArrow()
                } else {
                    // Log details of the failure
                    println("Error: \(error!) \(error!.userInfo!)")
                }
            }
        }else{
            GameIndex++
            self.NextMove()
        }
    }
    
    
    // Get the player high score for the current player
    func GetPlayerHighScore(){
        var query = PFQuery(className:"GameScore")
        query.whereKey("playerName", equalTo:UserName)
        query.orderByDescending("GameScore")
        query.findObjectsInBackgroundWithBlock {
            (objects: [AnyObject]?, error: NSError?) -> Void in
            
            if error == nil {
                // The find succeeded.
                println("Successfully retrieved \(objects!.count) scores.")
                // Do something with the found objects
                if objects!.count > 0{
                    var pfObjects = objects as! [PFObject]
                    self.highScore = pfObjects[0]["score"] as! Int
                }
                self.UpdateScoreLabel()
            } else {
                // Log details of the failure
                println("Error: \(error!) \(error!.userInfo!)")
            }
        }
    }
}


// Enum for the arrows
enum ArrowImagesCollection: String {
    case Blue = "arrow_blue"
    case Green = "arrow_green"
    case Red = "arrow_red"
    case Yellow = "arrow_yellow"
    case Refresh = "refresh"
}