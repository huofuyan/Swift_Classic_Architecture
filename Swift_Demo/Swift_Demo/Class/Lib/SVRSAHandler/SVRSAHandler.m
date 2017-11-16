//
//  SVRSAHandler.m
//  05-POST请求模拟登陆
//
//  Created by 张发政 on 16/10/1.
//  Copyright © 2016年 东方银谷. All rights reserved.
//


#import <Swift_Demo-Swift.h>

#import "SVRSAHandler.h"
#include <openssl/rsa.h>
#include <openssl/pem.h>
#include <openssl/err.h>
#include <openssl/md5.h>

typedef enum {
    RSA_PADDING_TYPE_NONE       = RSA_NO_PADDING,
    RSA_PADDING_TYPE_PKCS1      = RSA_PKCS1_PADDING,
    RSA_PADDING_TYPE_SSLV23     = RSA_SSLV23_PADDING
}RSA_PADDING_TYPE;

#define  PADDING   RSA_PADDING_TYPE_PKCS1

@implementation SVRSAHandler
{
    
    RSA* _rsa_pub;
    RSA* _rsa_pri;
}
static SVRSAHandler *instance;

+ (instancetype)sharedDFRSAHandler
{
    
    
    NSString * modulus = [[NSUserDefaults standardUserDefaults] objectForKey:@"modulus"];
    NSString * exp = [[NSUserDefaults standardUserDefaults] objectForKey:@"exp"];
    if(modulus == nil || exp == nil){
        
//        [SVBasePost getRSAKeyCodeSuccessBlock:^(NSDictionary *rsa) {
//            //        [self automaticLogin];
//            DLog(@"获取成功");
//
//        } failedBlock:^(NSError *error) {
////            [MBProgressHUD showNoImageMessage:@"连接到服务器失败"];
//        }];
        
        HBX_BasePost *post = [[HBX_BasePost alloc] init];
        
        [post getRSAKeyCodeSuccessBlockWithSuccessBlock:^(NSDictionary<NSString *,id> * error) {
            
        } faileBlock:^(NSError * error) {
            
        }];
       
        
        
    }
    
    static SVRSAHandler * RSAHandler;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        RSAHandler = [[self alloc] init];
    });
    
    [RSAHandler KeyWithModulus:modulus andExp:exp];
    return RSAHandler;
    
}




//+ (instancetype)sharedDFRSAHandler1
//{
//    static SVRSAHandler * RSAHandler;
//    
//    if(RSAHandler != nil){
//        return RSAHandler;
//    }
//    //    NSString * modulus = [[NSUserDefaults standardUserDefaults] objectForKey:@"modulus"];
//    //    NSString * exp = [[NSUserDefaults standardUserDefaults] objectForKey:@"exp"];
//    NSString * modulus = nil;
//    NSString * exp = nil;
//    if(modulus == nil || exp==nil){
//        
//        [SVBasePost getRSAKeyCodeSuccessBlock:^(NSDictionary *rsa) {
//            //        [self automaticLogin];
//            DLog(@"获取成功");
//            
//        } failedBlock:^(NSError *error) {
//            [MBProgressHUD showNoImageMessage:@"连接到服务器失败"];
//        }];
//        //创建一个通知
//        //        [NSNotification notificationWithName:RSA_ERROR object:self];
//        //        [[NSNotificationCenter defaultCenter] postNotificationName:RSA_ERROR object:self];
//        return [[self alloc] init];
//    }else{
//        static dispatch_once_t onceToken;
//        dispatch_once(&onceToken, ^{
//            RSAHandler = [[self alloc] init];
//            [RSAHandler KeyWithModulus:modulus andExp:exp];
//        });
//        return RSAHandler;
//    }
//    
//}






