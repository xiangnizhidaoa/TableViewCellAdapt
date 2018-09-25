//
//  PhotoViewController.m
//  Investigation
//
//  Created by 牛方路 on 2018/9/11.
//  Copyright © 2018年 牛方路. All rights reserved.
//

#import "PhotoViewController.h"
#import <AudioToolbox/AudioToolbox.h>//系统振动的类库

//1.获取屏幕宽度与高度
#define SCREEN_WIDTH   [UIScreen mainScreen].bounds.size.width
#define SCREENH_HEIGHT [UIScreen mainScreen].bounds.size.height

@interface PhotoViewController ()<UIScrollViewDelegate,UIActionSheetDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate>

@property (nonatomic,strong) UIScrollView *scrollerView;//滑动视图

@property (nonatomic,assign) NSInteger index;//滑动的位置


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
    self.scrollerView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREENH_HEIGHT )];
    self.scrollerView.backgroundColor = [UIColor blackColor];
    self.scrollerView.contentSize = CGSizeMake(SCREEN_WIDTH * self.imageArray.count, SCREENH_HEIGHT );
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
        longPress.minimumPressDuration = 1.0f;//设置长按响应事件(单位是秒)
        [imageView addGestureRecognizer:longPress];
        
        [self.scrollerView addSubview:imageView];
    }
    self.scrollerView.contentOffset = CGPointMake(SCREEN_WIDTH * self.locationView, 0);
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

-(void)deleat//点击删除弹出提示框(是否确定删除)
{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"提示"
                                                                   message:@"是否要删除当前图片?"
                                                            preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"是" style:UIAlertActionStyleDefault
                                                          handler:^(UIAlertAction * action) {
                                                              //确定删除后发起通知通知列表页面删除图片数据
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

//scrollView滑动后修改title指示文字
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    self.index = scrollView.contentOffset.x / SCREEN_WIDTH ;
    self.title = [NSString stringWithFormat:@"%ld/%lu",self.index+ 1,(unsigned long)self.imageArray.count];
}

//图片轻点手势事件
-(void)cilck
{
    [self changeState];
}

//设置导航栏和状态栏的隐藏与否
-(void)changeState
{
    self.navigationController.navigationBar.hidden = !self.navigationController.navigationBar.isHidden ;
    [[UIApplication sharedApplication] setStatusBarHidden:self.navigationController.navigationBar.isHidden withAnimation:UIStatusBarAnimationNone];
    self.scrollerView.contentOffset = CGPointMake(self.scrollerView.contentOffset.x, 0);//防止当导航栏和状态栏显示时scrollView视图整体下移的效果
    self.scrollerView.scrollEnabled = self.navigationController.navigationBar.isHidden;//在导航栏和状态栏显示时关闭scrollView的滑动事件
}

//图片长按手势事件
-(void)longPress:(UILongPressGestureRecognizer *)longPress
{
    if (longPress.state == UIGestureRecognizerStateBegan) {//判断长按当前所处的状态
        if (self.navigationController.navigationBar.isHidden == NO) {//判断当前导航栏和状态栏是否显示
            [self changeState];
        }
        AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);//调用系统振动效果
        //创建选择窗口
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
