//
//  FileStreamError.swift
//  CombineFinder
//
//  Created by Leonardo Okazaki on 11/12/20.
//

import Foundation

enum FSError: Error {
    case failed
    case sanityCheck
    case unableToCreate
    case invalidPaths([URL])
    case tooManyDirectories
    case internalFailure
}