#pragma mark - public methord
-(BOOL)importKeyWithType:(KeyType)type andPath:(NSString *)path
{
    BOOL status = NO;
    const char* cPath = [path cStringUsingEncoding:NSUTF8StringEncoding];
    FILE* file = fopen(cPath, "rb");
    if (!file) {
        return status;
    }
    if (type == KeyTypePublic) {
        _rsa_pub = NULL;
        if((_rsa_pub = PEM_read_RSA_PUBKEY(file, NULL, NULL, NULL))){
            status = YES;
        }
        
        
    }else if(type == KeyTypePrivate){
        _rsa_pri = NULL;
        if ((_rsa_pri = PEM_read_RSAPrivateKey(file, NULL, NULL, NULL))) {
            status = YES;
        }
        
    }
    fclose(file);
    return status;
    
}
- (BOOL)importKeyWithType:(KeyType)type andkeyString:(NSString *)keyString
{
    if (!keyString) {
        return NO;
    }
    BOOL status = NO;
    BIO *bio = NULL;
    RSA *rsa = NULL;
    bio = BIO_new(BIO_s_file());
    NSString* temPath = NSTemporaryDirectory();
    NSString* rsaFilePath = [temPath stringByAppendingPathComponent:@"RSAKEY"];
    NSString* formatRSAKeyString = [self formatRSAKeyWithKeyString:keyString andKeytype:type];
    BOOL writeSuccess = [formatRSAKeyString writeToFile:rsaFilePath atomically:YES encoding:NSUTF8StringEncoding error:nil];
    if (!writeSuccess) {
        return NO;
    }
    const char* cPath = [rsaFilePath cStringUsingEncoding:NSUTF8StringEncoding];
    BIO_read_filename(bio, cPath);
    if (type == KeyTypePrivate) {
        rsa = PEM_read_bio_RSAPrivateKey(bio, NULL, NULL, "");
        _rsa_pri = rsa;
        if (rsa != NULL && 1 == RSA_check_key(rsa)) {
            status = YES;
        } else {
            status = NO;
        }
        
        
    }
    else{
        rsa = PEM_read_bio_RSA_PUBKEY(bio, NULL, NULL, NULL);
        _rsa_pub = rsa;
        if (rsa != NULL) {
            status = YES;
        } else {
            status = NO;
        }
    }
    
    BIO_free_all(bio);
    [[NSFileManager defaultManager] removeItemAtPath:rsaFilePath error:nil];
    return status;
}


#pragma mark RSA sha1验证签名
//signString为base64字符串
- (BOOL)verifyString:(NSString *)string withSign:(NSString *)signString
{
    if (!_rsa_pub) {
        NSLog(@"please import public key first");
        return NO;
    }
    
    const char *message = [string cStringUsingEncoding:NSUTF8StringEncoding];
    int messageLength = (int)[string lengthOfBytesUsingEncoding:NSUTF8StringEncoding];
    NSData *signatureData = [[NSData alloc]initWithBase64EncodedString:signString options:0];
    unsigned char *sig = (unsigned char *)[signatureData bytes];
    unsigned int sig_len = (int)[signatureData length];
    
    
    
    
    unsigned char sha1[20];
    SHA1((unsigned char *)message, messageLength, sha1);
    int verify_ok = RSA_verify(NID_sha1
                               , sha1, 20
                               , sig, sig_len
                               , _rsa_pub);
    
    if (1 == verify_ok){
        return   YES;
    }
    return NO;
    
    
}
#pragma mark RSA MD5 验证签名
- (BOOL)verifyMD5String:(NSString *)string withSign:(NSString *)signString
{
    if (!_rsa_pub) {
        NSLog(@"please import public key first");
        return NO;
    }
    
    const char *message = [string cStringUsingEncoding:NSUTF8StringEncoding];
    // int messageLength = (int)[string lengthOfBytesUsingEncoding:NSUTF8StringEncoding];
    NSData *signatureData = [[NSData alloc]initWithBase64EncodedString:signString options:0];
    unsigned char *sig = (unsigned char *)[signatureData bytes];
    unsigned int sig_len = (int)[signatureData length];
    
    unsigned char digest[MD5_DIGEST_LENGTH];
    MD5_CTX ctx;
    MD5_Init(&ctx);
    MD5_Update(&ctx, message, strlen(message));
    MD5_Final(digest, &ctx);
    int verify_ok = RSA_verify(NID_md5
                               , digest, MD5_DIGEST_LENGTH
                               , sig, sig_len
                               , _rsa_pub);
    if (1 == verify_ok){
        return   YES;
    }
    return NO;
    
}

