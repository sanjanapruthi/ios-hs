//
//  PersonTableViewController.swift
//  Birthday Reminder 2
//
//  Created by Sanjana Pruthi on 1/21/18.
//  Copyright © 2018 Sanjana Pruthi. All rights reserved.

/*
Main Sources:
 permission to access contacts
    https://stackoverflow.com/questions/45966955/request-access-to-contacts-in-swift-3
 accessing contact information
    https://developer.apple.com/documentation/contacts
 table views and segues
    https://developer.apple.com/library/content/referencelibrary/GettingStarted/DevelopiOSAppsSwift/CreateATableView.html#//apple_ref/doc/uid/TP40015214-CH8-SW1
 multiple sections on table views
    https://www.appcoda.com/ios-programming-index-list-uitableview/
 pop up alert
    https://stackoverflow.com/questions/43370184/modal-pop-up-in-swift-3
 notifications:
    https://useyourloaf.com/blog/local-notifications-with-ios-10/
and many smaller sources from stackoverflow and the apple developer website
*/


import UIKit
import Contacts
import os.log
import UserNotifications

class PersonTableViewController: UITableViewController {

    var contactStore = CNContactStore()
    var contactArray = [(first: String, last: String, bdayMonth: String, bdayDate: Int, pic: UIImage)]()
    var contactDictionary: Dictionary<Int, [(first: String, last: String, bdayMonth: String, bdayDate: Int, pic: UIImage)]> = [:]
    let sections = ["January ", "February ", "March ", "April ", "May ","June ", "July ", "August ", "September ", "October ", "November ", "December "]
    var indexOfEditing = 0
    let center = UNUserNotificationCenter.current()
    let options: UNAuthorizationOptions = [.alert, .sound];
 
    
    
    @IBAction func ImportButton(_ sender: Any) {
        
        let alertController = UIAlertController(title: "Import Contacts", message: "Are you sure you want to import your contacts? This will replace all of your current contacts.", preferredStyle: .alert)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (action:UIAlertAction!) in
            print("you have pressed the No button");
            //Call another alert here
        }
        alertController.addAction(cancelAction)
        
        let OKAction = UIAlertAction(title: "Yes", style: .default) { (action:UIAlertAction!) in
            print("you have pressed Yes button");
            //Call another alert here
            self.contactArray = self.getContactsFromPhone()
            if (self.contactArray.count>0){
                self.contactArray = self.sortContacts(self.contactArray)
                self.contactDictionary = self.createDictionary(self.contactArray)
                self.tableView.reloadData()
                self.updateNotification()
            }
            
        }
        alertController.addAction(OKAction)
        
        self.present(alertController, animated: true, completion:nil)
        
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.leftBarButtonItem = editButtonItem
        print("app has opened")
        
        requestForAccess(completionHandler: { (true) in print("Done") })
        
        center.requestAuthorization(options: options) {
            (granted, error) in
            if !granted {
                print("Something went wrong")
            }
        }
        
