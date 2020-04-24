//
//  ProjectMetaInfoSection.swift
//  Indoor Architect
//
//  Created by Dennis Prudlo on 2/29/20.
//  Copyright © 2020 Dennis Prudlo. All rights reserved.
//

import UIKit

class ProjectMetaInfoSection: ProjectSection {
	
	var archive: IMDFArchive?
	
	let createdAtCell 			= UITableViewCell(style: .value1, reuseIdentifier: nil)
	let updatedAtCell			= UITableViewCell(style: .value1, reuseIdentifier: nil)
	let customExtensionsCell	= UITableViewCell(style: .value1, reuseIdentifier: nil)
	
	override init() {
		super.init()
		cells.append(createdAtCell)
		cells.append(updatedAtCell)
		cells.append(customExtensionsCell)
		
		createdAtCell.selectionStyle	= .none
		createdAtCell.textLabel?.text	= Localizable.Project.created
		createdAtCell.backgroundColor	= Color.lightStyleCellBackground
		
		updatedAtCell.selectionStyle	= .none
		updatedAtCell.textLabel?.text	= Localizable.Project.updated
		updatedAtCell.backgroundColor	= Color.lightStyleCellBackground
		
		customExtensionsCell.textLabel?.text	= Localizable.Extension.title
		customExtensionsCell.backgroundColor	= Color.lightStyleCellBackground
		customExtensionsCell.accessoryType		= .disclosureIndicator
	}
	
	private func prettyDate(_ date: Date?) -> String {
		guard let date = date else {
			return Localizable.General.missingInformation
		}
		
		let dateFormatter = DateFormatter()
		dateFormatter.dateStyle = .long
		dateFormatter.timeStyle = .medium
		return dateFormatter.string(from: date)
	}
	
	func resetExtensionCount() -> Void {
		guard let extensionCount = archive?.manifest.extensions?.count else {
			customExtensionsCell.detailTextLabel?.text = Localizable.General.none
			return
		}
		
		if extensionCount == 0 {
			customExtensionsCell.detailTextLabel?.text = Localizable.General.none
			return
		}
		
		if extensionCount == 1 {
			customExtensionsCell.detailTextLabel?.text = archive?.manifest.extensions?.first?.identifier
		} else {
			customExtensionsCell.detailTextLabel?.text = "\(extensionCount)"
		}
	}
	
	func setCreatedAt(date: Date?) -> Void {
		createdAtCell.detailTextLabel?.text = prettyDate(date)
	}
	
	func setUpdatedAt(date: Date?) -> Void {
		updatedAtCell.detailTextLabel?.text = prettyDate(date)
	}
	
	override func didSelectRow(at index: Int) {
		if cells[index] == customExtensionsCell {
			let projectExtensionsController = ProjectExtensionController(style: .insetGrouped)
			projectExtensionsController.project = delegate?.project
			delegate?.navigationController?.pushViewController(projectExtensionsController, animated: true)
		}
	}
	
	override func initialize() {
		setCreatedAt(date: delegate?.project.manifest.createdAt)
		setUpdatedAt(date: delegate?.project.manifest.updatedAt)
		archive = delegate?.project.imdfArchive
		reloadOnAppear()
	}
	
	override func reloadOnAppear() {
		resetExtensionCount()
	}
}
