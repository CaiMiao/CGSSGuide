//
//  EventPtRanking.swift
//  DereGuide
//
//  Created by zzk on 2017/1/24.
//  Copyright © 2017年 zzk. All rights reserved.
//

import UIKit
import SwiftyJSON

extension EventPtRanking {
    var lastDate: Date? {
        if let date = list.last?.date.toDate(format: "yyyy-MM-dd HH:mm") {
            return date
        } else {
            return nil
        }
    }
    var last: EventPtItem? {
        return list.last
    }
    
    var speed: EventPtRankingSpeed {
        var subList = [EventPtItem]()
        var count = 0
        for i in 0..<list.count {
            let ranking = list[list.count - i - 1]
            count += 1
            subList.append(ranking)
            if count >= 2 {
                break
            }
        }
        
        var rank1Speed = 0
        var rank2Speed = 0
        var rank3Speed = 0
        var reward1Speed = 0
        var reward2Speed = 0
        var reward3Speed = 0
        var reward4Speed = 0
        var reward5Speed = 0

        if let first = subList.first, let last = subList.last {
            let timeInterval = last.date.toDate(format: "yyyy-MM-dd HH:mm").timeIntervalSince(first.date.toDate(format: "yyyy-MM-dd HH:mm"))
            let hourInterval = timeInterval / 3600
            if hourInterval != 0 {
                rank1Speed = Int(round(Double(last.rank1 - first.rank1) / hourInterval))
                rank2Speed = Int(round(Double(last.rank2 - first.rank2) / hourInterval))
                rank3Speed = Int(round(Double(last.rank3 - first.rank3) / hourInterval))
                reward1Speed = Int(round(Double(last.reward1 - first.reward1) / hourInterval))
                reward2Speed = Int(round(Double(last.reward2 - first.reward2) / hourInterval))
                reward3Speed = Int(round(Double(last.reward3 - first.reward3) / hourInterval))
                reward4Speed = Int(round(Double(last.reward4 - first.reward4) / hourInterval))
                reward5Speed = Int(round(Double(last.reward5 - first.reward5) / hourInterval))
            }
        }
    
        return EventPtRankingSpeed(rank1: rank1Speed, rank2: rank2Speed, rank3: rank3Speed, reward1: reward1Speed, reward2: reward2Speed, reward3: reward3Speed, reward4: reward4Speed, reward5: reward5Speed)
    }
}

class EventPtRanking {
    
    var list: [EventPtItem]
    
    // not from json
    var event: CGSSEvent!
    /**
     * Instantiate the instance using the passed json values to set the properties values
     */
    init(fromJson json: JSON!){
        list = [EventPtItem]()
        for sub in json.arrayValue {
            if sub.isEmpty {
                continue
            }
            
            list.append(EventPtItem.init(fromJson: sub))
        }
    }
    
    /**
     * Returns all the available property values in the form of NSDictionary object where the key is the approperiate json key and the value is the value of the corresponding property
     */
    func toDictionary() -> NSDictionary
    {
        let dictionary = NSMutableDictionary()
        dictionary["list"] = list
        return dictionary
    }
    
    /**
     * NSCoding required initializer.
     * Fills the data from the passed decoder
     */
    required init(coder aDecoder: NSCoder)
    {
        list = aDecoder.decodeObject(forKey: "list") as? [EventPtItem] ?? [EventPtItem]()
    }
    
    /**
     * NSCoding required method.
     * Encodes mode properties into the decoder
     */
    func encode(with aCoder: NSCoder)
    {
        aCoder.encode(list, forKey: "list")
    }
    
}