        contactDictionary = createDictionary(contactArray)
     
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        
        return 12
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return contactDictionary[section]!.count
    }
    
    
    
    func requestForAccess(completionHandler: @escaping (_ accessGranted: Bool) -> Void) {
        let authorizationStatus = CNContactStore.authorizationStatus(for: CNEntityType.contacts)
        
        switch authorizationStatus {
        case .authorized:
            completionHandler(true)
            
        case .denied, .notDetermined:
            self.contactStore.requestAccess(for: CNEntityType.contacts, completionHandler: { (access, accessError) -> Void in
                if access {
                    completionHandler(access)
                }
                else {
                    if authorizationStatus == CNAuthorizationStatus.denied {
                        DispatchQueue.main.async{ () -> Void in //error here
                            let message = "\(accessError!.localizedDescription)\n\nPlease allow the app to access your contacts through the Settings."
                            print(message)
                        }
                    }
                }
            })
            
        default:
            completionHandler(false)
        }
    }
    
    
    func getContactsFromPhone()-> [(first: String, last: String, bdayMonth: String, bdayDate: Int, pic: UIImage)]{
    
        var arr = [(first: String, last: String, bdayMonth: String, bdayDate: Int, pic:UIImage)]()

    
        let req = CNContactFetchRequest(keysToFetch: [
            CNContactFamilyNameKey as CNKeyDescriptor,
            CNContactGivenNameKey as CNKeyDescriptor, CNContactBirthdayKey as CNKeyDescriptor, CNContactImageDataKey as CNKeyDescriptor
            ])
        
        do{
            try CNContactStore().enumerateContacts(with: req) {
            contact, stop in
       
                if (contact.birthday?.date as NSDate! != nil) {
                    
                    let formatter = DateFormatter()
                    formatter.dateFormat = "MMMM "
                    let formatter2 = DateFormatter()
                    formatter2.dateFormat = "dd"
                    formatter.timeZone = NSTimeZone(name: "UTC")! as TimeZone
                    formatter2.timeZone = NSTimeZone(name: "UTC")! as TimeZone
                    let stringDate1 = formatter.string(from: contact.birthday!.date!)
                    let stringDate2 = formatter2.string(from: contact.birthday!.date!)
                    if (contact.imageData != nil){
                        let img = UIImage(data: contact.imageData!)!
                        arr.append((contact.givenName, contact.familyName, stringDate1, Int(stringDate2)!, img))
                    }else {
                        let img = #imageLiteral(resourceName: "DefaultImage")
                        arr.append((contact.givenName, contact.familyName, stringDate1, Int(stringDate2)!, img))
                    }
                    
                    
                }
                
            }
           
        }  catch {
            print("no access to contacts")
            self.requestForAccess(completionHandler: { (true) in print("Done") })

        }
            

        return arr
    
    }
    
    
    func sortContacts(_ array: [(first: String, last: String, bdayMonth: String, bdayDate: Int, pic: UIImage)]) -> [(first: String, last: String, bdayMonth: String, bdayDate: Int, pic: UIImage)]{
        
        var arr = array
   
        let n = arr.count - 1
        for i in 0..<n
        {
            var index = i
            let k = i + 1
            for j in k..<arr.count
            {
                
                if (arr[j].bdayDate < arr[index].bdayDate){
                    index = j
                }
                
            }
            let temp = arr.remove(at:index)  //take out the one you want to move
            arr.insert(temp, at: i)

        }

        
        
        return arr
    }
    
    func createDictionary(_ array: [(first: String, last: String, bdayMonth: String, bdayDate: Int, pic: UIImage)]) -> Dictionary<Int, [(first: String, last: String, bdayMonth: String, bdayDate: Int, pic: UIImage)]>{
        
        var dictionaryOfContacts: Dictionary<Int, [(first: String, last: String, bdayMonth: String, bdayDate: Int, pic: UIImage)]> = [:]

        
        for i in 0..<12{
            var currentMonth = ""
            if (i==0){
                currentMonth = "January "
            }else if (i==1){
                currentMonth = "February "
            }else if (i==2){
                currentMonth = "March "
            }else if (i==3){
                currentMonth = "April "
            }else if (i==4){
                currentMonth = "May "
            }else if (i==5){
                currentMonth = "June "
            }else if (i==6){
                currentMonth = "July "
            }else if (i==7){
                currentMonth = "August "
            }else if (i==8){
                currentMonth = "September "
            }else if (i==9){
                currentMonth = "October "
            }else if (i==10){
                currentMonth = "November "
            }else if (i==11){
                currentMonth = "December "
            }
            var arr = [(first: String, last: String, bdayMonth: String, bdayDate: Int, pic: UIImage)]()
            for person in array{
                if (person.bdayMonth == currentMonth){
                    arr.append(person)
                }
                
            }
            dictionaryOfContacts[i] = arr

        }
        return dictionaryOfContacts
        
        
        
        
    }

    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sections[section]
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellIdentifier = "PersonTableViewCell"


        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? PersonTableViewCell  else {
            fatalError("The dequeued cell is not an instance of MealTableViewCell.")
        }
        let person = (contactDictionary[indexPath.section])![indexPath.row]
        
        cell.nameLabel.text = person.first + " " + person.last
        cell.birthdayLabel.text = person.bdayMonth + String(person.bdayDate)
        cell.personImage.image = person.pic
        

        return cell
    }
    
    
    //MARK: Actions
    
    @IBAction func unwindToPersonList(sender: UIStoryboardSegue) {
        
        if sender.source is NewContactViewController{
            
            if let senderVC = sender.source as? NewContactViewController{
                
                if let selectedIndexPath = tableView.indexPathForSelectedRow {
                    print("editing")
                    
                    
                    contactArray[indexOfEditing] = ((senderVC.firstNameToReturn, senderVC.lastNameToReturn, senderVC.monthToReturn, senderVC.dateToReturn, #imageLiteral(resourceName: "DefaultImage")))
                    
                    tableView.reloadRows(at: [selectedIndexPath], with: .none)
                    
                }else {
                    contactArray.append((senderVC.firstNameToReturn, senderVC.lastNameToReturn, senderVC.monthToReturn, senderVC.dateToReturn, #imageLiteral(resourceName: "DefaultImage")))
                }
                
            
            }
            contactArray = sortContacts(contactArray)
            contactDictionary = createDictionary(contactArray)
            tableView.reloadData()
            updateNotification()
            
        }
        
    }

    
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }


    
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            
            let selectedPerson = (contactDictionary[indexPath.section])![indexPath.row]
            
            for i in 0..<(contactArray.count){
                if ((contactArray[i].first == selectedPerson.first)&&(contactArray[i].last == selectedPerson.last)&&(contactArray[i].bdayMonth == selectedPerson.bdayMonth)&&(contactArray[i].bdayDate == selectedPerson.bdayDate)){
                    indexOfEditing = i
                }
            }
           // print("COUNT:")
           // print(contactArray.count)
           // print(indexOfEditing)

            contactArray.remove(at: indexOfEditing)
            
            if (contactArray.count>0){
                contactArray = sortContacts(contactArray)
            }
            
            contactDictionary = createDictionary(contactArray)
            tableView.reloadData()
            updateNotification()

            
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        super.prepare(for: segue, sender: sender)
        switch(segue.identifier ?? "") {
        case "AddContact":
            os_log("Adding a new contact.", log: OSLog.default, type: .debug)
        case "ShowDetail":
            guard let contactDetailViewController = segue.destination as? NewContactViewController else {
                fatalError("Unexpected destination: \(segue.destination)")
            }
            
            guard let selectedContactCell = sender as? PersonTableViewCell else {
                fatalError("Unexpected sender: \(sender)")
            }
            
            guard let indexPath = tableView.indexPath(for: selectedContactCell) else {
                fatalError("The selected cell is not being displayed by the table")
            }
            
            let selectedPerson = (contactDictionary[indexPath.section])![indexPath.row]
            contactDetailViewController.firstNameToReturn = selectedPerson.first
            contactDetailViewController.lastNameToReturn = selectedPerson.last
            contactDetailViewController.monthToReturn = selectedPerson.bdayMonth
            contactDetailViewController.dateToReturn = selectedPerson.bdayDate
            
            for i in 0..<(contactArray.count){
                if ((contactArray[i].first == selectedPerson.first)&&(contactArray[i].last == selectedPerson.last)&&(contactArray[i].bdayMonth == selectedPerson.bdayMonth)&&(contactArray[i].bdayDate == selectedPerson.bdayDate)){
                    indexOfEditing = i
                }
            }
            
            
        default:
            fatalError("Unexpected Segue Identifier; \(segue.identifier)")
        }
    }
    
    @objc func updateNotification(){
        print("updating")
        center.removeAllPendingNotificationRequests()
        var date = DateComponents()
        
        date.hour = 8
        date.minute = 0
        date.timeZone = NSTimeZone.system
        
        var content = UNMutableNotificationContent()

        
        content.title = "Birthday Reminder:"
        
        
        content.sound = UNNotificationSound.default()
        
 
        
        if (contactArray.count>0){
            
            for i in 0..<contactArray.count{
                var monthStr = contactArray[i].bdayMonth
                var monthNum = 0
                var day = contactArray[i].bdayDate
                if (monthStr=="January "){
                    monthNum = 1
                }else if (monthStr == "February "){
                    monthNum = 2
                }else if (monthStr == "March "){
                    monthNum = 3
                }else if (monthStr == "April "){
                    monthNum = 4
                }else if (monthStr == "May "){
                    monthNum = 5
                }else if (monthStr == "June "){
                    monthNum = 6
                }else if (monthStr == "July "){
                    monthNum = 7
                }else if (monthStr == "August "){
                    monthNum = 8
                }else if (monthStr == "September "){
                    monthNum = 9
                }else if (monthStr == "October "){
                    monthNum = 10
                }else if (monthStr == "November "){
                    monthNum = 11
                }else if (monthStr == "December "){
                    monthNum = 12
                }
                date.month = monthNum
                date.day = day
                date.year = 2018
                content.body = "Today is "+contactArray[i].first + " " + contactArray[i].last + "'s birthday!!!"
                
                var trigger = UNCalendarNotificationTrigger(dateMatching: date, repeats: true)
                
                var identifier = "Notification" + contactArray[i].first + String(i)
                var request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
                center.add(request, withCompletionHandler: { (error) in
                    if let error = error {
                        // Something went wrong
                    }
                })
            }
            
        }
        
     
   
        
        
    }
    
    

}
