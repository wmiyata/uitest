//
//  FirstViewController.m
//  tab
//
//  Created by MIYATA Wataru on 2014/02/05.
//  Copyright (c) 2014年 MIYATA Wataru. All rights reserved.
//

#import "HomeViewController.h"
#import "CustomTableViewCell.h"
#import "LiveInfoTrait.h"
#import "TabBarController.h"
#import "DetailViewController.h"
#import "CKViewController.h"
#import "Common.h"
#import "LoadData.h"

@implementation HomeViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	
    _currentDate = [NSDate date];
	self.items = [LiveInfoTrait traitListWithDate:_currentDate];
	
	//タイトル設定
	self.navigationItem.title = [NSString stringWithDateFormat:@"yyyy/MM/dd (E)" date:_currentDate];
    UIBarButtonItem *btn = [[UIBarButtonItem alloc]
                            initWithTitle:@"カレンダー"
                            style:UIBarButtonItemStylePlain
                            target:self
                            action:@selector(showCalendar:)];
    self.navigationItem.rightBarButtonItem = btn;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)showCalendar:(UIBarButtonItem*)buttonItem
{
    CKViewController *controller = [[CKViewController alloc] initWithCurrentDate:_currentDate];
    [self.navigationController pushViewController:controller animated:YES];
}

- (void)changeDate:(NSDate*)date
{
    _currentDate = date;
    
    //お気に入り登録されているライブを最上段に表示
    NSMutableArray *liveList = [NSMutableArray arrayWithArray:[LiveInfoTrait traitListWithDate:_currentDate]];
    NSMutableArray *favList = [NSMutableArray array];
    for( const LiveInfoTrait *trait in liveList )
    {
        if( [trait isFavorite] )
        {
            [favList addObject:trait];
        }
    }
    for( const LiveInfoTrait *trait in [favList reverseObjectEnumerator] )
    {
        //先頭に移動
        [liveList removeObject:trait];
        [liveList insertObject:trait atIndex:0];
    }
    
    self.items = liveList;
    self.navigationItem.title = [NSString stringWithDateFormat:@"yyyy/MM/dd (E)" date:_currentDate];
    [self reloadTable];
}

- (void) didSelect:(TabBarController *)tabBarController
{
	[super didSelect:tabBarController];
	
	//タブを押された時今日の予定を表示
	[self changeDate:[NSDate date]];
}

- (void)didLoadMast
{
	[self changeDate:_currentDate];
}
@end
