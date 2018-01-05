//
//  Utility.swift
//  Invoice
//
//  Created by MacMiniOld on 21/06/17.
//  Copyright © 2017 Xongolab. All rights reserved
//
import Foundation
import UIKit
import UserNotifications

var lblNotification : UILabel?
let bounds = UIScreen.main.bounds

var dictGlobal = NSDictionary()
var screenDispDict = NSDictionary()
var arrGlobal = NSArray()
var strGlobal = String()

let appDelegate = UIApplication.shared.delegate as! AppDelegate  //Global appDelegate variable
public var BaseURL : String = "BaseURL"
let TOKEN_URL = "Token"

let APIheaderHash = "Hash-key"
let APIheaderKey = "Header-key"

public var TITLE : String = "App name"
public var MyCrtPressed : Bool = false
public var currency : String = "test"
public var listInfobool : Bool = false
public let reachability = Reachability()!
public let boundsScreen = UIScreen.main.bounds



struct GlobalConstant {
    static let loginAPI = BaseURL + "get_shop_info"
    
}

public var themecolor : UIColor = UIColor(colorLiteralRed: 0.0/255.0, green: 158.0/255.0, blue: 195.0/255.0, alpha: 1.0)

public func ShowAlert (viewController : UIViewController,title : String,message : String)
{
    let alert : UIAlertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
    let action : UIAlertAction = UIAlertAction(title: "Ok", style: .default, handler: nil)
    alert.addAction(action)
    viewController.present(alert, animated: false, completion: nil)
}
public func secondsToHoursMinutesSeconds (seconds : Int) -> (Int, Int, Int) {
    return (seconds / 3600, (seconds % 3600) / 60, (seconds % 3600) % 60)
}
public func getStringFrom(seconds: Int) -> String {
    
    return seconds < 10 ? "0\(seconds)" : "\(seconds)"
}

class Utility: NSObject {
    
    //Singolton function for display globally alert
    class func showAlert(globalAlert:UIViewController,alertTitle:String, andMessage: String)
    {
        let alertController = UIAlertController(title: alertTitle, message: andMessage, preferredStyle: .alert)
        
        let OKAction = UIAlertAction(title: "OK", style: .default) { (action) in
            // ...
        }
        alertController.addAction(OKAction)
    
        globalAlert.present(alertController, animated: true) {
            // ...
        }
    }
    
    //Singolton function for Email validation
    class func isValidEmail(testStr:String) -> Bool {
        // print("validate calendar: \(testStr)")
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
        
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailTest.evaluate(with: testStr)
    }

