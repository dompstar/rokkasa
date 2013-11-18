//
//  Project.m
//  rokkasa
//
//  Created by Alexander Auer on 17.11.13.
//  Copyright (c) 2013 Alexander Auer. All rights reserved.
//

#import "Project.h"
#import "User.h"


@implementation Project

@dynamic objectId;
@dynamic projectName;
@dynamic createdAt;
@dynamic updatedAt;
@dynamic relUserProject;

-(NSString *)getProjectId {
    NSString *stringId = [[[self objectID] URIRepresentation] absoluteString];
    NSArray *components = [stringId componentsSeparatedByString:@"/p"];
    return [components lastObject];
}

@end
