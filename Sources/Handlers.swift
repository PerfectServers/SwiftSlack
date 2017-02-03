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

/*
These are the main Mustache handlers.
They are called as the handlers from the routes in main.swift
*/


//struct MainHandler: MustachePageHandler { // all template handlers must inherit from PageHandler
//	// This is the function which all handlers must impliment.
//	// It is called by the system to allow the handler to return the set of values which will be used when populating the template.
//	// - parameter context: The MustacheWebEvaluationContext which provides access to the HTTPRequest containing all the information pertaining to the request
//	// - parameter collector: The MustacheEvaluationOutputCollector which can be used to adjust the template output. For example a `defaultEncodingFunc` could be installed to change how outgoing values are encoded.
//
//	func extendValuesForResponse(context contxt: MustacheWebEvaluationContext, collector: MustacheEvaluationOutputCollector) {
//		var values = MustacheEvaluationContext.MapType()
//
//		values["title"] = slackName
//		values["active"] = 1
//		values["total"] = 2
//		values["slackname"] = slackName
//
//		contxt.extendValues(with: values)
//		do {
//			try contxt.requestCompleted(withCollector: collector)
//		} catch {
//			let response = contxt.webResponse
//			response.status = .internalServerError
//			response.appendBody(string: "\(error)")
//			response.completed()
//		}
//	}
//}



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
