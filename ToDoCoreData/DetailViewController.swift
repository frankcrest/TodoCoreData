//
//  DetailViewController.swift
//  ToDoCoreData
//
//  Created by Frank Chen on 2019-06-05.
//  Copyright © 2019 Frank Chen. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController {

  @IBOutlet weak var detailDescriptionLabel: UILabel!


  func configureView() {
    // Update the user interface for the detail item.
    if let detail = detailItem {
        if let label = detailDescriptionLabel {
          label.text = "Title: \(detail.title!)\nDescription: \(detail.todoDescription!)\nPriority: \(detail.priorityNumber)"
        }
    }
  }

  override func viewDidLoad() {
    super.viewDidLoad()
    // Do any additional setup after loading the view, typically from a nib.
    configureView()
  }

  var detailItem: ToDo? {
    didSet {
        // Update the view.
        configureView()
    }
  }


}

