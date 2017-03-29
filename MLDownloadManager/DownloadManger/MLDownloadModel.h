//
//  MLDownloadModel.h
//  MobileLibrary_iOS
//
//  Created by DevinWu on 17/3/7.
//  Copyright © 2017年 蓝鸽. All rights reserved.
//

#import <Foundation/Foundation.h>
typedef NS_ENUM(NSInteger,kDownLoadState) {
    kDownLoadState_loading,      //下载中
    kDownLoadState_waitting,     //等待下载
    kDownLoadState_stop        //停止下载
};


NS_ASSUME_NONNULL_BEGIN


NS_CLASS_AVAILABLE_IOS(7_0) @interface MLNetworkingProgressModel : NSObject

/** 已下载data数据大小 */
@property (nonatomic, assign) int64_t totalBytesWritten;
/** 总文件大小 */
@property (nonatomic, assign) int64_t totalBytesExpectedToWrite;
/** 每秒下载的数据 */
@property (nonatomic, assign) int64_t downloadSpeed;
/** 下载进度 */
@property (nonatomic, assign) float downloadProgress;
/** 下载剩余时间 */
@property (nonatomic, assign) int32_t downloadLeft;

@end

NS_CLASS_AVAILABLE_IOS(7_0) @interface MLNetworkingDownloadModel : NSObject

/** 资源路径 */
@property (nonatomic, copy) NSString *resourceURLString;
/** 资源名称 */
@property (nonatomic, copy) NSString *fileName;
/** 资源类型 */
@property (nonatomic,copy)    NSString *fileType;
/** 资源文件夹 */
@property (nonatomic, copy) NSString *fileDirectory;
/** 资源文件路径 */
@property (nonatomic, copy, nullable) NSString *filePath;
/** 文件的总长度 */
@property (nonatomic,strong) NSString      *fileSize;
/** 保存资源文件信息Plist 路径 */
@property (nonatomic, copy, nullable) NSString *plistFilePath;
/** 资源下载日期 */
@property (nonatomic, strong) NSDate *downloadDate;
/** 下载资源的data数据 */
@property (nonatomic, strong, nullable) NSData *resumeData;
/** 下载任务 */
@property (nonatomic, strong, nullable) NSURLSessionDownloadTask *downloadTask;
/** 资源进度model */
@property (nonatomic, strong, nullable) MLNetworkingProgressModel *progressModel;

/*
 下载状态的逻辑是这样的：三种状态，下载中，等待下载，停止下载
 *当超过最大下载数时，继续添加的下载会进入等待状态，当同时下载数少于最大限制时会自动开始下载等待状态的任务。
 *可以主动切换下载状态
 *所有任务以添加时间排序。
 */
@property (nonatomic,assign) kDownLoadState downloadState;

/** 初始化 */
-(instancetype)initWithResourceURLString:(NSString *)URLString;

@end

NS_ASSUME_NONNULL_END
