//
//  ReviewViewController.swift
//  cosc4355Project
//
//  Created by Timothy M Shepard on 10/19/17.
//  Copyright © 2017 cosc4355. All rights reserved.
//

import UIKit

class ReviewViewController: UIViewController {

    var stars: Int?
    var reviewWords: String?
    var reviewerPhotoString: String?
    
    @IBOutlet weak var starsImage: UIImageView!
    @IBOutlet weak var reviewWordsLabel: UILabel!
    @IBOutlet weak var reviewerPhoto: CustomImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let stars = self.stars {
            let starImageName = String(stars) + "stars"
            starsImage.image = UIImage(named: starImageName)
        }
        if let reviewWords = self.reviewWords {
            reviewWordsLabel.text = reviewWords
        }
        if let reviewerPhotoString = self.reviewerPhotoString {
            reviewerPhoto.loadImage(url: reviewerPhotoString)
        }
        
    }//layer.cornerRadius = 64
    
    @IBAction func backButton(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}