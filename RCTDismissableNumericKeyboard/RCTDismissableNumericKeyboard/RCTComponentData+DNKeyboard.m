//
//  RCTComponentData+DNKeyboard.m
//  RCTDismissableNumericKeyboard
//
//  Created by Lukas Pawlik on 08/01/2017.
//  Copyright © 2017 Lukas Pawlik. All rights reserved.
//

#import "RCTComponentData+DNKeyboard.h"
#import <objc/runtime.h>

@implementation RCTComponentData (DismissableNumericKeyboard)

- (void)setPropsAndAddToolbar:(NSDictionary<NSString *, id> *)props forView:(id<RCTComponent>)view
{
    if (!view) {
        return;
    }
    
    if ([self shouldCloseButtonBeInjected:props forView:view]) {
        CGFloat width = [UIScreen mainScreen].bounds.size.width;
        CGFloat height = 0;
        if(width > 320) {
            height = 42;
        } else {
            height = 35;
        }
        UIToolbar *toolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 320.0f, height)];
        toolbar.barStyle = UISearchBarStyleDefault;
        
        toolbar.backgroundColor = [UIColor colorWithRed:230.0f/255.0f
                                                  green:230.0f/255.0f
                                                   blue:230.0f/255.0f
                                                  alpha:1.0f];
        
        NSString *returnKeyTypeName = [props objectForKey:@"returnKeyType"];
        
        UIBarButtonSystemItem item = UIBarButtonSystemItemDone;
        
        if ([returnKeyTypeName isEqualToString:@"done"]) {
            item = UIBarButtonSystemItemDone;
        }
        
        if ([returnKeyTypeName isEqualToString:@"search"]) {
            item = UIBarButtonSystemItemSearch;
        }
        
        if ([returnKeyTypeName isEqualToString:@"default"]) {
            item = UIBarButtonSystemItemSave;
        }
        
        if ([returnKeyTypeName isEqualToString:@"send"]) {
            item = UIBarButtonSystemItemAdd;
        }
        
        if ([returnKeyTypeName isEqualToString:@"go"]) {
            item = UIBarButtonSystemItemEdit;
        }
        
        UIBarButtonItem *flexibleSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
            
        UIBarButtonItem *barButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:item target:view action:NSSelectorFromString(@"resignFirstResponder")];
        
        barButtonItem.tintColor = [UIColor colorWithRed:97.0f/255.0f
                                                  green:97.0f/255.0f
                                                   blue:97.0f/255.0f
                                                  alpha:1.0f];
            
        [toolbar setItems:[NSArray arrayWithObjects:flexibleSpace, barButtonItem, nil]];
        ((UITextField *)view).inputAccessoryView = toolbar;
            
    }
    
    
    [self setPropsAndAddToolbar:props forView:view];
    
}

-(BOOL)shouldCloseButtonBeInjected:(NSDictionary<NSString *, id> *)props forView:(id<RCTComponent>)view
{
    if (![NSStringFromClass([view class]) isEqualToString:@"RCTTextField"]) {
        return false;
    }
    
    NSArray *keys = @[@"keyboardType", @"returnKeyType"];
    NSArray *objects = [props objectsForKeys:keys notFoundMarker:[NSNull null]];
    
    id keyboardType = [objects objectAtIndex:0];
    id returnKey = [objects objectAtIndex:1];
    
    if (keyboardType == [NSNull null] || returnKey == [NSNull null]) {
        return false;
    }
    
    UIKeyboardType *type = [RCTConvert UIKeyboardType:keyboardType];
    
    BOOL shouldInject = (type == UIKeyboardTypeDecimalPad);
    return shouldInject;
}

+ (void)load
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        SEL setPropsSelector = @selector(setProps:forView:);
        SEL setPropsAndAddToolbarSelector = @selector(setPropsAndAddToolbar:forView:);
        Method originalMethod = class_getInstanceMethod(self, setPropsSelector);
        Method extendedMethod = class_getInstanceMethod(self, setPropsAndAddToolbarSelector);
        method_exchangeImplementations(originalMethod, extendedMethod);
    });
}

@end

