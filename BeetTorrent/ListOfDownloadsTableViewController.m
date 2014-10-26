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
#import "TDBadgedCell.h"
#import "DetailedDownloadViewController.h"
#import "RequestItemViewController.h"
#import <AddressBookUI/AddressBookUI.h>

@interface ListOfDownloadsTableViewController ()
- (IBAction)refresh:(id)sender;
@property NSMutableArray* myDownloads;
@property NSMutableArray* myProgress;
@property NSMutableArray* myFriendNames;
@property NSMutableArray* myFriendNumbers;
@end

@implementation ListOfDownloadsTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    [self retrievedDownloads];

        
}
-(void)startLoading
{
    [NSTimer scheduledTimerWithTimeInterval:.5 target:self selector:@selector(timerFireMethod:) userInfo:nil repeats:YES];
}
- (void)timerFireMethod:(NSTimer*)theTimer
{
    for(int i = 0; i<self.myDownloads.count;i++)
    {
        [self loadProgressWithPollid:[(Group*)self.myDownloads[i] pollid] forIndex:i];
    }
}
-(void)retrievedDownloads
{
    self.myDownloads = [NSMutableArray array];
    self.myProgress = [NSMutableArray array];
    self.myFriendNames = [NSMutableArray array];
    self.myFriendNumbers = [NSMutableArray array];
    
    [self askForContactsPermission];
    
    NSManagedObjectContext *context = ((AppDelegate *)[UIApplication sharedApplication].delegate).managedObjectContext;
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Group" inManagedObjectContext:context];
    [fetchRequest setEntity:entity];
    
    NSError *error = nil;
    NSArray* temp = [context executeFetchRequest:fetchRequest error:&error];
    self.myDownloads= [temp mutableCopy];
    for(int i = 0;i<self.myDownloads.count;i++)
    {
        int tempInt = 0;
        [self.myProgress addObject:@(tempInt)];
    }
    [self startLoading];
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
    
    TDBadgedCell *cell = [tableView dequeueReusableCellWithIdentifier:@"DownloadCell" forIndexPath:indexPath];
    cell.textLabel.text = [(Group*)self.myDownloads[indexPath.row] item];
    if(((NSString*)self.myProgress[indexPath.row]).intValue<((NSString*)[(Group*)self.myDownloads[indexPath.row] goal]).intValue)
    {
        cell.badgeString = [NSString stringWithFormat: @"%@/%@",self.myProgress[indexPath.row],[(Group*)self.myDownloads[indexPath.row] goal]];
        
        cell.badgeColor = [UIColor colorWithRed:0.792 green:0.197 blue:0.219 alpha:1.000];
    }
    else
    {
        cell.badgeString = [NSString stringWithFormat: @"Completed"];
        
        cell.badgeColor = [UIColor colorWithRed:0.0 green:0.97 blue:0.219 alpha:1.000];
    }



    return cell;
}



- (IBAction)unwindToListTableViewController:(UIStoryboardSegue *)unwindSegue
{
    [self retrievedDownloads];
  
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
    
    [self deleteFromServerPollid:[(Group*)self.myDownloads[indexPath.row] pollid] withIndexPath:indexPath];

    
    
}

