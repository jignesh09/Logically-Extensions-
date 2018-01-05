//
//  Utility.swift
//  MyApp
//
//  Copyright © 2017 myCompany. All rights reserved.
//

import Foundation
import UIKit

class headerCell: UITableViewCell {}

public var KKrange:Double = 0
public var BASEURL = "https://www.google.com"


struct appFonts
{
    static let black = "Montserrat-Black"
    static let BlackItalic = "Montserrat-BlackItalic"
    static let Bold = "Montserrat-Bold"
    static let BoldItalic = "Montserrat-BoldItalic"
    static let ExtraBold = "Montserrat-ExtraBold"
    static let ExtraBoldItalic = "Montserrat-ExtraBoldItalic"
    static let ExtraLight = "Montserrat-ExtraLight"
    static let ExtraLightItalic = "Montserrat-ExtraLightItalic"
    static let Italic = "Montserrat-Italic"
    static let Light = "Montserrat-Light"
    static let LightItalic = "Montserrat-LightItalic"
    static let Medium = "Montserrat-Medium"
    static let MediumItalic = "Montserrat-MediumItalic"
    static let Regular = "Montserrat-Regular"
    static let SemiBold = "Montserrat-SemiBold"
    static let SemiBoldItalic = "Montserrat-SemiBoldItalic"
    static let Thin = "Montserrat-Thin"
    static let ThinItalic = "Montserrat-ThinItalic"
}

extension UIScrollView {
    var currentPage: Int {
        return Int((self.contentOffset.x + (0.5*self.frame.size.width))/self.frame.width) + 1
    }
    func scrollToPage(index: UInt8, animated: Bool, after delay: TimeInterval) {
        let offset: CGPoint = CGPoint(x: CGFloat(index) * frame.size.width, y: 0)
        DispatchQueue.main.asyncAfter(deadline: .now() + delay, execute: {
            self.setContentOffset(offset, animated: animated)
        })
    }
}

extension String{
    func convertHtml() -> NSAttributedString{
        guard let data = data(using: .utf8) else { return NSAttributedString() }
        do{
            return try NSAttributedString(data: data, options: [NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType, NSCharacterEncodingDocumentAttribute: String.Encoding.utf8.rawValue], documentAttributes: nil)
        }catch{
            return NSAttributedString()
        }
    }
}

extension UIImageView
{
    func addBlurEffect()
    {
        let blurEffect = UIBlurEffect(style: UIBlurEffectStyle.light)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame = self.bounds
        
        blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight] // for supporting device rotation
        self.addSubview(blurEffectView)
    }
    func setRound() {
        self.layer.cornerRadius = self.frame.size.width / 2
        self.clipsToBounds = true
    }

}

//load image from url
extension UIImageView {
    public func imageFromURL(urlString: String) {
        
        let activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: .gray)
        activityIndicator.frame = CGRect.init(x: 0, y: 0, width: self.frame.size.width, height: self.frame.size.height)
        activityIndicator.startAnimating()
        if self.image == nil{
            self.addSubview(activityIndicator)
        }
        
        URLSession.shared.dataTask(with: NSURL(string: urlString)! as URL, completionHandler: { (data, response, error) -> Void in
            
            if error != nil {
                print(error ?? "No Error")
                return
            }
            DispatchQueue.main.async(execute: { () -> Void in
                let image = UIImage(data: data!)
                activityIndicator.removeFromSuperview()
                self.image = image
            })
            
        }).resume()
    }
}
//Check Valid Email
extension String {
    func isValidEmail() -> Bool {
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        return NSPredicate(format: "SELF MATCHES %@", emailRegex).evaluate(with: self)
    }
}
//Custome Popup for validation
public func popupView(_ view: UIViewController, message:String)
{
    let storyboard = UIStoryboard(name: "Main", bundle: nil)
    let controller = storyboard.instantiateViewController(withIdentifier: "popupVCViewController") as! popupVCViewController
    controller.cusMessage = message
    controller.modalPresentationStyle = UIModalPresentationStyle.overCurrentContext
    controller.modalTransitionStyle = .coverVertical
    
    view.present(controller, animated: true, completion: nil)
}



