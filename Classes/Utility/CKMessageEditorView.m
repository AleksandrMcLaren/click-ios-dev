//
//  CKMessageEditorView.m
//  click
//
//  Created by Igor Tetyuev on 08.04.16.
//  Copyright © 2016 Igor Tetyuev. All rights reserved.
//

#import "CKMessageEditorView.h"
#import "CKAttachCell.h"

@implementation CKMessageEditorView {
    UICollectionView *_collectionView;
}

- (instancetype) init
{
    if (self = [super init]) {
        
        self.textView = [UITextView new];
        
        self.textView.textColor = [UIColor blackColor];
        self.textView.scrollIndicatorInsets = UIEdgeInsetsMake(13, 0, 8, 6);
        self.textView.scrollsToTop = NO;
        self.textView.font = [UIFont systemFontOfSize:12.0];
        self.textView.text = @"";
        self.textView.backgroundColor = [UIColor whiteColor];
        self.textView.layer.borderColor = [[UIColor lightGrayColor] CGColor];
        self.textView.layer.borderWidth = 1.0;
        self.textView.layer.cornerRadius = 4.0;
        [self addSubview:self.textView];
        
        _sendButton = [UIButton new];
        [_sendButton setImage:[UIImage imageNamed:@"plane"] forState:UIControlStateNormal];
        [_sendButton setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
        [_sendButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateDisabled];
        _sendButton.enabled = NO;
        [self addSubview:_sendButton];
        self.backgroundColor = [UIColor colorFromHexString:@"#f8f8f8"];
        
        _showMediaButton = [UIButton new];
        [_showMediaButton setImage:[UIImage imageNamed:@"keyboard"] forState:UIControlStateNormal];
        _showMediaButton.imageView.contentMode = UIViewContentModeScaleAspectFit;
        [_showMediaButton setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
        [_showMediaButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateDisabled];
        _showMediaButton.enabled = YES;
        [self addSubview:_sendButton];
        [self addSubview:_showMediaButton];
        
        [self.textView makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.left).offset(32);
            make.top.equalTo(self.top).offset(8);
            make.bottom.equalTo(self.bottom).offset(-8);
            make.right.equalTo(self.right).offset(-64);
            make.height.greaterThanOrEqualTo(32);
        }];
        [_sendButton makeConstraints:^(MASConstraintMaker *make) {
            make.bottom.equalTo(self.bottom).offset(-8);
            make.right.equalTo(self.right).offset(-16);
        }];
        [_showMediaButton makeConstraints:^(MASConstraintMaker *make) {
            make.width.equalTo(32);
            make.height.equalTo(32);
            make.bottom.equalTo(self.bottom).offset(-8);
            make.left.equalTo(self.left).offset(16);
        }];
        UICollectionViewFlowLayout *collectionViewFlowControl = [UICollectionViewFlowLayout new];
        collectionViewFlowControl.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        _collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:collectionViewFlowControl];
        _collectionView.delegate = self;
        _collectionView.backgroundColor = [UIColor clearColor];
        _collectionView.dataSource = self;
        [_collectionView registerClass:[CKAttachCell class] forCellWithReuseIdentifier:@"CKAttachCell"];
        [self addSubview:_collectionView];
        [_collectionView makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self);
            make.right.equalTo(self);
            make.top.equalTo(self);
            make.height.equalTo(0);
        }];
        
    }
    return self;
}

- (void)setAttachements:(NSMutableArray *)attachements {
    _attachements = attachements;
    [_collectionView reloadData];
    [self updateConstraints];
}

- (void)updateConstraints
{
    [super updateConstraints];
    CGFloat attachHeight = _attachements.count > 0 ? 72:0;
    CGFloat height = self.textView.contentSize.height;
    height = fmin(fmax(31, height), self.textView.font.lineHeight*5);
    [_collectionView remakeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self);
        make.right.equalTo(self);
        make.top.equalTo(self);
        make.height.equalTo(attachHeight);
    }];
    [self.textView remakeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.left).offset(64);
        make.top.equalTo(self.top).offset(8 + attachHeight);
        make.bottom.equalTo(self.bottom).offset(-8);
        make.right.equalTo(self.right).offset(-64);
        make.height.greaterThanOrEqualTo(height);
    }];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    CKAttachCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"CKAttachCell" forIndexPath:indexPath];
    cell.model = _attachements[indexPath.item];
    cell.deleteButton.tag = indexPath.item;
    [cell.deleteButton addTarget:self action:@selector(delete:) forControlEvents:UIControlEventTouchUpInside];
    return cell;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return _attachements.count;
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}


- (CGSize)collectionView:(UICollectionView *)collectionView
                  layout:(UICollectionViewLayout *)collectionViewLayout
  sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return CGSizeMake(64, 64);
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView
                        layout:(UICollectionViewLayout *)collectionViewLayout
        insetForSectionAtIndex:(NSInteger)section {
    return UIEdgeInsetsMake(4, 4, 4, 4);
}

- (CGFloat)collectionView:(UICollectionView *)collectionView
                   layout:(UICollectionViewLayout *)collectionViewLayout
minimumLineSpacingForSectionAtIndex:(NSInteger)section {
    return 8.0f;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView
                   layout:(UICollectionViewLayout *)collectionViewLayout
minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
    return 8.0f;
}

- (void)delete:(UIButton *)sender {
    [self.chat deleteAttachementAt:sender.tag];
    [self updateConstraints];
}

@end
