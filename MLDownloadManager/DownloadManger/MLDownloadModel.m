//
//  MLDownloadModel.m
//  MobileLibrary_iOS
//
//  Created by DevinWu on 17/3/7.
//  Copyright © 2017年 蓝鸽. All rights reserved.
//

#import "MLDownloadModel.h"

@implementation MLNetworkingDownloadModel

-(instancetype)initWithResourceURLString:(NSString *)URLString{
    
    if (self = [super init]) {
        self.resourceURLString = URLString;
        self.progressModel =[[MLNetworkingProgressModel alloc] init];
    }
    
    return self;
}

-(instancetype)init{
   
    if (self = [super init]) {
        self.progressModel =[[MLNetworkingProgressModel alloc] init];
    }
    
    return self;

}

@end


@implementation MLNetworkingProgressModel


@end
