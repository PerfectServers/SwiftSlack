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
	if let config = JSONConfig(name: "\(FileRoot)ApplicationConfiguration.json") {
		guard let dict = config.getValues(), let apiToken = dict["token"] else {
			print("Unable to get API Token")
			return ("","")
		}
		guard let slackName = dict["name"] else {
			print("Unable to get Slack Name")
			return ("","")
		}
		return (apiToken as! String,slackName as! String)
	} else {
		print("Unable to get Configuration")
	}
	return ("","") // defaults
}

