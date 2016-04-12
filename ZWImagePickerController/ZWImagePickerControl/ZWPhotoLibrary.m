//
//  ZWPhotoLibrary.m
//  ZWImagePickerController
//
//  Created by Alex on 16/3/30.
//  Copyright © 2016年 Alex. All rights reserved.
//

#import "ZWPhotoLibrary.h"

#define MagicMaxSize 5000000
#define AlbumImageSize 66

@interface ZWAlbum()

@property (nonatomic, strong) PHAssetCollection *phColleciton;
@property (nonatomic, strong) ALAssetsGroup *alGroup;
@property (nonatomic, strong) PHFetchResult *phPhotos;

- (id)initWithPhassetCollection:(PHAssetCollection *)assetCollection;
- (id)initWithAlAssetsGroup:(ALAssetsGroup *)assetsGroup;

@end

@interface ZWAlbumPhoto()

@property (nonatomic, strong) PHAsset *phAsset;
@property (nonatomic, strong) ALAsset *alAsset;

- (id)initWithPHAsset:(PHAsset *)phAsset;
- (id)initWithAlAsset:(ALAsset *)alAsset;

@end


@implementation ZWAlbumPhoto

- (id)initWithPHAsset:(PHAsset *)phAsset {
    self = [super init];
    if (self) {
        _phAsset = phAsset;
    }
    return self;
}

- (id)initWithAlAsset:(ALAsset *)alAsset {
    self = [super init];
    if (self) {
        _alAsset = alAsset;
    }
    return self;
}

- (void)getThumbnailWithSuccessBlock:(void (^)(UIImage * _Nullable))successBlock {
    if (self.phAsset) {
        [[ZWPhotoLibrary sharedInstance]requestThumbnailForAsset:self.phAsset resultHandler:^(UIImage * _Nullable image) {
            if (successBlock) {
                successBlock(image);
            }
        }];
    }else {
        if (successBlock) {
            successBlock([UIImage imageWithCGImage:self.alAsset.thumbnail]);
        }
    }
}

- (void)getFullImageWithProgressBlock:(void(^)(double progress, NSError *__nullable error))progressBlock resultBlock:(void (^)(UIImage * _Nullable result))resultBlock {
    if (self.phAsset) {
        PHImageRequestOptions *options = [[PHImageRequestOptions alloc]init];
        options.version = PHImageRequestOptionsVersionCurrent;
        options.deliveryMode = PHImageRequestOptionsDeliveryModeHighQualityFormat;
        options.resizeMode = PHImageRequestOptionsResizeModeFast;
        [[ZWPhotoLibrary sharedInstance] requestOriginImageForAsset:self.phAsset downloadProgress:progressBlock resultHandler:resultBlock];
    }else {
        ALAssetRepresentation *resultRepresentation = self.alAsset.defaultRepresentation;
        if (resultRepresentation) {
            if (resultBlock) {
                resultBlock([UIImage imageWithCGImage:resultRepresentation.fullScreenImage]);
            }
        }else{
            if (resultBlock) {
                resultBlock([UIImage  imageWithCGImage:self.alAsset.aspectRatioThumbnail]);
            }
        }
    }
}

@end



@implementation ZWAlbum
@dynamic albumName;
@dynamic photoCount;

- (id)initWithAlAssetsGroup:(ALAssetsGroup *)assetsGroup {
    self = [super init];
    if (self) {
        _alGroup = assetsGroup;
    }
    return self;
}

- (id)initWithPhassetCollection:(PHAssetCollection *)assetCollection {
    self = [super init];
    if (self) {
        _phColleciton = assetCollection;
        [self reloadData];
    }
    return self;
}

- (void)reloadData {
    if (!self.phColleciton) {
        return;
    }
    PHFetchOptions *option = [[PHFetchOptions alloc]init];
    option.predicate = [NSPredicate predicateWithFormat:@"mediaType == %d",PHAssetMediaTypeImage];
    PHFetchResult *result = [PHAsset fetchAssetsInAssetCollection:self.phColleciton options:option];
    _phPhotos = result;
}

- (NSString *)albumName {
    return  self.phColleciton ? [self.phColleciton localizedTitle] : [self.alGroup valueForProperty:ALAssetsGroupPropertyName];
}

- (NSUInteger)photoCount {
    NSUInteger count = 0;
    if (self.phColleciton) {
        count = [self.phPhotos count];
    } else {
        count = [self.alGroup numberOfAssets];
    }
    return count;
}

