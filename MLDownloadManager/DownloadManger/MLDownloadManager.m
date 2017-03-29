//
//  MLDownloadManager.m
//  MobileLibrary_iOS
//
//  Created by DevinWu on 17/3/7.
//  Copyright © 2017年 蓝鸽. All rights reserved.
//

#import "MLDownloadManager.h"

NSString *const MLNetworkingManagerFileName = @"mobileLibrary.networking.manager_1.0";

#define DownloadDirectory [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES).firstObject stringByAppendingPathComponent:MLNetworkingManagerFileName]

#define UnFinishDownloadPlistFilePath  [DownloadDirectory stringByAppendingPathComponent:@"unFinishPlistFilePath.plist"]

#define FinishedDownloadPlistFilePath  [DownloadDirectory stringByAppendingPathComponent:@"finishedPlistFilePath.plist"]

#define DownloadfilesDirectory  [DownloadDirectory stringByAppendingPathComponent:@"DownloadFiles"]
#define PlistFileDirectory  [DownloadDirectory stringByAppendingPathComponent:@"PlistFiles"]

#define DownloadfilePath(name)  [DownloadfilesDirectory stringByAppendingPathComponent:name]

NSInteger const ml_timeInterval = 5;

@interface MLDownloadManager()

@property (nonatomic,assign)  NSInteger  maxDownloadCount;
@property (nonatomic,assign)  BOOL  resumeTaskFIFO;
@property (nonatomic,assign)  BOOL  batchDownload;

@end

@implementation MLDownloadManager


#pragma mark - download methods

