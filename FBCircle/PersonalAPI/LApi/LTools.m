//
//  LCWTools.m
//  FBAuto
//
//  Created by lichaowei on 14-7-9.
//  Copyright (c) 2014年 szk. All rights reserved.
//

#import "LTools.h"
#import <CommonCrypto/CommonDigest.h>
#import "AppDelegate.h"


@implementation LTools

+ (id)shareInstance
{
    static dispatch_once_t once_t;
    static LTools *dataBlock;
    
    dispatch_once(&once_t, ^{
        dataBlock = [[LTools alloc]init];
    });
    
    return dataBlock;
}

#pragma - mark MD5 加密

+ (NSString *) md5:(NSString *) text
{
    const char * bytes = [text UTF8String];
    unsigned char md5Binary[16];
    CC_MD5(bytes, (CC_LONG)strlen(bytes), md5Binary);
    
    NSString * md5String = [NSString
                            stringWithFormat:@"%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x",
                            md5Binary[0], md5Binary[1], md5Binary[2], md5Binary[3],
                            md5Binary[4], md5Binary[5], md5Binary[6], md5Binary[7],
                            md5Binary[8], md5Binary[9], md5Binary[10], md5Binary[11],
                            md5Binary[12], md5Binary[13], md5Binary[14], md5Binary[15]
                            ];
    return md5String;
}

#pragma - mark 网络数据请求

- (id)initWithUrl:(NSString *)url isPost:(BOOL)isPost postData:(NSData *)postData//post
{
    self = [super init];
    if (self) {
        requestUrl = url;
        
        if (isPost) {
            requestData = postData;
            isPostRequest = isPost;
        }
    }
    return self;
}

- (void)requestCompletion:(void(^)(NSDictionary *result,NSError *erro))completionBlock failBlock:(void(^)(NSDictionary *failDic,NSError *erro))failedBlock{
    successBlock = completionBlock;
    failBlock = failedBlock;
    
    NSString *newStr = [requestUrl stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    NSLog(@"requestUrl %@",newStr);
    NSURL *urlS = [NSURL URLWithString:newStr];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:urlS cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:2];
    
    
    if (isPostRequest) {
        
        [request setHTTPMethod:@"POST"];
        
        [request setHTTPBody:requestData];
    }

    
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
        
        if (data.length > 0) {
            NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
            
            NSLog(@"response :%@",response);
            
            if ([dic isKindOfClass:[NSDictionary class]]) {
                
                int erroCode = [[dic objectForKey:@"errcode"]intValue];
                NSString *erroInfo = [dic objectForKey:@"errinfo"];
                


                if (erroCode != 0) { //0代表无错误,  && erroCode != 1 1代表无结果


                    NSDictionary *failDic = @{ERROR_INFO:erroInfo};
                    failBlock(failDic,connectionError);
                    
                    return ;
                }else
                {
                    successBlock(dic,connectionError);//传递的已经是没有错误的结果
                }
            }
            
        }else
        {
            NSLog(@"data 为空 connectionError %@",connectionError);
            
            NSString *errInfo = @"网络有问题,请检查网络";
            switch (connectionError.code) {
                case NSURLErrorNotConnectedToInternet:
                    
                    errInfo = @"无网络连接";
                    break;
                case NSURLErrorTimedOut:
                    
                    errInfo = @"网络连接超时";
                    break;
                default:
                    break;
            }
            
            NSDictionary *failDic = @{ERROR_INFO: errInfo};
            failBlock(failDic,connectionError);
            
        }
        
    }];

}

#pragma mark - 常用视图快速创建

+ (UIButton *)createButtonWithType:(UIButtonType)buttonType
                             frame:(CGRect)aFrame
                             normalTitle:(NSString *)normalTitle
                    backgroudImage:(UIImage *)image
                         superView:(UIView *)superView
                            target:(id)target
                            action:(SEL)action
{
    UIButton *btn = [UIButton buttonWithType:buttonType];
    btn.frame = aFrame;
    [btn setTitle:normalTitle forState:UIControlStateNormal];
    [btn setBackgroundImage:image forState:UIControlStateNormal];
    [btn addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];
    [superView addSubview:btn];
    return btn;
}

