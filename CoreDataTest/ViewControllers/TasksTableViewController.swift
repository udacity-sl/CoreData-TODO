//
//  TasksTableViewController.swift
//  CoreDataTest
//
//  Created by Qutaibah Essa on 15/01/2019.
//  Copyright © 2019 qutaibah. All rights reserved.
//

import UIKit
import CoreData

class TasksTableViewController: UITableViewController {

	var fetchedResultsController: NSFetchedResultsController<Task>!

    override func viewDidLoad() {
        super.viewDidLoad()
		title = "Tasks"
		fetch()
    }

	func fetch() {
		let fetchRequest: NSFetchRequest<Task> = Task.fetchRequest()
		// TODO: Sort the results
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "createdAt", ascending: false)]
		// TODO: create the fetched results controller
        fetchedResultsController = NSFetchedResultsController(
            fetchRequest: fetchRequest,
            managedObjectContext: DataController.shared.viewContext,
            sectionNameKeyPath: nil,
            cacheName: nil
        )
        fetchedResultsController.delegate = self
		// TODO: perform the fetch with fetchedResultsController
        do {
            try fetchedResultsController.performFetch()
        } catch {
            debugPrint(error)
        }
	}

	@IBAction func addTask(_ sender: UIBarButtonItem) {
		let alertController = UIAlertController(title: "New Task", message: "What is your task?", preferredStyle: .alert)
		let okAction = UIAlertAction(title: "Save", style: .default) { (action) in
			guard let text = alertController.textFields?[0].text else {
				return
			}
			self.createNewTask(with: text)
		}
		let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (action) in }
		alertController.addAction(okAction)
		alertController.addAction(cancelAction)
		alertController.addTextField { (textField) in }
		self.present(alertController, animated: true, completion: nil)
	}

	func createNewTask(with title: String) {
		let task = Task(context: DataController.shared.viewContext)
		task.title = title
		try? DataController.shared.viewContext.save()
	}

	@IBAction func startEditing(_ sender: UIBarButtonItem) {
		tableView.setEditing(sender.style == .plain, animated: true)
		sender.title = sender.style == .plain ? "Done" : "Edit"
		sender.style = sender.style == .plain ? .done : .plain
	}

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return fetchedResultsController.sections?.count ?? 0
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return fetchedResultsController.sections?[section].numberOfObjects ?? 0
    }

	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let task = fetchedResultsController.object(at: indexPath)
		let cell = tableView.dequeueReusableCell(withIdentifier: "taskCell", for: indexPath)
		cell.textLabel?.text = task.title
		cell.detailTextLabel?.text = String(task.subtasks?.count ?? 0)
		return cell
	}

	override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
		switch editingStyle {
		case .delete:
			// TODO: get the task managed object from the fetchedResultsController and then remove it from the viewContext
            let task = fetchedResultsController.object(at: indexPath)
            DataController.shared.viewContext.delete(task)
            try? DataController.shared.viewContext.save()
			break
		default:
			break
		}
	}

	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		// TODO: get the managed object for the selected task and pass it to the subtasks controller
        let subtasksVC = storyboard?.instantiateViewController(withIdentifier: "SubTasksTableViewController") as! SubTasksTableViewController
        subtasksVC.task = fetchedResultsController.object(at: indexPath)
        navigationController?.pushViewController(subtasksVC, animated: true)
	}
}


extension TasksTableViewController: NSFetchedResultsControllerDelegate {

    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.beginUpdates()
    }
    
	func controller(
        _ controller: NSFetchedResultsController<NSFetchRequestResult>,
        didChange anObject: Any,
        at indexPath: IndexPath?,
        for type: NSFetchedResultsChangeType,
        newIndexPath: IndexPath?
    ) {
		switch type {
		case .insert:
			// TODO: insert the new item to the table view
            tableView.insertRows(at: [newIndexPath!], with: .automatic)
			break
		case .delete:
			// TODO: delete the item from the table view
            tableView.deleteRows(at: [indexPath!], with: .automatic)
			break
		case .update:
			tableView.reloadRows(at: [indexPath!], with: .fade)
		case .move:
			tableView.moveRow(at: indexPath!, to: newIndexPath!)
		}
	}

    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        // TODO: finish updating the table view
        tableView.endUpdates()
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
}
