//
//  CLSpreadsheetDataSource.m
//  SpreadsheetDataSourceExample
//
//  Created by Elad Ben-Israel on 4/26/14.
//  Copyright (c) 2014 Citylifeapps. All rights reserved.
//

#import "CLSpreadsheetDataSource.h"

@interface CLSpreadsheetDataSource ()

@property (strong, nonatomic) NSString *spreadsheetKey;
@property (strong, nonatomic) NSString *worksheetId;
@property (strong, nonatomic) NSURLSessionDataTask *dataTask;
@property (strong, nonatomic) NSArray *objects;
@property (strong, nonatomic) NSDictionary *objectsByID;
@property (strong, nonatomic) NSURLSession *session;

@end

@implementation CLSpreadsheetDataSource

- (instancetype)initWithSpreadsheetKey:(NSString *)key session:(NSURLSession *)session
{
    return [self initWithSpreadsheetKey:key worksheetId:@"od6" session:session];
}

- (instancetype)initWithSpreadsheetKey:(NSString *)key worksheetId:(NSString *)worksheetId session:(NSURLSession *)session
{
    NSParameterAssert(key);
    NSParameterAssert(session);
    
    self = [super init];
    if (self) {
        self.session = session;
        self.spreadsheetKey = key;
        self.worksheetId = worksheetId;
    }
    return self;
}

- (void)reloadWithTimeout:(NSTimeInterval)timeout completion:(void(^)(NSError *error))completionBlock
{
    NSURLSessionDataTask *task = [self dataTaskWithTimeout:timeout completionHandler:completionBlock];
    [task resume];
}

#pragma mark - Download Task

- (NSURLSessionDataTask *)dataTaskWithTimeout:(NSTimeInterval)timeout completionHandler:(void(^)(NSError *error))completionBlock
{
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"https://spreadsheets.google.com/feeds/list/%@/%@/public/values?alt=json", self.spreadsheetKey, self.worksheetId]];
    NSURLRequest *req = [NSURLRequest requestWithURL:url];
    
    __block dispatch_once_t completeOnce = 0;
    void(^completion)(NSData *responseData, NSError *error) = ^(NSData *responseData, NSError *error) {
        dispatch_once(&completeOnce, ^{
            [self processResponseData:responseData]; // process response data, even if we already completed
            if (completionBlock) {
                completionBlock(error);
            }
        });
    };
    
    NSCachedURLResponse *cachedResponse = [self.session.configuration.URLCache cachedResponseForRequest:req];

    // if we have a cached response, schedule a timeout and serve it as soon as the timeout expires.
    // nevertheless, issue the request so that the cache will be up-to-date for next time.
    if (cachedResponse) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(timeout * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            completion(cachedResponse.data, nil);
        });
    }
    
    return [self.session dataTaskWithRequest:req completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (error) {
            if (cachedResponse) {
                completion(cachedResponse.data, nil);
            }
            else {
                completion(nil, error);
            }
            
            return;
        }
        
        completion(data, nil);
    }];
}

- (void)processResponseData:(NSData *)data
{
    if (!data) {
        return;
    }
    
    NSMutableArray *objects = [[NSMutableArray alloc] init];
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];

    id response = [NSJSONSerialization JSONObjectWithData:data options:0 error:0];
    NSArray *rows = response[@"feed"][@"entry"];
    for (NSDictionary *row in rows) {
        NSMutableDictionary *object = [[NSMutableDictionary alloc] init];
        for (NSString *fkey in row.allKeys) {
            if ([fkey hasPrefix:@"gsx$"]) {
                NSString *key = [fkey substringWithRange:NSMakeRange(4, fkey.length - 4)];
                NSString *value = row[fkey][@"$t"];
                if (value.length > 0) {
                    object[key] = value;
                }
            }
        }
        [objects addObject:object];

        NSString *objectID = object[@"id"];
        if (!objectID) {
            continue; // no object id
        }
        
        dict[objectID] = object;
    }
    
    self.objects = objects;
    self.objectsByID = [dict copy];
}

@end