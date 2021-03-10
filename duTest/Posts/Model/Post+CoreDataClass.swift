//
//  Post+CoreDataClass.swift
//  
//
//  Created by Prateek Kansara on 10/03/21.
//
//

import Foundation
import CoreData

@objc(Post)
public class Post: NSManagedObject, Codable {

    enum CodingKeys : String, CodingKey {
        case userId
        case id
        case title
        case body
    }
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        // To encode during update
    }
    
    required convenience public init(from decoder: Decoder) throws {
        
        guard let context = DatabaseManager.shared.persistentContainer.viewContext as? NSManagedObjectContext else {
              throw DecoderConfigurationError.missingManagedObjectContext
            }
        
        self.init(context: context)
        
        let container = try decoder.container(keyedBy: CodingKeys.self)
        userId = try container.decodeIfPresent(Int32.self, forKey: .userId) ?? 0
        id = try container.decodeIfPresent(Int32.self, forKey: .id) ?? 0
        title = try container.decodeIfPresent(String.self, forKey: .title)
        body = try container.decodeIfPresent(String.self, forKey: .body)
    }
}
