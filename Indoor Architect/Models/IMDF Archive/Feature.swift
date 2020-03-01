//
//  Feature.swift
//  Indoor Architect
//
//  Created by Dennis Prudlo on 3/1/20.
//  Copyright © 2020 Dennis Prudlo. All rights reserved.
//

import Foundation
import MapKit

protocol DecodableFeature {
	init(feature: MKGeoJSONFeature) throws
}

class Feature<Properties: Codable>: NSObject, DecodableFeature {
	
	/// The globally unique feature id identifier
	let id: UUID
	
	/// The features feature type
	let properties: Properties
	
	/// The geometry object of the feature
	let geometry: [MKShape & MKGeoJSONObject]
	
	required init(feature: MKGeoJSONFeature) throws {
		guard let uuidString = feature.identifier, let uuid = UUID(uuidString: uuidString) else {
			throw IMDFDecodingError.malformedFeatureData
		}
		
		self.id = uuid
		
		if let propertiesData = feature.properties {
			let decoder = JSONDecoder()
			decoder.keyDecodingStrategy = .convertFromSnakeCase
			self.properties = try decoder.decode(Properties.self, from: propertiesData)
		} else {
			throw IMDFDecodingError.malformedFeatureData
		}
		
		self.geometry = feature.geometry
		
		super.init()
	}
}
