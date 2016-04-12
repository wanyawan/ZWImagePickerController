//
//  ZWPhotoLibrary.h
//  ZWImagePickerController
//
//  Created by Alex on 16/3/30.
//  Copyright © 2016年 Alex. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Photos/Photos.h>
#import <AssetsLibrary/AssetsLibrary.h>

#define SYSTEM_VERSION_EQUAL_TO(v)                  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedSame)
#define SYSTEM_VERSION_GREATER_THAN(v)              ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedDescending)
#define SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v)  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)
#define SYSTEM_VERSION_LESS_THAN(v)                 ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedAscending)
#define SYSTEM_VERSION_LESS_THAN_OR_EQUAL_TO(v)     ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedDescending)

@interface ZWAlbumPhoto : NSObject

- (void)getThumbnailWithSuccessBlock:(void (^_Nullable)(UIImage *_Nullable result))successBlock;
- (void)getFullImageWithProgressBlock:(void(^_Nullable)(double progress, NSError *__nullable error))progressBlock resultBlock:(void (^_Nullable)(UIImage *_Nullable result))resultBlock;

@end

@interface ZWAlbum : NSObject

@property (nonatomic, readonly, copy) NSString *_Nonnull albumName;
@property (nonatomic, readonly, assign) NSUInteger photoCount;

- (void)getCoverImageWithSuccessBlock:(void (^_Nullable)(UIImage * _Nullable result))successBlock;
- (ZWAlbumPhoto *_Nonnull)photoAtIndex:(NSUInteger)index;
- (void)reloadData;

@end

@interface ZWPhotoLibrary : NSObject

+ (ZWPhotoLibrary *_Nonnull)sharedInstance;

- (void)getAllAlbumsWithSuccessBlock:(void(^_Nullable)(NSArray *_Nonnull))successBlock;

- (void)requestThumbnailForAsset:(PHAsset *_Nonnull)asset resultHandler:(void (^_Nullable)(UIImage * _Nullable result))resultHandler;

- (void)requestOriginImageForAsset:(PHAsset *_Nullable)asset downloadProgress:(void(^_Nullable)(double progress, NSError *__nullable error))downloadProgress resultHandler:(void (^_Nullable)(UIImage * _Nullable result))resultHandler;

- (void)requestImageForAsset:(PHAsset  * _Nullable)asset targetSize:(CGSize)targetSize contentMode:(PHImageContentMode)contentMode options:(nullable PHImageRequestOptions *)options resultHandler:(nonnull void (^)(UIImage * _Nullable result))resultHandler;

- (void)loadALAssetsGroups:(void (^_Nullable)(NSArray * _Nullable assetsGroups))completion;

@end