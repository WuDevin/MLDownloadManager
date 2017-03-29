//
//  MLDownloadDelegate.h
//  MLDownloadManager
//
//  Created by DevinWu on 17/3/16.
//  Copyright © 2017年 蓝鸽. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MLDownloadModel.h"

@protocol MLDownloadDelegate <NSObject>

@optional

- (void)startDownload:(MLNetworkingDownloadModel *)downloadModel;
- (void)updateCellProgress:(MLNetworkingDownloadModel *)downloadModel;
- (void)finishedDownload:(MLNetworkingDownloadModel *)downloadModel error:(NSError *)error;
- (void)allowNextRequest;//处理一个窗口内连续下载多个文件且重复下载的情况

@end
