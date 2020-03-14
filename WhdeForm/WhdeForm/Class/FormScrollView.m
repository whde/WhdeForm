//
//  FormScrollView.m
//  WhdeFormDemo
//
//  Created by whde on 16/5/4.
//  Copyright © 2016年 whde. All rights reserved.
//

#import "FormScrollView.h"
@interface FormScrollView () {
    NSMutableArray *_reusableSectionsHeaders;
    NSMutableArray *_reusableColumnHeaders;
    NSMutableArray *_reusableCells;
    NSMutableArray *_reusableTopLeftHeaders;
    
    NSInteger _numberSection;
    NSInteger _numberColumn;
    
    CGFloat _width;
    CGFloat _height;
    
    FIndexPath *_firstIndexPath;
    FIndexPath *_maxIndexPath;
    FTopLeftHeaderView *_topLeftView;
}
@end
@implementation FormScrollView
////instance
- (id)init {
    return [self initWithFrame:CGRectZero];
}

- (id)initWithFrame:(CGRect)frame  {
    if ((self = [super initWithFrame:frame])) {
        [self commonInit];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    if ((self = [super initWithCoder:aDecoder])) {
        [self commonInit];
    }
    
    return self;
}
- (void)commonInit {
    _reusableColumnHeaders = [[NSMutableArray alloc] init];
    _reusableSectionsHeaders    = [[NSMutableArray alloc] init];
    _reusableCells   = [[NSMutableArray alloc] init];
    _reusableTopLeftHeaders = [[NSMutableArray alloc] init];
    _firstIndexPath = [FIndexPath indexPathForSection:-1 inColumn:-1];
    _maxIndexPath = [FIndexPath indexPathForSection:-1 inColumn:-1];
    self.bounces = NO;
}

////deq
- (FormColumnHeaderView *)dequeueReusableColumnWithIdentifier:(NSString *)identifier {
    FormColumnHeaderView *columnHeader = nil;
    for (FormColumnHeaderView *reusableHeader in _reusableColumnHeaders) {
        if ([reusableHeader.identifier isEqualToString:identifier]) {
            columnHeader = reusableHeader;
            break;
        }
    }
    if (columnHeader) {
        [_reusableColumnHeaders removeObject:columnHeader];
    }
    return columnHeader;
}
- (FormSectionHeaderView *)dequeueReusableSectionWithIdentifier:(NSString *)identifier {
    FormSectionHeaderView *sectionHeader = nil;
    for (FormSectionHeaderView *reusableSection in _reusableSectionsHeaders) {
        if ([reusableSection.identifier isEqualToString:identifier]) {
            sectionHeader = reusableSection;
            break;
        }
    }
    
    if (sectionHeader) {
        [_reusableSectionsHeaders removeObject:sectionHeader];
    }
    return sectionHeader;
}
- (FormCell *)dequeueReusableCellWithIdentifier:(NSString *)identifier {
    FormCell *cell = nil;
    for (FormCell *reusableCell in _reusableCells) {
        if ([reusableCell.identifier isEqualToString:identifier]) {
            cell = reusableCell;
            break;
        }
    }
    if (cell) {
        [_reusableCells removeObject:cell];
    }
    return cell;
}
- (FTopLeftHeaderView *)dequeueReusableTopLeftView {
    FTopLeftHeaderView *header = nil;
    for (FTopLeftHeaderView *reusableheader in _reusableTopLeftHeaders) {
        header = reusableheader;
        break;
    }
    if (header) {
        [_reusableTopLeftHeaders removeObject:header];
    }
    return header;
}

/////que
- (void)queueReusableCell:(FormCell *)cell {
    if (cell) {
        cell.indexPath = nil;
        [cell removeTarget:self action:@selector(cellClickAction:) forControlEvents:UIControlEventTouchUpInside];
        [_reusableCells addObject:cell];
    }
}
- (void)queueReusableColumnHeader:(FormColumnHeaderView *)columnHeader {
    if (columnHeader) {
        [columnHeader setColumn:-1];
        [columnHeader removeTarget:self action:@selector(columnClickAction:) forControlEvents:UIControlEventTouchUpInside];
        [_reusableColumnHeaders addObject:columnHeader];
    }
}
- (void)queueReusableSectionHeader:(FormSectionHeaderView *)sectionHeader {
    if (sectionHeader){
        [sectionHeader setSection:-1];
        [sectionHeader removeTarget:self action:@selector(sectionClickAction:) forControlEvents:UIControlEventTouchUpInside];
        [_reusableSectionsHeaders addObject:sectionHeader];
    }
}
- (void)queueReusableTopLeftHeader:(FTopLeftHeaderView *)topLeftView {
    if (topLeftView) {
        [_reusableTopLeftHeaders addObject:topLeftView];
    }
}


////LoadView
- (void)reloadData {
    if (!_fDataSource) {
#if DEBUG
        NSLog(@"!!!!!!FormScrollView's fDataSource not set!!!!!!");
#endif
        return;
    }
    [[self subviews] enumerateObjectsUsingBlock:^(id obj, NSUInteger index, BOOL *stop) {
         if ([obj isKindOfClass:[FormColumnHeaderView class]]) {
             [self queueReusableColumnHeader:(FormColumnHeaderView *)obj];
             [(UIView *)obj removeFromSuperview];
         } else if ([obj isKindOfClass:[FormSectionHeaderView class]]) {
             [self queueReusableSectionHeader:(FormSectionHeaderView *)obj];
             [(UIView *)obj removeFromSuperview];
         } else if ([obj isKindOfClass:[FormCell class]]) {
             [self queueReusableCell:(FormCell *)obj];
             [(UIView *)obj removeFromSuperview];
         } else if ([obj isKindOfClass:[FTopLeftHeaderView class]]){
             [self queueReusableTopLeftHeader:(FTopLeftHeaderView *)obj];
             [(UIView *)obj removeFromSuperview];
         } else {
             [(UIView *)obj removeFromSuperview];
         }
     }];
    
    NSInteger numberSection = [_fDataSource numberOfSection:self];
    _numberSection = numberSection;
    NSInteger numberColumn = [_fDataSource numberOfColumn:self];
    _numberColumn = numberColumn;
    _width = [_fDataSource widthForColumn:self];
    _height = [_fDataSource heightForSection:self];
    self.contentSize = CGSizeMake((_numberColumn+1)*_width, (_numberSection+1)*_height);
    
    _topLeftView = [_fDataSource topLeftHeadViewForForm:self];
    [self setNeedsLayout];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    [self cleanupUnseenItems];
    [self loadseenItems];
}

- (void)loadseenItems {
    if (!_topLeftView.superview) {
        _topLeftView.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, _width, _height);
        [self.superview addSubview:_topLeftView];
    }
    for (NSInteger section=0; section<_numberSection; section++) {
        if (section*_height>self.contentOffset.y+self.frame.size.height
            || (section+1)*_height<self.contentOffset.y) {
            continue;
        }
        for (NSInteger column=0; column<_numberColumn; column++) {
            if (column*_width>self.contentOffset.x+self.frame.size.width
                || (column+1)*_width<self.contentOffset.x) {
                continue;
            }
            if (column>=_firstIndexPath.column
                &&column<=_maxIndexPath.column
                &&section>=_firstIndexPath.section
                &&section<=_maxIndexPath.section) {
                continue;
            }
            CGRect rect = CGRectMake((column+1)*_width, (section+1)*_height, _width, _height);
            if ([self isOnScreenRect:rect]) {
                FIndexPath *indexPath = [FIndexPath indexPathForSection:section inColumn:column];
                FormCell *cell = [_fDataSource form:self cellForColumnAtIndexPath:indexPath];
                [cell addTarget:self action:@selector(cellClickAction:) forControlEvents:UIControlEventTouchUpInside];
                cell.indexPath = indexPath;
                cell.frame = rect;
                [self insertSubview:cell atIndex:0];
            }
        }
    }
    for (NSInteger section=0; section<_numberSection; section++) {
        if (section*_height>self.contentOffset.y+self.frame.size.height
            || (section+1)*_height<self.contentOffset.y) {
            continue;
        }
        if (section>=_firstIndexPath.section
            &&section<=_maxIndexPath.section) {
            continue;
        }
        CGRect rect = CGRectMake(self.contentOffset.x+self.contentInset.left, (section+1)*_height, _width, _height);
        if ([self isOnScreenRect:rect]) {
            FormSectionHeaderView *header = [_fDataSource form:self sectionHeaderAtSection:section];
            [header addTarget:self action:@selector(sectionClickAction:) forControlEvents:UIControlEventTouchUpInside];
            header.frame = rect;
            [self addSubview:header];
        }
    }
    for (NSInteger column=0; column<_numberColumn; column++) {
        if (column*_width>self.contentOffset.x+self.frame.size.width
            || (column+1)*_width<self.contentOffset.x) {
            continue;
        }
        if (column>=_firstIndexPath.column
            &&column<=_maxIndexPath.column) {
            continue;
        }
        CGRect rect = CGRectMake((column+1)*_width, self.contentOffset.y+self.contentInset.top, _width, _height);
        if ([self isOnScreenRect:rect]) {
            FormColumnHeaderView *header = [_fDataSource form:self columnHeaderAtColumn:column];
            [header addTarget:self action:@selector(columnClickAction:) forControlEvents:UIControlEventTouchUpInside];
            header.frame = rect;
            [self addSubview:header];
        }
    }
}


