# How the release gate decides

The operator starts from a canary. A release reaches a small share of users first. The gate stays shut until that share has something to say. The new build can pass every automated check in the gate. A quiet failure in one client library still reaches users who never opted into the trial. It holds the release for one reason. It watches the error count. It leaves the second reason out. The release advances to the full user base under a condition. One signal covers intake. A second signal covers review. A third signal covers release.

The shadow share kept climbing through the watched hours. Support tickets stayed flat. The error count fell from 40 in the first hour to 6 in the third. The quieter signal should decide.

The first hour saw 40 errors across 800 requests, which is 5 in every 100. The third hour saw 6 errors across 800 requests, which is under 1 in every 100. The release can advance.

The shadow share is the portion of traffic that sees the new build while the old build still serves the rest.
