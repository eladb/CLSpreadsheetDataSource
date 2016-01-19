//
//  CLSpreadsheetDataSource.h
//  SpreadsheetDataSourceExample
//
//  Created by Elad Ben-Israel on 4/26/14.
//  Copyright (c) 2014 Citylifeapps. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CLSpreadsheetDataSource : NSObject

@property (readonly, nonatomic) NSArray *objects;
@property (readonly, nonatomic) NSDictionary *objectsByID;

@property (readonly, nonatomic) NSString *spreadsheetKey;
@property (readonly, nonatomic) NSString *worksheetId;

- (instancetype)initWithSpreadsheetKey:(NSString *)key session:(NSURLSession *)session;
- (instancetype)initWithSpreadsheetKey:(NSString *)key worksheetId:(NSString *)worksheetId session:(NSURLSession *)session;

- (void)reloadWithTimeout:(NSTimeInterval)timeout completion:(void(^)(NSError *error))completionBlock;

@end