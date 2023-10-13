# ChatroomUIKit

[![CI Status](https://img.shields.io/travis/zjc19891106/ChatroomUIKit.svg?style=flat)](https://travis-ci.org/zjc19891106/ChatroomUIKit)
[![Version](https://img.shields.io/cocoapods/v/ChatroomUIKit.svg?style=flat)](https://cocoapods.org/pods/ChatroomUIKit)
[![License](https://img.shields.io/cocoapods/l/ChatroomUIKit.svg?style=flat)](https://cocoapods.org/pods/ChatroomUIKit)
[![Platform](https://img.shields.io/cocoapods/p/ChatroomUIKit.svg?style=flat)](https://cocoapods.org/pods/ChatroomUIKit)

# Sample Demo

After you download the project, there is a best practice demonstration project in the Example folder. You can refer to this project to build your business.

The QR code below is a demo that can be used to demonstrate and switch most functions of ChatroomUIKit.

![SampleDemo](./Documentation/demo.png).

# Chatroom UIKit Guide 

## Introduction

 This is a guide that provides an overview and usage examples for the Chatroom UIKit framework in iOS development. It covers various components and features of UIKit and aims to help developers understand and utilize the toolkit effectively.

## Table of Contents

- [Requirements](#requirements)
- [Installation](#installation)
- [Documentation](#documentation)
- [Structure](#structure)
- [QuickStart](#quickStart)
- [AdvancedUsage](#advancedusage)
- [Customize](#customize)
- [Contributing](#contributing)
- [License](#license)

# Requirements

- iOS 13.0+
- Xcode 13.0+
- Swift 5.0+

# Installation

You can install it using Swift Package Manager or CocoaPods. As a dependency to your Xcode project. Follow these steps:

## Swift Package Manager

1.Open your project in Xcode.

2.Go to the file.

3.Select add packages.

4.Search for "ChatroomUIKit" and select it.

5.Choose the desired version.

6.Click "Add".

## CocoaPods

```
   pod 'ChatroomUIKit'
```

# Structure

### ChatroomUIKit Basic Components
- Classes: Contains the main ChatroomUIKit classes and components.
```
ChatroomUIKit  
├─ Service                           // Basic service components
│  ├─ Protocol                       // ChatroomUIKit business protocols.Component    
│  │  ├─ GiftService                 // Gift send and receive channel.
│  │  ├─ UserService                 // User login and update your profile.
│  │  └─ ChatroomService             // The chat room management protocol includes the join and leave operations of the chat room as well as operations on members, sending and receiving messages, etc.
│  ├─ Implement                      // Protocol implement. 
│  └─ Client                         // ChatroomUIKit initialize class.
│
└─ UI                                // Basic UI components without business
   ├─ Resource                       // Image or localize file.
   ├─ Component                      // UI module containing specific business.Some functional UI components in chat room UIKit
   │  ├─ Room                        // All chatroom view container.
   │  ├─ Chat                        // The barrage component and bottom functional area in the chat room. 
   │  ├─ Gift                        // Components such as the gift barrage area and gift container in the chat room.
   │  └─ Input                       // Input components in chat rooms include emoticons, etc.
   └─ Core
      ├─ UIKit                       // Some common UIKit components and custom related.
      ├─ Theme                       // Theme-related components include colors, fonts, skinning protocols and their components.
      └─ Extension                   // Some convenient system class extensions.

   
```

# Documentation

## [Document](https://github.com/zjc19891106/ChatroomUIKit/tree/main/Documentation/ChatroomUIKit.doccarchive)
 You can use Xcode to open the ChatroomUIKit.doccarchive file to view the document in Xcode deploy it to your homepage for viewing.
 
 You can also right-click to display the package contents and copy all files inside to a folder. Then drag this folder to the `terminal` app and run the following command to deploy it to the local IP address. You can view it by accessing the link, or you can deploy it to an external network address.
 
 ```
 python3 -m http.server 8080
 ```
 
 Then,open `http://yourlocalhost:8080/documentation/chatroomuikit` in your browser.yourlocalhost is your local ip address.
 
## [Appearance](https://github.com/zjc19891106/ChatroomUIKit/tree/main/Documentation/Appearance.md).
Detailed illustrations of available items in the UI part.

## [ComponentRegister](https://github.com/zjc19891106/ChatroomUIKit/tree/main/Documentation/ComponentRegister.md).
UI components can be inherited to add specific illustrations of custom business parts.

## [GiftsViewController](https://github.com/zjc19891106/ChatroomUIKit/blob/main/Documentation/GiftsViewController.md)
This is a container containing a gift list. You can inherit this class to implement additional UI definitions and business processing. After clicking the Send button, decide whether to close the gift pop-up window after a gift is delivered to display some animation effects and display special effects. It is recommended to use Tencent libpag, or go to the server to call the gift interface in your business, and then send the gift message to the chat room after the call is successful.

# QuickStart

This guide provides several usage examples for different ChatroomUIKit components. Refer to the Examples folder for detailed code snippets and projects showcasing various use cases.

### Step 1: Initialize ChatroomUIKit

```Swift

import UIKit
import ChatroomUIKit
    
@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        // You can initialize ChatroomUIKit when the app loads or before you need to use ChatroomUIKit
        //What's app key?Where to get?
        //You can visit `https://docs.agora.io/en/agora-chat/get-started/enable?platform=ios` website.
        ChatroomUIKitClient.shared.setup(with: "Appkey")
        return true
    }
}
```
### Step 2: Login

```Swift
        // Use the user information of the current user object that conforms to the UserInfoProtocol protocol to log in to ChatroomUIKit
        // The token needs to be obtained from your server. You can also log in with a temporary token visit at (https://console.agora.io/project/WLRRH-ir6/extension?id=Chat)
        // Where to get user id and token?
        // You can visit `https://console.agora.io/project/`
        // Then,follow the following process.`ProjectManager->Operation Manager->User->Create User`.Then `Basic Information->Application Info->Chat User temp token`.Next,fill below param.Move on,fill user id.
        ChatroomUIKitClient.shared.login(with userId: "user id", token: "token", completion: <#T##(ChatError?) -> Void#>)
```

### Step 3: Create chatroom view
```Swift
        //Required,you need fetch room list or create room contain owner info from app server.Then join room with chatroom id.
        // Let's start creating the ChatroomView. The parameters that need to be passed in include layout parameters, the bottom toolbar extension button model protocol array, whether to hide the button that evokes the input box, etc.
        // Where to get?
        // First,enter `https://console.agora.io/project/` console.
        // Follow the following process to create a chat room on console.    
        // `ProjectManager->Operation Manager->Chat Room->Create Chat Room`.
        //Then fill in the `chatroomId` parameter below.
        let roomView = ChatroomUIKitClient.shared.launchRoomView(roomId: String,frame: CGRect, is owner: Bool)        
        //Then add to you destination frame.
        //Next,process is `ProjectManager->Operation Manager->Chat Room->More->View chat room members->Add members.
```
# AdvancedUsage

Let me give three examples below

### 1.For example login

```Swift
        
        class YourAppUser: UserInfoProtocol {
            var userId: String = "your application user id"
            
            var nickName: String = "you user nick name"
            
            var avatarURL: String = "you user avatar url"
            
            var gender: Int = 1
            
            var identify: String =  "you user level symbol url"
            
        }
        // Use the user information of the current user object that conforms to the UserInfoProtocol protocol to log in to ChatroomUIKit
        // The token needs to be obtained from your server. You can also log in with a temporary token visit at (https://console.agora.io/project/WLRRH-ir6/extension?id=Chat)
        ChatroomUIKitClient.shared.login(with: YourAppUser(), token: "token", completion: <#T##(ChatError?) -> Void#>)
```

### 2.For example initialize chatroom view

```Swift
        //Required,you need fetch room list or create room contain owner info from app server.Then join room with chatroom id.
        // Let's start creating the ChatroomView. The parameters that need to be passed in include layout parameters, the bottom toolbar extension button model protocol array, whether to hide the button that evokes the input box, etc.
        let options  = ChatroomUIKitInitialOptions()
        options.bottomDataSource = self.bottomBarDatas()
        options.hasGiftsBarrage = true
        options.hiddenChatRaise = false
        ChatroomUIKitClient.shared.launchRoomViewWithOptions(roomId: "chatroom id", frame: .zero, is: true,options: options)        
        //Then add to you destination frame.
```

### 3.How listen to ChatroomUIKit events and error？

```Swift
        //You can call the method.
        ChatroomUIKitClient.shared.registerRoomEventsListener(listener: self)

``` 

# Customize

### 1.Modify configurable items
For example
```Swift
        // You can change the overall cell layout style of the barrage area by setting the properties.
        Appearance.barrageCellStyle = .excludeLevel
        // Let's start creating the ChatroomView. The parameters that need to be passed in include layout parameters, the bottom toolbar extension button model protocol array, whether to hide the button that evokes the input box, etc.
        let roomView = ChatroomUIKitClient.shared.launchRoomView(roomId: "chatroom Id", frame: <#T##CGRect#>)
        self.view.addSubView(roomView)
```
For details, please refer to [Appearance](https://github.com/zjc19891106/ChatroomUIKit/blob/main/Documentation/Appearance.md).

### 2.Custom components
For example
```Swift
        class CustomGiftBarragesViewCell: GiftBarrageCell {
            lazy var redDot: UIView = {
                UIView().backgroundColor(.red).cornerRadius(.large)
            }()
    
            override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
                super.init(style: style, reuseIdentifier: reuseIdentifier)
                self.addSubview(redDot)
            }
    
            override func refresh(item: GiftEntityProtocol) {
                super.refresh(item: item)
                self.redDot.isHidden = item.selected
            }
        }
        //Register the custom class that integrates the original class into ChatroomUIKit to complete the replacement.
        //Note that before creating a ChatroomView or using other UI components, use.
        ComponentsRegister.shared.GiftBarragesViewCell = CustomGiftBarragesViewCell.self
```

For details, please refer to [ComponentsRegister](https://github.com/zjc19891106/ChatroomUIKit/blob/main/Documentation/ComponentsRegister.md).

### 3.Switch original or custom theme

- Switch original theme
```Swift
        //When you want to switch the light and dark themes that come with ChatroomUIKit, you can use the following method when switching themes in the iOS system
        `Theme.switchTheme(style: .dark)` or `Theme.switchTheme(style: .light)`
```

- Switch custom theme
```Swift
        /**
         How to custom theme?
         Users only need to determine the hue values of the following five theme colors based on the theme color of the design document to implement a customized theme.
         All colors in ChatroomUIKit use the HSLA color model.
         The HSLA color model is a model for describing colors, which includes the following elements:

         H (Hue): Indicates hue, which is the basic attribute of color, such as red, blue, green, etc. It is represented by an angle value, ranging from 0° to 360°, 0° represents red, 120° represents green, and 240° represents blue.

         S (Saturation): Indicates saturation, that is, the purity or concentration of a color. The higher the saturation, the brighter the color; the lower the saturation, the darker the color. It is represented by a percentage value, ranging from 0% to 100%, 0% represents gray, and 100% represents solid color.

         L (Lightness): Indicates brightness, that is, the lightness or darkness of a color. The higher the brightness, the brighter the color, the lower the brightness, the darker the color. It is represented by a percentage value, ranging from 0% to 100%, with 0% representing black and 100% representing white.

         A (Alpha): Indicates transparency, that is, the degree of transparency of the color. An A value of 1 means completely opaque, and an A value of 0 means completely transparent.

         By adjusting the values of individual components of the HSLA model, precise control of color can be achieved.
         */
        Appearance.primaryHue = 191/360.0
        Appearance.secondaryHue = 210/360.0
        Appearance.errorHue = 189/360.0
        Appearance.neutralHue = 191/360.0
        Appearance.neutralSpecialHue = 199/360.0
        Theme.switchHues()
```

For details, please refer to [UIDesign](https://www.figma.com/file/OX2dUdilAKHahAh9VwX8aI/Streamuikit?node-id=137%3A38589&mode=dev).

Please note that custom themes and native themes are mutually exclusive and do not support simultaneous switching.

# Contributing

Contributions and feedback are welcome! If you find any issues or have suggestions for improvements, please open an issue or submit a pull request.


## Author

zjc19891106, 984065974@qq.com

## License

ChatroomUIKit is available under the MIT license. See the LICENSE file for more info.
