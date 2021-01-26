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
        let devices = try DeviceMapper(listResponse: simCtlList)
        XCTAssert(devices.devices.contains(where: {$0.deviceTypeIdentifier.rawValue == "com.apple.CoreSimulator.SimDeviceType.iPhone-12"}))
        XCTAssertEqual(devices.devices.count,121)
    }
    func testLiveList() throws {
        let simctl = try Simctl()
        let results = try simctl.list()
        XCTAssert(results.deviceMapper.devices.count > 0)
    }
    
    func testDeviceTypeMapper() throws {
        let mapper = try DeviceTypeMapper(listResponse: simCtlList)
        XCTAssertEqual(mapper[DeviceTypeShortName("iPhone 12")].rawValue,"com.apple.CoreSimulator.SimDeviceType.iPhone-12")
    }
    func testRuntimeMapper() throws {
        let mapper = try RuntimeMapper(listResponse: simCtlList)
        XCTAssertEqual(mapper[RuntimeShortName("iOS 14.3")].rawValue,"com.apple.CoreSimulator.SimRuntime.iOS-14-3")
    }
    func testBestOS() throws {
        let mapper = try RuntimeMapper(listResponse: simCtlList)
        XCTAssertEqual(mapper.best(for: "iOS"), RuntimeIdentifier("com.apple.CoreSimulator.SimRuntime.iOS-14-3"))
    }
    
    func testDevicesMatching() throws {
        let mapper = try DeviceMapper(listResponse: simCtlList)
        let matchingDevices = mapper.devices(matching: DeviceTypeIdentifier("com.apple.CoreSimulator.SimDeviceType.iPhone-12"), runtimeIdentifier: RuntimeIdentifier("com.apple.CoreSimulator.SimRuntime.iOS-14-3"))
        XCTAssertEqual(matchingDevices.count, 1)
    }
    
    func testPartiallyResolve() throws {
        let mapper = try DeviceMapper(listResponse: simCtlList)
        let deviceType = DeviceTypeIdentifier("com.apple.CoreSimulator.SimDeviceType.iPhone-12")
        let runtime = RuntimeIdentifier("com.apple.CoreSimulator.SimRuntime.iOS-14-3")
        
        let requestZero = PrebootRequest(count: 0, deviceType: deviceType, runtime: runtime)
        XCTAssertEqual(mapper.partiallyResolve(request: requestZero).count, 0)
        
        let requestOne = PrebootRequest(count: 1, deviceType: deviceType, runtime: runtime)
        XCTAssertEqual(mapper.partiallyResolve(request: requestOne).count, 1)
        
        let requestTwo = PrebootRequest(count: 2, deviceType: deviceType, runtime: runtime)
        XCTAssertEqual(mapper.partiallyResolve(request: requestTwo).count, 1)
    }
}