    //Singolton function for Empty string validation
    class func isStringEmpty(validateString:String)->Bool
    {
       if(validateString.characters.count == 0)
       {
         return true
       }
        if(validateString.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).isEmpty)
       {
         return true
       }
        return false
    }

     //Call function for HomePage Api
    class func ScreenDisplAPI (completion: @escaping (_ success : Bool, _ bookList:NSDictionary) -> Void) {
        
        let homeAPI = "http://postSettings"
        print(homeAPI)
        request(homeAPI, method:.post, encoding:JSONEncoding() as ParameterEncoding, headers: nil).responseJSON
            {
                response in switch response.result {
                case .success(let JSON):
                    print("Success with JSON: \(JSON)")
                    screenDispDict = JSON as! NSDictionary
                    completion(true,screenDispDict)
                    
                case .failure(let error):
                    print("Request failed with error: \(error)")
                    completion(false,screenDispDict)
                    break
                }
        }
    }
    
    class func showActivityIndicatior(_ vc: UIViewController){
        
        for view in (UIApplication.shared.keyWindow?.subviews)! {
            if view is UIView && view.tag == 5001
            {
                view.removeFromSuperview();
            }
        }
        
        let blurView = UIView();
        blurView.frame = vc.view.frame;
        blurView.tag = 5001;
        blurView.backgroundColor = UIColor.black;
        blurView.alpha = 0.7;
        
        let imaviewRing = UIImageView(image: #imageLiteral(resourceName: "loading"))
        imaviewRing.frame = CGRect(x: 0, y: 0, width: #imageLiteral(resourceName: "loading").size.width, height: #imageLiteral(resourceName: "loading").size.height)
        imaviewRing.center = CGPoint(x: vc.view.frame.size.width / 2.0, y: vc.view.frame.size.height / 2.0)
        imaviewRing.rotateAnimation()
        blurView.addSubview(imaviewRing)
        
        UIApplication.shared.keyWindow?.addSubview(blurView)
    }
    
    class func removeActivityIndicatior(){
        
        for view in (UIApplication.shared.keyWindow?.subviews)!
        {
            if view is UIView && view.tag == 5001
            {
                view.removeFromSuperview();
            }
        }
        
    }
    class func showProgressHUD1()
    {
    }
    class func hideProgressHUD1()
    {
        
    }
    class func showProgressHUD()
    {
        SVProgressHUD.show()
        SVProgressHUD.setDefaultAnimationType(SVProgressHUDAnimationType.flat)
        SVProgressHUD.setDefaultMaskType(SVProgressHUDMaskType.black)
    }
    class func hideProgressHUD()
    {
        SVProgressHUD.dismiss()
    }
    
    
    //Create Rechability View for display No Internet connection
    class func createViewForWindow(isShow : Bool)
    {
        if isShow {
            UIView.animate(withDuration: 0.5) { () -> Void in
                UIApplication.shared.setStatusBarHidden(isShow, with: UIStatusBarAnimation.slide)
            }
            if lblNotification == nil {
                lblNotification = UILabel(frame :CGRect(x:0, y:-20, width:bounds.size.width, height:20))
                lblNotification!.textAlignment = .center
                lblNotification!.backgroundColor = UIColor.groupTableViewBackground
                lblNotification?.textColor = UIColor.red
                lblNotification!.text = "No Internet connection"
                lblNotification?.font = UIFont(name: "Roboto-Regular", size: 16.0)
                appDelegate.window?.addSubview(lblNotification!)
                lblNotification?.frame = CGRect(x:0, y:-20, width:bounds.size.width, height:20)
            }
            UIView.animate(withDuration: 0.33, animations: { () -> Void in
                lblNotification!.frame = CGRect(x:0, y:0, width:bounds.size.width, height:20)
            }, completion: { (isFinished) -> Void in
            })
        }
        else {
            UIView.animate(withDuration: 0.5) { () -> Void in
                UIApplication.shared.setStatusBarHidden(isShow, with: UIStatusBarAnimation.slide)
            }
            if lblNotification != nil {
                UIView.animate(withDuration: 0.33, animations: { () -> Void in
                    lblNotification!.frame = CGRect(x:0, y:-20, width:bounds.size.width, height:20)
                }, completion: { (isFinished) -> Void in
                    lblNotification?.removeFromSuperview()
                    lblNotification = nil
                })
            }
        }
    }
    
    //Get Current Timestamp use for current Log activity
    class func getCurrentDateTime()->String
    {
        let todayDay = NSDate()
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS"
        let timeStampString = formatter.string(from: todayDay as Date)
        
        return timeStampString
    }
}
extension UIView
{
    func rotateAnimation(_ duration : CFTimeInterval = 2.0)
    {
        let rotationAni = CABasicAnimation(keyPath: "transform.rotation")
        rotationAni.fromValue = 0.0
        rotationAni.toValue = CGFloat(Double.pi * 2.0)
        rotationAni.duration = duration
        rotationAni.repeatCount = Float.greatestFiniteMagnitude
        self.layer.add(rotationAni, forKey: nil)
    }
}
//Extension for Image to change color of image Tint color
extension UIImage {
    func imageWithColor(tintColor: UIColor) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(self.size, false, self.scale)
        
        let context = UIGraphicsGetCurrentContext()! as CGContext
        context.translateBy(x: 0, y: self.size.height)
        context.scaleBy(x: 1.0, y: -1.0);
        context.setBlendMode(CGBlendMode.normal)

        let rect = CGRect(x: 0, y: 0, width: self.size.width, height:  self.size.height)
        context.clip(to: rect, mask: self.cgImage!)
        tintColor.setFill()
        context.fill(rect)
        
        let newImage = UIGraphicsGetImageFromCurrentImageContext()! as UIImage
        UIGraphicsEndImageContext()
        
        return newImage
    }
}

//Extension Lable to display HTML data as received from APi
extension UILabel {
    func from(html: String) {
        
        let newHtmlString = html.replacingOccurrences(of: "\n\n<p>", with: "\n<p><center>")
        
        if let htmlData = newHtmlString.data(using: String.Encoding.unicode) {
            do {
                let attribString : NSAttributedString =  try NSAttributedString(data: htmlData,
                                                             options: [NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType],
                                                             documentAttributes: nil)
                self.attributedText = attribString
                
            } catch let e as NSError {
                print("Couldn't parse \(html): \(e.localizedDescription)")
            }
        }
    }
}


extension UIView {
    
