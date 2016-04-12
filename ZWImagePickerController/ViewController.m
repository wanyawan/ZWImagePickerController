//
//  ViewController.m
//  ZWImagePickerController
//
//  Created by Alex on 16/3/30.
//  Copyright © 2016年 Alex. All rights reserved.
//

#import "ViewController.h"
#import "ZWAlbumViewController.h"
@interface ViewController ()
@property (nonatomic ,strong)UIImageView *imageView;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initNavigationItem];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(reloadImage:) name:@"imageResult" object:nil];
    _imageView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height)];
    [self.view addSubview:_imageView];
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)initNavigationItem
{
    [self.navigationItem setTitle:@"选择照片demo"];
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeSystem];
    [btn setTitle:@"打开相册" forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(openAlbum:) forControlEvents:UIControlEventTouchUpInside];
    btn.frame = CGRectMake(0, 0, 80, 30);
    UIBarButtonItem *btnItem = [[UIBarButtonItem alloc]initWithCustomView:btn];
    [self.navigationItem setRightBarButtonItem:btnItem];
}
- (void)openAlbum:(id)sender{
    ZWAlbumViewController *albumViewController = [[ZWAlbumViewController alloc]init];
    [self.navigationController pushViewController:albumViewController animated:YES];
}

- (void)reloadImage:(NSNotification *)notification{
    id obj = [notification object];
    if ([obj isKindOfClass:[UIImage class]]) {
        UIImage *img = obj;
        [_imageView setImage:img];
    }
}
@end
