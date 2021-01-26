//CreateTests.swift: `simctl create` tests
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

final class CreateTests: XCTestCase {
    func testCreate() throws {
        let simctl = try Simctl()
        let typeIdentifier = DeviceTypeIdentifier("com.apple.CoreSimulator.SimDeviceType.iPhone-12")
        let runtime = RuntimeIdentifier("com.apple.CoreSimulator.SimRuntime.iOS-14-3")
        let r = try simctl.create(name: "testCreate", deviceType: typeIdentifier, runtimeIdentifier: runtime)
        
        //verify item was created
        let list = try simctl.list()
        let deviceInfo = list.deviceMapper[r]
        XCTAssertEqual(deviceInfo.name,"testCreate")
        
        try simctl.delete(deviceIdentifier: r)
    }
    
    func testCreateIfNeeded() throws {
        let simctl = try Simctl()
        let typeIdentifier = DeviceTypeIdentifier("com.apple.CoreSimulator.SimDeviceType.iPhone-12")
        let runtime = RuntimeIdentifier("com.apple.CoreSimulator.SimRuntime.iOS-14-3")
        
        try simctl.deleteAll(named: "simpreboot")
        let priorList = try simctl.list()
        let createRequest = PrebootRequest(count: 3, deviceType: typeIdentifier, runtime: runtime)
        let _ = try simctl.createIfNeeded(request: createRequest, deviceMapper: priorList.deviceMapper)
        
        let newList = try simctl.list()
        //make sure we created 3 devices
        XCTAssertEqual(newList.deviceMapper.partiallyResolve(request: createRequest).count, createRequest.count)
        //clean up
        try simctl.deleteAll(named: "simpreboot")
    }
}
