//
//  MLChatMessageListViewController.m
//  click
//
//  Created by Aleksandr on 02/02/2017.
//  Copyright © 2017 Click. All rights reserved.
//

#import "MLChatMessageListViewController.h"
#import "MLChatTableViewCell.h"

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
        self.tableView.contentInset = UIEdgeInsetsMake(64, 0, 0, 0);
        
        self.messages = [[NSMutableArray alloc] init];
    }
    
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.tableView.backgroundColor = [UIColor clearColor];
    [self.tableView registerClass:MLChatTableViewCell.class forCellReuseIdentifier:@"Cell"];
}

- (void)addMessages:(NSArray *)messages
{
    [self.messages addObjectsFromArray:messages];
    
    [self.tableView reloadData];
    
    if(self.messages.count)
    {
        [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:self.messages.count - 1 inSection:0]
                         atScrollPosition:UITableViewScrollPositionBottom
                                 animated:NO];
    }
}

- (void)addMessage:(MLChatMessageModel *)message
{
    NSIndexPath *rowPath = [NSIndexPath indexPathForRow:self.messages.count inSection:0];
    __weak typeof(self) weakSelf = self;
    
    [CATransaction begin];
    
    [CATransaction setCompletionBlock:^{
      //  dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf.tableView scrollToRowAtIndexPath:rowPath
                                  atScrollPosition:UITableViewScrollPositionTop
                                          animated:YES];
      //  });
    }];
    
    
    [self.tableView beginUpdates];
    [self.messages addObject:message];
    [self.tableView insertRowsAtIndexPaths:@[rowPath] withRowAnimation:UITableViewRowAnimationNone];
    [self.tableView endUpdates];
    
    [CATransaction commit];
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

- (CGFloat)contentMaxOrdinateOffSet
{
    return (self.tableView.contentSize.height - self.tableView.frame.size.height);
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    return self.messages.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellId = @"Cell";
    MLChatTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
    cell.message = self.messages[indexPath.row];
    
    return cell;
}

@end
