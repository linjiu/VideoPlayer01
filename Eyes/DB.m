//
//  DB.m
//  Eyes
//
//  Created by apple on 15/10/30.
//  Copyright © 2015年 apple. All rights reserved.
//
#import "DB.h"
#import <sqlite3.h>

static sqlite3 *db = nil;

@implementation DB

+ (sqlite3 *)open{
    if (db) {
        return db;
    }
    //获取沙盒路径
    NSString *doc = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    NSString *sqlPath = [doc stringByAppendingPathComponent:@"download.sqlite"];
    NSFileManager *fm = [NSFileManager defaultManager];
    //如果指定路径下没有文件
    if (![fm fileExistsAtPath:sqlPath]) {
        NSString *bundlePath = [[NSBundle mainBundle] pathForResource:@"download" ofType:@"sqlite"];
        //我们从bundle中copy过去
        [fm copyItemAtPath:bundlePath toPath:sqlPath error:nil];
    }
    sqlite3_open([sqlPath UTF8String], &db);
    return db;
}

+ (void)close{
    sqlite3 *db = [DB open];
    sqlite3_close(db);
    db = nil;
}

// 返回所有下载完成的TodayModel
+ (NSArray *)allDownloadComplated{
    sqlite3 *db = [DB open];
    sqlite3_stmt *stmt = nil;
    int result = sqlite3_prepare_v2(db, "select * from downloadComplated order by time desc", -1, &stmt, nil);
    // 创建一个数组，用来保存model
    NSMutableArray *array = nil;
    if (result == SQLITE_OK) {
        // 如果数据库语句执行成功，初始化array
        array = [NSMutableArray array];
        while (sqlite3_step(stmt) == SQLITE_ROW) {
            const unsigned char *cCategory = sqlite3_column_text(stmt, 0);
            NSString *category = [NSString stringWithUTF8String:(const char *)cCategory];
            
            const unsigned char *cCoverBlurred = sqlite3_column_text(stmt, 1);
            NSString *coverBlurred = [NSString stringWithUTF8String:(const char *)cCoverBlurred];
            
            const unsigned char *cCoverForDetail = sqlite3_column_text(stmt, 2);
            NSString *coverForDetail = [NSString stringWithUTF8String:(const char *)cCoverForDetail];
            
            double date = sqlite3_column_double(stmt, 3);
            
            const unsigned char *cMyDescription = sqlite3_column_text(stmt, 4);
            NSString *myDescription = [NSString stringWithUTF8String:(const char *)cMyDescription];
            
            int duration = sqlite3_column_int(stmt, 5);
            
            const unsigned char *cPlayUrl = sqlite3_column_text(stmt, 6);
            NSString *playUrl = [NSString stringWithUTF8String:(const char *)cPlayUrl];
            
            const unsigned char *cTitle = sqlite3_column_text(stmt, 7);
            NSString *title = [NSString stringWithUTF8String:(const char *)cTitle];
            
            const unsigned char *cWebUrl = sqlite3_column_text(stmt, 8);
            NSString *webUrl = [NSString stringWithUTF8String:(const char *)cWebUrl];
            
            const unsigned char *cSave = sqlite3_column_text(stmt, 9);
            NSString *save = [NSString stringWithUTF8String:(const char *)cSave];
            TodayModel *model = [[TodayModel alloc] init];
            NSDictionary *dic = @{@"category":category,@"coverBlurred":coverBlurred,@"coverForDetail":coverForDetail,@"date":[NSNumber numberWithDouble:date],@"myDescription":myDescription,@"duration":[NSNumber numberWithInt:duration],@"playUrl":playUrl,@"title":title,@"webUrl":webUrl,@"save":save};
            [model setValuesForKeysWithDictionary:dic];
            [array addObject:model];
            //我们模型中没有time，它只是用来做一个排序
//            int time = sqlite3_column_int(stmt, 10);
        }
    }
    //释放stmt
    sqlite3_finalize(stmt);
    return array;
}

