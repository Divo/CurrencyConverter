//
//  ZDCurrencyDisplayView.h
//  ZDCurrencyConverter
//
//  Created by Zendesk Inc on 7/26/15.
//  Copyright (c) 2015 Steven Diviney. All rights reserved.
//


#import <UIKit/UIKit.h>
#import "ZDCurrencyModel.h"

@interface ZDCurrencyDisplayView : UIView

@property (nonatomic, strong) ZDCurrencyModel *currency;
@property (nonatomic, strong) NSString *amount;
@property (nonatomic, strong) NSString *taxAmount;

- (void) taxEnabled:(BOOL)enabled;

@end
