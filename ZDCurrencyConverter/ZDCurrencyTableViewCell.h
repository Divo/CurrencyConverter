//
//  CurrencyTableViewCell.h
//  ZDCurrencyConverter
//
//  Created by Zendesk Inc on 7/26/15.
//  Copyright (c) 2015 Steven Diviney. All rights reserved.
//



#import <UIKit/UIKit.h>

@interface ZDCurrencyTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *currencyNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *currencyCodeLabel;
@property (weak, nonatomic) IBOutlet UILabel *currencySymbolLabel;

@end
