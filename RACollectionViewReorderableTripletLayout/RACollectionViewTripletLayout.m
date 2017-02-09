//
//  RACollectionViewTripletLayout.m
//  RACollectionViewTripletLayout-Demo
//
//  Created by Ryo Aoyama on 5/25/14.
//  Copyright (c) 2014 Ryo Aoyama. All rights reserved.
//

#import "RACollectionViewTripletLayout.h"
#import "RACollectionReusableView.h"

static NSString *const HorizontalLineKind = @"HorizontalLineKind";
static NSString *const VerticalLineKind = @"VerticalLineKind";

@interface RACollectionViewTripletLayout()

@property (nonatomic, strong) NSMutableArray *attributesBySection;
@property (nonatomic, assign) CGFloat collectionViewContentLength;

@property (nonatomic, assign) CGFloat interItemSpacing;
@property (nonatomic, assign) CGFloat lineSpacing;
@property (nonatomic, assign) NSInteger numOfItemPerLine;
@property (nonatomic, assign) CGFloat aspecRatio;
@property (nonatomic, assign) UIEdgeInsets insets;
@property (nonatomic, assign) CGFloat headerHeight;

@end

@implementation RACollectionViewTripletLayout

#pragma mark - init
- (instancetype)init
{
    if (self = [super init]) {
        [self sharedInit];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super initWithCoder:aDecoder]) {
        [self sharedInit];
    }
    return self;
}

- (void)sharedInit
{
    _insets = UIEdgeInsetsZero;
    _interItemSpacing = 1.f;
    _lineSpacing = 1.f;
    _numOfItemPerLine = 3;
    _aspecRatio  = 1.f;
    _headerHeight = 0.f;
}


#pragma mark - Override UICollectionViewFlowLayout methods
- (void)prepareLayout
{
    [super prepareLayout];
    
    if ([self.delegate respondsToSelector:@selector(minimumInteritemSpacingForCollectionView:)]) {
        _interItemSpacing = [self.delegate minimumInteritemSpacingForCollectionView:self.collectionView];
    }
    if ([self.delegate respondsToSelector:@selector(minimumLineSpacingForCollectionView:)]) {
        _lineSpacing = [self.delegate minimumLineSpacingForCollectionView:self.collectionView];
    }
    if ([self.delegate respondsToSelector:@selector(insetsForCollectionView:)]) {
        _insets = [self.delegate insetsForCollectionView:self.collectionView];
    }
    if ([self.delegate respondsToSelector:@selector(aspecRatioForCollectionView:)]) {
        _aspecRatio = [self.delegate aspecRatioForCollectionView:self.collectionView];
    }
    if ([self.delegate respondsToSelector:@selector(numOfItemsPerLine:)]) {
        _numOfItemPerLine = [self.delegate numOfItemsPerLine:self.collectionView];
    }
    if ([self.delegate respondsToSelector:@selector(sectionHeaderHeightForCollectionView:)]) {
        _headerHeight = [self.delegate sectionHeaderHeightForCollectionView:self.collectionView];
    }
    
    // Registers my decoration views.
    [self registerClass:[VerticalLine class] forDecorationViewOfKind:VerticalLineKind];
    [self registerClass:[HorizontalLine class] forDecorationViewOfKind:HorizontalLineKind];
    
    [self caulContentLength];
    [self layoutAttributes];
}

- (CGSize)collectionViewContentSize
{
    return CGSizeMake(self.collectionView.bounds.size.width, self.collectionViewContentLength);
}

- (void)setDelegate:(id<RACollectionViewDelegateTripletLayout>)delegate
{
    self.collectionView.delegate = delegate;
}

- (id<RACollectionViewDelegateTripletLayout>)delegate
{
    return (id<RACollectionViewDelegateTripletLayout>)self.collectionView.delegate;
}


