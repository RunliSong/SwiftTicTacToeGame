//
//  ViewController.swift
//  TicTacToeGame
//
//  Created by 宋润理 on 2017/3/22.
//  Copyright © 2017年 RunliSong. All rights reserved.
//

import UIKit
import AVFoundation
import MediaPlayer


enum ComputerLevel {
    case Easy, Normal, Hard, Genius
}


class ViewController: UIViewController {

    //outlets
    @IBOutlet weak var btn00: UIButton!
    @IBOutlet weak var btn10: UIButton!
    @IBOutlet weak var btn20: UIButton!
    @IBOutlet weak var btn01: UIButton!
    @IBOutlet weak var btn11: UIButton!
    @IBOutlet weak var btn21: UIButton!
    @IBOutlet weak var btn02: UIButton!
    @IBOutlet weak var btn12: UIButton!
    @IBOutlet weak var btn22: UIButton!
    @IBOutlet weak var xWinLabel: UILabel!
    @IBOutlet weak var drawLabel: UILabel!
    @IBOutlet weak var oWinLabel: UILabel!
    @IBOutlet weak var restartBtn: UIButton!
    @IBOutlet weak var musicBtn: UIButton!
    @IBOutlet weak var settingBtn: UIButton!
    @IBOutlet weak var playerXHeader: UIImageView!
    @IBOutlet weak var playerOHeader: UIImageView!
    @IBOutlet weak var computerLevelBtn: UIBarButtonItem!
    
    //global vars
    var stepCount = 0
    var clickEnable = true
    var XwinsCount = 0
    var OwinsCount = 0
    var drawCount = 0
    var btnArray: NSMutableArray = NSMutableArray.init();
    var audioPlayer: AVAudioPlayer?
    var isSinglePlayer = true
    var computerLevel = ComputerLevel.Hard
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //reset game on first launch
        resetGame()
        
        //prepare music player
        setupMusicPlayer()
     
        setupUI()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
//============================= Click actions ==============================
    
    @IBAction func switchOXAction(_ sender: UIButton) {
        //if button already has been clicked or game is over then do nothing
        if ((sender.title(for: UIControlState(rawValue: 0))) != "") || clickEnable == false { return}
        
        var anyoneWins = false

        if isSinglePlayer == false{
            //2 players mode
            //switch O and X every time clicks the button
            if stepCount%2 == 0 {
                sender.setTitle("X", for: .normal)
                sender.setTitleColor(UIColor.black, for: .normal)
            } else {
                sender.setTitle("O", for: .normal)
                sender.setTitleColor(UIColor.red, for: .normal)
            }
            stepCount = stepCount + 1
            
            //check if anyone wins on every step
            anyoneWins = chechWin()
            //if some one won ends the method
            if anyoneWins == true { return}
        } else {
            // single player mode
            if stepCount%2 == 0 {
                
                //player goes first
                sender.setTitle("X", for: .normal)
                sender.setTitleColor(UIColor.black, for: .normal)
                stepCount = stepCount + 1
                
                //remove the button that just clicked
                removeClickedBtn()
                
                //check if anyone wins on every step
                anyoneWins = chechWin()
                
                //if player won ends the method
                if anyoneWins == true {
                    return
                }
                
                //if the array still has any button then computer can click otherwise game must be draw
                if btnArray.count > 0 {
                    //computer‘s turn
                    computerMove(userMove: "X", computerMove: "O")
                    //check if anyone wins on every step
                    anyoneWins = chechWin()
                }
            }
        }

        //if the steps reached 9 and nobody wins, then game is darw
        if stepCount == 9 && anyoneWins == false {
            showWinner(winnerMsg: "Game is Draw...")
            drawCount = drawCount + 1
            drawLabel.text = "\(drawCount)"
        }
    }

    
    @IBAction func restartBtnAction(_ sender: UIButton) {
        //restarts the game
        resetGame()
    }
    
    @IBAction func musicPlayAcion(_ sender: UIButton) {
        //switch button‘s isSelected to play and pause the music
        if sender.isSelected == true {
            sender.isSelected = false
            audioPlayer?.pause()
        }else{
            sender.isSelected = true
            audioPlayer?.play()
        }
    }
    
