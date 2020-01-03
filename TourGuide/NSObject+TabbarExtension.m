//
//  NSObject+TabbarExtension.m
//  TourGuide
//
//  Created by Mac on 7/23/18.
//  Copyright © 2018 Mac. All rights reserved.
//

#import "NSObject+TabbarExtension.h"

#import <UIKit/UIKit.h>

@implementation NSObject (TabbarExtension)

- (void)customTab
{
    [[UITabBarItem appearance] setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIColor colorWithRed:232/255.0f green:125/255.0f blue:0/255.0f alpha:1] , NSForegroundColorAttributeName,[UIFont boldSystemFontOfSize:13],NSFontAttributeName ,nil] forState:UIControlStateSelected];
    
    [[UITabBarItem appearance] setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIColor colorWithRed:232/255.0f green:125/255.0f blue:0/255.0f alpha:1], NSForegroundColorAttributeName,[UIFont boldSystemFontOfSize:13],NSFontAttributeName ,nil] forState:UIControlStateNormal];
    
    [UITabBarItem appearance].titlePositionAdjustment = UIOffsetMake(0, -5);
}

- (NSString *)numerize:(NSString *)string
{
    NSString *newString = [string stringByReplacingOccurrencesOfString:@"." withString:@""];
    if ([newString length] == 0) {
        return nil;
    }
    
    NSCharacterSet *disallowedCharacters = [[NSCharacterSet characterSetWithCharactersInString:@"0123456789."] invertedSet];
    NSRange charRange = [newString rangeOfCharacterFromSet:disallowedCharacters];
    if ( charRange.location != NSNotFound) {
        return nil;
    }
    
    NSArray *numberArray = [newString componentsSeparatedByString:@"."];
    if ([numberArray count] > 2) {
        return nil;
    }
    
    NSString *integer           = [numberArray objectAtIndex:0];
    NSUInteger integerDigits    = [integer length];
    if (integerDigits == 0) {
        return nil;
    }

    NSMutableString *formattedString = [[NSMutableString alloc] init];
    if (integerDigits < 4) {
        [formattedString appendString:integer];
    } else {
        NSUInteger startingDigits = integerDigits % 3;
        if (startingDigits == 0) {
            startingDigits = 3;
        }
        [formattedString setString:[integer substringToIndex:startingDigits]];
        for (NSUInteger index = startingDigits; index < integerDigits; index = index + 3) {
            [formattedString appendFormat:@".%@", [integer substringWithRange:NSMakeRange(index, 3)]];
        }
    }
    
    if ([numberArray count] == 2) {
        [formattedString appendString:@"."];
        NSString *decimal = [numberArray objectAtIndex:1];
        if ([decimal length] > 0) {
            [formattedString appendString:decimal];
        }
    }
    
    return formattedString;
}


@end
