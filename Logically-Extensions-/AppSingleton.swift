//
//  AppSingleton.swift
//  MyApp
//
//  Copyright © 2017 myCompany. All rights reserved.
//

import UIKit
import ReachabilitySwift
import SystemConfiguration
import CoreData
import BRYXBanner
import TCBlobDownloadSwift

typealias SOSingltonCompletionHandler = (_ obj:AnyObject?, _ success:Bool?) -> Void

class AppSingleton: NSObject,NSURLConnectionDelegate,TCBlobDownloadDelegate
{
    typealias reloadFavoriteCompletionHandler = (_ isFav: String,_ section: Int,_ index: Int, _ type: String) -> Void
    var updateData : reloadFavoriteCompletionHandler?
    
    typealias reloadPurchaseCompletionHandler = (_ isPurchase: String,_ section: Int,_ index: Int, _ type: String) -> Void
    var updatePurchaseData : reloadPurchaseCompletionHandler?
    
    typealias reloadPurchaseMusicCompletionHandler = (_ isPurchase: String,_ section: Int,_ index: Int) -> Void
    var updateMusicPurchaseData : reloadPurchaseMusicCompletionHandler?
    
    
    typealias changeOfflineSong = (_ array: [Sauteez_Download],_ index: Int,_ songtitle: String, _ username: String) -> Void
    var updateOfflineSong : changeOfflineSong?
    
    typealias changeOnlineSong = (_ array: [SongData],_ index: Int,_ section: Int,_ songtitle: String, _ username: String,_ type: String) -> Void
    var updateOnlineSong : changeOnlineSong?
    
    
    typealias CompletionHandler = (_ success:Bool, _ response : NSDictionary) -> Void
    typealias CompletionHandlerSong = (_ success:Bool, _ tempSongData : [SongData]? ) -> Void

    static var instance: AppSingleton!
    
    var strTimeStamp : String!
    var strNonce : String!
    var strToken : String!
    
    var container: UIView = UIView()
    var tempView: UIView = UIView()

    var loadingView: UIView = UIView()
    var activityIndicator: UIActivityIndicatorView = UIActivityIndicatorView()
    
    var overlayView = UIView()
    let reachability = Reachability()!
    
    var banner = Banner()
    
    let manager = TCBlobDownloadManager.sharedInstance
    let managedObjectContext = AppDelObj.managedObjectContext
    
    var downloads = [TCBlobDownload]()
    
    // SHARED INSTANCE
    class func sharedInstance() -> AppSingleton {
        self.instance = (self.instance ?? AppSingleton())
        return self.instance
    }
    
    
    
    //MARK:- Network Rechability
    /// Check newtork is available or not
    func isConnectedToNetwork() -> Bool
    {
        if reachability.isReachable
        {
            return true
        }
        else
        {
            return false
        }
    }
    
    
    
