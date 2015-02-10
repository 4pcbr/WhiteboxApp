//
//  AppDelegate.m
//  Whitebox
//
//  Created by Olegs on 02/01/15.
//  Copyright (c) 2015 Brand New Heroes. All rights reserved.
//

#import "AppDelegate.h"


@interface AppDelegate ()

@property (weak) IBOutlet NSMenu           *menu;
@property (weak) IBOutlet NSWindow         *settings_window;
@property (weak) IBOutlet WebView          *js_web_view_sb;
@property (weak) IBOutlet CaptureMenuListViewController *capture_list_vc;

@property (strong, atomic) NSStatusBar     *status_bar;
@property (strong, atomic) NSImage         *default_menu_icon;
@property (strong, atomic) NSStatusItem    *status_bar_item;
@property (strong, atomic) Reactor         *plugin_reactor;

- (IBAction) saveAction:(id)sender;
- (IBAction) captureScreen:(id)sender;
- (IBAction) quit:(id)sender;
- (IBAction) openSettingsWindow:(id)sender;

@end

static int FETCH_LIMIT = 10;

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    [self setPlugin_reactor:[[Reactor alloc] init]];
    [self initSettings];
    [self initMenuIcon];
    [self initPlugins];
    [self registerPlugins];
    [self buildMenuItemView];
    [self buildSettingsView];
}

- (void)applicationWillTerminate:(NSNotification *)aNotification {
    // Insert code here to tear down your application
}

#pragma mark - Core Data stack

@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize managedObjectContext = _managedObjectContext;

- (NSURL *)applicationDocumentsDirectory {
    // The directory the application uses to store the Core Data store file. This code uses a directory named "brandnewheroes.com.Whitebox" in the user's Application Support directory.
    NSURL *appSupportURL = [[[NSFileManager defaultManager] URLsForDirectory:NSApplicationSupportDirectory inDomains:NSUserDomainMask] lastObject];
    return [appSupportURL URLByAppendingPathComponent:@"brandnewheroes.com.Whitebox"];
}

- (NSManagedObjectModel *)managedObjectModel {
    // The managed object model for the application. It is a fatal error for the application not to be able to find and load its model.
    if (_managedObjectModel) {
        return _managedObjectModel;
    }
	
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"Whitebox" withExtension:@"momd"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return _managedObjectModel;
}

- (NSPersistentStoreCoordinator *)persistentStoreCoordinator {
    // The persistent store coordinator for the application. This implementation creates and return a coordinator, having added the store for the application to it. (The directory for the store is created, if necessary.)
    if (_persistentStoreCoordinator) {
        return _persistentStoreCoordinator;
    }
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSURL *applicationDocumentsDirectory = [self applicationDocumentsDirectory];
    BOOL shouldFail = NO;
    NSError *error = nil;
    NSString *failureReason = @"There was an error creating or loading the application's saved data.";
    
    // Make sure the application files directory is there
    NSDictionary *properties = [applicationDocumentsDirectory resourceValuesForKeys:@[NSURLIsDirectoryKey] error:&error];
    if (properties) {
        if (![properties[NSURLIsDirectoryKey] boolValue]) {
            failureReason = [NSString stringWithFormat:@"Expected a folder to store application data, found a file (%@).", [applicationDocumentsDirectory path]];
            shouldFail = YES;
        }
    } else if ([error code] == NSFileReadNoSuchFileError) {
        error = nil;
        [fileManager createDirectoryAtPath:[applicationDocumentsDirectory path] withIntermediateDirectories:YES attributes:nil error:&error];
    }
    
    if (!shouldFail && !error) {
        NSPersistentStoreCoordinator *coordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
        NSURL *url = [applicationDocumentsDirectory URLByAppendingPathComponent:@"OSXCoreDataObjC.storedata"];
        if (![coordinator addPersistentStoreWithType:NSXMLStoreType configuration:nil URL:url options:nil error:&error]) {
            coordinator = nil;
        }
        _persistentStoreCoordinator = coordinator;
    }
    
    if (shouldFail || error) {
        // Report any error we got.
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
        dict[NSLocalizedDescriptionKey] = @"Failed to initialize the application's saved data";
        dict[NSLocalizedFailureReasonErrorKey] = failureReason;
        if (error) {
            dict[NSUnderlyingErrorKey] = error;
        }
        error = [NSError errorWithDomain:@"YOUR_ERROR_DOMAIN" code:9999 userInfo:dict];
        [[NSApplication sharedApplication] presentError:error];
    }
    return _persistentStoreCoordinator;
}

