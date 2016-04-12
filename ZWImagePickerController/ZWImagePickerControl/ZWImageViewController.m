//
//  ZWImageViewController.m
//  ZWImagePickerController
//
//  Created by Alex on 16/4/10.
//  Copyright © 2016年 Alex. All rights reserved.
//

#import "ZWImageViewController.h"
#import "ZWImageCollectionViewCell.h"
#import "MBProgressHUD.h"
@interface ZWImageViewController ()
@property (weak, nonatomic) IBOutlet UICollectionView *imageCollectionView;
@property (nonatomic, strong) PHFetchResult *result;
@property (nonatomic, strong) MBProgressHUD *progressHUD;
@property (nonatomic, strong) ZWAlbum *album;
@property (nonatomic, strong) ALAssetsGroup *assetsGroup;
@property (nonatomic, strong) NSIndexPath *startIndexPath;
@end

@implementation ZWImageViewController
- (id)initWithAlbum:(ZWAlbum *)album {
    self = [super init];
    if (self) {
        self.title = album.albumName;
        _album = album;
        _startIndexPath = [NSIndexPath indexPathForItem:_album.photoCount - 1 inSection:0];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadData) name:UIApplicationDidBecomeActiveNotification object:nil];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    NSString *imageCollcetionCellIdentifier = NSStringFromClass([ZWImageCollectionViewCell class]);
    [_imageCollectionView registerNib:[UINib nibWithNibName:imageCollcetionCellIdentifier bundle:nil] forCellWithReuseIdentifier:imageCollcetionCellIdentifier];
    _progressHUD = [[MBProgressHUD alloc] initWithWindow:[[UIApplication sharedApplication]keyWindow]];
    _progressHUD.mode = MBProgressHUDModeDeterminate;
    _progressHUD.dimBackground = YES;
    [_progressHUD hide:NO];
    [self.view addSubview:_progressHUD];
    if (_startIndexPath) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [_imageCollectionView scrollToItemAtIndexPath:_startIndexPath atScrollPosition:UICollectionViewScrollPositionBottom animated:NO];
        });
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)reloadData {
    [self.album reloadData];
    [self.imageCollectionView reloadData];
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.album.photoCount;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return CGSizeMake(([UIScreen mainScreen].bounds.size.width-3)/4 ,([UIScreen mainScreen].bounds.size.width-3)/4);
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *identifier = NSStringFromClass([ZWImageCollectionViewCell class]);
    ZWImageCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:identifier forIndexPath:indexPath];
    ZWAlbumPhoto *photo = [self.album photoAtIndex:indexPath.row];
    [photo getThumbnailWithSuccessBlock:^(UIImage * _Nullable result) {
        cell.image = result;
    }];
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    _progressHUD.labelText = @"正在处理...";
    _progressHUD.progress = 0.55f;
    [_progressHUD show:YES];
    ZWAlbumPhoto *photo = [self.album photoAtIndex:indexPath.row];
    [photo getFullImageWithProgressBlock:^(double progress, NSError * _Nullable error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (error == nil) {
                _progressHUD.labelText = @"从iCloud下载图片...";
                [_progressHUD show:YES];
                _progressHUD.progress = progress;
                if(progress == 1.0f){
                    [_progressHUD hide:NO];
                }
            }else{
                [_progressHUD hide:YES];
            }
        });
    } resultBlock:^(UIImage * _Nullable result) {
        [_progressHUD hide:YES];
        [[NSNotificationCenter defaultCenter]postNotificationName:@"imageResult" object:result];
        [self.navigationController popToRootViewControllerAnimated:YES];
    }];
}

-(void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
