//
//  UniversalAudioManager.swift
//
//  Created by Ernie Lail on 10/24/19.
//  Copyright © 2019 Development. All rights reserved.
//

import UIKit
import AVKit
import AVFoundation

class UniversalAudioManager: NSObject, AVAudioRecorderDelegate {
    
    //set up singleton
    static let shared = UniversalAudioManager()
    
    //audio player vars
    var audioPlayer: AVAudioPlayer?
    
    //recording vars
    var recordingSession: AVAudioSession!
    var audioRecorder: AVAudioRecorder!
    
    //vars to store temporary file info
    var filename = ""
    var highestDecible:Float?
    
    
    override init() {
        super.init()
        recordingSession = AVAudioSession.sharedInstance()
    }
    
    //update meters and record highest DB
    func levelCallback() {
        audioRecorder.updateMeters()
        highestDecible = audioRecorder.peakPower(forChannel: 0)
    }
    
    func playAudioFromDocuments(filename:String){
        do {
            try AVAudioSession.sharedInstance().overrideOutputAudioPort(.speaker)
            print("Playing Audio File")
            let audioFile = getDocumentsDirectory().appendingPathComponent(filename)
            do {
                audioPlayer = try AVAudioPlayer(contentsOf: audioFile)
                audioPlayer?.setVolume(1.0, fadeDuration: 0.5)
                audioPlayer?.play()
            }
            catch {
                print("Unable to load file!")
            }
        }
        catch{
            print("Unable to override output audio port!")
        }
    }
    
    func deleteAudio(filename:String){
        let path = getDocumentsDirectory().appendingPathComponent(filename)
        do{
            try FileManager.default.removeItem(at: path)
            print("Successully Deleted Audio File")
        }
        catch {
            print("Unable To Delete Audio FIle")
        }
    }
    
    func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }
    
    func requestRecordingPermissions(with completion:@escaping (Bool) -> ()) {
        do {
            try recordingSession.setCategory(.playAndRecord, mode: .default)
            try recordingSession.setActive(true)
            recordingSession.requestRecordPermission() { allowed in
                DispatchQueue.main.async {
                    completion(allowed)
                }
            }
        }
        catch {
            completion(false)
        }
    }
    
    func startRecording(recordingName:String) {
        let date = Date()
        filename = "\(recordingName) - \(date.description).m4a"
        let audioFilename = getDocumentsDirectory().appendingPathComponent(filename)
        do{
            try recordingSession.setCategory(.record)
        }
        catch{
            print("Unable to set recording session category!")
        }
        if let dataSources = recordingSession.inputDataSources{
            print("Available DataSources: \(dataSources.count)")
            do{
                try recordingSession.setInputDataSource(dataSources[2])
            }
            catch{
                print("Unable to set datasource")
            }
        }
        let settings = [
            AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
            AVSampleRateKey: 12000,
            AVNumberOfChannelsKey: 1,
            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
        ]
        do {
            audioRecorder = try AVAudioRecorder(url: audioFilename, settings: settings)
            audioRecorder.delegate = self
            audioRecorder.isMeteringEnabled = true
            audioRecorder.record()
            print("Recoding Audio")
        }
        catch {
            finishRecording()
        }
    }

    func finishRecording() {
        do{
            try recordingSession.setCategory(.playAndRecord)
        }
        catch{
            print("Unable to set recording session category!")
        }
        levelCallback()
        audioRecorder.stop()
        audioRecorder = nil
    }
    
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        if !flag {
            finishRecording()
        }
    }
    
    
}
