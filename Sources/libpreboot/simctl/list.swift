//simctl/list.swift: `simctl list` implementation
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

private struct ListCommand: Decodable {
    struct Device: Decodable {
        let name: String
        let deviceTypeIdentifier: String

    }
    let devices: [String: [Device]]
}

extension Simctl {
   
    static func parse(listResponse: String) throws -> [SimulatorSpecification] {
        let decoder = JSONDecoder()
        guard let data = listResponse.data(using: .utf8) else {
            throw Errors.cantDecodeString
        }
        let command = try decoder.decode(ListCommand.self, from: data)
        var specifications: [SimulatorSpecification] = []
        for (runtime,devices) in command.devices {
            for device in devices {
                specifications.append(SimulatorSpecification(deviceType: device.deviceTypeIdentifier, runtime: runtime))
            }
        }
        return specifications
    }
    
    func list() throws -> [SimulatorSpecification] {
        let output = try execute(arguments: ["list","-j"])
        return try Simctl.parse(listResponse: output)
    }
}

