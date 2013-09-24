//
//  HISendBitcoinsWindowController.h
//  Hive
//
//  Created by Jakub Suder on 05.09.2013.
//  Copyright (c) 2013 Hive Developers. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "HIContact.h"
#import "HIContactAutocompleteWindowController.h"

@class HIButtonWithSpinner;

extern NSString * const HISendBitcoinsWindowDidClose;
extern NSString * const HISendBitcoinsWindowSuccessKey;

@interface HISendBitcoinsWindowController : NSWindowController <HIContactAutocompleteDelegate, NSWindowDelegate>

@property (strong) IBOutlet NSBox *wrapper;
@property (strong) IBOutlet NSBox *separator;
@property (strong) IBOutlet NSImageView *photoView;
@property (strong) IBOutlet NSTextField *nameLabel;
@property (strong) IBOutlet NSTextField *addressLabel;
@property (strong) IBOutlet NSTextField *amountField;
@property (strong) IBOutlet HIButtonWithSpinner *sendButton;
@property (nonatomic, strong) IBOutlet NSButton *dropdownButton;

@property (copy) void(^sendCompletion)(BOOL success, double amount, NSString *hash);

- (id)initWithContact:(HIContact *)contact;
- (void)setHashAddress:(NSString *)hash;
- (void)setLockedAmount:(double)amount;

- (IBAction)cancelClicked:(id)sender;
- (IBAction)sendClicked:(id)sender;
- (IBAction)dropdownButtonClicked:(id)sender;

@end