- (void)getCoverImageWithSuccessBlock:(void (^)(UIImage * _Nullable))successBlock {
    if (self.phColleciton) {
        PHFetchOptions *option = [[PHFetchOptions alloc]init];
        option.predicate = [NSPredicate predicateWithFormat:@"mediaType == %d",PHAssetMediaTypeImage];
        PHFetchResult *result = [PHAsset fetchAssetsInAssetCollection:self.phColleciton options:option];
        PHAsset *asset = [result lastObject];
        [[ZWPhotoLibrary sharedInstance] requestImageForAsset:asset targetSize:CGSizeMake(AlbumImageSize, AlbumImageSize) contentMode:PHImageContentModeAspectFit options:nil resultHandler:^(UIImage * _Nullable image) {
            if (successBlock) {
                successBlock(image);
            }
        }];
    } else {
        [self.alGroup enumerateAssetsAtIndexes:[NSIndexSet indexSetWithIndex:self.alGroup.numberOfAssets-1] options:NSEnumerationConcurrent usingBlock:^(ALAsset *result, NSUInteger index, BOOL *stop) {
            if (result) {
                *stop = YES;
                if (successBlock) {
                    successBlock([UIImage imageWithCGImage:result.thumbnail]);
                }
            }
        }];
    }
}

- (ZWAlbumPhoto *)photoAtIndex:(NSUInteger)index {
    __block ZWAlbumPhoto *photo ;
    if (self.phColleciton) {
        PHAsset *asset = [self.phPhotos objectAtIndex:index];
        photo = [[ZWAlbumPhoto alloc] initWithPHAsset:asset];
    }else {
        [self.alGroup enumerateAssetsAtIndexes:[NSIndexSet indexSetWithIndex:index] options:NSEnumerationConcurrent usingBlock:^(ALAsset *result, NSUInteger index, BOOL *stop) {
            if (result) {
                photo = [[ZWAlbumPhoto alloc] initWithAlAsset:result];
                *stop = YES;
            }
        }];
    }
    return photo;
}

@end



@interface ZWPhotoLibrary()

@property(nonatomic ,strong) ALAssetsLibrary *assetsLibrary;
@property(nonatomic ,strong) PHCachingImageManager *imageManager;

@end

@implementation ZWPhotoLibrary

static ZWPhotoLibrary *shareInstance = nil;

+ (ZWPhotoLibrary *)sharedInstance
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        shareInstance = [[self alloc]init];
    });
    return shareInstance;
}

- (instancetype)init
{
    self = [super init];
    if (self && SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"8.0")) {
        _imageManager = [[PHCachingImageManager alloc]init];
    }
    return self;
}

- (ALAssetsLibrary *)assetsLibrary
{
    if (nil == _assetsLibrary) {
        _assetsLibrary = [[ALAssetsLibrary alloc] init];
    }
    return _assetsLibrary;
}

- (void)getAllAlbumsWithSuccessBlock:(void (^)(NSArray * _Nonnull))successBlock {
    NSMutableArray *albumArray = [NSMutableArray array];
    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"8.0")) {
        NSMutableArray *a = [NSMutableArray new];
        [a addObjectsFromArray:[self getSmartAlbum]];
        [a addObjectsFromArray:[self getUserCreatAlbum]];
        [a enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            [albumArray addObject:[[ZWAlbum alloc] initWithPhassetCollection:obj]];
        }];
        if (successBlock) {
            successBlock(albumArray);
        }
    }else {
        [self loadALAssetsGroups:^(NSArray * _Nullable assetsGroups) {
            [assetsGroups enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                [albumArray addObject:[[ZWAlbum alloc] initWithAlAssetsGroup:obj]];
            }];
            if (successBlock) {
                successBlock(albumArray);
            }
        }];
    }
}

- (NSArray *)getSmartAlbum
{
    PHFetchOptions *option = [[PHFetchOptions alloc]init];
    option.predicate = [NSPredicate predicateWithFormat:@"mediaType == %d",PHAssetMediaTypeImage];
    PHFetchResult *smartCollections = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeSmartAlbum subtype:PHAssetCollectionSubtypeAlbumRegular options:nil];
    NSMutableArray *smart = [NSMutableArray new];
    [smartCollections enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        PHAssetCollection * collection = obj;
        PHFetchResult *result = [PHAsset fetchAssetsInAssetCollection:collection options:option];
        if(result.count > 0)
        {
            if (collection.assetCollectionSubtype == PHAssetCollectionSubtypeSmartAlbumUserLibrary) {
                [smart insertObject:collection atIndex:0];
            }else
            {
                [smart addObject:collection];
            }
        }
    }];
    return [smart copy];
}

- (NSArray *)getUserCreatAlbum
{
    PHFetchResult *userCollections = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeAlbum subtype:PHAssetCollectionSubtypeAny options:nil];
    PHFetchOptions *option = [[PHFetchOptions alloc]init];
    option.predicate = [NSPredicate predicateWithFormat:@"mediaType == %d",PHAssetMediaTypeImage];
    NSMutableIndexSet *mutableIndexSet= [[NSMutableIndexSet alloc]init];
    [userCollections enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        PHFetchResult *result = [PHAsset fetchAssetsInAssetCollection:obj options:option];
        if(result.count > 0)
        {
            [mutableIndexSet addIndex:idx];
        }
    }];
    return [userCollections objectsAtIndexes:mutableIndexSet];
}

