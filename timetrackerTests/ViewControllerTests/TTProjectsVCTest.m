//
//  TTProjectsVCTest.m
//  timetracker
//
//  Created by Florian Goessler on 22.06.13.
//  Copyright (c) 2013 Florian Goessler. All rights reserved.
//

#import "TTProjectsVCTest.h"
#import "TTProjectsVC.h"

@implementation TTProjectsVCTest {
	TTProjectsVC* projectsVC;
}

- (void)setUp
{
    [super setUp];
    
	projectsVC = [[TTProjectsVC alloc] init];
}

- (void)tearDown
{
	projectsVC = nil;
	
    [super tearDown];
}

- (void)testThatItHasATableView
{
	//TODO STFail(@"unimplemented test!");
}

- (void)testThatCreatesAProjectDataManager
{
	//TODO STFail(@"unimplemented test!");
}

- (void)testToCreateANewProject
{
	//TODO STFail(@"unimplemented test!");
}

@end
