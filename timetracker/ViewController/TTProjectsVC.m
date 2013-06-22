//
//  TTProjectsVC.m
//  timetracker
//
//  Created by Florian Goessler on 22.06.13.
//  Copyright (c) 2013 Florian Goessler. All rights reserved.
//

#import "TTProjectsVC.h"
#import "TTProject+TTExtension.h"
#import "TTAppDelegate.h"

@interface TTProjectsVC () <UITableViewDelegate, UITableViewDataSource, UIAlertViewDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (strong, nonatomic) NSArray *projects;

@end

@implementation TTProjectsVC

- (IBAction)newProjectBtnClicked:(id)sender {
	UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"New Project" message:@"Please enter a name for your awesome new project!" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Create", nil];
	alertView.alertViewStyle = UIAlertViewStylePlainTextInput;
	
	[alertView show];

}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
	
	if(buttonIndex != 1) return;
	
	NSManagedObjectContext *context = ((TTAppDelegate*)[[UIApplication sharedApplication] delegate]).managedObjectContext;
    TTProject *newManagedObject = [NSEntityDescription insertNewObjectForEntityForName:@"TTProject" inManagedObjectContext:context];
    
    newManagedObject.name = [alertView textFieldAtIndex:0].text;
	
	[((TTAppDelegate*)[[UIApplication sharedApplication] delegate]) saveContext];
	
	[self updateProjectList];
	[self.tableView reloadData];
}

- (void)viewDidLoad
{
    [super viewDidLoad];

	self.tableView.delegate = self;
	self.tableView.dataSource = self;
}

- (void)updateProjectList {
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"TTProject"];
	
	self.projects = [((TTAppDelegate*)[[UIApplication sharedApplication] delegate]).managedObjectContext executeFetchRequest:request error:nil];
}

-(void)viewWillAppear:(BOOL)animated {
	[self updateProjectList];
}


-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return self.projects.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	NSString* requesIdentifier = @"ProjectsCell";
	
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:requesIdentifier];
	
	if(cell == nil) {
		cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:requesIdentifier];
	}
	
	TTProject *project = [self.projects objectAtIndex:indexPath.row];
	cell.textLabel.text = project.name;
		
	return cell;
}

@end
