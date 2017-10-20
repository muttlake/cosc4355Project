//
//  ReviewFormViewController.swift
//  cosc4355Project
//
//  Created by Timothy Shepard on 10/17/17.
//  Copyright © 2017 cosc4355. All rights reserved.
//

import UIKit
import Firebase

class ReviewFormViewController: UIViewController {
    
    var numStars: Int = -1
    
    var newReview: Review?
    
    @IBOutlet weak var reviewWordsField: UITextView!
    
    @IBOutlet weak var stars1Outlet: UIButton!
    @IBOutlet weak var stars2Outlet: UIButton!
    @IBOutlet weak var stars3Outlet: UIButton!
    @IBOutlet weak var stars4Outlet: UIButton!
    @IBOutlet weak var stars5Outlet: UIButton!
    
    @IBAction func stars0Button(_ sender: Any) {
        self.numStars = 0
        stars1Outlet.setImage(UIImage(named: "singleStarEmpty"), for: .normal)
        stars2Outlet.setImage(UIImage(named: "singleStarEmpty"), for: .normal)
        stars3Outlet.setImage(UIImage(named: "singleStarEmpty"), for: .normal)
        stars4Outlet.setImage(UIImage(named: "singleStarEmpty"), for: .normal)
        stars5Outlet.setImage(UIImage(named: "singleStarEmpty"), for: .normal)
    }
    
    @IBAction func stars1Button(_ sender: Any) {
        self.numStars = 1
        stars1Outlet.setImage(UIImage(named: "singleStarFilled"), for: .normal)
        stars2Outlet.setImage(UIImage(named: "singleStarEmpty"), for: .normal)
        stars3Outlet.setImage(UIImage(named: "singleStarEmpty"), for: .normal)
        stars4Outlet.setImage(UIImage(named: "singleStarEmpty"), for: .normal)
        stars5Outlet.setImage(UIImage(named: "singleStarEmpty"), for: .normal)
    }

    @IBAction func stars2Button(_ sender: Any) {
        self.numStars = 2
        stars1Outlet.setImage(UIImage(named: "singleStarFilled"), for: .normal)
        stars2Outlet.setImage(UIImage(named: "singleStarFilled"), for: .normal)
        stars3Outlet.setImage(UIImage(named: "singleStarEmpty"), for: .normal)
        stars4Outlet.setImage(UIImage(named: "singleStarEmpty"), for: .normal)
        stars5Outlet.setImage(UIImage(named: "singleStarEmpty"), for: .normal)
    }
    
    @IBAction func stars3Button(_ sender: Any) {
        self.numStars = 3
        stars1Outlet.setImage(UIImage(named: "singleStarFilled"), for: .normal)
        stars2Outlet.setImage(UIImage(named: "singleStarFilled"), for: .normal)
        stars3Outlet.setImage(UIImage(named: "singleStarFilled"), for: .normal)
        stars4Outlet.setImage(UIImage(named: "singleStarEmpty"), for: .normal)
        stars5Outlet.setImage(UIImage(named: "singleStarEmpty"), for: .normal)
    }
    
    @IBAction func stars4Button(_ sender: Any) {
        self.numStars = 4
        stars1Outlet.setImage(UIImage(named: "singleStarFilled"), for: .normal)
        stars2Outlet.setImage(UIImage(named: "singleStarFilled"), for: .normal)
        stars3Outlet.setImage(UIImage(named: "singleStarFilled"), for: .normal)
        stars4Outlet.setImage(UIImage(named: "singleStarFilled"), for: .normal)
        stars5Outlet.setImage(UIImage(named: "singleStarEmpty"), for: .normal)
    }
    
    @IBAction func stars5Button(_ sender: Any) {
        self.numStars = 5
        stars1Outlet.setImage(UIImage(named: "singleStarFilled"), for: .normal)
        stars2Outlet.setImage(UIImage(named: "singleStarFilled"), for: .normal)
        stars3Outlet.setImage(UIImage(named: "singleStarFilled"), for: .normal)
        stars4Outlet.setImage(UIImage(named: "singleStarFilled"), for: .normal)
        stars5Outlet.setImage(UIImage(named: "singleStarFilled"), for: .normal)
    }
    
    func alertNoStarLevelChosen() {
        let alert = UIAlertController(title: "Incomplete Review", message: "No star level chosen", preferredStyle: .alert)
        let okayAction = UIAlertAction(title: "Okay", style: .default, handler: nil)
        alert.addAction(okayAction)
        self.present(alert, animated: true, completion: nil)
    }
    
    @IBAction func submitButton(_ sender: Any) {
        if numStars == -1 {
            alertNoStarLevelChosen()
            return
        }
        self.newReview = Review(about_id: "Contractor22", posting_id: "253fdfds", stars: self.numStars, reviewWords: self.reviewWordsField.text!, reviewTime: Date.currentDate)
        print(newReview!)
        self.registerReviewIntoDatabase()
        self.dismiss(animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func registerReviewIntoDatabase() {
        let reviewId = NSUUID().uuidString
        let values = ["user_id": FIRAuth.getCurrentUserId(), "about_id": newReview!.about_id, "posting_id": newReview!.posting_id, "stars": newReview!.stars, "reviewWords": newReview!.reviewWords, "reviewTime": newReview!.reviewTime] as [String : Any]
        self.registerInfoIntoDatabaseWithUID(uid: reviewId, values: values as [String: AnyObject])
    }
    
    private func registerInfoIntoDatabaseWithUID(uid: String, values: [String: AnyObject]) {
        let ref = FIRDatabase.database().reference(fromURL: "https://cosc4355project.firebaseio.com/")
        let reviewsReference = ref.child("reviews").child(uid)
        reviewsReference.updateChildValues(values) { (err, ref) in
            if(err != nil) {
                print("Error Occured: \(err!)")
                return
            }
        }
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