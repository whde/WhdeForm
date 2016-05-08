//
//  ViewController.m
//  WhdeFormDemo
//
//  Created by whde on 16/5/4.
//  Copyright © 2016年 whde. All rights reserved.
//

#import "ViewController.h"
#import "FormScrollView.h"
@interface ViewController ()<FDelegate, FDataSource> {
    NSArray *_data;
}

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.edgesForExtendedLayout = UIRectEdgeNone;
    self.view.autoresizingMask = UIViewAutoresizingNone;
    FormScrollView *table = [[FormScrollView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height-64)];
    table.contentInset = UIEdgeInsetsMake(0, 0, 0, 0);
    table.fDelegate = self;
    table.fDataSource = self;
    [self.view addSubview:table];
    
    _data = [NSArray arrayWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"datas" ofType:@"plist"]];
    [table reloadData];
}
- (FTopLeftHeaderView *)topLeftHeadViewForForm:(FormScrollView *)formScrollView {
    FTopLeftHeaderView *view = [formScrollView dequeueReusableTopLeftView];
    if (view == NULL) {
        view = [[FTopLeftHeaderView alloc] initWithSectionTitle:@"行数" columnTitle:@"列数"];
    }
    return view;
}

- (NSInteger)numberOfSection:(FormScrollView *)formScrollView {
    return _data.count;
}
- (NSInteger)numberOfColumn:(FormScrollView *)formScrollView {
    return 100;
}
- (CGFloat)heightForSection:(FormScrollView *)formScrollView {
    return 44;
}
- (CGFloat)widthForColumn:(FormScrollView *)formScrollView {
    return 80;
}
- (FormSectionHeaderView *)form:(FormScrollView *)formScrollView sectionHeaderAtSection:(NSInteger)section {
    FormSectionHeaderView *header = [formScrollView dequeueReusableSectionWithIdentifier:@"Section"];
    if (header == NULL) {
        header = [[FormSectionHeaderView alloc] initWithIdentifier:@"Section"];
    }
    [header setTitle:[NSString stringWithFormat:@"第%ld行", (long)section] forState:UIControlStateNormal];
    [header setBackgroundColor:[UIColor redColor]];
    [header setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    return header;
}
- (FormColumnHeaderView *)form:(FormScrollView *)formScrollView columnHeaderAtColumn:(NSInteger)column {
    FormColumnHeaderView *header = [formScrollView dequeueReusableColumnWithIdentifier:@"Column"];
    if (header == NULL) {
        header = [[FormColumnHeaderView alloc] initWithIdentifier:@"Column"];
    }
    [header setTitle:[NSString stringWithFormat:@"第%ld列", (long)column] forState:UIControlStateNormal];
    [header setBackgroundColor:[UIColor greenColor]];
    [header setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    return header;
}
- (FormCell *)form:(FormScrollView *)formScrollView cellForColumnAtIndexPath:(FIndexPath *)indexPath {
    FormCell *cell = [formScrollView dequeueReusableCellWithIdentifier:@"Cell"];
    NSLog(@"%@", cell);
    if (cell == NULL) {
        cell = [[FormCell alloc] initWithIdentifier:@"Cell"];
        static int i=0;
        i++;
        NSLog(@"%d--%ld", i, (long)indexPath.section);
    }
    NSDictionary *dic = [_data objectAtIndex:indexPath.section];
    [cell setTitle:dic[@"name"] forState:UIControlStateNormal];
    [cell setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    /*[cell setBackgroundColor:[UIColor yellowColor]];*/
    return cell;
}
- (void)form:(FormScrollView *)formScrollView didSelectSectionAtIndex:(NSInteger)section {
    NSLog(@"Click Section At Index:%ld", (long)section);
}
- (void)form:(FormScrollView *)formScrollView didSelectColumnAtIndex:(NSInteger)column {
    NSLog(@"Click Cloumn At Index:%ld", (long)column);
}
- (void)form:(FormScrollView *)formScrollView didSelectCellAtIndexPath:(FIndexPath *)indexPath {
    NSLog(@"Click Cell At IndexPath:%ld,%ld", (long)indexPath.section, (long)indexPath.column);
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
