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

extension Simctl {
    /** Extracts a section starting with `== Devices ==`*/
    private static func extractDeviceSection(listResponse: String) -> [String] {
        let lines = listResponse.split(separator: "\n")
        var section: [String] = []
        var inSection = false
        for line in lines {
            if !inSection && line == "== Devices ==" {
                inSection = true
            }
            else if inSection && line.starts(with: "==") {
                inSection = false
            }
            else if inSection {
                section.append(String(line))
            }
        }
        return section
    }
    private static func parse(line: String) -> String {
        var pattern = #"\s*"# //trim whitespace
        pattern.append(#"(.+?(?=\s*\())"#) //look for name.  Stop before first (
        //pattern.append(#""#)
        let regex = try! NSRegularExpression(pattern: pattern, options: NSRegularExpression.Options())
        let result = regex.firstResult(in: line)!
        for (r,result) in result.enumerated() {
            logger.debug("group \(r) '\(result)'")
        }
        return String(result[1]) //device type
    }
    static func parse(listResponse: String) -> [SimulatorSpecification] {
        let deviceSection = extractDeviceSection(listResponse: listResponse)
        var currentRuntime: Substring? = nil
        
        var specs: [SimulatorSpecification] = []
        for line in deviceSection {
            if line.starts(with: "-- "), line.hasSuffix(" --") {
                let h = line.index(line.startIndex, offsetBy: 3)
                let t = line.index(line.endIndex, offsetBy: -3)
                currentRuntime = line[h..<t]
            }
            else {
                let deviceName = parse(line: line)
                let spec = SimulatorSpecification(deviceType: deviceName, runtime: String(currentRuntime!))
                specs.append(spec)
            }
        }
        return specs
    }
}