#pragma - mark 验证邮箱、电话等有效性

/*匹配正整数*/
+ (BOOL)isValidateInt:(NSString *)digit
{
    NSString * digitalRegex = @"^[1-9]\\d*$";
    NSPredicate * digitalTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",digitalRegex];
    return [digitalTest evaluateWithObject:digit];
}

/*匹配整浮点数*/
+ (BOOL)isValidateFloat:(NSString *)digit
{
    NSString * digitalRegex = @"^[1-9]\\d*\\.\\d*|0\\.\\d*[1-9]\\d*$";
    NSPredicate * digitalTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",digitalRegex];
    return [digitalTest evaluateWithObject:digit];
}

/*邮箱*/
+ (BOOL)isValidateEmail:(NSString *)email
{
    NSString * emailRegex = @"\\w+([-+.]\\w+)*@\\w+([-.]\\w+)*\\.\\w+([-.]\\w+)*";
    NSPredicate * emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",emailRegex];
    return [emailTest evaluateWithObject:email];
}

+ (BOOL)isValidateName:(NSString *)userName
{
    NSString * emailRegex = @"^[\u4E00-\u9FA5a-zA-Z0-9_]{1,20}$";
    NSPredicate * emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",emailRegex];
    return [emailTest evaluateWithObject:userName];
}

+ (BOOL)isValidatePwd:(NSString *)pwdString
{
    NSString * emailRegex = @"^[a-zA-Z0-9_]{6,20}$";
    NSPredicate * emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",emailRegex];
    return [emailTest evaluateWithObject:pwdString];
}

/*手机及固话*/
+ (BOOL)isValidateMobile:(NSString *)mobileNum
{
    /**
     * 手机号码
     * 移动：134[0-8],135,136,137,138,139,150,151,157,158,159,182,187,188
     * 联通：130,131,132,152,155,156,185,186
     * 电信：133,1349,153,180,189
     */
    NSString * MOBILE = @"^1(3[0-9]|5[0-35-9]|8[025-9])\\d{8}$";
    /**
     10         * 中国移动：China Mobile
     11         * 134[0-8],135,136,137,138,139,150,151,157,158,159,182,187,188
     12         */
    NSString * CM = @"^1(34[0-8]|(3[5-9]|5[017-9]|8[278])\\d)\\d{7}$";
    /**
     15         * 中国联通：China Unicom
     16         * 130,131,132,152,155,156,185,186
     17         */
    NSString * CU = @"^1(3[0-2]|5[256]|8[56])\\d{8}$";
    /**
     20         * 中国电信：China Telecom
     21         * 133,1349,153,180,189
     22         */
    NSString * CT = @"^1((33|53|8[09])[0-9]|349)\\d{7}$";
    /**
     25         * 大陆地区固话及小灵通
     26         * 区号：010,020,021,022,023,024,025,027,028,029
     27         * 号码：七位或八位
     28         */
    // NSString * PHS = @"^0(10|2[0-5789]|\\d{3})\\d{7,8}$";
    
    NSPredicate *regextestmobile = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", MOBILE];
    NSPredicate *regextestcm = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", CM];
    NSPredicate *regextestcu = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", CU];
    NSPredicate *regextestct = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", CT];
    
    if (([regextestmobile evaluateWithObject:mobileNum] == YES)
        || ([regextestcm evaluateWithObject:mobileNum] == YES)
        || ([regextestct evaluateWithObject:mobileNum] == YES)
        || ([regextestcu evaluateWithObject:mobileNum] == YES))
    {
        return YES;
    }
    else
    {
        return NO;
    }
}

#pragma - mark 小工具

//时间线转化

+(NSString *)timechange:(NSString *)placetime
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init] ;
    [formatter setDateStyle:NSDateFormatterMediumStyle];
    [formatter setTimeStyle:NSDateFormatterShortStyle];
    [formatter setDateFormat:@"MM-dd"];
    NSDate *confromTimesp = [NSDate dateWithTimeIntervalSince1970:[placetime doubleValue]];
    NSString *confromTimespStr = [formatter stringFromDate:confromTimesp];
    return confromTimespStr;
}