////Clear
- (void)cleanupUnseenItems {
    _firstIndexPath = [FIndexPath indexPathForSection:_numberSection inColumn:_numberColumn];
    _maxIndexPath = [FIndexPath indexPathForSection:0 inColumn:0];
    for (UIView *view in self.subviews) {
        if (![self isOnScreenRect:view.frame]) {
            if ([view isKindOfClass:[FormCell class]]) {
                FormCell*cell = (FormCell *)view;
                [self queueReusableCell:cell];
                [cell removeFromSuperview];
            } else if ([view isKindOfClass:[FormSectionHeaderView class]]) {
                FormSectionHeaderView*header = (FormSectionHeaderView *)view;
                header.frame = CGRectMake(self.contentOffset.x+self.contentInset.left, CGRectGetMinY(header.frame), CGRectGetWidth(header.frame), CGRectGetHeight(header.frame));
                if (![self isOnScreenRect:header.frame]) {
                    [self queueReusableSectionHeader:header];
                    [header removeFromSuperview];
                }
            } else if ([view isKindOfClass:[FormColumnHeaderView class]]) {
                FormColumnHeaderView*header = (FormColumnHeaderView *)view;
                header.frame = CGRectMake(CGRectGetMinX(header.frame), self.contentOffset.y+self.contentInset.top, CGRectGetWidth(header.frame), CGRectGetHeight(header.frame));
                if (![self isOnScreenRect:header.frame]) {
                    [self queueReusableColumnHeader:header];
                    [header removeFromSuperview];
                }
            }
        } else {
            if ([view isKindOfClass:[FormSectionHeaderView class]]) {
                FormSectionHeaderView*header = (FormSectionHeaderView *)view;
                header.frame = CGRectMake(self.contentOffset.x+self.contentInset.left, CGRectGetMinY(header.frame), CGRectGetWidth(header.frame), CGRectGetHeight(header.frame));
            } else if ([view isKindOfClass:[FormColumnHeaderView class]]) {
                FormColumnHeaderView*header = (FormColumnHeaderView *)view;
                header.frame = CGRectMake(CGRectGetMinX(header.frame), self.contentOffset.y+self.contentInset.top, CGRectGetWidth(header.frame), CGRectGetHeight(header.frame));
            } else if ([view isKindOfClass:[FormCell class]]) {
                FormCell*cell = (FormCell *)view;
                if (cell.indexPath.section<=_firstIndexPath.section && cell.indexPath.column<=_firstIndexPath.column) {
                    _firstIndexPath = [FIndexPath indexPathForSection:cell.indexPath.section inColumn:cell.indexPath.column];
                }
                if (cell.indexPath.section>=_maxIndexPath.section && cell.indexPath.column>=_maxIndexPath.column) {
                    _maxIndexPath = [FIndexPath indexPathForSection:cell.indexPath.section inColumn:cell.indexPath.column];
                }
            }
        }
    }
}
- (BOOL)isOnScreenRect:(CGRect)rect {
    return CGRectIntersectsRect(rect, CGRectMake(self.contentOffset.x, self.contentOffset.y, self.frame.size.width, self.frame.size.height));
}

