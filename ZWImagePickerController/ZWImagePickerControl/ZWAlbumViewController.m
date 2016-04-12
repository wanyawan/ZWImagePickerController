//
//  ZWAlbumViewController.m
//  ZWImagePickerController
//
//  Created by Alex on 16/3/30.
//  Copyright © 2016年 Alex. All rights reserved.
//

#import "ZWAlbumViewController.h"
#import "ZWAlbumTableViewCell.h"
#import "ZWPhotoLibrary.h"
#import "ZWImageViewController.h"
#define AlbumImageSize 66
#define AlbumTableViewCellHeight 80

@interface ZWAlbumViewController ()
@property (weak, nonatomic) IBOutlet UITableView *albumTableView;

@property(nonatomic ,strong)  NSArray *albums;
@end

@implementation ZWAlbumViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    NSString *albumTableViewCellIdentifier  = NSStringFromClass([ZWAlbumTableViewCell class]);
    [self.albumTableView registerNib:[UINib nibWithNibName:albumTableViewCellIdentifier bundle:nil] forCellReuseIdentifier:albumTableViewCellIdentifier];
    [self setNavigationBar];
    [self getAlbumInfo];
    // Do any additional setup after loading the view from its nib.
}

- (void)getAlbumInfo{
    [[ZWPhotoLibrary sharedInstance] getAllAlbumsWithSuccessBlock:^(NSArray * _Nonnull albums) {
        _albums = albums;
        [_albumTableView reloadData];
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setNavigationBar
{
    self.title = @"相簿";
    UIBarButtonItem *cancelButtonItem = [[UIBarButtonItem alloc]initWithTitle:@"取消" style:UIBarButtonItemStylePlain target:self action:@selector(cancelButtonTouched:)];
    self.navigationItem.rightBarButtonItem = cancelButtonItem;
}

- (void)cancelButtonTouched:(id)sender
{

}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _albums.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return AlbumTableViewCellHeight;
}

- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return AlbumTableViewCellHeight;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *cellIdentifier = NSStringFromClass([ZWAlbumTableViewCell class]);
    ZWAlbumTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    ZWAlbum *album = [self.albums objectAtIndex:indexPath.row];
    cell.albumName = album.albumName;
    cell.albumCount = album.photoCount;
    [album getCoverImageWithSuccessBlock:^(UIImage * _Nullable result) {
        cell.albumImage = result;
    }];
    [cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    ZWAlbum *album = [self.albums objectAtIndex:indexPath.row];
    ZWImageViewController *imageViewController = [[ZWImageViewController alloc] initWithAlbum:album];
    [self.navigationController pushViewController:imageViewController animated:YES];
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
