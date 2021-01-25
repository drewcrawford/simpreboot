# simpreboot

Are you tired of your iOS tests taking forever?  Have you optimized your tests and even turned on parallel testing, only to discover that the time to boot more simulators dominates everything?  This is the package for you!

`simpreboot` creates and boots long-lived simulators.  Unlike the transient clones created by `xcodebuild` which are created and destroyed on each test run, at significant expense, these simulators persist between CI runs which means they don't boot during your tests.

`simpreboot` can speed up testing by many orders of magnitude.  My tests went from 5 minutes to 10 seconds.  


simpreboot preboot 