    @IBAction func settingAction(_ sender: UIButton) {
        // create setting action sheet
        let settingAction = UIAlertController.init(title: "Setting", message: nil, preferredStyle: .actionSheet)
        let singlePlayerAction = UIAlertAction.init(title: "Single Player Mode", style: .default) { (UIAlertAction) in
            //single player
            self.isSinglePlayer = true
            
            //reset everything
            self.resetGame()
            self.XwinsCount = 0
            self.xWinLabel.text = "\(self.XwinsCount)"
            self.OwinsCount = 0
            self.oWinLabel.text = "\(self.OwinsCount)"
            self.playerXHeader.image = UIImage.init(named: "user.jpeg")
            self.playerOHeader.image = UIImage.init(named: "computer.jpeg")
        }
        let twoPlayersAction = UIAlertAction.init(title: "Two Players Mode", style: .default) { (UIAlertAction) in
            //2 players
            self.isSinglePlayer = false
            //reset everything
            self.resetGame()
            self.XwinsCount = 0
            self.xWinLabel.text = "\(self.XwinsCount)"
            self.OwinsCount = 0
            self.oWinLabel.text = "\(self.OwinsCount)"
            //change both header image to user
            self.playerXHeader.image = UIImage.init(named: "user.jpeg")
            self.playerOHeader.image = UIImage.init(named: "user.jpeg")
        }
        let cancelAction = UIAlertAction.init(title: "Cancel", style: .cancel, handler: nil)
        
        
        settingAction .addAction(singlePlayerAction)
        settingAction .addAction(twoPlayersAction)
        settingAction .addAction(cancelAction)
        
        self.present(settingAction, animated: true, completion: nil)
    }

    
    @IBAction func chooseComputerLevelAction(_ sender: UIBarButtonItem) {
        if isSinglePlayer == false { return }
        
        let computerLevelAction = UIAlertController.init(title: "Computer Player Level", message: nil, preferredStyle: .actionSheet)
        let easyAction = UIAlertAction.init(title: "Easy", style: .default) { (UIAlertAction) in
            self.computerLevel = .Easy;
            self.resetGame()
        }
        let normalAction = UIAlertAction.init(title: "Normal", style: .default) { (UIAlertAction) in
            self.computerLevel = .Normal;
            self.resetGame()
        }
        let hardAction = UIAlertAction.init(title: "Hard", style: .default) { (UIAlertAction) in
            self.computerLevel = .Hard;
            self.resetGame()
        }
        let geniusAction = UIAlertAction.init(title: "Genius", style: .default) { (UIAlertAction) in
            self.computerLevel = .Genius;
            self.resetGame()
        }
        let cancelAction = UIAlertAction.init(title: "Cancel", style: .cancel, handler: nil)

        computerLevelAction.addAction(easyAction)
        computerLevelAction.addAction(normalAction)
        computerLevelAction.addAction(hardAction)
        computerLevelAction.addAction(geniusAction)
        computerLevelAction.addAction(cancelAction)

        self.present(computerLevelAction, animated: true, completion: nil)
    }
    @IBAction func historyAction(_ sender: UIBarButtonItem) {
        
        
    }
    
//================================= Other Motheds ====================================
    
    /// config user interface setup
    func setupUI() {
        // mark button radius
        restartBtn.layer.cornerRadius = restartBtn.bounds.height/2
        restartBtn.layer.masksToBounds = true
        settingBtn.layer.cornerRadius = settingBtn.bounds.height/2
        settingBtn.layer.masksToBounds = true
        musicBtn.layer.cornerRadius = musicBtn.bounds.height/2
        musicBtn.layer.masksToBounds = true
        
    }
    
    /// reset game to start a new game.
    func resetGame() {
        // reset step count
        stepCount = 0
        // make all buttons enable to click
        clickEnable = true
        //change all button title to empty
        for subview in self.view.subviews {
            if subview.tag > 0 && subview.tag < 10 {
                let btn = subview as! UIButton
                btn.setTitle("", for: .normal)
                btnArray.add(btn)
            }
        }
    }
    
