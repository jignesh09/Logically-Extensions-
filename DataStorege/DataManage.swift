//
//  BookListViewController.swift
//  HabitCoach
//
//  Created by Kalpit Gajera on 31/01/17.
//  Copyright © 2017 Kalpit Gajera. All rights reserved.
//

import UIKit
import SVProgressHUD
import SDWebImage
import FirebaseDatabase

class BookListViewController: UIViewController,UITableViewDelegate,UITableViewDataSource {

    @IBOutlet var tblBookCollection: UITableView!
    @IBOutlet var viewBookList: UIView!
    @IBOutlet var btnGo: UIButton!
    @IBOutlet var btnChooseBooks: UIButton!
    @IBOutlet var viewChooseBooks: UIView!
    @IBOutlet var lblMakeMeGreateWidth: NSLayoutConstraint!
    
    @IBOutlet var viewTrialPopUp: UIView!
    @IBOutlet var tblBottomConst: NSLayoutConstraint!
    @IBOutlet var viewTrilaOver: UIView!
    @IBOutlet var lblHabitCoachBooksCount: UILabel!
    @IBOutlet var btnGoyoMyList: UIButton!
    @IBOutlet var btnSeePricing: UIButton!
    @IBOutlet var blankView: UIView!
    
    
    var storedOffsets = [Int: CGFloat]()
    var previousNumber: UInt32? // used in randomNumber()
    var arrBookSection = NSMutableArray()
    var books = NSArray()
    var names = NSDictionary()
    var mylist = Bool()
    var arrSelectedBooks = NSArray()
    
    var arrBookHabit = NSMutableArray()
    var arrBookHabit1 = NSArray()

    var userData = [UserData]() //UserData function for Get and Set to Firebase server
    
    // Define identifier
    let notificationName = Notification.Name("GetBooksData")
    let notificationAfterOnline = Notification.Name("GetBooksAtOnline")
    
    //Books Object array section wise
    struct Objects {
        var sectionName : String!
        var sectionObjects : NSMutableArray!
    }
    var objectArray = [Objects]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
      
        let isFirst:Bool = UserDefaults.standard.bool(forKey: Static.isfirstTime)
    
        let seventhDateTime = IntMax(UserDefaults.standard.integer(forKey: Static.isTrialTimeStamp))
        var currentTimeStamp = Double()
        let currentDate = NSDate()
        currentTimeStamp =  currentDate.timeIntervalSince1970
        
        //Check seventh day timestamp If Trial is Over or Not
        if(IntMax(currentTimeStamp) > seventhDateTime)
        {
            let curretDateTime = Utility.getCurrentDateTime()
            let arrLogCloseApp = ["timestamp": curretDateTime,"msg": "User’s trial ended.","item_id": ""]
            arrLogs.add(arrLogCloseApp)
            
            UserActivityLog.shared.setJsonPostData()  //Set Activity Data
            UserActivityLog.shared.submitUserDataApi() //Submit UserActivity Data
            
            self.viewBookList.isHidden = true
            self.viewTrilaOver.isHidden = false
            
            UserDefaults.standard.set(false, forKey: Static.premiumStarts)
        }
        else
        {
            //Display PopUp before 7 days Trial
            self.viewTrilaOver.isHidden = true
            if(isFirst == true)
            {
                self.viewBookList.isHidden = true
            }
            else
            {
                viewTrialPopUp.dropShadow()
                self.viewBookList.isHidden = false
            }
        }
        
