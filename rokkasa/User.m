//
//  User.m
//  rokkasa
//
//  Created by Alexander Auer on 17.11.13.
//  Copyright (c) 2013 Alexander Auer. All rights reserved.
//

#import "User.h"
#import "Project.h"


@implementation User

@dynamic objectId;
@dynamic createdAt;
@dynamic updatedAt;
@dynamic firstname;
@dynamic lastname;
@dynamic email;
@dynamic phone;
@dynamic mobile;
@dynamic relUserProject;

-(NSString *)getUserId {
    NSString *stringId = [[[self objectID] URIRepresentation] absoluteString];
    NSArray *components = [stringId componentsSeparatedByString:@"/p"];
    return [components lastObject];
}


@end
