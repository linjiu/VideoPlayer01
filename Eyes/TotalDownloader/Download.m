//
//  Download.m
//  Downloader
//
//  Created by apple on 15/10/29.
//  Copyright © 2015年 apple. All rights reserved.
//

#import "Download.h"
#import "DB.h"

@interface Download ()<NSURLSessionDownloadDelegate>

@property (copy, nonatomic) Complted complted;
@property (copy, nonatomic) Downloading downloading;
@property (strong, nonatomic) NSURLSessionDownloadTask *task;//暂停下载，和继续下载
@property (strong, nonatomic) NSURLSession *session;//根据session生成一个task
@property (strong, nonatomic) NSMutableData *data;//保存断点下载的数据

@end


@implementation Download

- (void)dealloc{
    //代理滞空
    _delegate = nil;
}

- (instancetype)initWithURL:(NSString *)url
{
    self = [super init];
    if (self) {
        //初始化的时候对url赋值，让外界可以去调用
        _url = url;
        NSURLSessionConfiguration *cfg = [NSURLSessionConfiguration defaultSessionConfiguration];
        self.session = [NSURLSession sessionWithConfiguration:cfg delegate:self delegateQueue:[NSOperationQueue mainQueue]];
        self.task = [self.session downloadTaskWithURL:[NSURL URLWithString:url]];
    }
    return self;
}

//下载开始
- (void)start{
    [self.task resume];
}

#pragma mark 下载完成的一个协议
- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask
didFinishDownloadingToURL:(NSURL *)location{
    //获取cache的路径
    NSString *cache = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject];
    //创建文件路径,拿到服务器的命名，根据服务器的命名来创建
    NSString *filePath = [cache stringByAppendingPathComponent:downloadTask.response.suggestedFilename];
    //对文件进行操作
    NSFileManager *fm = [NSFileManager defaultManager];
    //移动文件.如果我们的filePath已经有文件了呢？
    [fm moveItemAtPath:location.path toPath:filePath error:nil];
    self.complted(filePath,self.url);
    
    if ([_delegate respondsToSelector:@selector(didFinishDownloadWithURL:)]) {
        [_delegate didFinishDownloadWithURL:self.url];
    }
    //和NSTimer类似，用完之后，调用这个方法，使它可以被销毁
    [session invalidateAndCancel];
}

#pragma mark 下载进度的一个协议
- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask
      didWriteData:(int64_t)bytesWritten
 totalBytesWritten:(int64_t)totalBytesWritten
totalBytesExpectedToWrite:(int64_t)totalBytesExpectedToWrite{
    //算出当前进度
    float progress = (float)totalBytesWritten / totalBytesExpectedToWrite;
    //调用block
    self.progress = progress * 100;
    self.downloading(bytesWritten,progress * 100);
}

#pragma mark 对block赋值
- (void)didFinishDownload:(Complted)complted downloading:(Downloading)downloading{
    //对block赋值
    self.complted = complted;
    self.downloading = downloading;
}

//继续,外界传进来一个data，如果没有传一个nil（如果不是退出后，进来的重新下载）
- (void)resume:(NSData *)data{
    //判断是否传过来了data
    if (data) {
        self.data = (NSMutableData *)data;
    }
    //根据之前取消的data，生成我们需要的task
    self.task = [self.session downloadTaskWithResumeData:self.data];
    //task继续下载
    [self.task resume];
    //data滞空
    self.data = nil;
}

//暂停
- (void)suspend{
    __weak typeof(self) vc = self;
    [self.task cancelByProducingResumeData:^(NSData *resumeData) {
        vc.data = (NSMutableData *)resumeData;
//        vc.task = nil;
        //更新数据库。
        NSString *doc = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
        // 做一个Hash转换. 一个字符串对应一个hash值。相同的字符串。相同的hash
        NSString *urlHash = [NSString stringWithFormat:@"%lu",[self.url hash]];
        NSString *dataPath = [doc stringByAppendingPathComponent:urlHash];
        //归档
        [NSKeyedArchiver archiveRootObject:resumeData toFile:dataPath];
        //更新数据库
        [DB updateDownloading:self.progress dataPath:dataPath URL:self.url];
    }];
}

- (NSURLSessionTaskState)state{
    return self.task.state;
}

@end