- (NSArray<UICollectionViewLayoutAttributes *> *)layoutAttributesForElementsInRect:(CGRect)rect
{
    NSMutableArray *baseAttributesArray = [NSMutableArray array];
    
    //header
    for (NSInteger section = 0; section < self.collectionView.numberOfSections; section++) {
        [baseAttributesArray addObject:[self layoutAttributesForSupplementaryViewOfKind:UICollectionElementKindSectionHeader atIndexPath:[NSIndexPath indexPathForItem:0 inSection:section]]];
    }
    
    //cell
    for (NSArray *sectionAttArr in self.attributesBySection) {
        for (UICollectionViewLayoutAttributes *attriBute in sectionAttArr) {
            if (CGRectIntersectsRect(rect, attriBute.frame)) {
                [baseAttributesArray addObject:attriBute];
            }
        }
    }
    
    NSMutableArray *layoutAttributesArray = [baseAttributesArray mutableCopy];
    //decoration
    for (UICollectionViewLayoutAttributes *layoutAttributes in baseAttributesArray) {
        
        NSIndexPath *indexPath = layoutAttributes.indexPath;
        // add vertical lines
        if ([self indexPathNotInFirstCol:indexPath]) {
            //VerticalLine
            UICollectionViewLayoutAttributes *verticalAttributes = [self layoutAttributesForDecorationViewOfKind:VerticalLineKind atIndexPath:indexPath];
            [layoutAttributesArray addObject:verticalAttributes];
        }
        
        // add horizontal lines
        UICollectionViewLayoutAttributes *horizontalAttributes = [self layoutAttributesForDecorationViewOfKind:HorizontalLineKind atIndexPath:indexPath];
        [layoutAttributesArray addObject:horizontalAttributes];
    }
    
    return layoutAttributesArray;
}
- (UICollectionViewLayoutAttributes *)layoutAttributesForSupplementaryViewOfKind:(NSString *)elementKind atIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewLayoutAttributes *supplementaryAttributes = [UICollectionViewLayoutAttributes layoutAttributesForSupplementaryViewOfKind:elementKind withIndexPath:indexPath];
    
    supplementaryAttributes.frame = CGRectMake(0, 0, self.collectionView.size.width, _headerHeight);
    supplementaryAttributes.zIndex = 1000;
    
    return supplementaryAttributes;
}
- (UICollectionViewLayoutAttributes *)layoutAttributesForDecorationViewOfKind:(NSString *)decorationViewKind atIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewLayoutAttributes *decorationAttributes = [UICollectionViewLayoutAttributes layoutAttributesForDecorationViewOfKind:decorationViewKind withIndexPath:indexPath];
    UICollectionViewLayoutAttributes *cellLayoutAttributes = [self layoutAttributesForItemAtIndexPath:indexPath];
    CGRect cellFrame = cellLayoutAttributes.frame;
    
    if ([decorationViewKind isEqualToString:VerticalLineKind]) {
        decorationAttributes.frame = CGRectMake(cellFrame.origin.x - self.interItemSpacing, cellFrame.origin.y, self.interItemSpacing, cellFrame.size.height);
    }
    else if ([decorationViewKind isEqualToString:HorizontalLineKind]) {
        CGFloat horizontalLineWidth = cellFrame.size.width + self.interItemSpacing;
        if ([self isLastItemInSection:indexPath] && (indexPath.item % self.numOfItemPerLine + 1 < self.numOfItemPerLine)) { //last in section and not the last in line
            horizontalLineWidth -= self.interItemSpacing;
        }
        decorationAttributes.frame = CGRectMake(cellFrame.origin.x, CGRectGetMaxY(cellFrame), horizontalLineWidth, self.lineSpacing);
    }
    decorationAttributes.zIndex = 1000;
    
    return decorationAttributes;
}
- (UICollectionViewLayoutAttributes *)layoutAttributesForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return self.attributesBySection[indexPath.section][indexPath.row];
}

#pragma mark - private methods
- (UICollectionViewLayoutAttributes *)unVisiableLayoutAttributes:(NSIndexPath *)indexPath {
    return [self layoutAttributesForCell:indexPath];
}
- (BOOL)isLastItemInSection:(NSIndexPath *)indexPath
{
    NSInteger lastItemRow = [self.collectionView numberOfItemsInSection:indexPath.section] - 1;
    NSIndexPath *lastItem = [NSIndexPath indexPathForItem:lastItemRow inSection:indexPath.section];
    
    return lastItem == indexPath;
}

