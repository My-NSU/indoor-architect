//
//  MapCanvasViewController.swift
//  Indoor Architect
//
//  Created by Dennis Prudlo on 2/15/20.
//  Copyright © 2020 Dennis Prudlo. All rights reserved.
//

import UIKit
import MapKit

class MapCanvasViewController: UIViewController {

	static let shared		= MapCanvasViewController()
	
	let canvas				= MCMapCanvas()
	
	let leadingToolPalette	= MCToolPalette(axis: .vertical)
	let topToolPalette		= MCToolPalette(axis: .horizontal)
	
	var project: IMDFProject!
	
    override func viewDidLoad() {
        super.viewDidLoad()
		
		view.addSubview(canvas)
		canvas.edgesToSuperview()
		
		canvas.addToolPalette(leadingToolPalette)
		canvas.addToolPalette(topToolPalette)

		configureTopToolPalette()
		configureLeadingToolPalette()
	}
	
	func configureTopToolPalette() -> Void {
		let closeToolStack = MCToolStack(forAxis: topToolPalette.axis)
		closeToolStack.addItem(MCToolStackItem(type: .close))
		
		topToolPalette.addToolStack(closeToolStack)
		
		let testStack = MCToolStack(forAxis: topToolPalette.axis)
		testStack.addItem(MCToolStackItem(type: .custom))
		testStack.addItem(MCToolStackItem(type: .custom))
		
		topToolPalette.addToolStack(testStack)
	}
	
	func configureLeadingToolPalette() -> Void {
		let toolStack = MCToolStack(forAxis: leadingToolPalette.axis)
		toolStack.addItem(MCToolStackItem(type: .drawingTool(type: .pointer)))
		toolStack.addItem(MCToolStackItem(type: .drawingTool(type: .polyline)))
		toolStack.addItem(MCToolStackItem(type: .drawingTool(type: .polygon)))
		toolStack.addItem(MCToolStackItem(type: .drawingTool(type: .measure)))
		
		leadingToolPalette.addToolStack(toolStack)
	}
	
	func present(forProject project: IMDFProject) -> Void {
		self.project = project
		self.modalPresentationStyle = .fullScreen
		Application.rootViewController.present(self, animated: true, completion: nil)
	}
}
