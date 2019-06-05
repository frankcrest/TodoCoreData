//
//  MasterViewController.swift
//  ToDoCoreData
//
//  Created by Frank Chen on 2019-06-05.
//  Copyright © 2019 Frank Chen. All rights reserved.
//

import UIKit
import CoreData

class MasterViewController: UITableViewController, NSFetchedResultsControllerDelegate {

  var detailViewController: DetailViewController? = nil
  var managedObjectContext: NSManagedObjectContext? = nil


  override func viewDidLoad() {
    super.viewDidLoad()
    // Do any additional setup after loading the view, typically from a nib.
    navigationItem.leftBarButtonItem = editButtonItem

    let addButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(insertNewObject(_:)))
    navigationItem.rightBarButtonItem = addButton
    if let split = splitViewController {
        let controllers = split.viewControllers
        detailViewController = (controllers[controllers.count-1] as! UINavigationController).topViewController as? DetailViewController
    }
    saveDefaultToDoToUserDefaults()
  }

  override func viewWillAppear(_ animated: Bool) {
    clearsSelectionOnViewWillAppear = splitViewController!.isCollapsed
    super.viewWillAppear(animated)
  }

  @objc
  func insertNewObject(_ sender: Any) {
    let ud = UserDefaults.standard
    let defaultTitle = ud.string(forKey: "todoTitle")
    let defaultDesc = ud.string(forKey: "todoDesc")
    
    let context = self.fetchedResultsController.managedObjectContext
    
    let ac = UIAlertController(title: "Add new ToDo", message: "", preferredStyle: .alert)
    ac.addTextField { (titleTextField) in
      titleTextField.placeholder = defaultTitle
    }
    ac.addTextField { (descriptionTextField) in
      descriptionTextField.placeholder = defaultDesc
    }
    
    let saveAction = UIAlertAction(title: "Save", style: .default) { (alert) in
      let firstTF = ac.textFields![0] as UITextField
      let secondTF = ac.textFields![1] as UITextField
      guard let title = firstTF.text else{return}
      guard let description = secondTF.text else{return}
      let newToDo = ToDo(context: context)
      newToDo.title = title
      newToDo.todoDescription = description
      guard let count = self.fetchedResultsController.sections?[0].numberOfObjects else{return}
      newToDo.priorityNumber = Int16(count + 1)
      do {
        try context.save()
      } catch {
        // Replace this implementation with code to handle the error appropriately.
        // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
        let nserror = error as NSError
        fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
      }
    }
    
    let cancelAction = UIAlertAction(title: "Cancel", style: .default, handler: nil)
    
    ac.addAction(saveAction)
    ac.addAction(cancelAction)
    
    self.present(ac, animated: true, completion: nil)

  }

  // MARK: - Segues

  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    if segue.identifier == "showDetail" {
        if let indexPath = tableView.indexPathForSelectedRow {
        let object = fetchedResultsController.object(at: indexPath)
            let controller = (segue.destination as! UINavigationController).topViewController as! DetailViewController
            controller.detailItem = object
            controller.navigationItem.leftBarButtonItem = splitViewController?.displayModeButtonItem
            controller.navigationItem.leftItemsSupplementBackButton = true
        }
    }
  }

  // MARK: - Table View

  override func numberOfSections(in tableView: UITableView) -> Int {
    return fetchedResultsController.sections?.count ?? 0
  }

  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    let sectionInfo = fetchedResultsController.sections![section]
    return sectionInfo.numberOfObjects
  }

  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
    let todo = fetchedResultsController.object(at: indexPath)
    configureCell(cell, withTodo: todo)
    return cell
  }

  override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
    // Return false if you do not want the specified item to be editable.
    return true
  }

  override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
    if editingStyle == .delete {
        let context = fetchedResultsController.managedObjectContext
        context.delete(fetchedResultsController.object(at: indexPath))
            
        do {
            try context.save()
        } catch {
            // Replace this implementation with code to handle the error appropriately.
            // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            let nserror = error as NSError
            fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
        }
    }
  }

  func configureCell(_ cell: UITableViewCell, withTodo todo: ToDo) {
    guard let title = todo.title else{return}
    guard let description = todo.todoDescription else{return}
    let priority = todo.priorityNumber
    
    cell.textLabel?.text = title
    cell.detailTextLabel?.text = description
  }

  // MARK: - Fetched results controller

  var fetchedResultsController: NSFetchedResultsController<ToDo> {
      if _fetchedResultsController != nil {
          return _fetchedResultsController!
      }
      
      let fetchRequest: NSFetchRequest<ToDo> = ToDo.fetchRequest()
      
      // Set the batch size to a suitable number.
      fetchRequest.fetchBatchSize = 20
      
      // Edit the sort key as appropriate.
      let sortDescriptor = NSSortDescriptor(key: "priorityNumber", ascending: true)
      
      fetchRequest.sortDescriptors = [sortDescriptor]
      
      // Edit the section name key path and cache name if appropriate.
      // nil for section name key path means "no sections".
      let aFetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: self.managedObjectContext!, sectionNameKeyPath: nil, cacheName: "Master")
      aFetchedResultsController.delegate = self
      _fetchedResultsController = aFetchedResultsController
      
      do {
          try _fetchedResultsController!.performFetch()
      } catch {
           // Replace this implementation with code to handle the error appropriately.
           // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. 
           let nserror = error as NSError
           fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
      }
      
      return _fetchedResultsController!
  }    
  var _fetchedResultsController: NSFetchedResultsController<ToDo>? = nil

  func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
      tableView.beginUpdates()
  }

  func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType) {
      switch type {
          case .insert:
              tableView.insertSections(IndexSet(integer: sectionIndex), with: .fade)
          case .delete:
              tableView.deleteSections(IndexSet(integer: sectionIndex), with: .fade)
          default:
              return
      }
  }

  func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
      switch type {
          case .insert:
              tableView.insertRows(at: [newIndexPath!], with: .fade)
          case .delete:
              tableView.deleteRows(at: [indexPath!], with: .fade)
          case .update:
              configureCell(tableView.cellForRow(at: indexPath!)!, withTodo: anObject as! ToDo)
          case .move:
              configureCell(tableView.cellForRow(at: indexPath!)!, withTodo: anObject as! ToDo)
              tableView.moveRow(at: indexPath!, to: newIndexPath!)
      }
  }

  func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
      tableView.endUpdates()
  }

  func saveDefaultToDoToUserDefaults(){
    let ud = UserDefaults.standard
    ud.set("clean house", forKey: "todoTitle")
    ud.set("clean very well 5 times", forKey: "todoDesc")
    ud.set("0", forKey: "todoPriority")
  }
  
  override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
    return true
  }
  
  override func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
    guard let todos = self.fetchedResultsController.sections?[0].objects else{return}
    if let source = todos[sourceIndexPath.row] as? ToDo, let destination = todos[destinationIndexPath.row] as? ToDo{
      let sourcePriority = source.priorityNumber
      let destinationPriority = destination.priorityNumber
      source.priorityNumber = destinationPriority
      destination.priorityNumber = sourcePriority
      let context = self.fetchedResultsController.managedObjectContext
      do{
        try context.save()
      }catch let err{
        print(err)
      }
    }
  }
  /*
   // Implementing the above methods to update the table view in response to individual changes may have performance implications if a large number of changes are made simultaneously. If this proves to be an issue, you can instead just implement controllerDidChangeContent: which notifies the delegate that all section and object changes have been processed.
   
   func controllerDidChangeContent(controller: NSFetchedResultsController) {
       // In the simplest, most efficient, case, reload the table view.
       tableView.reloadData()
   }
   */

}

