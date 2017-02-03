//
//  Settings.swift
//  SwiftSlack
//
//  Created by Jonathan Guthrie on 2016-10-14.
//
//

import JSONConfig

// Function to read the JSON config file (ApplicationConfiguration.json) and set the apiToken
func getSettings() -> (String,String,Int) {
	if let config = JSONConfig(name: "\(FileRoot)ApplicationConfiguration.json") {
		guard let dict = config.getValues(), let apiToken = dict["token"] else {
			print("Unable to get API Token")
			return ("","",8181)
		}
		guard let slackName = dict["name"] else {
			print("Unable to get Slack Name")
			return ("","",8181)
		}
		guard let port = dict["port"] as? Int else {
			return ("","",8181)
		}
		return (apiToken as! String,slackName as! String,port)
	} else {
		print("Unable to get Configuration")
	}
	return ("","",8181) // defaults
}

