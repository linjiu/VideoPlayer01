//
//  DownloadCell.h
//  Eyes
//
//  Created by apple on 15/10/29.
//  Copyright © 2015年 apple. All rights reserved.
//

#import "TodayViewCell.h"

typedef void(^DownloadComplated)(NSIndexPath *indePath);
typedef void(^DeleteDownload)(NSIndexPath *indexPath);

@interface DownloadCell : TodayViewCell

@property (strong, nonatomic) NSIndexPath *indexPath;

// 下载完成的block方法和删除的block
- (void)downloadComplated:(DownloadComplated)complated delete:(DeleteDownload)deleteDownload;

@end
