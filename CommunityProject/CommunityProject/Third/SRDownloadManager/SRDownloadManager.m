//
//  SRDownloadManager.m
//  SRDownloadManager
//
//  Created by https://github.com/guowilling on 17/1/10.
//  Copyright © 2017年 SR. All rights reserved.
//

#import "SRDownloadManager.h"

#define SRDownloadDirectory self.saveFilesDirectory ?: [[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject] \
stringByAppendingPathComponent:NSStringFromClass([self class])]

#define SRFileName(URL) [URL lastPathComponent] // use URL's last path component as the file's name

#define SRFilePath(URL) [SRDownloadDirectory stringByAppendingPathComponent:SRFileName(URL)]

#define SRFilesTotalLengthPlistPath [SRDownloadDirectory stringByAppendingPathComponent:@"SRFilesTotalLength.plist"]
static SRDownloadManager *downloadManager;
static dispatch_once_t onceToken;
@interface SRDownloadManager() <NSURLSessionDelegate, NSURLSessionDataDelegate>

@property (nonatomic, strong) NSURLSession *urlSession;

@property (nonatomic, strong) NSMutableDictionary *downloadModelsDic; // a dictionary contains downloading and waiting models

@property (nonatomic, strong) NSMutableArray *downloadingModels; // a array contains models which are downloading now

@property (nonatomic, strong) NSMutableArray *waitingModels; // a array contains models which are waiting for download

@property (nonatomic, strong) NSMutableArray *finishModels; // a array contains models which  finish for download

@property (nonatomic,strong)NSMutableArray * suspendModels;//a array contains models which  suspend for download

@property (nonatomic,strong)NSMutableArray * errorModels;//a array contains models which  error for download

@end

@implementation SRDownloadManager

#pragma mark - Lazy Load

- (NSURLSession *)urlSession {
    
    if (!_urlSession) {
        _urlSession = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]
                                                    delegate:self
                                               delegateQueue:[[NSOperationQueue alloc] init]];
    }
    return _urlSession;
}

- (NSMutableDictionary *)downloadModelsDic {
    
    if (!_downloadModelsDic) {
        _downloadModelsDic = [NSMutableDictionary dictionary];
    }
    return _downloadModelsDic;
}

- (NSMutableArray *)downloadingModels {
    
    if (!_downloadingModels) {
        _downloadingModels = [NSMutableArray array];
    }
    return _downloadingModels;
}

- (NSMutableArray *)waitingModels {
    
    if (!_waitingModels) {
        _waitingModels = [NSMutableArray array];
    }
    return _waitingModels;
}
-(NSMutableArray *)finishModels{
    if (!_finishModels) {
        _finishModels = [NSMutableArray array];
    }
    return _finishModels;
}
-(NSMutableArray *)suspendModels{
    if (!_suspendModels) {
        _suspendModels = [NSMutableArray array];
    }
    return _suspendModels;
}
-(NSMutableArray *)errorModels{
    if (!_errorModels) {
        _errorModels = [NSMutableArray array];
    }
    return _errorModels;
}
-(NSMutableArray *)allArray{
    NSMutableArray * arr = [NSMutableArray new];
    [arr addObjectsFromArray:self.downloadingModels];
    [arr addObjectsFromArray:self.waitingModels];
    [arr addObjectsFromArray:self.finishModels];
    [arr addObjectsFromArray:self.suspendModels];
    [arr addObjectsFromArray:self.errorModels];
    return arr;
}
#pragma mark - Main Methods

+ (instancetype)sharedManager {
    
    dispatch_once(&onceToken, ^{
        downloadManager = [[self alloc] init];
        downloadManager.maxConcurrentCount = -1;
        downloadManager.waitingQueueMode = SRWaitingQueueModeFIFO;
    });
    return downloadManager;
}

- (instancetype)init {
    
    if (self = [super init]) {
        NSString *downloadDirectory = SRDownloadDirectory;
        BOOL isDirectory = NO;
        NSFileManager *fileManager = [NSFileManager defaultManager];
        BOOL isExists = [fileManager fileExistsAtPath:downloadDirectory isDirectory:&isDirectory];
        if (!isExists || !isDirectory) {
            [fileManager createDirectoryAtPath:downloadDirectory withIntermediateDirectories:YES attributes:nil error:nil];
        }
    }
    return self;
}

