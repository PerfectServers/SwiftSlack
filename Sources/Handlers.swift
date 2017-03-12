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
						var str = returned["error"] as! String
						str = str.replacingOccurrences(of: "_", with: " ")
						try response.setBody(json: ["msg": "Error: \(str)"])
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

	static func badge(data: [String:Any]) throws -> RequestHandler {
		return {
			request, response in

			let svg = "<svg xmlns=\"http://www.w3.org/2000/svg\" width=\"108\" height=\"20\"><rect rx=\"3\" width=\"108\" height=\"20\" fill=\"#555\"></rect><rect rx=\"3\" x=\"47\" width=\"61\" height=\"20\" fill=\"#E01563\"></rect><path d=\"M47 0h4v20h-4z\" fill=\"#E01563\"></path><g text-anchor=\"middle\" font-family=\"Verdana\" font-size=\"11\"><text fill=\"#010101\" fill-opacity=\".3\" x=\"24\" y=\"15\">slack</text><text fill=\"#fff\" x=\"24\" y=\"14\">slack</text><text fill=\"#010101\" fill-opacity=\".3\" x=\"78\" y=\"15\">\(slackObj.activeMembers)/\(slackObj.currentMembers)</text><text fill=\"#fff\" x=\"78\" y=\"14\">\(slackObj.activeMembers)/\(slackObj.currentMembers)</text></g></svg>"
			response.setBody(string: svg)
			response.setHeader(.contentType, value: "image/svg+xml")
			response.completed()
		}
	}

}
