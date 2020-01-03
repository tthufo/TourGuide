//
//  CustomField.h
//  PriceApp
//
//  Created by Thanh Hai Tran on 6/22/18.
//  Copyright © 2018 tthufo. All rights reserved.
//

#import <UIKit/UIKit.h>

@class CustomField;

typedef void (^rCompletion)(Boolean isDone, NSDictionary * result);

typedef void (^textCompletion)(int index, NSString* text);

typedef void (^textCompletion1)(int index, NSString* text);

typedef void (^textCompletion2)(int index, NSString* text);

@interface CustomField : NSObject

+ (id)shareText;

- (void)didDeploytextWith:(textCompletion)completion withTextField:(UITextField*)textField;

- (void)didDeploytextWith1:(textCompletion1)completion1 withTextField:(UITextField*)textField;

- (void)didDeploytextWith2:(textCompletion2)completion2 withTextField:(UITextField*)textField;

- (void)requesting:(NSString*)url andInfo:(NSString*)info andCompletion:(rCompletion)rCompletion;

- (void)request:(NSString*)url andInfo:(NSDictionary *)info andCompletion:(rCompletion)rCompletion;

@property(nonatomic,copy) rCompletion rCompletion;

@property(nonatomic,copy) textCompletion textCompletion;

@property(nonatomic,copy) textCompletion1 textCompletion1;

@property(nonatomic,copy) textCompletion2 textCompletion2;

@end


@interface NSString (dot)

- (NSString *)NUMB;

@end
