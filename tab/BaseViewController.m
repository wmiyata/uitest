//
//  BaseViewController.m
//  tab
//
//  Created by Wataru Miyata on 2014/02/15.
//  Copyright (c) 2014年 MIYATA Wataru. All rights reserved.
//

#import "BaseViewController.h"
#import "CustomTableViewCell.h"
#import "Common.h"
#import "DetailViewController.h"

@implementation BaseViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	
	UINib *nib = [UINib nibWithNibName:@"CustomTableViewCell" bundle:nil];
	[self.tableView registerNib:nib forCellReuseIdentifier:@"customCell"];
	
	_tableView.dataSource = self;
	_tableView.delegate = self;
    
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc] init];
	backButton.title = @"Back";
	[self.navigationItem setBackBarButtonItem:backButton];
	
	self.tableView.contentInset				= UIEdgeInsetsMake(0, 0, 50, 0);
	self.tableView.scrollIndicatorInsets	= UIEdgeInsetsMake(0, 0, 50, 0);
	
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(didLoadMast)
												 name:NOTICE_FINISH_LOADMAST
											   object:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)reloadTable
{
	[_tableView reloadData];
}

- (void)didLoadMast
{
	
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
    static NSString *CellIdentifier = @"customCell";
    
    CustomTableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil) {
        
        cell = [[CustomTableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle
										  reuseIdentifier:CellIdentifier];
        
        
    }
	
	const LiveInfoTrait *trait = [self.items objectAtIndex:indexPath.row];
	[cell setTextWithTrait:trait];
    
    return cell;
}

// =============================================================================
#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return CELL_HEIGHT;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	LiveInfoTrait *trait = self.items[indexPath.row];
	
	//詳細view表示
	DetailViewController *instance = [[DetailViewController alloc] initWithLiveInfoTrait:trait baseController:self];
	[self.navigationController pushViewController:instance
										 animated:YES];
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (void) tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    cell.backgroundColor = WHITE_COLOR;
}

#pragma mark - MyTabBarControllerDelegate
- (void) didSelect:(TabBarController *)tabBarController {
    [self.navigationController popToRootViewControllerAnimated:NO];
    
    NSIndexPath *index = [NSIndexPath indexPathForRow:0 inSection:0];
	if( _items && _items.count > 0 )
	{
		[_tableView scrollToRowAtIndexPath:index atScrollPosition:UITableViewScrollPositionNone animated:YES];
		[_tableView reloadData];
	}
}


@end