# SwiftSlack - A Launchpad for Slack

[![Perfect logo](http://www.perfect.org/github/Perfect_GH_header_854.jpg)](http://perfect.org/get-involved.html)

[![Perfect logo](http://www.perfect.org/github/Perfect_GH_button_1_Star.jpg)](https://github.com/PerfectlySoft/Perfect)
[![Perfect logo](http://www.perfect.org/github/Perfect_GH_button_2_Git.jpg)](https://gitter.im/PerfectlySoft/Perfect)
[![Perfect logo](http://www.perfect.org/github/Perfect_GH_button_3_twit.jpg)](https://twitter.com/perfectlysoft)
[![Perfect logo](http://www.perfect.org/github/Perfect_GH_button_4_slack.jpg)](http://perfect.ly)


[![Swift 3.0](https://img.shields.io/badge/Swift-3.0-orange.svg?style=flat)](https://developer.apple.com/swift/)
[![Platforms OS X | Linux](https://img.shields.io/badge/Platforms-OS%20X%20%7C%20Linux%20-lightgray.svg?style=flat)](https://developer.apple.com/swift/)
[![License Apache](https://img.shields.io/badge/License-Apache-lightgrey.svg?style=flat)](http://perfect.org/licensing.html)
[![Twitter](https://img.shields.io/badge/Twitter-@PerfectlySoft-blue.svg?style=flat)](http://twitter.com/PerfectlySoft)
[![Join the chat at https://gitter.im/PerfectlySoft/Perfect](https://img.shields.io/badge/Gitter-Join%20Chat-brightgreen.svg)](https://gitter.im/PerfectlySoft/Perfect?utm_source=badge&utm_medium=badge&utm_campaign=pr-badge&utm_content=badge)
[![Slack Status](http://perfect.ly/badge.svg)](http://perfect.ly) [![GitHub version](https://badge.fury.io/gh/PerfectlySoft%2FPerfect-CURL.svg)](https://badge.fury.io/gh/PerfectlySoft%2FPerfect-CURL)

This project started as a Swift 3 port of [Slackin](https://github.com/rauchg/slackin). It does not include the socket.io feature of Slackin as it's been built with the intent to be as lightweight as possible. 

SwiftSlack / Slackin provides a landing page you can point users to fill in their emails and receive an invite (https://slack.yourdomain.com). It also provides an SVG "badge" that can be included in places like your GitHub projects at a URL like: https://slack.yourdomain.com/badge.svg

**Note:** The current UI, as well as some portions of this readme are taken from the fabulous Slackin project, which was the inspiration for this project. 

Because there is no database backend required, it can be configured easily by renaming the `ApplicationConfiguration.json.default.json` file to `ApplicationConfiguration.json`, and updating the "token" and "name" values in the JSON:

```
{
	"token": "---",
	"name": "perfectswift"
}
```

This package builds with Swift Package Manager and is part of the [Perfect](https://github.com/PerfectlySoft/Perfect) project.

## Obtaining Configuration Details

The "name" is the subdomain (first part) of your Slack URL. For example, to access the Perfect Slack channel, the URL is https://perfectswift.slack.com. In the "https://perfectswift.slack.com" case the "name" would be "perfectswift".

You can find or generate your API test token at api.slack.com/web – note that the user you use to generate the token must be an admin. You need to create a dedicated @slackin-inviter user (or similar), mark that user an admin, and use a test token from that dedicated admin user. Note that test tokens have actual permissions so you do not need to create an OAuth 2 app. Also check out the Slack docs on generating a test token.

Important: If you use Slackin in single-channel mode, you'll only be able to invite as many external accounts as paying members you have times 5. If you are not getting invite emails, this might be the reason. Workaround: sign up for a free org, and set up Slackin to point to it (all channels will be visible).

## Deploying

By far the easiest way to deploy SwiftSlack is using [Perfect Assistant (PA)](https://www.perfect.org/en/assistant/). Either import the project directly from the URL into PA, or clone/download from GitHub and import as an existing project into PA.

Once imported, deploy to AWS or Google App Engine using PA. Make sure you check that the `ApplicationConfiguration.json` has been correctly configured and uploaded with the deployment.

When you run locally on macOS, the default port is set to 8181. When run on Linux, the default port is 8103.

To change this, change the values in main.swift:

``` swift
#if os(Linux)
	let	FileRoot = "/perfect-deployed/swiftslack/"
	let port = 8103
#else
	let FileRoot = ""
	let port = 8181
#endif
```

Note that the var "FileRoot" is also different between macOS and Linux. Change this to suit as needed.

## Further Information
For more information on the Perfect project, please visit [perfect.org](http://perfect.org).
