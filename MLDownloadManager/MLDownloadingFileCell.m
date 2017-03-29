//
//  MLDownloadingFileCell.m
//  MLDownloadManager
//
//  Created by DevinWu on 17/3/9.
//  Copyright © 2017年 蓝鸽. All rights reserved.
//

#import "MLDownloadingFileCell.h"
#import "MLFileHelper.h"
#define MAS_SHORTHAND
#define MAS_SHORTHAND_GLOBALS
#import <Masonry.h>

@interface MLDownloadingFileCell()

@end

@implementation MLDownloadingFileCell

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
    
    [self addSubview:self.titleLbl];
    [self addSubview:self.downloadStateBtn];
    [self addSubview:self.loadSpeedLbl];
    [self addSubview:self.loadSizeLbl];
    [self addSubview:self.progress];
     
}

#pragma mark - eventResponse                - Method -
-(void)downloadBtnAction:(UIButton *)sender{
    
    if (self.downloadBtnActionBlock) {
        self.downloadBtnActionBlock(self.model);
    }
    
}

#pragma mark - getters and setters          - Method -
- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
    
}


-(void)setModel:(MLNetworkingDownloadModel *)model{
    
    _model = model;
    
    _titleLbl.text = model.fileName;
    _loadSpeedLbl.text = [NSString stringWithFormat:@"%@/S",[MLFileHelper getFileSizeString:[NSString stringWithFormat:@"%lld",model.progressModel.downloadSpeed]]];
    _loadSizeLbl.text = [NSString stringWithFormat:@"%@ / %@",[MLFileHelper getFileSizeString:[NSString stringWithFormat:@"%lld",model.progressModel.totalBytesWritten]],[MLFileHelper getFileSizeString:[NSString stringWithFormat:@"%lld",model.progressModel.totalBytesExpectedToWrite]]];
    _progress.progress = (float)model.progressModel.downloadProgress;
  
    
    if (!model.downloadTask) {
         [self.downloadStateBtn setImage:[UIImage imageNamed:@"下载"] forState:UIControlStateNormal];
    }else{
        if (model.downloadTask.state == NSURLSessionTaskStateRunning ) {
            
            if (model.progressModel.downloadSpeed == 0) {
                 [self.downloadStateBtn setImage:[UIImage imageNamed:@"等待下载"] forState:UIControlStateNormal];
            }else{
                [self.downloadStateBtn setImage:[UIImage imageNamed:@"暂停"] forState:UIControlStateNormal]; 
            }
           
        }else{
            [self.downloadStateBtn setImage:[UIImage imageNamed:@"下载"] forState:UIControlStateNormal];
        }

    }
    
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


-(UILabel *)titleLbl{
    
    if (!_titleLbl) {
        _titleLbl = [[UILabel alloc]init];
        _titleLbl.textColor = [UIColor darkGrayColor];
        _titleLbl.font = [UIFont systemFontOfSize:15];
        _titleLbl.numberOfLines = 1;
        _titleLbl.text = @"标题";
    }
    return _titleLbl;
}

-(UILabel *)loadSpeedLbl{
    
    if (!_loadSpeedLbl) {
        _loadSpeedLbl = [[UILabel alloc]init];
        _loadSpeedLbl.textColor = [UIColor colorWithRed:43/255.0f green:162/255.0f blue:204/255.0f alpha:1];
        _loadSpeedLbl.font = [UIFont systemFontOfSize:13];
        _loadSpeedLbl.numberOfLines = 1;
        _loadSpeedLbl.text = @"0 k/s";
    }
    return _loadSpeedLbl;
}

-(UILabel *)loadSizeLbl{
    
    if (!_loadSizeLbl) {
        _loadSizeLbl = [[UILabel alloc]init];
        _loadSizeLbl.textColor = [UIColor darkGrayColor];
        _loadSizeLbl.font = [UIFont systemFontOfSize:13];
        _loadSizeLbl.numberOfLines = 1;
        _loadSizeLbl.textAlignment = NSTextAlignmentRight;
        _loadSizeLbl.text = @"0 m/ 0m";
    }
    return _loadSizeLbl;
}

-(UIProgressView *)progress{
    
    if (!_progress) {
        _progress = [[UIProgressView alloc]init];
        _progress.trackTintColor = [UIColor groupTableViewBackgroundColor];
        _progress.progressTintColor = [UIColor colorWithRed:43/255.0f green:162/255.0f blue:204/255.0f alpha:1];
        _progress.progress = 0;
    }
    return _progress;

}

-(UIButton *)downloadStateBtn{
    
    if (!_downloadStateBtn) {
        _downloadStateBtn = [[UIButton alloc] init];
        [_downloadStateBtn setImage:[UIImage imageNamed:@"下载"] forState:UIControlStateNormal];
        [_downloadStateBtn setImage:[UIImage imageNamed:@"暂停"] forState:UIControlStateSelected];
//        _downloadStateBtn.backgroundColor = [UIColor colorWithRed:43/255.0f green:162/255.0f blue:204/255.0f alpha:1];
        [_downloadStateBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_downloadStateBtn addTarget:self action:@selector(downloadBtnAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _downloadStateBtn;
}





#pragma mark - Layout                       - Method -
-(void)layoutSubviews{
    
    if (self.editing) {
        [self.titleLbl updateConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self).offset(60);
            make.right.equalTo(self).offset(-5);
            make.top.equalTo(self).offset(5);
        }];

    }else{
        [self.titleLbl updateConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self).offset(12);
            make.right.equalTo(self).offset(-5);
            make.top.equalTo(self).offset(5);
        }];

    }
    
    [self.downloadStateBtn updateConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self);
        make.right.equalTo(self).offset(-10);
        make.size.equalTo(CGSizeMake(40, 40));
    }];
    
    [self.loadSizeLbl updateConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.centerX);
        make.right.equalTo(self.downloadStateBtn.left).offset(-10);
        make.centerY.equalTo(self);
    }];
    
    [self.loadSpeedLbl updateConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.titleLbl.left);
        make.centerY.equalTo(self);
        make.right.equalTo(self.centerX);
    }];

    
    [self.progress updateConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.titleLbl.left);
        make.bottom.equalTo(self).offset(-8);
        make.right.equalTo(self).offset(-10);
        make.height.equalTo(3);
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