- (NSString *)signString:(NSString *)string
{
    if (!_rsa_pri) {
        NSLog(@"please import private key first");
        return nil;
    }
    const char *message = [string cStringUsingEncoding:NSUTF8StringEncoding];
    int messageLength = (int)strlen(message);
    unsigned char *sig = (unsigned char *)malloc(256);
    unsigned int sig_len;
    
    unsigned char sha1[20];
    SHA1((unsigned char *)message, messageLength, sha1);
    
    int rsa_sign_valid = RSA_sign(NID_sha1
                                  , sha1, 20
                                  , sig, &sig_len
                                  , _rsa_pri);
    if (rsa_sign_valid == 1) {
        NSData* data = [NSData dataWithBytes:sig length:sig_len];
        
        NSString * base64String = [data base64EncodedStringWithOptions:0];
        free(sig);
        return base64String;
    }
    
    free(sig);
    return nil;
}
- (NSString *)signMD5String:(NSString *)string
{
    if (!_rsa_pri) {
        NSLog(@"please import private key first");
        return nil;
    }
    const char *message = [string cStringUsingEncoding:NSUTF8StringEncoding];
    //int messageLength = (int)strlen(message);
    unsigned char *sig = (unsigned char *)malloc(256);
    unsigned int sig_len;
    
    unsigned char digest[MD5_DIGEST_LENGTH];
    MD5_CTX ctx;
    MD5_Init(&ctx);
    MD5_Update(&ctx, message, strlen(message));
    MD5_Final(digest, &ctx);
    
    int rsa_sign_valid = RSA_sign(NID_md5
                                  , digest, MD5_DIGEST_LENGTH
                                  , sig, &sig_len
                                  , _rsa_pri);
    
    if (rsa_sign_valid == 1) {
        NSData* data = [NSData dataWithBytes:sig length:sig_len];
        
        NSString * base64String = [data base64EncodedStringWithOptions:0];
        free(sig);
        return base64String;
    }
    
    free(sig);
    return nil;
    
    
}

#pragma mark-通过公钥对文本进行加密
////通过公钥对文本进行加密
//- (NSString *) encryptWithPublicKey:(NSString*)content
//{
//    if (!_rsa_pub) {
//        NSLog(@"please import public key first");
//        return nil;
//    }
//    int status;
//    int length  = (int)[content length];
//    unsigned char input[length + 1];
//    bzero(input, length + 1);
//    int i = 0;
//    for (; i < length; i++)
//    {
//        input[i] = [content characterAtIndex:i];
//    }
//
//    NSInteger  flen = [self getBlockSizeWithRSA_PADDING_TYPE:PADDING andRSA:_rsa_pub];
//
//    char *encData = (char*)malloc(flen);
//    bzero(encData, flen);
//    status = RSA_public_encrypt(length, (unsigned char*)input, (unsigned char*)encData, _rsa_pub, PADDING);
//
//    if (status){
//        NSData *returnData = [NSData dataWithBytes:encData length:status];
//        NSString * strHex = [self hex:returnData useLower:NO];
//        encData=NULL;
//        free(encData);
//
//        return strHex;
//    }
//
//    encData = NULL;
//    free(encData);
//
//    return nil;
//}


#pragma mark-通过公钥对文本进行加密
//通过公钥对文本进行加密
- (NSString *) encryptWithPublicKey:(NSString*)content
{
    
    
    
    if (!_rsa_pub) {
       
        return @"NULL";
    }
    int status;
//    if (content == NULL) {
//        return @"";
//    }
    const char *input = [content UTF8String];
    
    if(content.length==0){
        return @"";
    }
    
    
    
    
    int length  = (int)strlen(input);
    
    NSInteger  flen = [self getBlockSizeWithRSA_PADDING_TYPE:PADDING andRSA:_rsa_pub];
    
    if (flen < 0) {
        return @"";
    }
    
    char *encData = (char*)malloc(flen);
    bzero(encData, flen);
    status = RSA_public_encrypt(length, (unsigned char*)input, (unsigned char*)encData, _rsa_pub, PADDING);
    
    if (status){
        NSData *returnData = [NSData dataWithBytes:encData length:status];
        NSString * strHex = [self hex:returnData useLower:NO];
        encData=NULL;
        free(encData);
        
        return strHex;
    }
    
    encData = NULL;
    free(encData);
    
    return nil;
}



