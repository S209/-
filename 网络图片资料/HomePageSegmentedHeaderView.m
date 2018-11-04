//
//  HomePageSegmentedHeaderView.m
//  SoYoungMobile40
//
//  Created by Jeakon on 16/7/7.
//  Copyright © 2016年 soyoung. All rights reserved.
//
#import "UIView+Badge.h"
#import <Masonry/Masonry.h>
#import "HomePageRecommendModel.h"
#import "UIView+SYSeparatorLine.h"
#import "SYSegmentedView.h"
#import "HomePageSegmentedHeaderView.h"
#import "DataEngine.h"
#import "UIView+Gradient.h"
#import "SYGradientView.h"

//cell
@interface SegmentedCollectionViewCell : UICollectionViewCell
@property (nonatomic, strong) UILabel * titleLabel;
@end
@implementation SegmentedCollectionViewCell
- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self setupViews];
    }
    return self;
}
- (void)setupViews {
    [self.contentView addSubview:self.titleLabel];
    __weak UIView * superView = self.contentView;
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(superView);
    }];

    [superView updateConstraintsIfNeeded];
}
- (void)setSelected:(BOOL)selected {

    if (shouldShowGray()) {
        __weak UIView * superView = self.contentView;
        if (selected) {
            [self.titleLabel mas_updateConstraints:^(MASConstraintMaker *make) {
                make.centerY.equalTo(superView).offset(-2);
            }];
            self.titleLabel.font = [UIFont sy_pingFangTCSemiboldFontOfSize:20];
        }else{
            [self.titleLabel mas_updateConstraints:^(MASConstraintMaker *make) {
                make.center.equalTo(superView);
            }];
            self.titleLabel.font = [UIFont sy_pingFangTCSemiboldFontOfSize:16];
        }
    }else{
        UIColor * textColor = selected ? [UIColor sy_green4Color] : [UIColor sy_black1Color];
        self.titleLabel.textColor = textColor;
    }
}
- (UILabel *)titleLabel {
    if (_titleLabel == nil) {
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.useCustomFont = YES;
        if (shouldShowGray()) {
            _titleLabel.font = [UIFont sy_pingFangTCSemiboldFontOfSize:16];
        }else{
            _titleLabel.font = [UIFont sy_pingFangSCRegularFontOfSize:14];
        }
        _titleLabel.textColor = [UIColor sy_black1Color];
    }
    return _titleLabel;
}

@end



//headerview
@interface HomePageSegmentedHeaderView() <UICollectionViewDelegateFlowLayout, UICollectionViewDataSource>
@property (nonatomic, strong) UIImageView * allView;

@property (nonatomic, strong) UICollectionView * collectionView;
@property (nonatomic, strong) SYGradientView * selectView;

@property (nonatomic, assign) BOOL needReloadData;
@property (nonatomic, assign) CGRect selectFrame;

@property (nonatomic, strong) UILabel * testLabel;
//首页轻量化 猜你喜欢小红点
@property (nonatomic, strong) UIView *guessULikeBadgeView;
@property (nonatomic, assign) BOOL hasShowGuessULikeBadge;

@end
@implementation HomePageSegmentedHeaderView
+ (instancetype)createSegmentedView {
    HomePageSegmentedHeaderView * seg = [[HomePageSegmentedHeaderView alloc] init];
    seg.size = CGSizeMake(SY_SCREEN_WIDTH, 40);
    [seg setupViews];
    return seg;
}

