//
//  Task.h
//  DeprocastinatorCoreData
//
//  Created by Achyut Kumar Maddela on 15/09/15.
//  Copyright (c) 2015 iAKM. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Task : NSManagedObject

@property (nonatomic, retain) NSNumber * displayOrder;
@property (nonatomic, retain) NSString * taskName;
@property (nonatomic, retain) NSNumber * priority;
@property (nonatomic, retain) NSNumber * isChecked;

@end
