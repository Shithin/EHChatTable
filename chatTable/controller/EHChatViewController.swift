//
//  EHChatViewController.swift
//  chatTable
//
//  Created by Shithin PV on 01/01/18.
//  Copyright © 2018 e3Help. All rights reserved.
//

import UIKit

class EHChatViewController: UIViewController {

    @IBOutlet weak var chatTableView: UITableView!
    //initial setup
    var estimatedHeights : [IndexPath:CGFloat] = [IndexPath:CGFloat]()
    var chatMessages : [EHChatMessage] = []
    //To store all threads
    var typingAnimationThread:[DispatchWorkItem?] = []
    //time delay for each message
    var timeDelay:[Double] = []
    //var to store the status of typing
    var isTyping:Bool = false
    
    //MARK:- Life cycle events
    override func viewDidLoad() {
        super.viewDidLoad()
        //assign datasource and delegate
        chatTableView.delegate = self
        chatTableView.dataSource = self
        
        //Set backGround
        self.createGradientLayer()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        // assigning first chat. Demo only. Actual case this response may be from api call.
        //self.initialiseChatMessages(messages: self.simpleChatMaker())
        self.timerFunctions(messages: self.simpleChatMaker())
        //self.chatMessages = self.simpleChatMaker()
        //self.chatTableView.reloadData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK: - Sample chat maker
    func simpleChatMaker() -> [EHChatMessage]{
        let initialChat = EHChatMessage()
        initialChat.chatType = .senderSimpleChat
        initialChat.text = "First Chat. And it's very long chat to test the label capability."
        let secondChat = EHChatMessage()
        secondChat.chatType = .senderSimpleChat
        secondChat.text = "This is second chat. And it is very long too."
        return [initialChat,secondChat,initialChat,secondChat,initialChat,secondChat,initialChat,secondChat,initialChat,secondChat,initialChat,secondChat]
    }
    //MARK: -To Create background gradient
    func createGradientLayer() {
        let gradientLayer = CAGradientLayer()
        
        gradientLayer.frame = self.view.bounds
        
        gradientLayer.colors = [UIColor.red.cgColor, UIColor.yellow.cgColor]
        
        self.view.layer.insertSublayer(gradientLayer, at: 0)
    }
    
    func initialiseChatMessages(messages:[EHChatMessage]){
        var triggeringTime:Double = 6.2
        for index in 0 ..< messages.count{
        self.timeDelay.append(Double(messages[index].text.trimmingCharacters(in: .whitespacesAndNewlines).count)*0.1)
            print("time delay array - \(self.timeDelay)")
            let when = DispatchTime.now() + (triggeringTime+0.5)
            if index > 0{
                triggeringTime += self.timeDelay[index-1]
            }
            let thread = DispatchWorkItem(block: {
                self.changeContentInsetToHeightOfMessage(message: messages[index])
                print("time delay for next chat - \(self.timeDelay[index])")
                //add typing cell
                let typingMessage = EHChatMessage()
                typingMessage.chatType = .typing
                self.addNewChatMessage(newMessage: typingMessage)
                let when = DispatchTime.now() + self.timeDelay[index]
                DispatchQueue.main.asyncAfter(deadline: when, execute: {
                    //delete and add new message
                    self.deleteTypingAnimationAndAddNewMessage(newMessage:messages[index])
                })
            })
            typingAnimationThread.append(thread)
            print("Triggered on time - \(triggeringTime+0.5)")
            DispatchQueue.main.asyncAfter(deadline: when, execute: thread)
        }
    }
    
    func timerFunctions(messages:[EHChatMessage]){
        var triggeringTime:Double = 0.2
        for index in 0 ..< messages.count{
            self.timeDelay.append(Double(messages[index].text.trimmingCharacters(in: .whitespacesAndNewlines).count)*0.1)
            if index > 0{
                triggeringTime += self.timeDelay[index-1]
            }
            Timer.scheduledTimer(withTimeInterval: triggeringTime, repeats: false, block: { (timer1) in
                
                self.changeContentInsetToHeightOfMessage(message: messages[index])
                print("time delay for next chat - \(self.timeDelay[index])")
                //add typing cell
                if self.chatMessages.isEmpty{
                    self.addTypingCell()
                }
                if let lastChat = self.chatMessages.last,lastChat.chatType != .typing{
                    self.addTypingCell()
                }
                
                Timer.scheduledTimer(withTimeInterval: self.timeDelay[index], repeats: false, block: { (timer2) in
                    self.deleteTypingAnimationAndAddNewMessage(newMessage:messages[index])
                    timer2.invalidate()
                })
                timer1.invalidate()
            })
        }
    }
    func addTypingCell(){
        let typingMessage = EHChatMessage()
        typingMessage.chatType = .typing
        self.addNewChatMessage(newMessage: typingMessage)
    }
    
    //add new message with typing animation
    func addNewMessageWithTypingAnimation(newMessage:EHChatMessage,timeDelay:Double){
        //create typing chat
        let typingMessage = EHChatMessage()
        typingMessage.chatType = .typing
        typingMessage.text = newMessage.text
        self.addNewChatMessage(newMessage: typingMessage)
        let when = DispatchTime.now() + timeDelay
        DispatchQueue.main.asyncAfter(deadline: when) {
            print("added new message and deleted typing message)")
            self.deleteTypingAnimationAndAddNewMessage(newMessage:newMessage)
        }
    }
    
    //add chat messages
    func addNewChatMessage(newMessage:EHChatMessage)
    {
        self.chatMessages.append(newMessage)
        let indexPath = IndexPath(row: self.chatMessages.count - 1, section: 0)
        if newMessage.chatType != .typing{
            estimatedHeights[indexPath] = self.calculateHeightForChatMessageCell(indexPath: indexPath, message: newMessage)
        }
        
        UIView.setAnimationsEnabled(false)

        CATransaction.begin()
        
        CATransaction.setCompletionBlock(
            {
                UIView.setAnimationsEnabled(true)
        })
        
        self.chatTableView.beginUpdates()
        self.chatTableView.insertRows(at: [indexPath], with: .fade)
        self.chatTableView.endUpdates()
        CATransaction.commit()
    }
    //delete typing message
    
    func deleteTypingAnimationAndAddNewMessage(newMessage: EHChatMessage){
        
        if let message = chatMessages.last, message.chatType == .typing{
            print("chat messages before deleting count \(self.chatMessages.count)")
            for message in chatMessages{
                print("message type \(message.chatType)")
                print("message text \(message.text)")
            }
            self.chatMessages.remove(at: chatMessages.count-1)
            print("after deleting typing chat array count - \(chatMessages.count)")
            let indexPath = IndexPath(row: self.chatMessages.count, section: 0)
            
            UIView.setAnimationsEnabled(false)
            
            CATransaction.begin()
            
            CATransaction.setCompletionBlock(
                {
                    UIView.setAnimationsEnabled(true)
                    print("chat messages after deleting count \(self.chatMessages.count)")
                    for message in self.chatMessages{
                        print("message type \(message.chatType)")
                        print("message text \(message.text)")
                    }
                    self.addNewChatMessage(newMessage: newMessage)
            })
            
            self.chatTableView.beginUpdates()
            self.chatTableView.deleteRows(at: [indexPath], with: .fade)
            self.chatTableView.endUpdates()
            CATransaction.commit()
        }
        else{
            print("failed to delete - \(newMessage.chatType)")
        }
    }
    
    //change content offset
    func changeContentInsetToHeightOfMessage(message:EHChatMessage)
    {
        
        var totalHeight : CGFloat = 0
        
        let newMessageHeight:CGFloat = self.calculateHeightForChatMessageCell(indexPath: IndexPath(row:-1,section:0), message: message)
        
        totalHeight = self.chatTableView.contentSize.height + newMessageHeight
        let y : CGFloat = totalHeight - self.chatTableView.frame.height
        let previousOffsetHeight = self.chatTableView.contentOffset.y

        if y >= 0 && y >= previousOffsetHeight
        {
            DispatchQueue.main.async {
                
                UIView.animate(withDuration: 0.5, animations:
                    {
                        self.chatTableView.contentInset.top = -y
                })
                
            }
            
        }
    }
    
    //MARK: Height Calculation
    
    func calculateHeightForChatMessageCell(indexPath:IndexPath,message:EHChatMessage) -> CGFloat
    {
        //for "typing" cell
        if message.chatType == .typing{
            if self.shouldShowPicForCell(indexPath: indexPath){
            //if self.shouldShowProfilePicForChatMessage(newMessage: message){
                
                return 70 // height for "Typing" cell with profile pic
            }
            
            return 45 // height for "Typing" cell with out profile pic
        }
        // All cells except "Typing" and "Slider"
        else if message.chatType != .senderSliderChat{
            var extraHeight : CGFloat = 10
            if self.shouldShowPicForCell(indexPath: indexPath){
            //if self.shouldShowProfilePicForChatMessage(newMessage: message)
            //{
                extraHeight = 35
            }
            // Use correct width that used in storyboard
            let width = UIScreen.main.bounds.size.width*0.75 - 20
            let label = UILabel(frame: CGRect(x: 0, y: 0, width: width, height: 40))
            //Use font with correct size that used in storyboard
            label.font = UIFont.systemFont(ofSize: 16)
            label.numberOfLines = 0
            label.text = message.text
            //label.sizeToFit()
            label.lineBreakMode = .byWordWrapping
            let size = label.sizeThatFits(CGSize(width: width, height: CGFloat.greatestFiniteMagnitude))
            
            //let size = label.frame.size
            let cellHeight : CGFloat = size.height + 15 + extraHeight
            estimatedHeights[indexPath] = cellHeight
            return cellHeight
        }
        else{
            var extraHeight : CGFloat = 0
            let width = (UIScreen.main.bounds.size.width)*0.8 - 28
            if self.shouldShowPicForCell(indexPath: indexPath){
            //if self.shouldShowProfilePicForChatMessage(newMessage: message)
            //{
                extraHeight = 25
            }
            let label = UILabel(frame: CGRect(x: 0, y: 0, width: width, height: 30))
            label.font = UIFont.systemFont(ofSize: 16)
            label.numberOfLines = 0
            label.text = message.text
            let size = label.sizeThatFits(CGSize(width: width, height: CGFloat.greatestFiniteMagnitude))
            var messageHeight = size.height
            
            
            if messageHeight <= 25
            {
                messageHeight = 25
            }
            
            let cellHeight = messageHeight + 85 + extraHeight
            estimatedHeights[indexPath] = cellHeight
            return cellHeight
        }
    }
    
    func shouldShowProfilePicForChatMessage(newMessage:EHChatMessage) -> Bool
    {
        if self.chatMessages.isEmpty{
            return true
        }
        else{
            if let lastMessage = self.chatMessages.last{
                if newMessage.chatType == .userChatCell && lastMessage.chatType != .userChatCell{
                    return true
                }
                else if newMessage.chatType != .userChatCell && lastMessage.chatType == .userChatCell{
                    return true
                }
            }
        }
        return false
    }
    
    func shouldShowPicForCell(indexPath:IndexPath) -> Bool{
        return true
        if indexPath.row == 0{
            return true
        }
        else if self.chatMessages.isEmpty{
            return true
        }
        else{
            let newMessage = self.chatMessages[indexPath.row]
            let lastMessage = self.chatMessages[indexPath.row - 1]
            if newMessage.chatType == .userChatCell && lastMessage.chatType != .userChatCell{
                return true
            }
            else if newMessage.chatType != .userChatCell && lastMessage.chatType == .userChatCell{
                return true
            }
            else{
                return false
            }
        }
    }
    
    
    

}

extension EHChatViewController:UITableViewDelegate{
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        let message = self.chatMessages[indexPath.row]
        if message.chatType == .typing{
            let height = self.calculateHeightForChatMessageCell(indexPath: indexPath, message: message)
            return height
        }
        if let height = estimatedHeights[indexPath]{
            return height
        }
        
