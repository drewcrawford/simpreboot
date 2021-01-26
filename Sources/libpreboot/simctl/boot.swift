//simctl/boot.swift: `simctl boot` implementation
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

extension Simctl {
    func boot(device: DeviceIdentifier) throws {
        logger.info("Booting \(device.rawValue)")
        let _ = try execute(arguments: ["boot",device.rawValue])
    }
    func bootIfNeeded(request: PrebootRequestCreated, deviceMapper: DeviceMapper) throws {
        for identifier in request.devices {
            if let device = deviceMapper[identifier] {
                if device.isBootable {
                    try boot(device: device.identifier)
                }
            }
            else {
                //if the device is not in the mapper, we assume it was created "recently", e.g. after the deviceMapper was created.
                try boot(device: identifier)
            }
        }
    }
}