        // Register to receive notification
        NotificationCenter.default.addObserver(self, selector: #selector(self.callBooksOfflineData), name: notificationName, object: nil)  //For getting books Offline
    
       NotificationCenter.default.addObserver(self, selector: #selector(self.callBooksApi), name: notificationAfterOnline, object: nil)  //For getting books Offline
        
      if(MyViewState.isEditBooks == true)
      {
         self.callBooksOfflineData()
      }
      else
      {
        //Set BookData based on Intenet rechability online or offline
        if(MyViewState.isNotRechable == false)
        {
            self.callBooksApi()
        }
        else
        {
            self.callBooksOfflineData()
        }
        
        if(isFirst == false)
        {
            SVProgressHUD.dismiss()
        }
      }
        // Do any additional setup after loading the view.
    if(MyViewState.isFromLoginPage == true)
    {
        if(MyViewState.isEditBooks == false)
        {
            if(MyViewState.isHavingData == true)
            {
                self.blankView.isHidden = false
                SVProgressHUD.dismiss()
            }
            else
            {
                self.blankView.isHidden = true
            }
        }
    }
}
    
    //Make statusbar Lighter
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    
    //ViewDidAppear function
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(false)
        if(self.objectArray.count == 0)
        {
            if(MyViewState.isFromLoginPage == true)
            {
                if(MyViewState.isEditBooks == false)
                {
                    if(MyViewState.isHavingData == false)
                    {
                       Utility.showProgressHUD(lodingString: "Loading...")
                    }
                }
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.tblBookCollection.isUserInteractionEnabled = true
        btnChooseBooks.isUserInteractionEnabled = true
        
        mylist = UserDefaults.standard.bool(forKey: Static.mylist)
    
        if(MyViewState.isFromLoginPage == false)
        {
            self.blankView.isHidden = true
        }
        
        //Get data from Firebase server If already selected the books
        if(MyViewState.isFromBookDetail == false)
        {
            if(MyViewState.isAlreadyAddedHabits == false)
            {
                self.setBooksFromFirebaseData() //Set Selected Books Data
                self.tblBookCollection.reloadData()
            }
        }
        
        //Change the button MAKE ME BETTER after selects the Books
        if((UserDefaults.standard.value(forKey: Static.selectedBooks) as? NSArray) != nil)
        {
            self.arrSelectedBooks = UserDefaults.standard.value(forKey: Static.selectedBooks) as! NSArray
            self.tblBookCollection.reloadData()
            
            if(self.arrSelectedBooks.count >= 1)
            {
                btnChooseBooks.setTitle("MAKE ME BETTER", for: .normal)
            }
            else
            {
                btnChooseBooks.setTitle("CHOOSE AT LEAST 1 BOOKS", for: .normal)
            }
        }
        else
        {
            self.tabBarController?.tabBar.isHidden = true
            viewChooseBooks.isHidden = false
            btnChooseBooks.setTitle("CHOOSE AT LEAST 1 BOOKS", for: .normal)
        }
        
        //Set show of the button If already with selected books
        if(UserDefaults.standard.bool(forKey: Static.complete) == true)
        {
            self.viewChooseBooks.isHidden = true
            self.tblBottomConst.constant = 0
            lblMakeMeGreateWidth.constant = 230.0
        }
        else
        {
            self.viewChooseBooks.isHidden = false
            self.tblBottomConst.constant = 55
            lblMakeMeGreateWidth.constant = 148.0
        }
        tblBookCollection.reloadData()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
         btnChooseBooks.isUserInteractionEnabled = true
         MyViewState.isHudHide = false
        // Stop listening notification
        NotificationCenter.default.removeObserver(self, name: notificationName, object: nil);
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    @IBAction func btnGotoListClicked(_ sender: Any) {
        
        //Redirect to Habit Ideas if Habits are available
        if (FinalArray.count == 0)
        {
           // let bookid:Int = ((FinalArray[0] as AnyObject).value(forKey:"book_id") as? Int)!
            MyViewState.isFromHabitList = false
            let objHabitList = self.storyboard?.instantiateViewController(withIdentifier: "HabitIdeaFromListVC") as! HabitIdeaFromListVC
         //   objHabitList.bookID = bookid
            self.navigationController?.pushViewController(objHabitList, animated: true)
        }
        else
        {
            MyViewState.isFromNoMoreHabit = true
            let objHabitIdea = self.storyboard?.instantiateViewController(withIdentifier: "HabitIdeaViewController") as! HabitIdeaViewController
            
            self.navigationController?.pushViewController(objHabitIdea, animated: true)
        }
    }
    
    //Go for Premium view controller
    @IBAction func btnSeePricingClicked(_ sender: Any) {
      
        let objTrialFinish = self.storyboard?.instantiateViewController(withIdentifier: "UpgradeTrialViewController") as! UpgradeTrialViewController
        self.navigationController?.pushViewController(objTrialFinish, animated: true)
    }
    
    //Set Books Data If getting data from Firebase server
    func setBooksFromFirebaseData() {
        
        let arrSelectBooks = NSMutableArray()  //A2
        let arrManagedBooks = NSMutableArray() //Ans
        
        if(UserDefaults.standard.value(forKey: Static.selectedBooksID) != nil)
        {
            let arrSelectedId = UserDefaults.standard.value(forKey: Static.selectedBooksID) as! NSArray  //A1
            
            for book in self.books
            {
                for i in 0..<arrSelectedId.count
                {
                     if((arrSelectedId[i] as! Int) == ((book as AnyObject).value(forKey: "id") as! Int))
                     {
                        arrSelectBooks.add(book as! NSDictionary)
                       
                        let arrBlank = NSArray()
                        dictOperation.setValue(arrBlank, forKey: String(arrSelectedId[i] as! Int))
                        let dictHabitData:NSData = NSKeyedArchiver.archivedData(withRootObject: dictOperation) as NSData
                        UserDefaults.standard.set(dictHabitData, forKey: Static.selectedBookDictionary)
                     }
                }
            }
            
            for i in 0..<arrSelectedId.count
            {
                for j in 0..<arrSelectBooks.count
                {
                    if((arrSelectedId[i] as! Int) == ((arrSelectBooks[j] as AnyObject).value(forKey: "id") as! Int))
                    {
                        arrManagedBooks.add(arrSelectBooks[j] as! NSDictionary)
                        self.setSelectedBookHabit(bookID:(arrSelectBooks[j] as AnyObject).value(forKey: "id") as! Int)
                    }
                }
            }
            
            if(UserDefaults.standard.value(forKey: Static.UserHabits) != nil)
            {
                let arrUserHabits = UserDefaults.standard.value(forKey: Static.UserHabits) as! NSArray
                print(arrUserHabits)
                
                let arrSelectHabit = NSMutableArray()
                
                let habitIdeaViewController = HabitIdeaViewController()
                habitIdeaViewController.isGetData = true
                habitIdeaViewController.viewWillAppear(false)
                
                for i in 0..<arrUserHabits.count
                {
                    for j in 0..<FinalArray.count
                    {
                        if(((arrUserHabits[i] as AnyObject).value(forKey: "habitId") as! Int) == ((FinalArray[j] as AnyObject).value(forKey: "id") as! Int))
                        {
                            if(!arrSelectHabit.contains(FinalArray[j] as! NSDictionary))
                            {
                                arrSelectHabit.add(FinalArray[j] as! NSDictionary) //Get selected habits from firebase
                                habitIdeaViewController.bookHabitOperation(dictHabit: FinalArray[j] as! NSDictionary)
                            }
                        }
                    }
                }
               // print(arrSelectHabit)
                UserDefaults.standard.set(arrSelectHabit, forKey: Static.addedHabits)
               
               if(FinalArray.count != 0)
               {
                    if(FinalArray.contains(arrSelectHabit.firstObject as! NSDictionary))
                    {
                        let arrSelectedObject = arrSelectHabit.firstObject as! NSDictionary
                        var selecetdHabit = FinalArray.index(of: arrSelectedObject) as Int
                       
                        if(selecetdHabit >= FinalArray.count - 1)
                        {
                        }
                        else
                        {
                            selecetdHabit += 1
                        }
                        
                        let strNextHabitCategory = (FinalArray[selecetdHabit] as AnyObject).value(forKey: "habit_category") as! String
                        let strNextHabitTitle = (FinalArray[selecetdHabit] as AnyObject).value(forKey: "title") as! String
                        MyViewState.strHabitTitle = strNextHabitTitle
                        MyViewState.strHabit = strNextHabitCategory
                        UserDefaults.standard.set(strNextHabitTitle, forKey: Static.tomorrowHabitTitle)
                        UserDefaults.standard.set(strNextHabitCategory, forKey: Static.tomorrowHabit)
                    }
                }
            }
            
            UserDefaults.standard.set(arrManagedBooks, forKey: Static.selectedBooks)
            UserDefaults.standard.synchronize()
        }
    }
    
    //Set Books Habits which are selected
    func setSelectedBookHabit(bookID:Int)
    {
        let arrHabitsall = UserDefaults.standard.value(forKey: Static.allBookHabits) as! NSArray
        
        if((UserDefaults.standard.value(forKey: Static.selectedBookHabits) as? NSArray) != nil)
        {
            arrBookHabit1 = UserDefaults.standard.value(forKey: Static.selectedBookHabits) as! NSArray
            arrBookHabit = NSMutableArray(array: arrBookHabit1)
        }
        
        for i in 0..<arrHabitsall.count
        {
            if((arrHabitsall[i] as AnyObject).value(forKey: "book_id") as! Int == bookID)
            {
                if(!arrBookHabit.contains(arrHabitsall[i] as! NSDictionary))
                {
                    arrBookHabit.add(arrHabitsall.object(at: i))
                }
            }
        }
        // print(self.arrBookHabit)
        
        let arrExtraIda:NSArray = self.BookHabitSelect(bookID: bookID)
        
        arrNumber = arrNumber + 1
        arrNames.setValue(arrExtraIda, forKey: "habit\(arrNumber)")
        
        let arrNamesDict:NSData = NSKeyedArchiver.archivedData(withRootObject: arrNames) as NSData
        UserDefaults.standard.set(arrNamesDict, forKey: Static.selectedBooksHabits)
        
        UserDefaults.standard.set(arrNumber, forKey: Static.BookNumber)
        UserDefaults.standard.synchronize()
    }
    
    //Get Habits from selected Book
    func BookHabitSelect(bookID:Int) -> NSArray {
        let arrHabitsall = UserDefaults.standard.value(forKey: Static.allBookHabits) as! NSArray
        
        let arrHabit = NSMutableArray()
        for i in 0..<arrHabitsall.count
        {
            if((arrHabitsall[i] as AnyObject).value(forKey: "book_id") as! Int == bookID)
            {
                if(!arrHabit.contains(arrHabitsall[i] as! NSDictionary))
                {
                    arrHabit.add(arrHabitsall.object(at: i))
                }
            }
        }
        return arrHabit as NSArray
    }
    
    //Go button on 7 days trial PopUp
    @IBAction func btnGoClick(_ sender: Any) {
        self.viewBookList.isHidden = true
        if(MyViewState.isHudHide == false)
        {
             Utility.showProgressHUD(lodingString: "Loading...")
        }
    }
    
    //Make ME Better button Click
    @IBAction func btnChooseBooksClicked(_ sender: Any) {
        self.btnChooseBooks.isUserInteractionEnabled = false
        if (btnChooseBooks.titleLabel?.text == "MAKE ME BETTER")
        {
            let objBookDetail = self.storyboard?.instantiateViewController(withIdentifier: "BookDetailPageViewController") as! BookDetailPageViewController
            objBookDetail.isFromMakeBetter = true
            self.navigationController?.pushViewController(objBookDetail, animated: true)
        }
    }
    
    //Call Books Data Api
    func callBooksApi() {
     
      if(self.books.count == 0)
      {
        Utility.getBookList { (success, bookList) in
           
            if(success){
                
            if(self.books.count == 0)
            {
                var arrHabits = NSArray()
                arrHabits = bookList.value(forKey: "habits")! as! NSArray
                MyViewState.arrAllHabits = arrHabits
                UserDefaults.standard.set(arrHabits, forKey: Static.allBookHabits)
            
                let arrPrices = bookList.value(forKey: "prices")! as! NSArray
                MyViewState.arrPrices = arrPrices
                UserDefaults.standard.set(arrPrices, forKey: Static.prices)
                
                var arrDailyTips = NSArray()
                arrDailyTips = bookList.value(forKey: "daily_tips") as! NSArray
                MyViewState.arrDailyTips = arrDailyTips
                let tipData:NSData = NSKeyedArchiver.archivedData(withRootObject: arrDailyTips) as NSData
                UserDefaults.standard.set(tipData, forKey: Static.dailyTips)
                
                self.books = bookList.value(forKey: "books")! as! NSArray
                MyViewState.arrBooks = self.books
                UserDefaults.standard.set(self.books, forKey: Static.booksList)
                
                MyViewState.numberofBooks = self.books.count as Int
                MyViewState.numberofHabitIdeas = arrHabits.count as Int
            
                for i in 0..<self.books.count
                {
                    if(!self.arrBookSection.contains((self.books[i] as AnyObject).value(forKey: "category")!))
                    {
                        self.arrBookSection.add((self.books[i] as AnyObject).value(forKey: "category")!)
                    }
                }
                UserDefaults.standard.set(self.arrBookSection, forKey: Static.bookSection)
               
                for i in 0..<self.arrBookSection.count
                {
                  //  print("\(self.arrBookSection.object(at: i) as! String) -> \(self.sectionObjects(sectionName: self.arrBookSection.object(at: i) as! String))")
                    self.objectArray.append(Objects(sectionName: self.arrBookSection.object(at: i) as! String, sectionObjects: self.sectionObjects(sectionName: self.arrBookSection.object(at: i) as! String)))
                }
               // print(self.objectArray)
              //  print(self.books)
                UserDefaults.standard.set(true, forKey: Static.isfirstTime)
                UserDefaults.standard.synchronize()
                
                self.lblHabitCoachBooksCount.text = "HabitCoach has currently \(MyViewState.numberofBooks) books and total of \(MyViewState.numberofHabitIdeas) habit ideas!"
                
                MyViewState.isHudHide = true
                self.viewWillAppear(false)
                
                if(MyViewState.isHavingData == true)
                {
                    MyViewState.isCallOnlyOnce = false
                    if(MyViewState.isFromBookDetail == false)
                    {
                        appDelegate.setLoginPage()
                    }
                }
                else
                {
                     MyViewState.isCallOnlyOnce = true
                }
                
                self.tblBookCollection.reloadData()
              }
            }else{
            
            if(MyViewState.isNotRechable == false)
            {
               Utility.showAlert(globalAlert: self, alertTitle: Static.alertTitle, andMessage: "Fail to Get Books")
            }
            else
            {
                Utility.showAlert(globalAlert: self, alertTitle: Static.alertTitle, andMessage: "Try again.")
            }
          }
            UserDefaults.standard.synchronize()
        }
      }
    }
    
    
    //Get Books data when Offline state
    func callBooksOfflineData() {
     
      if(self.books.count == 0)
      {
        if((UserDefaults.standard.value(forKey: Static.booksList) as? NSArray) != nil)
        {
            UserDefaults.standard.set(MyViewState.arrAllHabits, forKey: Static.allBookHabits)
            UserDefaults.standard.set(MyViewState.arrPrices, forKey: Static.prices)
            
            let tipData:NSData = NSKeyedArchiver.archivedData(withRootObject: MyViewState.arrDailyTips) as NSData
            UserDefaults.standard.set(tipData, forKey: Static.dailyTips)
            
            self.books = MyViewState.arrBooks
            UserDefaults.standard.set(self.books, forKey: Static.booksList)
            
            MyViewState.numberofBooks = self.books.count as Int
            MyViewState.numberofHabitIdeas = MyViewState.arrAllHabits.count as Int
            
            for i in 0..<self.books.count
            {
                if(!self.arrBookSection.contains((self.books[i] as AnyObject).value(forKey: "category")!))
                {
                    self.arrBookSection.add((self.books[i] as AnyObject).value(forKey: "category")!)
                }
            }
            UserDefaults.standard.set(self.arrBookSection, forKey: Static.bookSection)
            
            for i in 0..<self.arrBookSection.count
            {
                self.objectArray.append(Objects(sectionName: self.arrBookSection.object(at: i) as! String, sectionObjects: self.sectionObjects(sectionName: self.arrBookSection.object(at: i) as! String)))
            }
            // print(self.objectArray)
            //  print(self.books)
            UserDefaults.standard.set(true, forKey: Static.isfirstTime)
            UserDefaults.standard.synchronize()
            
           self.lblHabitCoachBooksCount.text = "HabitCoach has currently \(MyViewState.numberofBooks) books and total of \(MyViewState.numberofHabitIdeas) habit ideas!"
            
            self.viewWillAppear(false)
            
            self.tblBookCollection.reloadData()
            
        }else{
            Utility.showAlert(globalAlert: self, alertTitle: Static.alertTitle, andMessage: "Fail to Get saved Books")
        }
        UserDefaults.standard.synchronize()
      }
    }

    //Get Books data and set in section wise Row
    func sectionObjects(sectionName:String) -> NSMutableArray {
        
        let arrData = NSMutableArray()
        for item in self.books
        {
            if(sectionName == (item as AnyObject).value(forKey: "category") as! String)
            {
                arrData.add(item)
            }
        }
        return arrData
    }
    
    //Generate Random Number
    func randomNumber() -> UInt32 {
        var randomNumber = arc4random_uniform(UInt32(self.arrBookSection.count))
        while previousNumber == randomNumber {
            randomNumber = arc4random_uniform(UInt32(self.arrBookSection.count))
        }
        previousNumber = randomNumber
        return randomNumber
    }

    
    // TableView Delegate and DataSource Methods
    func tableView(_ tableView: UITableView,willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
        guard let tableViewCell = cell as? collectionBooks else { return }
        
        tableViewCell.setCollectionViewDataSourceDelegate(dataSourceDelegate: self, forRow: indexPath.row)
      //  tableViewCell.collectionViewOffset = storedOffsets[indexPath.row] ?? 0
    }
    func tableView(_ tableView: UITableView,didEndDisplaying cell: UITableViewCell,forRowAt indexPath: IndexPath) {
        
        guard let tableViewCell = cell as? collectionBooks else { return }
       // storedOffsets[indexPath.row] = tableViewCell.collectionViewOffset
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
            return self.objectArray.count
    }
   /* func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return booksList[section]
    }*/
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 44.0
    }
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let vw = UIView()
        vw.backgroundColor = UIColor.groupTableViewBackground
        let lblTitle = UILabel(frame: CGRect(x: 17, y: 0, width: self.view.frame.size.width, height:40))
        lblTitle.textColor = UIColor.black
        lblTitle.backgroundColor = UIColor.groupTableViewBackground
        lblTitle.font = UIFont(name: "Roboto-Bold", size: 19.0)
        if(section < arrBookSection.count)
        {
            lblTitle.text = arrBookSection[section] as? String
        }
        vw.addSubview(lblTitle)
        return vw
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 190.0
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    // create a cell for each table view row
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        // create a new cell if needed or reuse an old one
        let cell:collectionBooks = self.tblBookCollection.dequeueReusableCell(withIdentifier: "bookCell") as! collectionBooks!
        cell.contentView.tag = indexPath.section
        
        cell.selectionStyle = .none
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
         print("You tapped cell number \(indexPath.row).")
    }
}

//Extension for collectionView of Books in one Row
extension BookListViewController: UICollectionViewDelegate, UICollectionViewDataSource {
   
