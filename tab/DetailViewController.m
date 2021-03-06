//
//  DetailViewController.m
//  tab
//
//  Created by MIYATA Wataru on 2014/02/12.
//  Copyright (c) 2014年 MIYATA Wataru. All rights reserved.
//

#import <CoreGraphics/CoreGraphics.h>
#import <QuartzCore/QuartzCore.h>
#import "DetailViewController.h"
#import "Common.h"
#import "LiveInfoTrait.h"
#import "LiveHouseTrait.h"
#import "SettingData.h"
#import "BaseViewController.h"
#import <Social/Social.h>
#import "TlsAlertView.h"
#import "TlsIndicatorView.h"

@interface DetailViewController ()

@end

@implementation DetailViewController

- (id)initWithLiveInfoTrait:(const LiveInfoTrait*)trait baseController:(BaseViewController *)baseController
{
    if( (self = [super init]) )
    {
        _liveTrait = trait;
		_baseController = baseController;
		[self setTitle:[NSString stringWithDateFormat:@"yyyy/MM/dd(E)" date:_liveTrait.liveDate]];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
	
	_scrollView.delegate = self;
	_childView.backgroundColor = WHITE_COLOR;
    
    float labelHeight = _place.frame.origin.y + 5;

    //会場名
	{
        _place.textColor        = RED_COLOR;
		_place.backgroundColor	= WHITE_COLOR;
        const LiveHouseTrait *liveHouseTrait = [LiveHouseTrait traitOfLiveHouseNo:_liveTrait.liveHouseNo];
        if(liveHouseTrait)
        {
            _place.attributedText       = [NSAttributedString tlsAttributedStringWithString:liveHouseTrait.name lineSpace:2.0f];
            [_place sizeToFit];
        }
        labelHeight += _place.frame.size.height + 5;
	}
    
    //イベント名
	{
        CGRect rect = _eventTitle.frame;
        _eventTitle.frame = CGRectMake(rect.origin.x, labelHeight, rect.size.width, rect.size.height);
        
		_eventTitle.textColor           = BLUE_COLOR;
		_eventTitle.backgroundColor     = WHITE_COLOR;
        _eventTitle.attributedText      = [NSAttributedString tlsAttributedStringWithString:_liveTrait.eventTitle lineSpace:2.0f];
        [_eventTitle sizeToFit];
        
        labelHeight += _eventTitle.frame.size.height + 10;
	}
    
    //出演者名
	{
        // URL文字列を事前に取得
        id dataDetector = [NSDataDetector dataDetectorWithTypes:NSTextCheckingTypeLink error:nil];
        NSArray *resultArray = [dataDetector matchesInString:_liveTrait.act
                                                     options:0
                                                       range:NSMakeRange(0,[_liveTrait.act length])];
        NSMutableArray* urlDetectorList = [NSMutableArray array];
        for (NSTextCheckingResult *result in resultArray)
        {
            if ([result resultType] == NSTextCheckingTypeLink)
            {
                NSURL *url = [result URL];
                NSString* urlString = [url description];
                NSLog(@"url:%@",urlString);
                [urlDetectorList addObject:[urlString stringByReplacingOccurrencesOfString:@"/" withString:@"\n"]];
            }
        }

        // スラッシュを改行コードに置き換え
        NSString *actText = [_liveTrait.act stringByReplacingOccurrencesOfString:@"/" withString:@"\n"];
        actText = [actText stringByReplacingOccurrencesOfString:@"／" withString:@"/"];
        actText = [actText stringByReplacingOccurrencesOfString:@"\n " withString:@"\n"];
        
        // URLのスラッシュも改行コードになっているので元に戻す
        for(NSString* str in urlDetectorList)
        {
            NSString* urlStr = [str stringByReplacingOccurrencesOfString:@"\n" withString:@"/"];
            actText = [actText stringByReplacingOccurrencesOfString:str withString:urlStr];
        }
        
        CGRect rect = _act.frame;
        _act.frame = CGRectMake(rect.origin.x, labelHeight, rect.size.width, rect.size.height);
        
		_act.textColor           = BLACK_COLOR;
		_act.backgroundColor     = WHITE_COLOR;
        _act.attributedText      = [NSAttributedString tlsAttributedStringWithString:actText lineSpace:4.0f];
        [_act sizeToFit];
        
        labelHeight += _act.frame.size.height + 20;
	}
    
    //時刻
	{
        NSString *otherText = [_liveTrait.otherInfo stringByReplacingOccurrencesOfString:@"／" withString:@"/"];
        CGRect rect = _other.frame;
        _other.frame = CGRectMake(rect.origin.x, labelHeight, rect.size.width, rect.size.height);
        
		_other.textColor           = BLACK_COLOR;
		_other.backgroundColor     = WHITE_COLOR;
        _other.attributedText      = [NSAttributedString tlsAttributedStringWithString:otherText
                                                                                 lineSpace:2.0f];
        [_other sizeToFit];
        
        labelHeight += _other.frame.size.height + 10;
	}
    
    //ライブハウス情報
	{
        const LiveHouseTrait *liveHouseTrait = [LiveHouseTrait traitOfLiveHouseNo:_liveTrait.liveHouseNo];
        if(liveHouseTrait)
        {
            NSString *liveHouseInfo = liveHouseTrait ? liveHouseTrait.info : @"";
            
            liveHouseInfo = [liveHouseInfo stringByAppendingString:@"\n\n※各ライブハウスのHPで最新の情報をご確認下さい。"];
            
            CGRect rect = _liveHouseInfo.frame;
            _liveHouseInfo.frame = CGRectMake(rect.origin.x, labelHeight, rect.size.width, rect.size.height);
            
            _liveHouseInfo.textColor        = BLACK_COLOR;
            _liveHouseInfo.backgroundColor	= WHITE_COLOR;
            _liveHouseInfo.attributedText   = [NSAttributedString tlsAttributedStringWithString:liveHouseInfo lineSpace:2.0f];
            [_liveHouseInfo sizeToFit];
        }
        labelHeight += _liveHouseInfo.frame.size.height + 70;
	}
	
	//画面サイズからヘッダー、フッダーの高さを引いたサイズ
	int appFrameHeight = [UIScreen mainScreen].applicationFrame.size.height - 44 - 48;
	if( labelHeight < appFrameHeight )
	{
		labelHeight = appFrameHeight;
	}
    
    
	[_scrollView setContentSize:CGSizeMake(_childView.bounds.size.width, labelHeight)];
	
	//スター画像
	{
		_favBaseView		= [[UIView alloc] initWithFrame:CGRectMake(260, 0, 60, 60)];
		[_scrollView addSubview:_favBaseView];
		
		UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onTapFavorite:)];
		_favBaseView.userInteractionEnabled = YES;
		[_favBaseView addGestureRecognizer:tapGesture];
		
		_favImageView		= [[UIImageView alloc] initWithFrame:CGRectMake(20, 15, 24, 24)];
		_favImageView.image = [self favoriteUIImage:[[SettingData instance] isContainsFavoriteUniqueId:_liveTrait.uniqueID]];
		
		[_favBaseView addSubview:_favImageView];
	}
	
	//ナビゲーションバー
	{
		UIBarButtonItem *btn = [[UIBarButtonItem alloc]
								initWithBarButtonSystemItem:UIBarButtonSystemItemCamera
								target:self
								action:@selector(screenShot:)];
		self.navigationItem.rightBarButtonItem = btn;
	}
	
	if( ![SettingData instance].isShowDetailDialog )
	{
		//初めて詳細画面に遷移した時に、「お気に入り」「キャプチャ」の説明をする
		[TlsAlertView dialogWithTitle:@""
							  message:@"・右上の☆マークをタップするとライブ情報を「お気に入り」に登録することができます。\n\n"
										"・「カメラマーク」をタップするとライブ情報を画像としてカメラロールに保存できます。作成した画像を添付してtwitterに投稿する事もできます。"
						   buttonType:ALERT_BUTTON_OK
								block:^(NSInteger index) {
									[[SettingData instance] setShowDetailDialog:YES];
								}];
	}
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)screenShot:(UIBarButtonItem*)barButtonItem
{
    [[TlsIndicatorView instance] startAnimating];
    [self performSelector:@selector(doScreenShot) withObject:nil afterDelay:1.50];
}

