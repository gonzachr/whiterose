//
//  StatusMenu.swift
//  MenuBarTimer
//
//  Created by Gonzalo Rodríguez on 3/14/20.
//  Copyright © 2020 Gonzalo Rodríguez. All rights reserved.
//

import Cocoa
import CSV

class MenuViewController: NSMenu {
    @IBOutlet weak var timerItem: NSMenuItem!
    @IBOutlet weak var startItem: NSMenuItem!
    @IBOutlet weak var pauseItem: NSMenuItem!
    @IBOutlet weak var stopItem: NSMenuItem!
    
    let timer = MenuTimer()
    let preferences = Preferences()


    @IBAction func onWriteCSV(_ sender: Any) {
        let fileUrl: URL = URL(fileURLWithPath: preferences.currentPath).appendingPathComponent("log.csv")
        
        if !FileManager.default.fileExists(atPath: fileUrl.path) {
            FileManager.default.createFile(atPath: fileUrl.path, contents: nil, attributes: nil)
        }

        if let stream = OutputStream(toFileAtPath: fileUrl.path, append: true) {
            do {
                let csv = try CSVWriter(stream: stream)

                try csv.write(row: ["id", "name"])
                try csv.write(row: ["1","foo"])
                csv.stream.close()
            } catch CSVError.cannotOpenFile{
               print("Cannot open file")
            } catch CSVError.cannotWriteStream {
                print("Cannot write stream")
            } catch {
                print("Yo")
            }
        }
    }
    
    @IBAction func onStartItem(_ sender: Any) {
        if (timer.delegate == nil) {
            timer.delegate = self
        }
        
        timer.startTimer()
        RunLoop.current.add(timer.timer!, forMode: RunLoop.Mode.common)
    }
    
    @IBAction func onPauseItem(_ sender: Any) {
        if !timer.isPaused {
            timer.pauseTimer()
        } else {
            timer.resumeTimer()
            RunLoop.current.add(timer.timer!, forMode: RunLoop.Mode.common)
        }
    }
    
    @IBAction func onStopItem(_ sender: Any) {
        timer.stopTimer()
    }
    
    private func textToDisplay(for elapsedTime: TimeInterval) -> String {
        let elapsedHours = floor(elapsedTime / 3600)
        let elapsedMinutes = floor((elapsedTime - (elapsedHours * 3600)) / 60)
        let elapsedSeconds = elapsedTime - (elapsedHours * 3600 + elapsedMinutes * 60)
        
        let hoursDisplay = String(format: "%02d", Int(elapsedHours))
        let minutesDisplay = String(format: "%02d", Int(elapsedMinutes))
        let secondsDisplay = String(format: "%02d", Int(elapsedSeconds))
        
        return "\(hoursDisplay):\(minutesDisplay):\(secondsDisplay)"
    }
    
    @IBAction func onQuitTimer(_ sender: Any) {
        NSApp.terminate(sender)
    }
    
    func updateButtons() {
        if timer.isStopped {
            startItem.isHidden = false
            pauseItem.isHidden = true
            stopItem.isHidden = true
        } else if timer.isPaused {
            startItem.isHidden = true
            pauseItem.title = "Resume"
            pauseItem.isHidden = false
            stopItem.isHidden = false
        } else if timer.isRunning {
            startItem.isHidden = true
            pauseItem.title = "Pause"
            pauseItem.isHidden = false
            stopItem.isHidden = false
        }
    }
}

extension MenuViewController: MenuTimerProtocol {
    func elapsedTimeOnTimer(_ timer: MenuTimer, elapsedTime: TimeInterval) {
        updateDisplay(for: elapsedTime)
        updateButtons()
        print(elapsedTime)
    }
}

extension MenuViewController {
    func updateDisplay(for elapsedTime: TimeInterval) {
        timerItem.title = textToDisplay(for: elapsedTime)
    }
}