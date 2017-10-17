//
//  ReviewFormViewController.swift
//  cosc4355Project
//
//  Created by Timothy Shepard on 10/17/17.
//  Copyright © 2017 cosc4355. All rights reserved.
//

import UIKit

class ReviewFormViewController: UIViewController {
    
    var numStars: Int = -1
    
    @IBOutlet weak var reviewWordsField: UITextView!
    
    @IBAction func stars0Button(_ sender: Any) {
        self.numStars = 0
    }
    
    @IBAction func stars1Button(_ sender: Any) {
        self.numStars = 1
    }

    @IBAction func stars2Button(_ sender: Any) {
        self.numStars = 2
    }
    
    @IBAction func stars3Button(_ sender: Any) {
        self.numStars = 3
    }
    
    @IBAction func stars4Button(_ sender: Any) {
        self.numStars = 4
    }
    
    @IBAction func stars5Button(_ sender: Any) {
        self.numStars = 5
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
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
