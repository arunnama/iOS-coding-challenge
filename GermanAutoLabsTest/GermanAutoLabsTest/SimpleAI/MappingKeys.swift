//
//  MappingKeys.swift
//  GermanAutoLabsTest
//
//  Created by Arun Kumar Nama on 2/5/18.
//  Copyright © 2018 Arun Kumar Nama. All rights reserved.
//



import Foundation

class MappingKeys: NSObject {
    
    var tokens : [String] = []
    
    func mapKeys(input: String) {
        //let input = "You shouldn't do that."
        
        
        let options: NSLinguisticTagger.Options = [.omitWhitespace, .omitPunctuation, .omitOther]
        
//        let options: NSLinguisticTagger.Options = .OmitWhitespace || .OmitPunctuation | .OmitOther
        let schemes = [NSLinguisticTagScheme.lexicalClass]
        let tagger = NSLinguisticTagger(tagSchemes: schemes, options: Int(options.rawValue))
        let range = NSMakeRange(0, (input as NSString).length)
        tagger.string = input
        tagger.enumerateTags(
            in: range,
            scheme: NSLinguisticTagScheme.lexicalClass,
            options: options) {
                (tag, tokenRange, _, _) in
        
                let token = (input as NSString).substring(with: tokenRange)
                tokens.append(token)
                print(tokens)
        
        }
    }
    
    func isKeywordsMatching(source:[String]) ->Bool {
        
        var mappValues = 0;
        for key in tokens {
            if ( source.contains(key) ) {
                mappValues += 1
            }
            
        }
        return percentageOfMapping(totalInputKeyCount: tokens.count, mappedKeys: mappValues, totalSourceKeyCount: source.count)
    }
        
    func percentageOfMapping(totalInputKeyCount:Int, mappedKeys:Int, totalSourceKeyCount:Int) ->Bool
    {
        if (mappedKeys > 0 && totalInputKeyCount == totalInputKeyCount) {
            return true
        }
        return false
    }
    

        
}
