//
//  EHChatMessage.swift
//  chatTable
//
//  Created by Shithin PV on 01/01/18.
//  Copyright © 2018 e3Help. All rights reserved.
//

import UIKit

enum EHChatType{
    case typing
    case senderSimpleChat
    case senderSliderChat
    case senderMultipleDropDown
    case senderSingleDropDown
    case userChatCell
    case none
}
enum EHDropDownType{
    case redirectToLink
    case simple
    case none
}

class EHChatMessage{
    var text:String = ""
    var chatType:EHChatType = .none
    var dropDownOptions:[EHDropDown] = []
    var slider = EHSlider()
}

class EHDropDown{
    var text:String = ""
    var dropDownType:EHDropDownType = .none
}
class EHSlider{
    var minValue:Int = 0
    var maxValue:Int = 100
}