-(void)loadProgressWithPollid:(NSString*)pollid forIndex:(int)index
{
//    curl -H "Content-Type: application/json" -H "Accept: application/json" -H "Authorization: Basic YXBpdGVzdDphcGl0ZXN0" "http://api.polleverywhere.com/free_text_polls/MjA5Mzg2OTk4OQ/results"

        //URL
        NSString *fixedUrl = [NSString stringWithFormat:@"http://api.polleverywhere.com/free_text_polls/%@/results",pollid];
        NSURL *url = [NSURL URLWithString:fixedUrl];
        //Session

        NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url];
        [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
        [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
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
                                [self.myProgress setObject:@(total) atIndexedSubscript:index];
                                [self.tableView reloadData];


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
-(void)deleteFromServerPollid:(NSString*)pollid withIndexPath:(NSIndexPath*)indexPath
{
        NSString *fixedUrl =
        [NSString stringWithFormat:@"http://api.polleverywhere.com/free_text_polls/%@/results", pollid];
        NSURL *url = [NSURL URLWithString:fixedUrl];
        
        //Request
        NSMutableURLRequest *request =
        [NSMutableURLRequest requestWithURL:url
                                cachePolicy:NSURLRequestUseProtocolCachePolicy
                            timeoutInterval:30.0];
    [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [request setValue:[NSString stringWithFormat:@"Basic %@",[self encoder:@"masakazuband823:2127512qwerty"]] forHTTPHeaderField:@"Authorization"];
        [request setHTTPMethod:@"DELETE"];
        
        //Session
        NSURLSession *urlSession = [NSURLSession sharedSession];
        
    NSError *error = nil;
    

    NSMutableDictionary* sendObj = [NSMutableDictionary dictionary];
    [sendObj setObject:@(true) forKey:@"ftp.destroy"];
    
    NSData *data = [NSJSONSerialization dataWithJSONObject:sendObj
                                                   options:kNilOptions
                                                     error:&error];

        NSURLSessionUploadTask *uploadTask =
        [urlSession uploadTaskWithRequest:request
                              fromData:data
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
                                    NSLog(@"%@",fetchedData);
                                    [self deleteObjectIndex:indexPath.row];
                                    [self.myDownloads removeObjectAtIndex:indexPath.row];
                                    [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
                                });
                 
                 // do something with this data
                 // if you want to update UI, do it on main queue
             }
             else
             {
                 // error handling
                 NSLog(@"cannot connect to server");
             }
         }];
        [uploadTask resume];


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
        [self loadProgressWithPollid:[(Group*)self.myDownloads[i] pollid] forIndex:i];
    }
}
-(void)askForContactsPermission
{
    ABAddressBookRef addressBookRef = ABAddressBookCreateWithOptions(NULL, NULL);
    
    if (ABAddressBookGetAuthorizationStatus() == kABAuthorizationStatusNotDetermined) {
        ABAddressBookRequestAccessWithCompletion(addressBookRef, ^(bool granted, CFErrorRef error) {
            if (granted) {
                // First time access has been granted, add the contact
                CFErrorRef *error = NULL;
                ABAddressBookRef addressBook = ABAddressBookCreateWithOptions(NULL, error);
                CFArrayRef allPeople = ABAddressBookCopyArrayOfAllPeople(addressBook);
                CFIndex numberOfPeople = ABAddressBookGetPersonCount(addressBook);
                
                for(int i = 0; i < numberOfPeople; i++) {
                    
                    ABRecordRef person = CFArrayGetValueAtIndex( allPeople, i );
                    
                    NSString *firstName = (__bridge NSString *)(ABRecordCopyValue(person, kABPersonFirstNameProperty));
                    NSString *lastName = (__bridge NSString *)(ABRecordCopyValue(person, kABPersonLastNameProperty));
                    NSString *fullName =[NSString stringWithFormat:@"%@%@",firstName,lastName];
                    NSLog(@"Name:%@ %@", firstName, lastName);
                    
                    ABMultiValueRef phoneNumbers = ABRecordCopyValue(person, kABPersonPhoneProperty);
                    
                    for (CFIndex i = 0; i < ABMultiValueGetCount(phoneNumbers); i++) {
                        NSString *phoneNumber = (__bridge_transfer NSString *) ABMultiValueCopyValueAtIndex(phoneNumbers, i);
                        NSLog(@"phone:%@", phoneNumber);
                        NSString *fixedNumber = [self stringFixer:phoneNumber];
                        if(![self.myFriendNumbers containsObject:fixedNumber])
                        {
                            [self.myFriendNumbers addObject:fixedNumber];
                            [self.myFriendNames addObject:fullName];
                        }
                        
                    }
                    
                    NSLog(@"=============================================");
                    
                }
            } else {
                // User denied access
                // Display an alert telling user the contact could not be added
            }
        });
    }
    else if (ABAddressBookGetAuthorizationStatus() == kABAuthorizationStatusAuthorized) {
        // The user has previously given access, add the contact
        CFErrorRef *error = NULL;
        ABAddressBookRef addressBook = ABAddressBookCreateWithOptions(NULL, error);
        CFArrayRef allPeople = ABAddressBookCopyArrayOfAllPeople(addressBook);
        CFIndex numberOfPeople = ABAddressBookGetPersonCount(addressBook);
        
        for(int i = 0; i < numberOfPeople; i++) {
            
            ABRecordRef person = CFArrayGetValueAtIndex( allPeople, i );
            
            NSString *firstName = (__bridge NSString *)(ABRecordCopyValue(person, kABPersonFirstNameProperty));
            NSString *lastName = (__bridge NSString *)(ABRecordCopyValue(person, kABPersonLastNameProperty));
            NSString *fullName =[NSString stringWithFormat:@"%@%@",firstName,lastName];
            NSLog(@"Name:%@ %@", firstName, lastName);
            
            ABMultiValueRef phoneNumbers = ABRecordCopyValue(person, kABPersonPhoneProperty);
            
            for (CFIndex i = 0; i < ABMultiValueGetCount(phoneNumbers); i++) {
                NSString *phoneNumber = (__bridge_transfer NSString *) ABMultiValueCopyValueAtIndex(phoneNumbers, i);
                NSLog(@"phone:%@", phoneNumber);
                NSString *fixedNumber = [self stringFixer:phoneNumber];
                if(![self.myFriendNumbers containsObject:fixedNumber])
                {
                    [self.myFriendNumbers addObject:fixedNumber];
                    [self.myFriendNames addObject:fullName];
                }

            }
            
            NSLog(@"=============================================");
            
        }
    }
    else {
        // The user has previously denied access
        // Send an alert telling user to change privacy setting in settings app
    }
}
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"Add"]) {
        RequestItemViewController *controller = [segue destinationViewController];
        controller.myFriendNames = self.myFriendNames;
        controller.myFriendNumbers = self.myFriendNumbers;
    }
    else if([segue.identifier isEqualToString:@"Show"])
    {
        DetailedDownloadViewController *controller = [segue destinationViewController];
        controller.myFriendNames = self.myFriendNames;
        controller.myFriendNumbers = self.myFriendNumbers;
    }
}

-(NSString*)stringFixer:(NSString*)str
{
    NSString* temp = [str stringByReplacingOccurrencesOfString:@" " withString:@""];
    temp = [temp stringByReplacingOccurrencesOfString:@"(" withString:@""];
    temp = [temp stringByReplacingOccurrencesOfString:@")" withString:@""];
    temp = [temp stringByReplacingOccurrencesOfString:@"-" withString:@""];
    return temp;
}
@end