-(void)ml_startDownloadWithDownloadModel:(MLNetworkingDownloadModel *)downloadModel
                                progress:(void (^)(MLNetworkingDownloadModel *_Nonnull))progress
                       completionHandler:(void (^)(MLNetworkingDownloadModel *_Nonnull, NSError *_Nullable))completionHandler{
    
    NSString *fileName = [downloadModel.fileName componentsSeparatedByString:@"."].firstObject;
    downloadModel.fileDirectory = DownloadfilesDirectory;
    downloadModel.filePath = [DownloadfilesDirectory stringByAppendingPathComponent:downloadModel.fileName];
    
    downloadModel.plistFilePath = [PlistFileDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.plist", fileName]];
   

    downloadModel.resumeData = [NSData dataWithContentsOfFile:downloadModel.plistFilePath];
    
    if (![self canBeStartDownloadTaskWithDownloadModel:downloadModel]) return;
    
  
    if (downloadModel.resumeData.length == 0) {
        NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:downloadModel.resourceURLString]];
        downloadModel.downloadTask = [self.AFManager downloadTaskWithRequest:request progress:^(NSProgress * _Nonnull downloadProgress) {
            
            [self setValuesForDownloadModel:downloadModel withProgress:downloadProgress.fractionCompleted];
            progress(downloadModel);
            if (self.downloadDelegate && [self.downloadDelegate respondsToSelector:@selector(updateCellProgress:)]) {
                [self.downloadDelegate updateCellProgress:downloadModel];
            }
            
        } destination:^NSURL * _Nonnull(NSURL * _Nonnull targetPath, NSURLResponse * _Nonnull response) {
            
            return [NSURL fileURLWithPath:downloadModel.filePath];
            
        } completionHandler:^(NSURLResponse * _Nonnull response, NSURL * _Nullable filePath, NSError * _Nullable error) {
            if (error) {
                [self ml_cancelDownloadTaskWithDownloadModel:downloadModel completed:^{}];
                completionHandler(downloadModel, error);
                if (self.downloadDelegate && [self.downloadDelegate respondsToSelector:@selector(finishedDownload:error:)]) {
                    [self.downloadDelegate finishedDownload:downloadModel error:error];
                }
 
            }else{
                [self.downloadModelsDict removeObjectForKey:downloadModel.resourceURLString];
                [self saveFinishedDownloadFileInfoWithDownloadModel:downloadModel];
                completionHandler(downloadModel, nil);
                [self deletePlistFileWithDownloadModel:downloadModel];
                [self.downloadingModels removeObject:downloadModel];
              
                if (self.downloadDelegate && [self.downloadDelegate respondsToSelector:@selector(finishedDownload:error:)]) {
                    [self.downloadDelegate finishedDownload:downloadModel error:nil];
                }

               
            }
        }];
        
    }else{
        
        downloadModel.progressModel.totalBytesWritten = [self getResumeByteWithDownloadModel:downloadModel];
        downloadModel.downloadTask = [self.AFManager downloadTaskWithResumeData:downloadModel.resumeData progress:^(NSProgress * _Nonnull downloadProgress) {
            
            [self setValuesForDownloadModel:downloadModel withProgress:[self.AFManager downloadProgressForTask:downloadModel.downloadTask].fractionCompleted];
            progress(downloadModel);
            if (self.downloadDelegate && [self.downloadDelegate respondsToSelector:@selector(updateCellProgress:)]) {
                [self.downloadDelegate updateCellProgress:downloadModel];
            }

            
        } destination:^NSURL * _Nonnull(NSURL * _Nonnull targetPath, NSURLResponse * _Nonnull response) {
            return [NSURL fileURLWithPath:downloadModel.filePath];
        } completionHandler:^(NSURLResponse * _Nonnull response, NSURL * _Nullable filePath, NSError * _Nullable error) {
            if (error) {
                [self ml_cancelDownloadTaskWithDownloadModel:downloadModel completed:^{}];
                completionHandler(downloadModel, error);
                if (self.downloadDelegate && [self.downloadDelegate respondsToSelector:@selector(finishedDownload:error:)]) {
                    [self.downloadDelegate finishedDownload:downloadModel error:error];
                }

            }else{
                [self.downloadModelsDict removeObjectForKey:downloadModel.resourceURLString];
                [self saveFinishedDownloadFileInfoWithDownloadModel:downloadModel];
                completionHandler(downloadModel, nil);
                [self.downloadingModels removeObject:downloadModel];
                if (self.downloadDelegate && [self.downloadDelegate respondsToSelector:@selector(finishedDownload:error:)]) {
                    [self.downloadDelegate finishedDownload:downloadModel error:nil];
                }

            }
        }];
       
    }
    
    if (![self.fileManager fileExistsAtPath:self.downloadDirectory]) {
        [self.fileManager createDirectoryAtPath:self.downloadDirectory withIntermediateDirectories:YES attributes:nil error:nil];
    }
    [self createFolderAtPath:DownloadfilesDirectory];
    [self createFolderAtPath:PlistFileDirectory];
    [self removeUnfinishDownloadFileInfoWithDownloadModel:downloadModel];
    [self ml_resumeDownloadWithDownloadModel:downloadModel];
}

-(void)ml_resumeDownloadWithDownloadModel:(MLNetworkingDownloadModel *)downloadModel{
    if (downloadModel.downloadTask) {
        downloadModel.downloadDate = [NSDate date];
        [downloadModel.downloadTask resume];
        self.downloadModelsDict[downloadModel.resourceURLString] = downloadModel;
        [self.downloadingModels addObject:downloadModel];
        [self deletePlistFileWithDownloadModel:downloadModel];
    }
}

-(void)ml_cancelDownloadTaskWithDownloadModel:(MLNetworkingDownloadModel *)downloadModel completed:(void(^)(void))completedBlock{
    if (!downloadModel) return;
    NSURLSessionTaskState state = downloadModel.downloadTask.state;
    if (state == NSURLSessionTaskStateRunning) {
        [downloadModel.downloadTask cancelByProducingResumeData:^(NSData * _Nullable resumeData) {
            downloadModel.resumeData = resumeData;
            @synchronized (self) {
                [downloadModel.resumeData writeToFile:downloadModel.plistFilePath atomically:YES];
 
                [self saveUnfinishDownloadFileInfoWithDownloadModel:downloadModel];               
                downloadModel.resumeData = nil;
                [self.downloadModelsDict removeObjectForKey:downloadModel.resourceURLString];
                [self.downloadingModels removeObject:downloadModel];
                completedBlock();
            }
            
        }];
    }
}


