//
//  ZDCurrencyDisplayView.m
//  ZDCurrencyConverter
//
//  Created by Zendesk Inc on 7/26/15.
//  Copyright (c) 2015 Steven Diviney. All rights reserved.
//


#import "ZDCurrencyDisplayView.h"

@interface ZDCurrencyDisplayView ()


@property (weak, nonatomic) IBOutlet UILabel *codeLabel;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *symbolLabel;
@property (weak, nonatomic) IBOutlet UILabel *amountLabel;
@property (weak, nonatomic) IBOutlet UILabel *taxLabel;

@end


@implementation ZDCurrencyDisplayView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (void) setCurrency:(ZDCurrencyModel *)currency
{
    _currency = currency;
    _codeLabel.text = currency.code;
    _nameLabel.text = currency.name;
    _symbolLabel.text = currency.symbol_native;
}


- (void) setAmount:(NSString *)amount
{
    _amount = amount;
    NSString *formatString = [NSString stringWithFormat:@"%%.0%lif", (long)[_currency.decimal_digits integerValue]];
    NSString *formattedNumber = [NSString stringWithFormat:formatString, [amount floatValue] ];
    _amountLabel.text = formattedNumber;
}

- (void) setTaxAmount:(NSString *)taxAmount
{
    _taxAmount = taxAmount;
    NSString *formatString = [NSString stringWithFormat:@"%%.0%lif", (long)[_currency.decimal_digits integerValue]];
    NSString *formattedNumber = [NSString stringWithFormat:formatString, [taxAmount floatValue] ];
    _taxLabel.text = [NSString stringWithFormat:@"Including V.A.T of %@%@", _currency.symbol_native, formattedNumber];
}


- (void)taxEnabled:(BOOL)enabled
{
    dispatch_async(dispatch_get_main_queue(), ^{
        _taxLabel.hidden = !enabled;
    });
}

@end
