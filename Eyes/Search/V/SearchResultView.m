//
//  SearchResultView.m
//  音乐播放模块
//
//  Created by apple on 15/11/2.
//  Copyright © 2015年 apple. All rights reserved.
//

#import "SearchResultView.h"
#import "VideoModel.h"
#import "UIImageView+WebCache.h"
#import "UIColor+AddColor.h"
@interface SearchResultView ()<UITableViewDataSource>

@end
@implementation SearchResultView

-(instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        self.tableV = [[UITableView alloc]initWithFrame:(CGRectMake(0, 0, frame.size.width, frame.size.height)) style:(UITableViewStylePlain)];
        self.tableV.dataSource = self;
        self.tableV.showsVerticalScrollIndicator = NO;
        [self addSubview:self.tableV];
        UIView *view = [[UIView alloc]initWithFrame:(CGRectZero)];
        self.tableV.tableFooterView = view;
        self.tableV.backgroundColor = [UIColor clearColor];
        self.tableV.rowHeight = 120;
        
    }
    return self;
    
}
-(void)setArr:(NSMutableArray *)arr
{
    _arr = arr;
    [self.tableV reloadData];
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.arr.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *reuseIdentifier = @"searchCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc]initWithStyle:(UITableViewCellStyleSubtitle) reuseIdentifier:reuseIdentifier];
    }
    VideoModel *model = self.arr[indexPath.row];
    cell.textLabel.text = model.restitle;
    [cell.imageView sd_setImageWithURL:[NSURL URLWithString:model.imgUrl]];
    cell.backgroundColor = [UIColor clearColor];
    return cell;
}



@end
