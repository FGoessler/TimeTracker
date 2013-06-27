//
//  TTLinksVC.m
//  timetracker
//
//  Created by Florian Goessler on 22.06.13.
//  Copyright (c) 2013 Florian Goessler. All rights reserved.
//

#import "TTLinksVC.h"
#import "TTExternalSystemLinksDataSource.h"
#import "TTExternalSystemLinkDetailsVC.h"

@interface TTLinksVC () <UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) TTExternalSystemLinksDataSource *dataSource;
@property (strong, nonatomic) TTExternalSystemLink *selectedExternalSystemLink;
@end

@implementation TTLinksVC

- (IBAction)addLinkBtnClicked:(id)sender {
	[TTExternalSystemLink createNewExternalSystemLinkOfType:TT_SYS_TYPE_GITHUB];
}

-(void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath {
	self.selectedExternalSystemLink = [self.dataSource systemLinkAtIndexPath:indexPath];
	[self performSegueWithIdentifier:@"Show TTExternalSystemLinkDetailsVC" sender:self];
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
	if([segue.identifier isEqualToString:@"Show TTExternalSystemLinkDetailsVC"]) {
		TTExternalSystemLinkDetailsVC *destVC = (TTExternalSystemLinkDetailsVC*)[segue.destinationViewController topViewController];
		destVC.externalSystemLink = self.selectedExternalSystemLink;
	}
}

- (void)viewDidLoad
{
    [super viewDidLoad];

	self.tableView.delegate = self;
	self.dataSource = [[TTExternalSystemLinksDataSource alloc] initAsDataSourceOfTableView:self.tableView];
}

@end
