//
//  ViewController.h
//  sockets
//
//  Created by Syritx on 2021-01-20.
//

#import <UIKit/UIKit.h>

@interface ViewController : UIViewController<NSStreamDelegate>
    
{
    CFReadStreamRef readStream;
    CFWriteStreamRef writeStream;
    
    NSInputStream *inputStream;
    NSOutputStream *outputStream;
    
    UILabel *temperatureLabel;
    UILabel *humidityLabel;
    
    NSString *HOST;
}
    
@end

