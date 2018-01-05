//
//  APIManager.swift
//  MyApp
//
//  Copyright © 2017 myCompany. All rights reserved.
//

import UIKit
import Alamofire

typealias SOAPICompletionHandler = (_ code:Int, _ error:NSError?, _ response:AnyObject?) -> Void

class APIManager: NSObject {
    
    static var instance: APIManager!
    
    // SHARED INSTANCE
    
    class func sharedInstance() -> APIManager
    {
        self.instance = (self.instance ?? APIManager())
        return self.instance
    }
    
    func callApi(_ strApiName:String, param : [String : AnyObject]?,
                 method: String,
                 header:[String : String]?,
                 encodeType:URLEncoding,
                 completionHandler:@escaping SOAPICompletionHandler)
    {
        if method == POSTREQ
        {
            let encodeURL = strApiName.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed)
            Alamofire.request(encodeURL!, method: HTTPMethod.post, parameters: param, encoding: encodeType, headers: header).responseJSON(completionHandler: { (responseData) in
                let isSuccess = JSON(responseData.result.isSuccess)
                if isSuccess.boolValue
                {
                    let jsonObject = responseData.result.value
                    completionHandler(1, nil, jsonObject as! NSDictionary?)
                }
                else
                {
                    let error = responseData.result.error! as NSError
                    completionHandler(0, error, nil)
                }
            })
        }
        else
        {
            let encodeURL = strApiName.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed)
            Alamofire.request(encodeURL!, method: HTTPMethod.get, parameters: param, encoding: encodeType, headers: header).responseJSON(completionHandler: { (responseData) in
                let isSuccess = JSON(responseData.result.isSuccess)
                if isSuccess.boolValue
                {
                    let jsonObject = responseData.result.value
                    completionHandler(1, nil, jsonObject as! NSDictionary?)
                }
                else
                {
                    let error = responseData.result.error! as NSError
                    completionHandler(0, error, nil)
                }
            })
        }
    }
    
    
    
    func uploadImageToServer (url:String,post:[String : AnyObject]?,imageData:Data?,image:UIImage?,imgName:String,method: String, completion: @escaping (NSDictionary,Error?) -> ()){
        
        var request: URLRequest = URLRequest(url: URL(string: url)!)
        request.cachePolicy = .reloadIgnoringLocalCacheData
        request.httpShouldHandleCookies = false
        request.timeoutInterval = 30
        request.httpMethod = method
        request.setValue(SharedFunctionObj.getObject(TOKEN) as? String, forHTTPHeaderField: kTOKEN)
        
        let boundary = "YOUR_BOUNDARY_STRING"
        let contentType = NSString(format: "multipart/form-data; boundary=%@",boundary)
        request.setValue(contentType as String, forHTTPHeaderField:"Content-Type")
        
        let body : NSMutableData = NSMutableData()
        
        for case let param in post!
        {
            print(String(describing: param.value))
            body.append(NSString(format:"--%@\r\n" ,boundary).data(using: String.Encoding.utf8.rawValue)!)
            body.append(NSString(format:"Content-Disposition: form-data; name=\"%@\"\r\n\r\n",param.key ).data(using: String.Encoding.utf8.rawValue)!)
            body.append(NSString(format:"%@\r\n",String(describing: param.value)).data(using: String.Encoding.utf8.rawValue)!)
        }
       
        if imageData != nil
        {
            let nameofFile:String = (6.randomString as String) + ".jpg"
            
            body.append(NSString(format:"--%@\r\n" ,boundary).data(using: String.Encoding.utf8.rawValue)!)
            body.append(NSString(format:"Content-Disposition: form-data; name=\"%@\"; filename=\"%@\"\r\n",imgName,nameofFile).data(using: String.Encoding.utf8.rawValue)!)
            body.append("Content-Type: image/jpeg\r\n\r\n" .data(using: String.Encoding.utf8)!)
            body.append(imageData!)
            body.append(NSString(format:"\r\n",locale: nil).data(using: String.Encoding.utf8.rawValue)!)
        }
        
        body.append(NSString(format:"--%@--\r\n" ,boundary).data(using: String.Encoding.utf8.rawValue)!)
        request.httpBody = body as Data
        request.url = NSURL(string: url as String) as URL?
        
        let task = URLSession.shared.dataTask(with: request, completionHandler: { (data, response, error) in
            self.mainQueue {
                do{
                    if let data = data{
                        let json = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as? Dictionary<String, AnyObject>
                        if let parsedJSON = json{
                            //Parsed JSON
                            completion((parsedJSON as NSDictionary?)!, nil)
                        }else{
                            // Woa, okay the json object was nil, something went worng. Maybe the server isn't running?
                            let jsonStr = String(data: data, encoding: .utf8)
                            #if DEBUG
                                print("Error could not parse JSON: \(jsonStr!)")
                            #endif
                        }
                    }else{
                        completion([:], error)
                    }
                }catch let error{
                    completion([:], error)
                }
            }
        })
        task.resume()
    }
    
    //MARK: Dispatch Queue
    
    func mainQueue(withCompletion completion:@escaping () -> Void){
        DispatchQueue.main.async(execute: completion)
    }
    
}