#pragma -mark iOS 8+
- (void)requestThumbnailForAsset:(PHAsset *)asset resultHandler:(void (^)(UIImage * _Nullable result))resultHandler
{
    PHImageRequestOptions *options = [[PHImageRequestOptions alloc]init];
    options.version = PHImageRequestOptionsVersionCurrent;
    options.deliveryMode = PHImageRequestOptionsDeliveryModeHighQualityFormat;
    options.resizeMode = PHImageRequestOptionsResizeModeFast;
    [self requestImageForAsset:asset targetSize:CGSizeMake(([UIScreen mainScreen].bounds.size.width-3)/4 ,([UIScreen mainScreen].bounds.size.width-3)/4) contentMode:PHImageContentModeAspectFill options:options resultHandler:^(UIImage * _Nullable result) {
        if (resultHandler) {
            resultHandler(result);
        }
    }];
}

- (void)requestOriginImageForAsset:(PHAsset *)asset downloadProgress:(void(^)(double progress, NSError *__nullable error))downloadProgress resultHandler:(void (^)(UIImage * _Nullable result))resultHandler
{
    CGSize size;
    NSInteger pixelSize = asset.pixelWidth * asset.pixelHeight;
    if (pixelSize > MagicMaxSize) {
        float i = 1.0 * MagicMaxSize/pixelSize;
        size = CGSizeMake(asset.pixelWidth * i, asset.pixelHeight * i);
    }else
    {
        size = CGSizeMake(asset.pixelWidth, asset.pixelHeight);
    }
    PHImageRequestOptions *options = [[PHImageRequestOptions alloc]init];
    options.version = PHImageRequestOptionsVersionCurrent;
    options.deliveryMode = PHImageRequestOptionsDeliveryModeHighQualityFormat;
    options.networkAccessAllowed = YES;
    options.synchronous = NO;
    [options setProgressHandler:^(double progress, NSError *__nullable error, BOOL *stop, NSDictionary *__nullable info){
        if (downloadProgress) {
            downloadProgress(progress, error);
        }
    }];
    [[ZWPhotoLibrary sharedInstance]requestImageForAsset:asset targetSize:size contentMode:PHImageContentModeDefault options:options resultHandler:^(UIImage * _Nullable result) {
        if (resultHandler) {
            resultHandler(result);
        }
    }];
}

- (void)requestImageForAsset:(PHAsset *)asset targetSize:(CGSize)targetSize contentMode:(PHImageContentMode)contentMode options:(nullable PHImageRequestOptions *)options resultHandler:(nonnull void (^)(UIImage * _Nullable result))resultHandler
{
    [_imageManager requestImageForAsset:asset targetSize:CGSizeMake(targetSize.width*[UIScreen mainScreen].nativeScale, targetSize.height*[UIScreen mainScreen].nativeScale) contentMode:contentMode options:options resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
        if([info objectForKey:PHImageErrorKey] == nil)
        {
            if (resultHandler) {
                resultHandler(result);
            }
        }
    }];
}

#pragma -mark
- (void)loadALAssetsGroups:(void (^)(NSArray *assetsGroups))completion
{
    __block NSMutableArray *assetsGroups = [NSMutableArray array];
    __block NSUInteger numberOfFinishedTypes = 0;
    [self.assetsLibrary enumerateGroupsWithTypes:ALAssetsGroupAll usingBlock:^(ALAssetsGroup *assetsGroup, BOOL *stop)
     {
         if (assetsGroup) {
             if (assetsGroup.numberOfAssets > 0) {
                 [assetsGroups addObject:assetsGroup];
             }
         } else {
             numberOfFinishedTypes++;
         }
         if (numberOfFinishedTypes == @[@(ALAssetsGroupAll)].count) {
             NSArray *tempGroups = [assetsGroups sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
                 ALAssetsGroup *a = obj1;
                 ALAssetsGroup *b = obj2;
                 NSNumber *apropertyType = [a valueForProperty:ALAssetsGroupPropertyType];
                 NSNumber *bpropertyType = [b valueForProperty:ALAssetsGroupPropertyType];
                 if ([apropertyType compare:bpropertyType] == NSOrderedAscending)
                 {
                     return NSOrderedDescending;
                 }
                 return NSOrderedSame;
             }];
             if (completion) {
                 completion(tempGroups);
             }
         }
     } failureBlock:^(NSError *error) {
         if ([ALAssetsLibrary authorizationStatus] != ALAuthorizationStatusAuthorized){
             
         }
     }];
}

@end
