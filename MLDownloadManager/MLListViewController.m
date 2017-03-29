//
//  MLListViewController.m
//  MLDownloadManager
//
//  Created by DevinWu on 17/3/7.
//  Copyright © 2017年 蓝鸽. All rights reserved.
//

#import "MLListViewController.h"
#import "MLDownloadViewController.h"
#import "MLDownloadManager.h"
#import "MLDownloadModel.h"
#import "MLListCell.h"

@interface MLListViewController ()<UITableViewDelegate,UITableViewDataSource>


@property (strong, nonatomic  ) UITableView *tableView;
@property (nonatomic, strong) NSArray       *dataSource;
@end

@implementation MLListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    self.title = @"下载列表";
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:@"下载界面" style:UIBarButtonItemStylePlain target:self action:@selector(gotoDownloadPage)];
    self.dataSource = @[@"http://192.168.200.22:3333/Files/201703/09204728397/刺客信条[韩版]HD高清中字.mp4",
                        @"http://192.168.200.22:3333/Files/201703/09204506266/神奇动物在哪里[韩版]HD高清中字.mp4",
                        @"http://192.168.200.22:3333/Files/201703/09204942916/黑夜传说5：血战BD高清修复中英双字.mp4",
                        @"http://192.168.200.22:3333/Files/201703/09202652990/Convert/Meghan Trainor - Better When I'm Dancin'.flv",
                        @"http://192.168.200.22:3333/Files/201703/09202058838/好久不见.mp3",
                        @"http://192.168.200.22:3333/Files/201703/09205038655/wx_camera_1485217138096.mp4",
                        @"http://192.168.200.22:3333/Files/201703/09204943041/《声声慢》ppt.ppt",
                        @"http://192.168.200.22:3333/Files/201703/09202421654/Convert/Robotica_1080.flv"];
    
    [self.view addSubview:self.tableView];
}

-(void)gotoDownloadPage{
    
    MLDownloadViewController *downPage = [[MLDownloadViewController alloc] init];
    [self.navigationController pushViewController:downPage animated:YES];
    
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.dataSource.count;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 50;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    MLListCell * cell = [tableView dequeueReusableCellWithIdentifier:@"listCell"];
    
    if (!cell) {
        cell = [[MLListCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"listCell"];
    }
    
    NSString *urlStr = [self.dataSource[indexPath.row] stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLFragmentAllowedCharacterSet]];
    cell.titleLabel.text = urlStr;
    cell.downloadCallBack = ^{
        // 此处是截取的下载地址，可以自己根据服务器的视频名称来赋值
        MLNetworkingDownloadModel *model = [[MLNetworkingDownloadModel alloc] initWithResourceURLString:urlStr];
        model.fileName = [[self.dataSource[indexPath.row] componentsSeparatedByString:@"/"] lastObject];
        model.downloadDate = [self makeDate:[self dateToString:[[NSDate alloc] init]]];
        
            
        [[MLDownloadManager shareManager] ml_startDownloadWithDownloadModel:model progress:^(MLNetworkingDownloadModel *downloadModel) {
            NSLog(@"%f",downloadModel.progressModel.downloadProgress);
        } completionHandler:^(MLNetworkingDownloadModel *downloadModel, NSError *error) {
            if (error) {
                NSLog(@"%@下载失败,%@",downloadModel.fileName,error.description.localizedCapitalizedString);
            }


        }];

    
    };
    return cell;
}

-(UITableView *)tableView{
    
    if (!_tableView) {
        _tableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 40, self.view.bounds.size.width, self.view.bounds.size.height -40)];
        _tableView.backgroundColor = [UIColor whiteColor];
        _tableView.delegate = self;
        _tableView.dataSource = self;
    }
    return _tableView;
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSDate *)makeDate:(NSString *)birthday
{
    NSDateFormatter *df = [[NSDateFormatter alloc] init];
    [df setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSDate *date = [df dateFromString:birthday];
    return date;
}

- (NSString *)dateToString:(NSDate*)date
{
    NSDateFormatter *df = [[NSDateFormatter alloc] init];
    [df setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSString *datestr = [df stringFromDate:date];
    return datestr;
}


@end
