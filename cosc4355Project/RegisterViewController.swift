//
//  RegisterViewController.swift
//  cosc4355Project
//
//  Created by Ron Borneo on 9/21/17.
//  Copyright © 2017 cosc4355. All rights reserved.
//

import UIKit
import Firebase

/**
 *  HEAVY CODE DUPLICATION IN THIS CLASS WITH ProjectFormViewController
 *  Must refactor.
 */


class RegisterViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate {
  
  @IBOutlet weak var profilePicture: UIImageView!
  
  @IBOutlet weak var emailText: UITextField!
  
  @IBOutlet weak var passwordText: UITextField!
  
  @IBOutlet weak var confirmPasswordText: UITextField!
  
  @IBOutlet weak var nameText: UITextField!
  
  /* Handle registration */
  @IBAction func register(_ sender: UIButton) {
    if !isFieldsValid() { return }
    
    /* Standard user registration */
    FIRAuth.auth()?.createUser(withEmail: emailText.text!, password: passwordText.text!) { (user, error) in
      if let error = error {
        print("Error creating new user: \(error)")
        return
      }
      print("Created user: \(String(describing: user?.uid))")
      guard let uid = user?.uid else { return }
      
      /* STORE USER PROFILE */
      let storageRef = FIRStorage.storage().reference().child("profilePics").child("\(uid).jpg")
      if let profilePic = self.profilePicture.image, let uploadData = UIImageJPEGRepresentation(profilePic, 0.1) {
        storageRef.put(uploadData, metadata: nil) { (metadata, error) in
          if let error = error { print(error); return }
          print("Succesful Photo Upload")
          if let projectImageUrl = metadata?.downloadURL()?.absoluteString {
            let values = ["name": self.nameText.text!, "profilePicture": projectImageUrl, "email": user?.email!, "userType": "client"] as [String: AnyObject]
            self.registerInfoIntoDatabaseWithUID(uid: uid, values: values)
          }
        }
      }
    
      self.emailText.text = ""
      self.passwordText.text = ""
      self.confirmPasswordText.text = ""
      self.dismiss(animated: true, completion: nil)
    }
  }
  
  @IBAction func goBackButton(_ sender: UIButton) {
    dismiss(animated: true, completion: nil)
  }
  
  func isFieldsValid() -> Bool {
    if emailText.text! == "" || passwordText.text! == "" || confirmPasswordText.text! == "" || nameText.text! == "" {
      print("Error: Empty field indicated")
      return false
    }
    if passwordText.text! != confirmPasswordText.text! {
      print("Error: Passwords does not match")
      return false
    }
    return true
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    profilePicture.layer.cornerRadius = 64
    profilePicture.layer.masksToBounds = true
    // Do any additional setup after loading the view.
    
    profilePicture.isUserInteractionEnabled = true
    let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handlePhotoUpload))
    profilePicture.addGestureRecognizer(tapGesture)
    
    emailText.delegate = self
    passwordText.delegate = self
    confirmPasswordText.delegate = self
    nameText.delegate = self
  }
  
  func textFieldShouldReturn(_ textField: UITextField) -> Bool {
    return true
  }
  
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
  
  func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
    var selectedImage: UIImage?
    if let editedImage = info["UIImagePickerControllerEditedImage"] as? UIImage {
      selectedImage = editedImage
    } else if let originalImage = info["UIImagePickerControllerOriginalImage"] as? UIImage {
      selectedImage = originalImage
    }
    if let image = selectedImage {
      profilePicture.image = image
    }
    
    dismiss(animated: true, completion: nil)
  }
  
  func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
    dismiss(animated: true, completion: nil)
  }
  
  private func registerInfoIntoDatabaseWithUID(uid: String, values: [String: AnyObject]) {
    let ref = FIRDatabase.database().reference(fromURL: "https://cosc4355project.firebaseio.com/")
    let projectsReference = ref.child("users").child(uid)
    projectsReference.updateChildValues(values) { (err, ref) in
      if(err != nil) {
        print("Error Occured: \(err!)")
        return
      }
    }
  }
}
