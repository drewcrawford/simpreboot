//simctl/delete.swift: `simctl delete` implementation
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
    func delete(deviceIdentifier: DeviceIdentifier) throws {
        logger.info("Deleting \(deviceIdentifier.rawValue)")
        let _ = try execute(arguments: ["delete",deviceIdentifier.rawValue])
    }
    
    func deleteAll(named: String) throws {
        while true {
            do {
                let _ = try execute(arguments: ["delete",named])
            }
            catch Simctl.Errors.returnCode(148) { //no such device
                break
            }
            
        }
    }
}
