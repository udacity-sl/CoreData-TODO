//
//  SubTasksTableViewController.swift
//  CoreDataTest
//
//  Created by Qutaibah Essa on 15/01/2019.
//  Copyright © 2019 qutaibah. All rights reserved.
//

import UIKit
import CoreData

class SubTasksTableViewController: UITableViewController {

	var fetchedResultsController: NSFetchedResultsController<SubTask>!

	var task: Task!

    override func viewDidLoad() {
        super.viewDidLoad()
		title = task.title
		fetch()
    }

	func fetch() {
		let fetchRequest: NSFetchRequest<SubTask> = SubTask.fetchRequest()
		let sortDescriptor = NSSortDescriptor(key: "createdAt", ascending: true)
		fetchRequest.sortDescriptors = [sortDescriptor]
		// TODO: add a predicate to get the subtasks for the selected task only
        fetchRequest.predicate = NSPredicate(format: "task == %@", task)
		fetchedResultsController = NSFetchedResultsController(
            fetchRequest: fetchRequest,
            managedObjectContext: DataController.shared.viewContext,
            sectionNameKeyPath: nil,
            cacheName: nil
        )
		fetchedResultsController.delegate = self
		do {
			try fetchedResultsController.performFetch()
		} catch {
			fatalError("The fetch could not be performed: \(error.localizedDescription)")
		}
	}

	@IBAction func addSubTask(_ sender: UIBarButtonItem) {
		let alertController = UIAlertController(title: "New Subtask", message: "What is your subtask?", preferredStyle: .alert)
		let okAction = UIAlertAction(title: "Save", style: .default) { (action) in
			guard let text = alertController.textFields?[0].text else {
				return
			}
			self.creatSubTask(with: text)
		}
		let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (action) in }
		alertController.addAction(okAction)
		alertController.addAction(cancelAction)
		alertController.addTextField { (textField) in }
		self.present(alertController, animated: true, completion: nil)
	}
	func creatSubTask(with title: String) {
		// TODO: create a new SubTask managed object using the viewContext
        let subtask = SubTask(context: DataController.shared.viewContext)
        subtask.title = title
        subtask.task = task
        try? DataController.shared.viewContext.save()
	}

	// MARK: - Table view data source

	override func numberOfSections(in tableView: UITableView) -> Int {
		return fetchedResultsController.sections?.count ?? 0
	}

	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return fetchedResultsController.sections?[section].numberOfObjects ?? 0
	}

	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let subtask = fetchedResultsController.object(at: indexPath)
		let cell = tableView.dequeueReusableCell(withIdentifier: "subTaskCell", for: indexPath)
		cell.textLabel?.text = subtask.title
		return cell
	}

	override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
		switch editingStyle {
		case .delete:
			let task = fetchedResultsController.object(at: indexPath)
			DataController.shared.viewContext.delete(task)
			try? DataController.shared.viewContext.save()
		default:
			break
		}
	}
}


extension SubTasksTableViewController: NSFetchedResultsControllerDelegate {
	func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
		switch type {
		case .insert:
			tableView.insertRows(at: [newIndexPath!], with: .fade)
			break
		case .delete:
			tableView.deleteRows(at: [indexPath!], with: .fade)
			break
		case .update:
			tableView.reloadRows(at: [indexPath!], with: .fade)
		case .move:
			tableView.moveRow(at: indexPath!, to: newIndexPath!)
		}
	}

	func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType) {
		let indexSet = IndexSet(integer: sectionIndex)
		switch type {
		case .insert: tableView.insertSections(indexSet, with: .fade)
		case .delete: tableView.deleteSections(indexSet, with: .fade)
		case .update, .move:
			fatalError("Invalid change type in controller(_:didChange:atSectionIndex:for:). Only .insert or .delete should be possible.")
		}
	}

	func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
		tableView.beginUpdates()
	}

	func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
		tableView.endUpdates()
	}
}
