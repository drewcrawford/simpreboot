# simpreboot

Are you tired of your iOS tests taking forever?  Have you optimized your tests and even turned on parallel testing, only to discover that the time to boot more simulators dominates everything?  This is the package for you!

`simpreboot` creates and boots long-lived simulators.  Unlike transient clones created by `xcodebuild` (which are created and destroyed on each test run, at significant expense) simpreboot simulators persist until you shut them down, e.g. between test runs.

`simpreboot` speeds up testing by many orders of magnitude.  My tests went from 5 minutes to 10 seconds.  

# Install
Prebuilt binaries are available on the [releases page](https://github.com/drewcrawford/simpreboot/releases).  An ansible script that can install to your whole fleet is available in my [xcode-ansible](https://github.com/drewcrawford/xcode-ansible) project.

# Usage

To bring up some simulators, use e.g.

```bash
simpreboot --count 3 --device-type-info 'iPhone 12'
```

see `--help` for more commands and information.

## CI usage

The following `xcodebuild` command is representative:

```bash
# Construct the xcodebuild arguments by running simpreboot in quiet mode:
eval "PREBOOT=($(simpreboot --count 3 --device-type-info 'iPhone 12' --quiet))"
# pass arguments to xcodebuild
xcodebuild test-without-building -scheme "MyScheme" "${PREBOOT[@]}"
```