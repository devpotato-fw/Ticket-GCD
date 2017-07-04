//
//  ViewController.m
//  Ticket(GCK)
//
//  Created by wangfang on 2017/3/2.
//  Copyright © 2017年 onefboy. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@property (assign, nonatomic) NSUInteger ticketCount;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    // 先监听线程退出的通知，以便知道线程什么时候退出
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(threadExitNotice)
                                                 name:NSThreadWillExitNotification
                                               object:nil];
    
    _ticketCount = 50;
    
    //1.创建队列组
    dispatch_group_t group = dispatch_group_create();
    
    //2.创建队列
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    
    // dispatch_group_async是异步的方法
    dispatch_group_async(group, queue, ^{
        
        [NSThread currentThread].name= @"西安售票系统";
        [self saleTicket];
        NSLog(@"-西安售票系统-");
    });
    
    dispatch_group_async(group, queue, ^{
        
        [NSThread currentThread].name= @"北京售票系统";
        [self saleTicket];
        NSLog(@"-北京售票系统-");
    });
    
    // 队列组里所有的任务都执行完了，队列组会通知我们
    dispatch_group_notify(group, dispatch_get_main_queue(), ^{
        
        NSLog(@"票已卖完");
    });
}

- (void)threadExitNotice {
    
    NSLog(@"%@", [NSThread currentThread]);
}

- (void)saleTicket {
    while (1) {
        // 添加同步锁
        @synchronized(self) {
            //如果还有票，继续售卖
            if (_ticketCount > 0) {
                _ticketCount --;
                NSLog(@"%@", [NSString stringWithFormat:@"剩余票数：%ld 窗口：%@", _ticketCount, [NSThread currentThread].name]);
                [NSThread sleepForTimeInterval:0.2];
            }
            //如果已卖完，关闭售票窗口
            else {
                break;
            }
        }
    }
}

@end