+(NSString *)timechange2:(NSString *)placetime
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init] ;
    [formatter setDateStyle:NSDateFormatterMediumStyle];
    [formatter setTimeStyle:NSDateFormatterShortStyle];
    [formatter setDateFormat:@"YYYY.MM.dd"];
    NSDate *confromTimesp = [NSDate dateWithTimeIntervalSince1970:[placetime doubleValue]];
    NSString *confromTimespStr = [formatter stringFromDate:confromTimesp];
    return confromTimespStr;
}

+(NSString *)timechange3:(NSString *)placetime
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init] ;
    [formatter setDateStyle:NSDateFormatterMediumStyle];
    [formatter setTimeStyle:NSDateFormatterShortStyle];
    [formatter setDateFormat:@"YYYY年MM月"];
    NSDate *confromTimesp = [NSDate dateWithTimeIntervalSince1970:[placetime doubleValue]];
    NSString *confromTimespStr = [formatter stringFromDate:confromTimesp];
    return confromTimespStr;
}


+ (NSString *)currentTime
{
    NSDateFormatter *outputFormatter = [[NSDateFormatter alloc] init];
    
    [outputFormatter setLocale:[NSLocale currentLocale]];
    
    [outputFormatter setDateFormat:@"yyyy-MM-dd"];
    
    NSString *date = [outputFormatter stringFromDate:[NSDate date]];
    
    NSLog(@"时间 === %@",date);
    return date;
}

//alert 提示

+ (void)alertText:(NSString *)text
{
    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:nil message:text delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
    [alert show];
}


+ (void)showMBProgressWithText:(NSString *)text addToView:(UIView *)aView
{
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:aView animated:YES];
    hud.mode = MBProgressHUDModeText;
    hud.labelText = text;
    hud.margin = 15.f;
    hud.yOffset = 150.f;
    hud.removeFromSuperViewOnHide = YES;
    [hud hide:YES afterDelay:1.5];
}

#pragma - mark 非空字符串

+ (NSString *)NSStringNotNull:(NSString *)text
{
    if (![text isKindOfClass:[NSString class]]) {
        return @"";
    }
    return text;
}

#pragma - mark CoreData数据管理

@synthesize managedObjectContext = _managedObjectContext;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;

- (void)saveContext
{
    NSError *error = nil;
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    if (managedObjectContext != nil) {
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
            // Replace this implementation with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
    }
}

#pragma mark - Core Data stack

// Returns the managed object context for the application.
// If the context doesn't already exist, it is created and bound to the persistent store coordinator for the application.
- (NSManagedObjectContext *)managedObjectContext
{
    if (_managedObjectContext != nil) {
        return _managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil) {
        _managedObjectContext = [[NSManagedObjectContext alloc] init];
        [_managedObjectContext setPersistentStoreCoordinator:coordinator];
    }
    return _managedObjectContext;
}

// Returns the managed object model for the application.
// If the model doesn't already exist, it is created from the application's model.
- (NSManagedObjectModel *)managedObjectModel
{
    if (_managedObjectModel != nil) {
        return _managedObjectModel;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"FBAuto" withExtension:@"momd"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return _managedObjectModel;
}

// Returns the persistent store coordinator for the application.
// If the coordinator doesn't already exist, it is created and the application's store added to it.
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
    if (_persistentStoreCoordinator != nil) {
        return _persistentStoreCoordinator;
    }
    
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"FBAuto.sqlite"];
    
    NSError *error = nil;
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error]) {
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    
    return _persistentStoreCoordinator;
}

#pragma mark - Application's Documents directory