- (NSString *) decryptWithPrivatecKey:(NSString*)content
{
    if (!_rsa_pri) {
        NSLog(@"please import private key first");
        return nil;
    }    int status;
    
    //NSData *data = [content base64DecodedData];
    NSData *data = [[NSData alloc]initWithBase64EncodedString:content options:NSDataBase64DecodingIgnoreUnknownCharacters];
    int length = (int)[data length];
    
    NSInteger flen = [self getBlockSizeWithRSA_PADDING_TYPE:PADDING andRSA:_rsa_pri];
    char *decData = (char*)malloc(flen);
    bzero(decData, flen);
    
    status = RSA_private_decrypt(length, (unsigned char*)[data bytes], (unsigned char*)decData, _rsa_pri, PADDING);
    
    if (status)
    {
        NSMutableString *decryptString = [[NSMutableString alloc] initWithBytes:decData length:strlen(decData) encoding:NSASCIIStringEncoding];
        free(decData);
        decData = NULL;
        
        return decryptString;
    }
    
    free(decData);
    decData = NULL;
    
    return nil;
}

- (int)getBlockSizeWithRSA_PADDING_TYPE:(RSA_PADDING_TYPE)padding_type andRSA:(RSA*)rsa
{
    int len = RSA_size(rsa);
    
    if (padding_type == RSA_PADDING_TYPE_PKCS1 || padding_type == RSA_PADDING_TYPE_SSLV23) {
        len -= 11;
    }
    
    return len;
}

-(NSString*)formatRSAKeyWithKeyString:(NSString*)keyString andKeytype:(KeyType)type
{
    NSInteger lineNum = -1;
    NSMutableString *result = [NSMutableString string];
    
    if (type == KeyTypePrivate) {
        [result appendString:@"-----BEGIN PRIVATE KEY-----\n"];
        lineNum = 79;
    }else if(type == KeyTypePublic){
        [result appendString:@"-----BEGIN PUBLIC KEY-----\n"];
        lineNum = 76;
    }
    
    int count = 0;
    for (int i = 0; i < [keyString length]; ++i) {
        unichar c = [keyString characterAtIndex:i];
        if (c == '\n' || c == '\r') {
            continue;
        }
        [result appendFormat:@"%c", c];
        if (++count == lineNum) {
            [result appendString:@"\n"];
            count = 0;
        }
    }
    if (type == KeyTypePrivate) {
        [result appendString:@"\n-----END PRIVATE KEY-----"];
        
    }else if(type == KeyTypePublic){
        [result appendString:@"\n-----END PUBLIC KEY-----"];
    }
    return result;
    
}




BIGNUM* bignum_decode(const char* bignum) {
    BIGNUM* bn = NULL;
    
    BN_dec2bn(&bn, bignum);
    
    return bn;
}

EVP_PKEY* RSA_fromBase64(const char* modulus, const char* exp) {
    BIGNUM *n = bignum_decode(modulus);
    BIGNUM *e = bignum_decode(exp);
    
    if (!n) printf("Invalid encoding for modulus\n");
    if (!e) printf("Invalid encoding for public exponent\n");
    
    if (e && n) {
        EVP_PKEY* pRsaKey = EVP_PKEY_new();
        RSA* rsa = RSA_new();
        rsa->e = e;
        rsa->n = n;
        EVP_PKEY_assign_RSA(pRsaKey, rsa);
        return pRsaKey;
    } else {
        if (n) BN_free(n);
        if (e) BN_free(e);
        return NULL;
    }
}

#pragma mark-根据模和指数生成公钥
//根据模和指数生成公钥
- (BOOL)KeyWithModulus:(NSString *)modulus andExp:(NSString *)exp
{
    if (!modulus||!exp) {
        return NO;
    }
    BOOL status = NO;
    BIGNUM *n = bignum_decode([modulus cStringUsingEncoding:NSUTF8StringEncoding]);
    BIGNUM *e = bignum_decode([exp cStringUsingEncoding:NSUTF8StringEncoding]);
    
    if (n && e) {
        EVP_PKEY* pRsaKey = EVP_PKEY_new();
        RSA* rsa = RSA_new();
        rsa->e = e;
        rsa->n = n;
        EVP_PKEY_assign_RSA(pRsaKey, rsa);
        RSA *EVP_PKEY_get1_RSA(EVP_PKEY *pRsaKey);
        _rsa_pub = rsa;
        if (rsa != NULL && 1 == RSA_check_key(rsa)) {
            status = YES;
        } else {
            status = NO;
        }
        
        
    }
    else{
        if (n) BN_free(n);
        if (e) BN_free(e);
        status = NO;
    }
    
    return status;
}



