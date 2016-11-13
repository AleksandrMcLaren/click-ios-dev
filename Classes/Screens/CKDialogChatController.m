//
//  CKDialogChatController.m
//  click
//
//  Created by Igor Tetyuev on 07.04.16.
//  Copyright © 2016 Igor Tetyuev. All rights reserved.
//

#import "CKDialogChatController.h"
#import "CKDialogChatModel.h"
#import "CKMessageEditorView.h"
#import "CKMessagesListController.h"
#import "CKAttachMenu.h"
#import "CKPictureAttachModel.h"
#import "CKVideoAttachModel.h"
#import "CKCloudAttachModel.h"

@interface CKDialogChatController()<UITextViewDelegate, UIDocumentPickerDelegate>

- (void) enableManualScrolling;
- (void) disableManualScrolling;
@property (nonatomic, strong) CKDialogChatModel *chat;

@end

@interface CKMessagesView : UIView

@property (nonatomic, strong) CKMessagesTableView *messages;
@property (nonatomic, strong) CKMessageEditorView *editView;
@property (nonatomic, strong) CKAttachMenu *attachView;
@property (nonatomic, assign) CKDialogChatController *controller;
@property (nonatomic, assign) BOOL isRotating;
@property (nonatomic, assign) BOOL isHidingKeyboard;

@end

@implementation CKMessagesView
{
    BOOL _isKeyboardHidden;
    BOOL _isAttachMenuShown;
    BOOL _disableEvents;
    double _keyboardPos;
    BOOL _animating;
}

- (instancetype) init
{
    if (self = [super init]) {
        _editView = [CKMessageEditorView new];
        _editView.hidden = NO;
        _attachView = [CKAttachMenu new];
        _attachView.hidden = YES;
        _isKeyboardHidden = YES;
        [self addSubview:_editView];
        [self addSubview:_attachView];
        [_editView makeConstraints:^(MASConstraintMaker *make) {
            make.width.equalTo(self.width);
            make.left.equalTo(0);
            make.bottom.equalTo(self.bottom);
        }];
        [_attachView makeConstraints:^(MASConstraintMaker *make) {
            make.width.equalTo(_editView);
            make.left.equalTo(_editView);
            make.top.equalTo(_editView.bottom);
            make.height.equalTo(225);
        }];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHideOrShow:) name:UIKeyboardWillHideNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHideOrShow:) name:UIKeyboardWillShowNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidHideOrShow:) name:UIKeyboardDidShowNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidHideOrShow:) name:UIKeyboardDidHideNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardFrameChanged:) name:UIKeyboardDidChangeFrameNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardFrameWillChange:) name:UIKeyboardWillChangeFrameNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(dismissKeyboard:) name:CKMessagesTableViewResignKeyboard object:nil];
        
    }
    return self;
}

- (void)dealloc {
    [_attachView removeFromSuperview];
    [_editView removeFromSuperview];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void) dismissKeyboard: (NSNotification *) note
{
    if (_editView.textView.isFirstResponder)
        dispatch_async(dispatch_get_main_queue(),^{
            [_editView.textView resignFirstResponder];
        });
}

- (void)keyboardDidHideOrShow:(NSNotification *)note
{
    NSLog(@"*** notif %@ %d", note.name, _isHidingKeyboard);
    if ([note.name isEqualToString:UIKeyboardDidShowNotification]) {
        [self.controller disableManualScrolling];
        _isKeyboardHidden = NO;
        _attachView.hidden = YES;
        _isAttachMenuShown = NO;
    } else {
        [self.controller enableManualScrolling];
        _isKeyboardHidden = YES;
    }
}

