//
//  ViewController.m
//  ZDCurrencyConverter
//
//  Created by Zendesk Inc on 7/26/15.
//  Copyright (c) 2015 Steven Diviney. All rights reserved.
//

#import <ZendeskSDK/ZendeskSDK.h>
#import <ChameleonFramework/Chameleon.h>


#import "ZDConverterViewController.h"
#import "ZDCurrencyUtil.h"
#import "ZDCurrencyDisplayView.h"

@interface ZDConverterViewController ()

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *buttonHeight;
@property (weak, nonatomic) IBOutlet ZDKeypadView *keyboardView;

@property (weak, nonatomic) IBOutlet ZDCurrencyDisplayView *topCurrencyView;
@property (weak, nonatomic) IBOutlet ZDCurrencyDisplayView *bottomCurrencyView;

@property (nonatomic, strong) ZDCurrencyDisplayView *tappedDisplayView;

@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (nonatomic, strong) UIRefreshControl *refreshControl;

@property (weak, nonatomic) IBOutlet UIButton *taxButton;
@property (nonatomic, assign) BOOL editTaxAmount;

@property (nonatomic, strong) NSString *currencyAmount;

@property (nonatomic, strong) NSDictionary *currencies;

@property (nonatomic, strong) NSString *taxPercentage;



@end

@implementation ZDConverterViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _keyboardView.delegate = self;
    _buttonHeight.constant = ceilf( (self.view.frame.size.height - 220) / 5);
    // Do any additional setup after loading the view, typically from a nib.
    _refreshControl = [UIRefreshControl new];
    [_refreshControl addTarget:self action:@selector(refreshCurrencies) forControlEvents:UIControlEventValueChanged];
    [_scrollView addSubview:_refreshControl];
    
    _taxPercentage = [ZDCurrencyUtil tax];
    if (! _taxPercentage || [_taxPercentage isEqualToString:@""])
    {
        _taxPercentage = @"21";
        [ZDCurrencyUtil setTax:_taxPercentage];
    }
    
    [_taxButton setTitle:[NSString stringWithFormat:@"%@%%", _taxPercentage] forState:UIControlStateNormal ];

    //Hack fix for refresh control messing up content size of scroll view
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.scrollView setContentOffset:CGPointMake(0, 0) animated:YES];
    });
    
    [self loadCurrencies];
    
}

- (void) dealloc
{
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Currency loading helpers

//Load from storage, if none there trigger a refersh
- (void) loadCurrencies
{
    NSLog(@"Loading currencies");
    _currencies = [ZDCurrencyUtil loadCurrencies];
    if( ! _currencies )
    {
        NSLog(@"No currencies found, triggering fetch");
        [self refreshCurrencies];
    } else {
        NSLog(@"Currencies found in local storage");
        [self setupCurrenciesInView];
    }
}

- (void) refreshCurrencies
{
    if ( ! [_refreshControl isRefreshing])
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            [_refreshControl beginRefreshing];
            [self.scrollView setContentOffset:CGPointMake(0, -self.refreshControl.frame.size.height) animated:YES];
        });
    }
    
    
    NSDictionary *currenciesJson = [ZDCurrencyUtil loadCurrenciesJson];
    [[ZDCurrencyUtil new] fetchRatesForCurrencies:currenciesJson withCallback:^(NSDictionary *currencies, NSError *error) {
        
        if (error)
        {
            //Do something nice
            [_refreshControl endRefreshing];
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.scrollView setContentOffset:CGPointMake(0, 0) animated:YES];
            });
            
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error fetching conversion rates"
                                                            message:@"Please ensure you are connected to the internet\n(They have cats, you'll like it)"
                                                           delegate:nil
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil];
            [alert show];
            
            return;
        }
        
        [ZDCurrencyUtil storeCurrencies:currencies];
        _currencies = currencies;
        
        [_refreshControl endRefreshing];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.scrollView setContentOffset:CGPointMake(0, 0) animated:YES];
        });

        [self setupCurrenciesInView];
    }];
}

- (void) setupCurrenciesInView
{
    dispatch_async(dispatch_get_main_queue(), ^{
        NSString *topCurrency = [ZDCurrencyUtil topViewCurrency];
        if (! topCurrency )
        {
            topCurrency = @"USD";
        }
        
        NSString *bottomCurrency = [ZDCurrencyUtil bottomViewCurrency];
        if (! bottomCurrency)
        {
            bottomCurrency = @"EUR";
        }
        
        [self setInputCurrency:_currencies[topCurrency] andTargetCurrency:_currencies[bottomCurrency]];
        [_topCurrencyView setAmount:@"0"];
        [_bottomCurrencyView setAmount:@"0"];
    });
}

- (void) setInputCurrency:(ZDCurrencyModel*)input andTargetCurrency:(ZDCurrencyModel*)target
{
    [_topCurrencyView setCurrency:input];
    [_bottomCurrencyView setCurrency:target];
    [ZDCurrencyUtil setTopViewCurrency:input.code];
    [ZDCurrencyUtil setBottomViewCurrency:target.code];
}

#pragma mark - Keypad delegate

