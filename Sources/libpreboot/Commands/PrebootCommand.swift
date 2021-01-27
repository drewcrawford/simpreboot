//MainCommand.swift
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

import ArgumentParser
import Foundation
struct PrebootCommand: ParsableCommand {
    static let configuration = CommandConfiguration(commandName: "preboot", abstract: "Preboots one or more simulators.")
    @Option(help: "How many instances to bring up") var count: Int
    @Option(help: "Device type.  May be a name like 'iPhone 12' or an identifier like 'com.apple.CoreSimulator.SimDeviceType.iPhone-12'.  See the output of`xcrun simctl list` for a list.")
    var deviceTypeInfo: String
    @Option(help: "Runtime information.  May be a name like 'iOS 14.3' or an identifier like 'com.apple.CoreSimulator.SimRuntime.iOS-10-0'.  See the output of `xcrun simctl list` for a list.  If you omit this value, we will try to find the latest runtime matching your device.")
    var runtimeInfo: String?
    @Option(help: "Path to simctl.  If you don't provide a value, we will ask `xcrun` for the path.")
    var simctlPath: String?
    
    @OptionGroup var commonOptions: CommonOptions
    
    func run() throws {
        commonOptions.setAppropriateLogLevel()
        let simCtl = try Simctl(argument: simctlPath)
        
        //resolve device
        let list = try simCtl.list()
        let resolvedDeviceType = list.deviceTypeMapper[deviceTypeInfo]
        logger.debug("Using device type \(resolvedDeviceType.rawValue)")
        
        //resolve runtime
        let resolvedRuntime = list.runtimeMapper[runtimeInfo, resolvedDeviceType]
        logger.debug("Using runtime \(resolvedRuntime.rawValue)")
        
        let request = PrebootRequest(count: count, deviceType: resolvedDeviceType, runtime: resolvedRuntime)
        let resolvedRequest = try request.run(simctl: simCtl, deviceMapper: list.deviceMapper)
        if commonOptions.quiet {
            print(resolvedRequest.recommendedXcodeArgs, terminator: "")
        }
        else {
            print("Recommended arguments: \(resolvedRequest.recommendedXcodeArgs)")
        }
    }
}