    /// computer makes a move by computer level
    func computerMove(userMove: String, computerMove: String) {
        switch computerLevel {
        case .Easy:
            //randomly select a button to move
            //take a random index from array
            let index = arc4random()%UInt32(btnArray.count)
            
            //find the button at the index and click it
            let nextBtn = btnArray.object(at: Int(index)) as! UIButton
            nextBtn.setTitle(computerMove, for: .normal)
            nextBtn.setTitleColor(UIColor.red, for: .normal)
            stepCount = stepCount + 1
            break
        case .Normal:
            //select a button that can win the game to move otherwise randomly
            if ((btn00.title(for: UIControlState(rawValue: 0))) == computerMove &&
                (btn01.title(for: UIControlState(rawValue: 0))) == computerMove &&
                (btn02.title(for: UIControlState(rawValue: 0))) == "") ||
                ((btn02.title(for: UIControlState(rawValue: 0))) == "" &&
                (btn12.title(for: UIControlState(rawValue: 0))) == computerMove &&
                (btn22.title(for: UIControlState(rawValue: 0))) == computerMove) ||
                ((btn02.title(for: UIControlState(rawValue: 0))) == "" &&
                (btn11.title(for: UIControlState(rawValue: 0))) == computerMove &&
                (btn20.title(for: UIControlState(rawValue: 0))) == computerMove)
            {
                btn02.setTitle(computerMove, for: .normal)
                btn02.setTitleColor(UIColor.red, for: .normal)
            }
            else if ((btn00.title(for: UIControlState(rawValue: 0))) == computerMove &&
                (btn01.title(for: UIControlState(rawValue: 0))) == "" &&
                (btn02.title(for: UIControlState(rawValue: 0))) == computerMove) ||
                ((btn01.title(for: UIControlState(rawValue: 0))) == "" &&
                (btn11.title(for: UIControlState(rawValue: 0))) == computerMove &&
                (btn21.title(for: UIControlState(rawValue: 0))) == computerMove)
            {
                btn01.setTitle(computerMove, for: .normal)
                btn01.setTitleColor(UIColor.red, for: .normal)
            }
            else if ((btn00.title(for: UIControlState(rawValue: 0))) == "" &&
                (btn01.title(for: UIControlState(rawValue: 0))) == computerMove &&
                (btn02.title(for: UIControlState(rawValue: 0))) == computerMove) ||
                ((btn00.title(for: UIControlState(rawValue: 0))) == "" &&
                (btn10.title(for: UIControlState(rawValue: 0))) == computerMove &&
                (btn20.title(for: UIControlState(rawValue: 0))) == computerMove) ||
                ((btn00.title(for: UIControlState(rawValue: 0))) == "" &&
                (btn11.title(for: UIControlState(rawValue: 0))) == computerMove &&
                (btn22.title(for: UIControlState(rawValue: 0))) == computerMove)
            {
                btn00.setTitle(computerMove, for: .normal)
                btn00.setTitleColor(UIColor.red, for: .normal)
            }
            else if ((btn10.title(for: UIControlState(rawValue: 0))) == computerMove &&
                (btn11.title(for: UIControlState(rawValue: 0))) == computerMove &&
                (btn12.title(for: UIControlState(rawValue: 0))) == "") ||
                ((btn02.title(for: UIControlState(rawValue: 0))) == computerMove &&
                (btn12.title(for: UIControlState(rawValue: 0))) == "" &&
                (btn22.title(for: UIControlState(rawValue: 0))) == computerMove)
            {
                btn12.setTitle(computerMove, for: .normal)
                btn12.setTitleColor(UIColor.red, for: .normal)
            }
            else if ((btn10.title(for: UIControlState(rawValue: 0))) == computerMove &&
                (btn11.title(for: UIControlState(rawValue: 0))) == "" &&
                (btn12.title(for: UIControlState(rawValue: 0))) == computerMove) ||
                ((btn01.title(for: UIControlState(rawValue: 0))) == computerMove &&
                (btn11.title(for: UIControlState(rawValue: 0))) == "" &&
                (btn21.title(for: UIControlState(rawValue: 0))) == computerMove) ||
                ((btn00.title(for: UIControlState(rawValue: 0))) == computerMove &&
                (btn11.title(for: UIControlState(rawValue: 0))) == "" &&
                (btn22.title(for: UIControlState(rawValue: 0))) == computerMove) ||
                ((btn02.title(for: UIControlState(rawValue: 0))) == computerMove &&
                (btn11.title(for: UIControlState(rawValue: 0))) == "" &&
                (btn20.title(for: UIControlState(rawValue: 0))) == computerMove)
            {
                btn11.setTitle(computerMove, for: .normal)
                btn11.setTitleColor(UIColor.red, for: .normal)
            }
            else if ((btn10.title(for: UIControlState(rawValue: 0))) == "" &&
                (btn11.title(for: UIControlState(rawValue: 0))) == computerMove &&
                (btn12.title(for: UIControlState(rawValue: 0))) == computerMove) ||
                ((btn00.title(for: UIControlState(rawValue: 0))) == computerMove &&
                (btn10.title(for: UIControlState(rawValue: 0))) == "" &&
                (btn20.title(for: UIControlState(rawValue: 0))) == computerMove)
            {
                btn10.setTitle(computerMove, for: .normal)
                btn10.setTitleColor(UIColor.red, for: .normal)
            }
            else if ((btn00.title(for: UIControlState(rawValue: 0))) == computerMove &&
                (btn10.title(for: UIControlState(rawValue: 0))) == computerMove &&
                (btn20.title(for: UIControlState(rawValue: 0))) == "") ||
                ((btn20.title(for: UIControlState(rawValue: 0))) == "" &&
                (btn21.title(for: UIControlState(rawValue: 0))) == computerMove &&
                (btn22.title(for: UIControlState(rawValue: 0))) == computerMove) ||
                ((btn02.title(for: UIControlState(rawValue: 0))) == computerMove &&
                (btn11.title(for: UIControlState(rawValue: 0))) == computerMove &&
                (btn20.title(for: UIControlState(rawValue: 0))) == "")
            {
                btn20.setTitle(computerMove, for: .normal)
                btn20.setTitleColor(UIColor.red, for: .normal)
            }
            else if ((btn20.title(for: UIControlState(rawValue: 0))) == computerMove &&
                (btn21.title(for: UIControlState(rawValue: 0))) == "" &&
                (btn22.title(for: UIControlState(rawValue: 0))) == computerMove) ||
                ((btn01.title(for: UIControlState(rawValue: 0))) == computerMove &&
                (btn11.title(for: UIControlState(rawValue: 0))) == computerMove &&
                (btn21.title(for: UIControlState(rawValue: 0))) == "")
            {
                btn21.setTitle(computerMove, for: .normal)
                btn21.setTitleColor(UIColor.red, for: .normal)
            }
            else if ((btn02.title(for: UIControlState(rawValue: 0))) == computerMove &&
                (btn12.title(for: UIControlState(rawValue: 0))) == computerMove &&
                (btn22.title(for: UIControlState(rawValue: 0))) == "") ||
                ((btn20.title(for: UIControlState(rawValue: 0))) == computerMove &&
                (btn21.title(for: UIControlState(rawValue: 0))) == computerMove &&
                (btn22.title(for: UIControlState(rawValue: 0))) == "") ||
                ((btn00.title(for: UIControlState(rawValue: 0))) == computerMove &&
                (btn11.title(for: UIControlState(rawValue: 0))) == computerMove &&
                (btn22.title(for: UIControlState(rawValue: 0))) == "")
            {
                btn22.setTitle(computerMove, for: .normal)
                btn22.setTitleColor(UIColor.red, for: .normal)
            }
            else
            {
                //take a random index from array
                let index = arc4random()%UInt32(btnArray.count)
                
                //find the button at the index and click it
                let nextBtn = btnArray.object(at: Int(index)) as! UIButton
                nextBtn.setTitle(computerMove, for: .normal)
                nextBtn.setTitleColor(UIColor.red, for: .normal)
            }
            stepCount = stepCount + 1
            break
        case .Hard:
            //stop user to win and select a button that can win the game to move otherwise randomly
            if ((btn11.title(for: UIControlState(rawValue: 0))) == userMove &&
                (btn02.title(for: UIControlState(rawValue: 0))) == "" &&
                (btn00.title(for: UIControlState(rawValue: 0))) == "" &&
                (btn20.title(for: UIControlState(rawValue: 0))) == "" &&
                (btn22.title(for: UIControlState(rawValue: 0))) == "")
            {
                let cornerBtns: NSArray = [btn02, btn00, btn20, btn22]
                let index = arc4random()%UInt32(cornerBtns.count)
                let nextBtn = cornerBtns.object(at: Int(index)) as! UIButton
                nextBtn.setTitle(computerMove, for: .normal)
                nextBtn.setTitleColor(UIColor.red, for: .normal)
            }
            else if ((btn11.title(for: UIControlState(rawValue: 0))) == "")
            {
                btn11.setTitle(computerMove, for: .normal)
                btn11.setTitleColor(UIColor.red, for: .normal)
            }
            else if ((btn00.title(for: UIControlState(rawValue: 0))) == computerMove &&
                (btn01.title(for: UIControlState(rawValue: 0))) == computerMove &&
                (btn02.title(for: UIControlState(rawValue: 0))) == "") ||
                ((btn02.title(for: UIControlState(rawValue: 0))) == "" &&
                (btn12.title(for: UIControlState(rawValue: 0))) == computerMove &&
                (btn22.title(for: UIControlState(rawValue: 0))) == computerMove) ||
                ((btn02.title(for: UIControlState(rawValue: 0))) == "" &&
                (btn11.title(for: UIControlState(rawValue: 0))) == computerMove &&
                (btn20.title(for: UIControlState(rawValue: 0))) == computerMove)
            {
                btn02.setTitle(computerMove, for: .normal)
                btn02.setTitleColor(UIColor.red, for: .normal)
            }
            else if ((btn00.title(for: UIControlState(rawValue: 0))) == computerMove &&
                (btn01.title(for: UIControlState(rawValue: 0))) == "" &&
                (btn02.title(for: UIControlState(rawValue: 0))) == computerMove) ||
                ((btn01.title(for: UIControlState(rawValue: 0))) == "" &&
                (btn11.title(for: UIControlState(rawValue: 0))) == computerMove &&
                (btn21.title(for: UIControlState(rawValue: 0))) == computerMove)
            {
                btn01.setTitle(computerMove, for: .normal)
                btn01.setTitleColor(UIColor.red, for: .normal)
            }
            else if ((btn00.title(for: UIControlState(rawValue: 0))) == "" &&
                (btn01.title(for: UIControlState(rawValue: 0))) == computerMove &&
                (btn02.title(for: UIControlState(rawValue: 0))) == computerMove) ||
                ((btn00.title(for: UIControlState(rawValue: 0))) == "" &&
                (btn10.title(for: UIControlState(rawValue: 0))) == computerMove &&
                (btn20.title(for: UIControlState(rawValue: 0))) == computerMove) ||
                ((btn00.title(for: UIControlState(rawValue: 0))) == "" &&
                (btn11.title(for: UIControlState(rawValue: 0))) == computerMove &&
                (btn22.title(for: UIControlState(rawValue: 0))) == computerMove)
            {
                btn00.setTitle(computerMove, for: .normal)
                btn00.setTitleColor(UIColor.red, for: .normal)
            }
            else if ((btn10.title(for: UIControlState(rawValue: 0))) == computerMove &&
                (btn11.title(for: UIControlState(rawValue: 0))) == computerMove &&
                (btn12.title(for: UIControlState(rawValue: 0))) == "") ||
                ((btn02.title(for: UIControlState(rawValue: 0))) == computerMove &&
                (btn12.title(for: UIControlState(rawValue: 0))) == "" &&
                (btn22.title(for: UIControlState(rawValue: 0))) == computerMove)
            {
                btn12.setTitle(computerMove, for: .normal)
                btn12.setTitleColor(UIColor.red, for: .normal)
            }
            else if ((btn10.title(for: UIControlState(rawValue: 0))) == computerMove &&
                (btn11.title(for: UIControlState(rawValue: 0))) == "" &&
                (btn12.title(for: UIControlState(rawValue: 0))) == computerMove) ||
                ((btn01.title(for: UIControlState(rawValue: 0))) == computerMove &&
                (btn11.title(for: UIControlState(rawValue: 0))) == "" &&
                (btn21.title(for: UIControlState(rawValue: 0))) == computerMove) ||
                ((btn00.title(for: UIControlState(rawValue: 0))) == computerMove &&
                (btn11.title(for: UIControlState(rawValue: 0))) == "" &&
                (btn22.title(for: UIControlState(rawValue: 0))) == computerMove) ||
                ((btn02.title(for: UIControlState(rawValue: 0))) == computerMove &&
                (btn11.title(for: UIControlState(rawValue: 0))) == "" &&
                (btn20.title(for: UIControlState(rawValue: 0))) == computerMove)
            {
                btn11.setTitle(computerMove, for: .normal)
                btn11.setTitleColor(UIColor.red, for: .normal)
            }
            else if ((btn10.title(for: UIControlState(rawValue: 0))) == "" &&
                (btn11.title(for: UIControlState(rawValue: 0))) == computerMove &&
                (btn12.title(for: UIControlState(rawValue: 0))) == computerMove) ||
                ((btn00.title(for: UIControlState(rawValue: 0))) == computerMove &&
                (btn10.title(for: UIControlState(rawValue: 0))) == "" &&
                (btn20.title(for: UIControlState(rawValue: 0))) == computerMove)
            {
                btn10.setTitle(computerMove, for: .normal)
                btn10.setTitleColor(UIColor.red, for: .normal)
            }
            else if ((btn00.title(for: UIControlState(rawValue: 0))) == computerMove &&
                (btn10.title(for: UIControlState(rawValue: 0))) == computerMove &&
                (btn20.title(for: UIControlState(rawValue: 0))) == "") ||
                ((btn20.title(for: UIControlState(rawValue: 0))) == "" &&
                (btn21.title(for: UIControlState(rawValue: 0))) == computerMove &&
                (btn22.title(for: UIControlState(rawValue: 0))) == computerMove) ||
                ((btn02.title(for: UIControlState(rawValue: 0))) == computerMove &&
                (btn11.title(for: UIControlState(rawValue: 0))) == computerMove &&
                (btn20.title(for: UIControlState(rawValue: 0))) == "")
            {
                btn20.setTitle(computerMove, for: .normal)
                btn20.setTitleColor(UIColor.red, for: .normal)
            }
            else if ((btn20.title(for: UIControlState(rawValue: 0))) == computerMove &&
                (btn21.title(for: UIControlState(rawValue: 0))) == "" &&
                (btn22.title(for: UIControlState(rawValue: 0))) == computerMove) ||
                ((btn01.title(for: UIControlState(rawValue: 0))) == computerMove &&
                (btn11.title(for: UIControlState(rawValue: 0))) == computerMove &&
                (btn21.title(for: UIControlState(rawValue: 0))) == "")
            {
                btn21.setTitle(computerMove, for: .normal)
                btn21.setTitleColor(UIColor.red, for: .normal)
            }
            else if ((btn02.title(for: UIControlState(rawValue: 0))) == computerMove &&
                (btn12.title(for: UIControlState(rawValue: 0))) == computerMove &&
                (btn22.title(for: UIControlState(rawValue: 0))) == "") ||
                ((btn20.title(for: UIControlState(rawValue: 0))) == computerMove &&
                (btn21.title(for: UIControlState(rawValue: 0))) == computerMove &&
                (btn22.title(for: UIControlState(rawValue: 0))) == "") ||
                ((btn00.title(for: UIControlState(rawValue: 0))) == computerMove &&
                (btn11.title(for: UIControlState(rawValue: 0))) == computerMove &&
                (btn22.title(for: UIControlState(rawValue: 0))) == "")
            {
                btn22.setTitle(computerMove, for: .normal)
                btn22.setTitleColor(UIColor.red, for: .normal)
            }
            else if ((btn00.title(for: UIControlState(rawValue: 0))) == userMove &&
                (btn01.title(for: UIControlState(rawValue: 0))) == userMove &&
                (btn02.title(for: UIControlState(rawValue: 0))) == "") ||
                ((btn02.title(for: UIControlState(rawValue: 0))) == "" &&
                (btn12.title(for: UIControlState(rawValue: 0))) == userMove &&
                (btn22.title(for: UIControlState(rawValue: 0))) == userMove) ||
                ((btn02.title(for: UIControlState(rawValue: 0))) == "" &&
                (btn11.title(for: UIControlState(rawValue: 0))) == userMove &&
                (btn20.title(for: UIControlState(rawValue: 0))) == userMove) ||
                ((btn00.title(for: UIControlState(rawValue: 0))) == computerMove &&
                (btn11.title(for: UIControlState(rawValue: 0))) == userMove &&
                (btn22.title(for: UIControlState(rawValue: 0))) == userMove &&
                (btn02.title(for: UIControlState(rawValue: 0))) == "") ||
                ((btn00.title(for: UIControlState(rawValue: 0))) == userMove &&
                (btn11.title(for: UIControlState(rawValue: 0))) == userMove &&
                (btn22.title(for: UIControlState(rawValue: 0))) == computerMove &&
                (btn02.title(for: UIControlState(rawValue: 0))) == "")
            {
                btn02.setTitle(computerMove, for: .normal)
                btn02.setTitleColor(UIColor.red, for: .normal)
            }
            else if ((btn00.title(for: UIControlState(rawValue: 0))) == userMove &&
                (btn01.title(for: UIControlState(rawValue: 0))) == "" &&
                (btn02.title(for: UIControlState(rawValue: 0))) == userMove) ||
                ((btn01.title(for: UIControlState(rawValue: 0))) == "" &&
                (btn11.title(for: UIControlState(rawValue: 0))) == userMove &&
                (btn21.title(for: UIControlState(rawValue: 0))) == userMove)
            {
                btn01.setTitle(computerMove, for: .normal)
                btn01.setTitleColor(UIColor.red, for: .normal)
            }
            else if ((btn00.title(for: UIControlState(rawValue: 0))) == "" &&
                (btn01.title(for: UIControlState(rawValue: 0))) == userMove &&
                (btn02.title(for: UIControlState(rawValue: 0))) == userMove) ||
                ((btn00.title(for: UIControlState(rawValue: 0))) == "" &&
                (btn10.title(for: UIControlState(rawValue: 0))) == userMove &&
                (btn20.title(for: UIControlState(rawValue: 0))) == userMove) ||
                ((btn00.title(for: UIControlState(rawValue: 0))) == "" &&
                (btn11.title(for: UIControlState(rawValue: 0))) == userMove &&
                (btn22.title(for: UIControlState(rawValue: 0))) == userMove) ||
                ((btn00.title(for: UIControlState(rawValue: 0))) == "" &&
                (btn11.title(for: UIControlState(rawValue: 0))) == userMove &&
                (btn20.title(for: UIControlState(rawValue: 0))) == userMove &&
                (btn02.title(for: UIControlState(rawValue: 0))) == computerMove) ||
                ((btn00.title(for: UIControlState(rawValue: 0))) == "" &&
                (btn11.title(for: UIControlState(rawValue: 0))) == userMove &&
                (btn20.title(for: UIControlState(rawValue: 0))) == computerMove &&
                (btn02.title(for: UIControlState(rawValue: 0))) == userMove)
            {
                btn00.setTitle(computerMove, for: .normal)
                btn00.setTitleColor(UIColor.red, for: .normal)
            }
            else if ((btn10.title(for: UIControlState(rawValue: 0))) == userMove &&
                (btn11.title(for: UIControlState(rawValue: 0))) == userMove &&
                (btn12.title(for: UIControlState(rawValue: 0))) == "") ||
                ((btn02.title(for: UIControlState(rawValue: 0))) == userMove &&
                (btn12.title(for: UIControlState(rawValue: 0))) == "" &&
                (btn22.title(for: UIControlState(rawValue: 0))) == userMove)
            {
                btn12.setTitle(computerMove, for: .normal)
                btn12.setTitleColor(UIColor.red, for: .normal)
            }
            else if ((btn10.title(for: UIControlState(rawValue: 0))) == userMove &&
                (btn11.title(for: UIControlState(rawValue: 0))) == "" &&
                (btn12.title(for: UIControlState(rawValue: 0))) == userMove) ||
                ((btn01.title(for: UIControlState(rawValue: 0))) == userMove &&
                (btn11.title(for: UIControlState(rawValue: 0))) == "" &&
                (btn21.title(for: UIControlState(rawValue: 0))) == userMove) ||
                ((btn00.title(for: UIControlState(rawValue: 0))) == userMove &&
                (btn11.title(for: UIControlState(rawValue: 0))) == "" &&
                (btn22.title(for: UIControlState(rawValue: 0))) == userMove) ||
                ((btn02.title(for: UIControlState(rawValue: 0))) == userMove &&
                (btn11.title(for: UIControlState(rawValue: 0))) == "" &&
                (btn20.title(for: UIControlState(rawValue: 0))) == userMove)
            {
                btn11.setTitle(computerMove, for: .normal)
                btn11.setTitleColor(UIColor.red, for: .normal)
            }
            else if ((btn10.title(for: UIControlState(rawValue: 0))) == "" &&
                (btn11.title(for: UIControlState(rawValue: 0))) == userMove &&
                (btn12.title(for: UIControlState(rawValue: 0))) == userMove) ||
                ((btn00.title(for: UIControlState(rawValue: 0))) == userMove &&
                (btn10.title(for: UIControlState(rawValue: 0))) == "" &&
                (btn20.title(for: UIControlState(rawValue: 0))) == userMove)
            {
                btn10.setTitle(computerMove, for: .normal)
                btn10.setTitleColor(UIColor.red, for: .normal)
            }
            else if ((btn00.title(for: UIControlState(rawValue: 0))) == userMove &&
                (btn10.title(for: UIControlState(rawValue: 0))) == userMove &&
                (btn20.title(for: UIControlState(rawValue: 0))) == "") ||
                ((btn20.title(for: UIControlState(rawValue: 0))) == "" &&
                (btn21.title(for: UIControlState(rawValue: 0))) == userMove &&
                (btn22.title(for: UIControlState(rawValue: 0))) == userMove) ||
                ((btn02.title(for: UIControlState(rawValue: 0))) == userMove &&
                (btn11.title(for: UIControlState(rawValue: 0))) == userMove &&
                (btn20.title(for: UIControlState(rawValue: 0))) == "")
            {
                btn20.setTitle(computerMove, for: .normal)
                btn20.setTitleColor(UIColor.red, for: .normal)
            }
            else if ((btn20.title(for: UIControlState(rawValue: 0))) == userMove &&
                (btn21.title(for: UIControlState(rawValue: 0))) == "" &&
                (btn22.title(for: UIControlState(rawValue: 0))) == userMove) ||
                ((btn01.title(for: UIControlState(rawValue: 0))) == userMove &&
                (btn11.title(for: UIControlState(rawValue: 0))) == userMove &&
                (btn21.title(for: UIControlState(rawValue: 0))) == "")
            {
                btn21.setTitle(computerMove, for: .normal)
                btn21.setTitleColor(UIColor.red, for: .normal)
            }
            else if ((btn02.title(for: UIControlState(rawValue: 0))) == userMove &&
                (btn12.title(for: UIControlState(rawValue: 0))) == userMove &&
                (btn22.title(for: UIControlState(rawValue: 0))) == "") ||
                ((btn20.title(for: UIControlState(rawValue: 0))) == userMove &&
                (btn21.title(for: UIControlState(rawValue: 0))) == userMove &&
                (btn22.title(for: UIControlState(rawValue: 0))) == "") ||
                ((btn00.title(for: UIControlState(rawValue: 0))) == userMove &&
                (btn11.title(for: UIControlState(rawValue: 0))) == userMove &&
                (btn22.title(for: UIControlState(rawValue: 0))) == "")
            {
                btn22.setTitle(computerMove, for: .normal)
                btn22.setTitleColor(UIColor.red, for: .normal)
            }
            else
            {
                //take a random index from array
                let index = arc4random()%UInt32(btnArray.count)
                
                //find the button at the index and click it
                let nextBtn = btnArray.object(at: Int(index)) as! UIButton
                nextBtn.setTitle(computerMove, for: .normal)
                nextBtn.setTitleColor(UIColor.red, for: .normal)
            }
            stepCount = stepCount + 1
            break
        case .Genius:
            //have all above movment and can make double two move
            break
        }
    }
    
