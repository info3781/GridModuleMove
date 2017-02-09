//
//  RACollectionReusableView.h
//  RACollectionViewReorderableTripletLayout-Demo
//
//  Created by info on 16/4/15.
//  Copyright © 2016年 Ryo Aoyama. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RACollectionReusableView : UICollectionReusableView

@end

@interface HorizontalLine : RACollectionReusableView

@end

@interface VerticalLine : RACollectionReusableView

@end

@interface SystemMainTainHeader : RACollectionReusableView
@property (nonatomic, copy) void(^closeBlock)();
+ (CGFloat)systemMainTainHeaderHeight:(NSString *)word;
- (void)updateSystemMainTainWord:(NSString *)word;
@end