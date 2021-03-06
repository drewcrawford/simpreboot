//PrebootRequest.swift
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
import os
/**
 The device(s) we need to create and boot
 */
struct PrebootRequest {
    ///how many devices we require
    let count: Int
    let deviceType: DeviceTypeIdentifier
    let runtime: RuntimeIdentifier
    
    /**Run the entire request, creating and booting the specified devices.
     - parameter simctl: Which simctl to use for future commands
     - parameter listMappers: Result of simctl list from prior call(s).*/
    func run(simctl: Simctl, deviceMapper: DeviceMapper) throws -> PrebootRequestCreated {
        let createRequest = try simctl.createIfNeeded(request: self, deviceMapper: deviceMapper)
        try simctl.bootIfNeeded(request: createRequest, deviceMapper: deviceMapper)
        return createRequest
    }
}



/**
 Device(s) we may need to boot
 */
struct PrebootRequestCreated {
    let devices: [DeviceIdentifier]
    
    var recommendedXcodeArgs: String {
        var args = "-parallelize-tests-among-destinations"
        for device in devices {
            args.append(" -destination 'id=\(device.rawValue)'")
        }
        return args
    }
}
