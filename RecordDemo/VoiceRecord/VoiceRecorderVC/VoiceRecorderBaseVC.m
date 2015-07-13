//
//  VoiceRecorderBaseVC.m
//  RecordDemo
//
//  Created by xuqianlong on 15/2/5.
//  Copyright (c) 2015年 夕阳栗子. All rights reserved.
//

#import "VoiceRecorderBaseVC.h"
#import "AudioToolbox/AudioToolbox.h"
#import <AVFoundation/AVFoundation.h>
#import <CoreAudio/CoreAudioTypes.h>
#import "VoiceConverter.h"

#define kFileTypeAMR @"amr"
#define kFileTypeWAV @"wav"

#define kStopLuYin @"正在录音【点击停止】"
@interface VoiceRecorderBaseVC ()<AVAudioPlayerDelegate>

QL_Nonatomic_Strong AVAudioRecorder     *recorder;
QL_Nonatomic_Strong AVAudioPlayer       *player;
QL_Nonatomic_Copy   NSString            *recordFilePath;    //录音文件路径
QL_Nonatomic_Copy   NSString            *recordFileName;    //录音wav文件名
QL_Nonatomic_Copy   NSString            *convertAmr;

QL_Nonatomic_Copy   void(^OverBlock)(bool isOver);
QL_Nonatomic_Strong UIButton *recordBtn;
QL_Nonatomic_Strong UIButton *deleteRecordBtn;

QL_Nonatomic_Assign bool isYangshengqi;
QL_Nonatomic_Assign bool isPlaying;

@end

@implementation VoiceRecorderBaseVC

- (AVAudioPlayer *)player
{
    if (!_player) {
        //初始化播放器
        _player = [[AVAudioPlayer alloc]init];
    }
    return _player;
}

/**
	生成当前时间字符串
	@returns 当前时间字符串
 */
+ (NSString*)getCurrentTimeString
{
    NSDateFormatter *dateformat=[[NSDateFormatter  alloc]init];
    [dateformat setDateFormat:@"yyyyMMddHHmmss"];
    return [dateformat stringFromDate:[NSDate date]];
}


/**
	获取缓存路径
	@returns 缓存路径
 */
+ (NSString*)getCacheDirectory
{
//    return [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)objectAtIndex:0];

    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    return [paths objectAtIndex:0];
}

/**
	判断文件是否存在
	@param _path 文件路径
	@returns 存在返回yes
 */
+ (BOOL)fileExistsAtPath:(NSString*)_path
{
    return [[NSFileManager defaultManager] fileExistsAtPath:_path];
}

/**
	删除文件
	@param _path 文件路径
	@returns 成功返回yes
 */
+ (BOOL)deleteFileAtPath:(NSString*)_path
{
    return [[NSFileManager defaultManager] removeItemAtPath:_path error:nil];
}
    
/**
	生成文件路径
	@param _fileName 文件名
	@param _type 文件类型
	@returns 文件路径
 */
+ (NSString*)getPathByFileName:(NSString *)fileName ofType:(NSString *)type
{
    NSString* fileDirectory = [[[VoiceRecorderBaseVC getCacheDirectory]stringByAppendingPathComponent:fileName]stringByAppendingPathExtension:type];
    return fileDirectory;
}

/**
 生成文件路径
 @param _fileName 文件名
 @returns 文件路径
 */
+ (NSString*)getPathByFileName:(NSString *)fileName
{
    NSString* fileDirectory = [[VoiceRecorderBaseVC getCacheDirectory]stringByAppendingPathComponent:fileName];
    return fileDirectory;
}

/**
	获取录音设置
	@returns 录音设置
 */
+ (NSDictionary*)getAudioRecorderSettingDict
{
    NSDictionary *recordSetting = [[NSDictionary alloc] initWithObjectsAndKeys:
                                   [NSNumber numberWithFloat: 8000.0],AVSampleRateKey, //采样率
                                   [NSNumber numberWithInt: kAudioFormatLinearPCM],AVFormatIDKey,
                                   [NSNumber numberWithInt:16],AVLinearPCMBitDepthKey,//采样位数 默认 16
                                   [NSNumber numberWithInt: 1], AVNumberOfChannelsKey,//通道的数目
//                                   [NSNumber numberWithBool:NO],AVLinearPCMIsBigEndianKey,//大端还是小端 是内存的组织方式
//                                   [NSNumber numberWithBool:NO],AVLinearPCMIsFloatKey,//采样信号是整数还是浮点数
                                   [NSNumber numberWithInt: AVAudioQualityHigh],AVEncoderAudioQualityKey,//音频编码质量
                                   nil];
    return recordSetting;
}


