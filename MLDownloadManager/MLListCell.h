//
//  MLListCell.h
//  MLDownloadManager
//
//  Created by DevinWu on 17/3/7.
//  Copyright © 2017年 蓝鸽. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Masonry.h>

@interface MLListCell : UITableViewCell

@property (strong, nonatomic)  UILabel *titleLabel;
@property (strong, nonatomic)  UIButton *downloadBtn;
@property (nonatomic, copy) void(^downloadCallBack)();

@end