-(void)ml_deleteDownloadedFileWithDownloadModel:(MLNetworkingDownloadModel *)downloadModel{
    /** 移除文件 */
    if ([self.fileManager fileExistsAtPath:downloadModel.fileDirectory]) {
        [self.fileManager removeItemAtPath:downloadModel.filePath error:nil];
    }
    /** 移除文件信息 */
    [self removeFinishDownloadFileWithModel:downloadModel];
}

-(void)ml_deleteUnfinishedFileWithDownloadModel:(MLNetworkingDownloadModel *)downloadModel{
    
    /** 移除文件 */
    if ([self.fileManager fileExistsAtPath:downloadModel.plistFilePath]) {
        [self.fileManager removeItemAtPath:downloadModel.plistFilePath error:nil];
    }
    /** 移除文件信息 */
    [self removeUnfinishDownloadFileInfoWithDownloadModel:downloadModel];
    
}

-(void)ml_deleteAllDownloadedFiles{
    if ([self.fileManager fileExistsAtPath:self.downloadDirectory]) {
        [self.fileManager removeItemAtPath:self.downloadDirectory error:nil];
    }
    [self removeAllFinishDownloadFiles];
}

-(BOOL)ml_hasDownloadedFileWithDownloadModel:(MLNetworkingDownloadModel *)downloadModel{
    if ([self.fileManager fileExistsAtPath:downloadModel.filePath]) {
        NSLog(@"已下载的文件...%@",downloadModel.filePath);
        return YES;
    }
     NSLog(@"已下载的文件...%@",downloadModel.filePath);
    return NO;
}

-(MLNetworkingDownloadModel *)ml_getDownloadingModelWithURLString:(NSString *)URLString{
    return self.downloadModelsDict[URLString];
}

-(MLNetworkingProgressModel *)ml_getDownloadProgressModelWithDownloadModel:(MLNetworkingDownloadModel *)downloadModel{
    MLNetworkingProgressModel *progressModel = downloadModel.progressModel;
    progressModel.downloadProgress = [self.AFManager downloadProgressForTask:downloadModel.downloadTask].fractionCompleted;
    return progressModel;
}

#pragma mark - private methods
-(BOOL)canBeStartDownloadTaskWithDownloadModel:(MLNetworkingDownloadModel *)downloadModel{
    if (!downloadModel) return NO;
    if (downloadModel.downloadTask && downloadModel.downloadTask.state == NSURLSessionTaskStateRunning) return NO;
    if ([self ml_hasDownloadedFileWithDownloadModel:downloadModel]) return NO;
    
    for (MLNetworkingDownloadModel *model in self.downloadingModels) {
        if ([model.resourceURLString isEqualToString:downloadModel.resourceURLString]) {
            return NO;
        }
    }
    
    
    return YES;
}

-(void)setValuesForDownloadModel:(MLNetworkingDownloadModel *)downloadModel withProgress:(double)progress{
    NSTimeInterval interval = -1 * [downloadModel.downloadDate timeIntervalSinceNow];
    downloadModel.progressModel.totalBytesWritten = downloadModel.downloadTask.countOfBytesReceived;
    downloadModel.progressModel.totalBytesExpectedToWrite = downloadModel.downloadTask.countOfBytesExpectedToReceive;
    downloadModel.progressModel.downloadProgress = progress;
    downloadModel.progressModel.downloadSpeed = (int64_t)((downloadModel.progressModel.totalBytesWritten - [self getResumeByteWithDownloadModel:downloadModel]) / interval);
    if (downloadModel.progressModel.downloadSpeed != 0) {
        int64_t remainingContentLength = downloadModel.progressModel.totalBytesExpectedToWrite  - downloadModel.progressModel.totalBytesWritten;
        int currentLeftTime = (int)(remainingContentLength / downloadModel.progressModel.downloadSpeed);
        downloadModel.progressModel.downloadLeft = currentLeftTime;
    }
}