- (void)cellClickAction:(FormCell *)cell {
    if (_fDelegate) {
        if ([_fDelegate respondsToSelector:@selector(form:didSelectCellAtIndexPath:)]) {
            [_fDelegate form:self didSelectCellAtIndexPath:cell.indexPath];
        }
    }
}
- (void)columnClickAction:(FormColumnHeaderView *)columnView {
    if (_fDelegate) {
        if ([_fDelegate respondsToSelector:@selector(form:didSelectColumnAtIndex:)]) {
            [_fDelegate form:self didSelectColumnAtIndex:columnView.column];
        }
    }
}
- (void)sectionClickAction:(FormSectionHeaderView *)sectionView {
    if (_fDelegate) {
        if ([_fDelegate respondsToSelector:@selector(form:didSelectSectionAtIndex:)]) {
            [_fDelegate form:self didSelectSectionAtIndex:sectionView.section];
        }
    }
}

@end

//// Cell
@interface FormCell ()
@end
@implementation FormCell
- (instancetype)initWithIdentifier:(NSString *)identifier {
    self = [super init];
    _identifier = [identifier copy];
    self.backgroundColor = UIColor.whiteColor;
    return self;
}
- (void)setIndexPath:(FIndexPath *)indexPath {
    _indexPath = indexPath;
}
- (void)drawRect:(CGRect)rect {
    [super drawRect:rect];
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetLineWidth(context, 1.0);
    CGContextSetStrokeColorWithColor(context, [UIColor blackColor].CGColor);
    CGPoint aPoints[5];
    aPoints[0] =CGPointMake(0, 0);
    aPoints[1] =CGPointMake(CGRectGetWidth(rect), 0);
    aPoints[2] =CGPointMake(CGRectGetWidth(rect), CGRectGetHeight(rect));
    aPoints[3] =CGPointMake(0, CGRectGetHeight(rect));
    aPoints[4] =CGPointMake(0, 0);
    CGContextAddLines(context, aPoints, 5);
    CGContextDrawPath(context, kCGPathStroke);
}

