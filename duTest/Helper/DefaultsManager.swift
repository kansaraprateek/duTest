//
//  DefaultsManager.swift
//  duTest
//
//  Created by Prateek Kansara on 15/03/21.
//

import Foundation

/// Can be used for multiple default types
class DefaultsManager {
    
    static func get(for key : String) -> Bool{
        if let valueForKey = UserDefaults.standard.value(forKey: key) as? Bool {
            return valueForKey
        }
        return false
    }
    
    static func get(for key : String) -> String?{
        if let valueForKey = UserDefaults.standard.value(forKey: key) as? String {
            return valueForKey
        }
        return nil
    }
    
    static func set(for key : String, value : Any){
        UserDefaults.standard.setValue(value, forKey: key)
        UserDefaults.standard.synchronize()
    }
    
    static func remove(for key : String){
        UserDefaults.standard.removeObject(forKey: key)
        UserDefaults.standard.synchronize()
    }
}
