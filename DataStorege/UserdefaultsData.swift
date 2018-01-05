//
//  DetailPage.swift
//  clvViewDemo
//
//  Created by Kalpit Gajera on 29/03/17.
//  Copyright © 2017 Kalpit Gajera. All rights reserved.
//

import UIKit
import Foundation
import QuartzCore

class DetailPage: UIViewController,UICollectionViewDataSource,UICollectionViewDelegate,UICollectionViewDelegateFlowLayout,UIWebViewDelegate,UITableViewDataSource,UITableViewDelegate {

    var dressTitle : String = ""
    @IBOutlet var btnCart: UIButton!
    @IBOutlet var btnShare: UIButton!
    @IBOutlet var btnBack: UIButton!
    @IBOutlet var btnAddtoCart: UIButton!
    @IBOutlet var lblProductName: UILabel!
    @IBOutlet var btnAddtoWishlist: UIButton!
    @IBOutlet var lblPrice: UILabel!
    @IBOutlet var cvlImageView: UICollectionView!
    var productArray = NSDictionary()
    var imageArray : NSArray = NSArray()
    @IBOutlet var imagePageControl: UIPageControl!
    var productPrice : String = ""
    var productTitle : String = ""
    
    @IBOutlet var myweb: UIWebView!
    var webviewurl : String = ""
    @IBOutlet var btnCount: UIButton!
    @IBOutlet var scrollView: UIScrollView!
    @IBOutlet var btnFavorite: UIButton!
    var isFavoriteNameArray : NSMutableArray = NSMutableArray()
    var isFavoriteHandleArray : NSMutableArray = NSMutableArray()
    var isFavoritePriceArray : NSMutableArray = NSMutableArray()
    var isFavoriteImageArray : NSMutableArray = NSMutableArray()
    var isFavoriteVariantID : NSMutableArray = NSMutableArray()
    var dropdownDataArray : NSMutableArray = NSMutableArray()
    let mydictionary : NSMutableDictionary = NSMutableDictionary()
    @IBOutlet var btnsub: UIButton!
    @IBOutlet var btnadd: UIButton!
    @IBOutlet var btnmainAddtoCart: UIButton!
    @IBOutlet var labelCount: UILabel!
    var mutableArray : NSMutableArray = NSMutableArray()
    var isFArray : NSMutableArray = NSMutableArray()
    var strAddSubCount : String = ""
    @IBOutlet var lblHEader: UILabel!
    var screenWidth  = UIScreen.main.bounds.width
    var screenHeight = UIScreen.main.bounds.height
    
    @IBOutlet var mywebheight: NSLayoutConstraint!
    @IBOutlet var mainviewheight: NSLayoutConstraint!
    @IBOutlet var webViewToBottomSpace: NSLayoutConstraint!
    
    
    var productOption : NSArray = NSArray()
    var dropdownOptionCount : Int = 0
    var selectedIndexx : Int = 100
    var selectedIndexValue : String = ""
    var flowLayoutIncDecr = 8
    
    @IBOutlet var tblDropDown: UITableView!
    @IBOutlet var tblDropDownHeight: NSLayoutConstraint!
    
    var isPop = Bool()
    
    @IBOutlet var vwNavBar: UIView!
    var cell = CellDetailPage()
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        isPop = false
        
        btnBack.tintColor = UIColor(hexString: button_font_color)
        btnCart.tintColor = UIColor(hexString: button_font_color)
        btnShare.tintColor = UIColor(hexString: button_font_color)
        btnFavorite.tintColor = UIColor(hexString: button_font_color)

