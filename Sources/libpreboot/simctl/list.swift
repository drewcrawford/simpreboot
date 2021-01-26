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

private struct ListCommandDevices: Decodable {
    struct Device: Decodable {
        let name: DeviceShortName
        let deviceTypeIdentifier: DeviceTypeIdentifier

    }
    let devices: [String: [Device]] //in order to make json happy, this needs to be indexed by String, not RuntimeIdentifier
}

struct DeviceTypeIdentifier: Decodable, Hashable {
    let rawValue: String
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        rawValue = try container.decode(String.self)
    }
}
struct DeviceShortName: Decodable, Hashable {
    let rawValue: String
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        rawValue = try container.decode(String.self)
    }
    init(_ string: String) {
        self.rawValue = string
    }
}

private struct ListCommandDeviceTypes: Decodable {
    struct DeviceType: Decodable {
        let name: DeviceShortName
        let identifier: DeviceTypeIdentifier
    }
    let devicetypes: [DeviceType]
}

/**Maps between device type names and identifiers */
struct DeviceTypeMapper {
    private let maps: [DeviceShortName: DeviceTypeIdentifier]
    init(listResponse: String) throws {
        guard let data = listResponse.data(using: .utf8) else {
            throw Simctl.Errors.cantDecodeString
        }
        
        let decoder = JSONDecoder()
        let command = try decoder.decode(ListCommandDeviceTypes.self, from: data)
        var _maps: [DeviceShortName: DeviceTypeIdentifier] = [:]
        for device in command.devicetypes {
            _maps[device.name] = device.identifier
        }
        maps = _maps
    }
    subscript(name: DeviceShortName) -> DeviceTypeIdentifier {
        return maps[name]!
    }
}

struct RuntimeIdentifier: Decodable, Hashable {
    let rawValue: String
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        rawValue = try container.decode(String.self)
    }
    init(_ rawValue: String) {
        self.rawValue = rawValue
    }
}
struct RuntimeShortName: Decodable, Hashable {
    let rawValue: String
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        rawValue = try container.decode(String.self)
    }
    init(_ rawValue: String) {
        self.rawValue = rawValue
    }
}

private struct ListCommandRuntimes: Decodable {
    struct Runtime: Decodable {
        let name: RuntimeShortName
        let identifier: RuntimeIdentifier
        let version: String
    }
    let runtimes: [Runtime]
}

struct RuntimeMapper {
    private let maps: [RuntimeShortName: RuntimeIdentifier]
    private let infos: [RuntimeIdentifier: ListCommandRuntimes.Runtime]
    init(listResponse: String) throws {
        guard let data = listResponse.data(using: .utf8) else {
            throw Simctl.Errors.cantDecodeString
        }
        
        let decoder = JSONDecoder()
        let command = try decoder.decode(ListCommandRuntimes.self, from: data)
        var _maps: [RuntimeShortName: RuntimeIdentifier] = [:]
        var _infos: [RuntimeIdentifier: ListCommandRuntimes.Runtime] = [:]
        for runtime in command.runtimes {
            _maps[runtime.name] = runtime.identifier
            _infos[runtime.identifier] = runtime
        }
        maps = _maps
        infos = _infos
        
    }
    subscript(name: RuntimeShortName) -> RuntimeIdentifier {
        return maps[name]!
    }
    func best(for family: String) -> RuntimeIdentifier {
        let candidates = maps.keys.filter({$0.rawValue.hasPrefix(family)})
        let bestShortName = candidates.max(by: {$0.rawValue < $1.rawValue})!
        return self[bestShortName]
    }
}

struct SimulatorSpecification {
    let deviceType: DeviceTypeIdentifier
    let runtime: RuntimeIdentifier
}

struct DeviceMapper {
    let specifications: [SimulatorSpecification]
    init(listResponse: String) throws {
        let decoder = JSONDecoder()
        guard let data = listResponse.data(using: .utf8) else {
            throw Simctl.Errors.cantDecodeString
        }
        let command = try! decoder.decode(ListCommandDevices.self, from: data)
        var _specifications: [SimulatorSpecification] = []
        for (runtime,devices) in command.devices {
            for device in devices {
                _specifications.append(SimulatorSpecification(deviceType: device.deviceTypeIdentifier, runtime: RuntimeIdentifier(runtime)))
            }
        }
        specifications = _specifications
    }
}

extension Simctl {
    
    struct ListMappers {
        let deviceMapper: DeviceMapper
        let deviceTypeMapper: DeviceTypeMapper
        let runtimeMapper: RuntimeMapper
        init(listResponse: String) throws {
            deviceMapper = try DeviceMapper(listResponse: listResponse)
            deviceTypeMapper = try DeviceTypeMapper(listResponse: listResponse)
            runtimeMapper = try RuntimeMapper(listResponse: listResponse)
        }
    }
    
    func list() throws -> ListMappers {
        let output = try execute(arguments: ["list","-j"])
        return try ListMappers(listResponse: output)
    }
}

