//
//  Handlers.swift
//  SwiftSlack
//
//  Created by Jonathan Guthrie on 2016-10-14.
//
//

import PerfectLib
import PerfectHTTP
import PerfectMustache
import SwiftString


class Handlers {

	static func main(data: [String:Any]) throws -> RequestHandler {
		return {
			request, response in
			let context: [String : Any] = ["title": slackName, "active": slackObj.activeMembers, "total": slackObj.currentMembers, "slackname": slackName, "logo": slackObj.logo]
			response.render(template: "index", context: context)
		}
	}

	static func invite(data: [String:Any]) throws -> RequestHandler {
		let slackAPI = SlackAPI()
		return {
			request, response in
			guard let _ = request.postBodyString else {
				do {
					response.status = .badRequest
					try response.setBody(json: ["msg":"No valid email provided"])
				} catch {
					print(error)
				}
				response.completed()
				return
			}
			do {
				let incoming = try request.postBodyString?.jsonDecode() as? [String:Any]
				let email = incoming?["email"] as! String
				if email.isValidEmail() {
					// ping slack...
					let returned = slackAPI.inviteToSlack(name: slackName, token: apiToken, email: email)
					if returned["ok"] as! Bool {
						try response.setBody(json: ["msg": "Success!"])
					} else {
						try response.setBody(json: ["msg": returned["error"] as! String])
					}
				} else {
					try response.setBody(json: ["msg":"Please supply a valid email"])
				}
			} catch {
				print(error)
			}
			response.completed()

		}
	}

	static func members(data: [String:Any]) throws -> RequestHandler {
		return {
			request, response in
			do {
				slackObj.userList()
				try response.setBody(json: ["total":slackObj.currentMembers, "active":slackObj.activeMembers])
			} catch {
				print(error)
			}
			response.completed()

		}
	}


}
