//
//  RequestItemViewController.m
//  BeetTorrent
//
//  Created by sloot on 10/25/14.
//  Copyright (c) 2014 sloot. All rights reserved.
//

#import "RequestItemViewController.h"
#import "AppDelegate.h"
#import "Group.h"
//#import <Sinch/Sinch.h>
//curl -X POST -H "Content-Type: application/json" -H "Accept: application/json" -H "Authorization: Basic dXNlcm5hbWU6cGFzc3dvcmQ=" -d "{\
//\"free_text_poll\": {\"id\":null,\"updated_at\":null,\"title\":\"What is the meaning of life?\",\"opened_at\":null,\"permalink\":null,\"state\":null,\"sms_enabled\":null,\"twitter_enabled\":null,\"web_enabled\":null,\"sharing_enabled\":null,\"keyword\":null}\
//}" "http://api.polleverywhere.com/free_text_polls"
//dXNlcm5hbWU6cGFzc3dvcmQ=
@interface RequestItemViewController ()
@property (strong, nonatomic) IBOutlet UITextField *itemTextField;
@property (strong, nonatomic) IBOutlet UITextField *goalTextField;
- (IBAction)torrentPressed:(id)sender;

@end

@implementation RequestItemViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    NSLog([self encoder:@"masakazuband823:2127512qwerty"]);
    NSData *nsdataFromBase64String = [[NSData alloc]
                                      initWithBase64EncodedString:@"YXBpdGVzdDphcGl0ZXN0" options:0];
    
    // Decoded NSString from the NSData
    NSString *base64Decoded = [[NSString alloc]
                               initWithData:nsdataFromBase64String encoding:NSUTF8StringEncoding];
    NSLog(@"Decoded: %@", base64Decoded);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
//-(void)createSinch
//{
//    // Instantiate a Sinch client object
//    id<SINClient> sinchClient = [Sinch clientWithApplicationKey:@"<833cb511-32c1-4efe-8e7d-fab211faa61d>"
//                                              applicationSecret:@"<8fpVvbie/EuCZYC444z1tQ==>"
//                                                environmentHost:@"sandbox.sinch.com"
//                                                         userId:@"1"];
//    
//    [sinchClient setSupportCalling:NO];
//    [sinchClient setSupportMessaging:YES];
//    [sinchClient setSupportActiveConnectionInBackground:YES];
//    [sinchClient setSupportPushNotifications:YES];
//    
//    id<SINMessageClient> messageClient = [sinchClient messageClient];
//    messageClient.delegate = self;
//    
//    SINOutgoingMessage *message = [SINOutgoingMessage messageWithRecipient:@"<recipient user id>" text:@"Hi there!"];
//                                   [messageClient sendMessage:message];
////}
//- (void) messageDelivered:(id<SINMessageDeliveryInfo>)info {
//    NSLog(@"Message with id %@ was delivered to recipient with id  %@",
//          info.messageId,
//          info.recipientId);
//}
//- (void) messageDeliveryFailed:(id<SINMessage>) message info:(NSArray *)messageFailureInfo {
//    for (id<SINMessageFailureInfo> reason in messageFailureInfo) {
//        NSLog(@"Delivering message with id %@ failed to user %@. Reason %@",
//              reason.messageId, reason.recipientId, [reason.error localizedDescription]);
//    }
//}
//- (void) messageClient:(id<SINMessageClient>) messageClient
//didReceiveIncomingMessage:(id<SINMessage>)message {
//    // Present a Local Notification if app is in background
//    if([UIApplication sharedApplication].applicationState == UIApplicationStateBackground){
//        UILocalNotification* notification = [[UILocalNotification alloc] init];
//        notification.alertBody = [NSString stringWithFormat:@"Message from %@",
//                                  [message recipientIds][0]];
//        [[UIApplication sharedApplication] presentLocalNotificationNow:notification];
//    } else {
//        // Update UI in-app
//    }
//    // Persist incoming message
//}
//-(void)sendToMultiple
//{
//    NSArray *recipients = @[@"recipient user id 1", @"recipient user id 2"];
//    SINOutgoingMessage *message = [SINOutgoingMessage messageWithRecipients:recipients text:@"Hi there!"];
//    //[messageClient sendMessage:message];
//}

