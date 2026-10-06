# How the release gate decides

The release can advance only after the watched share has spoken. The operator starts from a canary, a release that reaches a small share of users first, and that share is the shadow share, the portion of traffic that sees the new build while the old build still serves the rest.

The gate holds the release because the shadow share is still climbing, and because the error count in that share has not yet fallen below the rollback line. The new build can pass every automated check in the gate, but a quiet failure in one client library still reaches users who never opted into the trial. The release advances to the full user base only if the shadow share stays under the error line for a full day. The gate checks three signals in this fixed order before any later stage can hide an earlier failure: intake of the named build, review of the checks that already ran, and release to the watched share.

A late failure cannot hide an earlier one, because the three signals are one ordered decision. Intake asks whether the build is the one the operator named. Review asks whether the checks that already ran still describe this build. Release asks whether the share that has seen the build is wide enough to trust and still quiet enough to continue. A build that fails intake never reaches review, and a build that fails review never reaches the users past the canary.

A green check is not the same thing as a quiet caller, because a client library can still speak the old contract after the service has moved on. The checks run inside the service, against the build the service holds. The trial the user never opted into is then the only place that mismatch appears. The gate exists so that mismatch has a place to show up before the rest of the user base sees the build.

The quieter signal should decide, because the error count in the shadow share fell from 40 in the first hour to 6 in the third, and that fall is the stronger figure behind the choice. Support tickets stayed flat through the watched hours.

## The release can advance

The release can advance, because the shadow share is inside the rollback line. The first hour saw 40 errors across 800 requests, which is 5 in every 100. The third hour saw 6 errors across 800 requests, which is under 1 in every 100.