    func getPathOfFile(_ fileName : String) -> String
    {
        let paths = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.documentDirectory, FileManager.SearchPathDomainMask.userDomainMask, true)
        let documentsDirectory: AnyObject = paths[0] as AnyObject
        let getPath = (documentsDirectory as! NSString).appendingPathComponent(fileName)
        return getPath
    }
    
    func saveToPath() -> AnyObject
    {
        let paths = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.documentDirectory, FileManager.SearchPathDomainMask.userDomainMask, true)
        let documentsDirectory: AnyObject = paths[0] as AnyObject
        let datapath : String = documentsDirectory.appendingPathComponent("/Download") as String
        return datapath as AnyObject
    }

    
    //MARK: - Border of view && Make Image Round
    
    func borderView(_ borderview : AnyObject, cornerRadius : CGFloat ,borderWidth : CGFloat, borderColor : UIColor)
    {
        borderview.layer.masksToBounds = true
        borderview.layer.borderWidth = borderWidth
        borderview.layer.borderColor = borderColor.cgColor
        borderview.layer.cornerRadius = cornerRadius
    }
    
    func CircleImageview(_ imageview : UIImageView) -> UIImageView
    {
        let imgProfile : UIImageView = imageview
        imgProfile.layer.masksToBounds = false
        imgProfile.layer.cornerRadius = imgProfile.frame.height/2
        imgProfile.clipsToBounds = true
        
        return imgProfile
    }
    
    func rgbColor(_ red : CGFloat , green : CGFloat ,blue : CGFloat) -> UIColor
    {
        return UIColor(red: red/255.0, green: green/255.0, blue: blue/255.0, alpha: 1.0)
    }
    
    func convertDate(_ timeStamp : Int, originalFormate : String, convertFormate : String)-> String
    {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = originalFormate//this your string date format
        let tempDate = dateFormatter.string(from: NSDate.init(timeIntervalSince1970: Double(timeStamp)) as Date)
        
        let date = dateFormatter.date(from: tempDate)
        
        dateFormatter.dateFormat = convertFormate///this is you want to convert format
        let timeStamp = dateFormatter.string(from: date!)
        return timeStamp
    }
    
    //MARK:- Play Music
    
    func playMusicOffline(_ tabView : UITabBarController,arrSong : [Sauteez_Download] ,index : Int, songName : String, userName : String, SongImage : String)
    {
        AppDelObj.isOffline = true
        SharedFunctionObj.setBool(true, key: "isOffline")
        SharedFunctionObj.setObject("" as AnyObject, key: Current_Song_Album)

        SharedFunctionObj.setBool(true, key: Play_First_Time)
        MusicBar_Current_Image = SongImage
        SharedFunctionObj.setObject(songName as AnyObject?, key: Current_Song_Name)
        SharedFunctionObj.setObject(SongImage as AnyObject?, key: Current_Song_Image)
        SharedFunctionObj.setObject(userName as AnyObject?, key: Current_Song_Artist)

        if AppDelObj.isPlaying
        {
            self.updateOfflineSong!(arrSong,index,songName,userName)
            return
        }
        else
        {
            let popupContentController : MusicPlayerVC = POPUP_STORYBOARD.instantiateViewController(withIdentifier: "MusicPlayerVC") as! MusicPlayerVC
            popupContentController.popupItem.accessibilityHint = NSLocalizedString("Double Tap to Expand the Mini Player", comment: "")
            
            popupContentController.songArray = arrSong
            AppDelObj.indexRow = index
            popupContentController.songTitle = songName
            popupContentController.UserTitle = userName
            tabView.popupContentView.popupCloseButton?.setImage(UIImage(named : "arrow"), for: .normal)
            tabView.presentPopupBar(withContentViewController: popupContentController, openPopup: true, animated: true, completion: nil)
        }
    }
    
    func playMusic(_ tabView : UITabBarController,arrSong : [SongData] ,index : Int, songName : String, userName : String, SongImage : String, type: String? = nil, section : Int)
    {
        AppDelObj.isOffline = false
        SharedFunctionObj.setBool(false, key: "isOffline")

        SharedFunctionObj.setBool(true, key: Play_First_Time)
        MusicBar_Current_Image = SongImage
        SharedFunctionObj.setObject(songName as AnyObject?, key: Current_Song_Name)
        SharedFunctionObj.setObject(SongImage as AnyObject?, key: Current_Song_Image)
        SharedFunctionObj.setObject(userName as AnyObject?, key: Current_Song_Artist)

        if AppDelObj.isPlaying
        {
            if type != nil
            {
                self.updateOnlineSong!(arrSong,index,section,songName,userName,type!)
            }
            else
            {
                self.updateOnlineSong!(arrSong,index,section,songName,userName,"")
            }
            return
        }
        else
        {
            let popupContentController : MusicPlayerVC = POPUP_STORYBOARD.instantiateViewController(withIdentifier: "MusicPlayerVC") as! MusicPlayerVC
            popupContentController.popupItem.accessibilityHint = NSLocalizedString("Double Tap to Expand the Mini Player", comment: "")
            if type != nil
            {
                popupContentController.type = type!
            }
            popupContentController.arrSong = arrSong
            popupContentController.selectedIndex = index
            popupContentController.selectedSection = section
            popupContentController.songTitle = songName
            popupContentController.UserTitle = userName
            
            tabView.popupContentView.popupCloseButton?.setImage(UIImage(named : "arrow"), for: .normal)
            tabView.presentPopupBar(withContentViewController: popupContentController, openPopup: true, animated: true, completion: nil)
        }
    }
    
    //MARK: - Custom Method
    
    func addBanner(_ title : String, text : String, color : UIColor)
    {
        banner = Banner(title: title, subtitle: text, image: nil, backgroundColor: color)
        banner.dismissesOnTap = true
        banner.springiness = .heavy
        banner.show(duration: 3.0)
    }
    
    func removeBanner()
    {
        banner.dismiss()
    }
    
    func AddPlayListView(_ controller : UIViewController, songId : Int)
    {
        let controller : AddPlayListVC = POPUP_STORYBOARD.instantiateViewController(withIdentifier: "AddPlayListVC") as! AddPlayListVC
        controller.songId = songId
        controller.view.backgroundColor = UIColor.clear
        UIApplication.shared.keyWindow?.rootViewController?.addChildViewController(controller)
        controller.view.frame = (UIApplication.shared.keyWindow?.frame)!
        UIApplication.shared.keyWindow?.rootViewController?.view.addSubview(controller.view)

    }
    
    func AddPopUpView(_ viewcontroller : UIViewController, array : NSMutableArray, playListId : Int, playListName : String, arrSong : SongData? = nil, index : Int? = 0 , type: String? = nil, section : Int? = 0, arrOfflineSong : Sauteez_Download? = nil)
    {
        
        let controller : PopUpVC = POPUP_STORYBOARD.instantiateViewController(withIdentifier: "PopUpVC") as! PopUpVC
        if AppDelObj.purchaseAllow == 0
        {
            array.remove(Save_Offline)
        }
        controller.arrList = array
        controller.playListId = playListId
        controller.playListName = playListName
        controller.selectedIndex = index!
        controller.selectedSection = section!
        
        if type != nil{
            controller.type = type!
        }
        if arrSong != nil{
            controller.arrSong = arrSong!
        }
        if arrOfflineSong != nil{
            controller.arrOfflineSong = arrOfflineSong!
        }
        controller.view.backgroundColor = UIColor.clear
        
        UIApplication.shared.keyWindow?.rootViewController?.addChildViewController(controller)
        controller.view.frame = (UIApplication.shared.keyWindow?.frame)!
        UIApplication.shared.keyWindow?.rootViewController?.view.addSubview(controller.view)
    }
    
    func AddOfflinePopUpView(_ viewcontroller : UIViewController, array : NSMutableArray, arrOfflineSong : Sauteez_Download? = nil, arrOfflinePlaylist : [PlaylistDetail] = [], playListName : String? = nil, objectId : NSManagedObjectID? = nil)
    {
        let controller : PopUpVC = POPUP_STORYBOARD.instantiateViewController(withIdentifier: "PopUpVC") as! PopUpVC
        controller.arrList = array
        controller.objectId = objectId
        controller.isOffline = true
        
        if playListName != nil{
            controller.playListName = playListName!
        }
        if arrOfflineSong != nil
        {
            controller.arrOfflineSong = arrOfflineSong!
        }
        if arrOfflinePlaylist != []
        {
            controller.playlistArray = arrOfflinePlaylist
        }
        controller.view.backgroundColor = UIColor.clear
        
        UIApplication.shared.keyWindow?.rootViewController?.addChildViewController(controller)
        controller.view.frame = (UIApplication.shared.keyWindow?.frame)!
        UIApplication.shared.keyWindow?.rootViewController?.view.addSubview(controller.view)
    }


    func AddVerificationView(_ viewcontroller : UIViewController)
    {
        let controller : VerificationVC = POPUP_STORYBOARD.instantiateViewController(withIdentifier: "VerificationVC") as! VerificationVC
        controller.view.backgroundColor = UIColor.clear
        viewcontroller.addChildViewController(controller)
        controller.view.frame = (viewcontroller.view.frame)
        viewcontroller.view.addSubview(controller.view)
    }

    
    func pushToProfile(_ view : UIViewController)
    {
        let controller : UserProfileVC = PROFILE_STORYBOARD.instantiateViewController(withIdentifier: "UserProfileVC") as! UserProfileVC
        view.navigationController?.pushViewController(controller, animated: true)
    }
    
    func pushToNotification(_ view : UIViewController)
    {
        let controller : NotificationVC = MAIN_STORYBOARD.instantiateViewController(withIdentifier: "NotificationVC") as! NotificationVC
        view.navigationController?.pushViewController(controller, animated: true)
    }

    func pushToArtistProfile(_ view : UIViewController, artistId : Int)
    {
        ARTIST_ID = artistId
        let controller : ArtistProfileVC
            = PROFILE_STORYBOARD.instantiateViewController(withIdentifier: "ArtistProfileVC") as! ArtistProfileVC
        view.navigationController?.pushViewController(controller, animated: true)
    }
    
    func delay(_ delay:Double, closure:()->())
    {
        
    }
    //MARK: - AlertView
    
    func showSimpleAlert(_ defaultMsg:String, currentViewController: UIViewController, okTitle:String)
    {
        let alertController = UIAlertController(title: "Sauteez", message: defaultMsg, preferredStyle: .alert)
        
        let OKAction = UIAlertAction(title: okTitle, style: .default) { (String) in
        }
        alertController.addAction(OKAction)
        
        currentViewController.present(alertController, animated: true, completion: nil)
    }
    
    func showLoginAlert(_ defaultMsg:String, currentViewController: UIViewController)
    {
        var msg = String()
        if defaultMsg == ""
        {
            msg = "To Access this feature, you need to Sign In first!"
        }
        else
        {
            msg = defaultMsg
        }
        let alertController = UIAlertController(title: "Sauteez", message: msg, preferredStyle: .alert)
        
        let OKAction = UIAlertAction(title: "Sign In", style: .destructive) { (String) in
           
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: Change_Music_Mood), object: nil)
            
            let controller : UINavigationController = MAIN_STORYBOARD.instantiateViewController(withIdentifier: "navLogin") as! UINavigationController
            UIApplication.shared.keyWindow?.rootViewController = controller
            
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (String) in
        }
        alertController.addAction(OKAction)
        alertController.addAction(cancelAction)

        currentViewController.present(alertController, animated: true, completion: nil)

    }

    func showUnAuthorizedAlert(_ defaultMsg:String, currentViewController: UIViewController)
    {
        let alertController = UIAlertController(title: "Sauteez", message: defaultMsg, preferredStyle: .alert)
        
        let OKAction = UIAlertAction(title: "Ok", style: .default){ (String) in
            
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: Change_Music_Mood), object: nil)
            
            UserDefaults.standard.removeObject(forKey: USERNAME)
            if !SharedFunctionObj.getBool(isRemember)
            {
                UserDefaults.standard.removeObject(forKey: USEREMAIL)
                UserDefaults.standard.removeObject(forKey: USERPASSWORD)
            }
            UserDefaults.standard.removeObject(forKey: USERFULLNAME)
            UserDefaults.standard.removeObject(forKey: USER_MOBILE_NO)
            UserDefaults.standard.removeObject(forKey: TOKEN)
            UserDefaults.standard.removeObject(forKey: VERIFIED)
            
            let controller : UINavigationController = MAIN_STORYBOARD.instantiateViewController(withIdentifier: "navLogin") as! UINavigationController
            UIApplication.shared.keyWindow?.rootViewController = controller
        }
        alertController.addAction(OKAction)
        currentViewController.present(alertController, animated: true, completion: nil)
    }
    
    //MARK:- Call Favorite API
    
    func callFavoriteSong(_ view : UIViewController, songId : Int, completionHandler: @escaping CompletionHandler)
    {
        if !AppSingletonObj.isConnectedToNetwork()
        {
            AppSingletonObj.showSimpleAlert(ALERT_Internet, currentViewController: view, okTitle: "Ok")
        }
        else
        {
            let parameter = [kSONG_ID : songId]
            
            APIManagerObj.callApi(RequestString.addFavoriteSong.value(), param: parameter as [String : AnyObject]?, method: POSTREQ, header: [kTOKEN : SharedFunctionObj.getObject(TOKEN) as! String], encodeType: .httpBody) { (code, error, response) -> Void in
                
                if code == 1
                {
                    let responseObj : NSDictionary = response as! NSDictionary
                    
                    if responseObj.value(forKey: RESPONSE_STATUS) as! Int == 200
                    {
                        completionHandler(true, responseObj.value(forKey: RESPONSE_DATA) as! NSDictionary)
                    }
                    else if responseObj.value(forKey: RESPONSE_STATUS) as! Int == 401
                    {
                        AppSingletonObj.removeActivityIndicatior()
                        
                        let alertController = UIAlertController(title: "Sauteez", message: "You have login in another device. Please login again", preferredStyle: .alert)
                        
                        let OKAction = UIAlertAction(title: "Ok", style: .default){ (String) in
                            
                            NotificationCenter.default.post(name: NSNotification.Name(rawValue: Change_Music_Mood), object: nil)
                            
                            UserDefaults.standard.removeObject(forKey: USERNAME)
                            if !SharedFunctionObj.getBool(isRemember)
                            {
                                UserDefaults.standard.removeObject(forKey: USEREMAIL)
                                UserDefaults.standard.removeObject(forKey: USERPASSWORD)
                            }
                            UserDefaults.standard.removeObject(forKey: USERFULLNAME)
                            UserDefaults.standard.removeObject(forKey: USER_MOBILE_NO)
                            UserDefaults.standard.removeObject(forKey: TOKEN)
                            UserDefaults.standard.removeObject(forKey: VERIFIED)
                            
                            let controller : UINavigationController = MAIN_STORYBOARD.instantiateViewController(withIdentifier: "navLogin") as! UINavigationController
                            UIApplication.shared.keyWindow?.rootViewController = controller
                        }
                        alertController.addAction(OKAction)
                        view.present(alertController, animated: true, completion: nil)

                    }

                    else
                    {
                        completionHandler(false, responseObj)
                        AppSingletonObj.showSimpleAlert(response?.value(forKey: RESPONSE_MESSAGE) as! String, currentViewController: view, okTitle: "Ok")
                    }
                }
                else
                {
                    completionHandler(false, [String: AnyObject]() as NSDictionary)
                    print(error?.description)
                }
                
            }

        }
    }
    
    
    func call_Song_Album_Purchase(_ view : UIViewController, itemId : Int, type : Int,completionHandler: @escaping CompletionHandler)
    {
        if !AppSingletonObj.isConnectedToNetwork()
        {
            AppSingletonObj.showSimpleAlert(ALERT_Internet, currentViewController: view, okTitle: "Ok")
        }
        else
        {
            let parameter = [kID : itemId, kTYPE : type] as [String : Any]
            
            APIManagerObj.callApi(RequestString.checkPurchaseStatus.value(), param: parameter as [String : AnyObject]?, method: POSTREQ, header: [kTOKEN : SharedFunctionObj.getObject(TOKEN) as! String], encodeType: .httpBody) { (code, error, response) -> Void in
                
                if code == 1
                {
                    let responseObj : NSDictionary = response as! NSDictionary
                    
                    if responseObj.value(forKey: RESPONSE_STATUS) as! Int == 200
                    {
                        completionHandler(true, responseObj.value(forKey: RESPONSE_DATA) as! NSDictionary)
                    }
                    else if responseObj.value(forKey: RESPONSE_STATUS) as! Int == 401
                    {
                        AppSingletonObj.removeActivityIndicatior()
                    }
                        
                    else
                    {
                        completionHandler(false, responseObj)
                        AppSingletonObj.showSimpleAlert(response?.value(forKey: RESPONSE_MESSAGE) as! String, currentViewController: view, okTitle: "Ok")
                    }
                }
                else
                {
                    completionHandler(false, [String: AnyObject]() as NSDictionary)
                    print(error?.description)
                }
                
            }
            
        }
    }

    func callGetSongDetailsAPI(_ songid : String, viewController : UIViewController, completionHandlerSong: @escaping CompletionHandlerSong)
    {
        var arrSongData : [SongData] = []

        self.showActivityIndicatior(viewController)
        let parameter = [kPLYLIST_SONG_ID : songid]
        
        APIManagerObj.callApi(RequestString.songDetail.value(), param: parameter as [String : AnyObject]?, method: POSTREQ, header: [kTOKEN : SharedFunctionObj.getObject(TOKEN) as! String], encodeType: .httpBody) { (code, error, response) -> Void in
            
            if code == 1
            {
                let responseObj : NSDictionary = response as! NSDictionary
                
                if responseObj.value(forKey: RESPONSE_STATUS) as! Int == 200
                {
                    if ((responseObj.value(forKey: RESPONSE_DATA))  != nil)
                    {
                        let songData : SongData = SongData(dictionary: responseObj.value(forKey: RESPONSE_DATA) as! [String : AnyObject])
                        arrSongData.append(songData)
                    }
                    completionHandlerSong(true, arrSongData)
                }
                else if responseObj.value(forKey: RESPONSE_STATUS) as! Int == 401
                {
                    self.removeActivityIndicatior()
                    
                    self.showUnAuthorizedAlert(response?.value(forKey: RESPONSE_MESSAGE) as! String, currentViewController: viewController)
                }
                else
                {
                    AppSingletonObj.showSimpleAlert(response?.value(forKey: RESPONSE_MESSAGE) as! String, currentViewController: viewController, okTitle: "Ok")
                    completionHandlerSong(false,nil)
                }
                AppSingletonObj.removeActivityIndicatior()
            }
            else
            {
                completionHandlerSong(false, nil)

                AppSingletonObj.removeActivityIndicatior()
                print(error?.description)
            }
        }
    }
    
    
    //MARK: - Set Animation On Button Tap
    
    func animationOnTap(_ vw:UIButton, completion: @escaping (Bool) -> Void)
    {
        vw.transform = .init(scaleX: 1.0, y: 1.0) //CGAffineTransformIdentity.scaledBy(x: 1.0, y: 1.0)
        
        UIView .animate(withDuration: 0.1, animations: { () -> Void in
            
            vw.transform = .init(scaleX: 1.3, y: 1.3)
            
        }) { (complete) -> Void in
            
            UIView .animate(withDuration: 0.1/2, animations: { () -> Void in
                vw.transform = .init(scaleX: 1.0, y: 1.0)
                }, completion: { (complete) -> Void in
                    completion(true)
            })
        }
    }

    
    //MARK:- Activity Indicatior
    
    func showActivityIndicatior(_ vc: UIViewController){
        
        for view in (UIApplication.shared.keyWindow?.subviews)! {
            if view is UIView && view.tag == 500
            {
                view.removeFromSuperview();
            }
        }
        
        let blurView = UIView();
        blurView.frame = vc.view.frame;
        blurView.tag = 500;
        blurView.backgroundColor = UIColor.black;
        blurView.alpha = 0.8;
        
        let logo = UIImageView(frame: CGRect(x: 0, y: 0, width: 55, height: 55))
        logo.image = #imageLiteral(resourceName: "AppLogo")
        logo.center = CGPoint(x: vc.view.frame.size.width / 2.0, y: vc.view.frame.size.height / 2.0)
        blurView.addSubview(logo)
        
        let imaviewRing = UIImageView(image: #imageLiteral(resourceName: "imageRing"))
        imaviewRing.frame = CGRect(x: 0, y: 0, width: #imageLiteral(resourceName: "imageRing").size.width, height: #imageLiteral(resourceName: "imageRing").size.height)
        imaviewRing.center = CGPoint(x: vc.view.frame.size.width / 2.0, y: vc.view.frame.size.height / 2.0)
        imaviewRing.rotateAnimation()
        blurView.addSubview(imaviewRing)
        
        UIApplication.shared.keyWindow?.addSubview(blurView)
    }
    
    func removeActivityIndicatior(){
        
        for view in (UIApplication.shared.keyWindow?.subviews)!
        {
            if view is UIView && view.tag == 500
            {
                view.removeFromSuperview();
            }
        }
        
    }

    
    func collectionviewFlowLayOut(_ width : Int, height : Int, totalWidht : CGFloat, gapNumber : CGFloat) -> UICollectionViewFlowLayout
    {
        let gap = ((UIApplication.shared.keyWindow?.frame.size.width)! - totalWidht) / gapNumber
        
        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: 0, left: gap, bottom: 0, right: gap)
        layout.itemSize = CGSize(width: width, height: height)
        layout.minimumInteritemSpacing = gap
        layout.minimumLineSpacing = gap

        return layout
    }
    
    //MARK: - Algorithm and Key
    func convertDate(strdate : String, originalFormate : String, convertFormate : String)-> String
    {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = originalFormate//this your string date format
        let date = dateFormatter.date(from: strdate)
        
        dateFormatter.dateFormat = convertFormate///this is you want to convert format
        let timeStamp = dateFormatter.string(from: date!)
        return timeStamp
    }

    
    func getCurrentTimeStamp()->String
    {
        let dateFormate=DateFormatter()
        let date=NSDate()
        dateFormate.dateFormat="yyyyMMddhhmmss"
        var newdate=dateFormate.string(from: date as Date)
        newdate=newdate.replacingOccurrences(of: ":", with: "")
        return newdate
    }
    
    //MARK:- Add Download
    func addNewSongDownload(arrSong : SongData)
    {
        if !FileManager.default.fileExists(atPath: AppSingletonObj.saveToPath() as! String)
        {
            do
            {
                try FileManager.default.createDirectory(atPath: AppSingletonObj.saveToPath() as! String, withIntermediateDirectories: false, attributes: nil)
            }
            catch let error as NSError
            {
                print(error.localizedDescription);
            }
        }
        
        
        addBanner("Downloading", text: "Please wait while song complete download..", color: UIColor(red: 255.0/255.0, green: 0.0, blue: 0.0, alpha: 1.0))
        
        let downloadSong =  self.manager.downloadFileAtURL(URL(string: arrSong.Song_URL!)!, toDirectory: URL(string : AppSingletonObj.saveToPath() as! String), withName: "\(arrSong.SongId!).mp3", andDelegate: self)
        
        downloads.append(downloadSong)
        
        let downloadImage =  self.manager.downloadFileAtURL(URL(string: arrSong.Song_Pic!)!, toDirectory: URL(string : AppSingletonObj.saveToPath() as! String), withName: "\(arrSong.SongId!).png", andDelegate: self)
        
        downloads.append(downloadImage)
        
        self.saveData(arrSong.SongId!, songName: arrSong.SongTitle!, artistName: arrSong.Song_UserName!, albumName: arrSong.AlbumName!, desc: arrSong.Song_Desc!)
    }
    //MARK:- TCBlobDownload Delegate Method
    
    func download(_ download: TCBlobDownload, didProgress progress: Float, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64)
    {
        print("\(progress*100)% downloaded")
    }
    
    func download(_ download: TCBlobDownload, didFinishWithError error: NSError?, atLocation location: URL?)
    {
        if (error != nil)
        {
            print(error.debugDescription)
        }
        else
        {
            let request: NSFetchRequest<Sauteez_Download>
            if #available(iOS 10.0, *)
            {
                request = Sauteez_Download.fetchRequest()
            }
            else
            {
                request = NSFetchRequest(entityName: "Sauteez_Download")
            }
            var newFile = String()
            if (download.fileName?.contains(".png"))!
            {
                newFile = (download.fileName?.replacingOccurrences(of: ".png", with: ""))!
            }
            else
            {
                newFile = (download.fileName?.replacingOccurrences(of: ".mp3", with: ""))!
            }
            
            request.predicate = NSPredicate(format: "songId = %@", newFile)
            
            if let fetchResults = try! self.managedObjectContext.fetch(request as! NSFetchRequest<NSFetchRequestResult>) as? [Sauteez_Download] {
                
                if fetchResults.count != 0
                {
                    self.updateData(songId: newFile, fileName: download.fileName!)
                }
            }
        }
    }
    
    //MARK:- Core Data
    
    func saveData(_ songid : Int, songName : String, artistName : String, albumName : String, desc : String)
    {
        let entityDescription = NSEntityDescription.entity(forEntityName: "Sauteez_Download", in: managedObjectContext)
        let downLoadData = Sauteez_Download(entity: entityDescription!, insertInto: managedObjectContext)
        
        downLoadData.songId = Int32(songid)
        downLoadData.songName = songName
        downLoadData.songArtistName = artistName
        downLoadData.songAlbumName = albumName
        downLoadData.songDesc = desc
        downLoadData.songFileName = ""
        downLoadData.songImageFileName = ""
        downLoadData.songImagePath = ""
        downLoadData.songPath = ""
        downLoadData.isSongExpires = NSNumber(value: false) as! Bool
        
        do
        {
            try downLoadData.managedObjectContext?.save()
        }
        catch let error as NSError
        {
            print(error)
        }
    }
    
    func updateData(songId : String, fileName : String)
    {
        let request: NSFetchRequest<Sauteez_Download>
        if #available(iOS 10.0, *)
        {
            request = Sauteez_Download.fetchRequest()
        }
        else
        {
            request = NSFetchRequest(entityName: "Sauteez_Download")
        }
        request.predicate = NSPredicate(format: "songId = %@", songId)
        
        if let fetchResults = try! self.managedObjectContext.fetch(request as! NSFetchRequest<NSFetchRequestResult>) as? [Sauteez_Download] {
            
            if fetchResults.count != 0{
                
                let managedObject = fetchResults[0]
                
                if fileName.contains(".png")
                {
                    managedObject.songImageFileName = fileName
                    managedObject.songImagePath = "Download/\(songId).png"
                }
                else
                {
                    managedObject.songFileName = fileName
                    managedObject.songPath = "Download/\(songId).mp3"
                    
                    addBanner("Successfully", text: "\(managedObject.songName!) song complete downloading", color: Yellow_Color)
                    
                    
                }
                do {
                    
                    try managedObject.managedObjectContext?.save()
                    
                } catch let error as NSError {
                    print(error)
                }
            }
        }
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

