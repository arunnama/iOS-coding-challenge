//
//  ViewController.swift
//  GermanAutoLabsTest
//
//  Created by Arun Kumar Nama on 2/5/18.
//  Copyright © 2018 Arun Kumar Nama. All rights reserved.
//

import UIKit
import CoreSpotlight
import MobileCoreServices

protocol SpeechToTextProtocol {
    func textSpoken(text:String);
}
class ViewController: UIViewController,SpeechToTextProtocol {
    
    var myText:String = "";
    var temperature = ""
    var city = ""
    var viewModel:WeatherViewModel?
    var textSpoken = ""
    var textToSpeak = ""
    
    
    var timer:Timer?
    var change:CGFloat = 0.01
    
    @IBOutlet weak var audioView: SwiftSiriWaveformView!
    
    @objc internal func refreshAudioView(_:Timer) {
        if self.audioView.amplitude <= self.audioView.idleAmplitude || self.audioView.amplitude > 1.0 {
            self.change *= -1.0
        }
        
        // Simply set the amplitude to watever you need and the view will update itself.
        self.audioView.amplitude += self.change
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        viewModel = WeatherViewModel()
        viewModel?.delegate = self
    }
    
    @IBAction func StartSpeaking(_ sender: UIButton) {
        // speechToText()
        speechToText();

    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func speechToText()
    {
        let st = SpeechToText();
        st.initSpeech(uiDelegate: self)
        st.startRecording();
        self.audioView.density = 1.0
        timer = Timer.scheduledTimer(timeInterval: 0.009, target: self, selector: #selector(ViewController.refreshAudioView(_:)), userInfo: nil, repeats: true)
        mapKeywords()

    }
    
    func textSpoken(text:String){
        textSpoken = text;
        timer?.invalidate();
        self.audioView.amplitude = 0;
        self.mapKeywords()
    }
    
    
    func testTextToSpeech()
    {
        let textToSpeechApi = TextToSpeech()
        textToSpeechApi.speak(textToSpeak: myText)
        
    }
    
    func mapKeywords()
    {
        let myKeys = MappingKeys()
        myKeys.mapKeys(input: "How is weather today");
        if (myKeys.isKeywordsMatching(source: MappingData.WEATHER_KEY_WORDS))
        {
            viewModel?.startLocationService();
        }
        else{
            let textToSpeechApi = TextToSpeech()
            textToSpeechApi.speak(textToSpeak: "My skill is limited to weather report. Please ask about weather");
        }
    }
}

extension ViewController:WeatherViewModelProtocol{
    
    internal func update(_ weather: Weather) {
        myText = "Final Weather in \(weather.location) is about \(weather.temperature) degrees"
        print(myText);
        myText = "Weather report, you current location temperature is \(weather.temperature) degree"
        print(myText);
        testTextToSpeech()
        
    }
}
