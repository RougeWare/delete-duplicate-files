//
//  Logging.swift
//  DeleteDuplicateFiles
//
//  Created by S🌟System on 2022-07-24.
//

import Foundation
import SimpleLogging



private extension LogChannel {
    /// Allows all log messages to `stdout`. Good for debugging!
    static let debug = try! LogChannel(name: OutputVolume.debug.rawValue,
                                       location: .standardOut,
                                       severityFilter: .allowAll)
    
    /// Allows only messages fit for `stderr`, and sends them to `stderr`
    static let error = try! LogChannel(name: "Error",
                                       location: .standardError,
                                       lowestAllowedSeverity: .warning)
    
    /// Allows informative log messages to `stdout`. Good for people who are curious if it's working correctly, but who don't want full debugging-level output
    static let informative = try! LogChannel(name: OutputVolume.informative.rawValue,
                                             location: .standardOut,
                                             lowestAllowedSeverity: .info)
}



extension OutputVolume {
    
    /// The log channels that fulfil this output volume's promises
    var logChannels: [LogChannel] {
        switch self {
        case .unix:
            return [.error]
            
        case .debug:
            return [.debug, .error]
            
        case .informative:
            return [.informative, .error]
        }
    }
}
