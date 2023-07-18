//
//  Errors.swift
//  DeleteMatchingFiles
//
//  Created by S🌟System on 2022-07-24.
//

import Foundation



extension DeleteMatchingFiles {
    enum Errors {
        struct NotAFolder: LocalizedError {
            
            let problemUrl: URL
            
            var errorDescription: String {
                """
                Whoops! You need to tell this command where a folder currently is, but it seems this is not a folder:
                \(problemUrl.path)
                """
            }
        }
        
        
        struct EmptyFolder: LocalizedError {
            
            let problemUrl: URL
            
            var errorDescription: String {
                """
                Whoops! This command only looks at files in a folder. You told it which folder to look at, but that's empty:
                \(problemUrl.path)
                """
            }
        }
        
        
        struct NoHashFound: LocalizedError {
            
                
                var localizedDescription: String { errorDescription }
            let folderUrl: URL
            
            var errorDescription: String {
                """
                Whoops! This command needs a hash to compare matching files against, but it couldn't find any.
                \(hashOptionsDescription)
                
                I recommend you place a file named `\(defaultHashFileName)` in this folder, with the hash you want to match.
                
                As a reminder, this folder is:
                \(folderUrl.path)
                """
            }
        }
        
        
        struct HashOptionNotUtf8: LocalizedError {
            
            var localizedDescription: String { errorDescription }
            
            var errorDescription: String {
                """
                Whoops! You passed a hash to the `--hash` argument, but what you passed wasn't UTF-8. Try again with UTF-8 encoded hash data!
                """
            }
        }
    }
}



extension Error where Self == DeleteMatchingFiles.Errors.NotAFolder {
    static func notAFolder(at url: URL) -> Self { Self(problemUrl: url) }
}
extension Error where Self == DeleteMatchingFiles.Errors.EmptyFolder {
    static func emptyFolder(at url: URL) -> Self { Self(problemUrl: url) }
}
extension Error where Self == DeleteMatchingFiles.Errors.NoHashFound {
    static func noHashFound(in folderUrl: URL) -> Self { Self(folderUrl: folderUrl) }
}
extension Error where Self == DeleteMatchingFiles.Errors.HashOptionNotUtf8 {
    static var hashOptionNotUtf8: Self { Self() }
}
