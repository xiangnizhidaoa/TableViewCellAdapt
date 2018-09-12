//
//  TableViewController.m
//  TableViewCellAdapt
//
//  Created by 牛方路 on 2018/9/12.
//  Copyright © 2018年 牛方路. All rights reserved.
//

#import "TableViewController.h"
#import "TableViewCell.h"
#import <Masonry.h>
#import "PhotoViewController.h"

//1.获取屏幕宽度与高度
#define SCREEN_WIDTH   [UIScreen mainScreen].bounds.size.width
#define SCREENH_HEIGHT [UIScreen mainScreen].bounds.size.height

@interface TableViewController ()<UIActionSheetDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate>

@property (nonatomic,strong) NSMutableArray *imageArray;//展示图片的数组(可以自己设置为了方便我写的数据都是本地的)

@property (nonatomic,strong) TableViewCell *cell;

@property (nonatomic,assign) NSInteger imageTag;

@property (nonatomic,assign) NSInteger cellTag;

@end

@implementation TableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"动态cell高度";
    self.imageArray = [NSMutableArray array];//添加初始图片
    NSArray *array1 = @[@"uploading_y",@"uploading_y",@"uploading_y"];
    for (int  i = 0; i < 3; i ++) {
        NSMutableArray *array2 = [NSMutableArray arrayWithObject:[UIImage imageNamed:array1[i]]];
        [self.imageArray addObject:array2];
    }
    
    [self.tableView registerNib:[UINib nibWithNibName:@"TableViewCell" bundle:nil] forCellReuseIdentifier:@"TableViewCell"];//cell的注册没啥可说的
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;//去除横线(为了好看^_^)
    self.tableView.rowHeight = UITableViewAutomaticDimension; // 自适应单元格高度
    self.tableView.estimatedRowHeight = 5000.0f;//设置cell的自适应最大高度(值随便给不过不是越大越好)
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(deleat:) name:@"deleat" object:nil];//通知为了接收大图界面删除图片的事件
}

-(void)deleat:(NSNotification *)notif
{
    NSString *string = notif.userInfo[@"value"];
    [self.imageArray[self.cellTag - 100] removeObject:string];
    [self.tableView reloadData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 3;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    self.cell = [tableView cellForRowAtIndexPath:indexPath];//为了防止cell被重用(因为重用的cell高度不会再次被计算需要添加判断来处理,所以这里关闭了cell的重用)
    if (!self.cell) {
        self.cell = [[[NSBundle mainBundle] loadNibNamed:@"TableViewCell" owner:nil options:nil] firstObject];
    }
    NSInteger kSpace = 30;//设置间距
    NSInteger kHight = 84;//设置高度
    NSInteger kWidth = ( SCREEN_WIDTH - 60 - kSpace) / 2;//动态设置图片的宽度(减去的60是xib文件中listView的两边间距)
    NSInteger kLine = 2;//设置列数
    
    for (int i = 0; i <[self.imageArray[indexPath.row] count]; i ++) {
        CGFloat X = (i % kLine) * (kWidth + kSpace);//获取当前创建的imageView的X坐标
        NSUInteger Y = (i / kLine) * (kHight +kSpace);//获取当前创建的imageView的Y坐标
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(X, Y , kWidth, kHight)];
        imageView.image = self.imageArray[indexPath.row][i];
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(click:)];
        imageView.userInteractionEnabled = YES;
        [imageView addGestureRecognizer:tap];
        imageView.tag = 901 + i;
        [self.cell.listView addSubview:imageView];
    }
    
    NSInteger viewHeight = ([self.imageArray[indexPath.row] count] % kLine == 1 ? [self.imageArray[indexPath.row] count] / kLine + 1 : [self.imageArray[indexPath.row] count] / kLine) * (kHight +kSpace);//计算当前listView的视图高度
    [self.cell.listView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(viewHeight);//通过masonry来修改listView的视图高度
    }];
    
    self.cell.selectionStyle = UITableViewCellSelectionStyleNone;
    self.cell.tag = 100 + indexPath.row;//设置cell的tag从而确定应该修改那个cell上的数据
    return self.cell;
}

-(void)click:(UITapGestureRecognizer *)tap
{
    self.imageTag = tap.view.tag;
    self.cellTag = tap.view.superview.superview.superview.tag;
    UIImageView *imageView = (UIImageView *)tap.view;//获取被点击的imageView
    UIImage *image = [self.imageArray[self.cellTag - 100] lastObject];
    
    NSData *data1 = UIImagePNGRepresentation(imageView.image);
    NSData *data2 = UIImagePNGRepresentation(image);
    
    if ([data1 isEqual:data2] ) {//比较当前imageView上的视图和占位图(相同打开相机或者相册,不同进入图片展示界面)
        UIActionSheet * actionSheet = [[UIActionSheet alloc]initWithTitle:nil delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"相机",@"从相册选择", nil];
        actionSheet.actionSheetStyle = UIActionSheetStyleDefault;
        [actionSheet showInView:self.view];
    } else {
        PhotoViewController *photoVC = [[PhotoViewController alloc] initWithNibName:@"PhotoViewController" bundle:nil];
        NSMutableArray *array = [NSMutableArray array];
        for (int i = 0; i < [self.imageArray[self.cellTag - 100] count] - 1; i ++) {
            [array addObject:self.imageArray[self.cellTag - 100][i]];
        }
        photoVC.imageArray = array;
        photoVC.locationView = self.imageTag - 901;
        [self.navigationController pushViewController:photoVC animated:YES];
    }
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    NSLog(@"buttonIndex-----%li",(long)buttonIndex);
    if (buttonIndex==0) {
        NSLog(@"拍照");
        [self openCamera];
    }else if (buttonIndex==1){
        NSLog(@"从相册选择");
        [self openPhotoLibrary];
    }
}

/**
 *  调用照相机
 */
- (void)openCamera
{
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.delegate = self;
    //判断是否可以打开照相机
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]){
        //摄像头
        picker.sourceType = UIImagePickerControllerSourceTypeCamera;
        [self presentViewController:picker animated:YES completion:nil];
    }
    else{
        NSLog(@"没有摄像头");
    }
}

/**
 *  打开相册
 */
-(void)openPhotoLibrary
{
    // 进入相册
    if([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary])
    {
        UIImagePickerController *imagePicker = [[UIImagePickerController alloc]init];
        imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        imagePicker.delegate = self;
        [self presentViewController:imagePicker animated:YES completion:^{
            NSLog(@"打开相册");
        }];
    }
    else
    {
        NSLog(@"不能打开相册");
    }
}

#pragma mark - UIImagePickerControllerDelegate

// (拍照/相册选择)完成回调
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info;
{
    NSLog(@"finish..");
    UIImage *image = [info objectForKey:UIImagePickerControllerOriginalImage];
    self.cell = [self.view viewWithTag:self.cellTag];
    UIImageView *imageView = [self.cell.listView viewWithTag:self.imageTag];//获取点击的是那个imageView
    imageView.image = image;//修改imageView上的image
    [self dismissViewControllerAnimated:YES completion:nil];
    [self.imageArray[self.cellTag - 100] insertObject:image atIndex:0];//获取对应的cell的数组插入新的对象
    [self.tableView reloadData];//刷新tableView
}

//进入拍摄页面点击取消按钮
- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
