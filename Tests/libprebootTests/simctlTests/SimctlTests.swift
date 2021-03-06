//SimctlTests: Tests for simctl
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
import Foundation
@testable import libpreboot

//runtime known to simctl that we can use for testing.  Need to bump this in new xcodes for tests to pass
func testRuntime(runtimeMapper: RuntimeMapper) -> RuntimeIdentifier {
    return runtimeMapper.best(for: "iOS")
}
final class SimctlTests: XCTestCase {
    func testInvokeList() throws {
        let s = Simctl(simctl: URL(fileURLWithPath: "/Applications/Xcode.app/Contents/Developer/usr/bin/simctl"))
        let output = try s.execute(arguments: ["list"])!
        print(output)
    }
    func testInvokeListAuto() throws {
        let s = try Simctl()
        let output = try s.execute(arguments: ["list"])!
        print(output)
    }
}