- (NSURL *)applicationDocumentsDirectory
{
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

//查询数据的时候使用，不然查出的数据会dealloc

- (NSManagedObjectContext *)context
{
    return ((AppDelegate *)[[UIApplication sharedApplication] delegate]).managedObjectContext;
}

//#pragma - mark 查询 车品牌、车型、车款
////车品牌
//- (NSArray*)queryCarBrand
//{
//    NSManagedObjectContext *context = [self context];
//    
//    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
//    NSEntityDescription *entity = [NSEntityDescription entityForName:NSStringFromClass([CarBrand class]) inManagedObjectContext:context];
//    [fetchRequest setEntity:entity];
//    NSError *error;
//    NSArray *fetchedObjects = [context executeFetchRequest:fetchRequest error:&error];
//    
//    return fetchedObjects;
//}
//
////车型
//- (NSArray*)queryCarTypeUnique:(NSString *)unique
//{
//    NSManagedObjectContext *context = [self context];
//    
//    NSPredicate *predicate = [NSPredicate
//                              predicateWithFormat:@"parentId like[cd] %@",unique];
//    
//    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
//    
//    [fetchRequest setPredicate:predicate];
//    
//    NSEntityDescription *entity = [NSEntityDescription entityForName:NSStringFromClass([CarType class]) inManagedObjectContext:context];
//    [fetchRequest setEntity:entity];
//    NSError *error;
//    NSArray *fetchedObjects = [context executeFetchRequest:fetchRequest error:&error];
//    
//    return fetchedObjects;
//}
//
////车款
//- (NSArray*)queryCarStyleUnique:(NSString *)unique
//{
//    NSManagedObjectContext *context = [self context];
//    
//    NSPredicate *predicate = [NSPredicate
//                              predicateWithFormat:@"parentId like[cd] %@",unique];
//    
//    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
//    
//    [fetchRequest setPredicate:predicate];
//    
//    NSEntityDescription *entity = [NSEntityDescription entityForName:NSStringFromClass([CarStyle class]) inManagedObjectContext:context];
//    [fetchRequest setEntity:entity];
//    NSError *error;
//    NSArray *fetchedObjects = [context executeFetchRequest:fetchRequest error:&error];
//    
//    return fetchedObjects;
//}
//
//#pragma - mark 判断 车品牌、车型、车款是否已存在
//
////车品牌是否存在
//- (BOOL)brandUnique:(NSString *)unique
//{
//    NSManagedObjectContext *context = [self context];
//    
//    NSPredicate *predicate = [NSPredicate
//                              predicateWithFormat:@"brandId like[cd] %@",unique];
//    
//    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
//    
//    [fetchRequest setPredicate:predicate];
//    
//    NSEntityDescription *entity = [NSEntityDescription entityForName:NSStringFromClass([CarBrand class]) inManagedObjectContext:context];
//    [fetchRequest setEntity:entity];
//    NSError *error;
//    NSArray *fetchedObjects = [context executeFetchRequest:fetchRequest error:&error];
//    if (fetchedObjects.count > 0) {
//        return YES;
//    }
//    
//    return NO;
//}
//
//#pragma - mark 车品牌、车型、车款是否存在
//
//- (BOOL)existEntityUnique:(NSString *)unique parentId:(NSString *)parentId type:(NSString *)type
//{
//    NSManagedObjectContext *context = [self context];
//    
//    unique = (unique != nil) ? unique : @"";
//    NSString *entityName = nil;
//    NSPredicate *predicate = nil;
//    if ([type isEqualToString:CARSOURCE_BRAND_EXIST]) {
//        
//        predicate = [NSPredicate predicateWithFormat:@"brandId like[cd] %@",unique];
//        entityName = NSStringFromClass([CarBrand class]);
//        
//    }else if ([type isEqualToString:CARSOURCE_TYPE_EXIST])
//    {
//        predicate = [NSPredicate predicateWithFormat:@"typeName like[cd] %@",unique];
//        entityName = NSStringFromClass([CarType class]);
//        
//    }else if ([type isEqualToString:CARSOURCE_STYLE_EXIST])
//    {
//        predicate = [NSPredicate predicateWithFormat:@"styleName like[cd] %@",unique];
//        entityName = NSStringFromClass([CarStyle class]);
//    }
//    
//    
//    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
//    
//    [fetchRequest setPredicate:predicate];
//    
//    NSEntityDescription *entity = [NSEntityDescription entityForName:entityName inManagedObjectContext:context];
//    [fetchRequest setEntity:entity];
//    NSError *error;
//    NSArray *fetchedObjects = [context executeFetchRequest:fetchRequest error:&error];
//    if (fetchedObjects.count > 0) {
//        return YES;
//    }
//    
//    return NO;
//}
//
@end
