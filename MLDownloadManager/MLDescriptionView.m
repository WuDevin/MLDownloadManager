//
//  MLDescriptionView.m
//  MobileLibrary_iOS
//
//  Created by DevinWu on 17/1/19.
//  Copyright © 2017年 蓝鸽. All rights reserved.
//

#import "MLDescriptionView.h"

#define MAS_SHORTHAND
#define MAS_SHORTHAND_GLOBALS
#import <Masonry.h>

@implementation MLDescriptionView

#pragma mark - Init                         - Method -
-(instancetype)init{
    
    if (self = [super init]) {
        [self setupSubView];
    }
    return self;
}

#pragma mark - setupSubView                 - Method -
-(void)setupSubView{
    
    [self addSubview:self.iconImageView];
    [self addSubview:self.descriptionLbl];
}

#pragma mark - getters and setters          - Method -
-(UIImageView *)iconImageView{
    
    if (!_iconImageView) {
        _iconImageView = [[UIImageView alloc]init];
         _iconImageView.clipsToBounds = YES;
        [_iconImageView setContentMode:UIViewContentModeScaleAspectFill];
    }
    return _iconImageView;
}

-(UILabel *)descriptionLbl{
    
    if (!_descriptionLbl) {
        _descriptionLbl = [[UILabel alloc]init];
        _descriptionLbl.font = [UIFont systemFontOfSize:11];
        _descriptionLbl.textColor = [UIColor grayColor];
    }
    return _descriptionLbl;
}

#pragma mark - Layout                       - Method -
-(void)layoutSubviews{
    
    [super layoutSubviews];
    [self.iconImageView updateConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self);
        make.left.equalTo(self);
        make.size.equalTo(self.iconImageView.image.size);
    }];
    
    [self.descriptionLbl updateConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.iconImageView.right).offset(8);
        make.right.equalTo(self.right).offset(-8);
        make.centerY.equalTo(self);
    }];
    
}

#pragma mark - publicMethods               - Method -
-(void)setIconImage:(UIImage *)image andDescription:(NSString *)description{
    
    self.iconImageView.image = image;
    self.descriptionLbl.text = description;
    
}


@end