        print(productArray)
        if (productArray.value(forKey: "images")! is NSArray)
        {
            imageArray = productArray.value(forKey: "images")! as! NSArray
            imagePageControl.numberOfPages = imageArray.count
        }
        lblHEader.text = (productArray.value(forKey: "title")as! String)
        let htmlString = productArray.value(forKey: "body_html") as! String
        if(htmlString.isEmpty == false)
        {
            webviewurl = htmlString
        }
        self.myweb.loadHTMLString(self.webviewurl, baseURL: nil)

    }
    override func viewWillAppear(_ animated: Bool)
    {
       // print(productArray)
        webViewToBottomSpace.constant = 0
        tblDropDown.isScrollEnabled = false
        self.view.backgroundColor = UIColor(hexString: background_color)
        vwNavBar.backgroundColor = UIColor(hexString: header_color)
        btnAddtoCart.backgroundColor = UIColor(hexString: button_color)
        btnAddtoCart.setTitleColor(UIColor(hexString: button_font_color), for: .normal)
        btnAddtoWishlist.backgroundColor = UIColor(hexString: button_color)
        btnAddtoWishlist.setTitleColor(UIColor(hexString: button_font_color), for: .normal)
        btnmainAddtoCart.backgroundColor = UIColor(hexString: button_color)
        btnmainAddtoCart.setTitleColor(UIColor(hexString: button_font_color), for: .normal)
        
        if (UserDefaults.standard.object(forKey: "cart") != nil)
        {
            let data = UserDefaults.standard.object(forKey: "cart") as! NSData
            let mutableArrayCart1 = NSKeyedUnarchiver.unarchiveObject(with: data as Data) as! NSMutableArray
            
            if (mutableArrayCart1.count > 0)
            {
                labelCount.text = String(mutableArrayCart1.count)
            }
            else
            {
                labelCount.text = ""
            }
        }
        else
        {
            labelCount.text = ""
        }
        //MARK:Check prouduct is in wishlist or not
        if ((UserDefaults.standard.value(forKey: "wishlist")) != nil)
        {
            let data = UserDefaults.standard.object(forKey: "wishlist") as! NSData
            let myCartObjWishList = NSKeyedUnarchiver.unarchiveObject(with: data as Data) as! NSMutableArray
        
            if (myCartObjWishList.count == 0)
            {
                btnFavorite.setImage(UIImage(named: "ic_favorite"), for: .normal)
            }
            else
            {
                for cartobjid in myCartObjWishList
                {
                    print("cartobjid",cartobjid)
                    
                    print(productArray)
                    print(productArray.value(forKey: "variants") as AnyObject)
                    if (((cartobjid as AnyObject).value(forKey: "variants")as AnyObject).value(forKey: "id")as! NSNumber) == (((productArray.value(forKey: "variants") as AnyObject).object(at: 0) as AnyObject).value(forKey: "id") as! NSNumber)
                    {
                        btnFavorite.setImage(UIImage(named: "ic_favorite_selected"), for: .normal)
                        break
                    }
                    else
                    {
                        btnFavorite.setImage(UIImage(named: "ic_favorite"), for: .normal)
                    }
                }
            }
        }
        else
        {
            btnFavorite.setImage(UIImage(named: "ic_favorite"), for: .normal)
        }
        
        
        productOption = (productArray.value(forKey: "options"))! as! NSArray
        createOptions()
        dropdownDataArray.removeAllObjects()
        for product in productOption
        {
            //  let position : NSNumber = product.valueForKey("position") as! NSNumber
            let position : NSNumber = (product as AnyObject).value(forKey: "position")as! NSNumber
            
            if (((product as AnyObject).value(forKey:"values")as AnyObject).count > 1)
            {
                dropdownOptionCount = dropdownOptionCount + 1
                
                dropdownDataArray.add(product)
                
                for option in mydictionary {
                    let optionname : String = option.key as! String
                    let optionname1 = optionname.replacingOccurrences(of: "option", with: "")
                    if (optionname1 == String(describing: position))
                    {
                        
                    }
                }
            }
            else
            {
                
                for option in mydictionary {
                    let optionname : String = option.key as! String
                    let optionnameTomatch = optionname.replacingOccurrences(of: "option", with: "")
                    
                    if (optionnameTomatch == String(describing: position))
                    {
                        mydictionary.setValue(((product as AnyObject).value(forKey: "values")as AnyObject).objectAt(0)as! String, forKey: optionname)
                    }
                }
            }
        }
        
        if(isPop == false)
        {
            tblDropDownHeight.constant = CGFloat(dropdownOptionCount) * 60
            print(tblDropDownHeight.constant)
            dressTitle = ""
            tblDropDown.reloadData()
        }
        
        
    }
    
    func createOptions()
    {
        for  i in 1 ..< productOption.count + 1 {
            mydictionary.setValue("", forKey: "option\(i)")
        }
    }
    
    
    @IBAction func ChooseOptionPressed(sender: UIButton)
    {
        let controller : popUpDropdownViewController = storyboard?.instantiateViewController(withIdentifier: "popUpDropdownViewController") as! popUpDropdownViewController
        controller.modalPresentationStyle = UIModalPresentationStyle.custom
        appDelegate.window?.rootViewController?.present(controller, animated: true, completion: nil)
        controller.valueArray = dropdownDataArray.object(at: sender.tag) as! NSDictionary
        controller.productdeskBlock = {productOption -> Void in
            self.selectedIndexx = sender.tag
            self.selectedIndexValue = productOption
            self.dressTitle = ""
            self.tblDropDown.reloadData()
            self.cvlImageView .reloadData()
        }
           controller.productPositionBlock = {productPosition -> Void in
        for option in self.mydictionary {
            let optionname : String = option.key as! String
            let optionnameTomatch = optionname.replacingOccurrences(of: "option", with: "")
            
            print(self.productOption)
            if (optionnameTomatch == String(describing: productPosition))
            {
                self.mydictionary.setValue(self.selectedIndexValue, forKey: optionname)
            }
        }
        for options in self.mydictionary {
            let optionname : String = options.value as! String
            if (optionname.isEmpty == true)
            {
                ShowAlert(viewController: self, title: "", message: "Please Select options...")
                return
            }
        }
        
        self.CheckCurrentVarients()
         }
    }
    
    
    func CheckCurrentVarients() {
        let varientArray : NSArray = (productArray.value(forKey: "variants"))! as! NSArray
        
        let mudic : NSMutableDictionary = NSMutableDictionary()
        var isselectedVarient : Bool = false
        if (dropdownDataArray.count > 0)
        {
            for vA in varientArray {
                
                for checkvarient in mydictionary {
                    let optionname : String = checkvarient.key as! String
                    let optionValue : String = checkvarient.key as! String
                    
                    if (optionValue.isEmpty == false)
                    {
                        
                        if ((vA as AnyObject).value(forKey: optionname) as! String) == checkvarient.value as! String
                        {
                            isselectedVarient = true
                        }
                        else
                        {
                            isselectedVarient = false
                            break
                        }
                    }
                    else
                    {
                        ShowAlert(viewController: self, title: "", message: "Please Select options...")
                        return
                    }
                }
                
                if (isselectedVarient == true)
                {
                    mudic.setObject(vA, forKey: "variants" as NSCopying)
                    
                }
                
            }
        }
        else
        {
            for vA in varientArray {
                
                mudic.setObject(vA, forKey: "variants" as NSCopying)
            }
        }
        
        if (mudic.count > 0)
        {
            if ((mudic.value(forKey:"variants")as AnyObject).value(forKey: "available")as! Bool == false)
            {
                
            }
            else
            {
            }
            
            if ((mudic.value(forKey: "variants")as AnyObject).value(forKey: "compare_at_price") != nil)
            {
                if (((mudic.value(forKey: "variants")as AnyObject).value(forKey: "compare_at_price") is NSNull))
                {
                }
                else
                {
                    var cap : String = (mudic.value(forKey: "variants")as AnyObject).value(forKey: "compare_at_price")as! String
                    if (cap.isEmpty == false)
                    {
                        //                        cap = "$ \(cap)"
                        cap = currency.replacingOccurrences(of: "{{amount}}", with: cap)
                        let attributeString: NSMutableAttributedString =  NSMutableAttributedString(string: cap)
                        attributeString.addAttribute(NSStrikethroughStyleAttributeName, value: 2, range: NSMakeRange(0, attributeString.length))
                    }
                    else
                    {

                    }
                }
                
            }
            

            
        }
        mudic.removeAllObjects()
    }
    
   // func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        
        tblDropDown.separatorStyle = .none
        let cell : dropdownCell = tableView.dequeueReusableCell(withIdentifier: "dropdownCell") as! dropdownCell
        
        let values : NSArray = (dropdownDataArray.value(forKey:"values") as AnyObject).objectAt(indexPath.row) as! NSArray
        
        let Name : String = values.object(at: 0) as! String
        if (indexPath.row == selectedIndexx)
        {
            cell.lblDropdownName.text = selectedIndexValue
            if (dressTitle.isEmpty == true)
            {
                dressTitle = selectedIndexValue
                print(dressTitle)
            }
            else
            {
                dressTitle = "\(dressTitle) / \(selectedIndexValue)"
                print(dressTitle)
            }
            print(selectedIndexValue)
            cell.btnDropDown.tag = indexPath.row
            cell.btnDropDown.addTarget(self, action: #selector(DetailPage.ChooseOptionPressed), for: UIControlEvents.touchUpInside)
        }
        else
        {
            cell.btnDropDown.tag = indexPath.row
            cell.btnDropDown.addTarget(self, action: #selector(DetailPage.ChooseOptionPressed), for: UIControlEvents.touchUpInside)
            
            for option in self.mydictionary {
                let optionname : String = option.key as! String
                let optionValue : String = option.value as! String
                let optionnameTomatch = optionname.replacingOccurrences(of: "option", with: "")
                
                if (optionnameTomatch == String(indexPath.row+1))
                {
                    if (optionValue.isEmpty == true)
                    {
                        print(Name)
                        if (dressTitle.isEmpty == true)
                        {
                            dressTitle = Name
                            print(dressTitle)
                        }
                        else
                        {
                            dressTitle = "\(dressTitle) / \(Name)"
                            print(dressTitle)
                        }
                        cell.lblDropdownName.text = Name
                    }
                    else
                    {
                        if (dressTitle.isEmpty == true)
                        {
                            dressTitle = optionValue
                            print(dressTitle)
                        }
                        else
                        {
                            dressTitle = "\(dressTitle) / \(Name)"
                            print(dressTitle)
                        }
                        print(optionValue)
                        cell.lblDropdownName.text = optionValue
                    }
                }
            }
        }
        print(dressTitle)
        lblProductName.text = dressTitle
        productPrice = (((productArray.value(forKey: "variants")as AnyObject).objectAt(indexPath.row)).value(forKey: "price")as? String)!
        
        let productVarients : NSArray = productArray.value(forKey: "variants") as! NSArray
        
       print(productVarients)
        
        for product in productVarients {
            print(product)
            let productName : String = (product as! NSObject).value(forKey: "title")! as! String
            if (productName == dressTitle)
            {
                lblPrice.text = "\(currency)\((product as! NSObject).value(forKey: "price")! as! String)"
            }
        }
        
        cvlImageView.reloadData()
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return dropdownDataArray.count
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
       
        return imageArray.count
    }
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell
    {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "mycell", for: indexPath) as!CellDetailPage
        
        var imageURl : String = ""
        cell.cellImage.image = nil
        imageURl = ((imageArray[indexPath.row] as AnyObject).value(forKey: "src") as AnyObject) as! String
        
        if (imageURl.isEmpty == false)
        {
            cell.cellImage.sd_setImage(with:URL(string:imageURl))
        }

        if((productArray.value(forKey: "variants")as AnyObject).count! > indexPath.row)
        {
            productPrice = (((productArray.value(forKey: "variants")as AnyObject).objectAt(indexPath.row)).value(forKey: "price")as? String)!
            print(((productArray.value(forKey: "variants")as AnyObject).objectAt(indexPath.row)))
            productTitle = (((productArray.value(forKey: "variants")as AnyObject).objectAt(indexPath.row)).value(forKey: "title")as? String)!
            
        }
        print(dressTitle)
        if (dressTitle.isEmpty == true)
        {
            lblPrice.text = "\(currency)\(productPrice)"
            if (productTitle == "Default Title")
            {
                lblProductName.text = productArray.value(forKey: "title") as! String
            }
            else
            {
                lblProductName.text = productTitle
            }
            
        }
        
        return cell
    }
    
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        var visibleRect = CGRect()
        
        visibleRect.origin = cvlImageView.contentOffset
        visibleRect.size = cvlImageView.bounds.size
        
        let visiblePoint = CGPoint(x: visibleRect.midX, y: visibleRect.midY)
        
        let visibleIndexPath: IndexPath = cvlImageView.indexPathForItem(at: visiblePoint)!
        
        print(visibleIndexPath.row)
    }
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize
    {
       
        if (screenWidth == 320) //5s
        {
            return CGSize(width: 290+flowLayoutIncDecr , height: 243);
        }
        else if (screenWidth == 375) //6
        {
            return CGSize(width: 345, height: 243);
        }
        else if (screenWidth == 414) //6 plus
        {
            return CGSize(width: 384, height: 243);
        }
        else if (screenWidth == 1024.0) && (screenHeight == 1366.0) //6 plus
        {
            return CGSize(width: 964.0, height: 243);
        }
        else if (screenWidth == 768.0) && (screenHeight == 1024.0) //6 plus
        {
            return CGSize(width: 718.0, height: 243);
        }
        else
        {
            return CGSize(width: 380, height: 243);
        }
    }

    //MARK: Set pagecontroll currentpage
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let center = CGPoint(x: scrollView.contentOffset.x + (scrollView.frame.width / 2), y: (scrollView.frame.height / 2))
        if let ip = cvlImageView.indexPathForItem(at: center) {
            self.imagePageControl.currentPage = ip.row
            if(ip.row < 1)
            {
                flowLayoutIncDecr = 4
            }
            else
            {
                flowLayoutIncDecr = 8
            }
            cvlImageView.reloadData()
        }
    }
    
    //MARK: WebView methods
    func webViewDidFinishLoad(_ webView: UIWebView)
    {
        
        
        myweb.layer.cornerRadius = 5.0
        myweb.layer.borderWidth = 1.0
        myweb.layer.borderColor = UIColor.clear.cgColor
        myweb.layer.shadowColor = UIColor.lightGray.cgColor
        myweb.layer.shadowOffset = CGSize(width: 0, height: 2.0)
        myweb.layer.shadowRadius = 2.0
        myweb.layer.shadowOpacity = 1.0
        myweb.clipsToBounds = false
        myweb.layer.shadowPath = UIBezierPath(roundedRect: myweb.bounds, cornerRadius: myweb.layer.cornerRadius).cgPath
        myweb.layer.masksToBounds = true

        
        myweb.autoresizesSubviews = true
        webView.scrollView.isScrollEnabled=false;
        mywebheight.constant = webView.scrollView.contentSize.height
        mainviewheight.constant = webView.scrollView.contentSize.height + 506 + (CGFloat(dropdownOptionCount) * 60)
    }
    
    @IBAction func addToWishlistTapped(_ sender: UIButton)
    {
        self.favorite_tapped(btnFavorite)
        isPop = true
    }
    @IBAction func addToCart_tapped(_ sender: UIButton)
    {
        let varientArray : NSArray = (productArray.value(forKey: "variants"))! as! NSArray
        let titleofType : String = productArray.value(forKey: "title") as! String
        let mudic : NSMutableDictionary = NSMutableDictionary()
        var myimage : String = ""
        
        var isselectedVarient : Bool = false
        
        if ((productArray.value(forKey: "images")) != nil)
        {
            if ((((productArray.value(forKey: "images") as AnyObject).value(forKey: "src") as AnyObject).objectAt(0) as! String) .isEmpty)
            {
                myimage = ((productArray.value(forKey: "images") as AnyObject).value(forKey: "src") as AnyObject).objectAt(0) as! String
            }
        }
        if (dropdownDataArray.count > 0)
        {
            for varientobject in mydictionary
            {
                let optionname : String = varientobject.key as! String
                let optionValue : String = varientobject.value as! String
                if (optionValue.isEmpty == true)
                {
                    //  mydictionary.setValue(varientArray.objectAtIndex(0).valueForKey(optionname), forKey: optionname)
                    
                    mydictionary.setValue((varientArray.object(at: 0) as AnyObject).value(forKey: optionname), forKey: optionname)
                }
            }
            
            for vA in varientArray {
                for checkvarient in mydictionary {
                    let optionname : String = checkvarient.key as! String
                    let optionValue : String = checkvarient.value as! String
                    if (optionValue.isEmpty == false)
                    {
                        if ((vA as AnyObject).value(forKey: optionname) as! String) == checkvarient.value as! String
                        {
                            isselectedVarient = true
                        }
                        else
                        {
                            isselectedVarient = false
                            break
                        }
                    }
                    else
                    {
                        ShowAlert(viewController: self, title: "", message: "Please Select options...")
                        return
                    }
                }
                
                if (isselectedVarient == true)
                {
                    mudic.setObject(vA, forKey: "variants" as NSCopying)
                    mudic.setValue(titleofType, forKey: "title")
                    mudic.setValue(myimage, forKey: "img")
                }
                
            }
        }
        else
        {
            for vA in varientArray {
                
                mudic.setObject(vA, forKey: "variants" as NSCopying)
                mudic.setValue(titleofType, forKey: "title")
                mudic.setValue(myimage, forKey: "img")
            }
        }
        
        
        if ((UserDefaults.standard.value(forKey: "cart")) != nil)
        {
            let data = UserDefaults.standard.object(forKey: "cart") as! NSData
            mutableArray = NSKeyedUnarchiver.unarchiveObject(with: data as Data) as! NSMutableArray
            
            var islast : Bool = false
            for mA in mutableArray
            {
                
                if (((mA as AnyObject).value(forKey: "variants")as AnyObject).value(forKey: "id")as! NSNumber == (mudic.value(forKey: "variants")as AnyObject).value(forKey: "id")as! NSNumber)
                {
                    
                    islast = false
                    if (((mA as AnyObject).value(forKey: "count")) != nil)
                    {
                        var count : Int = (mA as AnyObject).value(forKey: "count") as! Int
                        if mainCount == 0
                        {
                            mainCount = 1
                        }
                        count = mainCount as Int
                        (mA as AnyObject).setValue(count, forKey: "count")
                        
                    }
                    else
                    {
                        var count : Int = (mA as AnyObject).value(forKey: "count") as! Int
                        if mainCount == 0
                        {
                            mainCount = 1
                        }
                        count = mainCount as Int
                        mudic.setValue(count, forKey: "count")
                        
                        if ((mudic.value(forKey:"variants")as AnyObject).value(forKey: "available")as! Bool == false)
                        {
                            ShowAlert(viewController: self, title: "Sorry", message: "Selected item is Not Available")
                            return
                        }
                        else
                        {
                            mutableArray.add(mudic)
                        }
                        
                    }
                    UserDefaults.standard.set(NSKeyedArchiver.archivedData(withRootObject: mutableArray),forKey: "cart")
                    ShowAlert(viewController: self, title: "", message: "\(productArray.value(forKey: "title")!) Added to Cart")
                    labelCount.text = String(mutableArray.count)
                    
                    return
                }
                else
                {
                    islast = true
                }
                
            }
            
            if (islast == true)
            {
                var count : Int = 1
                if mainCount == 0
                {
                    mainCount = 1
                }
                count = mainCount as Int
                mudic.setValue(count, forKey: "count")
                
                if ((mudic.value(forKey:"variants")as AnyObject).value(forKey: "available")as! Bool == false)
                {
                    ShowAlert(viewController: self, title: "Sorry", message: "Selected item is Not Available")
                    return
                }
                else
                {
                    mutableArray.add(mudic)
                }
                
            }
            
            if (mutableArray.count == 0)
            {
                var count : Int = 1
                if mainCount == 0
                {
                    mainCount = 1
                }
                count = mainCount as Int
                mudic.setValue(count, forKey: "count")
                
                if ((mudic.value(forKey:"variants")as AnyObject).value(forKey: "available")as! Bool == false)
                {
                    ShowAlert(viewController: self, title: "Sorry", message: "Selected item is Not Available")
                    return
                }
                else
                {
                    mutableArray.add(mudic)
                }
            }
            
            UserDefaults.standard.set(NSKeyedArchiver.archivedData(withRootObject: mutableArray),forKey: "cart")
            ShowAlert(viewController: self, title: "", message: "\(productArray.value(forKey: "title")!) Added to Cart")
            labelCount.text = String(mutableArray.count)
        }
        else
        {
            var count : Int = 1
            if mainCount == 0
            {
                mainCount = 1
            }
            count = mainCount as Int
            mudic.setValue(count, forKey: "count")
            
            if ((mudic.value(forKey:"variants")as AnyObject).value(forKey: "available")as! Bool == false)
            {
                ShowAlert(viewController: self, title: "Sorry", message: "Selected item is Not Available")
                return
            }
            else
            {
                mutableArray.add(mudic)
            }
            
            UserDefaults.standard.set(NSKeyedArchiver.archivedData(withRootObject: mutableArray),forKey: "cart")
            ShowAlert(viewController: self, title: "", message: "\(productArray.value(forKey: "title")!) Added to Cart")
            labelCount.text = String(mutableArray.count)
        }
        
        labelCount.text = String(mutableArray.count)

//        let CheckOutView  = self.storyboard?.instantiateViewController(withIdentifier:"CheckOutView")
//        self.navigationController?.pushViewController(CheckOutView!, animated: true)
    }
    @IBAction func mainBottomAddtoCart_Tapped(_ sender: UIButton) {
       self.addToCart_tapped(btnAddtoCart)
    }
    @IBAction func backTapped(_ sender: UIButton)
    {
//        let transition = CATransition()
//        transition.duration = 0.70
//        transition.type = kCATransitionPush
//        transition.subtype = kCATransitionFromLeft
//        view.window!.layer.add(transition, forKey: kCATransition)
        
        self.navigationController!.popViewController(animated: true)
    }
    
    @IBAction func favorite_tapped(_ sender: UIButton)
    {
        if (btnFavorite.currentImage == UIImage(named: "ic_favorite_selected"))
        {
            var myCartObjWishList : NSMutableArray = NSMutableArray()
            let data = UserDefaults.standard.object(forKey: "wishlist") as! NSData
            myCartObjWishList = NSKeyedUnarchiver.unarchiveObject(with: data as Data) as! NSMutableArray
            
            
            var mutableArrayForWishList : NSMutableArray = NSMutableArray()
            var myimage : String = ""
            let varientArray : NSArray = (productArray.value(forKey: "variants"))! as! NSArray
            
            let mudic : NSMutableDictionary = NSMutableDictionary()
            
            var isselectedVarient : Bool = false
            
            if (dropdownDataArray.count > 0)
            {
                for varientobject in mydictionary
                {
                    let optionname : String = varientobject.key as! String
                    let optionValue : String = varientobject.value as! String
                    if (optionValue.isEmpty == true)
                    {
                        // mydictionary.setValue((varientArray.objectAtIndex(0) as AnyObject).valueForKey(optionname), forKey: optionname)
                        
                        mydictionary.setValue(((varientArray.object(at: 0)as AnyObject).value(forKey: optionname)), forKey: optionname)
                        
                    }
                }
                for vA in varientArray {
                    for checkvarient in mydictionary {
                        let optionname : String = checkvarient.key as! String
                        let optionValue : String = checkvarient.value as! String
                        //                    print(optionname)
                        if (optionValue.isEmpty == false)
                        {
                            if ((vA as AnyObject).value(forKey:optionname) as! String) == checkvarient.value as! String
                            {
                                isselectedVarient = true
                            }
                            else
                            {
                                isselectedVarient = false
                                break
                            }
                        }
                        else
                        {
                            ShowAlert(viewController: self, title: "", message: "Please Select options...")
                            return
                        }
                    }
                    
                    if (isselectedVarient == true)
                    {
                        mudic.setObject(vA, forKey: "variants" as NSCopying)
                        btnFavorite.setImage(UIImage(named: "ic_favorite"), for: .normal)
                    }
                }
            }
            else
            {
                for vA in varientArray {
                    mudic.setObject(vA, forKey: "variants" as NSCopying)
                    btnFavorite.setImage(UIImage(named: "ic_favorite"), for: .normal)
                }
            }
            if ((UserDefaults.standard.value(forKey: "wishlist")) != nil)
            {
                let data = UserDefaults.standard.object(forKey: "wishlist") as! NSData
                mutableArrayForWishList = NSKeyedUnarchiver.unarchiveObject(with: data as Data) as! NSMutableArray
                
                var mynewarray : NSMutableArray = NSMutableArray()
                mynewarray = mutableArrayForWishList
                for mA in mutableArrayForWishList {
                    
                    if (((mA as AnyObject).value(forKey:"variants")as AnyObject).value(forKey:"id") as! NSNumber == (mudic.value(forKey:"variants")as AnyObject).value(forKey:"id")as! NSNumber)
                    {
                        mynewarray.remove(mA)
                        break
                    }
                }
                mutableArrayForWishList = mynewarray
                if (mutableArrayForWishList.count == 0)
                {
                    UserDefaults.standard.removeObject(forKey: "wishlist")
                    UserDefaults.standard.synchronize()
                }
                else
                {
                    UserDefaults.standard.set(NSKeyedArchiver.archivedData(withRootObject: mutableArrayForWishList),forKey: "wishlist")
                    UserDefaults.standard.synchronize()
                }
            }
            else
            {}
            btnFavorite.setImage(UIImage(named: "ic_favorite"), for: .normal)
        }
        else
        {
            var mutableArrayForWishList : NSMutableArray = NSMutableArray()
            var myimage : String = ""
            let varientArray : NSArray = (productArray.value(forKey:"variants"))! as! NSArray
            let titleofType : String = productArray.value(forKey:"title") as! String
            print(productArray)
            if ((productArray.value(forKey:"images")) != nil)
            {
                if ((((productArray.value(forKey: "images") as AnyObject).value(forKey: "src") as AnyObject).objectAt(0) as! String) .isEmpty)
                {
                    myimage = ((productArray.value(forKey: "images") as AnyObject).value(forKey: "src") as AnyObject).objectAt(0) as! String
                }
                else
                {
                    let imagesarray = productArray.value(forKey: "images") as! NSArray
                    print(imagesarray)
                     myimage = (imagesarray[0] as AnyObject).value(forKey: "src") as! String
//                    print((imagesarray[0] as AnyObject).value(forKey: "src")!)
                }
            }
            
            let mudic : NSMutableDictionary = NSMutableDictionary()
            
            var isselectedVarient : Bool = false
            
            if (dropdownDataArray.count > 0)
            {
                for varientobject in mydictionary
                {
                    let optionname : String = varientobject.key as! String
                    let optionValue : String = varientobject.value as! String
                    if (optionValue.isEmpty == true)
                    {
                        mydictionary.setValue((varientArray.object(at: 0) as AnyObject).value(forKey: optionname), forKey: optionname)
                    }
                }
                
                
                for vA in varientArray {
                    
                    for checkvarient in mydictionary {
                        let optionname : String = checkvarient.key as! String
                        let optionValue : String = checkvarient.value as! String
                        if (optionValue.isEmpty == false)
                        {
                            if ((vA as AnyObject).value(forKey: optionname) as! String) == checkvarient.value as! String
                            {
                                isselectedVarient = true
                            }
                            else
                            {
                                isselectedVarient = false
                                break
                            }
                        }
                        else
                        {
                            ShowAlert(viewController: self, title: "", message: "Please Select options...")
                            return
                        }
                    }
                    
                    if (isselectedVarient == true)
                    {
                        mudic.setObject(vA, forKey: "variants" as NSCopying)
                        mudic.setValue(titleofType, forKey: "title")
                        mudic.setValue(myimage, forKey: "img")
                        btnFavorite.setImage(UIImage(named: "ic_favorite_selected"), for: .normal)
                        
                        let varId = (((productArray.value(forKey: "variants") as AnyObject).objectAt(0) as AnyObject).value(forKey: "id") as! NSNumber)
                        print(varId)
                        
                    }
                    
                }
            }
            else
            {
                for vA in varientArray {
                    
                    mudic.setObject(vA, forKey: "variants" as NSCopying)
                    mudic.setValue(titleofType, forKey: "title")
                    mudic.setValue(myimage, forKey: "img")
                    btnFavorite.setImage(UIImage(named: "ic_favorite_selected"), for: .normal)
                    
                  //  let varId = (((productArray.value(forKey: "variants") as AnyObject).objectAt(0) as AnyObject).value(forKey: "id") as! NSNumber)
                  //  print(varId)
                }
            }
            
            
            
            if ((UserDefaults.standard.value(forKey: "wishlist")) != nil)
            {
                let data = UserDefaults.standard.object(forKey: "wishlist") as! NSData
                mutableArrayForWishList = NSKeyedUnarchiver.unarchiveObject(with: data as Data) as! NSMutableArray
                
                var islast : Bool = false
                for mA in mutableArrayForWishList
                {
                    if (((mA as AnyObject).value(forKey: "variants")as AnyObject).value(forKey: "id")as! NSNumber == (mudic.value(forKey: "variants")as AnyObject).value(forKey: "id")as! NSNumber)
                    {
                        islast = false
                        if (((mA as AnyObject).value(forKey:"count")) != nil)
                        {
                            var count : Int = (mA as AnyObject).value(forKey:"count") as! Int
                            count = count + 1
                            (mA as AnyObject).setValue(count, forKey: "count")
                            
                        }
                        else
                        {
                            let count : Int = 1
                            mudic.setValue(count, forKey: "count")
                            mutableArrayForWishList.add(mudic)
                            
                        }
                        UserDefaults.standard.set(NSKeyedArchiver.archivedData(withRootObject: mutableArrayForWishList),forKey: "wishlist")
                        ShowAlert(viewController: self, title: "", message: "\(productArray.value(forKey: "title")!) Added to Wishlist")
                        
                        
                        return
                    }
                    else
                    {
                        islast = true
                        
                    }
                    
                }
                
                if (islast == true)
                {
                    let count : Int = 1
                    mudic.setValue(count, forKey: "count")
                    mutableArrayForWishList.add(mudic)
                }
                if (mutableArrayForWishList.count == 0)
                {
                    let count : Int = 1
                    mudic.setValue(count, forKey: "count")
                    mutableArrayForWishList.add(mudic)
                }
                UserDefaults.standard.set(NSKeyedArchiver.archivedData(withRootObject: mutableArrayForWishList),forKey: "wishlist")
                ShowAlert(viewController: self, title: "", message: "\(productArray.value(forKey: "title")!) Added to WishList")
                
            }
            else
            {
                mudic.setValue(1, forKey: "count")
                mutableArrayForWishList.add(mudic)
                UserDefaults.standard.set(NSKeyedArchiver.archivedData(withRootObject: mutableArrayForWishList),forKey: "wishlist")
                ShowAlert(viewController: self, title: "", message: "\(productArray.value(forKey: "title")!) Added to WishList")
            }
            btnFavorite.setImage(UIImage(named: "ic_favorite_selected"), for: .normal)
            
            let varId = (((productArray.value(forKey: "variants") as AnyObject).objectAt(0) as AnyObject).value(forKey: "id") as! NSNumber)
            print(varId)
        }
}
    
