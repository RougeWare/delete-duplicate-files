//
//  OutputVolume.swift
//  DeleteDuplicateFiles
//
//  Created by S🌟System on 2022-07-24.
//

import Foundation

import ArgumentParser



enum OutputVolume: String, ExpressibleByArgument {
    
    /// The default output volume, which follows the UNIX philosophy of "don't say anything if there's nothing important to say".
    ///
    /// This causes the program to only output to stderr on errors, or to stdout with data the user requested
    case unix
    
    /// Causes the command to output as much information as possible, for debugging purposes
    case debug
    
    /// The program will output a log message when it might inform the user that someting useful happened, such as deleting a file or encountering an error
    case informative
}
