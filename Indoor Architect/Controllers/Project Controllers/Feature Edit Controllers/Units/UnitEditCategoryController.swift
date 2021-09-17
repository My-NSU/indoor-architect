//
//  FeatureUnitCategoriyPickerController.swift
//  Indoor Architect
//
//  Created by Dennis Prudlo on 5/12/20.
//  Copyright © 2020 Dennis Prudlo. All rights reserved.
//

import UIKit

protocol UnitEditCategoryControllerDelegate {
	func unitCategory(_ controller: UnitEditCategoryController, didPick category: IMDFType.UnitCategory) -> Void
}

class UnitEditCategoryController: IATableViewController {

    private let favoriteCategroies: Set<IMDFType.UnitCategory> = [
        .auditorium, .classroom, .foodservice, .laboratory,
        .nonpublic, .office, .room, .unspecified
    ]
    
	/// A mapping dictionary to store the category value for each cell
	var categoryCells: [UITableViewCell: IMDFType.UnitCategory] = [:]
	
	/// The currently selected category on initialization
	var currentCategory: IMDFType.UnitCategory = .unspecified
	
	/// The delegate that handles the selection
	var delegate: UnitEditCategoryControllerDelegate?
	
    override func viewDidLoad() {
        super.viewDidLoad()
		
		title = Localizable.Feature.selectCategory
		
		//
		// In this case for better readability we use the separator line between the cells
		tableView.separatorStyle = .singleLine
		
		//
		// Compose the cells for the categories
		IMDFType.UnitCategory.allCases.forEach { (category) in
			let categoryCell = UITableViewCell(style: .default, reuseIdentifier: nil)
			categoryCell.textLabel?.text	= Localizable.IMDF.unitCategory(category)
			categoryCell.accessoryType		= category == currentCategory ? .checkmark : .none
			categoryCell.tintColor			= Color.primary
			
			categoryCells[categoryCell] = category
		}
		
		//
		// Add the accessibility cells
        tableViewSections.append((
            title: "Favorites",
            description: nil,
            cells: categoryCells
                .filter({ favoriteCategroies.contains($0.value) })
                .sorted(by: { $0.value.rawValue < $1.value.rawValue })
                .map({ $0.key })
        ))
        tableViewSections.append((
            title: nil,
            description: nil,
            cells: categoryCells
                .filter({ !favoriteCategroies.contains($0.value) })
                .sorted(by: { $0.value.rawValue < $1.value.rawValue })
                .map({ $0.key })
        ))
    }
	
	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		guard let cell = tableView.cellForRow(at: indexPath), let category = categoryCells[cell] else {
			delegate?.unitCategory(self, didPick: self.currentCategory)
			return
		}
	
		delegate?.unitCategory(self, didPick: category)
	}
}