- (BOOL)indexPathNotInFirstCol:(NSIndexPath *)indexPath
{
    if (indexPath.item % self.numOfItemPerLine == 0) {
        return NO;
    }
    return YES;
}
//计算section item 布局
- (void)layoutAttributes
{
    _attributesBySection = [NSMutableArray array];
    for (NSInteger section = 0; section < self.collectionView.numberOfSections; section++) {
        [self.attributesBySection addObject:[self layoutAttributesInSection:section]];
    }
}
- (NSArray *)layoutAttributesInSection:(NSInteger)section
{
    NSMutableArray *attributeArr = [NSMutableArray array];
    
    for (int item = 0; item < [self.collectionView numberOfItemsInSection:section]; item++) {
        [attributeArr addObject:[self layoutAttributesForCell:[NSIndexPath indexPathForItem:item inSection:section]]];
    }
    
    return [attributeArr copy];
}
- (UICollectionViewLayoutAttributes *)layoutAttributesForCell:(NSIndexPath *)indexPath
{
    UICollectionViewLayoutAttributes *attribute = [UICollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:indexPath];
    
    attribute.frame = [self frameForItem:indexPath];
    
    return attribute;
}

- (CGRect)frameForItem:(NSIndexPath *)indexPath
{
    //caul item's row and col
    CGSize cellSize = [self caulCellSize];
    NSUInteger row = indexPath.item / _numOfItemPerLine;
    NSUInteger col = indexPath.item % _numOfItemPerLine;
    
    CGRect frame = CGRectZero;
    
    CGFloat sectionStart = [self sectionStartPos:indexPath.section size:cellSize];

    frame.origin.x = col * cellSize.width + col * _interItemSpacing + _insets.left;
    frame.origin.y = sectionStart + row * cellSize.height + row * _lineSpacing + _insets.top + _headerHeight;

    
    frame.size = cellSize;
    return frame;
}
- (CGFloat)sectionStartPos:(NSInteger)section size:(CGSize)cellSize
{
    CGFloat sectionStart = 0.;
    for (NSInteger index = 0; index < section; index++) {
        sectionStart += [self sectionContentLegth:index size:cellSize];
    }
    return sectionStart;
}
- (void)caulContentLength
{
    CGFloat contentLenght = 0.f;
    CGSize cellSize = [self caulCellSize];
    
    for (int section = 0; section < self.collectionView.numberOfSections; section++) {
        contentLenght += [self sectionContentLegth:section size:cellSize];
    }
    
    self.collectionViewContentLength = contentLenght + self.headerHeight;
    
}

- (CGFloat)sectionContentLegth:(NSInteger)section size:(CGSize)cellSize
{
    CGFloat sectionContentLength = 0.f;
    sectionContentLength += [self sectionInsetContentLength];
    NSUInteger rowItem = [self caulRowOfItem:section];
    
    sectionContentLength += rowItem * cellSize.height + (rowItem - 1) * _lineSpacing;
    
    return sectionContentLength;
}
///某个section item 行数
- (NSUInteger)caulRowOfItem:(NSInteger)section
{
    NSInteger totItemInSection = [self.collectionView numberOfItemsInSection:section];
    return totItemInSection / _numOfItemPerLine + (totItemInSection % _numOfItemPerLine == 0 ? 0 : 1);
}
- (CGFloat)sectionInsetContentLength
{
    CGFloat insetLenght = 0.;

    insetLenght = _insets.top + _insets.bottom;
    
    return insetLenght;
}

- (CGSize)caulCellSize
{
    CGFloat useableWidth = [self useableWidth];
    CGFloat itemWidth = useableWidth / _numOfItemPerLine;
    _cellSize = CGSizeMake(itemWidth, itemWidth / _aspecRatio);
    _cellLongPressSize = CGSizeMake(itemWidth + 5, itemWidth / _aspecRatio + 5);
    return _cellSize;
}
- (CGFloat)useableWidth
{
    return (self.collectionViewContentSize.width - _insets.left - _insets.right - (_numOfItemPerLine - 1) * _interItemSpacing);
    
}

@end
