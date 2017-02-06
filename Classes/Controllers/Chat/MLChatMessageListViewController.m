//
//  MLChatMessageListViewController.m
//  click
//
//  Created by Aleksandr on 02/02/2017.
//  Copyright © 2017 Click. All rights reserved.
//

#import "MLChatMessageListViewController.h"
#import "MLChatTextCell.h"

@interface MLChatMessageListViewController ()

@property (nonatomic, strong) NSMutableArray *messages;

@end

@implementation MLChatMessageListViewController

- (instancetype)init
{
    self = [super init];
    
    if(self)
    {
        self.tableView.estimatedRowHeight = 44.f;
        self.tableView.rowHeight = UITableViewAutomaticDimension;
        
        self.messages = [[NSMutableArray alloc] init];
    }
    
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.tableView.backgroundColor = [UIColor clearColor];
    
    [self.tableView registerClass:MLChatTextCell.class forCellReuseIdentifier:@"Cell"];
}

- (void)addMessages:(NSArray *)messages
{
    [self.messages addObjectsFromArray:messages];
    
    [self.tableView reloadData];
}

#pragma mark - tableView contentOffset

- (CGFloat)contentOffSet
{
    return self.tableView.contentOffset.y;
}

- (void)setContentOffSet:(CGFloat)contentOffset
{
    [self.tableView setContentOffset:CGPointMake(0, contentOffset) animated:NO];
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    return self.messages.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellId = @"Cell";
    MLChatTextCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
    cell.message = self.messages[indexPath.row];
    
    return cell;
}

@end