- (void) valueDidChange:(NSString *)text
{
#pragma Warning Dont forget to check for overflow
    if ( _editTaxAmount )
    {
        NSString *taxAmount = text;
        if ( ! taxAmount || [taxAmount isEqualToString:@""] )
        {
            taxAmount = @"0%";
        }
        
//warning Clean this up for fucks sake.
        [ZDCurrencyUtil setTax:taxAmount];
        _taxPercentage = taxAmount;
        [_taxButton setTitle:[NSString stringWithFormat:@"%@%%", _taxPercentage] forState:UIControlStateNormal ];
        
        [self updateConversionAmount:_currencyAmount];
        
    } else {
        
        [self updateConversionAmount:text];
    }
}
//warning Name this bettor
- (void) updateConversionAmount:(NSString*)text
{
    NSNumber *inputAmount = [NSNumber numberWithDouble:[text doubleValue]];
    
    [_topCurrencyView setAmount:text];
    
    NSNumber *taxAmount = @0;
    
    if ( _taxButton.selected )
    {
        taxAmount = [NSNumber numberWithDouble:[_taxButton.titleLabel.text doubleValue]];
    }
    
    
    if (_taxButton.isSelected)
    {
        NSNumber *tax = [NSNumber numberWithDouble:[_taxButton.titleLabel.text doubleValue]];
        NSNumber *taxAmount = [ZDCurrencyUtil calculateTax:tax onAmount:inputAmount];
        inputAmount = [NSNumber numberWithDouble:([inputAmount doubleValue] + [taxAmount doubleValue])];
        [_topCurrencyView setTaxAmount:[taxAmount stringValue]];
    }
    
    NSNumber *convertedAmount = [ZDCurrencyUtil convertAmount:inputAmount
                                                         from:_topCurrencyView.currency
                                                           to:_bottomCurrencyView.currency];
    
    [_bottomCurrencyView setAmount:[convertedAmount stringValue]];

}


//This should be returned by the KeyPad view but fuck it
#pragma mark Other buttons
- (IBAction)swapCurrencies:(id)sender {
    
//warning Sexy animation
    [self setInputCurrency:_bottomCurrencyView.currency andTargetCurrency:_topCurrencyView.currency];
    
    //More little hacks
    NSString *amount = [_bottomCurrencyView amount];
    if ( _taxButton.isSelected )
    {
        //What fucking language do you think your programming in? Clearly not a storngly typed one, jackass.
        NSNumber *amountWithoutTax = [NSNumber numberWithDouble:([amount doubleValue] - [[_topCurrencyView taxAmount] doubleValue])];
        amount = [amountWithoutTax stringValue];
    }
    
    [self valueDidChange:amount];

}

- (IBAction)showHelp:(id)sender {
    [ZDKHelpCenter showHelpCenterWithNavController:self.navigationController];
    //[ZDKRequests presentRequestListWithNavController:self.navigationController];
}


//This should be returned by the KeyPad view but fuck it
- (IBAction)taxButton:(id)sender {
    
        if ( ! _editTaxAmount )
        {
            
            [(UIButton*)sender setSelected:!((UIButton*)sender).selected];
            [_topCurrencyView taxEnabled:((UIButton*)sender).selected];
            [self valueDidChange:_topCurrencyView.amount];
        } else {
            [_keyboardView setText:_currencyAmount];
            _editTaxAmount = NO;
            [_taxButton setTintColor:[UIColor flatWhiteColor]];
            [_taxButton setTitleColor:[UIColor flatSkyBlueColor] forState:UIControlStateSelected];
            [self valueDidChange:_topCurrencyView.amount];
        }
}

- (IBAction)changeTaxAmountLongPressRecognizer:(id)sender
{
    if (((UILongPressGestureRecognizer*)sender).state == UIGestureRecognizerStateRecognized)
    {
        _editTaxAmount = ! _editTaxAmount;
        if ( _editTaxAmount )
        {
            _currencyAmount = [_keyboardView text];
            //[_keyboardView setText:[_taxButton titleLabel].text];
            [_keyboardView setText:@""];
            [_topCurrencyView setTaxAmount:[_taxButton titleLabel].text]; //Just for testing
            
            [_taxButton setSelected:YES];
            [_topCurrencyView taxEnabled:YES];
            
            [_taxButton setTintColor:[UIColor flatSkyBlueColor]];
            [_taxButton setTitleColor:[UIColor flatWhiteColor] forState:UIControlStateSelected];
        }
    }
    
}


#pragma mark - Gesture recognizers

//Not using IB to present as I need to set the delegate to this view controller to supply data + respond to events
- (IBAction)topCurrencyTapGesture:(id)sender
{
    //Create currency list view contoller and present it
    UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    ZDCurrencyListViewController *currencyListViewController = [sb instantiateViewControllerWithIdentifier:@"currencyListViewController"];
    currencyListViewController.delegate = self;
    
    _tappedDisplayView = _topCurrencyView;
    [self presentViewController:currencyListViewController animated:YES completion:NULL];
}

- (IBAction)bottomCurrencyTapGesture:(id)sender
{
    UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    ZDCurrencyListViewController *currencyListViewController = [sb instantiateViewControllerWithIdentifier:@"currencyListViewController"];
    currencyListViewController.delegate = self;
    
    _tappedDisplayView = _bottomCurrencyView;
    [self presentViewController:currencyListViewController animated:YES completion:NULL];
}

#pragma mark - Currency List delegate

- (NSDictionary*) currencies
{
    if (_currencies)
    {
        return _currencies;
    } else {
        return nil;
    }
}

- (void) currencySelected:(ZDCurrencyModel *)selected
{
    //Update relephant view
    [_tappedDisplayView setCurrency:selected];
    //Update all the values n shit
    [self valueDidChange:[_topCurrencyView amount]];
    
//warning less shit way of doing this please
    if (_tappedDisplayView == _topCurrencyView)
    {
        [ZDCurrencyUtil setTopViewCurrency:selected.code];
    } else {
        [ZDCurrencyUtil setBottomViewCurrency:selected.code];
    }
}

@end
