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
public struct MainCommand: ParsableCommand {
    public static var configuration = CommandConfiguration(
        commandName: "simpreboot",
        abstract: "Preboot iOS Simulators",
        subcommands: [Version.self,PrebootCommand.self, DeleteAllCommand.self],
        defaultSubcommand: PrebootCommand.self)
    public init() { }
}

struct CommonOptions: ParsableArguments {
    @Flag(name:[.long], help:ArgumentHelp("Avoid unnecessary prints, useful for machine-readable workflows.", discussion: """
    This option silences all unnecessary prints, and often reformats output into a machine-readable form.

    """))
    var quiet: Bool = false
    
    func setAppropriateLogLevel() {
        if quiet {
            logger = .init(level: .quiet)
        }
    }
}
