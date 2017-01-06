//
//  ViewController.swift
//  TouchBarDemo
//
//  Created by 朱德坤 on 2016/12/30.
//  Copyright © 2016年 朱德坤. All rights reserved.
//

import Cocoa
import AVFoundation

class ViewController: NSViewController {
    

    @IBOutlet weak var timeLabel: NSTextField!

    @IBOutlet weak var textCell: NSTextFieldCell!
    
    var audioPlayer: AVAudioPlayer?
    var lrcPraser: LrcParser!
    var date1: Date?
    
    var lrcString: String = ""
    
    var playSound: Bool = true {
        didSet {
            if playSound {
                audioPlayer?.play()
                date1 = Date()
            } else {
                audioPlayer?.pause()
            }
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        do {
            try audioPlayer = AVAudioPlayer(contentsOf: Bundle.main.url(forResource: "sound", withExtension: "mp3")!)
            try lrcString = String(contentsOf: Bundle.main.url(forResource: "sound", withExtension: "lrc")!, encoding: String.Encoding.utf8)
            lrcPraser = LrcParser(lrcString)
        } catch {
            print("error")
        }
        
        playSound = true

        printLrc()
        
    }
    func printLrc() {

        Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { timer in

            let line = self.lrcPraser.lineAt(timeSecond: Date().timeIntervalSince(self.date1!))
            // print(line.lrc)
            // print(Date().timeIntervalSince(self.date1!))
            self.textCell.title = line.lrc
            
            self.timeLabel.stringValue = String(format: "时间：%0.0lf 秒", Date().timeIntervalSince(self.date1!))
            if let delegate = NSApplication.shared().delegate as? AppDelegate{
                if delegate.musicBarController != nil{
                    delegate.musicBarController.textCell.stringValue = line.lrc
                }
            }
        }.fire()
        
    }
    override var representedObject: Any? {
        didSet {
            // Update the view, if already loaded.
        }
    }
    
}

