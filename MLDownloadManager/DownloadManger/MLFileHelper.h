//
//  MLFileHelper.h
//  MLDownloadManager
//
//  Created by DevinWu on 17/3/9.
//  Copyright © 2017年 蓝鸽. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MLFileHelper : NSObject

/** 将文件大小转化成M单位或者B单位 */
+ (NSString *)getFileSizeString:(NSString *)size;
/** 经文件大小转化成不带单位的数字 */
+ (float)getFileSizeNumber:(NSString *)size;
/** 字符串格式化成日期 */
+ (NSDate *)makeDate:(NSString *)birthday;
/** 日期格式化成字符串 */
+ (NSString *)dateToString:(NSDate*)date;

@end
