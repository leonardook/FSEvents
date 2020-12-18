//
//  FileStreamFactory.swift
//  CombineFinder
//
//  Created by Leonardo Okazaki on 17/12/20.
//

import Foundation

struct FSFactory {
    let directories: [String]
    let latency: TimeInterval
    let handler: FSStream.Handler
    let since: FSEvent.Identifier
    let flags: FSCreateFlags
    
    func make() throws -> FSEventStreamRef {
        let callback = makeCallback()
        var context = makeContext()
        let paths = directories as CFArray
        let sinceWhen = since as FSEventStreamEventId
        let latency = self.latency as CFTimeInterval
        let createFlags = FSEventStreamCreateFlags(flags.rawValue)
        
        guard let streamRef = FSEventStreamCreate(
            nil,
            callback,
            &context,
            paths,
            sinceWhen,
            latency,
            createFlags
        ) else {
            throw FSError.unableToCreate
        }
        
        return streamRef
    }
    
    private func makeContext() -> FSEventStreamContext {
        let pointer = Unmanaged.passUnretained(handler).toOpaque()
        return FSEventStreamContext(
            version: 0,
            info: pointer,
            retain: nil,
            release: nil,
            copyDescription: nil
        )
    }
    
    private func makeCallback() -> FSEventStreamCallback {
        return { (
            _ streamRef: ConstFSEventStreamRef,
            _ clientCallBackInfo: UnsafeMutableRawPointer?,
            _ numEvents: Int,
            _ eventPaths: UnsafeMutableRawPointer,
            _ eventFlags: UnsafePointer<FSEventStreamEventFlags>,
            _ eventIds: UnsafePointer<FSEventStreamEventId>
        ) -> () in
            
            let eventFactory = FSEventFactory(
                eventCount: numEvents,
                eventPaths: eventPaths,
                eventFlags: eventFlags,
                eventIds: eventIds
            )
            
            
            guard let info = clientCallBackInfo else {
                return
            }
            
            let handler = Unmanaged<FSStream.Handler>
                .fromOpaque(info)
                .takeUnretainedValue()
            
            let result = Result<[FSEvent],Error>{
                return try eventFactory.make()
            }
            
            handler.closure(result)
        }
    }
}
