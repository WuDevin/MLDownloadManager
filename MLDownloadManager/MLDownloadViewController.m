//
//  MLDownloadViewController.m
//  MLDownloadManager
//
//  Created by DevinWu on 17/3/8.
//  Copyright © 2017年 蓝鸽. All rights reserved.
//

#import "MLDownloadViewController.h"
#import "MLDownloadFilePageCell.h"
#import "MLDownloadingFileCell.h"
#import "MLDownloadManager.h"

#define MAS_SHORTHAND
#define MAS_SHORTHAND_GLOBALS
#import <Masonry.h>

@interface MLDownloadViewController ()<UITableViewDelegate,UITableViewDataSource,MLDownloadDelegate>

@property (nonatomic,strong) UISegmentedControl *segment;
@property (nonatomic,strong) UIBarButtonItem *rightBtnItem;
@property (nonatomic,strong) UITableView *tableView;
@property (nonatomic,strong) UITableView *downloadingTableView;
@property (nonatomic,strong) UIView *operatorView;//操作按钮
@property (nonatomic,strong) UIButton *allPauseBtn;

@property (nonatomic,strong) NSArray *finishArray;
@property (nonatomic,strong) NSMutableArray *downloadingArray;

@property (nonatomic,assign) NSInteger curSelectIndex;


@end

@implementation MLDownloadViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupMainView];
    
    NSLog(@"finishDownloadPlisDict-----%@",[[MLDownloadManager shareManager] finishDownloadPlisDict]);
    
    NSLog(@"UnfinishDownloadPlisDict-----%@",[[MLDownloadManager shareManager] unFinishDownloadPlisDict]);
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - setupSubView                 - Method -
-(void)setupMainView{
    
    [MLDownloadManager shareManager].downloadDelegate = self;
    self.view.backgroundColor = [UIColor groupTableViewBackgroundColor];
     _curSelectIndex = 0;
    [self.view addSubview:self.segment];
    [self.view addSubview:self.tableView];
    [self.view addSubview:self.operatorView];
    [self.view addSubview:self.allPauseBtn];
    self.navigationItem.rightBarButtonItem = self.rightBtnItem;
    self.allPauseBtn.hidden = YES;
    
    [self layoutSubviews];
}

#pragma mark - eventResponse                - Method -
-(void)segmentValueChangeAction:(UISegmentedControl *)segemnt{
    
    if ([self.rightBtnItem.title isEqualToString:@"取消"]) {
        self.rightBtnItem.title = @"编辑";
        self.tableView.allowsMultipleSelection = NO; //允许多选
        [self.tableView setEditing:NO animated:YES];

    }
    
    _curSelectIndex = _segment.selectedSegmentIndex;
    [self.tableView reloadData];
    if (segemnt.selectedSegmentIndex == 0) {
        
        self.allPauseBtn.hidden = YES;
        
    }else if(segemnt.selectedSegmentIndex == 1){
       
        if (!(self.downloadingArray.count == 0)) {
             self.allPauseBtn.hidden = NO;
        }else{
           self.allPauseBtn.hidden = YES;
        }
       
        
    }
    
     [self layoutSubviews];
}

-(void)allPauseBtnAction:(UIButton *)sender{
    
    sender.selected = !sender.selected;
    
    
    if (sender.selected) {
        
        for (MLNetworkingDownloadModel *model in [MLDownloadManager shareManager].downloadingModels) {
            
            [[MLDownloadManager shareManager] ml_cancelDownloadTaskWithDownloadModel:model completed:^{}];
        }

    }else{
        for (MLNetworkingDownloadModel *downloadModel in self.downloadingArray) {
           
            [[MLDownloadManager shareManager] ml_startDownloadWithDownloadModel:downloadModel progress:^(MLNetworkingDownloadModel *downloadModel) {
              
            } completionHandler:^(MLNetworkingDownloadModel *downloadModel, NSError *error) {
                
            }];

        }
    }
  
}