//MARK : Request String
enum RequestString {
    case checkToken
    case login
    case signUp
    case verificationCode
    case resendVerificationCode
    case resetVerificationDetails
    case forgotPassword
    case changePassword
    case songList
    case topChart_Moods
    case artist
    case topArtist
    case allArtist
    case youMightLike
    case topChart_Moods_Songs
    case userFavorite
    case userPlaylist
    case pushNotification
    case contactUS
    case contactSubject
    case pageContent
    case editProfile
    case searchCategory
    case searchCategorySong
    case searchSong
    case searchArtist
    case allSong
    case songDetail
    case userProfile
    case playListSong
    case artistProfile
    case artistSongs
    case relatedArtist
    case addFavoriteSong
    case addNewPlayList
    case editPlayList
    case addSongToPlayList
    case userPlaylistSection
    case userFollowing
    case follow_Unfollow
    case removeSongFromPlaylist
    case resendMailVerification
    case notification
    case purchaseHistory
    case signOut
    case songPlayCount
    case completePayment
    case albumDetail
    case checkPurchaseStatus
    case payUsingMobileMoney

    func value() -> String {
        switch self
        {
        case .checkToken:
            return BASEURL + APICHECK_TOKEN
            
        case .login:
            return BASEURL + APILOGIN
            
        case .signUp:
            return BASEURL + APISIGNUP
            
        case .verificationCode:
            return BASEURL + APIVERIFICATION_CODE
            
        case .resendVerificationCode:
            return BASEURL + APIRESEND_VERIFICATION_CODE
            
        case .resetVerificationDetails:
            return BASEURL + APIRESENT_VERIFICATION_DETAILS
            
        case .forgotPassword:
            return BASEURL + APIFORGOT_PASSWORD
            
        case .changePassword:
            return BASEURL + APICHANGE_PASSWORD
            
        case .songList:
            return BASEURL + APISONGS
            
        case .topChart_Moods:
            return BASEURL + APITOP_CHART_MOODS
            
        case .artist:
            return BASEURL + APIARTIST
            
        case .topArtist:
            return BASEURL + API_TOP_ARTIST
            
        case .allArtist:
            return BASEURL + API_ALL_ARTIST
            
        case .youMightLike:
            return BASEURL + APIYOU_MIGHT_LIKE
            
        case .topChart_Moods_Songs:
            return BASEURL + APITOP_CHART_MOODS_SONG
            
        case .userFavorite:
            return BASEURL + APIUSER_FAVORITE
            
        case .userPlaylist:
            return BASEURL + APIUSER_PLAYLIST
            
        case .pushNotification:
            return BASEURL + APIPUSH_NOTIFICATION
            
        case .contactUS:
            return BASEURL + APICONTACT_US
            
        case .contactSubject:
            return BASEURL + APICONTACT_SUBJECT
            
        case .pageContent:
            return BASEURL + APIPAGES
            
        case .editProfile:
            return BASEURL + APIEDIT_PROFILE
            
        case .searchCategory:
            return BASEURL + APISEARCH_CATEGORY
            
        case .searchCategorySong:
            return BASEURL + APISEARCH_CATEGORY_SONG
            
        case .searchSong:
            return BASEURL + APISEARCH_SONG
            
        case .searchArtist:
            return BASEURL + APISEARCH_SONG
            
        case .allSong:
            return BASEURL + APIALL_SONG
            
        case .songDetail:
            return BASEURL + APISONG_DETAIL
            
        case .userProfile:
            return BASEURL + APIUSER_PROFILE
            
        case .playListSong:
            return BASEURL + APIPLAYLIST_SONG
            
        case .artistProfile:
            return BASEURL + APIARTIST_PROFILE
            
        case .artistSongs:
            return BASEURL + APIARTIST_SONG
            
        case .relatedArtist:
            return BASEURL + APIARTIST_RELATED
            
        case .addFavoriteSong:
            return BASEURL + APIADD_FAVORITE
            
        case .addNewPlayList:
            return BASEURL + APIADD_PLAYLIST
            
        case .editPlayList:
            return BASEURL + APIEDIT_PLAYLIST
            
        case .addSongToPlayList:
            return BASEURL + APIADD_Song_PLAYLIST
            
        case .userPlaylistSection:
            return BASEURL + APIUSER_PLAYLIST_SECTION
            
        case .userFollowing:
            return BASEURL + APIUSER_FOLLOWING
            
        case .follow_Unfollow:
            return BASEURL + APIFOLLOW_UNFOLLOW
            
        case .removeSongFromPlaylist:
            return BASEURL + APIREMOVE_SONG_PLAYLIST
            
        case .resendMailVerification:
            return BASEURL + APIRESEND_MAIL_VERIFICATION
            
        case .notification:
            return BASEURL + APINOTIFICATION
            
        case .purchaseHistory:
            return BASEURL + APIPURCHASE_HISTORY
            
        case .signOut:
            return BASEURL + APISIGN_OUT
            
        case .songPlayCount:
            return BASEURL + APISONG_PLAY_COUNT
            
        case .completePayment:
            return BASEURL + APICOMPLETE_PAYMENT
            
        case .albumDetail:
            return BASEURL + APIALBUM_DETAIL
            
        case .checkPurchaseStatus:
            return BASEURL + APICHECK_PURCHASE_STATUS
            
        case .payUsingMobileMoney:
            return BASEURL + APIPAY_MOBILE_MONEY
            
        }
    }
}

