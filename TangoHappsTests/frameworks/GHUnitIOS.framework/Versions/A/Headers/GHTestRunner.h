/*
GHTestRunner.h
Interactex Designer

Created by Juan Haladjian on 31/05/2012.

Interactex Designer is a configuration tool to easily setup, simulate and connect e-Textile hardware with smartphone functionality. Interactex Client is an app to store and replay projects made with Interactex Designer.

www.interactex.org

Copyright (C) 2013 TU Munich, Munich, Germany; DRLab, University of the Arts Berlin, Berlin, Germany; Telekom Innovation Laboratories, Berlin, Germany
	
Contacts:
juan.haladjian@cs.tum.edu
katharina.bredies@udk-berlin.de
opensource@telekom.de

    
The first version of the software was designed and implemented as part of "Wearable M2M", a joint project of UdK Berlin and TU Munich, which was founded by Telekom Innovation Laboratories Berlin. It has been extended with funding from EIT ICT, as part of the activity "Connected Textiles".

Interactex is built using the Tango framework developed by TU Munich.

In the Interactex software, we use the GHUnit (a test framework for iOS developed by Gabriel Handford) and cocos2D libraries (a framework for building 2D games and graphical applications developed by Zynga Inc.). 
www.cocos2d-iphone.org
github.com/gabriel/gh-unit

Interactex also implements the Firmata protocol. Its software serial library is based on the original Arduino Firmata library.
www.firmata.org

All hardware part graphics in Interactex Designer are reproduced with kind permission from Fritzing. Fritzing is an open-source hardware initiative to support designers, artists, researchers and hobbyists to work creatively with interactive electronics.
www.frizting.org

Martijn ten Bhömer from TU Eindhoven contributed PureData support. Contact: m.t.bhomer@tue.nl.

This program is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.
 
This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more details.
 
You should have received a copy of the GNU General Public License along with this program.  If not, see <http://www.gnu.org/licenses/>.

*/

#import "GHTestGroup.h"
#import "GHTestSuite.h"

@class GHTestRunner;

/*!
 Notifies about the test run.
 Delegates can be guaranteed to be notified on the main thread.
 */
@protocol GHTestRunnerDelegate <NSObject>
@optional

/*!
 Test run started.
 @param runner Runner
 */
- (void)testRunnerDidStart:(GHTestRunner *)runner;

/*!
 Test run did start test.
 @param runner Runner
 @param test Test
 */
- (void)testRunner:(GHTestRunner *)runner didStartTest:(id<GHTest>)test;

/*!
 Test run did update test.
 @param runner Runner
 @param test Test
 */
- (void)testRunner:(GHTestRunner *)runner didUpdateTest:(id<GHTest>)test;

/*!
 Test run did end test.
 @param runner Runner
 @param test Test
 */
- (void)testRunner:(GHTestRunner *)runner didEndTest:(id<GHTest>)test;

/*!
 Test run did cancel.
 @param runner Runner
 */
- (void)testRunnerDidCancel:(GHTestRunner *)runner;

/*!
 Test run did end.
 @param runner Runner
 */
- (void)testRunnerDidEnd:(GHTestRunner *)runner;

/*!
 Test run did log message.
 @param runner Runner
 @param didLog Message
 */
- (void)testRunner:(GHTestRunner *)runner didLog:(NSString *)didLog;

/*!
 Test run test did log message.
 @param runner Runner
 @param test Test
 @param didLog Message
 */
- (void)testRunner:(GHTestRunner *)runner test:(id<GHTest>)test didLog:(NSString *)didLog;

@end

/*!
 Runs the tests.
 Tests are run a separate thread though delegates are called on the main thread by default.
 
 For example,
 
    GHTestRunner *runner = [[GHTestRunner alloc] initWithTest:suite];
    runner.delegate = self;
    [runner runTests];
 
 */
@interface GHTestRunner : NSObject <GHTestDelegate> { 
  
  id<GHTest> test_; // The test to run; Could be a GHTestGroup (suite), GHTestGroup (test case), or GHTest (target/selector)
  
  NSObject<GHTestRunnerDelegate> *__unsafe_unretained delegate_; // weak
    
  GHTestOptions options_; 
  
  BOOL running_;
  BOOL cancelling_;
  
  NSTimeInterval startInterval_;
  
  NSOperationQueue *operationQueue_; //! If running a suite in operation queue
}

@property  (strong) id<GHTest> test;
@property (unsafe_unretained) NSObject<GHTestRunnerDelegate> *delegate;
@property (assign) GHTestOptions options;
@property (readonly) GHTestStats stats;
@property (readonly, getter=isRunning) BOOL running;
@property (readonly, getter=isCancelling) BOOL cancelling;
@property (readonly) NSTimeInterval interval;
@property (strong, nonatomic) NSOperationQueue *operationQueue;
@property (assign, nonatomic, getter=isInParallel) BOOL inParallel;

/*!
 Create runner for test.
 @param test Test
 */
- (id)initWithTest:(id<GHTest>)test;

/*!
 Create runner for all tests.
 @see [GHTesting loadAllTestCases].
 @result Runner
 */
+ (GHTestRunner *)runnerForAllTests;

/*!
 Create runner for test suite.
 @param suite Suite
 @result Runner
 */
+ (GHTestRunner *)runnerForSuite:(GHTestSuite *)suite;

/*!
 Create runner for class and method.
 @param testClassName Test class name
 @param methodName Test method
 @result Runner
 */
+ (GHTestRunner *)runnerForTestClassName:(NSString *)testClassName methodName:(NSString *)methodName;

/*!
 Get the runner from the environment.
 If the TEST env is set, then we will only run that test case or test method.
 */
+ (GHTestRunner *)runnerFromEnv;

/*!
 Run the test runner. Usually called from the test main.
 Reads the TEST environment variable and filters on that; or all tests are run.
 @result 0 is success, otherwise the failure count
 */
+ (int)run;

/*!
 Run in the background.
 */
- (void)runInBackground;

/*!
 Start the test runner.
 @result 0 is success, otherwise the failure count
 */
- (int)runTests;

/*!
 Cancel test run.
 */
- (void)cancel;

/*!
 Write message to console.
 @param message Message to log
 */
- (void)log:(NSString *)message;

@end

//! @endcond

