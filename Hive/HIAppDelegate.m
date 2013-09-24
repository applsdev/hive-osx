//
//  HIAppDelegate.m
//  Hive
//
//  Created by Bazyli Zygan on 11.06.2013.
//  Copyright (c) 2013 Hive Developers. All rights reserved.
//

#import <WebKit/WebKit.h>
#import "BCClient.h"
#import "HIAppDelegate.h"
#import "HIApplicationURLProtocol.h"
#import "HIMainWindowController.h"
#import "HISendBitcoinsWindowController.h"
#import "HITransaction.h"

@interface HIAppDelegate ()
{
    HIMainWindowController *_mainWindowController;
    NSMutableArray *_sendBitcoinsWindows;
//    NPPreferencesWindowController *_preferencesWindowController;
}
- (void)sendWindowDidClose:(NSNotification *)not;
@end


@implementation HIAppDelegate

@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize managedObjectContext = _managedObjectContext;


- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    [[NSUserDefaults standardUserDefaults] registerDefaults:@{@"Currency": @1, @"ExchangeCurrency1": @"USD", @"ExchangeCurrency2": @"PLN", @"FirstRun": @YES, @"LastBalance": @0,
     @"WebKitDeveloperExtras": @YES}];
    //[WebView registerURLSchemeAsLocal:@"hiveapp"];
    [NSURLProtocol registerClass:[HIApplicationURLProtocol class]];

    _mainWindowController = [[HIMainWindowController alloc] initWithWindowNibName:@"HIMainWindowController"];
    [_mainWindowController showWindow:self];

    _sendBitcoinsWindows = [NSMutableArray new];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(sendWindowDidClose:) name:HISendBitcoinsWindowDidClose object:nil];
    [[NSAppleEventManager sharedAppleEventManager] setEventHandler:self andSelector:@selector(handleURLEvent:withReplyEvent:) forEventClass:kInternetEventClass andEventID:kAEGetURL];

    // TODO: mocked transactions - remove once real transactions are working
    NSFetchRequest *transactionsRequest = [NSFetchRequest fetchRequestWithEntityName:HITransactionEntity];
    for (HITransaction *transaction in [DBM executeFetchRequest:transactionsRequest error:nil])
    {
        [DBM deleteObject:transaction];
    }

    NSFetchRequest *contactsRequest = [NSFetchRequest fetchRequestWithEntityName:HIContactEntity];
    NSArray *contacts = [DBM executeFetchRequest:contactsRequest error:nil];

    HITransaction *t;
    NSTimeInterval now = [[NSDate date] timeIntervalSince1970];

    t = [NSEntityDescription insertNewObjectForEntityForName:HITransactionEntity inManagedObjectContext:DBM];
    t.id = @"c87ba65b87ad65b87da5c";
    t.read = YES;
    t.amount = 150000000;
    t.date = now - 3600;
    t.senderHash = @"98d7cb0987ad0b987cb8ad8bc679";
    t.contact = (contacts.count > 0) ? contacts[0] : nil;

    t = [NSEntityDescription insertNewObjectForEntityForName:HITransactionEntity inManagedObjectContext:DBM];
    t.id = @"cbca67b9d76b98cd8b706a";
    t.read = YES;
    t.amount = -50000000;
    t.date = now - 86400;
    t.senderHash = @"a87b6dc57865a798b698ad7698";
    t.contact = (contacts.count > 1) ? contacts[1] : nil;

    t = [NSEntityDescription insertNewObjectForEntityForName:HITransactionEntity inManagedObjectContext:DBM];
    t.id = @"bcd786bd9a876b98da76c";
    t.read = YES;
    t.amount = 10000000;
    t.date = now - 250000;
    t.senderHash = @"adc4687c94d86abc9684bc8dabc79ad9b67b";
    t.contact = (contacts.count > 2) ? contacts[2] : nil;

    t = [NSEntityDescription insertNewObjectForEntityForName:HITransactionEntity inManagedObjectContext:DBM];
    t.id = @"bacd565bc734576da54bc7653";
    t.read = YES;
    t.amount = -200000000;
    t.date = now - 500000;
    t.senderHash = @"dabc4875d4b684adbc9746dabc79";

    t = [NSEntityDescription insertNewObjectForEntityForName:HITransactionEntity inManagedObjectContext:DBM];
    t.id = @"ce65e8756dc9785bc98d759875";
    t.read = YES;
    t.amount = 4200000;
    t.date = now - 350000;
    t.senderHash = @"8769876985cd875987c5ecd897";

    [DBM save:nil];
    // end mocked transactions
}

