//
//  ProjectAddressEditController.swift
//  Indoor Architect
//
//  Created by Dennis Prudlo on 3/1/20.
//  Copyright © 2020 Dennis Prudlo. All rights reserved.
//

import UIKit
import MapKit

class ProjectAddressEditController: ComposePopoverController {
	
	var displayController: ProjectAddressController!
	var shouldRenderToCreate: Bool = false
	var addressToEdit: Address?
	
	let featureIdCell			= UITableViewCell(style: .default, reuseIdentifier: nil)
	let addressCell				= TextInputTableViewCell(placeholder: Localizable.Project.Address.placeholderAddress)
	let countryCell				= UITableViewCell(style: .value1, reuseIdentifier: nil)
	let provinceCell			= UITableViewCell(style: .value1, reuseIdentifier: nil)
	let localityCell			= TextInputTableViewCell(placeholder: Localizable.Project.Address.placeholderLocality)
	let postalCodeCell			= TextInputTableViewCell(placeholder: Localizable.Project.Address.placeholderCode)
	let postalCodeExtensionCell	= TextInputTableViewCell(placeholder: Localizable.Project.Address.placeholderExtension)
	let postalCodeVanityCell	= TextInputTableViewCell(placeholder: Localizable.Project.Address.placeholderVanity)
	let unitCell				= TextInputTableViewCell(placeholder: Localizable.Project.Address.placeholderUnit)
	
	var countryData: Address.LocalityCodeCombination? {
		didSet {
			provinceData = nil
		}
	}
	var provinceData: Address.LocalityCodeCombination?
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		tableView.rowHeight = UITableView.automaticDimension
		
		//
		// Set the confirm button title
		confirmButtonTitle = shouldRenderToCreate ? Localizable.General.add : Localizable.General.remove
		
		//
		// Set the controller title
		title = shouldRenderToCreate ? Localizable.Project.Address.addAddress : Localizable.Project.Address.editAddress
		
		//
		// Configure table view cells
		countryCell.textLabel?.text			= Localizable.Project.Address.placeholderCountry
		countryCell.textLabel?.textColor	= .placeholderText
		countryCell.detailTextLabel?.font	= countryCell.detailTextLabel?.font.monospaced()
		countryCell.accessoryType			= .disclosureIndicator
		
		provinceCell.textLabel?.text		= Localizable.Project.Address.placeholderProvince
		provinceCell.textLabel?.textColor	= .placeholderText
		provinceCell.detailTextLabel?.font	= provinceCell.detailTextLabel?.font.monospaced()
		provinceCell.accessoryType			= .disclosureIndicator
		
		//
		// Configure cell event handler
		for cell in [addressCell, localityCell, postalCodeCell, postalCodeExtensionCell, postalCodeVanityCell, unitCell] {
			cell.textField.addTarget(self, action: #selector(didChangeText(in:)), for: .editingChanged)
		}
		
		//
		// Configure the table view sections
		if !shouldRenderToCreate {
			tableView.cellLayoutMarginsFollowReadableWidth	= true
			tableView.backgroundColor						= Color.lightStyleTableViewBackground
			tableView.separatorColor						= Color.lightStyleCellSeparatorColor
			
			navigationItem.leftBarButtonItem = navigationItem.backBarButtonItem
			
			tableViewSections.append((title: "Feature ID", description: nil, cells: [featureIdCell]))
			
			featureIdCell.selectionStyle			= .none
			featureIdCell.textLabel?.isEnabled		= false
			
			featureIdCell.textLabel?.text			= addressToEdit?.id.uuidString
			addressCell.textField.text				= addressToEdit?.properties.address
			countryData								= addressToEdit?.getCountryData()
			provinceData							= addressToEdit?.getSubdivisionData()
			localityCell.textField.text				= addressToEdit?.properties.locality
			postalCodeCell.textField.text			= addressToEdit?.properties.postalCode
			postalCodeExtensionCell.textField.text	= addressToEdit?.properties.postalCodeExt
			postalCodeVanityCell.textField.text		= addressToEdit?.properties.postalCodeVanity
			unitCell.textField.text					= addressToEdit?.properties.unit
		}
		
		tableViewSections.append((
			title: nil,
			description: Localizable.Project.Address.addressDescription,
			cells: [addressCell]
		))
		tableViewSections.append((
			title:			nil,
			description:	nil,
			cells:			[countryCell, provinceCell, localityCell]
		))
		tableViewSections.append((
			title:			Localizable.Project.Address.postalCode,
			description:	Localizable.Project.Address.postalCodeDescription,
			cells:			[postalCodeCell, postalCodeExtensionCell, postalCodeVanityCell]
		))
		tableViewSections.append((
			title:			Localizable.Project.Address.unit,
			description:	Localizable.Project.Address.unitDescription,
			cells:			[unitCell]
		))
		tableViewSections.append((
			title:			nil,
			description:	nil,
			cells:			[confirmButtonCell]
		))
	}
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		
		if let countryData = self.countryData {
			countryCell.textLabel?.text			= countryData.title
			countryCell.detailTextLabel?.text	= countryData.code
			countryCell.textLabel?.textColor	= .label
		} else {
			countryCell.textLabel?.text			= Localizable.Project.Address.placeholderCountry
			countryCell.detailTextLabel?.text	= nil
			countryCell.textLabel?.textColor	= .placeholderText
		}
		