- (void)createNewGroupWith:(NSString*)needs andThisMany:(int) thisMany
{
    //URL
    NSString *fixedUrl = [NSString stringWithFormat:@"http://api.polleverywhere.com/free_text_polls"];
    NSURL *url = [NSURL URLWithString:fixedUrl];
    //Session
    NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession *session = [NSURLSession sessionWithConfiguration:config];
    //Request
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [request setValue:[NSString stringWithFormat:@"Basic %@",[self encoder:@"masakazuband823:2127512qwerty"]] forHTTPHeaderField:@"Authorization"];
    request.HTTPMethod = @"POST";
    //Data Task Block
    NSError *error = nil;
    
    NSMutableDictionary* sendObjInside = [NSMutableDictionary dictionary];
    [sendObjInside setObject:@"give me eggs" forKey:@"title"];
    
    NSMutableDictionary* sendObj = [NSMutableDictionary dictionary];
    [sendObj setObject:sendObjInside forKey:@"free_text_poll"];
    
    NSData *data = [NSJSONSerialization dataWithJSONObject:sendObj
                                                   options:kNilOptions
                                                     error:&error];
    if (!error)
    {
        NSURLSessionUploadTask *uploadTask =
        [session uploadTaskWithRequest:request
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
                                    NSDictionary *fetchedData = [NSJSONSerialization JSONObjectWithData:data
                                                                                           options:0
                                                                                             error:nil];
                                    NSDictionary *fetchedInfo = fetchedData[@"free_text_poll"];
                                    
                                    [self saveRequestWithItem:needs withGoal:thisMany withPollid:fetchedInfo[@"permalink"]];

                                    NSLog(@"Success");
                                });
                 NSLog(@"Success");
             }//if
             else
             {
                 NSLog(@"Failing");
             }
         }];//Upload task Block
        [uploadTask resume];
        NSLog(@"Connected to server");
    }
    else
    {
        NSLog(@"Cannot connect to server");
    }
}-(void)saveRequestWithItem:(NSString*)item withGoal:(int)goal withPollid:(NSString*)pollid
{
    NSManagedObjectContext *context = ((AppDelegate *)[UIApplication sharedApplication].delegate).managedObjectContext;
    
    NSEntityDescription *entityDescription = [NSEntityDescription entityForName:@"Group" inManagedObjectContext:context];
    
    
    Group *newGroup = [[Group alloc] initWithEntity:entityDescription insertIntoManagedObjectContext:context];
    
    
    [newGroup setValue:item forKey:@"item"];
    [newGroup setValue:@(goal) forKey:@"goal"];
    [newGroup setValue:pollid forKey:@"pollid"];
    
    NSError *error = nil;
    
    if (![context save:&error]) {
        NSLog(@"Unable to save managed object context.");
        NSLog(@"%@, %@", error, error.localizedDescription);
    }
    else
    {
        NSLog(@"Saved");
        [self performSegueWithIdentifier:@"Save" sender:self];
        
    }

}
-(void)createGroup
{

    /*
    curl -X POST -H "Content-Type: application/json" -H "Accept: application/json" -H "Authorization: Basic YXBpdGVzdDphcGl0ZXN0" -d "{\
    \"free_text_poll\": {\"id\":null,\"updated_at\":null,\"title\":\"What is the meaning of life?\",\"opened_at\":null,\"permalink\":null,\"state\":null,\"sms_enabled\":null,\"twitter_enabled\":null,\"web_enabled\":null,\"sharing_enabled\":null,\"keyword\":null}\
    }" "http://api.polleverywhere.com/free_text_polls"
    */
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)torrentPressed:(id)sender {
    [self createNewGroupWith:self.itemTextField.text andThisMany:self.goalTextField.text.intValue];
}
@end
