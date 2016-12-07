//
//  CKMessagesListController.m
//  click
//
//  Created by Igor Tetyuev on 07.04.16.
//  Copyright © 2016 Igor Tetyuev. All rights reserved.
//

#import "CKMessagesListController.h"
#import "MWPhoto.h"
#import "CKVideoAttachModel.h"
#import "CKPictureAttachModel.h"
#import "MWPhotoBrowser.h"
@import AVKit;

@interface CKMessagesListController()<MWPhotoBrowserDelegate>

@end

@interface CKMessagesTableView()

@property (nonatomic, assign) BOOL ignoreInset;

@end

@implementation CKMessagesTableView {
    double _bottomOffset;
    BOOL _disableStoring;
    BOOL _isSimultaneousDraggingEnabled;
    BOOL _fixBottom;
    UIPanGestureRecognizer *_panGestureRecognizer;
}
@synthesize disableStickyBottom = _disableStickyBottom, isManualScrollingEnabled = _isManualScrollingEnabled;

- (instancetype) init {
    if (self = [super init]) {
        _panGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panProcess:)];
        _panGestureRecognizer.delegate = self;
        _isSimultaneousDraggingEnabled = YES;
        [self addGestureRecognizer:_panGestureRecognizer];
    }
    return self;
}

- (BOOL) gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    return YES;
}

- (void) panProcess: (UIPanGestureRecognizer *) recognizer
{
    CGPoint lp = [recognizer locationInView:self];
    lp.y-=self.contentOffset.y;

    if (self.isManualScrollingEnabled) return;
    
    if (lp.y>(self.frame.size.height-self.contentInset.bottom)) {
        if (self.scrollEnabled) {
            [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionBeginFromCurrentState animations:^{
                self.scrollEnabled = NO;
            } completion:^(BOOL finished){
                
            }];
            [[NSNotificationCenter defaultCenter] postNotificationName:CKMessagesTableViewResignKeyboard object:self];
        }
    } else {
        self.scrollEnabled = YES;
        _bottomOffset = fmin(self.contentSize.height, self.contentOffset.y + (self.frame.size.height - self.contentInset.bottom - self.contentInset.top));
    }
}

- (void) setContentOffset:(CGPoint)contentOffset
{
    [super setContentOffset:contentOffset];
    if (_disableStoring) return;
    _bottomOffset = fmin(self.contentSize.height, self.contentOffset.y + (self.frame.size.height - self.contentInset.bottom - self.contentInset.top));
}

- (void) restoreBottomOffset
{
    if (self.disableStickyBottom) return;
    double topOffset = fmax(0, _bottomOffset - (self.frame.size.height - self.contentInset.bottom - self.contentInset.top));
    if (self.contentSize.height < (self.frame.size.height - self.contentInset.top - self.contentInset.bottom)) {
        topOffset = -self.contentInset.top;
    }

    [self setContentOffset:CGPointMake(0, topOffset) animated:NO];
}

- (void) setIsManualScrollingEnabled:(BOOL)isManualScrollingEnabled {
    _isManualScrollingEnabled = isManualScrollingEnabled;
    if (isManualScrollingEnabled) self.scrollEnabled = YES;
}

- (void) setDisableStickyBottom:(BOOL)disableStickyBottom
{
    _disableStickyBottom = disableStickyBottom;
    if (!_disableStickyBottom) {
        _bottomOffset = fmin(self.contentSize.height, self.contentOffset.y + (self.frame.size.height - self.contentInset.bottom - self.contentInset.top));
    }
}

- (void)setContentInset:(UIEdgeInsets)contentInset {
    if (self.ignoreInset) return;
    [super setContentInset:contentInset];
}

- (void) setMyContentInset:(UIEdgeInsets)contentInset
{
    _disableStoring = YES;
    [super setContentInset:contentInset];
    _disableStoring = NO;
    [self restoreBottomOffset];
}

- (void) setFrame:(CGRect)frame
{
    _disableStoring = YES;
    [super setFrame:frame];
    _disableStoring = NO;
    [self restoreBottomOffset];
}

- (void) scrollToBottom {
    [self setContentOffset:CGPointMake(0, self.contentSize.height-self.frame.size.height-self.contentInset.bottom) animated:YES];
}

@end


@implementation CKMessagesListController {
    BOOL _isVisible;
    BOOL _needReload;
    CKAttachModel *_selectedAttach;
    Message *_selectedMessage;
}

