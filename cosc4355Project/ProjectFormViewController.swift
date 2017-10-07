//
//  ProjectFormViewController.swift
//  cosc4355Project
//
//  Created by Ron Borneo on 10/6/17.
//  Copyright © 2017 cosc4355. All rights reserved.
//

import UIKit
import Firebase

class ProjectFormViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
  
  @IBOutlet weak var uploadImage: UIImageView!
  
  @IBOutlet weak var titleInput: UITextField!
  
  @IBOutlet weak var categoryInput: UITextField!
  
  @IBOutlet weak var descriptionInput: UITextView!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    uploadImage.isUserInteractionEnabled = true
    let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handlePhotoUpload))
    self.uploadImage.addGestureRecognizer(tapGesture)
  
  }
  
  func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
    var selectedImage: UIImage?
    if let editedImage = info["UIImagePickerControllerEditedImage"] as? UIImage {
      selectedImage = editedImage
    } else if let originalImage = info["UIImagePickerControllerOriginalImage"] as? UIImage {
      selectedImage = originalImage
    }
    
    if let image = selectedImage {
      uploadImage.image = image
    }
    
    dismiss(animated: true, completion: nil)
  }
  
  func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
    print("Cancelled Picker")
    dismiss(animated: true, completion: nil)
  }
  
  func handlePhotoUpload() {
    print("uploading")
    
    let cameraOrPhotoAlbum = UIAlertController(title: "Source", message: "Photo Source", preferredStyle: .actionSheet)
    
    let picker = UIImagePickerController()
    picker.delegate = self
    picker.allowsEditing = true
    
    let cameraOption = UIAlertAction(title: "Camera", style: .default) { (_) in
      picker.sourceType = .camera
      self.present(picker, animated: true, completion: nil)
    }
    
    let photoAlbumOption = UIAlertAction(title: "Photo Album", style: .default) { (_) in
      self.present(picker, animated: true, completion: nil)
    }
    let cancelOption = UIAlertAction(title: "Cancel", style: .cancel) { (_: UIAlertAction) in print("cancelled") }
    
    cameraOrPhotoAlbum.addAction(cameraOption)
    cameraOrPhotoAlbum.addAction(photoAlbumOption)
    cameraOrPhotoAlbum.addAction(cancelOption)
    present(cameraOrPhotoAlbum, animated: true, completion: nil)
  }
  
  
  @IBAction func postButton(_ sender: UIButton) {
    if titleInput.text! == "" || categoryInput.text! == "" || descriptionInput.text! == "" {
      print("Empty Fields")
      return
    }
    
    let imageName = NSUUID().uuidString
    let storageRef = FIRStorage.storage().reference().child("projects").child("\(imageName).jpg")
    if let projectImage = uploadImage.image, let uploadData = UIImageJPEGRepresentation(projectImage, 0.1) {
      storageRef.put(uploadData, metadata: nil) { (metadata, error) in
        print("TEST")
        if(error != nil) {
          print("Error Occured: \(error!)")
          return
        }
        
        /* Set up date */
        let date = Date()
        let formatter = DateFormatter()
        formatter.timeZone = TimeZone(abbreviation: "CDT")
        formatter.dateFormat = "MM.dd.yyyy hh:mm:ss"
        let dateString = formatter.string(from: date)
        
        /* Get current user id */
        guard let uid = FIRAuth.auth()?.currentUser?.uid else {
          print("Must be signed in to upload")
          return
        }
 
        /* Generate projectId, get values, then store into database */
        if let projectImageUrl = metadata?.downloadURL()?.absoluteString {
          let projectId = UUID().uuidString
          let values = ["title": self.titleInput.text!, "description": self.descriptionInput.text!, "status": String(describing: Status.pending), "date": dateString, "photoUrl": projectImageUrl, "startingBid": "0", "acceptedBid": "0", "location": Address().toString(), "posting_id": projectId, "user_id": uid]
          self.registerInfoIntoDatabaseWithUID(uid: projectId, values: values as [String: AnyObject])
        }
      }
    }
  }
  
  private func registerInfoIntoDatabaseWithUID(uid: String, values: [String: AnyObject]) {
    let ref = FIRDatabase.database().reference(fromURL: "https://cosc4355project.firebaseio.com/")
    let projectsReference = ref.child("projects").child(uid)
    projectsReference.updateChildValues(values) { (err, ref) in
      if(err != nil) {
        print("Error Occured: \(err!)")
        return
      }
    }
  }
  
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
}