-(int64_t)getResumeByteWithDownloadModel:(MLNetworkingDownloadModel *)downloadModel{
    int64_t resumeBytes = 0;
    NSDictionary *dict = [NSDictionary dictionaryWithContentsOfFile:downloadModel.plistFilePath];
    if (dict) {
        resumeBytes = [dict[@"NSURLSessionResumeBytesReceived"] longLongValue];
    }
    return resumeBytes;
}

-(NSString *)getTmpFileNameWithDownloadModel:(MLNetworkingDownloadModel *)downloadModel{
    NSString *fileName = nil;
    NSDictionary *dict = [NSDictionary dictionaryWithContentsOfFile:downloadModel.plistFilePath];
    if (dict) {
        fileName = dict[@"NSURLSessionResumeInfoTempFileName"];
    }
    return fileName;
}

-(void)createFolderAtPath:(NSString *)path{
    if ([self.fileManager fileExistsAtPath:path]) return;
    [self.fileManager createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:nil];
}

-(void)deletePlistFileWithDownloadModel:(MLNetworkingDownloadModel *)downloadModel{
  
    [self.fileManager removeItemAtPath:downloadModel.plistFilePath error:nil];
    [self removeUnfinishDownloadFileInfoWhenDownloadFinishedWithDownloadModel:downloadModel];

}

-(NSString *)unFinishDownloadPlistFilePath{
    return UnFinishDownloadPlistFilePath;
}

-(NSString *)finishedDownloadPlistFilePath{
    return FinishedDownloadPlistFilePath;
}


-(nullable NSMutableDictionary <NSString *, NSDictionary *> *)unFinishDownloadPlisDict{
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithContentsOfFile:[self unFinishDownloadPlistFilePath]];
    return dict;
}

-(nullable NSMutableDictionary <NSString *, NSDictionary *> *)finishDownloadPlisDict{
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithContentsOfFile:[self finishedDownloadPlistFilePath]];
    return dict;
}


-(void)saveUnfinishDownloadFileInfoWithDownloadModel:(MLNetworkingDownloadModel *)downloadModel{
    
     NSMutableDictionary <NSString *, NSDictionary *> *dict = [self unFinishDownloadPlisDict];
     NSDictionary *infoDict = @{
                               @"fileName":downloadModel.fileName ? downloadModel.fileName : @"",
                               @"fileReceivedSize":[NSString stringWithFormat:@"%lld", downloadModel.downloadTask.countOfBytesReceived],
                               @"fileSize":[NSString stringWithFormat:@"%lld", downloadModel.downloadTask.countOfBytesExpectedToReceive],
                               @"fileUrl":downloadModel.resourceURLString,
                               @"downloadDate":downloadModel.downloadDate,
                               @"fileDirectory":downloadModel.fileDirectory,
                               @"filePath":downloadModel.filePath,
                               @"plistFilePath":downloadModel.plistFilePath                        
                               };
     [dict setValue:infoDict forKey:downloadModel.resourceURLString];
     [dict writeToFile:[self unFinishDownloadPlistFilePath] atomically:YES];

}

-(void)removeUnfinishDownloadFileInfoWithDownloadModel:(MLNetworkingDownloadModel *)downloadModel{
    
    NSMutableDictionary <NSString *, NSDictionary *> *dict = [self unFinishDownloadPlisDict];
    [dict removeObjectForKey:downloadModel.resourceURLString];
    [dict writeToFile:[self unFinishDownloadPlistFilePath] atomically:YES];
}

-(void)saveFinishedDownloadFileInfoWithDownloadModel:(MLNetworkingDownloadModel *)downloadModel{
    
    NSMutableDictionary <NSString *, NSDictionary *> *dict = [self finishDownloadPlisDict];
    NSDictionary *infoDict = @{
                               @"fileName":downloadModel.fileName ? downloadModel.fileName : @"",
                               @"fileReceivedSize":[NSString stringWithFormat:@"%lld", downloadModel.downloadTask.countOfBytesReceived],
                               @"fileSize":[NSString stringWithFormat:@"%lld", downloadModel.downloadTask.countOfBytesExpectedToReceive],
                               @"fileUrl":downloadModel.resourceURLString,
                               @"downloadDate":downloadModel.downloadDate,
                               @"fileDirectory":downloadModel.fileDirectory,
                               @"filePath":downloadModel.filePath
                               
                               };
    [dict setValue:infoDict forKey:downloadModel.resourceURLString];
    [dict writeToFile:[self finishedDownloadPlistFilePath] atomically:YES];
    
}


