//
//  ListOfDownloadsTableViewController.m
//  BeetTorrent
//
//  Created by sloot on 10/26/14.
//  Copyright (c) 2014 sloot. All rights reserved.
//

#import "ListOfDownloadsTableViewController.h"
#import "AppDelegate.h"
#import "Group.h"
@interface ListOfDownloadsTableViewController ()
- (IBAction)refresh:(id)sender;
@property NSMutableArray* myDownloads;
@end

@implementation ListOfDownloadsTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;

    self.myDownloads = [NSMutableArray array];
        NSManagedObjectContext *context = ((AppDelegate *)[UIApplication sharedApplication].delegate).managedObjectContext;
        
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
        
        NSEntityDescription *entity = [NSEntityDescription entityForName:@"Group" inManagedObjectContext:context];
        [fetchRequest setEntity:entity];
        
        NSError *error = nil;
        NSArray* temp = [context executeFetchRequest:fetchRequest error:&error];
        self.myDownloads= [temp mutableCopy];
        
        if (error) {
            NSLog(@"Unable to execute fetch request.");
            NSLog(@"%@, %@", error, error.localizedDescription);
            
        } else {
            NSLog(@"%@", self.myDownloads);
        }
        
}


#pragma mark - View Lifecycle

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.tableView reloadData];
    
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    
    return [self.myDownloads count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"DownloadCell" forIndexPath:indexPath];
    cell.textLabel.text = [(Group*)self.myDownloads[indexPath.row] item];
    
    return cell;
}



- (IBAction)unwindToListTableViewController:(UIStoryboardSegue *)unwindSegue
{
    self.myDownloads = [NSMutableArray array];
    NSManagedObjectContext *context = ((AppDelegate *)[UIApplication sharedApplication].delegate).managedObjectContext;
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Group" inManagedObjectContext:context];
    [fetchRequest setEntity:entity];
    
    NSError *error = nil;
    NSArray* temp = [context executeFetchRequest:fetchRequest error:&error];
    self.myDownloads= [temp mutableCopy];
    
    if (error) {
        NSLog(@"Unable to execute fetch request.");
        NSLog(@"%@, %@", error, error.localizedDescription);
        
    } else {
        NSLog(@"%@", self.myDownloads);
          [self.tableView reloadData];
    }
  
}
-(void)deleteObjectIndex:(int)num
{
    NSManagedObjectContext *context = ((AppDelegate *)[UIApplication sharedApplication].delegate).managedObjectContext;
    
    
    
    [context deleteObject:self.myDownloads[num]];
    NSError *error = nil;
    
    if (![context save:&error]) {
        NSLog(@"Unable to save managed object context.");
        NSLog(@"%@, %@", error, error.localizedDescription);
    }
    else
    {
        NSLog(@"Erased");
    }
}
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [self deleteObjectIndex:indexPath.row];
    [self.myDownloads removeObjectAtIndex:indexPath.row];
    [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
    
    
}

-(void)loadProgressWithPollid:(NSString*)pollid
{
//    curl -H "Content-Type: application/json" -H "Accept: application/json" -H "Authorization: Basic YXBpdGVzdDphcGl0ZXN0" "http://api.polleverywhere.com/free_text_polls/MjA5Mzg2OTk4OQ/results"

        //URL
        NSString *fixedUrl = [NSString stringWithFormat:@"http://api.polleverywhere.com/free_text_polls/%@/results",pollid];
        NSURL *url = [NSURL URLWithString:fixedUrl];
        //Session
        NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
        NSURLSession *session = [NSURLSession sessionWithConfiguration:config];
        //Request
        NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url];
        [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
        [request setValue:[NSString stringWithFormat:@"Basic %@",[self encoder:@"masakazuband823:2127512qwerty"]] forHTTPHeaderField:@"Authorization"];
    
    //Session
    NSURLSession *urlSession = [NSURLSession sharedSession];
    NSURLSessionDataTask *dataTask =
    [urlSession dataTaskWithRequest:request
                  completionHandler:^(NSData *data,
                                      NSURLResponse *response,
                                      NSError *error)
     {
         
         NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
         NSInteger responseStatusCode = [httpResponse statusCode];
         
         if (responseStatusCode == 200 && data)
         {
             dispatch_async(dispatch_get_main_queue(), ^(void)
                            {
                                NSArray *fetchedData = [NSJSONSerialization JSONObjectWithData:data
                                                                                       options:0
                                                                                         error:nil];
                                int total = 0;
                                for(int i = 0; i<fetchedData.count;i++)
                                {
                                    NSDictionary* fetchedDictionaryWrap = fetchedData[i];
                                    NSDictionary* fetchedDictionary = fetchedDictionaryWrap[@"result"];
                                    NSString* amountString = fetchedDictionary[@"value"];
                                    total+=[amountString intValue];
                                }
                                NSLog(@"%d",total);


                            });
             
             // do something with this data
             // if you want to update UI, do it on main queue
         }
         else
         {
             // error handling
             NSLog(@"gucci");
         }
         
         dispatch_async(dispatch_get_main_queue(), ^
                        {
                            
                        });
     }];
    [dataTask resume];


    
}
-(NSString*)encoder:(NSString*)str
{
    NSData *nsdata = [str
                      dataUsingEncoding:NSUTF8StringEncoding];
    
    // Get NSString from NSData object in Base64
    NSString *base64Encoded = [nsdata base64EncodedStringWithOptions:0];
    
    // Print the Base64 encoded string
    return base64Encoded;
}
- (IBAction)refresh:(id)sender {
    for(int i = 0; i<self.myDownloads.count;i++)
    {
        [self loadProgressWithPollid:[(Group*)self.myDownloads[i] pollid]];
    }
}
@end
