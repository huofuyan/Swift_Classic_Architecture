//
//  SVRSAHandler.h
//  05-POST请求模拟登陆
//
//  Created by 张发政 on 16/10/1.
//  Copyright © 2016年 东方银谷. All rights reserved.
//

#import <Foundation/Foundation.h>



typedef enum {
    KeyTypePublic = 0,
    KeyTypePrivate
}KeyType;

@interface SVRSAHandler : NSObject

@property (copy, nonatomic) NSString *token;
+ (instancetype)sharedDFRSAHandler;

- (BOOL)importKeyWithType:(KeyType)type andPath:(NSString*)path;
- (BOOL)importKeyWithType:(KeyType)type andkeyString:(NSString *)keyString;

//验证签名 Sha1 + RSA
- (BOOL)verifyString:(NSString *)string withSign:(NSString *)signString;
//验证签名 md5 + RSA
- (BOOL)verifyMD5String:(NSString *)string withSign:(NSString *)signString;

- (NSString *)signString:(NSString *)string;

- (NSString *)signMD5String:(NSString *)string;


- (NSString *) encryptWithPublicKey:(NSString*)content;
- (NSString *) decryptWithPrivatecKey:(NSString*)content;

//根据模和指数生成公钥
- (BOOL)KeyWithModulus:(NSString *)modulus andExp:(NSString *)exp;
- (NSString *)setPublicKey:(const char *)data Mod:(const char *)mod Exp:(const char *)exp;

@end
