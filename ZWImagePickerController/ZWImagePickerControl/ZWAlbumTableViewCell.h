//
//  ZWAlbumTableViewCell.h
//  ZWImagePickerController
//
//  Created by Alex on 16/4/10.
//  Copyright © 2016年 Alex. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ZWAlbumTableViewCell : UITableViewCell

@property(nonatomic ,strong)UIImage *albumImage;
@property(nonatomic ,copy)NSString *albumName;
@property(nonatomic ,assign)NSUInteger albumCount;

@end
