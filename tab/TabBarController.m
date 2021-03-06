//
//  TabBarController.m
//  tab
//
//  Created by MIYATA Wataru on 2014/02/12.
//  Copyright (c) 2014年 MIYATA Wataru. All rights reserved.
//

#import "TabBarController.h"
#import <iAd/iAd.h>

@interface TabBarController ()

@end

@implementation TabBarController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
   
	self.delegate = self;
	
	int advertisementPosY = self.tabBar.frame.origin.y;

	self.tabBar.frame = CGRectMake(0, advertisementPosY - 49, self.tabBar.frame.size.width, self.tabBar.frame.size.height);
	
    UIView *adView = [[UIView alloc] initWithFrame:CGRectMake(0, advertisementPosY, 320, 50)];
	adView.backgroundColor = [UIColor blackColor];
	[self.view addSubview:adView];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) tabBarController:(UITabBarController *)tabBarController didSelectViewController:(UIViewController *)viewController
{
	// プロトコルを実装しているかのチェック
	if( [viewController isMemberOfClass:[UINavigationController class]] )
	{
		NSArray *controllers = [(UINavigationController*)viewController viewControllers];
		UIViewController *caller = [controllers objectAtIndex:0];
		if ([caller conformsToProtocol:@protocol(MyTabBarControllerDelegate)]) {
			// 各UIViewControllerのデリゲートメソッドを呼ぶ
			[(UIViewController<MyTabBarControllerDelegate>*)caller didSelect:self];
		}
	}
}

@end
