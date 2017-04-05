//
//  ZDCurrencyUtil.m
//  ZDCurrencyConverter
//
//  Created by Zendesk Inc on 7/26/15.
//  Copyright (c) 2015 Steven Diviney. All rights reserved.
//


#import "ZDCurrencyUtil.h"
#import "AFHTTPRequestOperationManager.h"

static NSString *const CurrencyQueryString = @"http://query.yahooapis.com/v1/public/yql?q=select * from yahoo.finance.xchange where pair in (%@)&format=json&env=store://datatables.org/alltableswithkeys";

NSString * const ZD_FetchCurrenciesStarting = @"ZD_FetchCurrenciesStarting";
NSString * const ZD_FetchCurrenciesSuccess = @"ZD_FetchCurrenciesSuccess";
NSString * const ZD_FetchCurrenciesFailure = @"ZD_FetchCurrenciesFailure";

NSString * const ZD_topViewCurrency = @"ZD_topViewCurrency";
NSString * const ZD_bottomViewCurrency = @"ZD_bottomViewCurrency";

NSString * const ZD_Tax = @"ZD_Tax";

@implementation ZDCurrencyUtil


+ (NSDictionary*) loadCurrenciesJson
{
    //Load json file
    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"currencies" ofType:@"json"];
    NSData *data = [NSData dataWithContentsOfFile:filePath];
    NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
    
    //parse to objects
    NSMutableDictionary *result = [NSMutableDictionary new];
    for (NSString *key in json) {
        NSDictionary *item = [json objectForKey:key];
        NSError *error;
        
        ZDCurrencyModel *currency = [[ZDCurrencyModel alloc] initWithDictionary:item error:&error];
        
        [result setObject:currency forKey:key];
    }

    
    
    return result;
    
}


#pragma mark - Rates fetcher

- (void) fetchRatesForCurrencies:(NSDictionary *)currencies withCallback:(ZDFetchCurrencyCallback)callback
{
    NSString *queryString = [ZDCurrencyUtil buildQueryStringWithCurrencies:currencies];
    NSMutableDictionary *result = [[NSMutableDictionary alloc] initWithDictionary:currencies];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:ZD_FetchCurrenciesStarting object:nil];
    NSLog(@"Fetching currencies");
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager GET:queryString parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject)
     {
         
         NSLog(@"Currencies GET successfull");
         
         for (NSDictionary *currencyRate in responseObject[@"query"][@"results"][@"rate"])
         {
             //Quickly tried to use json model but it can't parse the date + API response object names suck
             NSString *code = [currencyRate[@"id"] substringToIndex:3];
             NSNumber *rate = [NSNumber numberWithDouble:[((NSString*)currencyRate[@"Rate"]) doubleValue]];
             
             NSDateFormatter *dateFormatter = [NSDateFormatter new];
             [dateFormatter setDateFormat:@"MM/dd/yyyy"];
             NSDate *updateTimestamp = [dateFormatter dateFromString:(NSString*)currencyRate[@"Date"]];
             
             ZDCurrencyModel *currency = [result objectForKey:code];
             currency.rate = rate;
             currency.lastUpdate = updateTimestamp;
             
         }
         
         if (callback)
         {
             callback(result, nil);
         }
         
         [[NSNotificationCenter defaultCenter] postNotificationName:ZD_FetchCurrenciesSuccess object:nil];
         
         
     } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
         
         NSLog(@"Currencies GET failed");
         
         if (callback)
         {
             callback(nil, error);
         }
         
         [[NSNotificationCenter defaultCenter] postNotificationName:ZD_FetchCurrenciesFailure object:nil];

         
     }];
    
}


+ (NSString*) buildQueryStringWithCurrencies:(NSDictionary*)currencies
{

    NSMutableArray *codesArray = [NSMutableArray new];
    
    for (NSString *key in currencies) {
        ZDCurrencyModel *currency = [currencies objectForKey:key];
        [codesArray addObject:[NSString stringWithFormat:@"\"%@\"", currency.code]];
    }

    NSString *codes = [codesArray componentsJoinedByString:@","];
    
    NSString *urlString = [NSString stringWithFormat:CurrencyQueryString, codes];
    urlString = [urlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    
    return urlString;
}


+ (NSNumber*) convertAmount:(NSNumber*)amount from:(ZDCurrencyModel*)baseCurrency to:(ZDCurrencyModel*)selectedCurrency
{
    NSNumber *result = [NSNumber numberWithDouble:([amount doubleValue] / [baseCurrency.rate doubleValue])];
    result = [NSNumber numberWithDouble:( [result doubleValue] * [selectedCurrency.rate doubleValue])];
        
    return result;
}

+ (NSNumber*) calculateTax:(NSNumber*)tax onAmount:(NSNumber*)amount
{
    return [NSNumber numberWithDouble:( ([amount doubleValue] / 100) * [tax doubleValue] )];
}

+ (NSString *)topViewCurrency
{
    return [[NSUserDefaults standardUserDefaults] objectForKey:ZD_topViewCurrency];
}

+ (void)setTopViewCurrency:(NSString *)currency
{
    [[NSUserDefaults standardUserDefaults] setObject:currency forKey:ZD_topViewCurrency];
}

+ (NSString *)bottomViewCurrency
{
    return [[NSUserDefaults standardUserDefaults] objectForKey:ZD_bottomViewCurrency];
}

+ (void)setBottomViewCurrency:(NSString *)currency
{
    [[NSUserDefaults standardUserDefaults] setObject:currency forKey:ZD_bottomViewCurrency];
}

+ (void)storeCurrencies:(NSDictionary *)currencies
{
    NSArray *keys = [currencies allKeys];
    [[NSUserDefaults standardUserDefaults] setObject:keys forKey:@"currencyCodeKeys"];
    
    for (NSString *key in currencies) {
        ZDCurrencyModel *currency = [currencies objectForKey:key];
        [self storeCurrency:currency withKey:key];
    }
    
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (NSDictionary *)loadCurrencies
{
    NSMutableDictionary *result = [NSMutableDictionary new];
    NSArray *keys = [[NSUserDefaults standardUserDefaults] objectForKey:@"currencyCodeKeys"];
    
    if ( ! keys )
    {
        return nil;
    }
    
    for (NSString *key in keys) {
        ZDCurrencyModel *currency = [self loadCurrencyWithKey:key];
        [result setObject:currency forKey:key];
    }
    
    return result;
}

+ (ZDCurrencyModel *)loadCurrencyWithKey:(NSString*)key
{
    NSDictionary *currencyDict = [[NSUserDefaults standardUserDefaults] objectForKey:key];
    if (currencyDict)
    {
        return [[ZDCurrencyModel alloc] initWithDictionary:currencyDict error:nil];
    } else {
        return nil;
    }
}

+ (void) storeCurrency:(ZDCurrencyModel*)currency withKey:(NSString*)key
{
    [[NSUserDefaults standardUserDefaults] setObject:[currency toDictionary] forKey:key];

}

+(NSString*)tax
{
    return [[NSUserDefaults standardUserDefaults] objectForKey:ZD_Tax];
}

+(void)setTax:(NSString *)tax
{
    [[NSUserDefaults standardUserDefaults] setObject:tax forKey:ZD_Tax];
    [[NSUserDefaults standardUserDefaults] synchronize];

}


@end
