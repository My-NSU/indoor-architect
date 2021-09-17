//
//  MCPolygonRenderer.swift
//  Indoor Architect
//
//  Created by Dennis Prudlo on 3/17/20.
//  Copyright © 2020 Dennis Prudlo. All rights reserved.
//

import Foundation
import MapKit

class MCPolygonRenderer: MKPolygonRenderer, MCOverlayRenderer {
	
	var isCurrentlyDrawing: Bool = false
	
	init(overlay: MKOverlay, _ isCurrentlyDrawing: Bool) {
		super.init(polygon: overlay as! MKPolygon)
		
		self.isCurrentlyDrawing = isCurrentlyDrawing
		
		if isCurrentlyDrawing {
			strokeColor	= Color.currentDrawingTintColor
			fillColor	= Color.currentDrawingTintColor.withAlphaComponent(0.3)
			lineWidth	= Renderer.featureLineWidth
        } else if let unitOverlay = overlay as? IMDFUnitOverlay,
                  unitOverlay.unit.properties.category != .unspecified {
            strokeColor = UIColor.systemGreen
            fillColor   = UIColor.systemGreen.withAlphaComponent(0.3)
            lineWidth   = Renderer.featureLineWidth
		} else {
			strokeColor	= UIColor.systemGray
			fillColor	= UIColor.systemGray.withAlphaComponent(0.3)
			lineWidth	= Renderer.featureLineWidth
		}
	}
	
	override func draw(_ mapRect: MKMapRect, zoomScale: MKZoomScale, in context: CGContext) {
		super.draw(mapRect, zoomScale: zoomScale, in: context)
		
		//
		// Only proceed if the overlay is a currently drawing overlay
		if !isCurrentlyDrawing {
			return
		}
		
		//
		// Retrieve the points of the path
		let points = getPoints(of: path)
		
		//
		// Add the point mark of the last point in the path
		if let last = points.last {
			markEndpoint(last, for: zoomScale, in: context)
		}
	}
	
	override func createPath() {
		let path = CGMutablePath()
		
		var firstPoint: CGPoint?
		
		for index in 0..<polygon.pointCount {
			let point = self.point(for: polygon.points()[index])
			if path.isEmpty {
				firstPoint = point
				path.move(to: point)
			} else {
				path.addLine(to: point)
			}
		}
		
		if !isCurrentlyDrawing, let firstPoint = firstPoint {
			path.addLine(to: firstPoint)
		}
		
		self.path = path
	}
}
