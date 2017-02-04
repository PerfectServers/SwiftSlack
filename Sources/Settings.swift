//
//  Settings.swift
//  SwiftSlack
//
//  Created by Jonathan Guthrie on 2016-10-14.
//
//

import JSONConfig

// Function to read the JSON config file (ApplicationConfiguration.json) and set the apiToken
func getSettings() -> (String,String) {
	var apiToken = ""
	var slackName = ""

	if let config = JSONConfig(name: "\(FileRoot)ApplicationConfiguration.json") {
		let dict	= config.getValues()!
		apiToken	= dict["token"] as! String
		slackName	= dict["name"] as! String
	}
	return (apiToken, slackName)

}