#pragma mark - getters and setters          - Method -


#pragma mark - eventResponse                - Method -
-(void)rightBtnItemAction:(UIBarButtonItem *)item{
    
    if (![item.title isEqualToString:@"取消"]) {
        item.title = @"取消";
        self.tableView.allowsMultipleSelection = YES; //允许多选
        [self.tableView setEditing:YES animated:YES];
         self.allPauseBtn.hidden = YES;
    }else{
        item.title = @"编辑";
        self.tableView.allowsMultipleSelection = NO; //允许多选
        [self.tableView setEditing:NO animated:YES];
        if (_curSelectIndex == 0) {
            self.allPauseBtn.hidden = YES;
        }else{
           self.allPauseBtn.hidden = NO;
        }
        
    }
    [self layoutSubviews];
}

-(void)selectAllBtnAction:(UIButton *)sender{
    for (int i = 0; i < self.finishArray.count; i++) {
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:i inSection:0];
        [self.tableView selectRowAtIndexPath:indexPath animated:NO scrollPosition:UITableViewScrollPositionBottom];
    }
    
}

-(void)deleteBtnAction:(UIButton *)sender{
    
   
    if (_curSelectIndex == 0) {
        
        NSMutableArray *deleteArray = [NSMutableArray array];
         NSMutableArray *currentArray = [NSMutableArray arrayWithArray:self.finishArray];
        for (NSIndexPath *indexPath in self.tableView.indexPathsForSelectedRows) {
            [deleteArray addObject:currentArray[indexPath.row]];
            [[MLDownloadManager shareManager] ml_deleteDownloadedFileWithDownloadModel:currentArray[indexPath.row]];
        }
        
        
       [self.tableView deleteRowsAtIndexPaths:self.tableView.indexPathsForSelectedRows withRowAnimation:UITableViewRowAnimationLeft];//删除对应数据的cell
//
        
      
    }else{
        
        
        NSMutableArray *deleteArray = [NSMutableArray array];
        NSMutableArray *oldDownloadingArray = [NSMutableArray arrayWithArray:self.downloadingArray];
        for (NSIndexPath *indexPath in self.tableView.indexPathsForSelectedRows) {
            MLNetworkingDownloadModel *deleteModel = oldDownloadingArray[indexPath.row];
            
            [deleteArray addObject:oldDownloadingArray[indexPath.row]];
           
            if (deleteModel.downloadTask.state == NSURLSessionTaskStateRunning) {
                [deleteModel.downloadTask cancelByProducingResumeData:^(NSData * _Nullable resumeData) {
                    
                }];
            }
          
            if ([[MLDownloadManager shareManager].downloadingModels containsObject:deleteModel]) {
                [[MLDownloadManager shareManager].downloadingModels removeObject:deleteModel];
            }
            
            [[MLDownloadManager shareManager] ml_deleteUnfinishedFileWithDownloadModel:oldDownloadingArray[indexPath.row]];

          
        }
       
        [oldDownloadingArray removeObjectsInArray:deleteArray];
        self.downloadingArray = oldDownloadingArray;

         [self.tableView deleteRowsAtIndexPaths:self.tableView.indexPathsForSelectedRows withRowAnimation:UITableViewRowAnimationLeft];//删除对应数据的cell
    }
    
    [self setEditing:NO animated:YES];
    dispatch_time_t delayTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC));
    dispatch_after(delayTime, dispatch_get_main_queue(), ^{
        
        [self.tableView reloadData];
        
    });
    
    
    
}

