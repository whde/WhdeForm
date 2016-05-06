//
//  FormScrollView.h
//  WhdeFormDemo
//
//  Created by whde on 16/5/4.
//  Copyright © 2016年 whde. All rights reserved.
//

#import <UIKit/UIKit.h>
@class FIndexPath;
@class FormScrollView;
@class FormColumnHeaderView;
@class FormSectionHeaderView;
@class FormCell;
@class FTopLeftHeaderView;
@protocol FDelegate <NSObject>
@optional
- (void)form:(FormScrollView *)formScrollView didSelectCellAtIndexPath:(FIndexPath *)indexPath;
- (void)form:(FormScrollView *)formScrollView didSelectSectionAtIndex:(NSInteger)section;
- (void)form:(FormScrollView *)formScrollView didSelectColumnAtIndex:(NSInteger)column;
@end
@protocol FDataSource <NSObject>
@required
- (NSInteger)numberOfSection:(FormScrollView *)formScrollView;
- (NSInteger)numberOfColumn:(FormScrollView *)formScrollView;
- (CGFloat)heightForSection:(FormScrollView *)formScrollView;
- (CGFloat)widthForColumn:(FormScrollView *)formScrollView;
- (FTopLeftHeaderView *)topLeftHeadViewForForm:(FormScrollView *)formScrollView;
- (FormSectionHeaderView *)form:(FormScrollView *)formScrollView sectionHeaderAtSection:(NSInteger)section;
- (FormColumnHeaderView *)form:(FormScrollView *)formScrollView columnHeaderAtColumn:(NSInteger)column;
- (FormCell *)form:(FormScrollView *)formScrollView cellForColumnAtIndexPath:(FIndexPath *)indexPath;
@end

@interface FormScrollView : UIScrollView
@property (nonatomic, assign) id<FDelegate>fDelegate;
@property (nonatomic, assign) id<FDataSource>fDataSource;
- (FormColumnHeaderView *)dequeueReusableColumnWithIdentifier:(NSString *)identifier;
- (FormSectionHeaderView *)dequeueReusableSectionWithIdentifier:(NSString *)identifier;
- (FormCell *)dequeueReusableCellWithIdentifier:(NSString *)identifier;
- (FTopLeftHeaderView *)dequeueReusableTopLeftView;
- (void)reloadData;

@end

//// Cell
@interface FormCell : UIButton
@property (nonatomic, copy, readonly) NSString *identifier;
@property (nonatomic, copy, readonly) FIndexPath *indexPath;
- (instancetype)initWithIdentifier:(NSString *)identifier;
- (void)setIndexPath:(FIndexPath *)indexPath;
@end

//// FormColumnHeaderView
@interface FormColumnHeaderView : UIButton
@property (nonatomic, copy, readonly) NSString *identifier;
@property (nonatomic, assign, readonly) NSInteger column;
- (instancetype)initWithIdentifier:(NSString *)identifier;
- (void)setColumn:(NSInteger)column;
@end

//// FormSectionHeaderView
@interface FormSectionHeaderView : UIButton
@property (nonatomic, copy, readonly) NSString *identifier;
@property (nonatomic, assign, readonly) NSInteger section;
- (instancetype)initWithIdentifier:(NSString *)identifier;
- (void)setSection:(NSInteger)section;
@end

//// FTopLeftHeaderView
@interface FTopLeftHeaderView : UIView
@property (nonatomic, copy, readonly) NSString *sectionTitle;
@property (nonatomic, copy, readonly) NSString *columnTitle;
- (instancetype)initWithSectionTitle:(NSString *)sectionTitle columnTitle:(NSString *)columnTitle;
@end

//// IndexPath
@interface FIndexPath : NSObject
+ (instancetype)indexPathForSection:(NSInteger)section inColumn:(NSInteger)column;
@property (nonatomic, assign) NSInteger section;
@property (nonatomic, assign) NSInteger column;
@end