- (void)downloadURL:(NSURL *)URL
           destPath:(NSString *)destPath andTitle:(NSString *)title
              state:(void (^)(SRDownloadState state))state
           progress:(void (^)(NSInteger receivedSize, NSInteger expectedSize, CGFloat progress))progress
         completion:(void (^)(BOOL success, NSString *filePath, NSError *error))completion
{
    if (!URL) {
        return;
    }
    
    if ([self isDownloadCompletedOfURL:URL]) { // if this URL has been downloaded
        if (state) {
            state(SRDownloadStateCompleted);
        }
        if (completion) {
            completion(YES, [self fileFullPathOfURL:URL], nil);
        }
        return;
    }
    
    SRDownloadModel *downloadModel = self.downloadModelsDic[SRFileName(URL)];
    if (downloadModel) { // if the download model of this URL has been added in downloadModelsDic
        return;
    }
    
    // Range
    // bytes=x-y ==  x byte ~ y byte
    // bytes=x-  ==  x byte ~ end
    // bytes=-y  ==  head ~ y byte
    NSMutableURLRequest *requestM = [NSMutableURLRequest requestWithURL:URL];
    [requestM setValue:[NSString stringWithFormat:@"bytes=%ld-", (long)[self hasDownloadedLength:URL]] forHTTPHeaderField:@"Range"];
    NSURLSessionDataTask *dataTask = [self.urlSession dataTaskWithRequest:requestM];
    dataTask.taskDescription = SRFileName(URL);
    
    downloadModel = [[SRDownloadModel alloc] init];
    downloadModel.dataTask = dataTask;
    downloadModel.outputStream = [NSOutputStream outputStreamToFileAtPath:[self fileFullPathOfURL:URL] append:YES];
    downloadModel.URL = URL;
    downloadModel.destPath = destPath;
    downloadModel.state = state;
    downloadModel.progress = progress;
    downloadModel.completion = completion;
    downloadModel.title = title;
    self.downloadModelsDic[dataTask.taskDescription] = downloadModel;
    SRDownloadState downloadState;
    if ([self canResumeDownload]) {
        [self.downloadingModels addObject:downloadModel];
        [dataTask resume];
        downloadState = SRDownloadStateRunning;
    } else {
        [self.waitingModels addObject:downloadModel];
        downloadState = SRDownloadStateWaiting;
    }
    downloadModel.status = downloadState;
    dispatch_async(dispatch_get_main_queue(), ^{
        if (downloadModel.state) {
            downloadModel.state(downloadState);
        }
    });
}

#pragma mark - NSURLSessionDataDelegate

- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveResponse:(NSURLResponse *)response completionHandler:(nonnull void (^)(NSURLSessionResponseDisposition))completionHandler {
    
    SRDownloadModel *downloadModel = self.downloadModelsDic[dataTask.taskDescription];
    if (!downloadModel) {
        return;
    }
    
    [downloadModel openOutputStream];
    
    // response.expectedContentLength == [HTTPResponse.allHeaderFields[@"Content-Length"] integerValue]
    // response.expectedContentLength + [self hasDownloadedLength:downloadModel.URL] == [[HTTPResponse.allHeaderFields[@"Content-Range"] componentsSeparatedByString:@"/"].lastObject integerValue]
    NSInteger totalLength = (long)response.expectedContentLength + [self hasDownloadedLength:downloadModel.URL];
    downloadModel.totalLength = totalLength;
    NSMutableDictionary *filesTotalLength = [NSMutableDictionary dictionaryWithContentsOfFile:SRFilesTotalLengthPlistPath] ?: [NSMutableDictionary dictionary];
    filesTotalLength[SRFileName(downloadModel.URL)] = @(totalLength);
    [filesTotalLength writeToFile:SRFilesTotalLengthPlistPath atomically:YES];
    
    completionHandler(NSURLSessionResponseAllow);
}

- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveData:(NSData *)data {
    
   __block SRDownloadModel *downloadModel = self.downloadModelsDic[dataTask.taskDescription];
    if (!downloadModel) {
        return;
    }
    
    [downloadModel.outputStream write:data.bytes maxLength:data.length];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        if (downloadModel.progress) {
            NSUInteger receivedSize = [self hasDownloadedLength:downloadModel.URL];
            NSUInteger expectedSize = downloadModel.totalLength;
            if (expectedSize == 0) {
                return;
            }
            CGFloat progress = 1.0 * receivedSize / expectedSize;
            downloadModel.progress(receivedSize, expectedSize, progress);
        }
    });
}

- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error {
    
    if (error && error.code == -999) { // cancel task
        return;
    }
    
  __block  SRDownloadModel *downloadModel = self.downloadModelsDic[task.taskDescription];
    if (!downloadModel) {
        return;
    }
    
    [downloadModel closeOutputStream];
    [self.downloadModelsDic removeObjectForKey:task.taskDescription];
    [self.downloadingModels removeObject:downloadModel];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        if ([self isDownloadCompletedOfURL:downloadModel.URL]) {
            NSString *destPath = downloadModel.destPath;
            NSString *fullPath = [self fileFullPathOfURL:downloadModel.URL];
            if (destPath) {
                NSError *error;
                if (![[NSFileManager defaultManager] moveItemAtPath:fullPath toPath:destPath error:&error]) {
                    NSLog(@"moveItemAtPath error: %@", error);
                }
            }
            if (downloadModel.state) {
                downloadModel.state(SRDownloadStateCompleted);
                downloadModel.status = SRDownloadStateCompleted;
            }
            if (downloadModel.completion) {
                downloadModel.completion(YES, destPath ?: fullPath, error);
            }
            [self.finishModels addObject:downloadModel];
        } else {
            if (downloadModel.state) {
                downloadModel.state(SRDownloadStateFailed);
                downloadModel.status = SRDownloadStateFailed;

            }
            if (downloadModel.completion) {
                downloadModel.completion(NO, nil, error);
            }
            [self.errorModels addObject:downloadModel];
        }
    });
    
    [self resumeNextDowloadModel];
}

#pragma mark - Assist Methods

- (BOOL)canResumeDownload {
    
    if (self.maxConcurrentCount == -1) {
        return YES;
    }
    if (self.downloadingModels.count >= self.maxConcurrentCount) {
        return NO;
    }
    return YES;
}

- (NSInteger)totalLength:(NSURL *)URL {
    
    NSDictionary *filesTotalLenth = [NSDictionary dictionaryWithContentsOfFile:SRFilesTotalLengthPlistPath];
    if (!filesTotalLenth) {
        return 0;
    }
    if (!filesTotalLenth[SRFileName(URL)]) {
        return 0;
    }
    return [filesTotalLenth[SRFileName(URL)] integerValue];
}

- (NSInteger)hasDownloadedLength:(NSURL *)URL {
    
    NSDictionary *fileAttributes = [[NSFileManager defaultManager] attributesOfItemAtPath:[self fileFullPathOfURL:URL] error:nil];
    if (!fileAttributes) {
        return 0;
    }
    return [fileAttributes[NSFileSize] integerValue];
}

- (void)resumeNextDowloadModel {
    
    if (self.maxConcurrentCount == -1) { // no limit so no waiting for download models
        return;
    }
    
    if (self.waitingModels.count == 0) {
        return;
    }
    
    SRDownloadModel *downloadModel;
    switch (self.waitingQueueMode) {
        case SRWaitingQueueModeFIFO:
            downloadModel = self.waitingModels.firstObject;
            break;
        case SRWaitingQueueModeFILO:
            downloadModel = self.waitingModels.lastObject;
            break;
    }
    [self.waitingModels removeObject:downloadModel];
    if ([self.suspendModels containsObject:downloadModel]) {
        [self.suspendModels removeObject:downloadModel];
    }
    SRDownloadState downloadState;
    if ([self canResumeDownload]) {
        [downloadModel.dataTask resume];
        downloadState = SRDownloadStateRunning;
        [self.downloadingModels addObject:downloadModel];
        
    } else {
        downloadState = SRDownloadStateWaiting;
        [self.waitingModels addObject:downloadModel];
    }
    downloadModel.status = downloadState;
    dispatch_async(dispatch_get_main_queue(), ^{
        if (downloadModel.state) {
            downloadModel.state(downloadState);
        }
    });
}

#pragma mark - Public Methods

- (BOOL)isDownloadCompletedOfURL:(NSURL *)URL {
    
    NSInteger totalLength = [self totalLength:URL];
    if (totalLength != 0) {
        if (totalLength == [self hasDownloadedLength:URL]) {
            return YES;
        }
    }
    return NO;
}

