//
//  FileStreamEventFactory.swift
//  CombineFinder
//
//  Created by Leonardo Okazaki on 11/12/20.
//

import Foundation

struct FSEventFactory {
    let eventCount: Int
    let eventPaths: UnsafeMutableRawPointer
    let eventFlags: UnsafePointer<FSEventStreamEventFlags>
    let eventIds: UnsafePointer<FSEventStreamEventId>
    
    func make() throws -> [FSEvent] {

        let paths = try makePathsArray()
        let flags = try makeArray(from: eventFlags)
        let ids = try makeArray(from: eventIds)
        
        return (0..<eventCount).compactMap {
            FSEvent(
                id: ids[$0],
                path: URL(fileURLWithPath: paths[$0]),
                flags: flags[$0]
            )
        }
    }
    
    func makePathsArray() throws -> [String] {
        let cfArray = Unmanaged<CFArray>
            .fromOpaque(eventPaths)
            .takeUnretainedValue()
        
        guard let array = cfArray as? [String] else {
            throw FSError.internalFailure
        }
        
        return array
    }
}

fileprivate extension FSEventFactory {
    func makeArray<Element: Any>(
        from pointer: UnsafePointer<Element>
    ) throws -> [Element] {
        let buffer = UnsafeBufferPointer(
            start: pointer,
            count: eventCount
        )
        
        let array = Array(buffer)
        
        guard array.count == eventCount else {
            throw FSError.sanityCheck
        }
        
        return Array(buffer)
    }
}