// Returns the directory the application uses to store the Core Data store file. This code uses a directory named "net.novaproject.Hive" in the user's Application Support directory.
- (NSURL *)applicationFilesDirectory
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSURL *appSupportURL = [[fileManager URLsForDirectory:NSApplicationSupportDirectory inDomains:NSUserDomainMask] lastObject];
    return [appSupportURL URLByAppendingPathComponent:@"Hive"];
}

// Creates if necessary and returns the managed object model for the application.
- (NSManagedObjectModel *)managedObjectModel
{
    if (_managedObjectModel) {
        return _managedObjectModel;
    }
	
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"Hive" withExtension:@"momd"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return _managedObjectModel;
}

// Returns the persistent store coordinator for the application. This implementation creates and return a coordinator, having added the store for the application to it. (The directory for the store is created, if necessary.)
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
    if (_persistentStoreCoordinator) {
        return _persistentStoreCoordinator;
    }
    
    NSManagedObjectModel *mom = [self managedObjectModel];
    if (!mom) {
        NSLog(@"%@:%@ No model to generate a store from", [self class], NSStringFromSelector(_cmd));
        return nil;
    }
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSURL *applicationFilesDirectory = [self applicationFilesDirectory];
    NSError *error = nil;
    
    NSDictionary *properties = [applicationFilesDirectory resourceValuesForKeys:@[NSURLIsDirectoryKey] error:&error];
    
    if (!properties) {
        BOOL ok = NO;
        if ([error code] == NSFileReadNoSuchFileError) {
            ok = [fileManager createDirectoryAtPath:[applicationFilesDirectory path] withIntermediateDirectories:YES attributes:nil error:&error];
            
        }
        if (!ok) {
            [[NSApplication sharedApplication] presentError:error];
            return nil;
        }
    } else {
        if (![properties[NSURLIsDirectoryKey] boolValue]) {
            // Customize and localize this error.
            NSString *failureDescription = [NSString stringWithFormat:@"Expected a folder to store application data, found a file (%@).", [applicationFilesDirectory path]];
            
            NSMutableDictionary *dict = [NSMutableDictionary dictionary];
            [dict setValue:failureDescription forKey:NSLocalizedDescriptionKey];
            error = [NSError errorWithDomain:@"net.novaproject.DatabaseError" code:101 userInfo:dict];
            
            [[NSApplication sharedApplication] presentError:error];
            return nil;
        }
    }
    
    NSURL *url = [applicationFilesDirectory URLByAppendingPathComponent:@"Hive.storedata"];
        
    NSPersistentStoreCoordinator *coordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:mom];
    if (![coordinator addPersistentStoreWithType:NSXMLStoreType configuration:nil URL:url options:nil error:&error])
    {
//        [[NSApplication sharedApplication] presentError:error];
        // So - we need to delete old file
        [[NSFileManager defaultManager] removeItemAtURL:url error:NULL];
        return [self persistentStoreCoordinator];
    }
    _persistentStoreCoordinator = coordinator;
    
    return _persistentStoreCoordinator;
}

