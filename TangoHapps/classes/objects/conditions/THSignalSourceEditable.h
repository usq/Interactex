//
//  THSignalSourceEditable.h
//  TangoHapps
//
//  Created by Michael Conrads on 28/02/14.
//  Copyright (c) 2014 Technische Universität München. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "THProgrammingElementEditable.h"
#import "THSignalSource.h"
@interface THSignalSourceEditable : THProgrammingElementEditable
@property (nonatomic, assign, readwrite) Signal currentOutputValue;
@property (nonatomic, assign, readwrite) float leftBorderPercentage;
@property (nonatomic, assign, readwrite) float rightBorderPercentage;
@property (nonatomic, assign, readonly) BOOL recording;
@property (nonatomic, strong, readonly) NSArray *recordedData;

+ (instancetype)sharedSignalSourceEditable;
- (void)switchSourceFile:(NSString *)filename;
- (void)recordeNewGesture;
- (void)stopRecording;
- (void)saveRecording;
@end