//添加一条下载完成的数据
+ (void)insertDownloadComplated:(TodayModel *)model{
    //添加一个下载完成的数据。代表我们的正在下载是完成的了。需要把我们的正在下载删除
    [DB deleteDownloading:model.playUrl];
    
    
    sqlite3 *db = [DB open];
    //获取系统的时间，添加到数据库中，用来做排序
    int time = [[NSDate date] timeIntervalSince1970];
    NSString *sql = [NSString stringWithFormat:@"insert into downloadComplated values('%@','%@','%@',%f,'%@',%d,'%@','%@','%@','%@',%d)",model.category,model.coverBlurred,model.coverForDetail,model.date,model.myDescription,(int)model.duration,model.playUrl,model.title,model.webUrl,model.save,time];
    sqlite3_exec(db, [sql UTF8String], nil, nil, nil);
}

//根据url删除一个下载完成的数据
+ (void)deleteDownloadComplated:(NSString *)url{
    sqlite3 *db = [DB open];
    //一定要放到sql语句执行之前，如果放到后面，我的数据表已经被删除了。也就找不到数据了
    //删除沙盒中的视频
    NSFileManager *fm = [NSFileManager defaultManager];
    //拿到我们的save地址,进行删除
    TodayModel *model = [DB findDownloadComplated:url];
    [fm removeItemAtPath:model.save error:nil];
    
    NSString *sql = [NSString stringWithFormat:@"delete from downloadComplated where playUrl='%@'",url];
    sqlite3_exec(db, [sql UTF8String], nil, nil, nil);
}

//根据url找到一个下载完成的数据
+ (TodayModel *)findDownloadComplated:(NSString *)url{
    sqlite3 *db = [DB open];
    sqlite3_stmt *stmt = nil;
    NSString *sql = [NSString stringWithFormat:@"select * from downloadComplated where playUrl = '%@'",url];
    int result = sqlite3_prepare(db, [sql UTF8String], -1, &stmt, nil);
    // 创建一个数组，用来保存model
    NSMutableArray *array = nil;
    if (result == SQLITE_OK) {
        // 如果数据库语句执行成功，初始化array
        array = [NSMutableArray array];
        while (sqlite3_step(stmt) == SQLITE_ROW) {
            const unsigned char *cCategory = sqlite3_column_text(stmt, 0);
            NSString *category = [NSString stringWithUTF8String:(const char *)cCategory];
            
            const unsigned char *cCoverBlurred = sqlite3_column_text(stmt, 1);
            NSString *coverBlurred = [NSString stringWithUTF8String:(const char *)cCoverBlurred];
            
            const unsigned char *cCoverForDetail = sqlite3_column_text(stmt, 2);
            NSString *coverForDetail = [NSString stringWithUTF8String:(const char *)cCoverForDetail];
            
            double date = sqlite3_column_double(stmt, 3);
            
            const unsigned char *cMyDescription = sqlite3_column_text(stmt, 4);
            NSString *myDescription = [NSString stringWithUTF8String:(const char *)cMyDescription];
            
            int duration = sqlite3_column_int(stmt, 5);
            
            const unsigned char *cPlayUrl = sqlite3_column_text(stmt, 6);
            NSString *playUrl = [NSString stringWithUTF8String:(const char *)cPlayUrl];
            
            const unsigned char *cTitle = sqlite3_column_text(stmt, 7);
            NSString *title = [NSString stringWithUTF8String:(const char *)cTitle];
            
            const unsigned char *cWebUrl = sqlite3_column_text(stmt, 8);
            NSString *webUrl = [NSString stringWithUTF8String:(const char *)cWebUrl];
            
            const unsigned char *cSave = sqlite3_column_text(stmt, 9);
            NSString *save = [NSString stringWithUTF8String:(const char *)cSave];
            TodayModel *model = [[TodayModel alloc] init];
            NSDictionary *dic = @{@"category":category,@"coverBlurred":coverBlurred,@"coverForDetail":coverForDetail,@"date":[NSNumber numberWithDouble:date],@"myDescription":myDescription,@"duration":[NSNumber numberWithInt:duration],@"playUrl":playUrl,@"title":title,@"webUrl":webUrl,@"save":save};
            [model setValuesForKeysWithDictionary:dic];
            [array addObject:model];
            //我们模型中没有time，它只是用来做一个排序
            //            int time = sqlite3_column_int(stmt, 10);
        }
    }
    //释放stmt
    sqlite3_finalize(stmt);
    return [array lastObject];
}