- (instancetype)init
{
    if (self = [super initWithStyle:UITableViewStylePlain])
    {
        
    }
    return self;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    _isVisible = YES;
    if (_needReload) {
        _needReload = NO;
        [self.tableView reloadData];
        [self scrollToLastMessage];
    }
    [(CKMessagesTableView *)self.tableView setIgnoreInset:YES];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    _isVisible = NO;
}

//- (void)viewDidAppear:(BOOL)animated {
//    [(CKMessagesTableView *)self.tableView setIgnoreInset:YES];
//}

- (void)loadView
{
    self.view = [UIView new];
    CKMessagesTableView *tableView = [CKMessagesTableView new];
    self.tableView = tableView;
    [self.tableView makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.estimatedRowHeight = 42.0;
    self.tableView.backgroundColor = CKClickProfileGrayColor;
    self.tableView.separatorColor = [UIColor clearColor];
    self.tableView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"bgwhite"]];
}

- (void)unobserve {
}

- (void)setMessages:(NSArray *)messages
{
    NSInteger row = 0;
    if (self.messages.count == 0) _needReload = YES;
    for (Message *message in messages) {
        @weakify(self);
        
        [[RACObserve(message, attachPreviewCounter) skip:1] subscribeNext:^(NSString* text)
        {
            @strongify(self);
            if (row < self.messages.count - 1) {
                [self.tableView reloadData];
//                [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:row inSection:0]] withRowAnimation:UITableViewRowAnimationFade];
            }
        }];

        row++;
    }
    _messages = messages;
    if (!_isVisible) {
        _needReload = YES;
        return;
    }
    [self.tableView reloadData];
    [self scrollToLastMessage];
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.messages.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CKMessageCell *cell = (CKMessageCell *)[self.tableView dequeueReusableCellWithIdentifier:@"CKMessageCell"];
    if (!cell)
    {
        cell = [CKMessageCell new];
        cell.delegate = self;
    }
    cell.message = self.messages[indexPath.row];
    return cell;
}

- (void) scrollToLastMessage
{
    if ([self tableView:self.tableView numberOfRowsInSection:0]==0) return;
    CKMessagesTableView *view = (CKMessagesTableView *)self.tableView;
    view.disableStickyBottom = YES;
    [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:[self tableView:self.tableView numberOfRowsInSection:0]-1 inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:NO];
    view.disableStickyBottom = NO;
}

- (void)attachementButtonPressedWithModel:(Message *)model attachNumber:(NSInteger)attachNumber {
    _selectedMessage = model;
    _selectedAttach = _selectedMessage.attachements[attachNumber];
    if (_selectedAttach.type == CKAttachTypeImage) {
        CKPictureAttachModel *picturemodel = (CKPictureAttachModel *)_selectedAttach;
        @weakify(self)
        [picturemodel prepareForDisplay:^(NSString *path) {
            @strongify(self)
            MWPhotoBrowser *browser = [[MWPhotoBrowser alloc] initWithDelegate:self];
            browser.displayActionButton = YES;
            browser.displayNavArrows = NO;
            browser.displaySelectionButtons = NO;
            browser.alwaysShowControls = NO;
            browser.zoomPhotosToFill = YES;
            browser.enableGrid = YES;
            browser.startOnGrid = NO;
            browser.enableSwipeToDismiss = YES;
            browser.autoPlayOnAppear = YES;
            [browser setCurrentPhotoIndex:0];
            UINavigationController *nc = [[UINavigationController alloc] initWithRootViewController:browser];
            nc.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
            [self presentViewController:nc animated:YES completion:nil];
        }];
    }
    else if (_selectedAttach.type == CKAttachTypeVideo){
        CKVideoAttachModel *videomodel = (CKVideoAttachModel *)_selectedAttach;
        @weakify(self)
        [videomodel prepareForDisplay:^(NSString *path) {
            @strongify(self)
            AVPlayerViewController *moviePlayerView = [AVPlayerViewController new];
            moviePlayerView.player = [AVPlayer playerWithURL:[NSURL fileURLWithPath:videomodel.localPath]];
            [moviePlayerView.player play];
            [self presentViewController:moviePlayerView animated:YES completion:^{}];
        }];
    }
}

- (NSUInteger)numberOfPhotosInPhotoBrowser:(MWPhotoBrowser *)photoBrowser {
    return 1;
}

- (id <MWPhoto>)photoBrowser:(MWPhotoBrowser *)photoBrowser photoAtIndex:(NSUInteger)index {
    CKPictureAttachModel *picturemodel = (CKPictureAttachModel *)_selectedAttach;
    MWPhoto *photo = [MWPhoto photoWithURL:[NSURL fileURLWithPath:picturemodel.localPath]];
    return photo;
}

@end
