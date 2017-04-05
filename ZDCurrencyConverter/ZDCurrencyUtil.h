//
//  ZDCurrencyUtil.h
//  ZDCurrencyConverter
//
//  Created by Zendesk Inc on 7/26/15.
//  Copyright (c) 2015 Steven Diviney. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "ZDCurrencyModel.h"

typedef void (^ZDFetchCurrencyCallback)(NSDictionary *currencies, NSError *error);

extern NSString * const ZD_FetchCurrenciesStarting;
extern NSString * const ZD_FetchCurrenciesSuccess;
extern NSString * const ZD_FetchCurrenciesFailure;

@interface ZDCurrencyUtil : NSObject

/**
 *  Load currencies from json file.
 *
 *  @return Array of ZDCurrencyModel objects
 *
 */
+ (NSDictionary*) loadCurrenciesJson;

/**
 *  Fetch rates for the provided currencies
 *
 *  @param currencies Dictionary of ZDCurrencyModel objects.
 *  @param callback Callback to be executed when request completes
 *
 *  @return Updated ZDCurrencyModel objects
 *
 */
- (void) fetchRatesForCurrencies:(NSDictionary*)currencies
                             withCallback:(ZDFetchCurrencyCallback)callback;


/**
 *  Convert an NSNumber expressed as one currency to another currency using the base currency 
 *  the conversion rates are expressed in
 *
 *  @param amount The amount to convert
 *  @param from   The currency to convert from
 *  @param to     The currency to convert to
 *  @param base   The base currency (probably should be USD, just saying)
 *
 *  @return The converted number. Can be nil if models do not contain rates.
 *
 */
//+ (NSNumber*) convert:(NSNumber*)amount from:(ZDCurrencyModel*)from to:(ZDCurrencyModel*)to using:(NSNumber*)base;

+ (NSNumber*) convertAmount:(NSNumber*)amount from:(ZDCurrencyModel*)baseCurrency to:(ZDCurrencyModel*)selectedCurrency;

+ (NSNumber*) calculateTax:(NSNumber*)tax onAmount:(NSNumber*)amount;


/**
 *  Store currencies
 *
 *  @param currencies Dictionary of ZDCurrencyModel objects
 *
 */
+ (void) storeCurrencies:(NSDictionary*)currencies;

/**
 *  Load currencies from local storage. Returns nil if no currencies are stored
 *
 *  @return NSDictionary of ZDCurrencyModel object
 *
 */
+ (NSDictionary*) loadCurrencies;


+ (NSString*)topViewCurrency;
+ (void)setTopViewCurrency:(NSString*)currency;

+ (NSString*)bottomViewCurrency;
+ (void)setBottomViewCurrency:(NSString*)currency;

+ (NSString*)tax;
+ (void)setTax:(NSString*)tax;

@end
