//
//  FeatureEditController.swift
//  Indoor Architect
//
//  Created by Dennis Prudlo on 5/2/20.
//  Copyright © 2020 Dennis Prudlo. All rights reserved.
//

import UIKit

protocol FeatureEditControllerDelegate {
	
	/// Tells the delegate, that the feature controller is about to be dismissed. Perform saving here.
	func willCloseEditController() -> Void
}

class FeatureEditController: IATableViewController {
	
	/// A reference to the map canvas if the edit controller was opened inside a map canvas
	var canvas: MCMapCanvas?
	
	/// A reference to the features id
	var featureId: UUID!
	
	/// A reference to the features id
	var featureType: ProjectManager.ArchiveFeature!

	/// The cell which displays the feature id
	let featureIdCell		= UITableViewCell(style: .default, reuseIdentifier: nil)
	
	/// The cell which contains the textField to edit the feature comment
	let commentCell			= TextInputTableViewCell(placeholder: Localizable.Feature.comment)
	
	/// A reference to the specific feature edit controller
	var featureController: FeatureEditControllerDelegate?
	
	/// An array which stores all right bar button items that are currently displayed
	private var rightBarButtonItems: [UIBarButtonItem] = []
	
    override func viewDidLoad() {
        super.viewDidLoad()
		
		//
		// Use large titles when editing a feature but only when opened from the canvas
		if let _ = canvas {
			navigationController?.navigationBar.prefersLargeTitles = true
		}
		
		//
		// Add the delete feature and close controller buttons
		navigationItem.leftBarButtonItem	= UIBarButtonItem(barButtonSystemItem: .close, target: self, action: #selector(closeEditController(_:)))
		addNavigationBarButton(UIBarButtonItem(barButtonSystemItem: .trash, target: self, action: #selector(didTapRemoveFeature(_:))), animated: true)
		
		//
		// Adjust the table view cells row height to the content
		tableView.rowHeight = UITableView.automaticDimension
		
		//
		// Format the feature id cell
		featureIdCell.selectionStyle		= .none
		featureIdCell.textLabel?.isEnabled	= false
		featureIdCell.textLabel?.font		= featureIdCell.textLabel?.font.monospaced()
		
		//
		// Append the feature id cell
		tableViewSections.append((
			title: "Feature ID",
			description: nil,
			cells: [featureIdCell]
		))
		
		//
		// Append further information meta data cells
		tableViewSections.append((
			title: nil,
			description: nil,
			cells: [commentCell]
		))
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        featureController?.willCloseEditController()
        canvas?.renderFeatures()
    }
	
	/// Prepares the feature edit controller for the feature
	/// - Parameters:
	///   - id: The id of the feature to display
	///   - information: The information meta data set to display
	///   - featureController: The reference to the specific feature controller for event propagation
	func prepareForFeature(with id: UUID, type: ProjectManager.ArchiveFeature, information: IMDFType.EntityInformation?, from featureController: FeatureEditControllerDelegate) -> Void {
		self.featureController			= featureController
		
		featureId						= id
		featureType						= type
		featureIdCell.textLabel?.text	= id.uuidString
		commentCell.textField.text		= information?.comment
	}
	
	/// Triggers the willCloseEditController event for the specific feature edit controller to perform saving
	/// and dismisses the controller afterwards
	/// - Parameter barButtonItem: The barButtonItem that was tapped to trigger the event
	@objc func closeEditController(_ barButtonItem: UIBarButtonItem) -> Void {
		dismiss(animated: true, completion: nil)
	}
	
	/// Shows a confirmation dialog whether the user really wants to remove the feature from the project
	/// - Parameter barButtonItem: The barButtonItem that was tapped to trigger the event
	@objc func didTapRemoveFeature(_ barButtonItem: UIBarButtonItem) -> Void {
		let confirmationController = UIAlertController(title: Localizable.General.actionConfirmation, message: Localizable.Feature.removeAlertDescription, preferredStyle: .alert)
		confirmationController.addAction(UIAlertAction(title: Localizable.General.remove, style: .destructive, handler: { (action) in
			
			//
			// Triggers the event that performs deleting of the feature
			Application.currentProject.imdfArchive.removeFeature(with: self.featureId)
			try? Application.currentProject.imdfArchive.save()
			
			//
			// If the canvas property is set and the edit controller was opened in a canvas session
			// The overlays should be regenerated
			self.canvas?.renderFeatures()
			
			//
			// Dismiss the controller after the feature was deleted
			self.dismiss(animated: true, completion: nil)
		}))
		
		confirmationController.addAction(UIAlertAction(title: Localizable.General.cancel, style: .cancel, handler: nil))
		
		//
		// Present the confirmation controller
		present(confirmationController, animated: true, completion: nil)
	}
	
	/// Adds a new bar button item to the navigation bar
	/// - Parameters:
	///   - barButtonItem: The item to add
	///   - animated: whether to animate the insert
	func addNavigationBarButton(_ barButtonItem: UIBarButtonItem, animated: Bool) -> Void {
		rightBarButtonItems.append(barButtonItem)
		navigationItem.setRightBarButtonItems(rightBarButtonItems, animated: animated)
	}
}
