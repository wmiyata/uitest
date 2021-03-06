//
//  LiveHouseViewController.m
//  tab
//
//  Created by Wataru Miyata on 2014/02/15.
//  Copyright (c) 2014年 MIYATA Wataru. All rights reserved.
//

#import "LiveHouseViewController.h"
#import "LiveInfoTrait.h"
#import "LiveHouseTrait.h"
#import "HomeViewController.h"
#import "LiveListViewController.h"
#import "Common.h"

@interface LiveHouseViewController ()

@end

@implementation LiveHouseViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	
	self.items = [LiveHouseTrait traitList];
    
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc] init];
	backButton.title = @"Back";
	[self.navigationItem setBackBarButtonItem:backButton];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)didLoadMast
{
	self.items = [LiveHouseTrait traitList];
	[super reloadTable];
}

// =============================================================================
#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return [self.items count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
	UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil) {
        
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle
										  reuseIdentifier:CellIdentifier];
        
        
    }
	cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
	
	const LiveHouseTrait *trait = [self.items objectAtIndex:indexPath.row];
    UIFont *font = [UIFont fontWithName:@"HiraKakuProN-W6" size:16];
	cell.textLabel.font = font;
	cell.textLabel.attributedText = [NSAttributedString tlsAttributedStringWithString:trait.name
                                                                            lineSpace:2.0f];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	LiveHouseTrait *trait = self.items[indexPath.row];
	
	//詳細view表示
	LiveListViewController *instance = [[LiveListViewController alloc] initWithTrait:trait];
	
	[self.navigationController pushViewController:instance
										 animated:YES];
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

// =============================================================================
#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 40;
}

@end
