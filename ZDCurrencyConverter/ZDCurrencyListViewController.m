//
//  ZDCurrencyListViewController.m
//  ZDCurrencyConverter
//
//  Created by Zendesk Inc on 7/26/15.
//  Copyright (c) 2015 Steven Diviney. All rights reserved.
//



#import "ZDCurrencyListViewController.h"
#import "ZDCurrencyTableViewCell.h"

@interface ZDCurrencyListViewController ()

@property NSArray * currencies;
@property NSArray * filteredCurrencies;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end

@implementation ZDCurrencyListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
//warning Don't do this in view did load, have some setup method or something
    if ([_delegate currencies])
    {
        NSArray *keys = [[_delegate currencies] allKeys];
        keys = [keys sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
        
        NSMutableArray * mutableCurrencies = [NSMutableArray new];
        for (NSString *key in keys)
        {
            [mutableCurrencies addObject:[[_delegate currencies] objectForKey:key]];
        }
        
        _currencies = [NSArray arrayWithArray:mutableCurrencies];
        _filteredCurrencies = [NSArray arrayWithArray:_currencies];
    }
  
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)closeButton:(id)sender
{
    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Table Data Source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (_filteredCurrencies)
    {
        return [_filteredCurrencies count];
    } else {
        return 0;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    ZDCurrencyTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"currencyListCell" forIndexPath:indexPath];
    
    ZDCurrencyModel *currency = [_filteredCurrencies objectAtIndex:indexPath.row];
    
    cell.currencyCodeLabel.text = currency.code;
    cell.currencyNameLabel.text = currency.name;
    cell.currencySymbolLabel.text = currency.symbol_native;
    
    return cell;
}


#pragma mark - Table View delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [_delegate currencySelected:[_filteredCurrencies objectAtIndex:indexPath.row]];
    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Search delegate

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    NSPredicate *bPredicate = [NSPredicate predicateWithFormat:@"SELF.name contains[cd] %@ OR SELF.code contains[cd] %@",searchText, searchText];
    _filteredCurrencies = [_currencies filteredArrayUsingPredicate:bPredicate];

    [_tableView reloadData];
}



@end
