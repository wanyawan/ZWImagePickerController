//
//  ZWAlbumTableViewCell.m
//  ZWImagePickerController
//
//  Created by Alex on 16/4/10.
//  Copyright © 2016年 Alex. All rights reserved.
//

#import "ZWAlbumTableViewCell.h"
@interface ZWAlbumTableViewCell ()
@property (weak, nonatomic) IBOutlet UILabel *albumNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *albumCountLabel;
@property (weak, nonatomic) IBOutlet UIImageView *albumImageView;
@end

@implementation ZWAlbumTableViewCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setAlbumImage:(UIImage *)albumImage
{
    _albumImage = albumImage;
    [_albumImageView setImage:_albumImage];
}

- (void)setAlbumName:(NSString *)albumName
{
    _albumName = albumName;
    _albumNameLabel.text = _albumName;
}

- (void)setAlbumCount:(NSUInteger)albumCount
{
    _albumCount = albumCount;
    _albumCountLabel.text = [NSString stringWithFormat:@"%lu",(unsigned long)_albumCount];
}
@end