- (void)setupViews {
    self.backgroundColor = [UIColor whiteColor];
    self.layer.masksToBounds = YES;
    [self addSubview:self.collectionView];
    [self.collectionView addSubview:self.selectView];
    [self addSubview:self.allView];
    if (shouldShowGray()) {
    }else{
        [self addBottomSeparatorLine];
    }
    [self setupLayouts];
}
- (void)setupLayouts {
    __weak UIView * superView = self;
    __weak UIView * allLabel = self.allView;
    [allLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.centerY.equalTo(superView);
    }];
    [superView updateConstraintsIfNeeded];
}
#pragma mark - func
- (void)setDataList:(NSArray *)dataList {
    _dataList = dataList;
    self.doctorSayCenter = CGPointZero;
    self.needReloadData = YES;
    
}
- (BOOL)isEqual:(NSArray *)cateList otherCateList:(NSArray *)otherCateList {
    if (cateList.count != otherCateList.count) {
        return NO;
    }
    for (NSInteger i = 0; i < cateList.count; i++) {
        SYHomePageRecommendTabModel * model1 = cateList[i];
        SYHomePageRecommendTabModel * model2 = otherCateList[i];
        if ([model1 isEqual:model2]) {
            continue;
        } else {
            return NO;
        }
    }
    return YES;
}
- (void)setNeedReloadData {
    self.needReloadData = YES;
}
- (void)reloadDataIfNeeded {
    [self reloadDataIfNeeded:YES];
}
- (void)reloadDataIfNeeded:(BOOL)resetIndex {
    if (self.needReloadData) {
        [self reloadData:resetIndex];
        self.needReloadData = NO;
    }
}

- (void)updateWithCurIndex:(NSInteger)curIndex animated:(BOOL)animated {
    [self collectionView:self.collectionView didSelectItemAtIndexPath:[NSIndexPath indexPathForRow:curIndex inSection:0]];
    self.curIndex = curIndex;
    [self reloadView:animated];
}

//首页轻量化 猜你喜欢小红点
- (void)updateGuessULikeBadgeIfNeeded{
    
    if (!shouldShowGray()) {
        return;
    }
    if (!self.dataList || self.dataList.count <= 1) {
        return;
    }
    SYHomePageRecommendTabModel *model = self.dataList[1];
    if (![model.name isEqualToString:@"猜你喜欢"]) {
        //当用户退出后  小红点要消失
        [self.guessULikeBadgeView removeFromSuperview];
        //切换登录退出  小红点如果还要显示 
        self.hasShowGuessULikeBadge = NO;
        return;
    }
    if (self.hasShowGuessULikeBadge) {
        return;
    }
    [self.collectionView addSubview:self.guessULikeBadgeView];
    UICollectionViewCell * cell = [self collectionView:self.collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:0] isReloadView:YES];
    CGFloat textHeight = [@"猜你喜欢" cdf_sizeWithFont:[UIFont sy_pingFangTCSemiboldFontOfSize:16] constrainedToSize:CGSizeMake(MAXFLOAT, MAXFLOAT)].height;
    CGFloat textY = (self.size.height - textHeight)/2;
    self.guessULikeBadgeView.frame = CGRectMake(cell.x+cell.width, textY - 3.5, 7, 7);
    self.hasShowGuessULikeBadge = YES;
}

#pragma mark - target
- (void)allClicked:(UITapGestureRecognizer *)tap {
    if (self.delegate
        && [self.delegate respondsToSelector:@selector(homePageSegmentedHeaderViewToAllDiaryList:)]) {
        [self.delegate homePageSegmentedHeaderViewToAllDiaryList:self];
    }
}
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    scrollView.lastOffsetX = scrollView.contentOffsetX;
}
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    if (scrollView.contentOffsetX > scrollView.lastOffsetX) {
        //右滑
        [self loadRequestH5FromActionValue:@"home.classification.tab.leftslide"];
    } else if (scrollView.contentOffsetX < scrollView.lastOffsetX){
        //左滑
        [self loadRequestH5FromActionValue:@"home.classification.tab.rightslide"];
    }
    scrollView.lastOffsetX = 0;
}
- (void)segmentedView:(SYSegmentedView *)segmentedView segDidSelectAtIndex:(NSInteger)index {
    if (self.delegate
        && [self.delegate respondsToSelector:@selector(homePageSegmentedHeaderView:tabDidSelect:atIndex:)]) {
        [self.delegate homePageSegmentedHeaderView:self tabDidSelect:[self.dataList cdf_safeObjectAtIndex:index] atIndex:index];
    }
}



