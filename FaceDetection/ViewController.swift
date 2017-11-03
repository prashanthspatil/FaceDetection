//
//  ViewController.swift
//  FaceDetection
//
//  Created by Prashanth on 30/08/17.
//  Copyright © 2017 Prashanth. All rights reserved.
//

import UIKit
import Vision

class ViewController: UIViewController {

    @IBOutlet weak var dateTextField: UITextField!
    @IBOutlet weak var dateTextField1: UITextField!
    @IBOutlet weak var dateTextField2: UITextField!
    var dates = [UITextField: Date]()
    var datepicker: UIDatePicker?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setUpTextFields()
        detectFaces()
        for symbol: String in Thread.callStackSymbols {
            print(symbol)
        }
    }

    @objc func datePickerValueChanged() {
        if dateTextField.isEditing {
            //dates?.updateValue(datepicker!.date, forKey: dateTextField)
            dates.updateValue(datepicker!.date, forKey: dateTextField)
            dateTextField.text = String(describing: datepicker!.date)
        } else if dateTextField1.isEditing {
            dates.updateValue(datepicker!.date, forKey: dateTextField1)
            dateTextField1.text = String(describing: datepicker!.date)
        } else if dateTextField2.isEditing {
            dates.updateValue(datepicker!.date, forKey: dateTextField2)
            dateTextField2.text = String(describing: datepicker!.date)
        }
    }
    
    @objc func datePickerDoneAction() {
        dateTextField.resignFirstResponder()
        dateTextField1.resignFirstResponder()
        dateTextField2.resignFirstResponder()
        ascendingOrderDates()
    }
    
    func ascendingOrderDates() {
        let sortedDates = dates.values.sorted(by: { $0.compare($1) == .orderedAscending })
        print(sortedDates)
        
        zip(dates, sortedDates).forEach {
            let sortedDate = $1
            let field = $0
            field.key.text = String(describing: sortedDate)
            print(field.key.accessibilityIdentifier!, sortedDate)
        }
    }
    
    func setUpTextFields() {
        datepicker = UIDatePicker(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
        datepicker!.datePickerMode = .date
        datepicker!.addTarget(self, action: #selector(self.datePickerValueChanged), for: .valueChanged)
        
        let toolbar = UIToolbar(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: 44))
        toolbar.barStyle = .default
        let flexibleSpaceLeft = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let doneButton = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(self.datePickerDoneAction))
        toolbar.setItems([flexibleSpaceLeft, doneButton], animated: true)
        
        dateTextField.accessibilityIdentifier = "dateTextField"
        dateTextField.inputAccessoryView = toolbar
        dateTextField.inputView = datepicker
        
        dateTextField1.accessibilityIdentifier = "dateTextField1"
        dateTextField1.inputAccessoryView = toolbar
        dateTextField1.inputView = datepicker
        
        dateTextField2.accessibilityIdentifier = "dateTextField2"
        dateTextField2.inputAccessoryView = toolbar
        dateTextField2.inputView = datepicker
    }
    
    func detectFaces() {
        guard let image = UIImage(named: "MultipleFaces") else { return }
        let imageView = UIImageView(image: image)
        
        let scaledHeight = view.frame.width/image.size.width * image.size.height
        imageView.frame = CGRect(x: 0, y: 20, width: view.frame.width, height: scaledHeight)
        view.addSubview(imageView)
        
        let request = VNDetectFaceRectanglesRequest { (req, err) in
            if let err = err {
                print("failed to detect faces \(err)")
            }
            req.results?.forEach({ (res) in
                guard let faceObservation = res as? VNFaceObservation else { return }
                DispatchQueue.main.async {
                    let x = self.view.frame.width * faceObservation.boundingBox.origin.x
                    let height = scaledHeight * faceObservation.boundingBox.height
                    let y = scaledHeight * (1 - faceObservation.boundingBox.origin.y) - height
                    let width = self.view.frame.width * faceObservation.boundingBox.width
                    
                    let redView = UIView()
                    redView.backgroundColor = .red
                    redView.frame = CGRect(x: x, y: y+20, width: width, height: height)
                    redView.alpha = 0.4
                    self.view.addSubview(redView)
                    
                    print(faceObservation.boundingBox)
                }
            })
        }
        guard let cgImage = image.cgImage else { return }
        DispatchQueue.global(qos: .utility).async {
            let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])
            do {
                try handler.perform([request])
            } catch let reqErr {
                print("reqErr \(reqErr)")
            }
        }
    }
}