    // CollectionView Delegate and DataSource Methods
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int
    {
        let sectionTable = collectionView.superview!.tag
        return objectArray[sectionTable].sectionObjects.count
    }
    
   /* internal func numberOfSections(in collectionView: UICollectionView) -> Int {
        let section = collectionView.superview!.tag
        return section
    }*/
    internal func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell
    {
        let cell:booksListcollectionCollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: "books",for: indexPath) as! booksListcollectionCollectionViewCell
        
        cell.contentView.layer.cornerRadius = 0.0
        cell.contentView.layer.borderWidth = 1.0
        cell.contentView.layer.borderColor = UIColor.clear.cgColor
        cell.contentView.layer.masksToBounds = true
        
        cell.layer.shadowColor = UIColor.lightGray.cgColor
        cell.layer.shadowOffset = CGSize(width: 0, height: 2.0)
        cell.layer.shadowRadius = 2.0
        cell.layer.shadowOpacity = 1.0
        cell.layer.masksToBounds = false
        cell.layer.shadowPath = UIBezierPath(roundedRect: cell.bounds, cornerRadius: cell.contentView.layer.cornerRadius).cgPath
        
        
        cell.imgChecked.image = UIImage(named: "")
        let section = collectionView.superview!.tag
        
        if(self.books.count != 0)
        {
            let book_cover = (objectArray[section].sectionObjects[indexPath.row] as AnyObject).value(forKey: "book_cover") as? String
           cell.imgBook.sd_setImage(with: URL(string:book_cover!), placeholderImage: UIImage(named:"book"))
        
           cell.lblBookName.text = (objectArray[section].sectionObjects[indexPath.row] as AnyObject).value(forKey: "title") as? String
        }
        
