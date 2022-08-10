//
//  ViewController.swift
//  HelloMetal
//
//  Created by yaoxp on 2022/8/10.
//

import UIKit

struct Demo {
    let title: String
    let subtitle: String?
    let `class`: AnyClass
}

class ViewController: UITableViewController {

    // MARK: - cell
    static let tableViewCellIdentifier = "MainTableCell"
    
    var demos = [Demo(title: "compute", subtitle: nil, class: ComputeViewController.self)]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }


    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return demos.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ViewController.tableViewCellIdentifier, for: indexPath)

        // Configure the cell...
        let demo = demos[indexPath.row]
        cell.textLabel!.text = demo.title
        cell.detailTextLabel!.text = demo.subtitle
        return cell
    }

    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return false
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let demo = demos[indexPath.row]

        if let vcClass = demo.class as? UIViewController.Type {
            let vc = vcClass.init()
            navigationController!.pushViewController(vc, animated: true)
        }

    }

    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0.01
    }

    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.01
    }
}

