## Where is this forked repo used?

In the NiceDay app project: https://github.com/senseobservationsystems/goalie-2-mobile-app/

## Why do we have this repo forked?

Apple started rejecting apps that use UIWebView. Like other libraries we use (react-native-webview, react-native-gesture-handler, react-native0.61), this library also fixed it by itself. But together with the fix, they made the minimum iOS target to iOS 11. Since we still wanted to support iOS 10 users, what we needed was to get one of the latest iOS 10 supported Urban Airship iOS-library version (11.1.1), and manually remove all the UIWebView references.

## What does this fork version contain in comparison with the root one?

As just said, this version just removes all the UIWebView references of the repo, but without removing the iOS 10 support.

## When did we fork it?

13th of May 2020. When we were releasing 1.0.z version of the app to Beta. It's the version that contains the update to RN 0.61 (from 0.59) and the switch from react-native-navigation to react-navigation.

## From where did we apply the changes?

We applied our changes on the exact version of Urbain Airship iOS-library that we were using currently in the app, 11.1.1. Just to prevent other changes that were not properly tested before.

## What is necessary to proceed or get rid of this forked repo?

Once the iOS 10 users are considerably reduced, then we can move on and just update to the latest version from Urban Airship, which fixes the issue as well. 