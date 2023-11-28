//
//  ShutterTableViewController.swift
//  HomeControl
//
//  Created by Joachim Kittelberger on 07.06.17.
//  Copyright © 2017 Joachim Kittelberger. All rights reserved.
//

import UIKit

class ShutterTableViewController: UITableViewController {

    lazy var shutterList = ShutterList()
    
    // Zugriff auf appDelegate
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    
    
    
    // MARK: - Table view data source
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        print("ShutterTableViewController.init");
    }
    

    
    override func loadView() {
        super.loadView()
        
        print("ShutterTableViewController.loadView");
    }
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // TODO Jet32
        let homeControlConnection = Jet32.sharedInstance
//        let homeControlConnection = Jet32NW.sharedInstance
        homeControlConnection.connect()
        
        print("ShutterTableViewController.viewDidLoad");
    }
   
    
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        // standard is 1
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        
        // we have only one section!
        return shutterList.getShutterItems().count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let item = shutterList.getShutter(forIndex: indexPath.row)
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "shutterCell", for: indexPath) as! ShutterTableViewCell

        // Configure the cell...
        cell.nameLabel.text = item.name
        

        // TODO: if item ist not acitve
        
        if !item.isEnabled {
            // TODO. Keine Aktion auslösen
        }

          if !item.isMovingDown && !item.isMovingUp {
            cell.upImageView.image = UIImage(named: "Up")
            cell.downImageView.image = UIImage(named: "Down")
            cell.nameLabel.textColor = UIColor.black
            
        } else {
            if item.isMovingDown {
                cell.downImageView.image = UIImage(named: "Downward")
                cell.upImageView.image = UIImage(named: "Up")
            }
            if item.isMovingUp {
                cell.upImageView.image = UIImage(named: "Upward")
                cell.downImageView.image = UIImage(named: "Down")
            }
            cell.nameLabel.textColor = UIColor.gray
        }
        
        let tapGestureRecognizerDown = UITapGestureRecognizer(target: self, action: #selector(imageDownTaped(tapGestureRecognizerDown:)))
        cell.downImageView?.isUserInteractionEnabled = true
        cell.downImageView?.addGestureRecognizer(tapGestureRecognizerDown)
        cell.downImageView?.tag = indexPath.row     // damit später erkannt werden kann, welches Image gedrückt wurde

        let tapGestureRecognizerUp = UITapGestureRecognizer(target: self, action: #selector(imageUpTaped(tapGestureRecognizerUp:)))
        cell.upImageView?.isUserInteractionEnabled = true
        cell.upImageView?.addGestureRecognizer(tapGestureRecognizerUp)
        cell.upImageView?.tag = indexPath.row     // damit später erkannt werden kann, welches Image gedrückt wurde
        
        
        return cell
    }
    


/*
     // set direct the outputs in the PLC
    func imageUpTaped(tapGestureRecognizerUp: UITapGestureRecognizer) {
        
        // Die  Info, welches Image gedrückt wurde, ist im .tag hinterlegt
        let tapedImage = tapGestureRecognizerUp.view as! UIImageView
        let item = shutterList.getShutter(forIndex: tapedImage.tag)
        
        if item.isMovingDown {
            print("Error: The Image Up in \(item.name) was taped while moving down")
            return
        }
        
        let indexPath = IndexPath(row: tapedImage.tag, section: 0)
     
        // TODO Jet32
//        let homeControlConnection = Jet32NW.sharedInstance
        let homeControlConnection = Jet32.sharedInstance
        if !item.isMovingUp {
            // Make sure that only one output is active
            homeControlConnection.clearOutput(item.outputDown)
            homeControlConnection.setOutput(item.outputUp)
            item.isMovingUp = true
        } else {
            homeControlConnection.clearOutput(item.outputUp)
            item.isMovingUp = false
        }
        tableView.reloadRows(at: [indexPath], with: .fade)
        
        print("The Image Up in \(item.name) was taped")
    }

    
    
     // set direct the outputs in the PLC
    func imageDownTaped(tapGestureRecognizerDown: UITapGestureRecognizer) {
        
        // Die  Info, welches Image gedrückt wurde, ist im .tag hinterlegt
        let tapedImage = tapGestureRecognizerDown.view as! UIImageView
        let item = shutterList.getShutter(forIndex: tapedImage.tag)

        if item.isMovingUp {
            print("Error: The Image Down in \(item.name) was taped while moving up")
            return
        }
        
        let indexPath = IndexPath(row: tapedImage.tag, section: 0)
     
        // TODO Jet32
//        let homeControlConnection = Jet32NW.sharedInstance
        let homeControlConnection = Jet32.sharedInstance
        if !item.isMovingDown {
            // Make sure that only one output is active
            homeControlConnection.clearOutput(item.outputUp)
            homeControlConnection.setOutput(item.outputDown)
            item.isMovingDown = true
        } else {
            homeControlConnection.clearOutput(item.outputDown)
            item.isMovingDown = false
        }
        tableView.reloadRows(at: [indexPath], with: .fade)
       
        print("The Image Down in \(item.name) was taped")
    }
 */

    @objc func imageUpTaped(tapGestureRecognizerUp: UITapGestureRecognizer) {
        
        // Die  Info, welches Image gedrückt wurde, ist im .tag hinterlegt
        let tapedImage = tapGestureRecognizerUp.view as! UIImageView
        let item = shutterList.getShutter(forIndex: tapedImage.tag)
        
        let indexPath = IndexPath(row: tapedImage.tag, section: 0)
        
        // TODO Jet32
//        let homeControlConnection = Jet32NW.sharedInstance
        let homeControlConnection = Jet32.sharedInstance
        homeControlConnection.setFlag(288 + item.ID)        // Offset for flags up
        
        
        tableView.reloadRows(at: [indexPath], with: .fade)
        
        print("The Image Up in \(item.name) was taped")
    }
    
    
    
    @objc func imageDownTaped(tapGestureRecognizerDown: UITapGestureRecognizer) {
        
        // Die  Info, welches Image gedrückt wurde, ist im .tag hinterlegt
        let tapedImage = tapGestureRecognizerDown.view as! UIImageView
        let item = shutterList.getShutter(forIndex: tapedImage.tag)
        
        let indexPath = IndexPath(row: tapedImage.tag, section: 0)
        
        // TODO Jet32
//        let homeControlConnection = Jet32NW.sharedInstance
        let homeControlConnection = Jet32.sharedInstance
        homeControlConnection.setFlag(256 + item.ID)        // Offset for flags Down
        tableView.reloadRows(at: [indexPath], with: .fade)
        
        print("The Image Down in \(item.name) was taped")
    }


    
    

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50.0
    }
    
    
    
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        let item = shutterList.getShutter(forIndex: indexPath.row)
        
        // Todo: just for texting the selection
//        item.isEnabled = !item.isEnabled
        
        // TODO Test: Read the second register
        // TODO Jet32
        //        let homeControlConnection = Jet32NW.sharedInstance
        let homeControlConnection = Jet32.sharedInstance
        let _ = homeControlConnection.readIntReg(102911)
        
        // load this row again to update the view with animation
        tableView.reloadRows(at: [indexPath], with: .fade)
    }
    

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

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

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
       
        // Was ist zu tun, bevor auf die andere Seite gewechselt wird?
        if segue.identifier == "showDetail" {
            let dst = segue.destination as! ShutterDetailViewController
            guard let indexPath = tableView.indexPathForSelectedRow else {
                return
            }
            let item = shutterList.getShutter(forIndex: indexPath.row)
            dst.testName = item.name
        }
        
    }


}
