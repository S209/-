//
//  HomePageSegmentedHeaderView.h
//  SoYoungMobile40
//
//  Created by Jeakon on 16/7/7.
//  Copyright © 2016年 soyoung. All rights reserved.
//

#import <UIKit/UIKit.h>
@class SYSegmentedControl;
@class SYHomePageRecommendTabModel;
@protocol HomePageSegmentedHeaderViewDelegate;
@interface HomePageSegmentedHeaderView : UIView
@property (nonatomic, strong) NSArray <SYHomePageRecommendTabModel *> * dataList;
@property (nonatomic, strong) SYHomePageRecommendTabModel * curSelectModel;
@property (nonatomic, assign) NSInteger curIndex;
@property (nonatomic, weak) id <HomePageSegmentedHeaderViewDelegate> delegate;
@property (nonatomic, assign) CGPoint contentOffset;

@property (nonatomic, assign) CGPoint doctorSayCenter;//医生说的中心点

+ (instancetype)createSegmentedView;
- (void)setContentOffset:(CGPoint)contentOffset
                animated:(BOOL)animated
              completion:(void(^)(void))completion;
- (void)reloadDataIfNeeded;
- (void)reloadDataIfNeeded:(BOOL)resetIndex;
- (void)setNeedReloadData;
- (void)updateWithCurIndex:(NSInteger)curIndex
                  animated:(BOOL)animated;
//首页轻量化 猜你喜欢小红点
- (void)updateGuessULikeBadgeIfNeeded;
@end


@protocol HomePageSegmentedHeaderViewDelegate <NSObject>
@optional
/** tab点击 */
- (void)homePageSegmentedHeaderView:(HomePageSegmentedHeaderView *)homePageSegmentedHeaderView
                       tabDidSelect:(SYHomePageRecommendTabModel *)model
                            atIndex:(NSInteger)index;
/** 跳转全部日记 */
- (void)homePageSegmentedHeaderViewToAllDiaryList:(HomePageSegmentedHeaderView *)homePageSegmentedHeaderView;

@end
