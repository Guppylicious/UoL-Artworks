//
//  ArtViewController.swift
//  Assignment 2
//
//  Created by Adam Hawkins on 01/12/2017.
//  Copyright © 2017 Adam Hawkins. All rights reserved.
//

import UIKit

class ArtViewController: UIViewController {

    @IBOutlet weak var titleLbl: UILabel! //label for the title
    @IBOutlet weak var artistLbl: UILabel! //label for the artist
    @IBOutlet weak var yearLbl: UILabel! //label for the year of work
    @IBOutlet weak var locationLbl: UILabel! //label for the location notes
    @IBOutlet weak var infoLbl: UILabel! //label for the information
    @IBOutlet weak var artImg: UIImageView! //view for the art image
    
    //action to define what happens when the back button is pressed
    @IBAction func backBtn(_ sender: Any) {
        if fromBuilding == true { //if we have come from the building view
            fromBuilding = false //set the boolean back to false
            performSegue(withIdentifier: "goToBuild", sender: nil) //go back to the building view
        }
        else if fromBuilding == false { //if we have not come from the building view
            performSegue(withIdentifier: "goToMap", sender: nil) //go back to the map view
        }
    }
    
    //function for what happens when the view loads
    override func viewDidLoad() {
        super.viewDidLoad()
        let imageUrl = "https://cgi.csc.liv.ac.uk/~phil/Teaching/COMP327/artwork_images/\(chosenArt)" //url for the image concatenating the file name into the url
        let url = URL(string: imageUrl)
            artImg.contentMode = .scaleAspectFit //scaling the image to fit the view without stretching
            downloadImage(url: url!) //calling function to download the image

        titleLbl.text = chosenTitle //setting the text of the title label
        artistLbl.text = ("Artist: \(chosenArtist)") //setting the text of the artist label
        if chosenYear == "" { //if there is no year
            yearLbl.text = ("Year: Unknown") //set the year label text to unknown
        }
        else {
            yearLbl.text = ("Year: \(chosenYear)") //setting the text for the year label
        }
        locationLbl.text = ("Location: \(chosenLocation)") //setting the location label text
        infoLbl.text = chosenInformation //setting the information label text
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //function to get te data of the image from the url
    func getDataFromUrl(url: URL, completion: @escaping (Data?, URLResponse?, Error?) -> ()) {
        URLSession.shared.dataTask(with: url) { data, response, error in
            completion(data, response, error)
            }.resume()
    }
    
    //function to download the image from the url
    func downloadImage(url: URL) {
        getDataFromUrl(url: url) { data, response, error in //call the function to get the data from the url
            guard let data = data, error == nil else { return }
            DispatchQueue.main.async() {
                self.artImg.image = UIImage(data: data) //set the image to the image view
            }
        }
    }
}
