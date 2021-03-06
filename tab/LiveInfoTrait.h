//
//  LiveInfoTrait.h
//  iOS7Sampler
//
//  Created by MIYATA Wataru on 2014/01/31.
//  Copyright (c) 2014年 Shuichi Tsutsumi. All rights reserved.
//

#import <Foundation/Foundation.h>

@class LoadData;

@interface LiveInfoTrait : NSObject
@property int		liveHouseNo;	//会場ID
@property NSDate    *liveDate;		//日程
@property int		subNo;			//サブNo
@property NSString  *eventTitle;		//タイトル
@property NSString  *act;			//出演者
@property NSString  *otherInfo;		//その他の情報
@property NSString  *uniqueID;		//ユニークID
@property NSString  *dayOfWeek;     //曜日
@property int		sortNo;

+(void)loadMast:(LoadData *)data;

+(NSArray *)traitList;
+(NSArray *)traitListWithDate:(NSDate *)date;
+(NSArray *)traitListWithLiveHouseNo:(int)liveHouseNo;
+(id)traitOfUniqueID:(NSString *)uniqueID;
+(NSDate *)minLiveDate;
+(NSDate *)maxLiveDate;

//debug method
//+(void)addTestLiveInfo;

- (BOOL)isFavorite;
- (BOOL)isPastLive;
@end
