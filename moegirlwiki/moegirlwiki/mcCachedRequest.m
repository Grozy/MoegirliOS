//
//  mcCachedRequest.m
//  moegirlwiki
//
//  Created by master on 14-10-22.
//  Copyright (c) 2014年 masterchan.me. All rights reserved.
//

#import "mcCachedRequest.h"

@implementation mcCachedRequest

- (NSString*)MD5:(NSString *)targetString
{
    const char *ptr = [targetString UTF8String];
    unsigned char md5Buffer[CC_MD5_DIGEST_LENGTH];
    
    CC_MD5(ptr, (CC_LONG)strlen(ptr), md5Buffer);
    NSMutableString *output = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH * 2];
    for(int i = 0; i < CC_MD5_DIGEST_LENGTH; i++)
        [output appendFormat:@"%02x",md5Buffer[i]];
    
    return output;
}

- (void)launchRequest:(NSString *)URL ignoreCache:(bool)ignore
{
    NSString * hashString = [self MD5:URL];
    
    documentPath = [[[[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0]
                      stringByAppendingPathComponent:@"cache"]
                     stringByAppendingPathComponent:@"page"]
                    stringByAppendingPathComponent:hashString];
    
    fileManager = [NSFileManager defaultManager];
    if (([fileManager fileExistsAtPath:documentPath])&&(!ignore)) {
        [self.hook mcCachedRequestFinishLoading:YES
                                  LoadFromCache:YES
                                          error:nil
                                           data:[[NSMutableData alloc] initWithContentsOfFile:documentPath]];
    }else{
        NSMutableURLRequest * TheRequest = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:URL]
                                                                        cachePolicy:NSURLRequestReloadIgnoringLocalCacheData
                                                                    timeoutInterval:20];
        requestConnection = [[NSURLConnection alloc]initWithRequest:TheRequest
                                                           delegate:self
                                                   startImmediately:YES];
    }
}

- (void)launchPostRequest:(NSString *)URL ignoreCache:(bool)ignore
{
    NSString * hashString = [self MD5:URL];
    
    documentPath = [[[[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0]
                      stringByAppendingPathComponent:@"cache"]
                     stringByAppendingPathComponent:@"page"]
                    stringByAppendingPathComponent:hashString];
    
    fileManager = [NSFileManager defaultManager];
    if (([fileManager fileExistsAtPath:documentPath])&&(!ignore)) {
        [self.hook mcCachedRequestFinishLoading:YES
                                  LoadFromCache:YES
                                          error:nil
                                           data:[[NSMutableData alloc] initWithContentsOfFile:documentPath]];
    }else{
        NSMutableURLRequest * TheRequest = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:URL]
                                                                        cachePolicy:NSURLRequestReloadIgnoringLocalCacheData
                                                                    timeoutInterval:20];
        [TheRequest setHTTPMethod:@"POST"];
        requestConnection = [[NSURLConnection alloc]initWithRequest:TheRequest
                                                           delegate:self
                                                   startImmediately:YES];
    }
}

- (void)launchCookiedRequest:(NSString *)URL ignoreCache:(bool)ignore
{
    NSString * hashString = [self MD5:URL];
    
    documentPath = [[[[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0]
                      stringByAppendingPathComponent:@"cache"]
                     stringByAppendingPathComponent:@"page"]
                    stringByAppendingPathComponent:hashString];
    
    fileManager = [NSFileManager defaultManager];
    if (([fileManager fileExistsAtPath:documentPath])&&(!ignore)) {
        [self.hook mcCachedRequestFinishLoading:YES
                                  LoadFromCache:YES
                                          error:nil
                                           data:[[NSMutableData alloc] initWithContentsOfFile:documentPath]];
    }else{
        NSMutableURLRequest * TheRequest = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:URL]
                                                                        cachePolicy:NSURLRequestReloadIgnoringLocalCacheData
                                                                    timeoutInterval:20];
        
        NSUserDefaults * defaultdata = [NSUserDefaults standardUserDefaults];
        if (![[defaultdata objectForKey:@"cookie"] isEqualToString:@"--"]) {
            [TheRequest setValue:[defaultdata objectForKey:@"cookie"] forHTTPHeaderField:@"Cookie"];
        }
        requestConnection = [[NSURLConnection alloc]initWithRequest:TheRequest
                                                           delegate:self
                                                   startImmediately:YES];
    }
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    _recievePool = [NSMutableData new];
    [self.hook mcCachedRequestGotRespond];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    [_recievePool appendData:data];
    [self.hook mcCachedRequestGotData];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    [self.hook mcCachedRequestFinishLoading:NO
                              LoadFromCache:NO
                                      error:error.localizedDescription
                                       data:nil];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    [self.hook mcCachedRequestFinishLoading:YES
                              LoadFromCache:NO
                                      error:nil
                                       data:_recievePool];
    [_recievePool writeToFile:documentPath atomically:YES];
}

@end