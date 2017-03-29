//
//  MLDescriptionView.h
//  MobileLibrary_iOS
//
//  Created by DevinWu on 17/1/19.
//  Copyright © 2017年 蓝鸽. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MLDescriptionView : UIView

@property (nonatomic,strong) UIImageView *iconImageView;
@property (nonatomic,strong) UILabel *descriptionLbl;

-(void)setIconImage:(UIImage *)image andDescription:(NSString *)description;

@end
