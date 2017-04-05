//
//  ZDKeypadView.m
//  ZDCurrencyConverter
//
//  Created by Zendesk Inc on 7/26/15.
//  Copyright (c) 2015 Steven Diviney. All rights reserved.
//


#import "ZDKeypadView.h"

typedef NS_ENUM(NSUInteger, ZDButtonTags) {
    TAX = 10,
    SWAP,
    BACKSPACE,
    PERIOD,
    HELP,
};

@interface ZDKeypadView ()

@property (nonatomic, strong) NSMutableString *textStorage;

@end

@implementation ZDKeypadView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (IBAction)buttonPress:(id)sender
{
    if (! _textStorage )
    {
        _textStorage = [NSMutableString new];
    }
    
    NSInteger tag = [sender tag];
    
    switch (tag) {
        case BACKSPACE:
            if( ! [_textStorage length] )
            {
                return;
            }
            [_textStorage deleteCharactersInRange:NSMakeRange([_textStorage length] - 1, 1)];
            [self.delegate valueDidChange:self.text];
            break;
        case PERIOD:
            [_textStorage appendString:@"."];
            [self.delegate valueDidChange:self.text];
            break;

        default:
            [_textStorage appendString:[NSString stringWithFormat: @"%ld", (long)tag]];
            [self.delegate valueDidChange:self.text];
            break;
    }
    
    
}

- (NSString*)text
{
    if ( [_textStorage length] > 0 )
    {
        return [NSString stringWithString:_textStorage];
    } else {
        return @"";
    }
}

- (void)setText:(NSString*)text
{
    [_textStorage setString:text];
}

@end