- (void)keyboardFrameWillChange:(NSNotification *)note
{
    CGRect screenRect    = [[[note userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    CGRect windowRect    = [self.window convertRect:screenRect fromWindow:nil];
    CGRect keyboardFrame      = [self        convertRect:windowRect fromView:nil];
    keyboardFrame = CGRectIntersection(self.bounds, keyboardFrame);
    _keyboardPos = keyboardFrame.size.height;
    NSLog(@"*** notif %@ %d", note.name, _isHidingKeyboard);
    NSLog(@"keyboard frame: %f,%f %fx%f", keyboardFrame.origin.x, keyboardFrame.origin.y, keyboardFrame.size.width, keyboardFrame.size.height);
}

- (void)keyboardWillHideOrShow:(NSNotification *)note
{
    NSDictionary *userInfo = note.userInfo;
    NSTimeInterval duration = [[userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    UIViewAnimationCurve curve = [[userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey] intValue];
    
    CGRect screenRect    = [[[note userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    CGRect windowRect    = [self.window convertRect:screenRect fromWindow:nil];
    CGRect keyboardFrame      = [self        convertRect:windowRect fromView:nil];
    keyboardFrame = CGRectIntersection(self.bounds, keyboardFrame);
    _keyboardPos = keyboardFrame.size.height;
    NSLog(@"*** notif %@", note.name);
    NSLog(@"*** curve %ld %ld", (long)curve, (long)UIViewAnimationCurveEaseIn);
    NSLog(@"keyboard frame: %f,%f %fx%f", keyboardFrame.origin.x, keyboardFrame.origin.y, keyboardFrame.size.width, keyboardFrame.size.height);
    
    [self updateConstraints];
    
    [UIView animateWithDuration:duration*2
                          delay:0
         usingSpringWithDamping:500.0f
          initialSpringVelocity:0.0f
                        options:UIViewAnimationOptionCurveLinear
                     animations:^{
                         _animating = YES;
                         [self layoutIfNeeded];
                     }
                     completion:^(BOOL finished){
                         if (!finished) return;
                         _animating = NO;
                         [self updateInsets];
                     }];
}


- (void) keyboardFrameChanged: (NSNotification *)note
{
    CGRect screenRect    = [[[note userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    CGRect windowRect    = [self.window convertRect:screenRect fromWindow:nil];
    CGRect keyboardFrame      = [self        convertRect:windowRect fromView:nil];
    keyboardFrame = CGRectIntersection(self.bounds, keyboardFrame);
    _keyboardPos = keyboardFrame.size.height;
    NSLog(@"*** notif %@", note.name);
    NSLog(@"keyboard frame: %f,%f %fx%f", keyboardFrame.origin.x, keyboardFrame.origin.y, keyboardFrame.size.width, keyboardFrame.size.height);
    if (!_animating) {
        [self updateInsets];
        [self updateConstraints];
    }
    _messages.userInteractionEnabled = YES;
}

- (void) setMessages:(UITableView *)messages
{
    _messages = (CKMessagesTableView *)messages;
    [self addSubview:_messages];
    [self sendSubviewToBack:_messages];

    [_messages makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self);
    }];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    double h = self.bounds.size.height - _editView.frame.origin.y;
    UIEdgeInsets contentInsets = UIEdgeInsetsMake(self.controller.topLayoutGuide.length, 0.0, h, 0.0);
    _messages.scrollIndicatorInsets = contentInsets;
    [_messages setMyContentInset:contentInsets];
}

- (void) updateConstraints
{
    [super updateConstraints];
    double kp = _isAttachMenuShown? 225 : _keyboardPos;
    [_editView remakeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.left);
        make.width.equalTo(self.width);
        make.bottom.equalTo(self.bottom).offset(-kp);
    }];
    [self layoutSubviews];
}

- (void)updateInsets
{
//    if (!self.controller.topLayoutGuide) return;
//    double kp = _isAttachMenuShown? 225 : _keyboardPos;
//    double h = kp + _editView.frame.size.height;
//    UIEdgeInsets contentInsets = UIEdgeInsetsMake(self.controller.topLayoutGuide.length, 0.0, h, 0.0);
//    [_messages setMyContentInset:contentInsets];
//    _messages.scrollIndicatorInsets = contentInsets;
//    [_messages reloadData];
}

- (void) updateInputFrame
{
    [self updateInsets];
    [_editView updateConstraints];
}

- (void)toggleMedia {
    _isAttachMenuShown = !_isAttachMenuShown;
    if (_isAttachMenuShown) {
        if (_isKeyboardHidden) {
            _keyboardPos = 225;
            _attachView.hidden = NO;
            [self updateConstraints];
            [UIView animateWithDuration:0.3
                                  delay:0
                 usingSpringWithDamping:500.0f
                  initialSpringVelocity:0.0f
                                options:UIViewAnimationOptionCurveLinear
                             animations:^{
                                 _animating = YES;
                                 [self layoutIfNeeded];
                             }
                             completion:^(BOOL finished){
                                 if (!finished) return;
                                 _animating = NO;
                                 [self updateInsets];
                             }];
        } else
        {
            [self dismissKeyboard:nil];
            _attachView.hidden = NO;
        }
    } else
    {
        if (_isKeyboardHidden) {
            _keyboardPos = 0;
            [self updateConstraints];
            
            [UIView animateWithDuration:0.3
                                  delay:0
                 usingSpringWithDamping:500.0f
                  initialSpringVelocity:0.0f
                                options:UIViewAnimationOptionCurveLinear
                             animations:^{
                                 _animating = YES;
                                 [self layoutIfNeeded];
                             }
                             completion:^(BOOL finished){
                                 if (!finished) return;
                                 _animating = NO;
                                 _attachView.hidden = YES;
                                 [self updateInsets];
                             }];
        } else
        {
            _attachView.hidden = YES;
        }
    }
}


@end

@implementation CKDialogChatController
{
    NSString *_dialogId;
    NSString *_userId;
    CKMessagesView *_messagesView;
    CKPictureCaptureManager *_pictureCapture;
}
@dynamic chat;

- (instancetype)initWithDialogId:(NSString *)dialogId
{
    if (self = [super init])
    {
        self.hidesBottomBarWhenPushed = YES;
        _dialogId = dialogId;
        CKDialogChatModel *chat = [[CKDialogChatModel alloc] initWithDialogId:dialogId];
        self.chat = chat;
        @weakify(self);
        [[RACObserve(self.chat, attachements) takeUntil:self.rac_willDeallocSignal] subscribeNext:^(id x) {
            @strongify(self);
            _messagesView.editView.attachements = self.chat.attachements;
            [_messagesView updateInputFrame];
        }];
    }
    return self;
}

- (instancetype)initWithUserId:(NSString *)userId
{
    if (self = [super init])
    {
        self.hidesBottomBarWhenPushed = YES;
        _userId = userId;
        CKDialogChatModel *chat = [[CKDialogChatModel alloc] initWithUserId:userId];
        self.chat = chat;
        @weakify(self);
        [[RACObserve(self.chat, attachements) takeUntil:self.rac_willDeallocSignal] subscribeNext:^(id x) {
            @strongify(self);
            _messagesView.editView.attachements = self.chat.attachements;
            [_messagesView updateInputFrame];
        }];
    }
    return self;
}

- (void)loadView
{
    _messagesView = [CKMessagesView new];
    _messagesView.editView.chat = self.chat;
    _messagesView.controller = self;
    self.view = _messagesView;
    
    self.messagesList = [CKMessagesListController new];
    [self addChildViewController:self.messagesList];
    _messagesView.messages = self.messagesList.tableView;
//    if (self.chat.messages) self.messagesList.messages = self.chat.messages;

    _messagesView.editView.textView.delegate = self;
    [_messagesView.editView.sendButton addTarget:self action:@selector(send:) forControlEvents:UIControlEventTouchUpInside];
    [_messagesView.editView.showMediaButton addTarget:self action:@selector(media:) forControlEvents:UIControlEventTouchUpInside];
    [_messagesView.editView addTarget:self action:@selector(clickOnMessagesView:) forControlEvents:UIControlEventTouchDragInside];
    [_messagesView.attachView.hideButton addTarget:self action:@selector(media:) forControlEvents:UIControlEventTouchUpInside];
    [_messagesView.attachView.photosButton addTarget:self action:@selector(takePhotoAlbum) forControlEvents:UIControlEventTouchUpInside];
    [_messagesView.attachView.cameraButton addTarget:self action:@selector(takePhoto) forControlEvents:UIControlEventTouchUpInside];
    [_messagesView.attachView.cloudButton addTarget:self action:@selector(attachCloud) forControlEvents:UIControlEventTouchUpInside];
    self.navigationController.automaticallyAdjustsScrollViewInsets = NO;
}

- (void)takePhoto
{
    _pictureCapture = [CKPictureCaptureManager new];
    _pictureCapture.controller = self;
//    __weak CKDialogChatController *myself = self;
    _pictureCapture.cameraOnly = YES;
    _pictureCapture.albumsOnly = NO;
    [_pictureCapture captureWithCallback:^(UIImage* image, UIImage *preview, NSURL *path){
        // image captured
        NSLog(@"image: %@", image);
        _messagesView.editView.hidden = NO;
        if (image && !path) {
            CKPictureAttachModel *model = [CKPictureAttachModel new];
            model.image = image;
            [self.chat addAttachement:model];
        }
        if (path) {
            CKVideoAttachModel *model = [CKVideoAttachModel new];
            model.url = path;
            model.preview = preview;
            [self.chat addAttachement:model];
        }
        _pictureCapture = nil;
    }
     ];
}

- (void)takePhotoAlbum {
    _pictureCapture = [CKPictureCaptureManager new];
    _pictureCapture.controller = self;
    _pictureCapture.cameraOnly = NO;
    _pictureCapture.albumsOnly = YES;
//    __weak CKDialogChatController *myself = self;
    [_pictureCapture captureWithCallback:^(UIImage* image, UIImage *preview, NSURL *path){
        // image captured
        _messagesView.editView.hidden = NO;
        if (image && !path) {
            CKPictureAttachModel *model = [CKPictureAttachModel new];
            model.image = image;
            [self.chat addAttachement:model];
        }
        if (path) {
            CKVideoAttachModel *model = [CKVideoAttachModel new];
            model.url = path;
            model.preview = preview;
            [self.chat addAttachement:model];
        }
        _pictureCapture = nil;
        NSLog(@"image: %@", image);
    }
     ];
}

- (void)attachCloud {
    UIDocumentPickerViewController *documentPicker = [[UIDocumentPickerViewController alloc] initWithDocumentTypes:@[@"public.content"] inMode:UIDocumentPickerModeImport];
                                                      documentPicker.delegate = self;
                                                      documentPicker.modalPresentationStyle = UIModalPresentationFormSheet;
                                                      [self presentViewController:documentPicker animated:YES completion:nil];
}

- (void)documentPicker:(UIDocumentPickerViewController *)controller didPickDocumentAtURL:(NSURL *)url {
    CKCloudAttachModel *model = [CKCloudAttachModel new];
    model.url = url;
    model.preview = [UIImage imageNamed:@"attachcloud"];
    [self.chat addAttachement:model];
}

- (void)viewDidAppear:(BOOL)animated
{
    [_messagesView updateInsets];
}

- (void)viewDidLoad
{
    if (_wentFromTheMap == true)
    {
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Назад" style: UIBarButtonItemStylePlain target:self action:@selector(backToMap)];
    }
}

- (void)media:(id) button {
    [_messagesView toggleMedia];
}

- (void) send:(id) button
{
    NSString *text = [_messagesView.editView.textView.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    [self.chat sendMessage:text?text:@""];
    _messagesView.editView.textView.text = nil;
}

- (void) clickOnMessagesView: (CKMessageEditorView *) editorView
{
    if (!editorView.textView.isFirstResponder) [editorView.textView becomeFirstResponder];
}

- (void) textViewDidChange:(UITextView *)textView
{
    CKMessagesView *view = (CKMessagesView *)self.view;
    NSString *text = textView.text;
    
    view.editView.sendButton.enabled = [text length]!=0 || self.chat.attachements.count > 0;
    
    [view updateInputFrame];
    CGRect rect = [textView caretRectForPosition:textView.selectedTextRange.end];
    rect.size.height += textView.textContainerInset.bottom;
    [textView scrollRectToVisible:rect animated:NO];
}

- (void) textViewDidChangeSelection:(UITextView *)textView
{
    CGRect rect = [textView caretRectForPosition:textView.selectedTextRange.end];
    rect.size.height += textView.textContainerInset.bottom;
    [textView scrollRectToVisible:rect animated:NO];
}

- (BOOL) textViewShouldBeginEditing:(UITextView *)textView
{
    return YES;
}

- (BOOL) textViewShouldEndEditing:(UITextView *)textView
{
    return YES;
}


- (void) enableManualScrolling {
//    self.messagesTable.isManualScrollingEnabled = YES;
}

- (void) disableManualScrolling {
//    self.messagesTable.isManualScrollingEnabled = NO;
    
}

- (void) backToMap
{
    [self dismissViewControllerAnimated:YES completion:nil];
}
@end
