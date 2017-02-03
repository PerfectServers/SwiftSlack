//
//  makeRequest.swift
//  Borrowed from Perfect-Authentication
//
//  Created by Jonathan Guthrie on 2017-01-18.
//	Branched from CouchDB Version


import PerfectLib
import PerfectCURL
import cURL
import SwiftString
import PerfectHTTP


extension SlackAPI {

	func digIntoDictionary(mineFor: [String], data: [String: Any]) -> Any {
		if mineFor.count == 0 { return "" }
		for (key,value) in data {
			if key == mineFor[0] {
				var newMine = mineFor
				newMine.removeFirst()
				if newMine.count == 0 {
					return value
				} else if value is [String: Any] {
					return digIntoDictionary(mineFor: newMine, data: value as! [String : Any])
				}
			}
		}
		return ""
	}


	/// The function that triggers the specific interaction with a remote server
	/// Parameters:
	/// - method: The HTTP Method enum, i.e. .get, .post
	/// - route: The route required
	/// - body: The JSON formatted sring to sent to the server
	/// Response:
	/// (HTTPResponseStatus, "data" - [String:Any], "raw response" - [String:Any], HTTPHeaderParser)
	func makeRequest(
		_ method: HTTPMethod,
		_ url: String,
		body: String = "",
		encoding: String = "JSON",
		bearerToken: String = ""
		) -> (Int, [String:Any], [String:Any], HTTPHeaderParser) {

		let curlObject = CURL(url: url)
		curlObject.setOption(CURLOPT_HTTPHEADER, s: "Accept: application/json")
		curlObject.setOption(CURLOPT_HTTPHEADER, s: "Cache-Control: no-cache")
		curlObject.setOption(CURLOPT_USERAGENT, s: "PerfectAPI2.0")

		if !bearerToken.isEmpty {
			curlObject.setOption(CURLOPT_HTTPHEADER, s: "Authorization: Bearer \(bearerToken)")
		}

		switch method {
		case .post :
			let byteArray = [UInt8](body.utf8)
			curlObject.setOption(CURLOPT_POST, int: 1)
			curlObject.setOption(CURLOPT_POSTFIELDSIZE, int: byteArray.count)
			curlObject.setOption(CURLOPT_COPYPOSTFIELDS, v: UnsafeMutablePointer(mutating: byteArray))

			if encoding == "form" {
				curlObject.setOption(CURLOPT_HTTPHEADER, s: "Content-Type: application/x-www-form-urlencoded")
			} else {
				curlObject.setOption(CURLOPT_HTTPHEADER, s: "Content-Type: application/json")
			}

		default: //.get :
			curlObject.setOption(CURLOPT_HTTPGET, int: 1)
		}


		var header = [UInt8]()
		var bodyIn = [UInt8]()

		var code = 0
		var data = [String: Any]()
		var raw = [String: Any]()

		var perf = curlObject.perform()
		defer { curlObject.close() }

		while perf.0 {
			if let h = perf.2 {
				header.append(contentsOf: h)
			}
			if let b = perf.3 {
				bodyIn.append(contentsOf: b)
			}
			perf = curlObject.perform()
		}
		if let h = perf.2 {
			header.append(contentsOf: h)
		}
		if let b = perf.3 {
			bodyIn.append(contentsOf: b)
		}
		let _ = perf.1

		// Parsing now:

		// assember the header from a binary byte array to a string
		let headerStr = String(bytes: header, encoding: String.Encoding.utf8)

		// parse the header
		let http = HTTPHeaderParser(header:headerStr!)

		// assamble the body from a binary byte array to a string
		let content = String(bytes:bodyIn, encoding:String.Encoding.utf8)

		// prepare the failsafe content.
		raw = ["status": http.status, "header": headerStr!, "body": content!]

		// parse the body data into a json convertible
		do {
			if (content?.characters.count)! > 0 {
				if (content?.startsWith("["))! {
					let arr = try content?.jsonDecode() as! [Any]
					data["response"] = arr
				} else {
					data = try content?.jsonDecode() as! [String : Any]
				}
			}
			return (http.code, data, raw, http)
		} catch {
			return (http.code, [:], raw, http)
		}
	}
}


//
//  Extensions.swift
//  Perfect Authentication / OAuth2
//
//  Created by Jonathan Guthrie on 2016-10-24.
//
//

import SwiftString
import PerfectLib

func urlencode(dict: [String: String]) -> String {

	let httpBody = dict.map { (key, value) in
		return key + "=" + value
		}
		.joined(separator: "&")
	//		.data(using: .utf8)

	return httpBody

}

/// A lightweight HTTP Response Header Parser
/// transform the header into a dictionary with http status code
class HTTPHeaderParser {

	private var _dic: [String:String] = [:]
	private var _version: String? = nil
	private var _code : Int = -1
	private var _status: String? = nil

	/// HTTPHeaderParser default constructor
	/// - header: the HTTP response header string
	public init(header: String) {

		// parse the header into lines,
		_ = header.components(separatedBy: .newlines)
			// remove all null lines
			.filter{!$0.isEmpty}
			// map each line into the dictionary
			.map{

				// most HTTP header lines have a patter of "variable name: value"
				let range = $0.range(of: ":")

				if (range == nil && $0.hasPrefix("HTTP/")) {
					// except the first line, typically "HTTP/1.0 200 OK", so split it first
					let http = $0.tokenize()

					// parse the tokens
					_version = http[0].trimmed()
					_code = http[1].toInt()!
					_status = http[2].trimmed()
				} else {

					// split the line into a dictionary item expression
					//	let key = $0.left(range)
					//	let val = $0.right(range).trimmed()
					let key = $0.substring(to: (range?.upperBound)!)
					let val = $0.substring(from: (range?.lowerBound)!).trimmed()

					// insert or update the dictionary with this item
					_dic.updateValue(val, forKey: key)
				}
		}
	}

	/// HTTP response header information by keywords
	public var variables: [String:String] {
		get { return _dic }
	}

	/// The HTTP response code, e.g.,, HTTP/1.1 200 OK -> let code = 200
	public var code: Int {
		get { return _code }
	}

	/// The HTTP response code, e.g.,, HTTP/1.1 200 OK -> let status = "OK"
	public var status: String {
		get { return _status ?? "" }
	}

	/// The HTTP response code, e.g.,, HTTP/1.1 200 OK -> let version = "HTTP/1.1"
	public var version: String {
		get { return _version ?? "" }
	}
}
