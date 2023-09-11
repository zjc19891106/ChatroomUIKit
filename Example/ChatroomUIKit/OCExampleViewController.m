//
//  OCExampleViewController.m
//  ChatroomUIKit_Example
//
//  Created by 朱继超 on 2023/8/31.
//  Copyright © 2023 CocoaPods. All rights reserved.
//

#import "OCExampleViewController.h"
#import <ChatroomUIKit-Swift.h>

@interface OCExampleViewController ()

@end

@implementation OCExampleViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    ActionSheet *sheet = [[ActionSheet alloc] initWithItems:@[[[ActionSheetItem alloc] initWithTitle:@"Normal" type:ActionSheetItemTypeNormal tag:@"" action:^(id<ActionSheetItemProtocol> _Nonnull item) {
        
    }]] title:nil message:nil];
    [self.view addSubview:sheet];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
