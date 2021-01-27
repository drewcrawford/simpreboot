//simprebootTests: simpreboot Tests
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

import XCTest
import class Foundation.Bundle

final class simprebootTests: XCTestCase {
    
    
    func exec(arguments: [String]) throws -> String {
        let fooBinary = productsDirectory.appendingPathComponent("simpreboot")

        let process = Process()
        process.executableURL = fooBinary
        process.arguments = arguments

        let pipe = Pipe()
        process.standardOutput = pipe

        try process.run()
        process.waitUntilExit()

        let data = pipe.fileHandleForReading.readDataToEndOfFile()
        let output = String(data: data, encoding: .utf8)
        let str = try XCTUnwrap(output)
        return str
    }
    func testVersion() throws {
        
        let output = try exec(arguments: ["version"])

        XCTAssertEqual(output, "simpreboot © 2021 DrewCrawfordApps LLC\nvUNSPECIFIED-DEBUG\n")
    }
    
    func testVerisonQuiet() throws {
        let output = try exec(arguments: ["version","--quiet"])
        XCTAssertEqual(output, "UNSPECIFIED-DEBUG")

    }
    
    func testIntegration() throws {
        let output = try exec(arguments: ["--device-type-info","iPhone 12","--count","3"])
        print(output)
        XCTAssert(output.contains("Recommended arguments:"))
    }
    func testIntegrationQuiet() throws {
        let output = try exec(arguments: ["--device-type-info","iPhone 12","--count","3","--quiet"])
        XCTAssert(output.starts(with: "-parallelize-tests-among-destinations"))
        XCTAssert(output.hasSuffix("'")) //no newline
    }
    
    

    /// Returns path to the built products directory.
    var productsDirectory: URL {
      #if os(macOS)
        for bundle in Bundle.allBundles where bundle.bundlePath.hasSuffix(".xctest") {
            return bundle.bundleURL.deletingLastPathComponent()
        }
        fatalError("couldn't find the products directory")
      #else
        return Bundle.main.bundleURL
      #endif
    }
}