#pragma mark - delegate
- (void)reloadData:(BOOL)resetIndex {
    if (resetIndex) {
        self.collectionView.contentOffsetX = 0;//初始化
        self.curIndex = 0;
        self.selectFrame = CGRectZero;
    }
    [self.collectionView reloadData];
    [self.collectionView bringSubviewToFront:self.selectView];
}
- (void)reloadView:(BOOL)animated {
    if (shouldShowGray()) {
        self.selectView.y = 28;
    }else{
        self.selectView.y = self.collectionView.height - self.selectView.height - kOnePixel;
    }
    CGRect selectedCellFrame;
    UICollectionViewCell * cell = [self collectionView:self.collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForRow:self.curIndex inSection:0] isReloadView:YES];
    CGRect frame = cell.frame;
    //frame.origin.x += 25 / 2;
    //frame.size.width -= 25;
    if (cell) {
        self.selectFrame = frame;
    }
    selectedCellFrame = self.selectFrame;
    CGPoint contentoffSet = selectedCellFrame.origin;
    contentoffSet.x -= (self.collectionView.width - selectedCellFrame.size.width) / 2;
    if (contentoffSet.x < 0) {
        
        
        contentoffSet.x = 0;
    } else if (contentoffSet.x > self.collectionView.contentSize.width - self.collectionView.width) {
        if (self.collectionView.contentSize.width > self.collectionView.width) {
            
            contentoffSet.x = self.collectionView.contentSize.width - self.collectionView.width;
        } else {
            contentoffSet.x = 0;
        }
    }
    if (animated) {
        WEAKSELF
        [UIView animateWithDuration:0.3 animations:^{
            weakSelf.selectView.x = selectedCellFrame.origin.x;
            weakSelf.selectView.width = selectedCellFrame.size.width;
        }];
    } else {
        self.selectView.x = selectedCellFrame.origin.x;
        self.selectView.width = selectedCellFrame.size.width;
    }
    [self.collectionView setContentOffset:contentoffSet animated:animated];
    
    //点击其他item 导致猜你喜欢移动 小红点跟随
    if (self.dataList && self.dataList.count >1) {
        
        UICollectionViewCell * guessCell = [self collectionView:self.collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:0] isReloadView:YES];
        self.guessULikeBadgeView.x = guessCell.x + guessCell.width;
    }
}

- (CGFloat)widthWithTitleAtIndex:(NSInteger)index {
    SYHomePageRecommendTabModel * model = [self.dataList cdf_safeObjectAtIndex:index];
    CGFloat titleLabelWidth;
    if (model.name.length) {
        if (shouldShowGray()) {
            if (index == self.curIndex) {
                
                titleLabelWidth = [model.name cdf_sizeWithFont:[UIFont sy_pingFangTCSemiboldFontOfSize:20] constrainedToSize:CGSizeMake(MAXFLOAT, MAXFLOAT)].width;
            }else{
                
                titleLabelWidth = [model.name cdf_sizeWithFont:[UIFont sy_pingFangTCSemiboldFontOfSize:16] constrainedToSize:CGSizeMake(MAXFLOAT, MAXFLOAT)].width;
            }
        }else{
            self.testLabel.text = model.name;
            [self.testLabel sizeToFit];
            titleLabelWidth = self.testLabel.width;
        }
    } else {
        titleLabelWidth = 0;
    }
    return titleLabelWidth;
}
#pragma mark - delegate
- (NSInteger)collectionView:(UICollectionView *)collectionView
     numberOfItemsInSection:(NSInteger)section {
    return self.dataList.count;
}
- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView
                        layout:(UICollectionViewLayout *)collectionViewLayout
        insetForSectionAtIndex:(NSInteger)section {
    if (shouldShowGray()) {
        return UIEdgeInsetsMake(0, 17, 0, 17);
    }else{
        return UIEdgeInsetsMake(0, 12.5, 0, 12.5);
    }
}