- (void)doScreenShot
{
    // キャプチャ対象をWindowに設定
	UIWindow *window = [[UIApplication sharedApplication] keyWindow];
	
	// キャプチャ画像を描画する対象を生成
	UIGraphicsBeginImageContextWithOptions(window.bounds.size, NO, 0.0f);
	CGContextRef context = UIGraphicsGetCurrentContext();
	
    [[TlsIndicatorView instance] stopAnimating];
	// Windowの現在の表示内容を１つずつ描画
    CALayer *sublayer = [CALayer layer];
    CALayer *sublayerTop = [CALayer layer];
	for (UIWindow *aWindow in [[UIApplication sharedApplication] windows]) {
        CALayer *layer = aWindow.layer;
        //広告の上に描画
        sublayer.backgroundColor    = WHITE_COLOR.CGColor;
        sublayer.frame      = CGRectMake(0, layer.frame.size.height - 50, 320, 50);
        [layer addSublayer:sublayer];
        
        if( SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0"))
        {
            sublayerTop.backgroundColor = WHITE_COLOR.CGColor;
            sublayerTop.frame   = CGRectMake(0, 0, 320, 64);
            [layer addSublayer:sublayerTop];
            
            CATextLayer *label = [[CATextLayer alloc] init];
            label.contentsScale = [[UIScreen mainScreen] scale];
            [label setFont:@"HiraKakuProN-W6"];
            [label setFontSize:14];
            [label setFrame:sublayerTop.frame];
            [label setPosition:CGPointMake(250, 70)];
            [label setForegroundColor:BLACK_COLOR.CGColor];
            [label setString:self.navigationItem.title];
            [sublayerTop addSublayer:label];
        }
		[layer renderInContext:context];
	}
	
	// 描画した内容をUIImageとして受け取り
	UIImage *capturedImage = UIGraphicsGetImageFromCurrentImageContext();
	
	// 描画を終了
	UIGraphicsEndImageContext();
    
    [sublayer removeFromSuperlayer];
    [sublayerTop removeFromSuperlayer];
	
	//画像保存完了時のセレクタ指定
	SEL selector = @selector(onCompleteCapture:didFinishSavingWithError:contextInfo:);
	//画像を保存する
	UIImageWriteToSavedPhotosAlbum(capturedImage, self, selector, NULL);
}

//画像保存完了時のセレクタ
- (void)onCompleteCapture:(UIImage *)screenImage
 didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo
{
	if (error)
	{
		[TlsAlertView dialogWithTitle:nil
							  message:@"画像の保存に失敗しました"
						   buttonType:ALERT_BUTTON_OK
								block:^(NSInteger index) {}];
	}
	else
	{
		[TlsAlertView dialogWithTitle:nil
							  message:@"画像を保存しました。\n画像を添付してtwitterに投稿することが出来ます。\n投稿画面を表示しますか？"
						   buttonType:ALERT_BUTTON_YESNO
								block:^(NSInteger index) {
									if( index == 1)
									{
										//twitter投稿
										SLComposeViewController *composeCtl = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeTwitter];
										composeCtl.view.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.5];
                                        [composeCtl setInitialText:@"アプリDL：http://t.co/ZJO9HedW8w"];
										[composeCtl addImage:screenImage];
										
										[composeCtl setCompletionHandler:^(SLComposeViewControllerResult result) {
											if (result == SLComposeViewControllerResultDone) {
												//投稿成功時の処理
												NSLog(@"投稿完了");
											}
											else if( result == SLComposeViewControllerResultCancelled )
											{
												[self dismissViewControllerAnimated:YES completion: nil];
											}
										}];
										[self presentViewController:composeCtl animated:YES completion:nil];
										
									}
								}];
	}
}
										  
- (void)onTapFavorite:(UITapGestureRecognizer *)tapGesture
{
	if( [_liveTrait isFavorite] )
	{
		[[SettingData instance] removeFavoriteUniqueId:_liveTrait.uniqueID];
		_favImageView.image = [self favoriteUIImage:NO];
	}
	else
	{
		[[SettingData instance] addFavoriteUniqueId:_liveTrait.uniqueID];
		_favImageView.image = [self favoriteUIImage:YES];
	}
	
	//呼び出し元のテーブル表示をリロード
	[_baseController reloadTable];
}

- (UIImage *)favoriteUIImage:(BOOL)isFavorite
{
	return [UIImage imageNamed:@"star_64_f5f5f5.png"
					 withColor:isFavorite ? FAV_COLOR : FAV_DISABLE_COLOR
				 drawAsOverlay:NO];
}

@end