//返回所有正在下载的
+ (NSArray *)allDownloading{
    //创建db
    sqlite3 *db = [DB open];
    sqlite3_stmt *stmt = nil;
    int result = sqlite3_prepare_v2(db, "select * from downloading order by time desc", -1, &stmt, nil);
    //创建array。保存查询出来的数据
    NSMutableArray *array = nil;
    if (result == SQLITE_OK) {
        //如果sql语句成功，初始化数组
        array = [NSMutableArray array];
        while (sqlite3_step(stmt) == SQLITE_ROW) {
            const unsigned char *cCategory = sqlite3_column_text(stmt, 0);
            NSString *category = [NSString stringWithUTF8String:(const char *)cCategory];
            
            const unsigned char *cCoverBlurred = sqlite3_column_text(stmt, 1);
            NSString *coverBlurred = [NSString stringWithUTF8String:(const char *)cCoverBlurred];
            
            const unsigned char *cCoverForDetail = sqlite3_column_text(stmt, 2);
            NSString *coverForDetail = [NSString stringWithUTF8String:(const char *)cCoverForDetail];
            
            double date = sqlite3_column_double(stmt, 3);
            
            const unsigned char *cMyDescription = sqlite3_column_text(stmt, 4);
            NSString *myDescription = [NSString stringWithUTF8String:(const char *)cMyDescription];
            
            int duration = sqlite3_column_int(stmt, 5);
            
            const unsigned char *cPlayUrl = sqlite3_column_text(stmt, 6);
            NSString *playUrl = [NSString stringWithUTF8String:(const char *)cPlayUrl];
            
            const unsigned char *cTitle = sqlite3_column_text(stmt, 7);
            NSString *title = [NSString stringWithUTF8String:(const char *)cTitle];
            
            const unsigned char *cWebUrl = sqlite3_column_text(stmt, 8);
            NSString *webUrl = [NSString stringWithUTF8String:(const char *)cWebUrl];
            
            int progress = sqlite3_column_int(stmt, 9);
            
            const unsigned char *cDataPath = sqlite3_column_text(stmt, 10);
            NSString *dataPath = [NSString stringWithUTF8String:(const char *)cDataPath];
            TodayModel *model = [[TodayModel alloc] init];
            NSDictionary *dic = @{@"category":category,@"coverBlurred":coverBlurred,@"coverForDetail":coverForDetail,@"date":[NSNumber numberWithDouble:date],@"myDescription":myDescription,@"duration":[NSNumber numberWithInt:duration],@"playUrl":playUrl,@"title":title,@"webUrl":webUrl,@"progress":@(progress),@"dataPath":dataPath};
            [model setValuesForKeysWithDictionary:dic];
            [array addObject:model];
            //我们模型中没有time，它只是用来做一个排序
            //            int time = sqlite3_column_int(stmt, 10);
        }
    }
    sqlite3_finalize(stmt);
    return array;
}

//插入一条正在下载的
+ (void)insertDownloading:(TodayModel *)model{
    sqlite3 *db = [DB open];
    //当前的时间
    int time = [[NSDate date] timeIntervalSince1970];
    //创建我们的sql语句
    NSString *sql = [NSString stringWithFormat:@"insert into downloading values('%@','%@','%@',%f,'%@',%d,'%@','%@','%@',%d,'%@',%d)",model.category,model.coverBlurred,model.coverForDetail,model.date,model.myDescription,(int)model.duration,model.playUrl,model.title,model.webUrl,(int)model.progress,model.dataPath,time];
    //执行我们的sql语句
    sqlite3_exec(db, [sql UTF8String], nil, nil, nil);
}

