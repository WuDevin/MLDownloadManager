//
//  MLDownloadingFileCell.h
//  MLDownloadManager
//
//  Created by DevinWu on 17/3/9.
//  Copyright © 2017年 蓝鸽. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MLDownloadModel.h"

typedef void(^DownloadBtnActionBlock)(MLNetworkingDownloadModel *downloadModel);

@interface MLDownloadingFileCell : UITableViewCell

@property (nonatomic,strong) UILabel *titleLbl;
@property (nonatomic,strong) UILabel *loadSpeedLbl;
@property (nonatomic,strong) UILabel *loadSizeLbl;
@property (nonatomic,strong) UIProgressView *progress;
@property (nonatomic,strong) UIButton *downloadStateBtn;

@property (nonatomic,strong) MLNetworkingDownloadModel *model;
@property (nonatomic,copy) DownloadBtnActionBlock downloadBtnActionBlock;

@end
