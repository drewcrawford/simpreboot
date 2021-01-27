//PrebootRequestTests.swift
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
final class PrebootRequestTests: XCTestCase {
    func testArgs() {
        let request = PrebootRequestCreated(devices: [DeviceIdentifier("identifier1"),DeviceIdentifier("identifier2")])
        let args = request.recommendedXcodeArgs
        XCTAssertEqual(args, "-parallelize-tests-among-destinations -destination 'id=identifier1' -destination 'id=identifier2'")
    }
    
    func testRunRequest() throws {
        let identifier = DeviceTypeIdentifier("com.apple.CoreSimulator.SimDeviceType.iPhone-12")
        let request = PrebootRequest(count: 3, deviceType: identifier, runtime: testRuntime)
        
        let simctl = try Simctl()
        //cleanup
        logger.info("Pre cleanup")
        try simctl.deleteAll(named: "simpreboot")
        
        let priorList = try simctl.list()
        logger.info("Run request")
        let createRequest = try request.run(simctl: simctl, deviceMapper: priorList.deviceMapper)
        XCTAssertEqual(createRequest.devices.count, 3)
        let postRequest = try simctl.list()
        for item in createRequest.devices {
            let device = try XCTUnwrap(postRequest.deviceMapper[item])
            XCTAssertEqual(device.state, .booted)
        }
        //clean up
        logger.info("Cleaning up...")
        try simctl.deleteAll(named: "simpreboot")
    }
}