//删除一个正在下载的
+ (void)deleteDownloading:(NSString *)url{
    sqlite3 *db = [DB open];
    //做的是一个下载完成的删除。下载一半的删除没有做
    TodayModel *model = [DB findDownloading:url];
    NSFileManager *fm = [NSFileManager defaultManager];
    [fm removeItemAtPath:model.dataPath error:nil];
    
    NSString *sql = [NSString stringWithFormat:@"delete from downloading where playUrl = '%@'",url];
    sqlite3_exec(db, [sql UTF8String], nil, nil, nil);
}

//查找一个正在下载的
+ (TodayModel *)findDownloading:(NSString *)url{
    sqlite3 *db = [DB open];
    sqlite3_stmt *stmt = nil;
    NSString *sql = [NSString stringWithFormat:@"select from downloading where playUrl = '%@'",url];
    int result = sqlite3_prepare(db, [sql UTF8String], -1, &stmt, nil);
    //创建一个model
    TodayModel *model = nil;
    if (result == SQLITE_OK) {
        //如果sql语句执行成功。初始化我们的model
        if (sqlite3_step(stmt) == SQLITE_ROW) {
            model = [[TodayModel alloc] init];
            const unsigned char *cCategory = sqlite3_column_text(stmt, 0);
            NSString *category = [NSString stringWithUTF8String:(const char *)cCategory];
            
            const unsigned char *cCoverBlurred = sqlite3_column_text(stmt, 1);
            NSString *coverBlurred = [NSString stringWithUTF8String:(const char *)cCoverBlurred];
            
            const unsigned char *cCoverForDetail = sqlite3_column_text(stmt, 2);
            NSString *coverForDetail = [NSString stringWithUTF8String:(const char *)cCoverForDetail];
            
            double date = sqlite3_column_double(stmt, 3);
            
            const unsigned char *cMyDescription = sqlite3_column_text(stmt, 4);
            NSString *myDescription = [NSString stringWithUTF8String:(const char *)cMyDescription];
            
            int duration = sqlite3_column_int(stmt, 5);
            
            const unsigned char *cPlayUrl = sqlite3_column_text(stmt, 6);
            NSString *playUrl = [NSString stringWithUTF8String:(const char *)cPlayUrl];
            
            const unsigned char *cTitle = sqlite3_column_text(stmt, 7);
            NSString *title = [NSString stringWithUTF8String:(const char *)cTitle];
            
            const unsigned char *cWebUrl = sqlite3_column_text(stmt, 8);
            NSString *webUrl = [NSString stringWithUTF8String:(const char *)cWebUrl];
            
            int progress = sqlite3_column_int(stmt, 9);
            
            const unsigned char *cDataPath = sqlite3_column_text(stmt, 10);
            NSString *dataPath = [NSString stringWithUTF8String:(const char *)cDataPath];
            NSDictionary *dic = @{@"category":category,@"coverBlurred":coverBlurred,@"coverForDetail":coverForDetail,@"date":[NSNumber numberWithDouble:date],@"myDescription":myDescription,@"duration":[NSNumber numberWithInt:duration],@"playUrl":playUrl,@"title":title,@"webUrl":webUrl,@"progress":@(progress),@"dataPath":dataPath};
            [model setValuesForKeysWithDictionary:dic];
        }
    }
    sqlite3_finalize(stmt);
    return model;
}

//更新一个正在下载的数据
+ (void)updateDownloading:(int)proress dataPath:(NSString *)dataPath URL:(NSString *)url{
    sqlite3 *db = [DB open];
    //update 表名 set 列名称 ＝ 值 where 列名 ＝ 值
    NSString *sql = [NSString stringWithFormat:@"update downloading set progress = %d,dataPath = '%@' where playUrl = '%@'",proress,dataPath,url];
    sqlite3_exec(db, [sql UTF8String], nil, nil, nil);
}

@end
