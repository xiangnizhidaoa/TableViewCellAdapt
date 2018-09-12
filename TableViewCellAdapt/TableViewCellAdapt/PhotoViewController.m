//
//  PhotoViewController.m
//  Investigation
//
//  Created by 牛方路 on 2018/9/11.
//  Copyright © 2018年 牛方路. All rights reserved.
//

#import "PhotoViewController.h"
#import <AudioToolbox/AudioToolbox.h>

//1.获取屏幕宽度与高度
#define SCREEN_WIDTH   [UIScreen mainScreen].bounds.size.width
#define SCREENH_HEIGHT [UIScreen mainScreen].bounds.size.height

@interface PhotoViewController ()<UIScrollViewDelegate,UIActionSheetDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate>

@property (nonatomic,strong) UIScrollView *scrollerView;

@property (nonatomic,assign) NSInteger index;


@end

@implementation PhotoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initView];
}

-(void)initView{
    self.index = 0;
    self.navigationController.navigationBar.hidden = YES;//隐藏导航栏
    [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationNone];//隐藏状态栏
    self.view.backgroundColor = [UIColor blackColor];
    self.title =  [NSString stringWithFormat:@"1/%lu",(unsigned long)self.imageArray.count];
    self.navigationController.navigationBar.translucent = YES;//设置导航栏透明度
    self.scrollerView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREENH_HEIGHT  )];
    self.scrollerView.backgroundColor = [UIColor blackColor];
    self.scrollerView.contentSize = CGSizeMake(SCREEN_WIDTH * self.imageArray.count, SCREENH_HEIGHT  );
    self.scrollerView.delegate = self;
    self.scrollerView.pagingEnabled = YES;
    
    for (int i = 0; i < self.imageArray.count; i ++) {
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(SCREEN_WIDTH * i, 0, SCREEN_WIDTH, SCREENH_HEIGHT )];
        imageView.image  = self.imageArray[i];
        imageView.userInteractionEnabled = YES;
        imageView.contentMode = UIViewContentModeScaleAspectFill;//设置图片填充样式
        //图片点击手势
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(cilck)];
        [imageView addGestureRecognizer:tap];
        
//        //图片滑动手势
//        UISwipeGestureRecognizer *swipe = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipe)];
//        swipe.direction=UISwipeGestureRecognizerDirectionRight | UISwipeGestureRecognizerDirectionLeft;
//        [imageView addGestureRecognizer:swipe];
        
        //图片长按手势
        UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPress:)];
        longPress.minimumPressDuration = 1.0f;
        [imageView addGestureRecognizer:longPress];
        
        [self.scrollerView addSubview:imageView];
    }
    [self.view addSubview:self.scrollerView];
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setTitle:@"删除" forState:UIControlStateNormal];
    [button setTitleColor:[UIColor yellowColor] forState:UIControlStateNormal];
    button.frame = CGRectMake(0, 0, 44, 44);
    // 让按钮内部的所有内容左对齐
    button.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    [button addTarget:self action:@selector(deleat) forControlEvents:UIControlEventTouchUpInside];
    // 修改导航栏左边的item
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:button];
}

-(void)deleat
{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"提示"
                                                                   message:@"是否要删除当前图片?"
                                                            preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"是" style:UIAlertActionStyleDefault
                                                          handler:^(UIAlertAction * action) {
                                                              [[NSNotificationCenter defaultCenter] postNotificationName:@"deleat" object:self userInfo:@{@"value":self.imageArray[self.index]}];
                                                              [self.navigationController popViewControllerAnimated:YES];
                                                          }];
    UIAlertAction* cancelAction = [UIAlertAction actionWithTitle:@"否" style:UIAlertActionStyleDefault
                                                         handler:^(UIAlertAction * action) {
                                                             
                                                         }];
#pragma mark - 设置弹框按钮颜色
    [defaultAction setValue:[UIColor redColor] forKey:@"_titleTextColor"];
    [cancelAction setValue:[UIColor blueColor] forKey:@"_titleTextColor"];
    
    [alert addAction:cancelAction];
    [alert addAction:defaultAction];
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    self.index = scrollView.contentOffset.x / SCREEN_WIDTH ;
    self.title = [NSString stringWithFormat:@"%ld/%lu",self.index+ 1,(unsigned long)self.imageArray.count];
}

-(void)cilck
{
    [self changeState];
}

-(void)changeState
{
    self.navigationController.navigationBar.hidden = !self.navigationController.navigationBar.isHidden ;
    [[UIApplication sharedApplication] setStatusBarHidden:self.navigationController.navigationBar.isHidden withAnimation:UIStatusBarAnimationNone];
    self.scrollerView.contentOffset = CGPointMake(self.scrollerView.contentOffset.x, 0);
    self.scrollerView.scrollEnabled = self.navigationController.navigationBar.isHidden;
}

-(void)longPress:(UILongPressGestureRecognizer *)longPress
{
    if (longPress.state == UIGestureRecognizerStateBegan) {
        if (self.navigationController.navigationBar.isHidden == NO) {
            [self changeState];
        }
        AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
        UIActionSheet * actionSheet = [[UIActionSheet alloc]initWithTitle:nil delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"分享",@"XXXX", nil];
        actionSheet.actionSheetStyle = UIActionSheetStyleDefault;
        [actionSheet showInView:self.view];
    }
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    NSLog(@"buttonIndex-----%li",(long)buttonIndex);
    if (buttonIndex==0) {
        NSLog(@"分享");
    }else if (buttonIndex==1){
        NSLog(@"XXXX");
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}


@end