@IBAction func shared_tapped(_ sender: UIButton)
    {
        let handle : String = productArray.value(forKey: "handle") as! String
       // let textToShare = "Hey Check This out its awesome.."
        
       // let myWebsite = NSURL(string: "<html><body><br\\><a href='%@'>\(domainName)/products/\(handle)</a></body></html>")
        let myWebsite = "<html><body><br\\><a href='%@'>http://\(domainName)/products/\(handle)</a></body></html>"
        print(myWebsite)
     /*   guard let url = myWebsite else {
            print("nothing found")
            return
        }*/
        
        let shareItems:Array = [myWebsite] as [Any]
        let activityViewController:UIActivityViewController = UIActivityViewController(activityItems: shareItems, applicationActivities: nil)
        activityViewController.excludedActivityTypes = [UIActivityType.print, UIActivityType.postToWeibo, UIActivityType.copyToPasteboard, UIActivityType.addToReadingList, UIActivityType.postToVimeo]
        self.present(activityViewController, animated: true, completion: nil)
    }
    
    @IBAction func cart_tapped(_ sender: UIButton)
    {
        isPop = true
        let CheckOutView  = self.storyboard?.instantiateViewController(withIdentifier:"CheckOutView")
//        let transition = CATransition()
//        transition.duration = 0.70
//        transition.type = kCATransitionPush
//        transition.subtype = kCATransitionFromRight
//        view.window!.layer.add(transition, forKey: kCATransition)
        self.navigationController?.pushViewController(CheckOutView!, animated: true)
    }
    var plusOne : Int = 1
    var counted : Int = 1
    var mainCount : Int = 0
    @IBAction func sub_tapped(_ sender: UIButton)
    {
        if (strAddSubCount == "1")
        {
            return
        }
        mainCount = mainCount - plusOne
        strAddSubCount = String(mainCount)
        btnCount.setTitle(strAddSubCount, for: .normal)
    }
    @IBAction func add_tapped(_ sender: UIButton)
    {
        mainCount = mainCount + plusOne
        strAddSubCount = String(mainCount)
        btnCount.setTitle(strAddSubCount, for: .normal)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

}