#pragma mark - TableView DataSource delegate
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    if (_curSelectIndex == 0) {
        return self.finishArray.count;
    }else{
        NSLog(@"%@",self.downloadingArray);
        return self.downloadingArray.count;
        
    }
   
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
   
    
    if (_curSelectIndex == 0) {
        static NSString *identify = @"cellID";
        MLDownloadFilePageCell   *cell = [tableView dequeueReusableCellWithIdentifier:identify];
        
        if (!cell) {
            cell = [[MLDownloadFilePageCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identify];
        }
        cell.model = self.finishArray[indexPath.row];
        return cell;

    }else{
        
        static NSString *identify = @"downloadCellID";
        MLDownloadingFileCell   *cell = [tableView dequeueReusableCellWithIdentifier:identify];
        
        if (!cell) {
            cell = [[MLDownloadingFileCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identify];
            cell.downloadBtnActionBlock = ^(MLNetworkingDownloadModel *downloadModel){
                
                if (downloadModel.downloadTask) {
                    if (downloadModel.downloadTask.state == NSURLSessionTaskStateRunning) {
                        [[MLDownloadManager shareManager] ml_cancelDownloadTaskWithDownloadModel:downloadModel completed:^{}];
                    }else{
                        [[MLDownloadManager shareManager] ml_startDownloadWithDownloadModel:downloadModel progress:^(MLNetworkingDownloadModel *downloadModel) {
                            NSLog(@"正在下载界面=====%f",downloadModel.progressModel.downloadProgress);
                        } completionHandler:^(MLNetworkingDownloadModel *downloadModel, NSError *error) {
                            
                            
                            
                        }];
 
                    }
                }else{
                   
                    [[MLDownloadManager shareManager] ml_startDownloadWithDownloadModel:downloadModel progress:^(MLNetworkingDownloadModel *downloadModel) {
                        NSLog(@"正在下载界面=====%f",downloadModel.progressModel.downloadProgress);
                    } completionHandler:^(MLNetworkingDownloadModel *downloadModel, NSError *error) {
                       
                    
                    }];

                }
              
            };
        }
        cell.model = self.downloadingArray[indexPath.row];
        return cell;
        
    }
    
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    return 80;
}


-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
}


