//simctlListTests.swift: tests for 'simctl list'
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
@testable import libpreboot
final class SimctlListTests: XCTestCase {
    func testListParse() throws {
        let devices = try Simctl.parse(listResponse: simCtlList)
        XCTAssert(devices.contains(where: {$0.deviceType == "com.apple.CoreSimulator.SimDeviceType.iPhone-12"}))
        XCTAssertEqual(devices.count,121)
    }
    func testLiveList() throws {
        let simctl = try Simctl()
        let results = try simctl.list()
        XCTAssert(results.count > 0)
    }
    
    func testDeviceTypeMapper() throws {
        let mapper = try DeviceTypeMapper(listResponse: simCtlList)
        XCTAssertEqual(mapper[DeviceShortName("iPhone 12")].rawValue,"com.apple.CoreSimulator.SimDeviceType.iPhone-12")
    }
    func testRuntimeMapper() throws {
        let mapper = try RuntimeMapper(listResponse: simCtlList)
        XCTAssertEqual(mapper[RuntimeShortName("iOS 14.3")].rawValue,"com.apple.CoreSimulator.SimRuntime.iOS-14-3")
    }
    func testBestOS() throws {
        let mapper = try RuntimeMapper(listResponse: simCtlList)
        XCTAssertEqual(mapper.best(for: "iOS"), RuntimeIdentifier("com.apple.CoreSimulator.SimRuntime.iOS-14-3"))
    }
}
