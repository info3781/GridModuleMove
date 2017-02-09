//
//  RACollectionViewTripletLayout.h
//  RACollectionViewTripletLayout-Demo
//
//  Created by Ryo Aoyama on 5/25/14.
//  Copyright (c) 2014 Ryo Aoyama. All rights reserved.
//

#import <UIKit/UIKit.h>

#define RACollectionViewTripletLayoutStyleSquare CGSizeZero

@protocol RACollectionViewDelegateTripletLayout <UICollectionViewDelegateFlowLayout>

@optional

- (NSInteger)numOfItemsPerLine:(UICollectionView *)collectionView;
- (CGFloat)aspecRatioForCollectionView:(UICollectionView *)collectionView;
- (UIEdgeInsets)insetsForCollectionView:(UICollectionView *)collectionView;
- (CGFloat)minimumInteritemSpacingForCollectionView:(UICollectionView *)collectionView;
- (CGFloat)minimumLineSpacingForCollectionView:(UICollectionView *)collectionView;
- (CGFloat)sectionHeaderHeightForCollectionView:(UICollectionView *)collectionView;

@end

@protocol RACollectionViewTripletLayoutDatasource <UICollectionViewDataSource>

@end

@interface RACollectionViewTripletLayout : UICollectionViewFlowLayout

@property (nonatomic, weak) id<RACollectionViewDelegateTripletLayout> delegate;
@property (nonatomic, weak) id<RACollectionViewTripletLayoutDatasource> datasource;

@property (nonatomic,assign,readonly) CGSize cellSize;
@property (nonatomic,assign, readonly) CGSize cellLongPressSize;

- (UICollectionViewLayoutAttributes *)unVisiableLayoutAttributes:(NSIndexPath *)indexPath;

@end
