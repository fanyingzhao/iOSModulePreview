//
//  HomeTableViewController.m
//  iOSModulePreview
//
//  Created by silent.shi on 15/8/29.
//  Copyright (c) 2015年 Gao Friend Information and Technology Inc. All rights reserved.
//

#import "HomeTableViewController.h"
#import "MapAnchorViewController.h"
#import "MapTrackViewController.h"
#import "CodeScanViewController.h"

@interface HomeTableViewController ()

@property (nonatomic, copy) NSArray *moduleArray;

@end

@implementation HomeTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self getModuleNameArray];
    [self configureViews];
}

#pragma mark - Private methods
- (void)configureViews {
    self.tableView.dataSource=self;
    self.tableView.delegate=self;
    self.tableView.tableFooterView=[[UIView alloc] init];
}

- (void)getModuleNameArray {
    self.moduleArray=@[@"MapAnchor",
                       @"MapTrack",
                       @"CodeScan"];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return self.moduleArray.count;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellId=@"cellIdentifier";
    UITableViewCell *cell=[tableView dequeueReusableCellWithIdentifier:cellId];
    if (!cell) {
        cell=[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellId];
    }
    cell.accessoryType=UITableViewCellAccessoryDisclosureIndicator;
    cell.textLabel.text=[self.moduleArray objectAtIndex:indexPath.row];
    return cell;
}

#pragma mark - Table view delgate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    switch (indexPath.row) {
        case 0:
        {
            MapAnchorViewController *mapAnchor=[[MapAnchorViewController alloc] init];
            mapAnchor.title=@"MapAnchor";
            [self.navigationController pushViewController:mapAnchor animated:YES];
        }
            break;
        case 1:
        {
            MapTrackViewController  *mapTrack=[[MapTrackViewController alloc] init];
            mapTrack.title=@"MapTrack";
            [self.navigationController pushViewController:mapTrack animated:YES];
        }
            break;
        case 2:
        {
            CodeScanViewController  *codeScan=[[CodeScanViewController alloc] init];
            codeScan.title=@"CodeScan";
            [self.navigationController pushViewController:codeScan animated:YES];
        }
            break;
        default:
            break;
    }
}


@end
