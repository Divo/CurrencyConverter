//
//  ZDKeypadView.h
//  ZDCurrencyConverter
//
//  Created by Zendesk Inc on 7/26/15.
//  Copyright (c) 2015 Steven Diviney. All rights reserved.
//


#import <UIKit/UIKit.h>

@protocol ZDKeypadViewDelegate <NSObject>

#pragma warning Check how UITextFieldDelegate protocol works? Presume it is passed in as arg OR you need to get the text
- (void)valueDidChange:(NSString*)text;

@end

@interface ZDKeypadView : UIView

- (IBAction)buttonPress:(id)sender;

@property (nonatomic, strong) NSString *text;

#pragma warning This should probably be weak
@property (nonatomic, strong) id<ZDKeypadViewDelegate> delegate;


@end
