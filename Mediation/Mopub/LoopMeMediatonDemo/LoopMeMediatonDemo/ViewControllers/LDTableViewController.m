//
//  LDTableViewController.m
//  LoopMeMediatonDemo
//
//  Created by Dmitriy on 7/31/15.
//  Copyright (c) 2015 injectios. All rights reserved.
//

#import "LDTableViewController.h"

@interface LDTableViewController ()

@property (nonatomic, strong) NSArray *menuItems;
@end

@implementation LDTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.menuItems = [NSArray arrayWithObjects:@"Native Ads (Ad Request)", @"Interstitial Ad",  @"Rewarded Video Ad", nil];
    //TODO: bridge for MPTableViewPlacer
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.menuItems count];;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"LDMenuItemIdentifier"
                                                            forIndexPath:indexPath];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"LDMenuItemIdentifier"];
    }
    
    cell.textLabel.text = self.menuItems[indexPath.row];
    
    return cell;
}

// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == 0) {
        [self performSegueWithIdentifier:@"LDShowAdRequestSegueIdentifier" sender:self];
    } else if (indexPath.row == 1) {
        [self performSegueWithIdentifier:@"LDShowIntAdSegueIdentifier" sender:self];
    } else if (indexPath.row == 2) {
        [self performSegueWithIdentifier:@"LDShowRWSegueIdentifier" sender:self];
    }
}

@end
