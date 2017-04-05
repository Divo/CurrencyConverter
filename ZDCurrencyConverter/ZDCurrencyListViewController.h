//
//  ZDCurrencyListViewController.h
//  ZDCurrencyConverter
//
//  Created by Zendesk Inc on 7/26/15.
//  Copyright (c) 2015 Steven Diviney. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ZDCurrencyModel.h"

@protocol ZDCurrencyListProtocol <NSObject>

- (NSDictionary*) currencies;
- (void) currencySelected:(ZDCurrencyModel*)selected;

@end

@interface ZDCurrencyListViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate>

@property (weak, nonatomic) IBOutlet id<ZDCurrencyListProtocol> delegate;

- (IBAction)closeButton:(id)sender;

@end
