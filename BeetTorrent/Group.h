//
//  Group.h
//  BeetTorrent
//
//  Created by sloot on 10/26/14.
//  Copyright (c) 2014 sloot. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Group : NSManagedObject

@property (nonatomic, retain) NSString * pollid;
@property (nonatomic, retain) NSNumber * goal;
@property (nonatomic, retain) NSString * item;

@end