    //Show shadow on PopUP Views
    func dropShadow() {
        
        // corner radius
        self.layer.cornerRadius = 10
        
        // border
        self.layer.borderWidth = 0.0
        self.layer.borderColor = UIColor.black.cgColor
        
        // shadow
        self.layer.shadowColor = UIColor(white: 0.0, alpha: 0.8).cgColor
        self.layer.shadowOffset = CGSize(width: 0.0, height: 0.0)
        self.layer.shadowOpacity = 1.0
        self.layer.shadowRadius = 6.0
    }
    
    //Animation of views in one viewcontroler
    func addAnimationRightToLeft() {
        let slideInFromLeftTransition = CATransition()
        // Customize the animation's properties
        slideInFromLeftTransition.type = kCATransitionPush
        slideInFromLeftTransition.subtype = kCATransitionFromRight
        slideInFromLeftTransition.duration = 0.5
        slideInFromLeftTransition.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
        slideInFromLeftTransition.fillMode = kCAFillModeRemoved
        
        // Add the animation to the View's layer
        self.layer.add(slideInFromLeftTransition, forKey: "slideInFromLeftTransition")
    }
    func addAnimationLeftToRight() {
        let slideInFromLeftTransition = CATransition()
        // Customize the animation's properties
        slideInFromLeftTransition.type = kCATransitionPush
        slideInFromLeftTransition.subtype = kCATransitionFromLeft
        slideInFromLeftTransition.duration = 0.5
        slideInFromLeftTransition.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
        slideInFromLeftTransition.fillMode = kCAFillModeRemoved
        
        // Add the animation to the View's layer
        self.layer.add(slideInFromLeftTransition, forKey: "slideInFromLeftTransition")
    }
    func addAnimationtToptoBottom() {
        let transition:CATransition = CATransition()
        transition.duration = 0.5
        transition.type = kCATransitionPush
        transition.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseOut)
        transition.subtype = kCATransitionFromTop
        self.layer.add(transition, forKey: kCATransition)
    }
    func addAnimationtBottomtoTop() {
        let transition:CATransition = CATransition()
        transition.duration = 0.5
        transition.type = kCATransitionPush
        transition.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseIn)
        transition.subtype = kCATransitionFromBottom
        self.layer.add(transition, forKey: kCATransition)
    }
}

//Extension String to display HTML data as received from APi
extension String {
    var html2AttributedString: NSAttributedString? {
        guard let data = data(using: .utf8) else {
            return nil
        }
        
        do {
            return try NSAttributedString(data: data, options: [NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType, NSCharacterEncodingDocumentAttribute: String.Encoding.utf8.rawValue], documentAttributes: nil)
        }
        catch {
            print(error.localizedDescription)
            return nil
        }
    }
    
    public func getHtml2AttributedString(font: UIFont?) -> NSAttributedString? {
        guard let font = font else {
            return html2AttributedString
        }
        
        let modifiedString = "<style>body{font-family: '\(font.fontName)'; font-size:\(font.pointSize)px;}</style>\(self)";
        
        guard let data = modifiedString.data(using: .utf8) else {
            return nil
        }
        
        do {
            return try NSAttributedString(data: data, options: [NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType, NSCharacterEncodingDocumentAttribute: String.Encoding.utf8.rawValue], documentAttributes: nil)
        }
        catch {
            print(error)
            return nil
        }
    }
}

//Set Date Formate extension
extension NSDate {
    var formatted: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd-MM-yyyy"
        return formatter.string(from: self as Date)
    }
    func add(minutes: Int) -> NSDate {
        return Calendar(identifier: .gregorian).date(byAdding: .minute, value: minutes, to: self as Date)! as NSDate
    }
}
extension String {
    var asNSDate:NSDate {
        let styler = DateFormatter()
        styler.dateFormat = "dd-MM-yyyy"
        return styler.date(from: self) as NSDate? ?? NSDate()
    }
}
extension Date {
    func add(minutes: Int) -> Date {
        return Calendar(identifier: .gregorian).date(byAdding: .minute, value: minutes, to: self)!
    }
}

//Compare Date  extension
extension NSDate {
    func isGreaterThanDate(dateToCompare: NSDate) -> Bool {
        //Declare Variables
        var isGreater = false
        
        //Compare Values
        if self.compare(dateToCompare as Date) == ComparisonResult.orderedDescending {
            isGreater = true
        }
        
        //Return Result
        return isGreater
    }
    
    func isLessThanDate(dateToCompare: NSDate) -> Bool {
        //Declare Variables
        var isLess = false
        
        //Compare Values
        if self.compare(dateToCompare as Date) == ComparisonResult.orderedAscending {
            isLess = true
        }
        
        //Return Result
        return isLess
    }
    
