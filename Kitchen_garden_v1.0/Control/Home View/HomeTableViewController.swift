//
//  HomeTableViewController.swift
//  Kitchen_garden_v0.3
//
//  Created by Peigeng Jiang on 2/4/19.
//  Copyright © 2019 Peigeng Jiang. All rights reserved.
//

import UIKit

class HomeTableViewController: UITableViewController {
    
    //MARK: Properites
    var user: UserInfo?
    var plants = [Plant]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.clearsSelectionOnViewWillAppear = false
        
        loadUserAndNVtitle()
        
        //update ui
        setNavigationBarAndCell()
        updateBackground()
        
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return plants.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "HomeTableViewCell", for: indexPath) as? HomeTableViewCell else {
            fatalError("Unable getting UItable view cell")
        }
        
        //cell style
        cell.backgroundColor = UIColor.clear
        cell.cellBackground.layer.cornerRadius = 20
        cell.cellBackground.layer.shadowColor = UIColor.black.cgColor
        cell.cellBackground.layer.shadowOpacity = 0.4
        cell.cellBackground.layer.shadowOffset = CGSize.zero
        cell.cellBackground.layer.shadowRadius = 4
        cell.plantImage.layer.cornerRadius = 20
        // change cell select color
        let backgroundView = UIView()
        backgroundView.backgroundColor = UIColor.clear
        cell.selectedBackgroundView = backgroundView
        
        let plant = plants[indexPath.row]
        cell.name.text = plant.name
        cell.plantImage.image = UIImage(named: plant.name)
        
        return cell
    }
    

    
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    

    
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            
            deleteConfirmation(indexPath)
            
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        
        switch segue.identifier {
        case "homeToSearch":
            guard let nv = segue.destination as? UINavigationController else {
                fatalError("cant get navigation controller")
            }
            
            guard let preferenceVC = nv.topViewController as? PerferenceViewController else {
                fatalError("cant get perference view controller")
            }
            
            preferenceVC.user = user
        case "showDetail":
            guard let detailVC = segue.destination as? DetailViewController else {
                fatalError("cant get detail view controller")
            }
            
            guard let selectedPlantCell = sender as? HomeTableViewCell else {
                fatalError("Unexpected sender: \(String(describing: sender))")
            }
            
            guard let indexPath = tableView.indexPath(for: selectedPlantCell) else {
                fatalError("The selected cell is not being displayed by the table")
            }
            
            
            let selectedPlant = plants[indexPath.row]
            detailVC.plant = selectedPlant
            detailVC.displayButton = false
            //detailVC.addToMyFarm.isEnabled = false
            tableView.deselectRow(at: indexPath, animated: true)
            
        default: break
        }
        
    }
    
    @IBAction func backToLogin(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    //MARK: Unwind method
    @IBAction func unwindToHome(sender: UIStoryboardSegue) {
                
        if sender.identifier == "toHomeFromSearch" {
            if let sourceViewController = sender.source as? SearchTableViewController, let plant = sourceViewController.selectedPlant {
                
                let newIndexPath = IndexPath(row: plants.count, section: 0)
                
                plants.append(plant)
                tableView.insertRows(at: [newIndexPath], with: .automatic)
            }
        } else {
            if let sourceViewController = sender.source as? DetailViewController, let plant = sourceViewController.plant {
                
                let newIndexPath = IndexPath(row: plants.count, section: 0)
                
                plants.append(plant)
                tableView.insertRows(at: [newIndexPath], with: .automatic)
                
            }
        }
        
        savePlants()
        updateBackground()
        
        print("welcome back")
    }
    
    
    
    //MARK: Private method
    private func savePlants() {
        let data = try? NSKeyedArchiver.archivedData(withRootObject: plants, requiringSecureCoding: false)
        UserDefaults.standard.set(data, forKey: "plants")
    }
    
    private func loadPlants() -> [Plant]?  {
        guard let data = UserDefaults.standard.data(forKey: "plants") else {
            return nil
        }
        return try! NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(data) as? [Plant]
    }
    
    //MARK: UI
    private func setNavigationBarAndCell() {
        tableView.separatorStyle = .none
        navigationController?.navigationBar.barTintColor = UIColor.init(red: 96/255, green: 186/255, blue: 114/255, alpha: 1.0)
        navigationController?.navigationBar.isTranslucent = false
        tableView.tableFooterView = UIView()
        
    }
    
    private func updateBackground() {
        if plants.isEmpty {
            let image1 = UIImageView(image: UIImage(named: "background1"))
            image1.contentMode = .scaleAspectFill
            tableView.backgroundView = image1
        } else {
            let image2 = UIImageView(image: UIImage(named: "background"))
            image2.contentMode = .scaleAspectFill
            tableView.backgroundView = image2
        }
    }
    
    //MARK: Load and change navigation title
    private func loadUserAndNVtitle() {
        //Check for persistent data
        if let loadPlants = loadPlants() {
            plants = loadPlants
        }
        
        if let user = user {
            if user.name == "Your" {
                navigationItem.title = "\(user.name) Farm"
            } else {
                navigationItem.title = "\(user.name)'s Farm"
            }
        }
    }
    
    //MARK: Delete pop up confirmation
    private func deleteConfirmation(_ indexPath: IndexPath) {
        let alert = UIAlertController(title: "Delete plant", message: "Are you sure you want to delete this plant ?", preferredStyle: UIAlertController.Style.actionSheet)
        
        alert.addAction(UIAlertAction(title: "Delete", style: UIAlertAction.Style.destructive, handler: { (_) in
            self.plants.remove(at: indexPath.row)
            self.savePlants()
            self.tableView.deleteRows(at: [indexPath], with: .fade)
            self.updateBackground()
        }))
        
        alert.addAction(UIAlertAction(title: "Dismiss", style: UIAlertAction.Style.cancel, handler: { (_) in
            print("Delete dismiss")
        }))
        
        self.present(alert, animated: true, completion: {
            print("completion block")
        })
        
    }

}
