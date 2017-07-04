# Ticket-GCD
Grand Central Dispatch简称（GCD）是苹果公司开发的技术，以优化的应用程序支持多核心处理器和其他的对称多处理系统的系统。这建立在任务并行执行的线程池模式的基础上的。它首次发布在 Mac OS X 10.6 以及 iOS 4 上。

1、GCD的工作原理是：让程序平行排队的特定任务，根据可用的处理资源，安排他们在任何可用的处理器核心上执行任务。

2、一个任务可以是一个函数(function)或者是一个block。GCD的底层依然是用线程实现，不过这样可以让程序员不用关注实现的细节。

3、GCD中的FIFO队列称为dispatch queue，它可以保证先进来的任务先得到执行。
队列类型：

1、串行队列（Serial queues）同时只执行一个任务。Serial queue通常用于同步访问特定的资源或数据。当你创建多个Serial queue时，虽然它们各自是同步执行的，但Serial queue与Serial queue之间是并发执行的。

2、并发队列（Concurrent queue）可以并发地执行多个任务，但是执行完成的顺序是随机的。
队列使用

1、主队列（Main queue）：是一个特殊的串行队列，是全局可用的特殊队列。它是在应用程序主线程上执行任务的。和其它串行队列一样，这个队列中的任务一次只能执行一个。然而，它能保证所有的任务都在主线程执行，而主线程是唯一可用于更新UI的线程。这个队列就是用于发生消息给UIView或发送通知的。

获取主队列

dispatch_queue_t mainQueue = dispatch_get_main_queue();
2、全局并行队列：这应该是唯一一个并行队列，只要是并行任务一般都加入到这个队列。这是系统提供的一个并发队列。

获取并行队列

dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
3、自定义队列

自定义串行队列

dispatch_queue_t queue = dispatch_queue_create("tk.bourne.testQueue", NULL);

dispatch_queue_t queue = dispatch_queue_create("tk.bourne.testQueue", DISPATCH_QUEUE_SERIAL);
自定义并发队列

dispatch_queue_t queue3 = dispatch_queue_create("tk.bourne.testQueue", DISPATCH_QUEUE_CONCURRENT);
参数说明

1、第一个参数是标识符，用于DEBUG的时候标识唯一的队列，可以为空。

2、第二个参数用来表示创建的队列是串行的还是并行的，传入DISPATCH_QUEUE_SERIAL或NULL表示创建串行队列。传入DISPATCH_QUEUE_CONCURRENT表示创建并发队列
1、dispatch_async 创建异步任务

dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT,0), ^{

//耗时的操作

NSURL* url = [NSURLURLWithString:kURL];

NSData* data = [[NSDataalloc]initWithContentsOfURL:url];

UIImage*image = [[UIImagealloc]initWithData:data];

if(image !=nil) {

//在主队列中更新UI

dispatch_async(dispatch_get_main_queue(), ^{

//更新界面

self.imageView.image= image;

});

}

});
2、dispatch_group_async队列组

可以实现监听一组任务是否完成，完成后得到通知执行其他的操作。这个方法很有用，比如你执行三个下载任务，当三个任务都下载完成后你才通知界面说完成的了

创建队列组

dispatch_group_tgroup = dispatch_group_create();
获取系统并发队列

dispatch_queue_tqueue =dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT,0);
// dispatch_group_async是异步的方法

dispatch_group_async(group, queue, ^{

[NSThreadsleepForTimeInterval:1];

NSLog(@"group1");

});
dispatch_group_async(group, queue, ^{

[NSThreadsleepForTimeInterval:3];

NSLog(@"group2");

});
队列组里所有的任务都执行完了，队列组会通知我们

dispatch_group_notify(group,dispatch_get_main_queue(), ^{

NSLog(@"updateUi");

});
dispatch_barrier_async的使用

1.是在前面的任务执行结束后它才执行，而且它后面的任务等它执行完成之后才会执行

2.这个方法会阻塞这个queue（注意是阻塞queue，而不是阻塞当前线程）
自定义一个并发队列

dispatch_queue_tqueue =dispatch_queue_create("tk.bourne.testQueue",DISPATCH_QUEUE_CONCURRENT);
dispatch_async(queue, ^{

[NSThreadsleepForTimeInterval:1];

NSLog(@"dispatch_async1");

});
dispatch_async(queue, ^{

[NSThreadsleepForTimeInterval:1];

NSLog(@"dispatch_async2");

});
等前面的任务执行完毕后才执行，后面的任务也要等这个任务完毕才能执行

dispatch_barrier_async(queue, ^{

NSLog(@"dispatch_barrier_async");

[NSThreadsleepForTimeInterval:4];

});
dispatch_async(queue, ^{

[NSThreadsleepForTimeInterval:1];

NSLog(@"dispatch_async3");

});
dispatch_apply执行某个代码片段N次

dispatch_apply(5, queue, ^(size_tindex) {

//执行5次

NSLog(@"dispatch_apply");

});