- (void)setSaveFilesDirectory:(NSString *)saveFilesDirectory {
    
    _saveFilesDirectory = saveFilesDirectory;
    
    if (!saveFilesDirectory) {
        return;
    }
    BOOL isDirectory = NO;
    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL isExists = [fileManager fileExistsAtPath:saveFilesDirectory isDirectory:&isDirectory];
    if (!isExists || !isDirectory) {
        [fileManager createDirectoryAtPath:saveFilesDirectory withIntermediateDirectories:YES attributes:nil error:nil];
    }
}

#pragma mark - Downloads
//暂停的数据放这里
- (void)suspendDownloadOfURL:(NSURL *)URL {
    //根据URL获取模型并把状态设置为暂停
    SRDownloadModel *downloadModel = self.downloadModelsDic[SRFileName(URL)];
    if (!downloadModel) {
        return;
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        if (downloadModel.state) {
            downloadModel.state(SRDownloadStateSuspended);
        }
    });
    downloadModel.status = SRDownloadStateSuspended;
    if ([self.waitingModels containsObject:downloadModel]) {
        [self.suspendModels addObject:downloadModel];
        [self.waitingModels removeObject:downloadModel];
    } else {
        //正在下载的停止下载
        [downloadModel.dataTask suspend];
        [self.suspendModels addObject:downloadModel];
        [self.downloadingModels removeObject:downloadModel];
    }
    [self resumeNextDowloadModel];
}

- (void)suspendAllDownloads {
    
    if (self.downloadModelsDic.count == 0) {
        return;
    }
    
    if (self.waitingModels.count > 0) {
        for (NSInteger i = 0; i < self.waitingModels.count; i++) {
           __block SRDownloadModel *downloadModel = self.waitingModels[i];
            dispatch_async(dispatch_get_main_queue(), ^{
                if (downloadModel.state) {
                    downloadModel.state(SRDownloadStateSuspended);
                    downloadModel.status = SRDownloadStateSuspended;
                    [self.suspendModels addObject:downloadModel];
                }
            });
        }
        [self.waitingModels removeAllObjects];
    }
    
    if (self.downloadingModels.count > 0) {
        for (NSInteger i = 0; i < self.downloadingModels.count; i++) {
           __block SRDownloadModel *downloadModel = self.downloadingModels[i];
            [downloadModel.dataTask suspend];
            dispatch_async(dispatch_get_main_queue(), ^{
                if (downloadModel.state) {
                    downloadModel.state(SRDownloadStateSuspended);
                    downloadModel.status = SRDownloadStateSuspended;
                    [self.suspendModels addObject:downloadModel];
                }
            });
        }
        [self.downloadingModels removeAllObjects];
    }
    
}

- (void)resumeDownloadOfURL:(NSURL *)URL {
    
    SRDownloadModel *downloadModel = self.downloadModelsDic[SRFileName(URL)];
    if (!downloadModel) {
        return;
    }
    if ([self.suspendModels containsObject:downloadModel]) {
        [self.suspendModels removeObject:downloadModel];
    }
    //重新下载 单列模型状态是替换而不是添加
    SRDownloadState downloadState;
    if ([self canResumeDownload]) {
        [downloadModel.dataTask resume];
        downloadState = SRDownloadStateRunning;
        [self.downloadingModels addObject:downloadModel];
    } else {
        downloadState = SRDownloadStateWaiting;
        [self.waitingModels addObject:downloadModel];
    }
    downloadModel.status = downloadState;
    dispatch_async(dispatch_get_main_queue(), ^{
        if (downloadModel.state) {
            downloadModel.state(downloadState);
        }
    });
}

- (void)resumeAllDownloads {
    
    if (self.downloadModelsDic.count == 0) {
        return;
    }
    
    NSArray *downloadModels = self.downloadModelsDic.allValues;
    for (SRDownloadModel *downloadModel in downloadModels) {
        SRDownloadState downloadState;
        if ([self canResumeDownload]) {
            [downloadModel.dataTask resume];
            downloadState = SRDownloadStateRunning;
            [self.downloadingModels addObject:downloadModel];
        } else {
            downloadState = SRDownloadStateWaiting;
            [self.waitingModels addObject:downloadModel];
        }
        downloadModel.status = downloadState;
        dispatch_async(dispatch_get_main_queue(), ^{
            if (downloadModel.state) {
                downloadModel.state(downloadState);

            }
        });
    }
}
//
- (void)cancelDownloadOfURL:(NSURL *)URL {
    
    SRDownloadModel *downloadModel = self.downloadModelsDic[SRFileName(URL)];
    if (!downloadModel) {
        return;
    }
    
    [downloadModel closeOutputStream];
    [downloadModel.dataTask cancel];
    downloadModel.status = SRDownloadStateCanceled;
    dispatch_async(dispatch_get_main_queue(), ^{
        if (downloadModel.state) {
            downloadModel.state(SRDownloadStateCanceled);
        }
    });
    
    if ([self.waitingModels containsObject:downloadModel]) {
        [self.waitingModels removeObject:downloadModel];
    } else {
        [self.downloadingModels removeObject:downloadModel];
    }
    [self.downloadModelsDic removeObjectForKey:SRFileName(URL)];
    
    [self resumeNextDowloadModel];
}

