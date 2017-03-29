//
//  MLDownloadFilePageCell.m
//  MobileLibrary_iOS
//
//  Created by DevinWu on 17/2/6.
//  Copyright © 2017年 蓝鸽. All rights reserved.
//

#import "MLDownloadFilePageCell.h"
#import "MLFileHelper.h"

#define MAS_SHORTHAND
#define MAS_SHORTHAND_GLOBALS
#import <Masonry.h>

@interface MLDownloadFilePageCell()

@end

@implementation MLDownloadFilePageCell

#pragma mark - Init                         - Method -
-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.selectionStyle = UITableViewCellSelectionStyleDefault;
        self.selectedBackgroundView = [[UIView alloc] initWithFrame:self.contentView.frame];
        self.selectedBackgroundView.backgroundColor = [UIColor groupTableViewBackgroundColor];
        self.tintColor = [UIColor colorWithRed:43/255.0f green:162/255.0f blue:204/255.0f alpha:1];
        [self setupSubView];
    }
    
    return self;
}

#pragma mark - setupSubView                 - Method -
-(void)setupSubView{
    
    [self addSubview:self.iconImageView];
    [self addSubview:self.titleLbl];
    [self addSubview:self.downLoadTimeView];
    [self addSubview:self.fileSizeView];
    [self addSubview:self.coverView];
    
}

#pragma mark - getters and setters          - Method -

-(void)setModel:(MLNetworkingDownloadModel *)model{
    
    _model = model;
    
    _iconImageView.image = [UIImage imageNamed:@"英语"];
     _titleLbl.text = model.fileName;
    [_downLoadTimeView setIconImage:[UIImage imageNamed:@"touixang"] andDescription:[MLFileHelper dateToString:model.downloadDate]];
    [_fileSizeView setIconImage:[UIImage imageNamed:@"USB"] andDescription:[MLFileHelper getFileSizeString:[NSString stringWithFormat:@"%lld",model.progressModel.totalBytesExpectedToWrite]]];
    
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
    
}

//-(void)setFrame:(CGRect)frame{
//   
//    frame.size.height -= 10;
//    frame.origin.x += 10;
//    frame.origin.y += 10;
//    frame.size.width -= 20;
//    
//    [super setFrame:frame];
//}

-(UIImageView *)iconImageView{
    
    if (!_iconImageView) {
        _iconImageView = [[UIImageView alloc]init];
        _iconImageView.image = [UIImage imageNamed:@"英语"];
    }
    return _iconImageView;
}

-(UILabel *)titleLbl{
    
    if (!_titleLbl) {
        _titleLbl = [[UILabel alloc]init];
        _titleLbl.textColor = [UIColor darkGrayColor];
        _titleLbl.font = [UIFont systemFontOfSize:15];
        _titleLbl.numberOfLines = 2;
        _titleLbl.text = @"标题";
    }
    return _titleLbl;
}

-(MLDescriptionView *)downLoadTimeView{
    
    if (!_downLoadTimeView) {
        _downLoadTimeView = [[MLDescriptionView alloc]init];
        [_downLoadTimeView setIconImage:[UIImage imageNamed:@"touixang"] andDescription:@"描述"];
    }
    return _downLoadTimeView;
}

-(MLDescriptionView *)fileSizeView{
    
    if (!_fileSizeView) {
        _fileSizeView = [[MLDescriptionView alloc]init];
        [_fileSizeView setIconImage:[UIImage imageNamed:@"USB"] andDescription:@"描述"];
    }
    return _fileSizeView;
}

-(UIImageView *)coverView{
    
    if (!_coverView) {
        _coverView = [[UIImageView alloc]init];
        _coverView.backgroundColor = [UIColor whiteColor];
    }
    return _coverView;
}




#pragma mark - Layout                       - Method -
-(void)layoutSubviews{
   
    if (self.editing) {
        
        [self.iconImageView updateConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self);
            make.left.equalTo(self).offset(55);
            make.size.equalTo(CGSizeMake(41, 48));
        }];
        
        
    }else{
        [self.iconImageView updateConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self);
            make.left.equalTo(self).offset(12);
            make.size.equalTo(CGSizeMake(41, 48));
        }];
        
    }
    
    [self.coverView updateConstraints:^(MASConstraintMaker *make) {
        make.left.top.bottom.equalTo(self);
        make.right.equalTo(self.iconImageView.left).offset(-12);
    }];

    
    [self.titleLbl updateConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.iconImageView.right).offset(12);
        make.right.equalTo(self).offset(-5);
    }];
    
    [self.downLoadTimeView updateConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.iconImageView.bottom).offset(5);
        make.left.equalTo(self.titleLbl);
        make.width.equalTo(self.titleLbl.width).dividedBy(2);
    }];
    
    [self.fileSizeView updateConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.iconImageView.bottom).offset(5);
        make.left.equalTo(self.downLoadTimeView.right);
        make.width.equalTo(self.titleLbl.width).dividedBy(2);
    }];
   
    [super layoutSubviews];

}

#pragma mark - other
- (void)willTransitionToState:(UITableViewCellStateMask)state {
    if(state == UITableViewCellStateShowingEditControlMask){
        self.selectedBackgroundView.backgroundColor = [UIColor whiteColor];
    } else {
        self.selectedBackgroundView.backgroundColor = [UIColor whiteColor];
    }
    [super willTransitionToState:state];
}

@end
