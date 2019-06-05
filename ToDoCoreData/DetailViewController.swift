//
//  DetailViewController.swift
//  ToDoCoreData
//
//  Created by Frank Chen on 2019-06-05.
//  Copyright © 2019 Frank Chen. All rights reserved.
//

import UIKit

protocol DetailViewDelegate {
  func setCompleteStatus(status:Bool, index:IndexPath)
}

class DetailViewController: UIViewController {
  
  @IBOutlet weak var detailDescriptionLabel: UILabel!
  @IBOutlet weak var completeSwitch: UISwitch!
  
  var delegate:DetailViewDelegate? = nil
  var indexPath:IndexPath?
  
  override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)
    if completeSwitch != nil{
      let completeStatus = completeSwitch.isOn
      print(completeStatus)
      guard let indexPath = indexPath else{return}
      delegate?.setCompleteStatus(status: completeStatus, index: indexPath)
    }
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    // Do any additional setup after loading the view, typically from a nib.
    configureView()
  }
  
  func configureView() {
    // Update the user interface for the detail item.
    if let detail = detailItem {
      if let label = detailDescriptionLabel {
        label.text = "Title: \(detail.title!)\nDescription: \(detail.todoDescription!)\nPriority: \(detail.priorityNumber)"
      }
    }
  }
  
  var detailItem: ToDo? {
    didSet {
      // Update the view.
      configureView()
    }
  }
  
  
}

