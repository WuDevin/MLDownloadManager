//
//  MLDownloadManager.h
//  MobileLibrary_iOS
//
//  Created by DevinWu on 17/3/7.
//  Copyright © 2017年 蓝鸽. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AFNetworking/AFNetworking.h>
#import "MLDownloadModel.h"
#import "MLDownloadDelegate.h"


@interface MLDownloadManager : NSObject


/** 获得下载事件的vc，用在比如多选图片后批量下载的情况，这时需配合 allowNextRequest 协议方法使用 */
@property (nonatomic, weak  ) id<MLDownloadDelegate> VCdelegate;
/** 下载列表delegate */
@property (nonatomic, weak  ) id<MLDownloadDelegate> downloadDelegate;
/** AFManager */
@property (nonatomic, strong) AFHTTPSessionManager *AFManager;
/** downloadDirectory */
@property (nonatomic, copy) NSString *downloadDirectory;
/** fileManager */
@property (nonatomic, strong) NSFileManager *fileManager;

/*
 * the models for waiting for download, the elements should be FKDownloadModel and it's subClasses
 */
@property (nonatomic, strong) NSMutableArray <__kindof MLNetworkingDownloadModel *> *waitingModels;

/*
 * the models whose being downloaded, the elements should be FKDownloadModel and it's subClasses
 */
@property (nonatomic, strong) NSMutableArray <__kindof MLNetworkingDownloadModel *> *downloadingModels;

/*
 *  key-values dictionary of the downloadModels, format as '<NSString *key, FKDownloadModel *model>' to make constraints
 *  used to find a downloadModel from this container,
 *  when the program will terminate, container will be clear
 */
@property (nonatomic, strong) NSMutableDictionary <NSString *, __kindof MLNetworkingDownloadModel *> *downloadModelsDict;

@property (nonatomic,strong)  NSMutableDictionary <NSString *, NSDictionary *> *unFinishDownloadPlisDict;

@property (nonatomic,strong)  NSMutableDictionary <NSString *, NSDictionary *> *finishDownloadPlisDict;

-(void)ml_startDownloadWithDownloadModel:(MLNetworkingDownloadModel *)downloadModel
                                progress:(void (^)(MLNetworkingDownloadModel *downloadModel))progress
                       completionHandler:(void (^)(MLNetworkingDownloadModel *downloadModel, NSError *error))completionHandler;

-(void)ml_resumeDownloadWithDownloadModel:(MLNetworkingDownloadModel *)downloadModel;
-(void)ml_cancelDownloadTaskWithDownloadModel:(MLNetworkingDownloadModel *)downloadModel completed:(void(^)(void))completedBlock;
-(void)ml_deleteDownloadedFileWithDownloadModel:(MLNetworkingDownloadModel *)downloadModel;
-(void)ml_deleteUnfinishedFileWithDownloadModel:(MLNetworkingDownloadModel *)downloadModel;
-(void)ml_deleteAllDownloadedFiles;
-(BOOL)ml_hasDownloadedFileWithDownloadModel:(MLNetworkingDownloadModel *)downloadModel;
-(MLNetworkingDownloadModel *)ml_getDownloadingModelWithURLString:(NSString *)URLString;
-(MLNetworkingProgressModel *)ml_getDownloadProgressModelWithDownloadModel:(MLNetworkingDownloadModel *)downloadModel;
+(MLDownloadManager *)shareManager;

@end
