//
//  AppDelegate.m
//  Stone
//
//  Created by Stanislav Cherednichenko on 17.02.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "AppDelegate.h"
#import "Zone.h"
#import "ZoneView.h"

@interface AppDelegate ()

@property (nonatomic, strong, readonly) NSStatusItem *systemTray;
@property (nonatomic, strong, readonly) NSMenu *menu;
@property (nonatomic, strong, readonly) Zone *currentStone;
@property (nonatomic, strong, readonly) NSDate *startDate;
@property (nonatomic, strong, readonly) NSTimer *timer;

- (void)_reloadData;
- (void)_stopStone;
- (void)_makeATickUpdate:(id)sender;

@end

@implementation AppDelegate

@synthesize window = _window;
@synthesize menu = _menu;
@synthesize systemTray = _systemTray;
@synthesize tableView = _tableView;
@synthesize currentStone = _currentStone;
@synthesize startDate = _startDate;
@synthesize timer = _timer;

- (void)_createTrayBar  {
    NSZone *menuZone = [NSMenu menuZone];
    _menu = [[NSMenu allocWithZone:menuZone] init];
    NSMenuItem *menuItem;
    
    [self.menu addItem:[NSMenuItem separatorItem]];
    
    menuItem = [self.menu addItemWithTitle:kReportsString action:@selector(openReports:) keyEquivalent:@""];
    [menuItem setTarget:self];
    
    menuItem = [self.menu addItemWithTitle:kPreferencesString action:@selector(openPreferences:) keyEquivalent:@""];
    [menuItem setTarget:self];
    
    menuItem = [self.menu addItemWithTitle:kQuitString action:@selector(killApplication:) keyEquivalent:@""];
    [menuItem setTarget:self];
    
    _systemTray = [[NSStatusBar systemStatusBar] statusItemWithLength:NSVariableStatusItemLength];
    
    self.systemTray.menu = self.menu;
    self.systemTray.highlightMode = YES;
    self.systemTray.toolTip = kTooltipString;
    self.systemTray.image = [NSImage imageNamed:kStoneImageName];
//    self.systemTray.target = self;
//    self.systemTray.action = @selector(systemTrayClicked:);
    self.systemTray.alternateImage = [NSImage imageNamed:kStoneImageHighlightedName];
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    srandom((unsigned int)time(NULL));
    [self _createTrayBar];
    
    [Zone addNewZone];
    [Zone addNewZone];
    [Zone addNewZone];
    
    [self _reloadData];
}

- (NSView *)tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row {
    ZoneView *zoneView = [[ZoneView alloc] init];
    Zone *zone = [tableView.dataSource tableView:tableView objectValueForTableColumn:tableColumn row:row];
    [zoneView setZone:zone];
    return zoneView;
}

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView {
    return [[Zone availableZones] count];
}

- (id)tableView:(NSTableView *)tableView objectValueForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row {
    return [[Zone availableZones] objectAtIndex:row];
}

// Don't know how make it better
- (void)_recompileMenuItems {
    
    for (NSMenuItem *item in self.menu.itemArray) {
        if (item.isSeparatorItem) {
            break;
        }
             
        [self.menu removeItemAtIndex:0];       
    }
    
    NSMenuItem *menuItem;
    Zone *zone;
    NSArray *zones = [Zone availableZones];
    for (NSInteger i = 0; i < [zones count]; i++) {
        zone = [zones objectAtIndex:i];
        menuItem = [self.menu insertItemWithTitle:[zone description] action:@selector(startStone:) keyEquivalent:@"" atIndex:i];
        menuItem.tag = i;
        [menuItem setTarget:self];
    }
}

- (void)_reloadData {
    [self.tableView reloadData];
    [self _recompileMenuItems];
}

- (IBAction)addNewZone:(NSButton *)button {
    [Zone addNewZone];
    [self _reloadData];
}

//- (void)systemTrayClicked:(NSStatusItem *)tray {
//    self.systemTray.image = [NSImage imageNamed:kStoneImageHighlightedName];
//}

- (void)startStone:(NSMenuItem *)menuItem {
    _startDate = [NSDate date];
    [self _stopStone];
    _timer = [NSTimer scheduledTimerWithTimeInterval:0.5f target:self selector:@selector(_makeATickUpdate:) userInfo:nil repeats:YES];
    _currentStone = [[Zone availableZones] objectAtIndex:menuItem.tag];
    [self.currentStone startPeriod];
    [self _makeATickUpdate:nil];
}

- (void)_stopStone {
    [_timer invalidate];
    _timer = nil;
    self.systemTray.title = @"";
    if (self.currentStone) {
        [self.currentStone stopPeriod];
    }
}

- (void)_makeATickUpdate:(id)sender {
    NSTimeInterval interval = [[NSDate date] timeIntervalSinceDate:self.startDate];
    
    NSInteger numSeconds = interval;
    NSInteger days = numSeconds / (60 * 60 * 24);
    numSeconds -= days * (60 * 60 * 24);
    NSInteger hours = numSeconds / (60 * 60);
    numSeconds -= hours * (60 * 60);
    NSInteger minutes = numSeconds / 60;
    numSeconds -= minutes * 60;
    
    self.systemTray.title = [NSString stringWithFormat:@"%.2d:%.2d:%.2d", hours, minutes, numSeconds];
}

- (void)openReports:(NSMenuItem *)menuItem {
}

- (void)openPreferences:(NSMenuItem *)menuItem {
}

- (void)killApplication:(NSMenuItem *)menuItem {
    [[NSApplication sharedApplication] terminate:menuItem];
}

@end
