//
//  User.h
//  rokkasa
//
//  Created by Alexander Auer on 17.11.13.
//  Copyright (c) 2013 Alexander Auer. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Project;

@interface User : NSManagedObject

@property (nonatomic, retain) NSString * objectId;
@property (nonatomic, retain) NSDate * createdAt;
@property (nonatomic, retain) NSDate * updatedAt;
@property (nonatomic, retain) NSString * firstname;
@property (nonatomic, retain) NSString * lastname;
@property (nonatomic, retain) NSString * email;
@property (nonatomic, retain) NSString * phone;
@property (nonatomic, retain) NSString * mobile;
@property (nonatomic, retain) NSSet *relUserProject;
-(NSString *)getUserId;
@end

@interface User (CoreDataGeneratedAccessors)

- (void)addRelUserProjectObject:(Project *)value;
- (void)removeRelUserProjectObject:(Project *)value;
- (void)addRelUserProject:(NSSet *)values;
- (void)removeRelUserProject:(NSSet *)values;

@end
