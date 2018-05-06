//
//  SpeechToText.swift
//  GermanAutoLabsTest
//
//  Created by Arun Kumar Nama on 2/5/18.
//  Copyright © 2018 Arun Kumar Nama. All rights reserved.
//

import UIKit
import Speech
class SpeechToText: NSObject, SFSpeechRecognizerDelegate {
    
    private let speechRecognizer = SFSpeechRecognizer(locale: Locale.init(identifier: "en-US"))!
    
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?
    private let audioEngine = AVAudioEngine()
    private var uiDelegate : SpeechToTextProtocol?;
    private var detectionTimer : Timer?
    func initSpeech(uiDelegate: SpeechToTextProtocol?){
        speechRecognizer.delegate = self
        
        self.uiDelegate = uiDelegate!;
        SFSpeechRecognizer.requestAuthorization { (authStatus) in
            

            switch authStatus {
            case .authorized:
                print("User authorized access to speech recognition")
            case .denied:
                print("User denied access to speech recognition")
                
            case .restricted:
                print("Speech recognition restricted on this device")
                
            case .notDetermined:
                print("Speech recognition not yet authorized")
            }
            
            OperationQueue.main.addOperation() {
              //  self.microphoneButton.isEnabled = isButtonEnabled
            }
        }
    }
    
       func startRecording() {
        
        if recognitionTask != nil {  //1
            recognitionTask?.cancel()
            recognitionTask = nil
        }
        
        let audioSession = AVAudioSession.sharedInstance()  //2
        do {
            try audioSession.setCategory(AVAudioSessionCategoryRecord)
            try audioSession.setMode(AVAudioSessionModeMeasurement)
            try audioSession.setActive(true, with: .notifyOthersOnDeactivation)
        } catch {
            print("audioSession properties weren't set because of an error.")
        }
        
        recognitionRequest = SFSpeechAudioBufferRecognitionRequest()  //3
        let  inputNode = audioEngine.inputNode
//        guard let inputNode = audioEngine.inputNode else {
//            fatalError("Audio engine has no input node")
//        }  //4
        
        guard let recognitionRequest = recognitionRequest else {
            fatalError("Unable to create an SFSpeechAudioBufferRecognitionRequest object")
        } //5
        
        recognitionRequest.shouldReportPartialResults = true  //6
        
        recognitionTask = speechRecognizer.recognitionTask(with: recognitionRequest, resultHandler: { (result, error) in  //7
            
            var isFinal = false  //8
            
            if result != nil {
                print(result?.bestTranscription.formattedString);
               // self.textView.text = result?.bestTranscription.formattedString  //9
                isFinal = (result?.isFinal)!
                if (isFinal) {
                    self.uiDelegate?.textSpoken(text: (result?.bestTranscription.formattedString)!)
                }
            }
            
            
            if let timer = self.detectionTimer, timer.isValid {
                if isFinal {
                    self.detectionTimer?.invalidate()
                }
            } else {
                self.detectionTimer = Timer.scheduledTimer(withTimeInterval: 1.5, repeats: false, block: { (timer) in
                     self.uiDelegate?.textSpoken(text: (result?.bestTranscription.formattedString)!)
                    isFinal = true
                    timer.invalidate()
                })
            }
            
            
            if error != nil || isFinal {  //10
                self.audioEngine.stop()
                inputNode.removeTap(onBus: 0)
                
                self.recognitionRequest = nil
                self.recognitionTask = nil
                
               // self.microphoneButton.isEnabled = true
            }
        })
        
        let recordingFormat = inputNode.outputFormat(forBus: 0)  //11
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { (buffer, when) in
            self.recognitionRequest?.append(buffer)
        }
        
        audioEngine.prepare()  //12
        
        do {
            try audioEngine.start()
        } catch {
            print("audioEngine couldn't start because of an error.")
        }
        
      //  textView.text = "Say something, I'm listening!"
        
    }
    
    func speechRecognizer(_ speechRecognizer: SFSpeechRecognizer, availabilityDidChange available: Bool) {
        if available {
           // microphoneButton.isEnabled = true
        } else {
           // microphoneButton.isEnabled = false
        }
    }

}
