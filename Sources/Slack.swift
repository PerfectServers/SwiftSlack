//
//  Extras.swift
//  SwiftSlack
//
//  Created by Jonathan Guthrie on 2016-10-14.
//
//


import Foundation
import PerfectLib
import PerfectCURL
import cURL

class SlackAPI {
	var logo = ""
	var currentMembers = 0
	var activeMembers = 0

	init(){}

	/// INVITE user to slack
	func inviteToSlack(name: String, token: String, email: String) -> [String:Any] {
		let now = Date()
		let url = "https://\(name).slack.com/api/users.admin.invite?t=\(Int(now.timeIntervalSince1970))&token=\(token)&email=\(email)"
		let (_, data, _, _) = makeRequest(.get, url)
		return data
	}


	/// GET team info (i.e. logo)
	func teamInfo() {
		let url = "https://\(slackName).slack.com/api/team.info?token=\(apiToken)"
		let (_, data, _, _) = makeRequest(.get, url)
		logo = digIntoDictionary(mineFor: ["team", "icon", "image_132"], data: data) as! String
	}

	/// GET User List
	func userList() {
		let url = "https://\(slackName).slack.com/api/users.list?token=\(apiToken)&presence=true"
		let (_, data, _, _) = makeRequest(.get, url)


		if let mm = data["members"] {
			let mmm = mm as! [[String:Any]]
			let filtered = mmm.filter{
				$0["id"] as! String != "USLACKBOT" && $0["is_bot"] as! Bool == false && $0["deleted"] as! Bool == false
			}
			let active = filtered.filter{
				$0["presence"] as! String == "active"
			}

			currentMembers = filtered.count
			activeMembers = active.count
		}

	}

}