- (NSManagedObjectContext *)managedObjectContext {
    // Returns the managed object context for the application (which is already bound to the persistent store coordinator for the application.)
    if (_managedObjectContext) {
        return _managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (!coordinator) {
        return nil;
    }
    _managedObjectContext = [[NSManagedObjectContext alloc] init];
    [_managedObjectContext setPersistentStoreCoordinator:coordinator];

    return _managedObjectContext;
}

#pragma mark - Core Data Saving and Undo support

- (IBAction)saveAction:(id)sender {
    // Performs the save action for the application, which is to send the save: message to the application's managed object context. Any encountered errors are presented to the user.
    if (![[self managedObjectContext] commitEditing]) {
        NSLog(@"%@:%@ unable to commit editing before saving", [self class], NSStringFromSelector(_cmd));
    }
    
    NSError *error = nil;
    if ([[self managedObjectContext] hasChanges] && ![[self managedObjectContext] save:&error]) {
        [[NSApplication sharedApplication] presentError:error];
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"CaptureListDidChange" object:nil];
}

- (IBAction)captureScreen:(id)sender {
    
    NSDictionary *options = [[NSDictionary alloc] init];
    
    [ScreenGrabber capture:options].then(^(NSFileHandle *file_handle) {
        if (file_handle == NULL) {
            return;
        }
        
        Session *session = [SessionManager createSession];
        
        Capture *capture = [NSEntityDescription insertNewObjectForEntityForName:@"Capture" inManagedObjectContext:[self managedObjectContext]];
        [capture setType:[NSNumber numberWithInt:CAPTURE_TYPE_SCREEN_IMG]];
        [capture setCreated_at:[NSDate date]];
        
        NSMutableDictionary *shared_context = [[NSMutableDictionary alloc] init];
        [shared_context setValue:capture               forKey:@SHRD_CTX_CAPTURE_MNGD_OBJ];
        [shared_context setValue:file_handle           forKey:@SHRD_CTX_TMP_FILE_HANDLE];
        [shared_context setValue:file_handle.file_path forKey:@SHRD_CTX_TMP_FILE_FULL_PATH];
        
        [session setContext:shared_context];
        [session setEventID:RE_SCREEN_CAPTURE_CREATED];
        // TODO: fix this place: event_id should be stored in session
        // Session might be renamed to ReactorEvent
        
        [[self plugin_reactor] emitEvent:RE_SCREEN_CAPTURE_CREATED session:session].then(^(NSData *data) {
            //[self saveAction:nil];
            [[self plugin_reactor] emitEvent:RE_EOC session:nil];
        }).catch(^(NSError *error) {
            NSLog(@"Reactor error: %@", error);
        }).finally(^{
            // OPTIONAL
        });
        
    }).catch(^(NSError *error) {
        // TODO
        NSLog(@"ScreenGrabber error: %@", error);
    }).finally(^{
        // OPTIONAL
    });
}

- (IBAction)quit:(id)sender {
    exit(0);
}

- (IBAction)openSettingsWindow:(id)sender {
    [[self settings_window] makeKeyAndOrderFront:self];
    [NSApp activateIgnoringOtherApps:YES];
}

- (NSUndoManager *)windowWillReturnUndoManager:(NSWindow *)window {
    // Returns the NSUndoManager for the application. In this case, the manager returned is that of the managed object context for the application.
    return [[self managedObjectContext] undoManager];
}

- (NSApplicationTerminateReply)applicationShouldTerminate:(NSApplication *)sender {
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
        
        if (answer == NSAlertFirstButtonReturn) {
            return NSTerminateCancel;
        }
    }

    return NSTerminateNow;
}

- (void) initSettings {
    NSLog(@"Will init the global settings");
    NSDictionary *options = [NSDictionary dictionaryWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"Settings" ofType:@"plist"]];
    [WhiteBox setOptions:options];
    [WhiteBox setValue:[self js_web_view_sb] ForPathKey:@"Sandbox.Web.JS"];
    NSLog(@"Done initing the global settings");
}

- (void) initPlugins {
    NSLog(@"Will init plugins");
    NSDictionary *plugin_settings = [NSDictionary dictionaryWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"StoragePlugins" ofType:@"plist"]];
    NSLog(@"Plugin settings: %@", plugin_settings);
    [PluginManager initPlugins:plugin_settings];
    
    [PluginManager registerFlyweight:^PMKPromise *(Session *session) {
        return [PMKPromise new:^(PMKPromiseFulfiller fulfill, PMKPromiseRejecter reject) {
            NSLog(@"EOC event catched by the flyweight");
            [self saveAction:nil];
        }];
    } forEventID:RE_EOC];
    
    NSLog(@"Done initing plugins");
}

- (void) registerPlugins {
    NSLog(@"Will register plugins in the reactor");
    for (ReactorPlugin *plugin in [PluginManager plugins]) {
        NSLog(@"Registering %@", [plugin className]);
        [[self plugin_reactor] registerPlugin:plugin];
    }
}

- (NSArray *) loadRecentCaptures:(NSUInteger)fetch_limit {
    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"Capture"];
    [request setSortDescriptors:[NSArray arrayWithObjects:[[NSSortDescriptor alloc] initWithKey:@"created_at" ascending:NO], nil]];
    [request setFetchLimit:fetch_limit];
    return [[self managedObjectContext] executeFetchRequest:request error:nil];
}

- (void) reloadMenuItemView {
    NSArray *capture_list = [self loadRecentCaptures:FETCH_LIMIT];
    [self capture_list_vc].capture_list = capture_list;
    [self capture_list_vc].plugins = [PluginManager plugins];
    [[self capture_list_vc] captureListDidChange:nil];
}

- (void) buildMenuItemView {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadMenuItemView) name:@"CaptureListDidChange" object:nil];
    [self reloadMenuItemView];
}

- (void) buildSettingsView {
    // TODO
}

- (void) initMenuIcon {
    [self setStatus_bar:[NSStatusBar systemStatusBar]];
    [self setStatus_bar_item:[[self status_bar] statusItemWithLength:-1]];
    [self setDefault_menu_icon:[NSImage imageNamed:@"MenuIcon"]];
    [[self status_bar_item] setImage:[self default_menu_icon]];
    [[self status_bar_item] setAlternateImage:[self default_menu_icon]];
    [[self status_bar_item] setMenu:[self menu]];
}

- (PMKPromise *) emitEvent:(int)event_id session:(Session *)session {
    NSLog(@"Bang!");
    return [[self plugin_reactor] emitEvent:event_id session:session];
}

@end
