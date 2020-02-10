//
//  Application.swift
//  Indoor Architect
//
//  Created by Dennis Prudlo on 2/9/20.
//  Copyright © 2020 Dennis Prudlo. All rights reserved.
//

import Foundation

struct Application {
	
	/// The application title used all over the app
	static let title		= "Indoor Architect"
	
	/// The applications current version
	static let version		= Bundle.main.infoDictionary?["CFBundleShortVersionString"] as! String
	
	/// The application current build number
	static let build		= Int(Bundle.main.infoDictionary?["CFBundleVersion"] as! String) ?? 0
	
	/// The currently used version of the indoor mapping data format
	static let imdfVersion	= "1.0.0.rc.1"
}
