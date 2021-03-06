//
//  NetworkDownload.m
//  tab
//
//  Created by MIYATA Wataru on 2014/03/03.
//  Copyright (c) 2014年 MIYATA Wataru. All rights reserved.
//

#import "NetworkDownload.h"
#import "AFHTTPRequestOperation.h"
#import "Common.h"

@implementation NetworkDownload

+ (void)isNeedUpdateMaster:(void(^)(enum MASTER_UPDATE_STATE))isNeedUpdate
{
	NSString *filePath			= [CACHE_FOLDER stringByAppendingPathComponent:VERSION_FILE];
	NSFileHandle *fileHandle	= [NSFileHandle fileHandleForReadingAtPath:filePath];
	if (!fileHandle)
	{
		isNeedUpdate(MASTER_UPDATE_CONSTRAINT);			//バージョンファイルが無いときは強制DL
		return;
	}
	
	//Localのバージョンを読み出し
	NSData *localVersionData	= [fileHandle readDataToEndOfFile];
	int localVersion			= CFSwapInt32LittleToHost(*(int*)([localVersionData bytes]));
	
	[NetworkDownload downloadFile:VERSION_FILE
						   saveTo:TEMP_FOLDER
							block:^(NSError *error) {
								if( error )
								{
									isNeedUpdate(MASTER_UPDATE_NETWORK_ERROR);	//通信エラー
									return;
								}
								NSString *downloadFilePath = [TEMP_FOLDER stringByAppendingPathComponent:VERSION_FILE];
								NSFileHandle *fileHandle	= [NSFileHandle fileHandleForReadingAtPath:downloadFilePath];
								if (!fileHandle)
								{
									isNeedUpdate(MASTER_UPDATE_NETWORK_ERROR);
									return;
								}
								NSData *data = [fileHandle readDataToEndOfFile];
								int version	= CFSwapInt32LittleToHost(*(int*)([data bytes]));
		
								if( localVersion < version )
								{
									isNeedUpdate(MASTER_UPDATE_NEED);			//更新あり
								}
								else
								{
									isNeedUpdate(MASTER_UPDATE_NONE);			//更新なし
								}
							}];
}

+ (void)downloadMaster:(BOOL)isConstraintDL block:(void(^)(BOOL))block
{
	if( isConstraintDL )
	{
		//強制DLの時はversion.binを所持していないのでDLしてから実行
		[NetworkDownload downloadFile:VERSION_FILE
							   saveTo:TEMP_FOLDER
								block:^(NSError *error) {
									if( error )
									{
										block(NO);	//DL失敗
										return;
									}
						 
									//マスターDL実行
									[NetworkDownload doDownloadMaster:block];
								}];
		return;
	}
	
	//マスターDL実行
	[NetworkDownload doDownloadMaster:block];
}

+ (void)doDownloadMaster:(void(^)(BOOL))block
{
	//マスターDL
	[NetworkDownload downloadFile:MASTER_FILE
						   saveTo:CACHE_FOLDER
							block:^(NSError *error) {
								if( error )
								{
									//DL失敗
									block(NO);
									return;
								}
								//version.binをtempから移動
								[NetworkDownload moveFileToCacheFromTemp:VERSION_FILE];
								//DL成功
								block(YES);
							}];
}

+ (void)downloadFile:(NSString*)fileName saveTo:(NSString*)saveTo block:(void(^)(NSError*))block
{
	//まだマスターダウンロードをしていなければ強制DL
	
    NSURL *url				= [NSURL URLWithString:[NSString stringWithFormat:@"%@%@",SERVER_URL, fileName]];
	NSString *fullPath		= [saveTo stringByAppendingPathComponent:fileName];
	
    NSURLRequest *request				= [NSURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:10.0];
    AFHTTPRequestOperation *operation	= [[AFHTTPRequestOperation alloc] initWithRequest:request];

    [operation setOutputStream:[NSOutputStream outputStreamToFileAtPath:fullPath append:NO]];
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSError *error;
		[[NSFileManager defaultManager] attributesOfItemAtPath:fullPath error:&error];
        if (error)
		{
			//DL失敗
			block(error);
			return;
        }
		//DL成功
		block(nil);
		
//		NSLog(@"RES: %@", [[[operation response] allHeaderFields] description]);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
		//DL失敗
		block(error);
		
//		NSLog(@"ERR: %@", [error description]);
    }];

    [operation start];
}

+ (void)moveFileToCacheFromTemp:(NSString *)fileName
{
	NSFileManager *fileManager = [NSFileManager defaultManager];
	
	if( [fileManager fileExistsAtPath:tempPath(fileName)] )
	{
		//バージョンファイルを最新に変更
		[fileManager removeItemAtPath:downloadPath(fileName)
								error:nil];
		
		[fileManager moveItemAtPath:tempPath(fileName)
							 toPath:downloadPath(fileName)
							  error:nil];
	}
}

//-<NHN>--------------------------------------------------------------------------------------------
// Function : downloadPath
// Explain  :
//--------------------------------------------------------------------------------------------<NHN>-
static NSString* downloadPath(NSString *fileName)
{
	NSString* basePath = [Common libraryCachesDir];
	return [basePath stringByAppendingPathComponent:fileName];
}

//-<NHN>--------------------------------------------------------------------------------------------
// Function : tempPath
// Explain  :
//--------------------------------------------------------------------------------------------<NHN>-
static NSString* tempPath(NSString *fileName)
{
	NSString* basePath = [Common tempDir];
	return [basePath stringByAppendingPathComponent:fileName];
}

@end
