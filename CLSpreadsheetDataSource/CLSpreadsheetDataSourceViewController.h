//
//  CLSpreadsheetDataSourceViewController.h
//  SpreadsheetDataSourceExample
//
//  Created by Elad Ben-Israel on 4/26/14.
//  Copyright (c) 2014 Citylifeapps. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CLSpreadsheetDataSource.h"

@interface CLSpreadsheetDataSourceViewController : UITableViewController

@property (strong, nonatomic) CLSpreadsheetDataSource *dataSource;

@end
