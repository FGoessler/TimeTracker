//
//  TTProjectSettingsVC.m
//  timetracker
//
//  Created by Florian Goessler on 22.06.13.
//  Copyright (c) 2013 Florian Goessler. All rights reserved.
//

#import "TTProjectSettingsVC.h"
#import "TTLinksVC.h"
#import "TTAppDelegate.h"

@interface TTProjectSettingsVC ()
@property (weak, nonatomic) IBOutlet UITextField *projectNameTextField;
@property (weak, nonatomic) IBOutlet UILabel *externaLinkLbl;

@end

@implementation TTProjectSettingsVC
- (IBAction)doneBtnClicked:(id)sender {	
	//change data and save it
	self.project.name = self.projectNameTextField.text;
	
	BOOL saved = [((TTAppDelegate*)[[UIApplication sharedApplication] delegate]) saveContextWithErrorHandler:^BOOL(NSError *err) {
		if([[err userInfo][@"NSValidationErrorKey"] isEqualToString:@"name"]) {
			//show a message to inform the user about the invalid name
			UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Invalid data" message:@"The name you entered for the project is invalid!" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
			[alertView show];
			
			return true;	//the error could be handled - do not crash the app!
		}
		return false;	//another error occurred - let the default routine handle this (most likely it crashes the app)
	}];
	
	//dismiss this ViewController if data was saved
	if(saved) {
		[self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
	}
}
- (IBAction)cancelBtnClicked:(id)sender {
	//reset all changes
	[((TTAppDelegate*)[[UIApplication sharedApplication] delegate]).managedObjectContext rollback];
	
	//dismiss this ViewController
	[self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
	if([segue.identifier isEqualToString:@"Show ChangeExternalLink"]) {
		TTLinksVC *destVC = (TTLinksVC*)[segue.destinationViewController topViewController];
		destVC.projectToSelectLinkFor = self.project;
	}
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
	
	[self updateViews];
}

-(void)updateViews {
	self.projectNameTextField.text = self.project.name;
	if(self.project.parentSystemLink != nil) {
		self.externaLinkLbl.text = [NSString stringWithFormat:@"%@@%@ - %@", self.project.parentSystemLink.username, self.project.parentSystemLink.type, self.project.externalSystemUID];
	} else {
		self.externaLinkLbl.text = @"no system link configured";
	}
}

#pragma  mark tableView Delegate

-(void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
	[self.projectNameTextField resignFirstResponder];
}

-(void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath {
	if(indexPath.section == 1 && indexPath.row == 0) {
		[self performSegueWithIdentifier:@"Show ChangeExternalLink" sender:self];
	}
}

-(BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
	if(indexPath.section == 1 && indexPath.row == 0 && self.project.externalSystemUID != nil) {
		return YES;
	} else {
		return NO;
	}
}

-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
	if(editingStyle == UITableViewCellEditingStyleDelete) {
		[self.project.parentSystemLink removeChildProjectsObject:self.project];
		self.project.externalSystemUID = nil;
		
		[self updateViews];
	}
}

@end
