//
//  BuildingViewController.swift
//  Assignment 2
//
//  Created by Adam Hawkins on 08/12/2017.
//  Copyright © 2017 Adam Hawkins. All rights reserved.
//

import UIKit
import CoreData

var artTitle: [String] = [] //array to store all the artwork titles in the building
var artSubtitle: [String] = [] //array to store all the artist names of artwork in the building

var fromBuilding = false //boolean to check whether we have come from the building or map view

class BuildingViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    let managedObjectContext = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext //manages the objects within core data

    @IBOutlet weak var buildingLbl: UILabel! //label for the building name
    @IBOutlet weak var buildTbl: UITableView! //table to view artworks in the building
    
    //function to define the number of rows in each section
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return artTitle.count //count the number of artworks in the building
    }
    
    //function to define what information is in each cell
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: UITableViewCellStyle.subtitle, reuseIdentifier: "buildCell") //setting the cell to buildCell
        cell.textLabel?.text = artTitle[indexPath.row] //setting the title of each cell to the value in each position of artworks
        cell.detailTextLabel?.text = artSubtitle[indexPath.row] //setting the text inside the subtitle of each table cell
        return cell //return the cell with all information inside
    }
    
    //function to define what happens when a table row is selected
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //setting all of the information of the chosen artwork for display in the next view
        let fetchRequest: NSFetchRequest<Art> = Art.fetchRequest()
        do {
            let sortDescriptor = NSSortDescriptor(key: "id", ascending: true) //sorting the core data by the id
            let sort = [sortDescriptor] //setting sort to the array of sorted core data
            fetchRequest.sortDescriptors = sort //search through sort
            fetchRequest.predicate = NSPredicate(format: "title MATCHES[cd] '(\(artTitle[indexPath.row])).*'") //search where the title matches the art title selected
            let fetchResult = try managedObjectContext.fetch(fetchRequest)
            let results = fetchResult as [Art]
            //setting the values of the chosen artwork
            chosenTitle = results[0].title!
            chosenArtist = results[0].artist!
            chosenYear = results[0].yearOfWork!
            chosenLocation = results[0].location!
            chosenInformation = results[0].information!
            chosenArt = results[0].fileName!
            fromBuilding = true //we will want to go back to the building view
            performSegue(withIdentifier: "goToArt", sender: nil) //go to the view of the art
        } catch {
                print("Error getting art")
            }
    }
    
    //function to define what happens when the view appears
    override func viewDidAppear(_ animated: Bool) {
        buildTbl.reloadData() //reload all of the data in the table
    }
    
    //function to define what happens when the view loads
    override func viewDidLoad() {
        super.viewDidLoad()
        //remove all current art titles and subtitles
        artTitle.removeAll()
        artSubtitle.removeAll()
        buildingLbl.text = chosenBuilding //set the text of the building label
        let fetchRequest: NSFetchRequest<Art> = Art.fetchRequest()
        do {
            let sortDescriptor = NSSortDescriptor(key: "id", ascending: true) //sorting the core data by the id
            let sort = [sortDescriptor] //setting sort to the array of sorted core data
            fetchRequest.sortDescriptors = sort //search through sort
            fetchRequest.predicate = NSPredicate(format: "location MATCHES[cd] '(\(chosenBuilding)).*'") //search where the location matches the chosen building selected
            let fetchResult = try managedObjectContext.fetch(fetchRequest)
            let results = fetchResult as [Art]
            for result in results { //for all of the results
                artTitle.append(result.title!) //add the artworks title
                artSubtitle.append(result.artist!) //add the artworks artist
            }
        } catch {
            print("Error fetching buildings") //print the error
        }
        DispatchQueue.main.async {
            self.buildTbl.reloadData() //reload the table
        }
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