// Returns the managed object context for the application (which is already bound to the persistent store coordinator for the application.) 
- (NSManagedObjectContext *)managedObjectContext
{
    if (_managedObjectContext) {
        return _managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (!coordinator) {
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
        [dict setValue:@"Failed to initialize the store" forKey:NSLocalizedDescriptionKey];
        [dict setValue:@"There was an error building up the data file." forKey:NSLocalizedFailureReasonErrorKey];
        NSError *error = [NSError errorWithDomain:@"YOUR_ERROR_DOMAIN" code:9999 userInfo:dict];
        [[NSApplication sharedApplication] presentError:error];
        return nil;
    }
    _managedObjectContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
    [_managedObjectContext setPersistentStoreCoordinator:coordinator];

    return _managedObjectContext;
}

// Returns the NSUndoManager for the application. In this case, the manager returned is that of the managed object context for the application.
- (NSUndoManager *)windowWillReturnUndoManager:(NSWindow *)window
{
    return [[self managedObjectContext] undoManager];
}

// Performs the save action for the application, which is to send the save: message to the application's managed object context. Any encountered errors are presented to the user.
- (IBAction)saveAction:(id)sender
{
    NSError *error = nil;
    
    if (![[self managedObjectContext] commitEditing]) {
        NSLog(@"%@:%@ unable to commit editing before saving", [self class], NSStringFromSelector(_cmd));
    }
    
    if (![[self managedObjectContext] save:&error]) {
        [[NSApplication sharedApplication] presentError:error];
    }
}

- (void)applicationWillTerminate:(NSNotification *)notification
{
//    [[BCClient sharedClient] shutdown];
}

- (NSApplicationTerminateReply)applicationShouldTerminate:(NSApplication *)sender
{
    // Save changes in the application's managed object context before the application terminates.
    
    if (!_managedObjectContext) {
        return NSTerminateNow;
    }
    
    if (![[self managedObjectContext] commitEditing]) {
        NSLog(@"%@:%@ unable to commit editing to terminate", [self class], NSStringFromSelector(_cmd));
        return NSTerminateCancel;
    }
    
    if (![[self managedObjectContext] hasChanges]) {
        return NSTerminateNow;
    }
    
    NSError *error = nil;
    if (![[self managedObjectContext] save:&error]) {

        // Customize this code block to include application-specific recovery steps.              
        BOOL result = [sender presentError:error];
        if (result) {
            return NSTerminateCancel;
        }

        NSString *question = NSLocalizedString(@"Could not save changes while quitting. Quit anyway?", @"Quit without saves error question message");
        NSString *info = NSLocalizedString(@"Quitting now will lose any changes you have made since the last successful save", @"Quit without saves error question info");
        NSString *quitButton = NSLocalizedString(@"Quit anyway", @"Quit anyway button title");
        NSString *cancelButton = NSLocalizedString(@"Cancel", @"Cancel button title");
        NSAlert *alert = [[NSAlert alloc] init];
        [alert setMessageText:question];
        [alert setInformativeText:info];
        [alert addButtonWithTitle:quitButton];
        [alert addButtonWithTitle:cancelButton];

        NSInteger answer = [alert runModal];
        
        if (answer == NSAlertAlternateReturn) {
            return NSTerminateCancel;
        }
    }

    return NSTerminateNow;
}

- (BOOL)applicationOpenUntitledFile:(NSApplication *)theApplication
{
    [_mainWindowController showWindow:nil];
    return  NO;
}

- (BOOL)application:(NSApplication *)sender openFile:(NSString *)filename
{
    if ([[filename pathExtension] compare:@"hiveapp"] == NSOrderedSame)
    {
        NSDictionary *manifest = [[BCClient sharedClient] applicationMetadata:[NSURL fileURLWithPath:filename]];
        NSAlert *alert = [[NSAlert alloc] init];
        [alert setMessageText:@"Install Hive App"];
        [alert addButtonWithTitle:@"Yes"];
        [alert addButtonWithTitle:@"No"];
        if ([[BCClient sharedClient] hasApplicationOfId:manifest[@"id"]])
            [alert setInformativeText:[NSString stringWithFormat:@"You already have \"%@\" application. Would you like to overwrite it?", manifest[@"name"]]];
        else
            [alert setInformativeText:[NSString stringWithFormat:@"Would you like to install \"%@\" application?", manifest[@"name"]]];
        
        if ([alert runModal] == NSAlertFirstButtonReturn)
        {
            [[BCClient sharedClient] installApplication:[NSURL fileURLWithPath:filename]];
        }
        
        return YES;
    }
    
    return NO;
}

- (void)handleURLEvent:(NSAppleEventDescriptor*)event withReplyEvent:(NSAppleEventDescriptor*)replyEvent
{
    id url = [event paramDescriptorForKeyword:keyDirectObject];
    NSLog(@"%@", url);
}

//- (void)application:(NSApplication *)sender openFiles:(NSArray *)filenames
//{
//    for (NSString *filename in filenames)
//    {
//        [self application:sender openFile:filename];
//    }
//}

- (IBAction)openPreferences:(id)sender
{
//    [self openPreferencesOnWalletConf:NO];
}

- (IBAction)openSendBitcoinsWindow:(id)sender
{
    [[self sendBitcoinsWindow] showWindow:self];
}

- (void)openPreferencesOnWalletConf:(BOOL)conf
{
//    if (!_preferencesWindowController)
//        _preferencesWindowController = [[NPPreferencesWindowController alloc] initWithWindowNibName:@"NPPreferencesWindowController"];
//    
//    _preferencesWindowController.openWalletEdit = conf;
//    [_preferencesWindowController showWindow:self];
}

- (HISendBitcoinsWindowController *)sendBitcoinsWindowForContact:(HIContact *)contact {
    HISendBitcoinsWindowController *wc = [[HISendBitcoinsWindowController alloc] initWithContact:contact];
    [_sendBitcoinsWindows addObject:wc];
    return wc;
}

- (HISendBitcoinsWindowController *)sendBitcoinsWindow
{
    HISendBitcoinsWindowController *wc = [[HISendBitcoinsWindowController alloc] init];
    [_sendBitcoinsWindows addObject:wc];
    return wc;
}

- (void)sendWindowDidClose:(NSNotification *)notification {
    HISendBitcoinsWindowController *wc = notification.object;
    [_sendBitcoinsWindows removeObject:wc];
}

@end