//
//  ZWImageCollectionViewCell.m
//  ZWImagePickerController
//
//  Created by Alex on 16/4/10.
//  Copyright © 2016年 Alex. All rights reserved.
//

#import "ZWImageCollectionViewCell.h"
@interface ZWImageCollectionViewCell ()
@property (weak, nonatomic) IBOutlet UIImageView *photoImageView;

@end
@implementation ZWImageCollectionViewCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setImage:(UIImage *)image
{
    _image = image;
    [_photoImageView setImage:_image];
}
@end
