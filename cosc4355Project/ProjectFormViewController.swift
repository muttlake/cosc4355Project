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
    
    /* Tap gesture utilized when the user taps on the UIImageView above the post button. */
    uploadImage.isUserInteractionEnabled = true
    let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handlePhotoUpload))
    self.uploadImage.addGestureRecognizer(tapGesture)
  
  }
  
  /* Sets the selected imaged based on whether it was edited or not */
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
    dismiss(animated: true, completion: nil)
  }
  
  /* Sets up a choice between camera roll or using the camera itself. Keep note that the simulator does NOT have a camera. */
  func handlePhotoUpload() {
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
    
    cameraOrPhotoAlbum.addActions(actions: cameraOption, photoAlbumOption, cancelOption)
    present(cameraOrPhotoAlbum, animated: true, completion: nil)
  }
  
  
  @IBAction func postButton(_ sender: UIButton) {
    guard let title = titleInput.text, let category = categoryInput.text, let description = descriptionInput.text else { return }
    if !validateFields(fields: title, category, description) { return }
    
    let imageName = NSUUID().uuidString
    let storageRef = FIRStorage.storage().reference().child("projects").child("\(imageName).jpg")
    
    if let projectImage = uploadImage.image, let uploadData = UIImageJPEGRepresentation(projectImage, 0.1) {
      storageRef.put(uploadData, metadata: nil) { (metadata, error) in
        if let error = error { print(error); return }
        
        /* Set up date */
        let currentDate = Date.currentDate
        
        /* Get current user id */
        guard let uid = FIRAuth.auth()?.currentUser?.uid else { print("Error: User not signed in"); return }
 
        /* Generate projectId, get values, then store into database */
        if let projectImageUrl = metadata?.downloadURL()?.absoluteString {
          let projectId = UUID().uuidString
          let values = ["title": title, "description": description, "status": String(describing: Status.pending), "category": String(describing: ProjectCategory.general), "date": currentDate, "photoUrl": projectImageUrl, "startingBid": "0", "acceptedBid": "0", "location": Address().toString(), "posting_id": projectId, "user_id": uid]
          self.registerInfoIntoDatabaseWithUID(uid: projectId, values: values as [String: AnyObject])
          self.navigationController?.popViewController(animated: true)
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
  
  /* Makes sure every field is not blank. */
  private func validateFields(fields: String...) -> Bool {
    for field in fields {
      if field == "" {
        return false
      }
    }
    return true
  }
}

/* Generates a date string in the desired format */
extension Date {
  static var currentDate: String {
    let date = Date()
    let formatter = DateFormatter()
    formatter.timeZone = TimeZone(abbreviation: "CDT")
    formatter.dateFormat = "MM.dd.yyyy hh:mm:ss"
    return formatter.string(from: date)
  }
}

/* Adds a list of actions to the alert controller item */
extension UIAlertController {
  func addActions(actions: UIAlertAction...) {
    for action in actions {
      addAction(action)
    }
  }
}
