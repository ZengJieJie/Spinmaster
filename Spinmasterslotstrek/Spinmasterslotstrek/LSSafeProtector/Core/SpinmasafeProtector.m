//
//  LSSafeProtector.m
// https://github.com/lsmakethebest/LSSafeProtector
//
//  Created by liusong on 2018/8/9.
//  Copyright © 2018年 liusong. All rights reserved.
//

#import "SpinmasafeProtector.h"

static  LSSpinmasSafeProtectorLogType ls_safe_logType=LSSafeProtectorLogTypeAll;
static  LSSafeProtectorBlock lsSafeProtectorBlock;
static  BOOL LSSafeProtectorKVODebugInfoEnable=NO;
@interface NSObject (LSSafeProtector)
//打开当前类安全保护
+ (void)openSpinmasSafeProtector;
+ (void)openKSpinmasVOSafeProtector;
+(void)opSpinmasenMRCSafeProtector;
@end


#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wincomplete-implementation"

@implementation NSObject (LSSafeProtector)
@end

#pragma clang diagnostic pop


@implementation SpinmasafeProtector

+(void)SpinmasopenSafeProtectorWithIsDebug:(BOOL)isDebug block:(LSSafeProtectorBlock)block
{
    [self SpinmasopenSafeProtectorWithIsDebug:isDebug types:LSSafeProtectorCrashTypeAll block:block];
}

+(void)SpinmasopenSafeProtectorWithIsDebug:(BOOL)isDebug types:(LSSafeProtectorCrashType)types block:(LSSafeProtectorBlock)block
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (types & LSSafeProtectorCrashTypeSelector) {
            //开启防止selecetor crash
            [NSObject openSpinmasSafeProtector];
        }
        if (types & LSSafeProtectorCrashTypeNSArray) {
            [NSArray openSpinmasSafeProtector];
        }
        
        if (types & LSSafeProtectorCrashTypeNSMutableArray) {
            [NSMutableArray openSpinmasSafeProtector];
            [NSMutableArray opSpinmasenMRCSafeProtector];
        }
        
        if (types & LSSafeProtectorCrashTypeNSDictionary) {
            [NSDictionary openSpinmasSafeProtector];
        }
        
        if (types & LSSafeProtectorCrashTypeNSMutableDictionary) {
            [NSMutableDictionary openSpinmasSafeProtector];
        }
        
        if (types & LSSafeProtectorCrashTypeNSStirng) {
            [NSString openSpinmasSafeProtector];
        }
        
        if (types & LSSafeProtectorCrashTypeNSMutableString) {
            [NSMutableString openSpinmasSafeProtector];
        }
        
        if (types & LSSafeProtectorCrashTypeNSAttributedString) {
            [NSAttributedString openSpinmasSafeProtector];
        }
        
        if (types & LSSafeProtectorCrashTypeNSMutableAttributedString) {
            [NSMutableAttributedString openSpinmasSafeProtector];
        }
        
        if (types & LSSafeProtectorCrashTypeNSNotificationCenter) {
            [NSNotificationCenter openSpinmasSafeProtector];
        }
    
        if (types & LSSafeProtectorCrashTypeKVO) {
            [NSObject openKSpinmasVOSafeProtector];
        }
        
        if (types & LSSafeProtectorCrashTypeNSUserDefaults) {
            [NSUserDefaults openSpinmasSafeProtector];
        }
        
        if (types & LSSafeProtectorCrashTypeNSCache) {
            [NSCache openSpinmasSafeProtector];
        }
        
        if (types & LSSafeProtectorCrashTypeNSSet) {
            [NSSet openSpinmasSafeProtector];
        }
        
        if (types & LSSafeProtectorCrashTypeNSMutableSet) {
            [NSMutableSet openSpinmasSafeProtector];
        }
        
        if (types & LSSafeProtectorCrashTypeNSOrderedSet) {
            [NSOrderedSet openSpinmasSafeProtector];
        }
        
        if (types & LSSafeProtectorCrashTypeNSMutableOrderedSet) {
            [NSMutableOrderedSet openSpinmasSafeProtector];
        }
        
        if (types & LSSafeProtectorCrashTypeNSData) {
            [NSData openSpinmasSafeProtector];
        }
        
        if (types & LSSafeProtectorCrashTypeNSMutableData) {
            [NSMutableData openSpinmasSafeProtector];
        }
        
        if (isDebug) {
            ls_safe_logType=LSSafeProtectorLogTypeAll;
        }else{
            ls_safe_logType=LSSafeProtectorLogTypeNone;
        }
        lsSafeProtectorBlock=block;
    });
}