-(BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath{
    return  YES;
}


#pragma mark - getters and setters          - Method -

-(UITableView *)tableView{
    
    if (!_tableView) {
        
        _tableView = [[UITableView alloc]init];
        _tableView.backgroundColor = [UIColor groupTableViewBackgroundColor];
        _tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
        _tableView.separatorColor = [UIColor groupTableViewBackgroundColor];
        _tableView.allowsMultipleSelection = NO;
        _tableView.allowsSelection = YES; //允许选择某cell
        _tableView.allowsSelectionDuringEditing = YES; //编辑模式下允许可以
        _tableView.allowsMultipleSelectionDuringEditing = YES; //编辑模式下是否可以多选,选中后前面出现对勾
        _tableView.delegate = self;
        _tableView.dataSource = self;
    }
    return _tableView;
}


-(UIBarButtonItem *)rightBtnItem{
    
    if (!_rightBtnItem) {
        _rightBtnItem = [[UIBarButtonItem alloc] initWithTitle:@"编辑" style:UIBarButtonItemStyleDone target:self action:@selector(rightBtnItemAction:)];
        
    }
    return _rightBtnItem;
}

-(UIView *)operatorView{
    
    if (!_operatorView) {
        
        _operatorView = [[UIView alloc]init];
        _operatorView.backgroundColor = [UIColor whiteColor];
        UIButton *deleteBtn = [[UIButton alloc] initWithFrame:CGRectMake(self.view.frame.size.width/2, 0, self.view.frame.size.width/2, 50)];
        [deleteBtn setTitle:@"删除" forState:UIControlStateNormal];
        deleteBtn.backgroundColor = [UIColor colorWithRed:43/255.0f green:162/255.0f blue:204/255.0f alpha:1];
        [deleteBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [deleteBtn addTarget:self action:@selector(deleteBtnAction:) forControlEvents:UIControlEventTouchUpInside];
        [_operatorView addSubview:deleteBtn];
        
        UIButton *selectAllBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width/2, 50)];
        [selectAllBtn setTitle:@"全选" forState:UIControlStateNormal];
        selectAllBtn.backgroundColor = [UIColor whiteColor];
        [selectAllBtn setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
        [selectAllBtn addTarget:self action:@selector(selectAllBtnAction:) forControlEvents:UIControlEventTouchUpInside];
        [_operatorView addSubview:selectAllBtn];
        
    }
    return _operatorView;
}


-(UIButton *)allPauseBtn{
    
    
    if (!_allPauseBtn) {
        _allPauseBtn = [[UIButton alloc] init];
        [_allPauseBtn setTitle:@"全部暂停" forState:UIControlStateNormal];
        [_allPauseBtn setTitle:@"全部开始" forState:UIControlStateSelected];
        _allPauseBtn.backgroundColor = [UIColor colorWithRed:43/255.0f green:162/255.0f blue:204/255.0f alpha:1];;
        [_allPauseBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_allPauseBtn addTarget:self action:@selector(allPauseBtnAction:) forControlEvents:UIControlEventTouchUpInside];
    }
   
    return _allPauseBtn;
}



-(UISegmentedControl *)segment{
    
    if (!_segment) {
        _segment = [[UISegmentedControl alloc]initWithItems:@[@"已下载",@"正在下载"]];
        _segment.selectedSegmentIndex = 0;
        [_segment addTarget:self action:@selector(segmentValueChangeAction:) forControlEvents:UIControlEventValueChanged];
    }
    return _segment;
}
-(NSArray *)finishArray{
    
    _finishArray = [[NSArray alloc]init];
    
    NSMutableArray *tempArray = [NSMutableArray array];
    if ([[MLDownloadManager shareManager] finishDownloadPlisDict].allValues != 0) {
        for (NSDictionary *dic in [[MLDownloadManager shareManager] finishDownloadPlisDict].allValues) {
            MLNetworkingDownloadModel *file = [[MLNetworkingDownloadModel alloc] init];
            file.fileName = [dic objectForKey:@"fileName"];
            file.fileType = [file.fileName pathExtension];
            file.fileSize = [dic objectForKey:@"fileSize"];
            file.downloadDate = [dic objectForKey:@"downloadDate"];
            file.progressModel.totalBytesExpectedToWrite = [[dic objectForKey:@"fileReceivedSize"] longLongValue];
            file.resourceURLString = [dic objectForKey:@"fileUrl"];
            file.filePath = [dic objectForKey:@"filePath"];
            file.fileDirectory = [dic objectForKey:@"fileDirectory"];
            [tempArray addObject:file];
        }
        
    }
    
    _finishArray = [tempArray sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        
        MLNetworkingDownloadModel *pModel1 = obj1;
        MLNetworkingDownloadModel *pModel2 = obj2;
        
        return [pModel2.downloadDate compare: pModel1.downloadDate];
        
    }];
    return _finishArray;
}

-(NSMutableArray *)downloadingArray{
    
    _downloadingArray = [[NSMutableArray alloc]init];
    
    if ([MLDownloadManager shareManager].downloadingModels.count != 0) {
        for (MLNetworkingDownloadModel *model in [MLDownloadManager shareManager].downloadingModels) {
            [_downloadingArray addObject:model];
            
        }
    }
    
    NSLog(@"downloadingModels--------%@",[MLDownloadManager shareManager].downloadingModels);
    
    if ([[MLDownloadManager shareManager] unFinishDownloadPlisDict].allValues != 0) {
        for (NSDictionary *dic in [[MLDownloadManager shareManager] unFinishDownloadPlisDict].allValues) {
            
            MLNetworkingDownloadModel *file = [[MLNetworkingDownloadModel alloc] init];
            file.fileName = [dic objectForKey:@"fileName"];
            file.progressModel.totalBytesExpectedToWrite = [[dic objectForKey:@"fileSize"] longLongValue];
            file.downloadDate = [dic objectForKey:@"downloadDate"];
            file.progressModel.totalBytesWritten = [[dic objectForKey:@"fileReceivedSize"] longLongValue];
            file.resourceURLString = [dic objectForKey:@"fileUrl"];
            file.progressModel.downloadProgress = (float)[[dic objectForKey:@"fileReceivedSize"] longLongValue] / [[dic objectForKey:@"fileSize"] longLongValue] ;
            file.filePath = [dic objectForKey:@"filePath"];
            file.fileDirectory = [dic objectForKey:@"fileDirectory"];
            file.plistFilePath = [dic objectForKey:@"plistFilePath"];
            [_downloadingArray addObject:file];
            
        }
        
    }

    
    return _downloadingArray;
}