        let height = self.calculateHeightForChatMessageCell(indexPath: indexPath, message: message)
        return height
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let message = self.chatMessages[indexPath.row]
        if message.chatType == .typing{
            let height = self.calculateHeightForChatMessageCell(indexPath: indexPath, message: message)
            return height
        }
        if let height = estimatedHeights[indexPath]{
            return height
        }
        let height = self.calculateHeightForChatMessageCell(indexPath: indexPath, message: message)
        return height
    }
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let message = chatMessages[indexPath.row]
        if let cell = cell as? EHSenderChatCell{
            if shouldShowPicForCell(indexPath: indexPath){
                cell.topConstraintOfChatLabel.constant = 17
                cell.profilePic.isHidden = false
            }
            else{
                cell.topConstraintOfChatLabel.constant = 0
                cell.profilePic.isHidden = true
            }
            if message.chatType == .typing{
                cell.labelWidthConstraint.constant = 80
            }
            else if message.chatType != .userChatCell{
                let width = UIScreen.main.bounds.size.width*0.75 - 20
                let size = cell.chatLabel.sizeThatFits(CGSize(width:width,height:cell.frame.size.height - 15))
                cell.labelWidthConstraint.constant = (size.width + 10) > 80 ? (size.width + 10) : 80
            }
        }
        
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        self.chatTableView.contentInset.top = 0
    }
}
extension EHChatViewController:UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.chatMessages.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let chatMessage = chatMessages[indexPath.row]
        switch chatMessage.chatType{
        case .senderSimpleChat:
            let cell = self.chatTableView.dequeueReusableCell(withIdentifier: "EHSenderChatCell", for: indexPath) as! EHSenderChatCell
            cell.chatLabel.text = chatMessage.text
            return cell
        default:
            break
        }
        let cell = self.chatTableView.dequeueReusableCell(withIdentifier: "EHSenderChatCell", for: indexPath) as! EHSenderChatCell
        return cell
    }
    
}
