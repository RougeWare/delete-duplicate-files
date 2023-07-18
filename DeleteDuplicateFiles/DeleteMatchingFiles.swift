//
//  DeleteMatchingFiles.swift
//  DeleteMatchingFiles
//
//  Created by S🌟System on 2022-07-24.
//

import CryptoKit
import Foundation

import ArgumentParser
import SimpleLogging



internal let defaultHashFileName = "delete-files-matching-hashes.txt"

internal let hashOptionsDescription = """
    By default, the name of the file which contains that hash is `\(defaultHashFileName)`.
    You may choose a different file with the `--hash-file-name` option.
    You may also provide a hash without using a file by using the `--hash` option.
    Providing both of those options at the same time is not defined behavior.
    """

var isDirectory: ObjCBool = false



@main
struct DeleteMatchingFiles: ParsableCommand {
    
    static let configuration = CommandConfiguration(
        commandName: "delete-matching-files",
        abstract: "Deletes all files in a folder that match a given hash",
        discussion: """
            This will use a file hash you choose in order to delete any files in a folder you choose which have that same hash.
            
            ***This version of this command ONLY uses UTF-8 encoded SHA-512 hashes!***
            
            \(hashOptionsDescription)
            """,
        version: "1.0.0",
        shouldDisplay: true,
        helpNames: .long)
    
    
    /// _optional_ - A hash which will be used instead of the hash file. If excluded, the hash file will be used
    @Option(help: "A hash which will be used instead of the hash file. If excluded, the hash file will be used")
    var hash: String?
    
    /// _optional_ - Overides the default hash file name
    @Option(help: "Overides the default hash file name")
    var hashFileName: String?
    
    /// _optional_ - The volume (amount) of output you want from this command
    @Option(help: "The volume (amount) of output you want from this command")
    var outputVolume: OutputVolume = .unix
    
    /// The path to the folder which this will clean. This is required to ensure you understand that files in this folder will be deleted.
    @Argument(help: "The path to the folder which this will clean. This is required to ensure you understand that files in this folder will be deleted.")
    var folderPath: String
    
    
    func run() throws {
        LogManager.defaultChannels = outputVolume.logChannels
        logEntry(); defer { logExit() }
        
        let folderUrl = URL(fileURLWithPath: folderPath)
        
        log(debug: "Searching \(folderUrl.path)")
        
        guard let hashData = try findHash(for: folderUrl) else {
            throw .noHashFound(in: folderUrl)
        }
        
        log(debug: "Looking for hashes matching: \(hashData.base64EncodedString())")
        
        guard
            FileManager.default.fileExists(atPath: folderPath, isDirectory: &isDirectory),
            isDirectory.boolValue
        else {
            throw .notAFolder(at: folderUrl)
        }
        
        log(debug: "Folder exists and is a directory")
        
        let children = try FileManager.default.contentsOfDirectory(at: folderUrl, includingPropertiesForKeys: nil)
        
        log(debug: "Child files:")
        log(debug: children)
        
        guard !children.isEmpty else {
            throw .emptyFolder(at: folderUrl)
        }
        
        try children
            .lazy
            .filter { url in
                log(verbose: "Filtering \(url.lastPathComponent) for exisence")
                
                let exists = FileManager.default.fileExists(atPath: url.path, isDirectory: &isDirectory)
                
                log(debug: "\t It does\(exists ? "" : "n't") exist")
                log(debug: "\t It is\(isDirectory.boolValue ? "" : "n't") a directory")
                
                return exists && !isDirectory.boolValue
            }
            .compactMap { url in
                log(verbose: "Compact mapping \(url.lastPathComponent) to data and comparing hashes")
                
                guard let data = try? Data(contentsOf: url) else {
                    log(debug: "\t Could not read contents of file at \(url.lastPathComponent)")
                    return nil
                }
                
                let hash = SHA512.hash(data: data)
                
                log(verbose: "\t The hash is \(hash)")
                
                guard hash == hashData else {
                    log(verbose: "Hashes don't match for \(url.lastPathComponent)")
                    
                    
                    if hash.description.contains(hashData.base64EncodedString()) {
                        log(error: "They actually match tho")
                    }
                    
                    return nil
                }
                
                log(debug: "Hashes match for \(url.lastPathComponent)")
                
                return url
            }
            .forEach { (url: URL) in
                //print("Would trash \(url.lastPathComponent)")
                log(info: "Trashing \(url.lastPathComponent)")
                try FileManager.default.trashItem(at: url, resultingItemURL: nil)
            }
    }
    
    
    private func findHash(for folderUrl: URL) throws -> Data? {
        func encoded() throws -> String? {
            if let explicitHashOption = hash {
                log(debug: "Hash was given in the CLI")
                return explicitHashOption
            }
            else {
                let hashFileName = self.hashFileName ?? defaultHashFileName
                log(debug: "Hash file name: \(hashFileName)")
                
                let hashFile = folderUrl.appendingPathComponent(hashFileName)
                
                guard FileManager.default.fileExists(atPath: hashFile.path, isDirectory: &isDirectory),
                      !isDirectory.boolValue
                else {
                    throw .noHashFound(in: folderUrl)
                }
                
                return try String(contentsOf: hashFile)
            }
        }
        
        guard let encodedHash = try encoded()?.trimmingCharacters(in: .whitespacesAndNewlines) else {
            log(verbose: "No hash found")
            return nil
        }
        
        log(verbose: "Encoded hash: \(encodedHash.replacingCharacters(in: .alphanumerics.inverted, with: "🚫"))")
        
        return Data(hexEncoded: encodedHash)
    }
}



extension String {
    func replacingCharacters(in characterSet: CharacterSet, with replacement: String) -> String {
        let replacementScalars = Array(replacement.unicodeScalars)
        return String(UnicodeScalarView(self.lazy
            .flatMap(\.unicodeScalars)
            .flatMap { scalar in
                characterSet.contains(scalar)
                    ? replacementScalars
                    : [scalar]
            }
        ))
    }
}
