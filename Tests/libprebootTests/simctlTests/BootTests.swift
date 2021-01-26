//BootTests.swift: `simctl boot` tests
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

final class BootTests: XCTestCase {
    func testBoot() throws {
        let simctl = try Simctl()
        let list = try simctl.list()
        
        let device = list.deviceMapper.bootable.first!.identifier
        
        try simctl.boot(device: device)
        
        let newList = try simctl.list()
        let newDevice = try XCTUnwrap(newList.deviceMapper[device])
        XCTAssertEqual(newDevice.state, .booted)
        
        //shutdown when done
        try simctl.shutdown(device: device)
        let shutdownList = try simctl.list()
        let shutdownDevice = try XCTUnwrap(shutdownList.deviceMapper[device])
        XCTAssertEqual(shutdownDevice.state, .shutdown)
    }
    func testBootIfNeeded() throws {
        let simctl = try Simctl()
        let list = try simctl.list()
        //create a request with 3 bootable devices
        var bootMe: [DeviceIdentifier] = []
        var bootable = list.deviceMapper.bootable
        while bootMe.count < 3 {
            let device = bootable.removeLast()
            bootMe.append(device.identifier)
        }
        
        let request = PrebootRequestCreated(devices: bootMe)
        try simctl.bootIfNeeded(request: request, deviceMapper: list.deviceMapper)
        
        let newList = try simctl.list()
        for identifier in request.devices {
            let device = try XCTUnwrap(newList.deviceMapper[identifier])
            XCTAssertEqual(device.state, .booted)
        }
        
        //shutdown all devices
        for identifier in request.devices {
            try simctl.shutdown(device: identifier)
        }
    }
}
