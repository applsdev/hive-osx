//
//  HIProfileViewController.h
//  Hive
//
//  Created by Jakub Suder on 30.08.2013.
//  Copyright (c) 2013 Hive Developers. All rights reserved.
//

#import "HIViewController.h"
#import "HIContact.h"
#import "HIProfileTabBarController.h"
#import "HIProfileTabView.h"
#import "HIFlippedView.h"
#import "HIBox.h"
#import "HITextField.h"

@interface HIProfileViewController : HIViewController <HIProfileTabBarControllerDelegate>

@property (strong) IBOutlet NSImageView *photoView;
@property (strong) IBOutlet NSTextField *nameLabel;
@property (strong) IBOutlet NSButton *sendBtcBtn;
@property (strong) IBOutlet HIProfileTabView *tabView;
@property (strong) IBOutlet NSView *contentView;
@property (strong) IBOutlet NSScrollView *profileScrollView;
@property (strong) IBOutlet NSView *profileView;

@property (strong) IBOutlet NSView *profileScrollContent;
@property (weak) IBOutlet HITextField *profileEmailField;
@property (weak) IBOutlet HIBox *addressBoxView;


- (id)initWithContact:(HIContact *)aContact;
- (IBAction) sendBitcoinsPressed:(id)sender;
- (IBAction)editButtonClicked:(NSButton *)sender;

@end