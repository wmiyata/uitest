//
//  FavViewController.m
//  tab
//
//  Created by Wataru Miyata on 2014/02/15.
//  Copyright (c) 2014年 MIYATA Wataru. All rights reserved.
//

#import "FavViewController.h"
#import "LiveInfoTrait.h"
#import "SettingData.h"
#import "CustomTableViewCell.h"

@interface FavViewController ()

@end

@implementation FavViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	
	_sectionArray = @[@"2014/02",@"2014/03"];

	NSArray *datas = [NSArray arrayWithObjects:self.items, self.items, nil];
	_dataSource = [NSDictionary dictionaryWithObjects:datas forKeys:_sectionArray];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)reloadFavItems
{
    NSMutableArray *favArray = [NSMutableArray array];
    NSArray *saveUniqueIdArray = [SettingData instance].favoriteLiveArray;
    for( NSString *uniqueId in saveUniqueIdArray )
    {
        const LiveInfoTrait *trait = [LiveInfoTrait traitOfUniqueID:uniqueId];
        if( trait )
        {
            [favArray addObject:trait];
        }
    }
	self.items = favArray;
    [self.tableView reloadData];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [_sectionArray count];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return [_sectionArray objectAtIndex:section];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"customCell";
    
    CustomTableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil) {
        
        cell = [[CustomTableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle
										  reuseIdentifier:CellIdentifier];
        
        
    }
	NSString *sectionName = [_sectionArray objectAtIndex:indexPath.section];
	
    // セクション名をキーにしてそのセクションの項目をすべて取得
    NSArray *items = [_dataSource objectForKey:sectionName];
	LiveInfoTrait *trait = [items objectAtIndex:indexPath.row];
	[cell setTextWithTrait:trait];
	return cell;
}

#pragma mark - MyTabBarControllerDelegate
- (void) didSelect:(TabBarController *)tabBarController {
    [self reloadFavItems];
}
@end
