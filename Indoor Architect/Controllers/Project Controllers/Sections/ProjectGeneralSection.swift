//
//  ProjectGeneralSection.swift
//  Indoor Architect
//
//  Created by Dennis Prudlo on 2/29/20.
//  Copyright © 2020 Dennis Prudlo. All rights reserved.
//

import UIKit

class ProjectGeneralSection: ProjectSection {
	
	let projectTitleCell		= TextInputTableViewCell(placeholder: Localizable.Project.projectTitle, maxLength: 50)
	let projectDescriptionCell	= TextInputTableViewCell(placeholder: Localizable.Project.projectDescription)
	let projectClientCell		= TextInputTableViewCell(placeholder: Localizable.Project.projectClient)
	
	override init() {
		super.init()
		
		cells.append(projectTitleCell)
		cells.append(projectDescriptionCell)
		cells.append(projectClientCell)
		
		projectTitleCell.textField.addTarget(self,			action: #selector(didChangeTitle),			for: .editingChanged)
		projectDescriptionCell.textField.addTarget(self,	action: #selector(didChangeDescription),	for: .editingChanged)
		projectClientCell.textField.addTarget(self,			action: #selector(didChangeClient),			for: .editingChanged)
	}
	
	/// Updates the project data after the project title was changed
	/// - Parameter sender: The text field that was edited
	@objc func didChangeTitle(_ sender: UITextField) -> Void {
		guard let title = sender.text, title.count > 0 else {
			return
		}
		
		delegate?.title = title
		
		Application.currentProject.manifest.title = title
		Application.currentProject.hasChangesToStoredVersion = true
		delegate?.projectDetailsDidChange()
	}
	
	/// Updates the project data after the description was changed
	/// - Parameter sender: The text field that was edited
	@objc func didChangeDescription(_ sender: UITextField) -> Void {
		Application.currentProject.manifest.description = sender.text
		Application.currentProject.hasChangesToStoredVersion = true
		delegate?.projectDetailsDidChange()
	}
	
	/// Updates the project data after the client title was changed
	/// - Parameter sender: The text field that was edited
	@objc func didChangeClient(_ sender: UITextField) -> Void {
		Application.currentProject.manifest.client = sender.text
		Application.currentProject.hasChangesToStoredVersion = true
		delegate?.projectDetailsDidChange()
	}
	
	override func initialize() {
		projectTitleCell.setText(Application.currentProject.manifest.title)
		projectDescriptionCell.setText(Application.currentProject.manifest.description)
		projectClientCell.setText(Application.currentProject.manifest.client)
	}
}
