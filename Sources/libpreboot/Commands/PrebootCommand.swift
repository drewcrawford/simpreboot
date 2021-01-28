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

private let countHelp = ArgumentHelp("How many instances to bring up.", discussion: """
The optimum value is often substantially different than what Xcode uses for its workflow, so I recommend finding an optimum value by trial and error.
The optimal value is usually lower than what Xcode would do, and for short test suites is often '1'.
""")

private let runtimeHelp = ArgumentHelp("Runtime for new simulators.  Optional.", discussion: """
May be a name like 'iOS 14.3' or an identifier like 'com.apple.CoreSimulator.SimRuntime.iOS-10-0'.  See the output of `xcrun simctl list` for a list.  If you omit this value, we will try to find the latest runtime for the device.
""")

private let deviceHelp = ArgumentHelp("Device type for new simulators", discussion: """
May be a name like 'iPhone 12' or an identifier like 'com.apple.CoreSimulator.SimDeviceType.iPhone-12'.  See the output of`xcrun simctl list` for a list.
""")

struct PrebootCommand: ParsableCommand {
    static let configuration = CommandConfiguration(commandName: "preboot", abstract: "Preboots one or more simulators.", discussion: """
    This preboots the specified simulators, which will be left running after any xcodebuild invocations complete.
    
    EXAMPLES
    
    preboot 3x iPhone 12:
        simpreboot --count 3 --device-type-info 'iPhone 12'

    The above, but showing chaining to xcodebuild:
    
        # Construct the xcodebuild arguments by running simpreboot in quiet mode:
        eval "PREBOOT=($(simpreboot --count 3 --device-type-info 'iPhone 12' --quiet))"
        # pass arguments to xcodebuild
        xcodebuild test-without-building -scheme "MyScheme" "${PREBOOT[@]}"

    """)
    
    @Option(help: countHelp ) var count: Int
    @Option(help: deviceHelp)
    var deviceTypeInfo: String
    @Option(help: runtimeHelp)
    var runtimeInfo: String?
    @Option(help: "Path to simctl. Optional. If you don't provide a value, we will ask `xcrun` for the path.")
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
