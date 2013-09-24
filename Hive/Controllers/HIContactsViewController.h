//
//  HIContactsViewController.h
//  Hive
//
//  Created by Bazyli Zygan on 28.08.2013.
//  Copyright (c) 2013 Hive Developers. All rights reserved.
//

#import "HIViewController.h"

@interface HIContactsViewController : HIViewController <NSTableViewDataSource, NSTableViewDelegate>

@property (strong) IBOutlet NSTableView *tableView;
@property (strong) IBOutlet NSView *navigationView;
@property (nonatomic, readonly, getter = managedObjectContext) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, readonly, getter = sortDescriptors) NSArray *sortDescriptors;
@property (strong) IBOutlet NSArrayController *arrayController;
- (IBAction)newContactClicked:(NSButton *)sender;
@end