@end

//// FormColumnHeaderView
@interface FormColumnHeaderView ()
@end
@implementation FormColumnHeaderView
- (instancetype)initWithIdentifier:(NSString *)identifier {
    self = [super init];
    _identifier = [identifier copy];
    self.backgroundColor = UIColor.whiteColor;
    return self;
}
- (void)setColumn:(NSInteger)column {
    _column = column;
}
- (void)drawRect:(CGRect)rect {
    [super drawRect:rect];
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetLineWidth(context, 1.0);
    CGContextSetStrokeColorWithColor(context, [UIColor blackColor].CGColor);
    CGPoint aPoints[5];
    aPoints[0] =CGPointMake(0, 0);
    aPoints[1] =CGPointMake(CGRectGetWidth(rect), 0);
    aPoints[2] =CGPointMake(CGRectGetWidth(rect), CGRectGetHeight(rect));
    aPoints[3] =CGPointMake(0, CGRectGetHeight(rect));
    aPoints[4] =CGPointMake(0, 0);
    CGContextAddLines(context, aPoints, 5);
    CGContextDrawPath(context, kCGPathStroke);
}
@end

//// FormRowHeaderView
@interface FormSectionHeaderView ()
@end
@implementation FormSectionHeaderView
- (instancetype)initWithIdentifier:(NSString *)identifier {
    self = [super init];
    _identifier = [identifier copy];
    self.backgroundColor = UIColor.whiteColor;
    return self;
}
- (void)setSection:(NSInteger)section {
    _section = section;
}
- (void)drawRect:(CGRect)rect {
    [super drawRect:rect];
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetLineWidth(context, 1.0);
    CGContextSetStrokeColorWithColor(context, [UIColor blackColor].CGColor);
    CGPoint aPoints[5];
    aPoints[0] =CGPointMake(0, 0);
    aPoints[1] =CGPointMake(CGRectGetWidth(rect), 0);
    aPoints[2] =CGPointMake(CGRectGetWidth(rect), CGRectGetHeight(rect));
    aPoints[3] =CGPointMake(0, CGRectGetHeight(rect));
    aPoints[4] =CGPointMake(0, 0);
    CGContextAddLines(context, aPoints, 5);
    CGContextDrawPath(context, kCGPathStroke);
}

