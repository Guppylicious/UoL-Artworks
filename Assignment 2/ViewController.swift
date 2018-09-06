//
//  ViewController.swift
//  Assignment 2
//
//  Created by Adam Hawkins on 29/11/2017.
//  Copyright © 2017 Adam Hawkins. All rights reserved.
//

import UIKit
import MapKit
import CoreData

var artworks: [NSManagedObject] = [] //array to retrieve items in core data
//variables to store the chosen artwork's details
var chosenAnnotation = ""
var chosenTitle = ""
var chosenArtist = ""
var chosenYear = ""
var chosenLocation = ""
var chosenInformation = ""
var chosenArt = ""
var chosenBuilding = ""
var found: Bool = false //boolean to check whether the item has been found in core data or not
var start = false
//variables for the annotation
var title = ""
var latitude = ""
var longitude = ""
var buildings: [String] = [] //array to store the names of buildings

var cLat: Double = 0
var cLong: Double = 0

class ViewController: UIViewController, MKMapViewDelegate, UITableViewDelegate, UITableViewDataSource, CLLocationManagerDelegate {
    
    let managedObjectContext = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext //manages the objects within core data
    var locationManager = CLLocationManager()

    @IBOutlet weak var map: MKMapView! //outlet for the map
    @IBOutlet weak var myTable: UITableView! //outlet for the table
    