-(void)removeUnfinishDownloadFileInfoWhenDownloadFinishedWithDownloadModel:(MLNetworkingDownloadModel *)downloadModel{
    NSMutableDictionary <NSString *, NSDictionary *> *dict = [self unFinishDownloadPlisDict];
    [dict removeObjectForKey:downloadModel.resourceURLString];
    [dict writeToFile:[self unFinishDownloadPlistFilePath] atomically:YES];
}

-(void)removeFinishDownloadFileWithModel:(MLNetworkingDownloadModel *)downloadModel{
    
    NSMutableDictionary <NSString *, NSDictionary *> *dict = [self finishDownloadPlisDict];
    [dict removeObjectForKey:downloadModel.resourceURLString];
    [dict writeToFile:[self finishedDownloadPlistFilePath] atomically:YES];
 
}

-(void)removeAllFinishDownloadFiles{
    
    NSDictionary <NSString *, NSDictionary *> *dict = [[NSDictionary alloc] init];
    [dict writeToFile:[self finishedDownloadPlistFilePath] atomically:YES];
    
}


#pragma mark - share instance
+(MLDownloadManager *)shareManager{
    static MLDownloadManager *manager = nil;
    static dispatch_once_t sigletonOnceToken;
    dispatch_once(&sigletonOnceToken, ^{
        manager = [[self alloc] init];
    });
    return manager;
}

- (instancetype)init{
    self = [super init];
    if (self) {
        
        _AFManager = [[AFHTTPSessionManager alloc]init];
        _AFManager.requestSerializer.timeoutInterval = 5;
        [_AFManager.operationQueue setMaxConcurrentOperationCount:2];
        _AFManager.requestSerializer.cachePolicy = NSURLRequestReloadIgnoringLocalCacheData;//NSURLRequestUseProtocolCachePolicy;
        NSSet *typeSet = [NSSet setWithObjects:@"application/json", @"text/plain", @"text/javascript", @"text/json", @"text/html", nil];
        _AFManager.responseSerializer.acceptableContentTypes = typeSet;
        _AFManager.securityPolicy.allowInvalidCertificates = YES;
        
        _maxDownloadCount = 2;
        _resumeTaskFIFO = YES;
        _batchDownload = NO;
        _fileManager = [NSFileManager defaultManager];
        _waitingModels = [[NSMutableArray alloc] initWithCapacity:1];
        _downloadingModels = [[NSMutableArray alloc] initWithCapacity:1];
        _downloadModelsDict = [[NSMutableDictionary alloc] initWithCapacity:1];
        
        _downloadDirectory = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES).firstObject stringByAppendingPathComponent:MLNetworkingManagerFileName];
        [_fileManager createDirectoryAtPath:_downloadDirectory withIntermediateDirectories:YES attributes:nil error:nil];
        [_fileManager createDirectoryAtPath:DownloadfilesDirectory withIntermediateDirectories:YES attributes:nil error:nil];
        
        if ([self unFinishDownloadPlisDict] == nil) {
            NSDictionary <NSString *, NSDictionary *> *plistDict = [[NSDictionary alloc] init];
            [plistDict writeToFile:UnFinishDownloadPlistFilePath atomically:YES];
        }
        
        if ([self finishDownloadPlisDict] == nil) {
            NSDictionary <NSString *, NSDictionary *> *plistDict1 = [[NSDictionary alloc] init];
            [plistDict1 writeToFile:FinishedDownloadPlistFilePath atomically:YES];

        }
}
    return self;
}

@end