        if((UserDefaults.standard.value(forKey: Static.selectedBooks) as? NSArray) != nil)
        {
           for i in 0..<self.arrSelectedBooks.count
           {
                let indexPath1 = NSIndexPath(row: i, section: section)
                if(objectArray[section].sectionObjects[indexPath.row] as! NSDictionary == self.arrSelectedBooks[indexPath1.row] as! NSDictionary)
                {
                    if(mylist == false)
                    {
                        cell.imgChecked.image = UIImage(named: "GreenChecked")
                    }
                    else
                    {
                        cell.imgChecked.image = UIImage(named: "check-mark")
                    }
                 }
            }
        }
        return cell
    }
    
    internal func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath)
    {
        let section = collectionView.superview!.tag
        
        self.tblBookCollection.isUserInteractionEnabled = false
        
        let bookID = (objectArray[section].sectionObjects[indexPath.row] as AnyObject).value(forKey: "id") as? Int
        UserDefaults.standard.set(bookID, forKey: Static.currentBookId)
        UserDefaults.standard.synchronize()
    
        let objBookDetail = self.storyboard?.instantiateViewController(withIdentifier: "BookDetailPageViewController") as! BookDetailPageViewController
        
        objBookDetail.dictSelectedBook = (objectArray[section].sectionObjects[indexPath.row] as AnyObject) as! NSDictionary
        objBookDetail.isFromMakeBetter = false
        
        self.navigationController?.pushViewController(objBookDetail, animated: true)
    }
    
    internal func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout:UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        
        let cellsAcross: CGFloat = 2.35
        let spaceBetweenCells: CGFloat = 8
        let dim = (collectionView.bounds.width - (cellsAcross - 2) * spaceBetweenCells) / cellsAcross
        return CGSize(width: dim, height: dim + 26.0)
    }
}
