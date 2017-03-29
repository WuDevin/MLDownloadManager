//
//  MLDownloadFilePageCell.h
//  MobileLibrary_iOS
//
//  Created by DevinWu on 17/2/6.
//  Copyright © 2017年 蓝鸽. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MLDescriptionView.h"
#import "MLDownloadModel.h"

@interface MLDownloadFilePageCell : UITableViewCell

@property (nonatomic,strong) UIImageView *iconImageView;
@property (nonatomic,strong) UILabel *titleLbl;
@property (nonatomic,strong) MLDescriptionView *downLoadTimeView;
@property (nonatomic,strong) MLDescriptionView *fileSizeView;
@property (nonatomic,strong) UIImageView *coverView;

@property (nonatomic,strong) MLNetworkingDownloadModel *model;

@end
