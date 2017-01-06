//
//  AppDelegate.swift
//  TouchBarDemo
//
//  Created by 朱德坤 on 2016/12/30.
//  Copyright © 2016年 朱德坤. All rights reserved.
//

import Cocoa
import SpriteKit
@available(OSX 10.12.2, *)
extension NSTouchBarItemIdentifier {
    static let musicBarController = NSTouchBarItemIdentifier("br.com.music")
}

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate, NSTouchBarDelegate, NSTouchBarProvider {

    var musicBarController: MusicBarController!

    @available(OSX 10.12.2, *)
    var touchBar: NSTouchBar? {
        let bar = NSTouchBar()

        bar.delegate = self
        bar.defaultItemIdentifiers = [.musicBarController]
        return bar
    }

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Insert code here to initialize your application
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }

    @available(OSX 10.12.2, *)
    func touchBar(_ touchBar: NSTouchBar, makeItemForIdentifier identifier: NSTouchBarItemIdentifier) -> NSTouchBarItem? {
        switch identifier {
        case NSTouchBarItemIdentifier.musicBarController:
            let item = NSCustomTouchBarItem(identifier: .musicBarController)

            if musicBarController == nil {
                musicBarController = MusicBarController()
            }

            item.viewController = musicBarController

            return item
        default: return nil
        }
    }

}
class MusicBarController: NSViewController {
    var textCell: NSTextField!
    override func loadView() {
        view = NSView()
        textCell = NSTextField(string: "--lrc歌词--")
        textCell.frame = NSRect(x: 60, y: 0, width: 500, height: 30)
        textCell.textColor = NSColor.red
        view.addSubview(textCell)

    }
    override func viewDidLayout() {
        super.viewDidLayout()

        textCell.frame = view.bounds

    }
}