+ (void)Spinmassafe_logCrashWithException:(NSException *)exception crashType:(LSSafeProtectorCrashType)crashType
{
    // 堆栈数据
    NSArray *callStackSymbolsArr = [NSThread callStackSymbols];
    
    //获取在哪个类的哪个方法中实例化的数组
    NSString *mainMessage = [self safe_getMainCallStackSymbolMessageWithCallStackSymbolArray: callStackSymbolsArr index:2 first:YES];
    
    if (mainMessage == nil) {
        mainMessage = @"崩溃方法定位失败,请您查看函数调用栈来查找crash原因";
    }
    
    NSString *crashName = [NSString stringWithFormat:@"\t\t[Crash Type]: %@",exception.name];
    
    NSString *crashReason = [NSString stringWithFormat:@"\t\t[Crash Reason]: %@",exception.reason];;
    NSString *crashLocation = [NSString stringWithFormat:@"\t\t[Crash Location]: %@",mainMessage];
    
    NSString *fullMessage = [NSString stringWithFormat:@"\n------------------------------------  Crash START -------------------------------------\n%@\n%@\n%@\n函数堆栈:\n%@\n------------------------------------   Crash END  -----------------------------------------", crashName, crashReason, crashLocation, exception.callStackSymbols];
    
    NSMutableDictionary *userInfo=[NSMutableDictionary dictionary];
    userInfo[@"callStackSymbols"]=[NSString stringWithFormat:@"%@",exception.callStackSymbols];
    userInfo[@"location"]=mainMessage;
    NSException *newException = [NSException exceptionWithName:exception.name reason:exception.reason userInfo:userInfo];
    if (lsSafeProtectorBlock) {
        lsSafeProtectorBlock(newException,crashType);
    }
    LSSpinmasSafeProtectorLogType logType=ls_safe_logType;
    if (logType==LSSafeProtectorLogTypeNone) {
    }
    else if (logType==LSSafeProtectorLogTypeAll) {
        LSSafeLog(@"%@", fullMessage);
        assert(NO&&"检测到崩溃，详情请查看上面信息");
    }
}

#pragma mark -   获取堆栈主要崩溃精简化的信息<根据正则表达式匹配出来
+ (NSString *)safe_getMainCallStackSymbolMessageWithCallStackSymbolArray:(NSArray *)callStackSymbolArray index:(NSInteger)index first:(BOOL)first
{
    NSString *  callStackSymbolString;
    if (callStackSymbolArray.count<=0) {
        return nil;
    }
    if (index<callStackSymbolArray.count) {
        callStackSymbolString=callStackSymbolArray[index];
    }
    //正则表达式
    //http://www.jianshu.com/p/b25b05ef170d
    
    //mainCallStackSymbolMsg 的格式为   +[类名 方法名]  或者 -[类名 方法名]
    __block NSString *mainCallStackSymbolMsg = nil;
    
    //匹配出来的格式为 +[类名 方法名]  或者 -[类名 方法名]
    NSString *regularExpStr = @"[-\\+]\\[.+\\]";
    
    NSRegularExpression *regularExp = [[NSRegularExpression alloc] initWithPattern:regularExpStr options:NSRegularExpressionCaseInsensitive error:nil];
    
    [regularExp enumerateMatchesInString:callStackSymbolString options:NSMatchingReportProgress range:NSMakeRange(0, callStackSymbolString.length) usingBlock:^(NSTextCheckingResult * _Nullable result, NSMatchingFlags flags, BOOL * _Nonnull stop) {
        if (result) {
            mainCallStackSymbolMsg = [callStackSymbolString substringWithRange:result.range];
            *stop = YES;
        }
    }];
    
    if (index==0) {
        return mainCallStackSymbolMsg;
    }
    if (mainCallStackSymbolMsg==nil) {
        NSInteger newIndex=0;
        if (first) {
            newIndex=callStackSymbolArray.count-1;
        }else{
            newIndex=index-1;
        }
        mainCallStackSymbolMsg = [self safe_getMainCallStackSymbolMessageWithCallStackSymbolArray:callStackSymbolArray index:newIndex first:NO];
    }
    return mainCallStackSymbolMsg;
}
void sSpinmasafe_KVOCustomLog(NSString *format,...)
{
    if (LSSafeProtectorKVODebugInfoEnable) {
        va_list args;
        va_start(args, format);
        NSString *string = [[NSString alloc] initWithFormat:format arguments:args];
        NSString *strFormat = [NSString stringWithFormat:@"%@",string];
        NSLogv(strFormat, args);
        va_end(args);
    }
}

+(void)SpinmasLogEnable:(BOOL)enable
{
    LSSafeProtectorKVODebugInfoEnable=enable;
}

@end
