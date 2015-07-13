//
//  ViewController.m
//  RecordDemo
//
//  Created by xuqianlong on 15/2/5.
//  Copyright (c) 2015年 夕阳栗子. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor redColor];
    
    // Do any additional setup after loading the view, typically from a nib.
    self.recordView.frame = CGRectMake(0,130, 320, 40);
    self.recordView.backgroundColor = [UIColor orangeColor];
    [self.view addSubview:self.recordView];

    UIButton *btn = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
    btn.frame = CGRectMake(290,4, 30, 30);
    [self.recordView addSubview:btn];
    
    [btn addTarget:self action:@selector(showRecodeFilePath) forControlEvents:UIControlEventTouchUpInside];
}

- (void)showRecodeFilePath
{
    if (self.convertAmrFilePath && self.convertAmrFilePath.length > 0) {
        NSLog(@"----语音：%@",self.convertAmrFilePath);
        NSURL *url = [NSURL fileURLWithPath:self.convertAmrFilePath];
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"录音路径" message:[url description] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
        
    }else{
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"囧" message:@"先录音啊！" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];

    }
}

@end