    //function to define the view for the map
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if annotation is MKUserLocation { return nil } //for the user's location do not place annotation
        let identifier = "pin" //setting an identifier for the annotations
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier) as? MKPinAnnotationView //returns a reusable annotation view located by its identifier
        if annotationView == nil { //if there is no annotation view
            annotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: identifier) //displaying the pin
            annotationView?.canShowCallout = true //the pin can show callouts
            annotationView?.rightCalloutAccessoryView = UIButton(type: .infoLight) //adding an info button to the callout
        } else {
            annotationView?.annotation = annotation
        }
        annotationView?.pinTintColor = UIColor.purple //setting the pin colour to blue
        return annotationView
    }
    
    //function to define what happens when the callout is tapped
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        chosenAnnotation = (view.annotation!.title as? String)! //set the chosen title to the annotations title
        var buildingFound = false //boolean for whether a building has been matched
        let buildingCount = buildings.count - 1 //minus the count so it can be started at 0
        for i in 0...buildingCount { //loop through the buildings found
            if(chosenAnnotation == buildings[i]) { //if the annotation matches the building
                buildingFound = true //set found to true
                break //break from loop
            }
        }
        if buildingFound == true { //if a building has been found
            chosenBuilding = chosenAnnotation //take the building name
            performSegue(withIdentifier: "goToBuildings", sender: nil) //go to the building view
        }
        else {
            let fetchRequest: NSFetchRequest<Art> = Art.fetchRequest() //fetch request to search through core data
            do {
                let sortDescriptor = NSSortDescriptor(key: "id", ascending: true) //sorting the core data by the id
                let sort = [sortDescriptor] //setting sort to the array of sorted core data
                fetchRequest.sortDescriptors = sort //search through sort
                fetchRequest.predicate = NSPredicate(format: "title MATCHES[cd] '(\(chosenAnnotation)).*'") //search where the title matches the chosen annotation
                let fetchResult = try managedObjectContext.fetch(fetchRequest) //try the search
                let results = fetchResult as [Art] //set the results of the search to results
                //setting the results of the search to variables (0 because only one item should be returned)
                chosenTitle = results[0].title!
                chosenArtist = results[0].artist!
                chosenYear = results[0].yearOfWork!
                chosenLocation = results[0].locationNotes!
                chosenInformation = results[0].information!
                chosenArt = results[0].fileName!
            } catch {
                print("Error with sort and search") //print an error
            }
            performSegue(withIdentifier: "goToArt", sender: nil) //go to the view of the art
        }
    }
    
    //function to define the number of rows in each section of the table
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return artworks.count //return the number of entries in artworks
    }
    
    //function to define the data in each cell of the table
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: UITableViewCellStyle.subtitle, reuseIdentifier: "myCell") //setting the cell to myCell
        cell.textLabel?.text = artworks[indexPath.row].value(forKey: "title") as? String //setting the title of each cell to the value in each position of artworks
        let dist = artworks[indexPath.row].value(forKey: "distance") as? Double //retrieving he distance from current location
        let distInt = Int(dist!) //changing the distance from double to int to avoid long decimal number
        cell.detailTextLabel?.text = ("\(artworks[indexPath.row].value(forKey: "location") ?? "") - Distance: \(distInt)m") //setting the text inside the subtitle of each table cell
        return cell //return the cell with all information inside
    }
    
    //function to define what happens when a table row is selected
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //setting all of the information of the chosen artwork for display in the next view
        chosenTitle = artworks[indexPath.row].value(forKey: "title") as! String
        chosenArtist = artworks[indexPath.row].value(forKey: "artist") as! String
        chosenYear = artworks[indexPath.row].value(forKey: "yearOfWork") as! String
        chosenLocation = artworks[indexPath.row].value(forKey: "locationNotes") as! String
        chosenInformation = artworks[indexPath.row].value(forKey: "information") as! String
        chosenArt = artworks[indexPath.row].value(forKey: "fileName") as! String
        performSegue(withIdentifier: "goToArt", sender: nil) //go to the view of the art
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location = CLLocationCoordinate2D(latitude: locations[0].coordinate.latitude, longitude: locations[0].coordinate.longitude)
        cLat = locations[0].coordinate.latitude
        cLong = locations[0].coordinate.longitude
        let span = MKCoordinateSpan(latitudeDelta: 0.006, longitudeDelta: 0.006)
        let region = MKCoordinateRegion(center: location, span: span)
        self.map.setRegion(region, animated: true)
    }
    
    //function to define what happens when the view appears
    override func viewDidAppear(_ animated: Bool) {
        myTable.reloadData() //reload all of the data in the table
    }
    
    internal func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        start = true
        viewDidLoad()
    }
    
    //function to define what happens when the view loads
    override func viewDidLoad() {
        super.viewDidLoad()
        // do any additional setup after loading the view, typically from a nib.
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        
        if start == true {
            let url = URL(string: "https://cgi.csc.liv.ac.uk/~phil/Teaching/COMP327/artworksOnCampus/data.php?class=artworks2&lastUpdate=2017-11-01")! //the url of the json file
            //start task
            let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
                //if there is an error
                if error != nil {
                    print(error!) //print the error
                }
                //else there is no error
                else {
                    if let urlContent = data {
                        do {
                            //deserialize JSON data
                            let jsonResult = try JSONSerialization.jsonObject(with: urlContent, options: JSONSerialization.ReadingOptions.mutableContainers) as AnyObject
                            let result = jsonResult["artworks2"] as? [[String: Any]] //retrieve all entries in json
                            //loop through all of the results
                            for results in result! {
                                //storing all of the retrieved data from json to variables
                                let id = results["id"] as! String
                                let title = results["title"] as! String
                                let artist = results["artist"] as! String
                                let yearOfWork = results["yearOfWork"] as! String
                                let information = results["Information"] as! String
                                let lat = results["lat"] as! String
                                let long = results["long"] as! String
                                let location = results["location"] as! String
                                let locationNotes = results["locationNotes"] as! String
                                let fileName = results["fileName"] as! String
                                
                                let newFileName = fileName.replacingOccurrences(of: " ", with: "%20", options: .literal, range: nil) //creating a new file name replacing " " with "%20" to get the images from the url
                                
                                let lastModified = results["lastModified"] as! String
                                let artLatString = results["lat"] as! String
                                let artLongString = results["long"] as! String
                                //setting the lat and long of te art to doubles
                                let artLat = Double(artLatString)
                                let artLong = Double(artLongString)
                                //let artLocation = CLLocationCoordinate2D(latitude: artLat!, longitude: artLong!) //setting the lat and long to a 2d coordinate for annotations
                                let currentCoordinate = CLLocation(latitude: cLat, longitude: cLong) //setting the current location lat and long as CLLocation
                                let artCoordinate = CLLocation(latitude: artLat!, longitude: artLong!) //setting the art location lat and long CLLocation
                                let distance = currentCoordinate.distance(from: artCoordinate) //calculating the distance between current location coordinates and art location coordinates
                                
                                //fetching entities in core data to check whether there is anything in core data
                                let fetchRequest = NSFetchRequest<NSFetchRequestResult>()
                                let entityDescription = NSEntityDescription.entity(forEntityName: "Art", in: self.managedObjectContext)
                                fetchRequest.entity = entityDescription
                                do {
                                    let fetchResult = try self.managedObjectContext.fetch(fetchRequest)
                                    var loop = Int(fetchResult.count) //setting loop to equal the number of entities in the fetch result
                                    loop = loop + 1 //loop as an index out of range issue, adding 1 stops this error
                                    if (fetchResult.count > 0) { //if there are entities in core data
                                        for i in 0...loop { //loop through all entities
                                            let arts = fetchResult[i] as! NSManagedObject //fetch each item
                                            let artID = arts.value(forKey: "id") as! String //take the id from the item
                                            if artID == id { //if the id is equal to the id needed to be added
                                                found = true //set found to true
                                                break //break from loop
                                            }
                                        }
                                    }
                                    else if found == false { //else if nothing is in core data or the entry is not in core data, add i
                                        DispatchQueue.main.async {
                                            let entity = NSEntityDescription.entity(forEntityName: "Art", in: self.managedObjectContext) //the entity to add into
                                            let newArt = NSManagedObject(entity: entity!, insertInto: self.managedObjectContext) //specify that the entity is to be added to
                                            //adding all of the values to Art entity in core data
                                            newArt.setValue(id, forKey: "id")
                                            newArt.setValue(title, forKey: "title")
                                            newArt.setValue(artist, forKey: "artist")
                                            newArt.setValue(yearOfWork, forKey: "yearOfWork")
                                            newArt.setValue(information, forKey: "information")
                                            newArt.setValue(lat, forKey: "lat")
                                            newArt.setValue(long, forKey: "long")
                                            newArt.setValue(location, forKey: "location")
                                            newArt.setValue(locationNotes, forKey: "locationNotes")
                                            newArt.setValue(newFileName, forKey: "fileName")
                                            newArt.setValue(lastModified, forKey: "lastModified")
                                            newArt.setValue(distance, forKey: "distance")
                                        }
                                    }
                                    found = false //resetting found to false for next loop
                                } catch {
                                    let fetchError = error as NSError
                                    print(fetchError)
                                }
                              DispatchQueue.main.async {
                                    //sorting the values in core data by the distance
                                    let request = NSFetchRequest<Art>(entityName: "Art")
                                    let sort = NSSortDescriptor(key: "distance", ascending: true)
                                    request.sortDescriptors = [sort]
                                    do {
                                        artworks = try self.managedObjectContext.fetch(request) as [NSManagedObject]
                                        self.myTable.reloadData() //reload the table
                                    } catch {
                                        print("Can't fetch art")
                                    }
                                    do {
                                        try self.managedObjectContext.save() //save the core data
                                    } catch {
                                        print("Failed saving")
                                    }
                                }
                            }
                            //getting the question number from the JSON file
                        } catch {
                            print("======\nJSON processing Failed\n=======")
                        }
                        DispatchQueue.main.async {
                            self.buildingsArray() //call the function to build the array of buildings
                        }
                    }
                }
            }
            task.resume()
        }
    }
    
    //function to get all of the buildings in core data
    func buildingsArray() {
        //fetching entities in core data to check whether there is anything in core data
        let fetchRequest: NSFetchRequest<Art> = Art.fetchRequest()
        do {
            let sortDescriptor = NSSortDescriptor(key: "id", ascending: true) //sorting the core data by the id
            let sort = [sortDescriptor] //setting sort to the array of sorted core data
            fetchRequest.sortDescriptors = sort //search through sort
            let fetchResult = try managedObjectContext.fetch(fetchRequest) //try the search
            let results = fetchResult as [Art] //set the results of the search to results
            for result in results { //loop through all the results
                var buildingFound = false //boolean for whether a building has been found or not
                if (buildings.count == 0) { //if there are no buildings in the array
                    buildings.append(result.location!) //add the first building
                }
                else {
                    let buildLoop = buildings.count - 1 //minus the building count so it can be used for an loop of the array
                    for i in 0...buildLoop { //loop through all of the buildings
                        if (result.location == buildings[i]) { //if the building is in the array
                            buildingFound = true //set the building match to true
                        }
                    }
                    if buildingFound == false { //if a match is not found
                        buildings.append(result.location!) //add it to the array
                    }
                }
            }
        } catch {
            print("Error with building array") //print the error
        }
        DispatchQueue.main.async {
            self.getAnnotations() //call function to add annotations
            self.myTable.reloadData() //reload the table
        }
    }
    
    //function to get all of the annotations
    func getAnnotations() {
        self.map.delegate = self
        //fetching entities in core data to check whether there is anything in core data
        let fetchRequest: NSFetchRequest<Art> = Art.fetchRequest()
        do {
            let sortDescriptor = NSSortDescriptor(key: "id", ascending: true) //sorting the core data by the id
            let sort = [sortDescriptor] //setting sort to the array of sorted core data
            fetchRequest.sortDescriptors = sort //search through sort
            let buildingCount = buildings.count - 1 //minus the building count so it can be used for an loop of the array
            for i in 0...buildingCount { //looping through all of the buildings
                fetchRequest.predicate = NSPredicate(format: "location MATCHES[cd] '(\(buildings[i])).*'") //search where the location matches the building
                let fetchResult = try managedObjectContext.fetch(fetchRequest)
                let results = fetchResult as [Art]
                let artCount = results.count - 1 //minus the count so it can be used to loop through the array
                if (results.count == 1) { //if there is only one artwork in the building
                    //get the coordinates as doubles
                    let lat = Double(results[0].lat!)
                    let long = Double(results[0].long!)
                    let artLocation = CLLocationCoordinate2D(latitude: lat!, longitude: long!) //set the 2d coordinate for the art
                    //create the annontation for the artwork
                    let annotation = MKPointAnnotation()
                    annotation.coordinate = artLocation
                    annotation.title = results[0].title
                    annotation.subtitle = results[0].artist
                    self.map.addAnnotation(annotation)
                }
                else {
                    var buildingName = "" //variable for the building name
                    var placed = false //boolean for whether the annotation has been placed or not
                    for j in 0...artCount { //loop through all of the artworks
                        if buildingName == "" { //if there is no building name set
                            buildingName = results[j].location! //set the building name
                        }
                        else if buildingName == results[j].location && placed == false { //if the building name matches and the annotation has not been placed
                            //get the coordinates of the building
                            let lat = Double(results[j].lat!)
                            let long = Double(results[j].long!)
                            let artLocation = CLLocationCoordinate2D(latitude: lat!, longitude: long!) //set the 2d coordinate for the building
                            //create the annotation for the building
                            let annotation = MKPointAnnotation()
                            annotation.coordinate = artLocation
                            annotation.title = results[j].location
                            self.map.addAnnotation(annotation)
                            placed = true //set placed to true
                        }
                    }
                }
            }
        } catch {
            print("Error getting annotations") //print error
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // dispose of any resources that can be recreated.
    }
}
