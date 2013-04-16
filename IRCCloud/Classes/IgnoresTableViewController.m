//
//  IgnoresTableViewController.m
//  IRCCloud
//
//  Created by Sam Steele on 4/15/13.
//  Copyright (c) 2013 IRCCloud, Ltd. All rights reserved.
//

#import "IgnoresTableViewController.h"
#import "NetworkConnection.h"

@implementation IgnoresTableViewController

-(id)initWithStyle:(UITableViewStyle)style {
    self = [super initWithStyle:style];
    if (self) {
        _addButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addButtonPressed)];
    }
    return self;
}

-(void)viewDidLoad {
    [super viewDidLoad];
    if([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        self.navigationItem.rightBarButtonItem = _addButton;
    } else {
        self.navigationItem.leftBarButtonItem = _addButton;
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(doneButtonPressed)];
    }
}

-(void)viewWillAppear:(BOOL)animated {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleEvent:) name:kIRCCloudEventNotification object:nil];
}

-(void)viewWillDisappear:(BOOL)animated {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

-(void)handleEvent:(NSNotification *)notification {
    kIRCEvent event = [[notification.userInfo objectForKey:kIRCCloudEventKey] intValue];
    Server *s = nil;
    
    switch(event) {
        case kIRCEventSetIgnores:
            s = [[ServersDataSource sharedInstance] getServer:_cid];
            _ignores = s.ignores;
            [self.tableView reloadData];
            break;
        default:
            break;
    }
}

-(void)doneButtonPressed {
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(void)addButtonPressed {
    Server *s = [[ServersDataSource sharedInstance] getServer:_cid];
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:[NSString stringWithFormat:@"%@ (%@:%i)", s.name, s.hostname, s.port] message:@"Ignore this hostmask" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Ignore", nil];
    alert.alertViewStyle = UIAlertViewStylePlainTextInput;
    [alert show];
}

-(void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - Table view data source

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [[_ignores objectAtIndex:indexPath.row] sizeWithFont:[UIFont boldSystemFontOfSize:18] constrainedToSize:CGSizeMake(self.tableView.frame.size.width, CGFLOAT_MAX) lineBreakMode:NSLineBreakByCharWrapping].height + 16;
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    @synchronized(_ignores) {
        return [_ignores count];
    }
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    @synchronized(_ignores) {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ignorescell"];
        if(!cell)
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"ignorescell"];
        cell.textLabel.text = [_ignores objectAtIndex:[indexPath row]];
        cell.textLabel.font = [UIFont boldSystemFontOfSize:18];
        cell.textLabel.numberOfLines = 0;
        cell.textLabel.lineBreakMode = UILineBreakModeCharacterWrap;
        return cell;
    }
}

-(BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        NSString *mask = [_ignores objectAtIndex:indexPath.row];
        [[NetworkConnection sharedInstance] unignore:mask cid:_cid];
    }
}

#pragma mark - Table view delegate

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    NSString *title = [alertView buttonTitleAtIndex:buttonIndex];
    
    if([title isEqualToString:@"Ignore"]) {
        [[NetworkConnection sharedInstance] ignore:[alertView textFieldAtIndex:0].text cid:_cid];
    }
}

-(BOOL)alertViewShouldEnableFirstOtherButton:(UIAlertView *)alertView {
    if(alertView.alertViewStyle == UIAlertViewStylePlainTextInput && [alertView textFieldAtIndex:0].text.length == 0)
        return NO;
    else
        return YES;
}

@end