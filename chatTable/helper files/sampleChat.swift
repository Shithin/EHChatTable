//
//  sampleChat.swift
//  chatTable
//
//  Created by Shithin PV on 04/01/18.
//  Copyright © 2018 e3Help. All rights reserved.
//

import UIKit

func sampleChatMaker() -> [EHChatMessage]{
    let chats = ["Hi User.",
                "All the message is from one api result. By using timing functions it's get seperated to different messages.",
                "Yes. It's an illution!.",
                "It's just a sample chat even though I will show all the features."]
    var sampleChat:[EHChatMessage] = []
    for chat in chats{
        let chatObject = EHChatMessage()
        chatObject.chatType = .senderSimpleChat
        chatObject.text = chat
        sampleChat.append(chatObject)
    }
    return sampleChat
}


