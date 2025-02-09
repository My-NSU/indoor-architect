//
//  ProjectExplorerHandler.swift
//  Indoor Architect
//
//  Created by Dennis Prudlo on 2/15/20.
//  Copyright © 2020 Dennis Prudlo. All rights reserved.
//

import UIKit
import SafariServices

/// The `ProjectExplorerHandler` is responsible for inserting and removing cells that are visible in the project explorer.
/// It manages the sections and the cell behavior
class ProjectExplorerHandler: NSObject, UITableViewDelegate, UITableViewDataSource, SFSafariViewControllerDelegate {
	
	static let shared: ProjectExplorerHandler = ProjectExplorerHandler()
	
	/// The section type defines a whole section in the project explorer. Each section has a title, a text for when the section has no items, an array with all
	/// cells currently visible in the section and a function that reloads the section data
	typealias Section = (title: String, emptyTitle: String, cells: [UITableViewCell], exposed: Bool, reload: () -> [UITableViewCell])
	
	/// The array that holds all sections of the project explorer
	var sections: [Section] = []
	
	/// A reference to the tableView that is being handled
	var tableView: UITableView!
	
	/// A category reference for the different type of sections
	enum SectionCategory: Int {
		case projects
		case guides
		case resources
	}
	
	let resources = [
		(title: "IMDF Documentation", url: URL(string: "https://register.apple.com/resources/imdf/Reference/"), icon: Icon.link),
		(title: "Human Interface Guidelines", url: URL(string: "https://developer.apple.com/design/human-interface-guidelines/maps/overview/indoor-maps/"), icon: Icon.link)
	]
	
	override init() {
		super.init()
		
		let projects: Section = (
			title:		Localizable.ProjectExplorer.sectionTitleProjects,
			emptyTitle: Localizable.ProjectExplorer.sectionEmptyProjects,
			cells:		[],
			exposed:	true,
			reload:	{
				var cells: [UITableViewCell] = []
				IMDFProject.projects.forEach { (project) in
					cells.append(ProjectExplorerProjectTableViewCell(project: project))
				}
				return cells
			}
		)
		
		let guides: Section = (
			title:		Localizable.ProjectExplorer.sectionTitleGuides,
			emptyTitle: Localizable.ProjectExplorer.sectionEmptyGuides,
			cells:		[],
			exposed:	true,
			reload:	{
				return []
			}
		)
		
		let resources: Section = (
			title:		Localizable.ProjectExplorer.sectionTitleResources,
			emptyTitle: Localizable.ProjectExplorer.sectionEmptyResources,
			cells:		[],
			exposed:	true,
			reload:	{
				var cells: [UITableViewCell] = []
				for resource in self.resources {
					let cell = LeadingIconTableViewCell(title: resource.title, icon: resource.icon)
					cells.append(cell)
				}
				return cells
			}
		)
		
		//
		// Add the different section categories to the sections array
		sections.append(projects)
		sections.append(guides)
		sections.append(resources)
		
		//
		// Reload all sections so its data can be set
		reloadSections()
	}
	
	/// Prepares the table view to animate the insertion of an item
	/// - Parameters:
	///   - indexPath: The index path where the item is being inserted
	///   - animation: The animation for the insertion
	func insert(at indexPath: IndexPath, with animation: UITableView.RowAnimation) -> Void {
		if sections.count <= indexPath.section {
			return
		}
		
		tableView.beginUpdates()
		
		if sections[indexPath.section].cells.count == 0 {
			tableView.deleteRows(at: [IndexPath(row: 0, section: indexPath.section)], with: animation)
		}
		tableView.insertRows(at: [indexPath], with: animation)
		
		reloadSections(justFor: indexPath.section)
		
		tableView.endUpdates()
	}
	
	/// Preparest the table view to animate the deletion of an item
	/// - Parameters:
	///   - indexPath: The index path where the item is being deleted from
	///   - animation: The animation for the deletion
	func delete(at indexPath: IndexPath, with animation: UITableView.RowAnimation) -> Void {
		if sections.count <= indexPath.section {
			return
		}
		
		tableView.beginUpdates()
		tableView.deleteRows(at: [indexPath], with: .left)
		reloadSections(justFor: indexPath.section)
		
		if sections[indexPath.section].cells.count == 0 {
			tableView.insertRows(at: [indexPath], with: animation)
		}
		
		tableView.endUpdates()
	}
	
	/// Reloads the table view data
	func reloadData() -> Void {
		reloadSections(justFor: SectionCategory.projects.rawValue)
		tableView.reloadData()
	}
	
	/// Reloads the data for the sections or a single section in particular
	/// - Parameter section: The id of the section if just one section should reload its data
	private func reloadSections(justFor section: Int? = nil) -> Void {
		if section != nil && sections.count > section! {
			sections[section!].cells = sections[section!].reload()
			return
		}
		
		for section in 0..<sections.count {
			sections[section].cells = sections[section].reload()
		}
	}
	
	func indexPath(for project: IMDFProject) -> IndexPath? {
		for (index, arrayProject) in IMDFProject.projects.enumerated() {
			if (arrayProject.manifest.uuid == project.manifest.uuid) {
				return IndexPath(row: index, section: SectionCategory.projects.rawValue)
			}
		}
		
		return nil
	}
	
