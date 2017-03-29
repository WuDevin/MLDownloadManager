//
//  MLListCell.m
//  MLDownloadManager
//
//  Created by DevinWu on 17/3/7.
//  Copyright © 2017年 蓝鸽. All rights reserved.
//

#import "MLListCell.h"



@implementation MLListCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}


#pragma mark - Init                         - Method -

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        [self setupSubView];
    }
    return self;
}

#pragma mark - setupSubView                 - Method -
-(void)setupSubView{
    
    [self addSubview:self.titleLabel];
    [self addSubview:self.downloadBtn];
    
}

#pragma mark - eventResponse                - Method -

-(void)downloadBtnAction:(UIButton *)sender{
    
    if (self.downloadCallBack) {
        self.downloadCallBack();
    }
    
}


#pragma mark - getters and setters          - Method -

-(UILabel *)titleLabel{
    
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc]init];
        _titleLabel.font = [UIFont systemFontOfSize:15];
        _titleLabel.numberOfLines = 2;
        _titleLabel.textColor = [UIColor darkGrayColor];
    }
    return _titleLabel;
}

-(UIButton *)downloadBtn{
    
    if (!_downloadBtn) {
        _downloadBtn = [[UIButton alloc]init];
        _downloadBtn.backgroundColor = [UIColor redColor];
        [_downloadBtn setTitle:@"下载" forState:UIControlStateNormal];
        [_downloadBtn addTarget:self action:@selector(downloadBtnAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _downloadBtn;
}


-(void)layoutSubviews{
    
    [super layoutSubviews];
    
    
    [self.titleLabel mas_updateConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self).offset(10);
        make.centerY.equalTo(self);
        make.right.equalTo(self.downloadBtn.mas_left);
        make.height.mas_equalTo(@40);
        
    }];
    
    [self.downloadBtn mas_updateConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self);
        make.right.equalTo(self).offset(-10);
        make.size.mas_equalTo(CGSizeMake(50, 30));
    }];
    
}







@end
