//
//  VoiceRecorderBaseVC.h
//  RecordDemo
//
//  Created by xuqianlong on 15/2/5.
//  Copyright (c) 2015年 夕阳栗子. All rights reserved.
//

#import <UIKit/UIKit.h>

#define QL_Nonatomic_Strong     @property (nonatomic, strong)
#define QL_Nonatomic_Assign     @property (nonatomic, assign)
#define QL_Nonatomic_Copy       @property (nonatomic, copy)
#define QL_Nonatomic_Weak       @property (nonatomic, weak)

@interface VoiceRecorderBaseVC : UIViewController

@property (copy, nonatomic)     NSString                *convertAmrFilePath;        //转换后的amr文件路径

QL_Nonatomic_Strong UIView *recordView;

/**
 生成当前时间字符串
 @returns 当前时间字符串
 */
+ (NSString*)getCurrentTimeString;

/**
 获取缓存路径
 @returns 缓存路径
 */
+ (NSString*)getCacheDirectory;

/**
 判断文件是否存在
 @param _path 文件路径
 @returns 存在返回yes
 */
+ (BOOL)fileExistsAtPath:(NSString*)_path;

/**
 删除文件
 @param _path 文件路径
 @returns 成功返回yes
 */
+ (BOOL)deleteFileAtPath:(NSString*)_path;


#pragma mark -

/**
 生成文件路径
 @param _fileName 文件名
 @param _type 文件类型
 @returns 文件路径
 */
+ (NSString*)getPathByFileName:(NSString *)_fileName;
+ (NSString*)getPathByFileName:(NSString *)_fileName ofType:(NSString *)_type;

//******************************//******************************//******************************//
/**
 *  @Author xuqianlong, 14-10-26 20:10:53
 *
 *  开始录音
 */
- (void)beginRecordAction;
/**
 *  @Author xuqianlong, 14-10-26 20:10:36
 *
 *  结束录音
 */
- (void)endRecordAction;

- (void)playRecordAction:(void(^)(bool isOver))OverBlock;
- (void)stopPlayRecordAction;
- (void)changePlayRoteAction;
- (void)deleteThisRecordAction;

@end
