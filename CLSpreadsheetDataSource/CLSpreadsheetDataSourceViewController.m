//
//  CLSpreadsheetDataSourceViewController.m
//  SpreadsheetDataSourceExample
//
//  Created by Elad Ben-Israel on 4/26/14.
//  Copyright (c) 2014 Citylifeapps. All rights reserved.
//

#import "CLSpreadsheetDataSourceViewController.h"
#import "CLSpreadsheetDataSource.h"

static NSString *const kCLSpreadsheetDataSourceViewControllerCellIdentifier = @"kCLSpreadsheetDataSourceViewControllerCellIdentifier";

@interface CLSpreadsheetDataSourceItemViewController : UITableViewController
@property (strong, nonatomic) NSDictionary *item;
@end

@interface CLSpreadsheetDataSourceItemImageViewController : UIViewController
@end

@implementation CLSpreadsheetDataSourceViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl addTarget:self action:@selector(refresh:) forControlEvents:UIControlEventValueChanged];
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:kCLSpreadsheetDataSourceViewControllerCellIdentifier];
}

- (void)viewDidAppear:(BOOL)animated
{
    [self refresh:self.refreshControl];
}

- (void)setDataSource:(CLSpreadsheetDataSource *)dataSource
{
    _dataSource = dataSource;
    [self.tableView reloadData];
}

- (void)refresh:(UIRefreshControl *)sender
{
    [sender beginRefreshing];
    [self.dataSource reloadWithTimeout:50000.0f completion:^(NSError *error) {
        [sender endRefreshing];
        if (error) {
            [[[UIAlertView alloc] initWithTitle:error.localizedDescription message:nil delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:nil] show];
            return;
        }

        [self.tableView reloadData];
    }];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.dataSource.objects.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kCLSpreadsheetDataSourceViewControllerCellIdentifier forIndexPath:indexPath];
    NSDictionary *obj = self.dataSource.objects[indexPath.row];
    NSMutableString *desc = [[NSMutableString alloc] init];
    
    if (obj[@"id"]) {
        desc = obj[@"id"];
    }
    else {
        for (NSString *k in obj.allKeys) {
            [desc appendString:k];
            [desc appendString:@"="];
            [desc appendString:obj[k]];
            [desc appendString:@" "];
        }
    }
    cell.textLabel.text = desc;
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *item = self.dataSource.objects[indexPath.row];
    CLSpreadsheetDataSourceItemViewController *detail = [[CLSpreadsheetDataSourceItemViewController alloc] init];
    detail.item = item;
    detail.title = item[@"id"];
    [self.navigationController pushViewController:detail animated:YES];
}

@end

@implementation CLSpreadsheetDataSourceItemViewController

- (void)viewDidLoad
{
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"cell"];
}

- (void)setItem:(NSDictionary *)item
{
    _item = item;
    [self.tableView reloadData];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.item.allKeys.count;
}

- (NSURL *)imageURLForIndexPath:(NSIndexPath *)indexPath
{
    NSString *key = self.item.allKeys[indexPath.row];
    NSString *lcvalue = [self.item[key] lowercaseString];
    if (!([lcvalue hasPrefix:@"http"] && ([lcvalue rangeOfString:@"png"].length > 0 ||
                                          [lcvalue rangeOfString:@"jpg"].length > 0))) {
        return nil;
    }
    return [NSURL URLWithString:self.item[key]];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *key = self.item.allKeys[indexPath.row];
    NSString *value = self.item[key];
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    cell.textLabel.text = [NSString stringWithFormat:@"%@ = %@", key, value];

    if ([self imageURLForIndexPath:indexPath]) {
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSURL *url = [self imageURLForIndexPath:indexPath];
    if (!url) {
        return;
    }
    
    UIViewController *viewController = [[UIViewController alloc] init];
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:viewController.view.bounds];
    imageView.backgroundColor = [UIColor greenColor];
    imageView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    imageView.contentMode = UIViewContentModeScaleAspectFit;
    [viewController.view addSubview:imageView];
    [[[NSURLSession sharedSession] dataTaskWithURL:url completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            imageView.image = [UIImage imageWithData:data];
        });
    }] resume];
    [self.navigationController pushViewController:viewController animated:YES];
}

@end