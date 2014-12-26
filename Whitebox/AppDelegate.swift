//
//  AppDelegate.swift
//  Whitebox
//
//  Created by Olegs on 01/11/14.
//  Copyright (c) 2014 Brand New Heroes. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate, ScreenGrabberDelegate, ReactorDelegate {

    @IBOutlet weak var menu           : NSMenu!
    @IBOutlet weak var settingsWindow : NSWindow!
    @IBOutlet weak var capture_list_vc: CaptureMenuListViewController!

    let statusBar       : NSStatusBar  = NSStatusBar.systemStatusBar()
    let defaultMenuIcon : NSImage      = NSImage(named: "MenuIcon")!
    var statusBarItem   : NSStatusItem = NSStatusItem()
    let plugin_reactor  : Reactor      = Reactor()
//    let capture_list_vc : CaptureMenuListViewController = CaptureMenuListViewController(nibName: nil, bundle: nil)!
    
    let FETCH_LIMIT     : Int          = 10
    
    @IBAction func captureScreen(sender: AnyObject) {
        let options = NSDictionary()
        ScreenGrabber.capture(options, delegate: self)
    }
    
    @IBAction func quit(sender: AnyObject) {
        exit(0)
    }
    
    @IBAction func openSettingsWindow(sender: AnyObject) {
        settingsWindow.makeKeyAndOrderFront(self)
        NSApp.activateIgnoringOtherApps(true)
    }
    
    func applicationDidFinishLaunching(aNotification: NSNotification) {
        // Insert code here to initialize your application
    }

    func applicationWillTerminate(aNotification: NSNotification) {
        // Insert code here to tear down your application
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        initSettings()
        initMenuIcon()
        initPlugins()
        registerPlugins()
        buildMenuItemView()
        buildSettingsView()
    }
    
    // MARK: - Fetch last N items
    
    func loadRecentCaptures(fetch_limit : Int) -> NSArray {
        let request : NSFetchRequest = NSFetchRequest(entityName: "Capture")
        request.sortDescriptors = [NSSortDescriptor(key: "created_at", ascending: false)]
        request.fetchLimit = fetch_limit
        return managedObjectContext!.executeFetchRequest(request, error: nil)!
    }
    
    // MARK: - Build view
    
    func buildMenuItemView() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "reloadMenuItemView", name: "CaptureListDidChange", object: nil)
        self.reloadMenuItemView()
    }
    
    func reloadMenuItemView() {
        let capture_list : NSArray   = loadRecentCaptures(FETCH_LIMIT)
        capture_list_vc.capture_list = capture_list
        capture_list_vc.plugins      = PluginManager.plugins()
        capture_list_vc.captureListDidChange(nil)
    }
    
    func buildSettingsView() {
        // TODO
    }
    
    // MARK: - Init global settings
    
    func initSettings() {
        NSLog("Will init the global settings");
        let options : NSDictionary = NSDictionary(
            contentsOfFile: NSBundle.mainBundle().pathForResource("Settings", ofType: "plist")!
        )!
        WhiteBox.setOptions(options);
        NSLog("Done initing the global settings");
    }
    
    // MARK: - Init plugins
    
    func initPlugins() {
        NSLog("Will init plugins")
        let plugin_settings : NSDictionary = NSDictionary(
            contentsOfFile: NSBundle.mainBundle().pathForResource("StoragePlugins", ofType: "plist")!
            )!
        NSLog("Plugin settings: %@", plugin_settings)
        PluginManager.initPlugins(plugin_settings);
        NSLog("Done initing plugins")
    }
    
    func registerPlugins() {
        NSLog("Will register plugins in the reactor")
        for item in PluginManager.plugins() {
            let plugin : ReactorPlugin = item as ReactorPlugin
            NSLog("Registering %@", _stdlib_getTypeName(item))
            plugin_reactor.registerPlugin(plugin)
        }
        NSLog("Done registering plugins in the reactor")
    }
    
    // MARK: - Inteface build section
    
    func initMenuIcon() {
        statusBarItem = statusBar.statusItemWithLength(-1)
        statusBarItem.image = defaultMenuIcon
        statusBarItem.alternateImage = defaultMenuIcon
        statusBarItem.menu = menu
    }

    // MARK: - Core Data stack

    lazy var applicationDocumentsDirectory: NSURL = {
        // The directory the application uses to store the Core Data store file. This code uses a directory named "brandnewheroes.com.Whitebox" in the user's Application Support directory.
        let urls = NSFileManager.defaultManager().URLsForDirectory(.ApplicationSupportDirectory, inDomains: .UserDomainMask)
        let appSupportURL = urls[urls.count - 1] as NSURL
        return appSupportURL.URLByAppendingPathComponent("brandnewheroes.com.Whitebox")
    }()

    lazy var managedObjectModel: NSManagedObjectModel = {
        // The managed object model for the application. This property is not optional. It is a fatal error for the application not to be able to find and load its model.
        let modelURL = NSBundle.mainBundle().URLForResource("Whitebox", withExtension: "momd")!
        NSLog("ModelURL: %@", modelURL)
        return NSManagedObjectModel(contentsOfURL: modelURL)!
    }()

    lazy var persistentStoreCoordinator: NSPersistentStoreCoordinator? = {
        // The persistent store coordinator for the application. This implementation creates and return a coordinator, having added the store for the application to it. (The directory for the store is created, if necessary.) This property is optional since there are legitimate error conditions that could cause the creation of the store to fail.
        let fileManager = NSFileManager.defaultManager()
        var shouldFail = false
        var error: NSError? = nil
        var failureReason = "There was an error creating or loading the application's saved data."

        // Make sure the application files directory is there
        let propertiesOpt = self.applicationDocumentsDirectory.resourceValuesForKeys([NSURLIsDirectoryKey], error: &error)
        if let properties = propertiesOpt {
            if !properties[NSURLIsDirectoryKey]!.boolValue {
                failureReason = "Expected a folder to store application data, found a file \(self.applicationDocumentsDirectory.path)."
                shouldFail = true
            }
        } else if error!.code == NSFileReadNoSuchFileError {
            error = nil
            fileManager.createDirectoryAtPath(self.applicationDocumentsDirectory.path!, withIntermediateDirectories: true, attributes: nil, error: &error)
        }
        
        // Create the coordinator and store
        var coordinator: NSPersistentStoreCoordinator?
        if !shouldFail && (error == nil) {
            coordinator = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)
            let url = self.applicationDocumentsDirectory.URLByAppendingPathComponent("Whitebox.storedata")
            NSLog("Storage url: %@", url)
            if coordinator!.addPersistentStoreWithType(NSXMLStoreType, configuration: nil, URL: url, options: nil, error: &error) == nil {
                coordinator = nil
            }
        }
        
        if shouldFail || (error != nil) {
            // Report any error we got.
            let dict = NSMutableDictionary()
            dict[NSLocalizedDescriptionKey] = "Failed to initialize the application's saved data"
            dict[NSLocalizedFailureReasonErrorKey] = failureReason
            if error != nil {
                dict[NSUnderlyingErrorKey] = error
            }
            error = NSError(domain: "YOUR_ERROR_DOMAIN", code: 9999, userInfo: dict)
            NSApplication.sharedApplication().presentError(error!)
            return nil
        } else {
            return coordinator
        }
    }()

    lazy var managedObjectContext: NSManagedObjectContext? = {
        // Returns the managed object context for the application (which is already bound to the persistent store coordinator for the application.) This property is optional since there are legitimate error conditions that could cause the creation of the context to fail.
        let coordinator = self.persistentStoreCoordinator
        if coordinator == nil {
            return nil
        }
        var managedObjectContext = NSManagedObjectContext()
        managedObjectContext.persistentStoreCoordinator = coordinator
        return managedObjectContext
    }()

    // MARK: - Core Data Saving and Undo support

    @IBAction func saveAction(sender: AnyObject!) {
        // Performs the save action for the application, which is to send the save: message to the application's managed object context. Any encountered errors are presented to the user.
        if let moc = self.managedObjectContext {
            if !moc.commitEditing() {
                NSLog("\(NSStringFromClass(self.dynamicType)) unable to commit editing before saving")
            }
            var error: NSError? = nil
            if moc.hasChanges && !moc.save(&error) {
                NSApplication.sharedApplication().presentError(error!)
            }
        NSNotificationCenter.defaultCenter().postNotificationName("CaptureListDidChange", object: nil)
        }
    }

    func windowWillReturnUndoManager(window: NSWindow) -> NSUndoManager? {
        // Returns the NSUndoManager for the application. In this case, the manager returned is that of the managed object context for the application.
        if let moc = self.managedObjectContext {
            return moc.undoManager
        } else {
            return nil
        }
    }

    func applicationShouldTerminate(sender: NSApplication) -> NSApplicationTerminateReply {
        // Save changes in the application's managed object context before the application terminates.
        
        if let moc = managedObjectContext {
            if !moc.commitEditing() {
                NSLog("\(NSStringFromClass(self.dynamicType)) unable to commit editing to terminate")
                return .TerminateCancel
            }
            
            if !moc.hasChanges {
                return .TerminateNow
            }
            
            var error: NSError? = nil
            if !moc.save(&error) {
                // Customize this code block to include application-specific recovery steps.
                let result = sender.presentError(error!)
                if (result) {
                    return .TerminateCancel
                }
                
                let question = NSLocalizedString("Could not save changes while quitting. Quit anyway?", comment: "Quit without saves error question message")
                let info = NSLocalizedString("Quitting now will lose any changes you have made since the last successful save", comment: "Quit without saves error question info");
                let quitButton = NSLocalizedString("Quit anyway", comment: "Quit anyway button title")
                let cancelButton = NSLocalizedString("Cancel", comment: "Cancel button title")
                let alert = NSAlert()
                alert.messageText = question
                alert.informativeText = info
                alert.addButtonWithTitle(quitButton)
                alert.addButtonWithTitle(cancelButton)
                
                let answer = alert.runModal()
                if answer == NSAlertFirstButtonReturn {
                    return .TerminateCancel
                }
            }
        }
        // If we got here, it is time to quit.
        return .TerminateNow
    }

    // ScreenCaprureDelegate protocol section
    
    func screenGrabberComplete(handle: NSFileHandle?) {
        
        if handle === nil { return }
        
        let capture : Capture = NSEntityDescription.insertNewObjectForEntityForName("Capture", inManagedObjectContext: managedObjectContext!) as Capture
        
        capture.type = NSNumber(int: CAPTURE_TYPE_SCREEN_IMG)
        capture.created_at = NSDate()
        
        NSLog("Capture: %@", capture)
        
        let shared_context : NSMutableDictionary = NSMutableDictionary(objectsAndKeys:
                capture, SHRD_CTX_CAPTURE_MNGD_OBJ,
                handle!, SHRD_CTX_TMP_FILE_HANDLE
        )
        
        let reactor_data : ReactorData = ReactorData(data: shared_context)
        
        plugin_reactor.emitEvent(RE_SCREEN_CAPTURE_CREATED, data: reactor_data, delegate: self)
    }
    
    func screenGrabberFail(error: NSError) {
        // TODO
        NSLog("%@", error)
        NSLog("Fail!")
    }
    
    func screenGrabberFinally() {
    }
    
    // End of ScreenCaprureDelegate protocol section
    
    
    func reactorComplete(data: NSData!) {
        NSLog("Reactor complete")
        self.saveAction(nil)
    }
    
    func reactorFail(error: NSError!) {
        // TODO
    }
    
    func reactorFinally() {
        
    }
}