#pragma mark - Layout                       - Method -

-(void)layoutSubviews{
    
    [self.segment updateConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view);
        make.top.equalTo(self.view).offset(74);
        make.size.equalTo(CGSizeMake(180, 30));
    }];

    
    if (_curSelectIndex == 0) {
      
        if (self.tableView.editing) {
            [self.tableView remakeConstraints:^(MASConstraintMaker *make) {
                make.left.right.equalTo(self.view);
                make.top.equalTo(self.segment.bottom).offset(10);
                make.bottom.equalTo(self.view).offset(-50);
            }];
            
        }else{
            
            [self.tableView updateConstraints:^(MASConstraintMaker *make) {
                make.top.equalTo(self.segment.bottom).offset(10);
                make.bottom.left.right.equalTo(self.view);
            }];
            
        }

    }else{
       
        [self.tableView remakeConstraints:^(MASConstraintMaker *make) {
            make.left.right.equalTo(self.view);
            make.top.equalTo(self.segment.bottom).offset(10);
            make.bottom.equalTo(self.view).offset(-50);
        }];
 
    }
    
    [self.operatorView updateConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self.tableView);
        make.top.equalTo(self.tableView.bottom);
        make.height.equalTo(50);
    }];
    
    [self.allPauseBtn updateConstraints:^(MASConstraintMaker *make) {
        
        make.left.bottom.right.equalTo(self.view);
        make.height.equalTo(50);
    }];

}

#pragma mark - customDelegate               - Method -

-(void)updateCellProgress:(MLNetworkingDownloadModel *)downloadModel{
    
     [self performSelectorOnMainThread:@selector(updateCellOnMainThread:) withObject:downloadModel waitUntilDone:YES];
   
}


-(void)finishedDownload:(MLNetworkingDownloadModel *)downloadModel error:(NSError *)error{
    
    NSArray *cellArr = [self.tableView visibleCells];
    
    for (id obj in cellArr) {
        if([obj isKindOfClass:[MLDownloadingFileCell class]]) {
            MLDownloadingFileCell *cell = (MLDownloadingFileCell *)obj;
            
            if ([cell.model.resourceURLString isEqualToString:downloadModel.resourceURLString]) {
               
                if (error) {
                    
                    if ([error.description isEqualToString:@"cancelled"] || error.code == -999) {
                        NSLog(@"%@下载暂停,请继续下载----%@",downloadModel.fileName,error);
                    }else{
                        NSLog(@"%@下载出现错误,请重新下载----%@",downloadModel.fileName,error);
                    }
                }else{
                    NSLog(@"%@下载完成",downloadModel.fileName);
                }
                
            }
            
        }
    }

    [self.tableView reloadData];
    
}

// 更新下载进度
- (void)updateCellOnMainThread:(MLNetworkingDownloadModel *)downloadModel
{
    NSArray *cellArr = [self.tableView visibleCells];
    
    for (id obj in cellArr) {
        if([obj isKindOfClass:[MLDownloadingFileCell class]]) {
            MLDownloadingFileCell *cell = (MLDownloadingFileCell *)obj;
          
            if ([cell.model.resourceURLString isEqualToString:downloadModel.resourceURLString]) {
                cell.model = downloadModel;
            }

        }
    }
}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