- (void)cancelAllDownloads {
    
    if (self.downloadModelsDic.count == 0) {
        return;
    }
    
    NSArray *downloadModels = self.downloadModelsDic.allValues;
    for (SRDownloadModel *downloadModel in downloadModels) {
        [downloadModel closeOutputStream];
        [downloadModel.dataTask cancel];
        downloadModel.status = SRDownloadStateCanceled;
        dispatch_async(dispatch_get_main_queue(), ^{
            if (downloadModel.state) {
                downloadModel.state(SRDownloadStateCanceled);
            }
        });
    }
    
    [self.waitingModels removeAllObjects];
    [self.downloadingModels removeAllObjects];
    [self.downloadModelsDic removeAllObjects];
}

#pragma mark - Files

- (NSString *)fileFullPathOfURL:(NSURL *)URL {
    
    return SRFilePath(URL);
}

- (CGFloat)fileHasDownloadedProgressOfURL:(NSURL *)URL {
    
    if ([self isDownloadCompletedOfURL:URL]) {
        return 1.0;
    }
    if ([self totalLength:URL] == 0) {
        return 0.0;
    }
    return 1.0 * [self hasDownloadedLength:URL] / [self totalLength:URL];
}

- (void)deleteFile:(NSString *)fileName {
    
    NSMutableDictionary *filesTotalLenth = [NSMutableDictionary dictionaryWithContentsOfFile:SRFilesTotalLengthPlistPath];
    [filesTotalLenth removeObjectForKey:fileName];
    [filesTotalLenth writeToFile:SRFilesTotalLengthPlistPath atomically:YES];
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *filePath = [SRDownloadDirectory stringByAppendingPathComponent:fileName];
//    NSSLog(@"%@",filePath);
    if (![fileManager fileExistsAtPath:filePath]) {
        return;
    }
    [fileManager removeItemAtPath:filePath error:nil];
}

- (void)deleteFileOfURL:(NSURL *)URL andModel:(SRDownloadModel *)model{
    
    [self cancelDownloadOfURL:URL];
    //只删除了视频文件
    [self deleteFile:SRFileName(URL)];
    //删除这个数据
    if ([self.finishModels containsObject:model]) {
        [self.finishModels removeObject:model];
    }
    if ([self.waitingModels containsObject:model]) {
        [self.waitingModels removeObject:model];
    }

    if ([self.downloadingModels containsObject:model]) {
        [self.downloadingModels removeObject:model];
    }

    if ([self.errorModels containsObject:model]) {
        [self.errorModels removeObject:model];
    }

    if ([self.suspendModels containsObject:model]) {
        [self.suspendModels removeObject:model];
    }
    [self.downloadModelsDic removeObjectForKey:SRFileName(URL)];

}
-(void)deleteVideo:(NSURL *)url{
    [self cancelDownloadOfURL:url];
    //只删除了视频文件
    [self deleteFile:SRFileName(url)];
    //根据URL找到数据源 删除
    NSString * urlStr = [url absoluteString];
    for (SRDownloadModel * model in self.finishModels) {
        NSString * modelStr = [model.URL absoluteString];
        if ([modelStr isEqualToString:urlStr]) {
            [self.finishModels removeObject:model];
            break;
        }
    }
    [self.downloadModelsDic removeObjectForKey:SRFileName(url)];

}
- (void)deleteAllFiles {
    
    [self cancelAllDownloads];
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSArray *fileNames = [fileManager contentsOfDirectoryAtPath:SRDownloadDirectory error:nil];
    for (NSString *fileName in fileNames) {
        NSString *filePath = [SRDownloadDirectory stringByAppendingPathComponent:fileName];
        [fileManager removeItemAtPath:filePath error:nil];
    }
}

@end