enum RequestParameter
{
    case checkToken()
    case login(String,String,String,String,String,String,String)
    case signUp(String,String,String,String,String,String,String,String)
    case verificationCode(String)
    case resendVerificationCode(String)
    case resetVerificationDetails(String,String)
    case forgotPassword(String)
    case changePassword(String,String,String)
    case songList()
    case songDetail(String)
    case topChart_Moods(String,String,String)
    case artist(String,String)
    case topArtist()
    case allArtist(String,String)
    case youMightLike(String,String)
    case userFavorite(String,String)
    case userPlaylist()
    case pushNotification(String)
    case contactUS(String,String)
    case contactSubject()
    case pageContent()
    case searchCategory()
    case searchCategorySong(String,String,String)
    case searchSong(String)
    case searchArtist(String,String)
    case userProfile()
    case relatedArtist(String,String,String)
    case playListSong(String,String,String)
    case topChart_Moods_Songs(String,String,String)
    case addFavoriteSong(String)
    case addNewPlayList(String)
    case editPlayList(String,String,String)
    case addSongToPlayList(String,String)
    case userPlaylistSection()
    case userFollowing(String,String)
    case follow_Unfollow(String)
    case removeSongFromPlaylist(String,String)
    case resendMailVerification(String)
    case notification(String,String)
    case purchaseHistory(String,String)
    case signOut()
    case songPlayCount(String)
    case completePayment(String,String,String,String,String,String)
    case albumDetail(String,String,String)
    case checkPurchaseStatus(String,String)
    case payUsingMobileMoney(String,String,String)

    
    func value() -> Dictionary<String,String> {
        switch self {
            
        case .checkToken() :
            
            let requestDictionary : Dictionary<String,String> = Dictionary()
            
            return requestDictionary
            
        case .login(let userName, let password, let deviceToken, let socialId, let emailId, let profilePic, let devicetype) :
            
            var requestDictionary : Dictionary<String,String> = Dictionary()
            requestDictionary[kUSERNAME] = userName
            requestDictionary[kPASSWORD] = password
            requestDictionary[kDEVICE_TOKEN] = deviceToken
            requestDictionary[kSOCIAL_ID] = socialId
            requestDictionary[kEMAIL] = emailId
            requestDictionary[kPROFILE_PIC] = profilePic
            requestDictionary[kDEVICE_TYPE] = devicetype

            return requestDictionary
            
        case .signUp(let userName, let password, let confirmPass, let email, let fullname, let mobile, let profilepic,let deviceToken) :
            
            var requestDictionary : Dictionary<String,String> = Dictionary()
            requestDictionary[kUSERNAME] = userName
            requestDictionary[kPASSWORD] = password
            requestDictionary[kCONFIRM_PASSWORD] = confirmPass
            requestDictionary[kEMAIL] = email
            requestDictionary[kFULLNAME] = fullname
            requestDictionary[kMOBILE_NO] = mobile
            requestDictionary[kPROFILE_PIC] = profilepic
            requestDictionary[kDEVICE_TOKEN] = deviceToken
            
            return requestDictionary
            
        case .verificationCode(let code) :
            
            var requestDictionary : Dictionary<String,String> = Dictionary()
            requestDictionary[kVERIFICATION_CODE] = code
            
            return requestDictionary
            
        case .resendVerificationCode(let mobile_no) :
            
            var requestDictionary : Dictionary<String,String> = Dictionary()
            requestDictionary[kMOBILE_NO] = mobile_no
            
            return requestDictionary
            
        case .resetVerificationDetails(let mobile_no,let email) :
            
            var requestDictionary : Dictionary<String,String> = Dictionary()
            requestDictionary[kMOBILE_NO] = mobile_no
            requestDictionary[kEMAIL] = email
            
            return requestDictionary
            
            
        case .forgotPassword(let username) :
            
            var requestDictionary : Dictionary<String,String> = Dictionary()
            requestDictionary[kUSERNAME] = username
            
            return requestDictionary
            
        case .changePassword(let oldPassword, let newPassword, let confirmPassword) :
            
            var requestDictionary : Dictionary<String,String> = Dictionary()
            requestDictionary[kOLD_PASSWORD] = oldPassword
            requestDictionary[kNEW_PASSWORD] = newPassword
            requestDictionary[kCONFIRM_PASSWORD] = confirmPassword
            
            return requestDictionary
            
        case .songList() :
            
            let requestDictionary : Dictionary<String,String> = Dictionary()
            
            return requestDictionary
            
        case .songDetail(let songId) :
            
            var requestDictionary : Dictionary<String,String> = Dictionary()
            requestDictionary[kPLYLIST_SONG_ID] = songId
            
            return requestDictionary
            
        case .topChart_Moods(let albumType, let start, let offset) :
            
            var requestDictionary : Dictionary<String,String> = Dictionary()
            requestDictionary[kALBUM_TYPE] = albumType
            requestDictionary[kPAGE] = start
            requestDictionary[kLIMIT] = offset
            
            return requestDictionary
            
        case .artist(let start, let offset) :
            
            var requestDictionary : Dictionary<String,String> = Dictionary()
            requestDictionary[kPAGE] = start
            requestDictionary[kLIMIT] = offset
            
            return requestDictionary
            
        case .topArtist() :
            
            let requestDictionary : Dictionary<String,String> = Dictionary()
            
            return requestDictionary
            
        case .allArtist(let start, let offset) :
            
            var requestDictionary : Dictionary<String,String> = Dictionary()
            requestDictionary[kPAGE] = start
            requestDictionary[kLIMIT] = offset
            
            return requestDictionary
            
        case .youMightLike(let start, let offset) :
            
            var requestDictionary : Dictionary<String,String> = Dictionary()
            requestDictionary[kPAGE] = start
            requestDictionary[kLIMIT] = offset
            
            return requestDictionary
            
        case .topChart_Moods_Songs(let albumId, let start, let offset) :
            
            var requestDictionary : Dictionary<String,String> = Dictionary()
            requestDictionary[kADDITIONAL_ALBUM_ID] = albumId
            requestDictionary[kPAGE] = start
            requestDictionary[kLIMIT] = offset
            
            return requestDictionary
            
        case .userFavorite(let start, let offset) :
            
            var requestDictionary : Dictionary<String,String> = Dictionary()
            requestDictionary[kPAGE] = start
            requestDictionary[kLIMIT] = offset
            
            return requestDictionary
            
        case .userPlaylist() :
            
            let requestDictionary : Dictionary<String,String> = Dictionary()
            return requestDictionary
            
        case .pushNotification(let pushActive) :
            
            var requestDictionary : Dictionary<String,String> = Dictionary()
            requestDictionary[kPUSH_ON_OFF] = pushActive
            
            return requestDictionary
            
        case .contactUS(let message,let subjectId) :
            
            var requestDictionary : Dictionary<String,String> = Dictionary()
            requestDictionary[kMESSAGE] = message
            requestDictionary[kCONTACT_SUB_ID] = subjectId
            
            return requestDictionary
            
        case .contactSubject() :
            
            let requestDictionary : Dictionary<String,String> = Dictionary()
            
            return requestDictionary
            
        case .pageContent() :
            
            let requestDictionary : Dictionary<String,String> = Dictionary()
            
            return requestDictionary
            
        case .searchCategory() :
            
            let requestDictionary : Dictionary<String,String> = Dictionary()
            
            return requestDictionary
            
        case .searchCategorySong(let songcatid, let page, let limit) :
            
            var requestDictionary : Dictionary<String,String> = Dictionary()
            requestDictionary[kSONG_CAT_ID] = songcatid
            requestDictionary[kPAGE] = page
            requestDictionary[kLIMIT] = limit
            
            return requestDictionary
            
        case .searchSong(let name) :
            
            var requestDictionary : Dictionary<String,String> = Dictionary()
            requestDictionary[kMESSAGE] = name
            
            return requestDictionary
            
        case .searchArtist(let name, let OnlyArtist) :
            
            var requestDictionary : Dictionary<String,String> = Dictionary()
            requestDictionary[kMESSAGE] = name
            requestDictionary[kONLY_ARTSIT] = OnlyArtist

            return requestDictionary
            
        case .userProfile() :
            
            let requestDictionary : Dictionary<String,String> = Dictionary()
            
            return requestDictionary
            
        case .relatedArtist(let artistid, let page, let limit) :
            
            var requestDictionary : Dictionary<String,String> = Dictionary()
            requestDictionary[kARTIST_ID] = artistid
            requestDictionary[kPAGE] = page
            requestDictionary[kLIMIT] = limit
            return requestDictionary
            
        case .playListSong(let playlistId, let page, let limit) :
            
            var requestDictionary : Dictionary<String,String> = Dictionary()
            requestDictionary[kPLAYLIST_ID] = playlistId
            requestDictionary[kPAGE] = page
            requestDictionary[kLIMIT] = limit
            
            return requestDictionary
            
        case .addFavoriteSong(let songId) :
            
            var requestDictionary : Dictionary<String,String> = Dictionary()
            requestDictionary[kSONG_ID] = songId
            
            return requestDictionary
            
        case .addNewPlayList(let playlistName) :
            
            var requestDictionary : Dictionary<String,String> = Dictionary()
            requestDictionary[kPLAYLIST_NAME] = playlistName
            
            return requestDictionary
            
        case .editPlayList(let playlistId,let playlistName,let type) :
            
            var requestDictionary : Dictionary<String,String> = Dictionary()
            requestDictionary[kPLAYLIST_NAME] = playlistName
            requestDictionary[kPLAYLIST_ID] = playlistId
            requestDictionary[kTYPE] = type
            
            return requestDictionary
            
        case .addSongToPlayList(let playlistId, let songId) :
            
            var requestDictionary : Dictionary<String,String> = Dictionary()
            requestDictionary[kPLAYLIST_ID] = playlistId
            requestDictionary[kPLYLIST_SONG_ID] = songId
            
            return requestDictionary
            
        case .userPlaylistSection() :
            
            let requestDictionary : Dictionary<String,String> = Dictionary()
            
            return requestDictionary
            
        case .userFollowing(let page, let limit) :
            
            var requestDictionary : Dictionary<String,String> = Dictionary()
            requestDictionary[kPAGE] = page
            requestDictionary[kLIMIT] = limit
            
            return requestDictionary
            
        case .follow_Unfollow(let artistID) :
            
            var requestDictionary : Dictionary<String,String> = Dictionary()
            requestDictionary[kARTIST_ID] = artistID
            
            return requestDictionary
            
        case .removeSongFromPlaylist(let playlistId, let songId) :
            
            var requestDictionary : Dictionary<String,String> = Dictionary()
            requestDictionary[kPLAYLIST_ID] = playlistId
            requestDictionary[kPLYLIST_SONG_ID] = songId
            
            return requestDictionary
            
        case .resendMailVerification(let emailId) :
            
            var requestDictionary : Dictionary<String,String> = Dictionary()
            requestDictionary[kEMAIL] = emailId
            
            return requestDictionary
            
        case .notification(let page, let limit) :
            
            var requestDictionary : Dictionary<String,String> = Dictionary()
            requestDictionary[kPAGE] = page
            requestDictionary[kLIMIT] = limit
            
            return requestDictionary
            
        case .purchaseHistory(let page, let limit) :
            
            var requestDictionary : Dictionary<String,String> = Dictionary()
            requestDictionary[kPAGE] = page
            requestDictionary[kLIMIT] = limit
            
            return requestDictionary
            
        case .signOut() :
            
            let requestDictionary : Dictionary<String,String> = Dictionary()
            
            return requestDictionary
            
        case .songPlayCount(let songId) :
            
            var requestDictionary : Dictionary<String,String> = Dictionary()
            requestDictionary[kPLYLIST_SONG_ID] = songId
            
            return requestDictionary
            
        case .completePayment(let Id, let transactionId, let amount, let createDate, let currencyType, let type):
            
            var requestDictionary : Dictionary<String,String> = Dictionary()
            requestDictionary[kID] = Id
            requestDictionary[kTYPE] = type
            requestDictionary[kTRANSACTION_ID] = transactionId
            requestDictionary[kAMOUNT] = amount
            requestDictionary[kCREATED_AT] = createDate
            requestDictionary[kCURRENCY_TYPE] = currencyType
            
            return requestDictionary
            
            
        case .albumDetail(let albumId, let page, let limit) :
            
            var requestDictionary : Dictionary<String,String> = Dictionary()
            requestDictionary[kAlbumID] = albumId
            requestDictionary[kPAGE] = page
            requestDictionary[kLIMIT] = limit
            
            return requestDictionary
            
        case .checkPurchaseStatus(let itemId, let type) :
            
            var requestDictionary : Dictionary<String,String> = Dictionary()
            requestDictionary[kID] = itemId
            requestDictionary[kTYPE] = type
            
            return requestDictionary
        
        case .payUsingMobileMoney(let songId, let phoneNumber, let type) :
            
            var requestDictionary : Dictionary<String,String> = Dictionary()
            requestDictionary[kID] = songId
            requestDictionary[kPHONE_NUMBER] = phoneNumber
            requestDictionary[kTYPE] = phoneNumber

            return requestDictionary

        }
    }
}

//MARK: CREATE RANDOM STRING of LENGTH
extension Int
{
    var randomString : String {
        
        let letters : NSString = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        let randomString : NSMutableString = NSMutableString(capacity: self)
        
        for _ in 0 ..< self
        {
            let length = UInt32 (letters.length)
            let rand = arc4random_uniform(length)
            randomString.appendFormat("%C", letters.character(at: Int(rand)))
        }
        return randomString as String
    }
}