- (CGSize)collectionView:(UICollectionView *)collectionView
                  layout:(UICollectionViewLayout *)collectionViewLayout
  sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    CGFloat titleLabelWidth = [self widthWithTitleAtIndex:indexPath.row];
    titleLabelWidth = titleLabelWidth < 30 ? 30 : titleLabelWidth;
    //titleLabelWidth += 25;
    return CGSizeMake(titleLabelWidth, collectionView.height);
}
- (CGFloat)collectionView:(UICollectionView *)collectionView
                   layout:(UICollectionViewLayout *)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
    if (shouldShowGray()) {
        return 20;
    }else{
        return 25;
    }
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView
                  cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    return [self collectionView:collectionView cellForItemAtIndexPath:indexPath isReloadView:NO];
}
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath isReloadView:(BOOL)isReloadView {
    UICollectionViewCell * cell = [collectionView dequeueReusableCellWithReuseIdentifier:[[SegmentedCollectionViewCell class] description] forIndexPath:indexPath];
    if (IS_IOS8_LATTER == NO
        && isReloadView == NO) {
        [self collectionView:collectionView willDisplayCell:cell forItemAtIndexPath:indexPath];
    }
    return cell;
}
- (void)collectionView:(UICollectionView *)collectionView willDisplayCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath {
    SegmentedCollectionViewCell * titleCell = (SegmentedCollectionViewCell *)cell;
    SYHomePageRecommendTabModel * model = [self.dataList cdf_safeObjectAtIndex:indexPath.row];
    titleCell.titleLabel.text = model.name;
    if (model.isDoctorSayModel) {
        self.doctorSayCenter = titleCell.center;
    }
    BOOL bol = indexPath.row == self.curIndex;
//    if (indexPath.row == self.dataList.count - 1) {
//        titleCell.separatorView.hidden = YES;
//    } else {
//        titleCell.separatorView.hidden = NO;
//    }
    titleCell.selected = bol;
    if (model.showBadge) {
        [titleCell.titleLabel sy_addBadge:CGPointMake(0.5, 6.25)];
    } else {
        [titleCell.titleLabel sy_removeBadge];
    }
    if (bol
        && !collectionView.isDragging &&
        !collectionView.isDecelerating) {
        CGRect frame = titleCell.frame;
        //frame.origin.x += 25 / 2;
        //frame.size.width -= 25;
        self.selectFrame = frame;
        if (shouldShowGray()) {
        }else{//保留迷一样的坑爹老代码
            [self reloadView:NO];
        }
    }
}
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    
    if (shouldShowGray()) {
        
        if (self.hasShowGuessULikeBadge && indexPath.row == 1) {//移除猜你喜欢红点
            [self.guessULikeBadgeView removeFromSuperview];
        }
        
        NSInteger lastCurIndex = self.curIndex;
        self.curIndex = indexPath.row;
        [self.collectionView reloadData];//刷新size
        UICollectionViewCell * newSelectedCell = [collectionView cellForItemAtIndexPath:indexPath];
        self.selectFrame = newSelectedCell.frame;;
        [self reloadView:YES];

        SYHomePageRecommendTabModel * model = [self.dataList cdf_safeObjectAtIndex:indexPath.row];
        if (lastCurIndex != indexPath.row) {
            if (self.delegate
                && [self.delegate respondsToSelector:@selector(homePageSegmentedHeaderView:tabDidSelect:atIndex:)]) {
                [self.delegate homePageSegmentedHeaderView:self tabDidSelect:model atIndex:indexPath.row];
            }
        }
    }else{//旧逻辑
        
        NSInteger lastCurIndex = self.curIndex;
        //    if (self.curIndex == indexPath.row) {
        //        return;
        //    }
        SYHomePageRecommendTabModel * model = [self.dataList cdf_safeObjectAtIndex:indexPath.row];
        NSIndexPath * oldSelectedIndexPath = [NSIndexPath indexPathForRow:self.curIndex inSection:0];
        UICollectionViewCell * oldSelectedCell = [collectionView cellForItemAtIndexPath:oldSelectedIndexPath];
        oldSelectedCell.selected = NO;
        
        UICollectionViewCell * newSelectedCell = [collectionView cellForItemAtIndexPath:indexPath];
        newSelectedCell.selected = YES;
        self.curIndex = indexPath.row;
        CGRect frame = newSelectedCell.frame;
        //frame.origin.x += 25 / 2;
        //frame.size.width -= 25;
        self.selectFrame = frame;
        [self reloadView:YES];
        if (lastCurIndex != indexPath.row) {
            if (self.delegate
                && [self.delegate respondsToSelector:@selector(homePageSegmentedHeaderView:tabDidSelect:atIndex:)]) {
                [self.delegate homePageSegmentedHeaderView:self tabDidSelect:model atIndex:indexPath.row];
            }
        }
    }
}




