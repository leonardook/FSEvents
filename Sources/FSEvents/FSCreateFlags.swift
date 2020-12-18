//
//  FSCreateFlags.swift
//  CombineFinder
//
//  Created by Leonardo Okazaki on 17/12/20.
//

import Foundation

public struct FSCreateFlags: OptionSet {
    public typealias RawValue = Int
    
    public let rawValue: Int
    
    public static let none = FSCreateFlags(rawValue: kFSEventStreamCreateFlagNone)
    public static let noDefer = FSCreateFlags(rawValue:kFSEventStreamCreateFlagNoDefer)
    public static let watchRoot = FSCreateFlags(rawValue: kFSEventStreamCreateFlagWatchRoot)
    public static let ignoreSelf = FSCreateFlags(rawValue:kFSEventStreamCreateFlagIgnoreSelf)
    public static let fileEvents = FSCreateFlags(rawValue: kFSEventStreamCreateFlagFileEvents)
    public static let markSelf = FSCreateFlags(rawValue: kFSEventStreamCreateFlagMarkSelf)
    public static let useExtendedData = FSCreateFlags(rawValue: kFSEventStreamCreateFlagUseExtendedData)
    public static let fullHistory = FSCreateFlags(rawValue: kFSEventStreamCreateFlagFullHistory)
    
    static let useCFFlags  = FSCreateFlags(rawValue: kFSEventStreamCreateFlagUseCFTypes)
    
    public init(rawValue: Int) {
        self.rawValue = rawValue
    }
}
