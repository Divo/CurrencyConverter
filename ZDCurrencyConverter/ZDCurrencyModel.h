//
//  ZDCurrencyModel.h
//  ZDCurrencyConverter
//
//  Created by Zendesk Inc on 7/26/15.
//  Copyright (c) 2015 Steven Diviney. All rights reserved.
//


#import <Foundation/Foundation.h>

#import "JSONModel.h"


@interface ZDCurrencyModel : JSONModel

@property (nonatomic, strong) NSString *symbol;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *symbol_native;
@property (nonatomic, strong) NSNumber *decimal_digits;
@property (nonatomic, strong) NSNumber *rounding;
@property (nonatomic, strong) NSString *code;
@property (nonatomic, strong) NSString *name_plural;

@property (nonatomic, strong) NSNumber<Optional> *rate;
@property (nonatomic, strong) NSDate<Optional> *lastUpdate;

@end
