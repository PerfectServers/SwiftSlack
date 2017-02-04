//
//  main.swift
//  SwiftSlack
//
//  Created by Jonathan Guthrie on 2016-10-14.
//	Copyright (C) 2015 PerfectlySoft, Inc.
//
//===----------------------------------------------------------------------===//
//
// This source file is part of the Perfect.org open source project
//
// Copyright (c) 2015 - 2016 PerfectlySoft Inc. and the Perfect project authors
// Licensed under Apache License v2.0
//
// See http://perfect.org/licensing.html for license information
//
//===----------------------------------------------------------------------===//
//
import PerfectLib
import PerfectHTTP
import PerfectHTTPServer
import PerfectMustache
import PerfectRequestLogger

// Settings path vars.
#if os(Linux)
	let	FileRoot = "/perfect-deployed/swiftslack/"
	let port = 8103
#else
	let FileRoot = ""
	let port = 8181
#endif

let (apiToken, slackName) = getSettings()

let slackObj = SlackAPI()
// get team info / logo
slackObj.teamInfo()
print(slackObj.logo)

slackObj.userList()
//print(slackObj.logo)

RequestLogFile.location = "./log.log"

// Configure Server
var confData: [String:[[String:Any]]] = [
	"servers": [
		[
			"name":"localhost",
			"port":port,
			"routes":[],
			"filters":[
				[
					"type":"response",
					"priority":"high",
					"name":PerfectHTTPServer.HTTPFilter.contentCompression,
					],
				[
					"type":"request",
					"priority":"high",
					"name":RequestLogger.filterAPIRequest,
					],
				[
					"type":"response",
					"priority":"high",
					"name":RequestLogger.filterAPIResponse,
					]
			]
		]
	]
]

// Add routes
var routes: [[String: Any]] = [[String: Any]]()
routes.append(["method":"get", "uri":"/", "handler":Handlers.main])
routes.append(["method":"post", "uri":"/invite", "handler":Handlers.invite])
routes.append(["method":"get", "uri":"/api/v1/stats", "handler":Handlers.members])
routes.append(["method":"get", "uri":"/badge.svg", "handler":Handlers.badge])

routes.append(["method":"get", "uri":"/**", "handler":PerfectHTTPServer.HTTPHandler.staticFiles,
               "documentRoot":"./webroot",
               "allowResponseFilters":true])

confData["servers"]?[0]["routes"] = routes

do {
	// Launch the servers based on the configuration data.
	try HTTPServer.launch(configurationData: confData)

} catch {
	fatalError("\(error)") // fatal error launching one of the servers
}