		if let provinceData = self.provinceData {
			provinceCell.textLabel?.text		= provinceData.title
			provinceCell.detailTextLabel?.text	= provinceData.code
			provinceCell.textLabel?.textColor	= .label
		} else {
			provinceCell.textLabel?.text		= Localizable.Project.Address.placeholderProvince
			provinceCell.detailTextLabel?.text	= nil
			provinceCell.textLabel?.textColor	= .placeholderText
		}
		
		setAddressButtonStates()
	}
	
	@objc func didChangeText(in textField: UITextField) -> Void {
		setAddressButtonStates()
	}
	
	override func didTapSave(_ barButtonItem: UIBarButtonItem) {
		super.didTapSave(barButtonItem)
		
		guard let properties = createAddressProperties() else {
			return
		}
		
		addressToEdit?.properties = properties
		
		//
		// Save the created address and reload the main controllers table view
		try? displayController.project.imdfArchive.save(.address)
		displayController.tableView.reloadData()
	}
	
	override func didTapConfirm(_ sender: UIButton) -> Void {
		
		//
		// The controller shows the delete button instead
		if !shouldRenderToCreate {
			if let visibleAddress = addressToEdit {
				displayController.project.imdfArchive.addresses.removeAll { (address) -> Bool in
					return address.id.uuidString == visibleAddress.id.uuidString
				}
				
				//
				// Save the created address and reload the main controllers table view
				try? displayController.project.imdfArchive.save(.address)
				displayController.tableView.reloadData()
				
				navigationController?.popViewController(animated: true)
			}
		}
		
		if shouldRenderToCreate {
			let uuid = displayController.project.imdfArchive.getUnusedGlobalUuid()
			
			guard let properties = createAddressProperties() else {
				return
			}
			
			let addressToAdd = Address(withIdentifier: uuid, properties: properties, geometry: [], type: .address)
			displayController.project.imdfArchive.addresses.append(addressToAdd)
			
			//
			// Save the created address and reload the main controllers table view
			try? displayController.project.imdfArchive.save(.address)
			displayController.tableView.reloadData()
			
			dismiss(animated: true, completion: nil)
		}
	}
	
	private func createAddressProperties() -> Address.Properties? {
		guard
			let address = addressCell.textField.text,
			let country = countryData?.code,
			let province = provinceData?.code,
			let locality = localityCell.textField.text
		else {
				return nil
		}
		
		let unitValue = unitCell.textField.text
		let postalCodeValue = postalCodeCell.textField.text
		let postalCodeExtValue = postalCodeExtensionCell.textField.text
		let postalCodeVanityValue = postalCodeVanityCell.textField.text
		
		return Address.Properties(
			address:			address,
			unit:				unitValue?.count ?? 0 == 0 ? nil : unitValue,
			locality:			locality,
			province:			province,
			country:			country,
			postalCode:			postalCodeValue?.count ?? 0 == 0 ? nil : postalCodeValue,
			postalCodeExt:		postalCodeExtValue?.count ?? 0 == 0 ? nil : postalCodeExtValue,
			postalCodeVanity:	postalCodeVanityValue?.count ?? 0 == 0 ? nil : postalCodeVanityValue
		)
	}
	
	private func setAddressButtonStates() -> Void {
		
		if shouldRenderToCreate {
			guard let address = addressCell.textField.text, let locality = localityCell.textField.text, let _ = countryData, let _ = provinceData else {
				isConfirmButtonEnabled = false
				return
			}
			
			if address.count == 0 || locality.count == 0 {
				isConfirmButtonEnabled = false
				return
			}
			
			isConfirmButtonEnabled = true
		}
		
		if !shouldRenderToCreate {
			guard let addressToEdit = addressToEdit, let properties = createAddressProperties() else {
				hasChangesToSave = false
				return
			}
			
			var hasChanges = addressToEdit.properties.address != properties.address
			hasChanges = hasChanges || addressToEdit.properties.country != properties.country
			hasChanges = hasChanges || addressToEdit.properties.province != properties.province
			hasChanges = hasChanges || addressToEdit.properties.locality != properties.locality
			hasChanges = hasChanges || addressToEdit.properties.postalCode != properties.postalCode
			hasChanges = hasChanges || addressToEdit.properties.postalCodeExt != properties.postalCodeExt
			hasChanges = hasChanges || addressToEdit.properties.postalCodeVanity != properties.postalCodeVanity
			hasChanges = hasChanges || addressToEdit.properties.unit != properties.unit
			
			hasChangesToSave = hasChanges
		}
	}
	
	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableViewSections[indexPath.section].cells[indexPath.row]
		
		if !shouldRenderToCreate {
			cell.backgroundColor = Color.lightStyleCellBackground
		}
		
		return cell
	}
	
	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		let cell = tableView.cellForRow(at: indexPath)
		
		if cell == countryCell {
			
			//
			// Prepare the locality picker controller
			let localityPickerController				= ProjectAddressLocalityController(style: .insetGrouped)
			localityPickerController.displayController	= self
			localityPickerController.dataType			= .country
			localityPickerController.existingAddresses	= displayController.project.imdfArchive.addresses
			navigationController?.pushViewController(localityPickerController, animated: true)
		} else if cell == provinceCell {
			
			guard let code = countryData?.code else {
				return tableView.deselectRow(at: indexPath, animated: true)
			}
			
			//
			// Prepare the locality picker controller
			let localityPickerController				= ProjectAddressLocalityController(style: .insetGrouped)
			localityPickerController.displayController	= self
			localityPickerController.dataType			= .province
			localityPickerController.preselectedCountry	= code
			localityPickerController.existingAddresses	= displayController.project.imdfArchive.addresses
			
			navigationController?.pushViewController(localityPickerController, animated: true)
		}
	}
}
