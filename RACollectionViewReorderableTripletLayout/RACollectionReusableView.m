//
//  RACollectionReusableView.m
//  RACollectionViewReorderableTripletLayout-Demo
//
//  Created by info on 16/4/15.
//  Copyright © 2016年 Ryo Aoyama. All rights reserved.
//

#import "RACollectionReusableView.h"

@implementation RACollectionReusableView
@end


@implementation HorizontalLine

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor colorWithHexString:DividingLineColor];
    }
    
    return self;
}

- (void)applyLayoutAttributes:(UICollectionViewLayoutAttributes *)layoutAttributes {
    self.frame = layoutAttributes.frame;
}
@end


@implementation VerticalLine

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor colorWithHexString:DividingLineColor];
    }
    
    return self;
}

- (void)applyLayoutAttributes:(UICollectionViewLayoutAttributes *)layoutAttributes {
    self.frame = layoutAttributes.frame;
}

@end

@interface SystemMainTainHeader()
@property (nonatomic, strong) UILabel *mainTainWord;
@property (nonatomic, strong) UIButton *closeMaintainHeader;
@end

@implementation SystemMainTainHeader

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor colorWithHexString:NomalBlueTextFontColor];
        
        _mainTainWord = [[UILabel alloc] initWithFrame:CGRectZero];
        _mainTainWord.backgroundColor = [UIColor clearColor];
        _mainTainWord.textColor = [UIColor whiteColor];
        _mainTainWord.font = [UIFont systemFontOfSize:12.0];
        _mainTainWord.lineBreakMode = NSLineBreakByCharWrapping;
        _mainTainWord.numberOfLines = 0;
        [self addSubview:_mainTainWord];
        
        _closeMaintainHeader = [UIButton buttonWithType:UIButtonTypeCustom];
        _closeMaintainHeader.frame = CGRectZero;
        [_closeMaintainHeader setImage:[UIImage imageNamed:@"closeMaintain"] forState:UIControlStateNormal];
        [_closeMaintainHeader addTarget:self action:@selector(closeMaintainHeaderBanner) forControlEvents:UIControlEventTouchUpInside];
        _closeMaintainHeader.hidden = YES;
        [self addSubview:_closeMaintainHeader];
    }
    return self;
}

- (void)applyLayoutAttributes:(UICollectionViewLayoutAttributes *)layoutAttributes {
    self.frame = layoutAttributes.frame;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    CGFloat titLabelWidth = self.bounds.size.width - 46.5;
    CGSize mainTainSize = [self.mainTainWord.text sizeForFont:self.mainTainWord.font size:CGSizeMake(titLabelWidth, MAXFLOAT) mode:NSLineBreakByCharWrapping];
    self.mainTainWord.frame = CGRectMake(12, 12, ceilf(mainTainSize.width), ceilf(mainTainSize.height));
    self.closeMaintainHeader.frame = CGRectMake(self.bounds.size.width - 22, CGRectGetMinY(self.mainTainWord.frame) + 4, 10, 10);
}

- (void)updateSystemMainTainWord:(NSString *)word {
    if ([word isNotBlank]) {
        self.mainTainWord.text = word;
        self.closeMaintainHeader.hidden = NO;
    }
}

- (void)closeMaintainHeaderBanner {
    [self removeAllSubviews];
    if (self.closeBlock) {
        self.closeBlock();
    }
}
+ (CGFloat)systemMainTainHeaderHeight:(NSString *)word {
    CGFloat titLabelWidth = kScreenWidth - 46.5;
    CGSize mainTainSize = [word sizeForFont:[UIFont systemFontOfSize:12.0] size:CGSizeMake(titLabelWidth, MAXFLOAT) mode:NSLineBreakByCharWrapping];
    return ceilf(mainTainSize.height) + 24.0;
}
@end