- (UIView *)recordView
{
    if (!_recordView) {
        _recordView = [[UIView alloc]init];
        UIButton *luyinBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [luyinBtn setBackgroundImage:[UIImage imageNamed:@"center_btn"] forState:UIControlStateNormal];
        luyinBtn.frame = CGRectMake(6, 5, 210, 30);
        [luyinBtn addTarget:self action:@selector(Record:) forControlEvents:UIControlEventTouchUpInside];
        [luyinBtn setTitle:@"点击录音" forState:UIControlStateNormal];
        [_recordView addSubview:luyinBtn];
        self.recordBtn = luyinBtn;
        
        UIButton *delBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [delBtn setBackgroundImage:[UIImage imageNamed:@"cancel_btn"] forState:UIControlStateNormal];
        delBtn.frame = CGRectMake(216, 5, 90, 30);
        [delBtn addTarget:self action:@selector(Delete:) forControlEvents:UIControlEventTouchUpInside];
        [delBtn setTitle:@"删除" forState:UIControlStateDisabled];
        [delBtn setEnabled:NO];
        [_recordView addSubview:delBtn];
        self.deleteRecordBtn = delBtn;
    }
    return _recordView;
}

- (void)Record:(UIButton *)sender
{
    NSString *str = sender.currentTitle;
    if ([@"点击录音" isEqualToString:str]) {
        [self beginRecordAction];
        [sender setTitle:kStopLuYin forState:UIControlStateNormal];
        [self.deleteRecordBtn setEnabled:NO];
    }else if([kStopLuYin isEqualToString:str]){
        [self endRecordAction];
        [self.deleteRecordBtn setEnabled:NO];
        [sender setTitle:@"播放录音" forState:UIControlStateNormal];
    }else if([@"播放录音" isEqualToString:str]){
        [self playRecordAction:^(bool isOver) {
            if (isOver) {
                [self.deleteRecordBtn setTitle:@"删除" forState:UIControlStateNormal];
                [self.recordBtn setTitle:@"播放录音" forState:UIControlStateNormal];
            }
        }];
        [sender setTitle:@"播放中..." forState:UIControlStateNormal];\
        NSLog(@"------%@",self.convertAmrFilePath);
        [self.deleteRecordBtn setEnabled:YES];
        if (!self.isYangshengqi) {
            [self.deleteRecordBtn setTitle:@"扬声器🎺" forState:UIControlStateNormal];
        }else{
            [self.deleteRecordBtn setTitle:@"听筒👂" forState:UIControlStateNormal];
        }
    }else if ([@"播放中..." isEqualToString:str]){
        [self stopPlayRecordAction];
        [sender setTitle:@"播放录音" forState:UIControlStateNormal];
        [self.deleteRecordBtn setTitle:@"删除" forState:UIControlStateNormal];
    }
}

- (void)Delete:(UIButton *)sender
{
    NSString *str = sender.currentTitle;
    if ([@"删除" isEqualToString:str])
    {
        [self.recordBtn setTitle:@"点击录音" forState:UIControlStateNormal];
        [self deleteThisRecordAction];
        [sender setEnabled:NO];
    }else{
        if (self.isPlaying) {
            [self changePlayRoteAction];
            if (!self.isYangshengqi) {
                [self.deleteRecordBtn setTitle:@"扬声器🎺" forState:UIControlStateNormal];
            }else{
                [self.deleteRecordBtn setTitle:@"听筒👂" forState:UIControlStateNormal];
            }
        }
    }
}


