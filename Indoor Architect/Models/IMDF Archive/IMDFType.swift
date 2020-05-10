//
//  IMDFType.swift
//  Indoor Architect
//
//  Created by Dennis Prudlo on 3/16/20.
//  Copyright © 2020 Dennis Prudlo. All rights reserved.
//

import Foundation

struct IMDFType {
	
	struct PointGeometry: Codable {
		let type: String = "Point"
		let coordinates: [Double]
	}
	
	struct PolygonGeometry: Codable {
		let type: String = "Polygon"
		let coordinates: [[[Double]]]
	}
	
	typealias Labels = Dictionary<String, String>
	
	typealias FeatureID = UUID
	typealias Hours = String
	typealias Website = String
	typealias Phone = String
	
	enum Accessibility: String, Codable {
		case assistedListening = "assisted.listening"
		case braille
		case hearing
		case hearingloop
		case signlanginterpreter
		case tactilepaving
		case tdd
		case trs
		case volume
		case wheelchair
	}
	
	enum Restriction: String, Codable {
		case employeesonly
		case restricted
	}
	
	enum VenueCategory: String, Codable {
		case airport
		case airportIntl = "airport.intl"
		case aquarium
		case businesscampus
		case casino
		case communitycenter
		case conventioncenter
		case governmentfacility
		case healthcarefacility
		case hotel
		case museum
		case parkingfacility
		case resort
		case retailstore
		case shoppingcenter
		case stadium
		case stripmall
		case theater
		case themepark
		case trainstation
		case transitstation
		case university
	}
	
	enum UnitCategory: String, Codable {
		case auditorium
		case brick
		case classroom
		case column
		case concrete
		case conferenceroom
		case drywall
		case elevator
		case escalator
		case fieldofplay
		case firstaid
		case fitnessroom
		case foodservice
		case footbridge
		case glass
		case huddleroom
		case kitchen
		case laboratory
		case library
		case lobby
		case lounge
		case mailroom
		case mothersroom
		case movietheater
		case movingwalkway
		case nonpublic
		case office
		case opentobelow
		case parking
		case phoneroom
		case platform
		case privatelounge
		case ramp
		case recreation
		case restroom
		case restroomFamily = "restroom.family"
		case restroomFemale = "restroom.female"
		case restroomMale = "restroom.male"
		case restroomTransgender = "restroom.transgender"
		case restroomUnisex = "restroom.unisex"
		case road
		case room
		case serverroom
		case shower
		case smokingarea
		case stairs
		case steps
		case storage
		case structure
		case theater
		case unenclosedarea
		case unspecified
		case vegetation
		case waitingroom
		case walkway
		case walkwayIsland = "walkway.island"
		case wood
	}
	
	/// A structure that defines the properties each feature has to describe its meta information
	struct EntityInformation: Codable {
		var comment: String?
	}
}
