//
//  MLChatCellTextViewController.m
//  click
//
//  Created by Aleksandr on 07/02/2017.
//  Copyright © 2017 Click. All rights reserved.
//

#import "MLChatCellTextViewController.h"
#import "MLChatLib.h"
#import <CoreText/CoreText.h>

@interface MLChatCellTextViewController ()

@property (nonatomic, strong) UILabel *label;

@property (nonatomic) CGSize textSize;
@property (nonatomic) UIEdgeInsets insets;
@property (nonatomic) CGFloat minWidth;

@end


@implementation MLChatCellTextViewController

- (instancetype)init
{
    self = [super init];
    
    if(self)
    {
        self.insets = UIEdgeInsetsMake(15, 15, 15, 15);
        self.minWidth = 120;
        
        self.label = [[UILabel alloc] init];
        self.label.textColor = [UIColor blackColor];
        self.label.font = [UIFont systemFontOfSize:16];
        self.label.numberOfLines = 0;
    }
    
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.view addSubview:self.label];
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    
    self.label.frame = CGRectMake(self.insets.left, self.insets.top, self.textSize.width, self.textSize.height);
}

- (void)setMessage:(MLChatMessage *)message
{
    [super setMessage:message];
    
    self.label.text = self.message.text;
    
    CGFloat maxTextWidth = self.maxWidth - self.insets.left - self.insets.right;
    self.textSize = [MLChatLib textSizeLabel:self.label withWidth:maxTextWidth];
    CGSize size = CGSizeMake(self.insets.left + self.textSize.width + self.insets.right, self.insets.top + self.textSize.height + self.insets.bottom);
    
    CGFloat statusЦшвер = 0;
    
    if(self.message.isOwner)
       statusЦшвер = 60;
    else
        statusЦшвер = 48;
    
    // если нужно увеличим высоту для вьюхи статуса
    NSArray *lines = [self getLinesArrayOfStringInLabel:self.label withWidth:self.textSize.width];
    
    if(lines.count)
    {
        if(lines.count == 1)
        {
            if(size.width + statusЦшвер > self.maxWidth)
                size = CGSizeMake(size.width, size.height + self.label.font.lineHeight);
            else
                size = CGSizeMake(size.width + statusЦшвер, size.height);
        }
        else
        {
            NSString *lastLine = lines.lastObject;
            CGSize lastLineSize = [lastLine boundingRectWithSize:CGSizeMake(maxTextWidth, CGFLOAT_MAX)
                                                         options:NSStringDrawingUsesLineFragmentOrigin
                                                      attributes:@{NSFontAttributeName:self.label.font}
                                                         context:nil].size;
            
            if(size.width + statusЦшвер > maxTextWidth &&
               self.insets.left + self.insets.right + lastLineSize.width + statusЦшвер < size.width)
            {
                // статус вмещается под строкой
            }
            else
            {
                size = CGSizeMake(size.width, size.height + self.label.font.lineHeight);
            }
        }
    }
    else
    {
        size = CGSizeMake(size.width + statusЦшвер, size.height + self.label.font.lineHeight);
    }
    
    if(size.width < statusЦшвер)
        size = CGSizeMake(self.insets.left + statusЦшвер, size.height);
    
    [self.view setNeedsLayout];
    [self.delegate chatCellContentViewControllerNeedsSize:size];
}

-(NSArray *)getLinesArrayOfStringInLabel:(UILabel *)label withWidth:(CGFloat)width
{
    NSString *text = [label text];
    UIFont   *font = [label font];
    
    CTFontRef myFont = CTFontCreateWithName(( CFStringRef)([font fontName]), [font pointSize], NULL);
    NSMutableAttributedString *attStr = [[NSMutableAttributedString alloc] initWithString:text];
    [attStr addAttribute:(NSString *)kCTFontAttributeName value:font range:NSMakeRange(0, attStr.length)];
    
    CFRelease(myFont);
    
    CTFramesetterRef frameSetter = CTFramesetterCreateWithAttributedString(( CFAttributedStringRef)attStr);
    
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathAddRect(path, NULL, CGRectMake(0, 0, width, CGFLOAT_MAX));
    
    CTFrameRef frame = CTFramesetterCreateFrame(frameSetter, CFRangeMake(0, 0), path, NULL);
    
    NSArray *lines = ( NSArray *)CTFrameGetLines(frame);
    
    NSMutableArray *linesArray = [[NSMutableArray alloc]init];
    
    for (id line in lines)
    {
        CTLineRef lineRef = (__bridge  CTLineRef )line;
        CFRange lineRange = CTLineGetStringRange(lineRef);
        NSRange range = NSMakeRange(lineRange.location, lineRange.length);
        
        NSString *lineString = [text substringWithRange:range];
        
        CFAttributedStringSetAttribute((CFMutableAttributedStringRef)attStr, lineRange, kCTKernAttributeName, (CFTypeRef)([NSNumber numberWithFloat:0.0]));
        CFAttributedStringSetAttribute((CFMutableAttributedStringRef)attStr, lineRange, kCTKernAttributeName, (CFTypeRef)([NSNumber numberWithInt:0.0]));

        [linesArray addObject:lineString];
    }

    CGPathRelease(path);
    CFRelease( frame );
    CFRelease(frameSetter);

    return (NSArray *)linesArray;
}
@end
