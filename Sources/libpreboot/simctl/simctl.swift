//simctl.swift: simctl invocation
/*
 simpreboot © 2021 DrewCrawfordApps LLC
 Unless explicitly acquired and licensed from Licensor under another
 license, the contents of this file are subject to the Reciprocal Public
 License ("RPL") Version 1.5, or subsequent versions as allowed by the RPL,
 and You may not copy or use this file in either source code or executable
 form, except in compliance with the terms and conditions of the RPL.

 All software distributed under the RPL is provided strictly on an "AS
 IS" basis, WITHOUT WARRANTY OF ANY KIND, EITHER EXPRESS OR IMPLIED, AND
 LICENSOR HEREBY DISCLAIMS ALL SUCH WARRANTIES, INCLUDING WITHOUT
 LIMITATION, ANY WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR
 PURPOSE, QUIET ENJOYMENT, OR NON-INFRINGEMENT. See the RPL for specific
 language governing rights and limitations under the RPL.
 */
import Foundation
import os.log

struct Simctl {
    private let simctl: URL
    enum Errors: Error {
        case noDataToRead
        case cantDecodeString
        case returnCode(Int)
    }
    func execute(arguments: [String]) throws -> String? {
        logger.debug("simctl \(arguments.joined(separator: " "))")
        let process = Process()
        process.arguments = arguments
        process.executableURL = simctl
        let stdout = Pipe()
        process.standardOutput = stdout
        
        try process.run()
        

        let _data = try stdout.fileHandleForReading.readToEnd()
        process.waitUntilExit()
        if process.terminationStatus != 0 {
            throw Errors.returnCode(Int(process.terminationStatus))
        }
        guard let data = _data else { return nil }

        guard let string = String(data: data, encoding: .utf8) else { throw Errors.cantDecodeString }
        return string
    }
    init(simctl: URL) {
        self.simctl = simctl
    }
    ///Creates the type by asking xcrun which simctl to use
    init() throws {
        let xcruntask = try NSUserUnixTask(url: URL(fileURLWithPath: "/usr/bin/xcrun"))
        let sema = DispatchSemaphore(value: 0)
        let stdout = Pipe()
        var err: Error? = nil
        xcruntask.standardOutput = stdout.fileHandleForWriting
        xcruntask.execute(withArguments: ["-f","simctl"], completionHandler: .some({ (error) in
            if let error = error {
                err = error
            }
            sema.signal()
        }))
        sema.wait()
        if let error = err {
            throw error
        }
        let _data = try stdout.fileHandleForReading.readToEnd()
        guard let data = _data else { throw Errors.noDataToRead }
        guard let string = String(data: data, encoding: .utf8)?.trimmingCharacters(in: .whitespacesAndNewlines) else { throw Errors.cantDecodeString }
        logger.debug("Using simctl \(string)")
        self.simctl = URL(fileURLWithPath: string)
    }
    
    ///Creates with the specified path or uses `xcrun` if nil
    init(argument: String?) throws {
        if let argument = argument {
            self.init(simctl: URL(fileURLWithPath: argument))
        }
        else {
            try self.init()
        }
    }
}
