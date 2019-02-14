//
//  DKCSKDID.m
//  DKCSProject
//
//  Created by hzad on 2019/1/7.
//  Copyright © 2019 hzad. All rights reserved.
//

#import "WJDKDID.h"

@implementation WJDKDID

+ (NSString *)getKDID{
    
    NSString *uuid =[self loadStringDataWithIdentifier:@"JD_UUID"];
    if (!uuid) {
        NSString *idfv = [[[UIDevice currentDevice] identifierForVendor] UUIDString];
        [self saveStringWithdIdentifier:@"JD_UUID" data:idfv];
        uuid =idfv;
    }
    return uuid;
    
}

+ (BOOL)saveStringWithdIdentifier:(NSString *)identifier data:(NSString *)str;
{
    
    //Get search dictionary
    NSMutableDictionary *keychainQuery = [self getKeychainQuery:identifier accessGroup:nil];
    //Delete old item before add new item
    SecItemDelete((CFDictionaryRef)keychainQuery);
    //Add new object to search dictionary(Attention:the data format)
    [keychainQuery setObject:[NSKeyedArchiver archivedDataWithRootObject:str] forKey:(id)kSecValueData];
    //Add item to keychain with the search dictionary
    OSStatus status =  SecItemAdd((CFDictionaryRef)keychainQuery, NULL);
    if (status != noErr) {
        return NO;
    }
    return YES;
    
}

//获取通用密码类型的一个查询体
+ (NSMutableDictionary *)getKeychainQuery:(NSString *)identifier accessGroup:(NSString *)accessGroup
{
    
    
    
    NSMutableDictionary *dic =[NSMutableDictionary dictionaryWithObjectsAndKeys:
                               (id)kSecClassGenericPassword,(id)kSecClass,
                               identifier, (id)kSecAttrAccount,//一般密码
                               (id)kSecAttrAccessibleAfterFirstUnlock,(id)kSecAttrAccessible,
                               nil];
    if (accessGroup) {
        [dic setObject:accessGroup forKey:(id)kSecAttrAccessGroup];
        [dic setObject:identifier forKey:(id)kSecAttrGeneric];
        
    }
    return dic;
}

+ (NSString *)loadStringDataWithIdentifier:(NSString *)identifier
{
    NSString *ret = nil;
    NSMutableDictionary *keychainQuery = [self getKeychainQuery:identifier accessGroup:nil];
    //Configure the search setting
    //Since in our simple case we are expecting only a single attribute to be returned (the password) we can set the attribute kSecReturnData to kCFBooleanTrue
    [keychainQuery setObject:(id)kCFBooleanTrue forKey:(id)kSecReturnData];
    [keychainQuery setObject:(id)kSecMatchLimitOne forKey:(id)kSecMatchLimit];
    CFDataRef keyData = NULL;
    if (SecItemCopyMatching((CFDictionaryRef)keychainQuery, (CFTypeRef *)&keyData) == noErr) {
        @try {
            ret = [NSKeyedUnarchiver unarchiveObjectWithData:(__bridge NSData *)keyData];
        } @catch (NSException *e) {
            DLog(@"Unarchive of %@ failed: %@", identifier, e);
        } @finally {
        }
    }
    if (keyData)
        CFRelease(keyData);
    return ret;
}


@end