#pragma mark - setter
- (void)setContentOffset:(CGPoint)contentOffset {
    [self setContentOffset:contentOffset
                  animated:NO
                completion:nil];
}
- (void)setContentOffset:(CGPoint)contentOffset
                animated:(BOOL)animated
              completion:(void (^)(void))completion {
    if (animated) {
        WEAKSELF
        [UIView animateWithDuration:0.5 animations:^{
            weakSelf.collectionView.contentOffset = contentOffset;
        } completion:^(BOOL finished) {
            if (completion) {
                completion();
            }
        }];
    } else {
        self.collectionView.contentOffset = contentOffset;
        if (completion) {
            completion();
        }
    }
}
- (CGPoint)contentOffset {
    return self.collectionView.contentOffset;
}
#pragma mark - getter
- (SYHomePageRecommendTabModel *)curSelectModel {
    return [self.dataList cdf_safeObjectAtIndex:self.curIndex];
}
- (UIImageView *)allView
{
    if (_allView == nil) {
        NSString *iconmame = nil;
        if (shouldShowGray()) {
            iconmame = @"icon_home_all_gray";
        } else {
            iconmame = @"icon_home_all";
        }
        _allView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:iconmame]];
        _allView.userInteractionEnabled = YES;
        [_allView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(allClicked:)]];
    }
    return _allView;
}

- (UICollectionView *)collectionView {
    if (_collectionView == nil) {
        UICollectionViewFlowLayout * flowLayout = [[UICollectionViewFlowLayout alloc] init];
        flowLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        _collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, SY_SCREEN_WIDTH - self.allView.width + self.allView.height / 2, 40) collectionViewLayout:flowLayout];
        _collectionView.showsVerticalScrollIndicator = NO;
        _collectionView.showsHorizontalScrollIndicator = NO;
        _collectionView.delegate = self;
        _collectionView.dataSource = self;
        _collectionView.scrollsToTop = NO;
        _collectionView.backgroundColor = self.backgroundColor;
        [_collectionView registerClass:[SegmentedCollectionViewCell class] forCellWithReuseIdentifier:[[SegmentedCollectionViewCell class] description]];
    }
    return _collectionView;
}
- (SYGradientView *)selectView {
    if (_selectView == nil) {
        _selectView = [[SYGradientView alloc] init];
        if (shouldShowGray()) {
            _selectView.startColor = [UIColor cdf_colorWithHexString:@"#3ED9D7"];
            _selectView.endColor = [UIColor cdf_colorWithHexString:@"#0FD3B3"];
            _selectView.gradientViewType = EGradientViewTypeHorizontal;
            _selectView.height = 3;
            _selectView.layer.cornerRadius = 1.5;
            _selectView.layer.masksToBounds = YES;
        }else{
            _selectView.backgroundColor = [UIColor sy_green4Color];
            _selectView.height = 2;
            _selectView.layer.masksToBounds = YES;
            _selectView.layer.cornerRadius = 2;
        }
        _selectView.y = 40 - 2 - kOnePixel;
    }
    return _selectView;
}
- (UILabel *)testLabel {
    if (_testLabel == nil) {
        _testLabel = [[UILabel alloc] init];
        _testLabel.useCustomFont = YES;
        _testLabel.font = [UIFont sy_pingFangSCRegularFontOfSize:14];
    }
    return _testLabel;
}
// 猜你喜欢小红点
- (UIView *)guessULikeBadgeView{
    if (_guessULikeBadgeView == nil) {
        _guessULikeBadgeView = [[UIView alloc]init];
        _guessULikeBadgeView.backgroundColor = [UIColor cdf_colorWithHexString:@"#FC5D7B"];
        _guessULikeBadgeView.layer.cornerRadius = 3.5;
        _guessULikeBadgeView.layer.masksToBounds = YES;
    }
    return _guessULikeBadgeView;
}
@end
