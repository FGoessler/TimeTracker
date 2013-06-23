//
// Based on: http://stackoverflow.com/questions/13305298/unit-test-for-nsmanagedobject-ghunit
// Created by Florian Goessler on 05.06.13.
// Copyright (c) 2013 Florian Goessler. All rights reserved.
//


#import "TTCoreDataTest.h"
#import "TTAppDelegate.h"


@implementation TTCoreDataTest {
	NSManagedObjectModel *_mom;
	NSPersistentStoreCoordinator *_psc;
	NSManagedObjectContext *_moc;
	NSPersistentStore *_store;
}

@synthesize managedObjectContext = _moc;

- (void)setUp {
	[super setUp];
	
	NSArray *bundles = [NSArray arrayWithObject:[NSBundle mainBundle]];
	_mom = [NSManagedObjectModel mergedModelFromBundles:bundles];
	_psc = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:_mom];
	
	_store = [_psc addPersistentStoreWithType:NSInMemoryStoreType configuration:nil URL:nil options:nil error:NULL];
	STAssertNotNil(_store,@"Unable to create in-memory store");
	
	_moc = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
	[_moc setPersistentStoreCoordinator:_psc];
		
	((TTAppDelegate*)[[UIApplication sharedApplication] delegate]).managedObjectContext = _moc;
}

- (void)tearDown {
	_mom = nil; _psc = nil; _moc = nil; _store = nil;
	[super tearDown];
}

@end