@end

//// FTopLeftHeaderView
@interface FTopLeftHeaderView()
@end
@implementation FTopLeftHeaderView

- (instancetype)initWithSectionTitle:(NSString *)sectionTitle columnTitle:(NSString *)columnTitle {
    self = [super init];
    _sectionTitle = sectionTitle;
    _columnTitle = columnTitle;
    return self;
}
- (void)drawRect:(CGRect)rect {
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextAddRect(context, rect);
    CGContextSetFillColorWithColor(context, [UIColor whiteColor].CGColor);
    CGContextDrawPath(context, kCGPathFill);
    CGContextStrokePath(context);
    NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
    style.alignment = NSTextAlignmentCenter;
    NSDictionary *attributrs = @{NSForegroundColorAttributeName:UIColor.blackColor, NSFontAttributeName:[UIFont systemFontOfSize:17], NSParagraphStyleAttributeName:style};
    if (_columnTitle) {
        [_columnTitle drawInRect:CGRectMake(CGRectGetWidth(rect)/2, 0, CGRectGetWidth(rect)/2, CGRectGetHeight(rect)/2) withAttributes:attributrs];
        CGContextStrokePath(context);
    }
    if (_sectionTitle) {
        [_sectionTitle drawInRect:CGRectMake(0, CGRectGetHeight(rect)/2, CGRectGetWidth(rect)/2, CGRectGetHeight(rect)/2) withAttributes:attributrs];
    }
    CGContextSetLineWidth(context, 1.0);
    CGContextSetStrokeColorWithColor(context, [UIColor blackColor].CGColor);
    CGPoint aPoints[6];
    aPoints[0] =CGPointMake(0, 0);
    aPoints[1] =CGPointMake(CGRectGetWidth(rect), 0);
    aPoints[2] =CGPointMake(CGRectGetWidth(rect), CGRectGetHeight(rect));
    aPoints[3] =CGPointMake(0, 0);
    aPoints[4] =CGPointMake(0, CGRectGetHeight(rect));
    aPoints[5] =CGPointMake(CGRectGetWidth(rect), CGRectGetHeight(rect));
    CGContextAddLines(context, aPoints, 6);
    CGContextDrawPath(context, kCGPathStroke);
}
@end


//// IndexPath
@interface FIndexPath ()
@end
@implementation FIndexPath
+ (instancetype)indexPathForSection:(NSInteger)section inColumn:(NSInteger)column {
    FIndexPath *indexPath = [[FIndexPath alloc] init];
    indexPath.section = section;
    indexPath.column = column;
    return indexPath;
}
@end