void assert_syntax(int argc, char** argv) {
    if (argc != 4) {
        fprintf(stderr, "Description: %s takes a RSA public key modulus and exponent in base64 encoding and produces a public key file in PEM format.\n", argv[0]);
        fprintf(stderr, "syntax: %s <modulus_base64> <exp_base64> <output_file>\n", argv[0]);
        exit(1);
    }
}

#pragma MARK-data转字符串
//data转字符串
- (NSString*)hexStringForData:(NSData*)data

{
    
    if (data == nil) {
        
        return nil;
        
    }
    
    
    NSMutableString* hexString = [NSMutableString string];
    
    
    const unsigned char *p = [data bytes];
    
    
    
    for (int i=0; i < [data length]; i++) {
        
        [hexString appendFormat:@"%02x", *p++];
        
    }
    
    return hexString;
    
}

#pragma mark-根据模和指数对数据进行加密
//根据模和指数对数据进行加密
- (NSString *)setPublicKey:(const char *)data Mod:(const char *)mod Exp:(const char *)exp
{
    RSA * pubkey = RSA_new();
    
    BIGNUM * bnmod = BN_new();
    
    BIGNUM * bnexp = BN_new();
    
    BN_dec2bn(&bnmod, mod);
    BN_dec2bn(&bnexp, exp);
    
    pubkey->n = bnmod;
    pubkey->e = bnexp;
    
    int nLen = RSA_size(pubkey);
    char *crip = (char *)malloc(sizeof(char*)*nLen+1);
    
    //RSA_print_fp(stdout,pubkey,10);
    int nLen1 = RSA_public_encrypt((int)strlen((const char *) data), (const unsigned char *) data, (unsigned char *) crip, pubkey, RSA_PKCS1_PADDING);
    //NSLog(@"len size : %d",nLen1);
    if (nLen1 <= 0)
    {
        NSLog(@"erro encrypt");
    }
    else
    {
        NSLog(@"SUC encrypt");
    }
    
    free(crip);
    RSA_free(pubkey);
    
    NSData *resData = [NSData dataWithBytes:crip length:nLen];
    return [self hex:resData useLower:NO];
}


#pragma mark-将二进制数据转化为16进制字条串
//将二进制数据转化为16进制字条串
- (NSString *)hex: (NSData *)data useLower: (bool)isOutputLower
{
    static const char HexEncodeCharsLower[] = { '0', '1', '2', '3', '4', '5', '6', '7', '8', '9', 'a', 'b', 'c', 'd', 'e', 'f' };
    static const char HexEncodeChars[] = { '0', '1', '2', '3', '4', '5', '6', '7', '8', '9', 'A', 'B', 'C', 'D', 'E', 'F' };
    char *resultData;
    // malloc result data
    resultData = malloc([data length] * 2 +1);
    // convert imgData(NSData) to char[]
    unsigned char *sourceData = ((unsigned char *)[data bytes]);
    uint length = [data length];
    
    if (isOutputLower) {
        for (uint index = 0; index < length; index++) {
            // set result data
            resultData[index * 2] = HexEncodeCharsLower[(sourceData[index] >> 4)];
            resultData[index * 2 + 1] = HexEncodeCharsLower[(sourceData[index] % 0x10)];
        }
    }
    else {
        for (uint index = 0; index < length; index++) {
            // set result data
            resultData[index * 2] = HexEncodeChars[(sourceData[index] >> 4)];
            resultData[index * 2 + 1] = HexEncodeChars[(sourceData[index] % 0x10)];
        }
    }
    resultData[[data length] * 2] = 0;
    
    // convert result(char[]) to NSString
    NSString *result = [NSString stringWithCString:resultData encoding:NSASCIIStringEncoding];
    sourceData = nil;
    free(resultData);
    
    return result;
}

@end
