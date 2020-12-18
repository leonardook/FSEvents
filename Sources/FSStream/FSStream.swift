//
//  FileStream.swift
//  CombineFinder
//
//  Created by Leonardo Okazaki on 11/12/20.
//

import Foundation
import CoreServices

public class FSStream {
    //MARK: Public definitions
    public typealias Closure = (Result<[FSEvent], Error>) -> Void
    
    //MARK: Private properties
    fileprivate var ref: FSEventStreamRef
    fileprivate let handler: Handler
    fileprivate var thread: Thread?
    
    //MARK: Public methods
    /**
    The File System Event Stream 
     
     - Parameter directories: Array of paths, each specifying a path to a directory, signifying the root of a filesystem hierarchy to be watched for modifications.
     
     - Parameter latency: The number of seconds the service should wait after hearing about an event from the kernel before passing it along to the client via its callback. Specifying a larger value may result in more effective temporal coalescing, resulting in fewer callbacks and greater overall efficiency.
     
     - Parameter since: The service will supply events that have happened after the given event ID.
     
        Default is `.now`.
     
        See `FileStreamEvent.Identifier`
     
     - Parameter closure: A closure to be called whenever an event occur.
     */
    public init(
        directories: [String],
        latency: TimeInterval,
        since: FSEvent.Identifier = .now,
        flags: FSCreateFlags,
        closure: @escaping Closure
    ) throws {
        
        handler = Handler(closure: closure)
        var completeFlags = flags
        completeFlags.insert(.useCFFlags)
        ref = try FSFactory(
            directories: directories,
            latency: latency,
            handler: handler,
            since: since,
            flags: completeFlags
        ).make()
    }
    
    public func start(
        on runLoop: RunLoop,
        mode: RunLoop.Mode
    ) throws {
        
        let cfRunLoop = runLoop.getCFRunLoop()
        let cfMode = mode as CFString
        FSEventStreamScheduleWithRunLoop(ref, cfRunLoop, cfMode)
        
        let success = FSEventStreamStart(ref)
        
        if !success {
            throw FSError.failed
        }
    }
    
    /**
     Sets directories to be filtered from the EventStream.
     
     A maximum of 8 directories maybe specified.
     
     - Parameter directories: Array of paths, each specifying a path to a directory, signifying the root of a filesystem hierarchy to be watched for modifications.
     */
    public func exclude(directories: [URL]) throws {
        guard directories.count > 8 else {
            throw FSError.tooManyDirectories
        }
        
        let paths = directories.compactMap { $0.path as CFString } as CFArray
        
        let success = FSEventStreamSetExclusionPaths(ref, paths)
        
        if !success {
            throw FSError.failed
        }
    }
}

extension FSStream {
    //Is there a better way to do this?
    //If a pointer to the closure is created instead of a object holding the closure
    //will the pointer always work? Or the reference will be lost and will risk a crash?
    class Handler {
        let closure: Closure
        init(closure: @escaping Closure) {
            self.closure = closure
        }
    }
}
