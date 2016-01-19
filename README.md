# CLSpreadsheetDataSource

A data source which reads from Google spreadsheets.

## Installation

We need to import this to Cocoapods. In the meantime, just copy the files from the `CLSpreadsheetDataSource` directory into your project.

## API

#### Initialization

```objc
- (instancetype)initWithSpreadsheetKey:(NSString *)key session:(NSURLSession *)session;
- (instancetype)initWithSpreadsheetKey:(NSString *)key worksheetId:(NSString *)worksheetId session:(NSURLSession *)session;
```

 * __key__ - The google [spreadsheets key](http://www.coolheadtech.com/blog/use-data-from-other-google-spreadsheets).
 * __worksheetId__ - If the document contains multiple worksheets, the ID of the worksheet to associate with the data source (otherwise the first one is taken).
 * __session__ - The `NSURLSession` to use (you can use `sharedSession`).

 #### Reloading data from the spreadsheet

```objc
- (void)reloadWithTimeout:(NSTimeInterval)timeout completion:(void(^)(NSError *error))completionBlock;
```

 * __timeout__ - Load timeout
 * __completion__ - Completion block.

#### Accessing Objects

Each row in the worksheet is converted to an object. Each object is an
`NSDictionary` where keys are column names and values are the value within the cell.

```objc
@property NSArray *objects;
@property NSDictionary *objectsByID;
```

 * The `objects` array contains all the objects as an array.
 * The `objectsByID` dictionary can be used to access any object by ID. Objects are
   mapped to their ID if they have an `id` column. Otherwise, they will not be available
   from this dictionary.

## Debugging UI

`CLSpreadsheetDataSourceViewController` is provided. It can be used to display
the contents of a `CLSpreadsheetDataSource`. Simply push it into your view
controller hierarchy:

```objc
CLSpreadsheetDataSource *dataSource;

CLSpreadsheetDataSourceViewController *vc = [[CLSpreadsheetDataSourceViewController alloc] init];
vc.dataSource = dataSource;
vc.title = propertyName;
[self.navigationController pushViewController:vc animated:YES];
```

## License

MIT
