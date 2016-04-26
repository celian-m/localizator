//
//  Localizator.swift
//  Netro
//
//  Created by Célian MOUTAFIS on 25/04/2016.
//  Copyright © 2016 mstv. All rights reserved.
//

import UIKit

/**
 Localizator let you use NSLocalizedString from a distant file. It is a convenient way to fix misspelling without resubmitting apps
 */

class Localizator: NSObject {

    /**
        The name on the strings file on your server
    */
    static let localizedFileName = "Localizable"
    
    /** 
         This is your server URL
         If the URL is http://my.server.com, you must be authorized to access to
         http://my.server.com/{locale}.lproj/Localizable.strings, for each required locale
     */
    static let serverURL = "https://mouce.fr/"
    
    /** 
        The locales supported by your application. The Localizator will
        try to fetch each {locale}.lproj folder on the server
     */
    static let supportedLocales = ["en"]
    
    /** 
        Random value to know when a key as no know value in the downloaded strings files
     */
    private static let unknowKey = "l0lizat0rr0cksL1keACh4rm";
    
    
    /** 
        Returns a localized string based on NSLocalizaedString logic. It first looks into the downloaded folder, and next in defaut strings files.
        if the key is not in localized files and not in embedded strings files, the key is returned
     */
    static func localizedString(key : String, locale : String = "en") -> String {
        let dir = NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.DocumentDirectory, NSSearchPathDomainMask.AllDomainsMask, true).first
        let path = NSURL(fileURLWithPath: dir!).URLByAppendingPathComponent("localizator-\(locale).lproj")
        let bundle = NSBundle(URL:path)
        let s = NSLocalizedString(key, tableName: nil, bundle: bundle!, value: unknowKey, comment: "")
        
        if s.characters.count > 0 && s != unknowKey{
            return s
        }
        return NSLocalizedString(key,  comment: "")
    }
    
    
    /**
         This method will fetch the server for each local in supportedLocale attribute.
         It returns in the main thread when all locales are concurrentialy fetched
     */
    static func synchronize(completion : ((success : Bool) -> Void )? = nil ){
        let group = dispatch_group_create() //create group for concurency calls
        var success = true //remember if everything was ok
        for locale in supportedLocales {
            dispatch_group_enter(group)
            let url = NSURL(string: "\(serverURL)\(locale).lproj/\(localizedFileName).strings")!
            let request = NSMutableURLRequest(URL: url)
            let task = NSURLSession.sharedSession().dataTaskWithRequest(request) { (data, response, error) in
                if data != nil {
                    let dir = NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.DocumentDirectory, NSSearchPathDomainMask.AllDomainsMask, true).first
                    let path = NSURL(fileURLWithPath: dir!).URLByAppendingPathComponent("localizator-\(locale).lproj").URLByAppendingPathComponent("Localizable.strings")
                        data!.writeToURL(path, atomically: true)
                }else{
                    success = false //something get wrong
                }
                dispatch_group_leave(group)
            }
            task.resume();
        }
        
        if (completion != nil) {
            dispatch_group_notify(group, dispatch_get_main_queue()) {
                completion!(success:success)
            }
        }
        
    }
    
}
