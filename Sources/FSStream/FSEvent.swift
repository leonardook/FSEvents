//
//  FileStreamEvent.swift
//  CombineFinder
//
//  Created by Leonardo Okazaki on 11/12/20.
//

import Foundation

/**
 The File System Event Stream
 */
public struct FSEvent: Identifiable {
    public typealias Identifier = FSEventStreamEventId
    
    public let id: Identifier
    public let path: URL
    public let flags: UInt32
}

extension FSEvent.Identifier {
    public static let now: FSEvent.Identifier = FSEvent.Identifier(kFSEventStreamEventIdSinceNow)
}
