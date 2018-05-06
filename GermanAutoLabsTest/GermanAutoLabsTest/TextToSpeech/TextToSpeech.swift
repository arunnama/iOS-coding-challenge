//
//  TextToSpeech.swift
//  GermanAutoLabsTest
//
//  Created by Arun Kumar Nama on 2/5/18.
//  Copyright © 2018 Arun Kumar Nama. All rights reserved.
//

import UIKit
import AVFoundation

class TextToSpeech: NSObject {
    // Line 1. Create an instance of AVSpeechSynthesizer.
    var speechSynthesizer = AVSpeechSynthesizer()
    
    func speak(textToSpeak: String) {
        let speechUtterance: AVSpeechUtterance = AVSpeechUtterance(string: textToSpeak)
        //Line 3. Specify the speech utterance rate. 1 = speaking extremely the higher the values the slower speech patterns. The default rate, AVSpeechUtteranceDefaultSpeechRate is 0.5
        speechUtterance.rate = AVSpeechUtteranceMaximumSpeechRate / 4.0
        // Line 4. Specify the voice. It is explicitly set to English here, but it will use the device default if not specified.
        speechUtterance.voice = AVSpeechSynthesisVoice(language: "en-US")
        // Line 5. Pass in the urrerance to the synthesizer to actually speak.
        speechSynthesizer.speak(speechUtterance)
    }
    // Line 2. Create an instance of AVSpeechUtterance and pass in a String to be spoken.
    
}
