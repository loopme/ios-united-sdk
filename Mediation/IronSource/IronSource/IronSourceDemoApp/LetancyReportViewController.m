//
//  LetancyReportViewController.m
//  IronSourceDemoApp
//
//  Created by Valerii Roman on 17/07/2024.
//

#import <Foundation/Foundation.h>
#import <IronSourceDemoApp-Swift.h>
#import "LetancyReportViewController.h"
#import "LatencyManagerSwizz.h"


@implementation LetancyReportViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor]; // Ensure the background is set to white
    
}

- (void)viewWillAppear:(BOOL)animated {
    NSDictionary<NSString *, TimeDifference *> *timeDifferences = [[LegacyManger shared] minMaxTimeDifferences];
    NSMutableAttributedString *latencyText = [[NSMutableAttributedString alloc] init];
    
    if (timeDifferences || ![timeDifferences  isEqual: @""]) {
        NSLog(@"%@", timeDifferences);
        for (NSString *key in timeDifferences) {
            TimeDifference *timeDifference = timeDifferences[key];
            NSAttributedString *boldLoadAd = [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"Load ad: %@\n", key]
                                                                             attributes:@{NSFontAttributeName: [UIFont boldSystemFontOfSize:[UIFont systemFontSize]]}];
            [latencyText appendAttributedString:boldLoadAd];
            NSAttributedString *minTimeDiff = [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"Min Time Difference: %@\n", timeDifference.min]
                                                                              attributes:@{NSFontAttributeName: [UIFont systemFontOfSize:[UIFont systemFontSize]]}];
            [latencyText appendAttributedString:minTimeDiff];
            
            NSAttributedString *maxTimeDiff = [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"Max Time Difference: %@\n\n", timeDifference.max]
                                                                              attributes:@{NSFontAttributeName: [UIFont systemFontOfSize:[UIFont systemFontSize]]}];
            [latencyText appendAttributedString:maxTimeDiff];
        }
    } else {
        NSAttributedString *noTimeDifferences = [[NSAttributedString alloc] initWithString:@"No time differences found.\n"
                                                                                attributes:@{NSFontAttributeName: [UIFont systemFontOfSize:[UIFont systemFontSize]]}];
        [latencyText appendAttributedString:noTimeDifferences];
    }
    _latencyText.attributedText = latencyText;
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [[LegacyManger shared] cleanLogDictionary];
    
}

- (IBAction)exportCSVReport:(UIButton *)sender {
    [self exportCSV];
}

- (void)exportCSV {
    NSString *csvString = [[LegacyManger shared] logDictionaryToCSV];
    
    NSString *filePath = [self createCSVFileWithContent: csvString];
    if (filePath) {
        NSURL *fileURL = [NSURL fileURLWithPath:filePath];
        [self presentShareSheetWithURL:fileURL];
    }
}

- (NSString *)createCSVFileWithContent:(NSString *)content {
    NSString *fileName = [NSString stringWithFormat:@"LogReport_%@.csv", [self getCurrentTimestamp]];
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *filePath = [documentsDirectory stringByAppendingPathComponent:fileName];
    
    NSError *error;
    BOOL success = [content writeToFile:filePath atomically:YES encoding:NSUTF8StringEncoding error:&error];
    if (success) {
        return filePath;
    } else {
        NSLog(@"Error creating CSV file: %@", error.localizedDescription);
        return nil;
    }
}

- (void)presentShareSheetWithURL:(NSURL *)fileURL {
    UIActivityViewController *activityVC = [[UIActivityViewController alloc] initWithActivityItems:@[fileURL] applicationActivities:nil];
    [self presentViewController:activityVC animated:YES completion:nil];
}

- (NSString *)getCurrentTimestamp {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = @"yyyy-MM-dd_HH-mm-ss";
    return [dateFormatter stringFromDate:[NSDate date]];
}

@end