    /// remove btns that has title to avoid AI click the same button again
    func removeClickedBtn() {
        for subview in self.view.subviews {
            if subview.tag > 0 && subview.tag < 10 {
                let btn = subview as! UIButton
                if ((btn.title(for: UIControlState(rawValue: 0))) != ""){
                    btnArray .remove(btn)
                }
            }
        }
    }
    
    /// check if any player wins the game
    func chechWin() -> Bool {
        // there are 8 conditions that player X could win
        if ((btn00.title(for: UIControlState(rawValue: 0))) == "X" &&
            (btn01.title(for: UIControlState(rawValue: 0))) == "X" &&
            (btn02.title(for: UIControlState(rawValue: 0))) == "X") ||
           ((btn10.title(for: UIControlState(rawValue: 0))) == "X" &&
            (btn11.title(for: UIControlState(rawValue: 0))) == "X" &&
            (btn12.title(for: UIControlState(rawValue: 0))) == "X") ||
           ((btn20.title(for: UIControlState(rawValue: 0))) == "X" &&
            (btn21.title(for: UIControlState(rawValue: 0))) == "X" &&
            (btn22.title(for: UIControlState(rawValue: 0))) == "X") ||
           ((btn00.title(for: UIControlState(rawValue: 0))) == "X" &&
            (btn10.title(for: UIControlState(rawValue: 0))) == "X" &&
            (btn20.title(for: UIControlState(rawValue: 0))) == "X") ||
           ((btn01.title(for: UIControlState(rawValue: 0))) == "X" &&
            (btn11.title(for: UIControlState(rawValue: 0))) == "X" &&
            (btn21.title(for: UIControlState(rawValue: 0))) == "X") ||
           ((btn02.title(for: UIControlState(rawValue: 0))) == "X" &&
            (btn12.title(for: UIControlState(rawValue: 0))) == "X" &&
            (btn22.title(for: UIControlState(rawValue: 0))) == "X")  ||
           ((btn00.title(for: UIControlState(rawValue: 0))) == "X" &&
            (btn11.title(for: UIControlState(rawValue: 0))) == "X" &&
            (btn22.title(for: UIControlState(rawValue: 0))) == "X") ||
           ((btn02.title(for: UIControlState(rawValue: 0))) == "X" &&
            (btn11.title(for: UIControlState(rawValue: 0))) == "X" &&
            (btn20.title(for: UIControlState(rawValue: 0))) == "X")
        {
            showWinner(winnerMsg: "Winner is X")
            XwinsCount = XwinsCount + 1
            xWinLabel.text = "\(XwinsCount)"
            return true
            // there are 8 conditions that player O could win
        } else if ((btn00.title(for: UIControlState(rawValue: 0))) == "O" &&
            (btn01.title(for: UIControlState(rawValue: 0))) == "O" &&
            (btn02.title(for: UIControlState(rawValue: 0))) == "O") ||
            ((btn10.title(for: UIControlState(rawValue: 0))) == "O" &&
            (btn11.title(for: UIControlState(rawValue: 0))) == "O" &&
            (btn12.title(for: UIControlState(rawValue: 0))) == "O") ||
            ((btn20.title(for: UIControlState(rawValue: 0))) == "O" &&
            (btn21.title(for: UIControlState(rawValue: 0))) == "O" &&
            (btn22.title(for: UIControlState(rawValue: 0))) == "O") ||
            ((btn00.title(for: UIControlState(rawValue: 0))) == "O" &&
            (btn10.title(for: UIControlState(rawValue: 0))) == "O" &&
            (btn20.title(for: UIControlState(rawValue: 0))) == "O") ||
            ((btn01.title(for: UIControlState(rawValue: 0))) == "O" &&
            (btn11.title(for: UIControlState(rawValue: 0))) == "O" &&
            (btn21.title(for: UIControlState(rawValue: 0))) == "O") ||
            ((btn02.title(for: UIControlState(rawValue: 0))) == "O" &&
            (btn12.title(for: UIControlState(rawValue: 0))) == "O" &&
            (btn22.title(for: UIControlState(rawValue: 0))) == "O")  ||
            ((btn00.title(for: UIControlState(rawValue: 0))) == "O" &&
            (btn11.title(for: UIControlState(rawValue: 0))) == "O" &&
            (btn22.title(for: UIControlState(rawValue: 0))) == "O") ||
            ((btn02.title(for: UIControlState(rawValue: 0))) == "O" &&
            (btn11.title(for: UIControlState(rawValue: 0))) == "O" &&
            (btn20.title(for: UIControlState(rawValue: 0))) == "O")
        {
             showWinner(winnerMsg: "Winner is O")
            OwinsCount = OwinsCount + 1
            oWinLabel.text = "\(OwinsCount)"
            return true
        } else{
            //if nobody won, return false
            return false
        }
    }
    
    /// use alert to show the winner
    ///
    /// - Parameter winner: winner
    func showWinner(winnerMsg: String) {
        let alert: UIAlertController = UIAlertController.init(title: "Game Over", message: winnerMsg, preferredStyle: .alert)
        let action = UIAlertAction.init(title: "OK", style: .cancel, handler: nil)
        alert .addAction(action)
        
        self.present(alert, animated: true, completion: nil)
        clickEnable = false
    }
    
    /// prepare music player to play music
    func setupMusicPlayer() {
        
        let path = Bundle.main.path(forResource: "BalladePourAdeline", ofType: "mp3")
        let pathURL = NSURL.init(fileURLWithPath: path!)
        
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: pathURL as URL)
        } catch {
            audioPlayer = nil
        }
        
        if audioPlayer != nil {
            audioPlayer?.prepareToPlay();
        }
    }
    
    func gamestartConfigAlert() {
        
    }
    
}