#pragma mark - 开始录音
- (void)beginRecordByFileName:(NSString*)fileName
{
    //设置文件名和录音路径
    self.recordFilePath = [VoiceRecorderBaseVC getPathByFileName:fileName ofType:kFileTypeWAV];
    NSLog(@"---recordFileName--%@",self.recordFileName);
    NSLog(@"---recordFilePath--%@",self.recordFilePath);
    bool isExist = [VoiceRecorderBaseVC fileExistsAtPath:self.recordFilePath];
    if (isExist) {
        [VoiceRecorderBaseVC deleteFileAtPath:self.recordFilePath];
    }
    //初始化录音
    self.recorder = [[AVAudioRecorder alloc]initWithURL:[NSURL URLWithString:self.recordFilePath]
                                               settings:[VoiceRecorderBaseVC getAudioRecorderSettingDict]
                                                  error:nil];
    self.recorder.meteringEnabled = YES;
    if ([self.recorder prepareToRecord]) {
        
//        UInt32 sessionCategory = kAudioSessionCategory_MediaPlayback;
//        AudioSessionSetProperty(kAudioSessionProperty_AudioCategory, sizeof(sessionCategory), &sessionCategory);
////        外置；
//        UInt32 audioRouteOverride = kAudioSessionOverrideAudioRoute_Speaker;
////        AudioSessionSetProperty (kAudioSessionProperty_OverrideAudioRoute,sizeof (audioRouteOverride),&audioRouteOverride);
//        AudioSessionSetProperty (kAudioSessionProperty_OverrideCategoryDefaultToSpeaker,sizeof (audioRouteOverride),&audioRouteOverride);
        //开始录音
        [[AVAudioSession sharedInstance] setCategory: AVAudioSessionCategoryPlayAndRecord error:nil];
        [[AVAudioSession sharedInstance] setActive:YES error:nil];
        [self.recorder record];
        
        [VoiceConverter changeStu];
        //启动计时器
        NSInvocationOperation *operation = [[NSInvocationOperation alloc] initWithTarget:self                                                                           selector:@selector(wav2AmrAction) object:nil];
        NSOperationQueue *queue = [[NSOperationQueue alloc] init];
        [queue addOperation:operation];
    }
}


- (void)changePlayRoteAction
{
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    if (!self.isYangshengqi) {
        //设置下扬声器模式
        [audioSession setCategory:AVAudioSessionCategoryPlayback error:nil];
    }else{
        //设置听筒模式
        [audioSession setCategory:AVAudioSessionCategoryPlayAndRecord error:nil];
    }
    self.isYangshengqi = !self.isYangshengqi;
    [audioSession setActive:YES error:nil];
}

- (void)beginRecordAction
{
    self.recordFileName = [VoiceRecorderBaseVC getCurrentTimeString];
    [self beginRecordByFileName:self.recordFileName];

}

#pragma mark - 录音结束
- (void)endRecordAction
{
    [VoiceConverter changeStu];
    
    if (self.recorder.isRecording)
    {
        [self.recorder stop];
    }
}

#pragma mark - wav转amr
- (void)wav2AmrAction
{
    if (self.recordFileName.length > 0){
        self.convertAmr = [self.recordFileName stringByAppendingString:@"wavToAmr"];
        
        NSLog(@"wavToAmr:%@",self.convertAmr);
        //转格式
        [VoiceConverter wavToAmr:[VoiceRecorderBaseVC getPathByFileName:self.recordFileName ofType:kFileTypeWAV] amrSavePath:[VoiceRecorderBaseVC getPathByFileName:self.convertAmr ofType:kFileTypeAMR]];
//        [self amr2WavAction];
    }
}

- (NSString *)convertAmrFilePath
{
    if (self.convertAmr && self.convertAmr.length > 0) {
        return [VoiceRecorderBaseVC getPathByFileName:self.convertAmr ofType:kFileTypeAMR];
    }
    return nil;
}

//#pragma mark - amr转wav
//- (void)amr2WavAction
//{
//    if (self.convertAmr.length > 0){
//        self.convertWav = [self.recordFileName stringByAppendingString:@"amrToWav"];
//        NSLog(@"amrToWav :%@",self.convertWav);
//        
//        //转格式
//        [VoiceConverter amrToWav:[VoiceRecorderBaseVC getPathByFileName:self.convertAmr ofType:kFileTypeAMR] wavSavePath:[VoiceRecorderBaseVC getPathByFileName:self.convertWav ofType:kFileTypeWAV]];
//    }
//}

#pragma mark - 播放转换后wav
- (void)playRecordAction:(void (^)(bool))OverBlock
{
    if (self.recordFileName.length > 0){
        self.player = [self.player initWithContentsOfURL:[NSURL URLWithString:self.recordFilePath] error:nil];
        self.player.delegate = self;
        self.isPlaying = [self.player play];
        if (OverBlock) {
            self.OverBlock = OverBlock;
        }
    }
}

- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag
{
    self.isPlaying = NO;
    if (self.OverBlock) {
        self.OverBlock(YES);
    }
}

- (void)stopPlayRecordAction
{
    if (self.player.isPlaying) {
        [self.player stop];
    }
}

- (void)deleteThisRecordAction
{
    [VoiceRecorderBaseVC deleteFileAtPath:self.recordFilePath];
    [VoiceRecorderBaseVC deleteFileAtPath:self.convertAmrFilePath];
    
    [self stopPlayRecordAction];
    self.isPlaying = NO;
    self.recordFilePath = nil;
    self.recordFileName = nil;
    self.convertAmrFilePath = nil;
    self.convertAmr = nil;

}

@end