    func equalToDate(dateToCompare: NSDate) -> Bool {
        //Declare Variables
        var isEqualTo = false
        
        //Compare Values
        if self.compare(dateToCompare as Date) == ComparisonResult.orderedSame {
            isEqualTo = true
        }
        
        //Return Result
        return isEqualTo
    }
    
    func addDays(daysToAdd: Int) -> NSDate {
        let secondsInDays: TimeInterval = Double(daysToAdd) * 60 * 60 * 24
        let dateWithDaysAdded: NSDate = self.addingTimeInterval(secondsInDays)
        
        //Return Result
        return dateWithDaysAdded
    }
    
    func addHours(hoursToAdd: Int) -> NSDate {
        let secondsInHours: TimeInterval = Double(hoursToAdd) * 60 * 60
        let dateWithHoursAdded: NSDate = self.addingTimeInterval(secondsInHours)
        
        //Return Result
        return dateWithHoursAdded
    }
}

//Extension for array to remove duplicate values
extension Array where Element:Equatable {
    func removeDuplicates() -> [Element] {
        var result = [Element]()
        
        for value in self {
            if result.contains(value) == false {
                result.append(value)
            }
        }
        
        return result
    }
}

//Manage Notification Extension
extension UIViewController:UNUserNotificationCenterDelegate {
    
    //for displaying notification when app is in foreground
    @available(iOS 10.0, *)
    public func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        
        UIApplication.shared.applicationIconBadgeNumber = 0
        
        completionHandler([.alert,.badge])
    }
    
    // For handling tap and user actions
    @available(iOS 10.0, *)
    public func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        switch response.actionIdentifier {
        case "action1":
            print("Action First Tapped")
            
            UNMutableNotificationContent().badge = (UIApplication.shared.applicationIconBadgeNumber - 1) as NSNumber
            break
        case "action2":
            print("Action Second Tapped")
             UNMutableNotificationContent().badge = (UIApplication.shared.applicationIconBadgeNumber - 1) as NSNumber
            break
        default:
            break
        }
        completionHandler()
    }
}

extension UICollectionView {
    func reloadWithoutAnimation(){
        CATransaction.begin()
        CATransaction.setValue(kCFBooleanTrue, forKey: kCATransitionFromTop)
        self.reloadData()
        CATransaction.commit()
    }
}

extension UIColor {
    convenience init(hexString: String) {
        let hex = hexString.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int = UInt32()
        Scanner(string: hex).scanHexInt32(&int)
        let a, r, g, b: UInt32
        switch hex.characters.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(red: CGFloat(r) / 255, green: CGFloat(g) / 255, blue:      CGFloat(b) / 255, alpha: CGFloat(a) / 255)
    }
}

extension NSRange {
    func range(for str: String) -> Range<String.Index>? {
        guard location != NSNotFound else { return nil }
        
        guard let fromUTFIndex = str.utf16.index(str.utf16.startIndex, offsetBy: location, limitedBy: str.utf16.endIndex) else { return nil }
        guard let toUTFIndex = str.utf16.index(fromUTFIndex, offsetBy: length, limitedBy: str.utf16.endIndex) else { return nil }
        guard let fromIndex = String.Index(fromUTFIndex, within: str) else { return nil }
        guard let toIndex = String.Index(toUTFIndex, within: str) else { return nil }
        
        return fromIndex ..< toIndex
    }
}
extension String {
    func condenseWhitespace() -> String {
        return self.components(separatedBy: CharacterSet.whitespacesAndNewlines)
            .filter { !$0.isEmpty }
            .joined(separator: "")
    }
}

//Public get data
public func GetApiData (url : URLConvertible,method:HTTPMethod,param:Parameters,encoding:ParameterEncoding,completion:@escaping (_ apiresponse:NSDictionary)-> Void)
{
    
    request(url, method: method, parameters: param, encoding: encoding).responseJSON { (response:DataResponse<Any>) in
        //print(response.result.value)
        if response.result.value == nil
        {
            //ShowAlert(controller: self, title: "Aktivo", messaeg: notRespondeMessage)
            return
        }
        if (response.result.value != nil)
        {
            if ((response.result.value as AnyObject).value(forKey: "msg") as! NSNumber == 1)
            {
                let myCaloriesData = (response.result.value as AnyObject).value(forKey: "data") as! NSDictionary
                
                completion(myCaloriesData)
                HUD.hide()
            }
            else
            {
                HUD.hide()
                ShowAlert(controller: (appdelegate.window?.rootViewController)!, title: "Message", messaeg: (response.result.value as AnyObject).value(forKey: "mobile_message") as! String )
            }
        }
        else
        {
            HUD.hide()
        }
    }
}