	func numberOfSections(in tableView: UITableView) -> Int {
		return sections.count
	}
	
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		
		//
		// If the section is not exposed all cells are hidden
		if !sections[section].exposed {
			return 0
		}
		
		let count = sections[section].cells.count
		return count == 0 ? 1 : count
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let count = sections[indexPath.section].cells.count
		if count > 0 {
			return sections[indexPath.section].cells[indexPath.row]
		} else {
			return ProjectExplorerPlaceholderCell(title: sections[indexPath.section].emptyTitle)
		}
	}
	
	func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
		if sections[indexPath.section].cells.count == 0 {
			return nil
		}

		if indexPath.section == SectionCategory.projects.rawValue {
			let canvasAction = UIContextualAction(style: .normal, title: nil, handler: { (action, view, completion) in
				
				let project = IMDFProject.projects[indexPath.row]
				
				//
				// When using the leading swip option to navigate into one projects map canvas
				// the current project needs to be set for the reference
				Application.currentProject = project
				
				(MapCanvasViewController()).presentForSelectedProject {
					let projectController		= ProjectController(style: .insetGrouped)
					let navigationController	= UINavigationController(rootViewController: projectController)
					Application.rootController.showDetailViewController(navigationController, sender: nil)
				}
				
				completion(true)
			})
			canvasAction.backgroundColor = Color.indoorMapEdit
			canvasAction.image = Icon.map
			
			return UISwipeActionsConfiguration(actions: [canvasAction])
		}
		
		return nil
	}

	func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
		if sections[indexPath.section].cells.count == 0 {
			return nil
		}
		
		if indexPath.section == SectionCategory.projects.rawValue {
			let deleteAction = UIContextualAction(style: .destructive, title: nil, handler: { (action, view, completion) in
				if indexPath.row >= IMDFProject.projects.count {
					completion(false)
					return
				}
				
				let project = IMDFProject.projects[indexPath.row]
				
				guard let _ = try? project.delete() else {
					completion(false)
					return
				}
				
				IMDFProject.projects.removeAll { (imdfProject) -> Bool in
					return imdfProject.manifest.uuid == project.manifest.uuid
				}
				self.delete(at: indexPath, with: .left)
				
				if project.manifest.uuid == Application.currentProject.manifest.uuid {
					Application.rootController.showDetailViewController(WelcomeController(), sender: nil)
				}
				
				completion(true)
			})
			deleteAction.backgroundColor = Color.primary
			deleteAction.image = Icon.trash
			
			let exportAction = UIContextualAction(style: .normal, title: nil, handler: { (action, view, completion) in
                if indexPath.row >= IMDFProject.projects.count {
                    completion(false)
                    return
                }
                
                let project = IMDFProject.projects[indexPath.row]
                
                guard let url = project.exportIMDFArchive() else {
                    completion(false)
                    return
                }
                    
                let activityViewController = UIActivityViewController(
                    activityItems: [url], applicationActivities: nil)
                Application.rootController.present(
                    activityViewController, animated: true)
                
                completion(true)
			})
			exportAction.backgroundColor = Color.indoorMapExport
			exportAction.image = Icon.download
			
			return UISwipeActionsConfiguration(actions: [deleteAction, exportAction])
		}

		return nil
	}
	
	func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
		return ProjectExplorerSectionHeaderView(title: sections[section].title) { (isContentExposed) in
			self.sections[section].exposed = isContentExposed
			
			//
			// We retrieve the possible index paths for all cells in that section
			var indexPaths: [IndexPath] = []
			for row in 0..<self.sections[section].cells.count {
				indexPaths.append(IndexPath(row: row, section: section))
			}
			
			//
			// If the index path array is empty there are no cells in the section
			// meaning there is the palceholder cell visible (at index path row 0)
			if indexPaths.count == 0 {
				indexPaths.append(IndexPath(row: 0, section: section))
			}
			
			tableView.beginUpdates()
			if isContentExposed {
				tableView.insertRows(at: indexPaths, with: .fade)
			} else {
				tableView.deleteRows(at: indexPaths, with: .fade)
			}
			tableView.endUpdates()
		}
	}

	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		if indexPath.section == SectionCategory.projects.rawValue && sections[indexPath.section].cells.count > 0 {
			let project = IMDFProject.projects[indexPath.row]
			
			Application.currentProject = project
			let projectController = ProjectController(style: .insetGrouped)
			
			let navigationController = UINavigationController(rootViewController: projectController)
			Application.rootController.showDetailViewController(navigationController, sender: nil)
		}
		
		if indexPath.section == SectionCategory.resources.rawValue {
			guard let url = self.resources[indexPath.row].url else {
				return
			}
			
			Application.currentProject = nil
			
			let safariViewController = SFSafariViewController(url: url)
			safariViewController.preferredControlTintColor	= Color.primary
			safariViewController.preferredBarTintColor		= .systemBackground
			safariViewController.dismissButtonStyle			= .close
			safariViewController.delegate					= self
			
			safariViewController.view.isOpaque = false
			
			Application.rootController.show(safariViewController, sender: nil)
		}
	}
	
	func safariViewControllerDidFinish(_ controller: SFSafariViewController) {
		Application.rootController.showDetailViewController(WelcomeController(), sender: nil)
		Application.masterController.deselectSelectedRow()
	}
}
