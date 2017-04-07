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
@property (nonatomic, strong) UITapGestureRecognizer *tapRecognizer;


@end

@implementation MLChatMessageListViewController

- (instancetype)init
{
    self = [super init];
    
    if(self)
    {
        self.heightCellAtIndexPath = [[NSMutableDictionary alloc] init];
        self.messages = [[NSMutableArray alloc] init];
    }
    
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.tableView.estimatedRowHeight = 44.f;
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.contentInset = UIEdgeInsetsMake(64, 0, 0, 0);
    self.tableView.separatorColor = [UIColor clearColor];
    self.tableView.showsVerticalScrollIndicator = NO;
    self.tableView.backgroundColor = [UIColor clearColor];
    [self.tableView registerClass:MLChatTableViewCell.class forCellReuseIdentifier:@"Cell"];

    self.tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapped)];
    [self.view addGestureRecognizer:self.tapRecognizer];
    
    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl addTarget:self
                            action:@selector(reloadData)
                  forControlEvents:UIControlEventValueChanged];

    [self reloadData];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.3 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        
        if(!self.messages.count)
            [self beginRefreshing];
    });
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    
    if(!self.tableView.tableHeaderView)
    {
        self.tableView.tableHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 5)];
    }
}

#pragma mark - Data

- (void)reloadData
{
    [self.delegate chatMessageListViewControllerNeedsReloadData];
}

- (void)reloadMessages:(NSArray *)messages animated:(BOOL)animated
{
    [self.refreshControl endRefreshing];
    
    [self.messages removeAllObjects];
    [self.messages addObjectsFromArray:messages];
    [self.tableView reloadData];
    
    if(self.messages.count)
    {
        [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:self.messages.count - 1 inSection:0]
                              atScrollPosition:UITableViewScrollPositionBottom
                                      animated:animated];
    }
}

- (void)addMessage:(MLChatMessage *)message
{
    __weak typeof(self) weakSelf = self;
    
    void (^addMessage)() = ^() {
        
        if(!weakSelf)
            return;
        
        NSIndexPath *rowPath = [NSIndexPath indexPathForRow:weakSelf.messages.count inSection:0];
        
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
    };
    
    addMessage();
}

- (void)insertTopMessages:(NSArray *)messages
{
    [self.refreshControl endRefreshing];
   
    if(!messages || !messages.count)
        return;

    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.3 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
                   
        NSMutableArray *paths = [[NSMutableArray alloc] init];
        
        for(NSInteger i = 0; i < messages.count; i++)
        {
            NSIndexPath *path = [NSIndexPath indexPathForRow:i inSection:0];
            [paths addObject:path];
        }

        CGFloat initialOffset = self.tableView.contentOffset.y;
        NSIndexSet *indexSet = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, messages.count)];
        NSIndexPath *topIndexPath = [NSIndexPath indexPathForRow:messages.count inSection:0];
        
        [self.messages insertObjects:messages atIndexes:indexSet];
        [self.tableView reloadData];
        
        [self.tableView scrollToRowAtIndexPath:topIndexPath
                              atScrollPosition:UITableViewScrollPositionTop
                                      animated:NO];
        self.tableView.contentOffset = CGPointMake(0, self.tableView.contentOffset.y + initialOffset);
    });
}

- (void)beginRefreshing
{
    [self.refreshControl layoutIfNeeded];
    [self.refreshControl beginRefreshing];
    
    [UIView animateWithDuration:0.25
                          delay:0
                        options:UIViewAnimationOptionBeginFromCurrentState
                     animations:^(void){
                         self.tableView.contentOffset = CGPointMake(0, self.tableView.contentOffset.y - self.refreshControl.frame.size.height);
                     } completion:^(BOOL finished){
           
                     }];
}

- (void)endRefreshing
{
    self.tableView.contentOffset = CGPointMake(0, self.tableView.contentOffset.y + self.refreshControl.frame.size.height);
    [self.refreshControl endRefreshing];
//    self.refreshControl = nil;
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

#pragma mark - Actions

- (void)tapped
{
    [self.delegate chatMessageListViewControllerTapped];
}

@end
