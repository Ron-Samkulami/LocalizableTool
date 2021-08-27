//
//  RSGoogleTranslate.h
//  LocalizabalTool
//
//  Created by 111 on 2021/8/24.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface RSGoogleTranslate : NSObject
- (void)translateWithText:(NSString *)text
       targetLanguageCode:(NSString *)languageCode
               completion:(void (^)(NSString * _Nullable originalText,
                                    NSString * _Nullable originalLanguageCode,
                                    NSString * _Nullable translatedText,
                                    NSString * _Nullable targetLanguageCode,
                                    NSString * _Nullable error))completionHandler;

@end

NS_ASSUME_NONNULL_END
