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
@property (nonatomic, strong) NSMutableDictionary *heightCellAtIndexPath;

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
        self.tableView.separatorColor = [UIColor clearColor];
        self.tableView.showsVerticalScrollIndicator = NO;
        
        self.refreshControl = [[UIRefreshControl alloc] init];
        
        self.heightCellAtIndexPath = [[NSMutableDictionary alloc] init];
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

- (void)viewDidLayoutSubviews
{
    if(!self.tableView.tableHeaderView)
    {
        self.tableView.tableHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 25)];
        
        if(!self.messages.count)
        {
            [UIView animateWithDuration:0.25
                                  delay:0
                                options:UIViewAnimationOptionBeginFromCurrentState
                             animations:^(void){
                                 self.tableView.contentOffset = CGPointMake(0, self.tableView.contentOffset.y - self.refreshControl.frame.size.height);
                             } completion:^(BOOL finished){
                                 [self.refreshControl beginRefreshing];
                             }];
        }
    }
}

- (void)addMessages:(NSArray *)messages
{
    if(messages.count)
    {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.25 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
            
            [self.messages addObjectsFromArray:messages];
            [self.tableView reloadData];
            
            [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:self.messages.count - 1 inSection:0]
                                  atScrollPosition:UITableViewScrollPositionBottom
                                          animated:NO];
            
            if(self.refreshControl)
            {
                [self.refreshControl endRefreshing];
                self.refreshControl = nil;
            }
        });
    }
}

- (void)addMessage:(MLChatMessage *)message
{
    void (^addMessage)() = ^() {
        
        NSIndexPath *rowPath = [NSIndexPath indexPathForRow:self.messages.count inSection:0];
        __weak typeof(self) weakSelf = self;
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            [CATransaction begin];
            
            [CATransaction setCompletionBlock:^{
                
                    [weakSelf.tableView scrollToRowAtIndexPath:rowPath
                                          atScrollPosition:UITableViewScrollPositionTop
                                                  animated:YES];
            }];

            [weakSelf.tableView beginUpdates];
            [weakSelf.messages addObject:message];
            [weakSelf.tableView insertRowsAtIndexPaths:@[rowPath]
                                  withRowAnimation:UITableViewRowAnimationNone];
            [weakSelf.tableView endUpdates];
            
            [CATransaction commit];
        });
    };
    
    addMessage();
    
    /*
    NSDate* newDate = [oldDate dateByAddingTimeInterval:0.3];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.3 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        addMessage();
    });
     */
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
    MLChatTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
    cell.message = self.messages[indexPath.row];
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSNumber *height = self.heightCellAtIndexPath[indexPath];
    
    if(height)
        return height.floatValue;
    else
        return UITableViewAutomaticDimension;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    self.heightCellAtIndexPath[indexPath] = @(cell.frame.size.height);
}

@end