/*
GHTestMacros.h
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

#import <Foundation/Foundation.h>

#import "NSException+GHTestFailureExceptions.h"
#import "NSValue+GHValueFormatter.h"

// GTM_BEGIN

extern NSString *const GHTestFilenameKey;
extern NSString *const GHTestLineNumberKey;
extern NSString *const GHTestFailureException;

#if defined(__cplusplus) 
extern "C" 
#endif 

NSString *GHComposeString(NSString *, ...);


/*!
 Generates a failure when a1 != noErr

 @param a1 Should be either an OSErr or an OSStatus
 @param description A format string as in the printf() function. Can be nil or an empty string but must be present.
 @param ...: A variable number of arguments to the format string. Can be absent.
 */
#define GHAssertNoErr(a1, description, ...) \
do { \
@try {\
OSStatus a1value = (a1); \
if (a1value != noErr) { \
NSString *_expression = [NSString stringWithFormat:@"Expected noErr, got %ld for (%s)", a1value, #a1]; \
if (description) { \
_expression = [NSString stringWithFormat:@"%@: %@", _expression, GHComposeString(description, ##__VA_ARGS__)]; \
} \
[self failWithException:[NSException ghu_failureInFile:[NSString stringWithUTF8String:__FILE__] \
atLine:__LINE__ \
withDescription:_expression]]; \
} \
}\
@catch (id anException) {\
[self failWithException:[NSException ghu_failureInRaise:[NSString stringWithFormat:@"(%s) == noErr fails", #a1] \
exception:anException \
inFile:[NSString stringWithUTF8String:__FILE__] \
atLine:__LINE__ \
withDescription:GHComposeString(description, ##__VA_ARGS__)]]; \
}\
} while(0)

/*!
 Generates a failure when a1 != a2

 @param a1 Rreceived value. Should be either an OSErr or an OSStatus
 @param a2 Expected value. Should be either an OSErr or an OSStatus
 @param description A format string as in the printf() function. Can be nil or an empty string but must be present.
 @param ... A variable number of arguments to the format string. Can be absent.
 */
#define GHAssertErr(a1, a2, description, ...) \
do { \
@try {\
OSStatus a1value = (a1); \
OSStatus a2value = (a2); \
if (a1value != a2value) { \
NSString *_expression = [NSString stringWithFormat:@"Expected %s(%ld) but got %ld for (%s)", #a2, a2value, a1value, #a1]; \
if (description) { \
_expression = [NSString stringWithFormat:@"%@: %@", _expression, GHComposeString(description, ##__VA_ARGS__)]; \
} \
[self failWithException:[NSException ghu_failureInFile:[NSString stringWithUTF8String:__FILE__] \
atLine:__LINE__ \
withDescription:_expression]]; \
} \
}\
@catch (id anException) {\
[self failWithException:[NSException ghu_failureInRaise:[NSString stringWithFormat:@"(%s) == (%s) fails", #a1, #a2] \
exception:anException \
inFile:[NSString stringWithUTF8String:__FILE__] \
atLine:__LINE__ \
withDescription:GHComposeString(description, ##__VA_ARGS__)]]; \
}\
} while(0)


/*!
 Generates a failure when a1 is NULL

 @param a1 Should be a pointer (use GHAssertNotNil for an object)
 @param description A format string as in the printf() function. Can be nil or an empty string but must be present.
 @param ... A variable number of arguments to the format string. Can be absent.
 */
#define GHAssertNotNULL(a1, description, ...) \
do { \
@try {\
const void* a1value = (a1); \
if (a1value == NULL) { \
NSString *_expression = [NSString stringWithFormat:@"(%s) != NULL", #a1]; \
if (description) { \
_expression = [NSString stringWithFormat:@"%@: %@", _expression, GHComposeString(description, ##__VA_ARGS__)]; \
} \
[self failWithException:[NSException ghu_failureInFile:[NSString stringWithUTF8String:__FILE__] \
atLine:__LINE__ \
withDescription:_expression]]; \
} \
}\
@catch (id anException) {\
[self failWithException:[NSException ghu_failureInRaise:[NSString stringWithFormat:@"(%s) != NULL fails", #a1] \
exception:anException \
inFile:[NSString stringWithUTF8String:__FILE__] \
atLine:__LINE__ \
withDescription:GHComposeString(description, ##__VA_ARGS__)]]; \
}\
} while(0)

/*!
 Generates a failure when a1 is not NULL

 @param a1 should be a pointer (use GHAssertNil for an object)
 @param description A format string as in the printf() function. Can be nil or an empty string but must be present.
 @param ... A variable number of arguments to the format string. Can be absent.
 */
#define GHAssertNULL(a1, description, ...) \
do { \
@try {\
const void* a1value = (a1); \
if (a1value != NULL) { \
NSString *_expression = [NSString stringWithFormat:@"(%s) == NULL", #a1]; \
if (description) { \
_expression = [NSString stringWithFormat:@"%@: %@", _expression, GHComposeString(description, ##__VA_ARGS__)]; \
} \
[self failWithException:[NSException ghu_failureInFile:[NSString stringWithUTF8String:__FILE__] \
atLine:__LINE__ \
withDescription:_expression]]; \
} \
}\
@catch (id anException) {\
[self failWithException:[NSException ghu_failureInRaise:[NSString stringWithFormat:@"(%s) == NULL fails", #a1] \
exception:anException \
inFile:[NSString stringWithUTF8String:__FILE__] \
atLine:__LINE__ \
withDescription:GHComposeString(description, ##__VA_ARGS__)]]; \
}\
} while(0)

/*!
 Generates a failure when a1 is equal to a2. This test is for C scalars, structs and unions.

 @param a1 Argument 1
 @param a2 Argument 2
 @param description A format string as in the printf() function. Can be nil or an empty string but must be present.
 @param ... A variable number of arguments to the format string. Can be absent.
 */
#define GHAssertNotEquals(a1, a2, description, ...) \
do { \
@try {\
if (strcmp(@encode(__typeof__(a1)), @encode(__typeof__(a2))) != 0) { \
[self failWithException:[NSException ghu_failureInFile:[NSString stringWithUTF8String:__FILE__] \
atLine:__LINE__ \
withDescription:[@"Type mismatch -- " stringByAppendingString:GHComposeString(description, ##__VA_ARGS__)]]]; \
} else { \
__typeof__(a1) a1value = (a1); \
__typeof__(a2) a2value = (a2); \
NSValue *a1encoded = [NSValue value:&a1value withObjCType:@encode(__typeof__(a1))]; \
NSValue *a2encoded = [NSValue value:&a2value withObjCType:@encode(__typeof__(a2))]; \
if ([a1encoded isEqualToValue:a2encoded]) { \
NSString *_expression = [NSString stringWithFormat:@"(%s) != (%s)", #a1, #a2]; \
if (description) { \
_expression = [NSString stringWithFormat:@"%@: %@", _expression, GHComposeString(description, ##__VA_ARGS__)]; \
} \
[self failWithException:[NSException ghu_failureInFile:[NSString stringWithUTF8String:__FILE__] \
atLine:__LINE__ \
withDescription:_expression]]; \
} \
} \
} \
@catch (id anException) {\
[self failWithException:[NSException ghu_failureInRaise:[NSString stringWithFormat:@"(%s) != (%s)", #a1, #a2] \
exception:anException \
inFile:[NSString stringWithUTF8String:__FILE__] \
atLine:__LINE__ \
withDescription:GHComposeString(description, ##__VA_ARGS__)]]; \
}\
} while(0)

/*!
 Generates a failure when a1 is equal to a2. This test is for objects.

 @param a1 Argument 1. object.
 @param a2 Argument 2. object.
 @param description A format string as in the printf() function. Can be nil or an empty string but must be present.
 @param ... A variable number of arguments to the format string. Can be absent.
 */
#define GHAssertNotEqualObjects(a1, a2, desc, ...) \
do { \
@try {\
id a1value = (a1); \
id a2value = (a2); \
if ( (strcmp(@encode(__typeof__(a1value)), @encode(id)) == 0) && \
(strcmp(@encode(__typeof__(a2value)), @encode(id)) == 0) && \
![(id)a1value isEqual:(id)a2value] ) continue; \
NSString *_expression = [NSString stringWithFormat:@"%s('%@') != %s('%@')", #a1, [a1 description], #a2, [a2 description]]; \
if (desc) { \
_expression = [NSString stringWithFormat:@"%@: %@", _expression, GHComposeString(desc, ##__VA_ARGS__)]; \
} \
[self failWithException:[NSException ghu_failureInFile:[NSString stringWithUTF8String:__FILE__] \
atLine:__LINE__ \
withDescription:_expression]]; \
}\
@catch (id anException) {\
[self failWithException:[NSException ghu_failureInRaise:[NSString stringWithFormat: @"(%s) != (%s)", #a1, #a2] \
exception:anException \
inFile:[NSString stringWithUTF8String:__FILE__] \
atLine:__LINE__ \
withDescription:GHComposeString(desc, ##__VA_ARGS__)]]; \
}\
} while(0)

/*!
 Generates a failure when a1 is not 'op' to a2. This test is for C scalars. 

 @param a1 Argument 1
 @param a2 Argument 2
 @param op Operation
 @param description A format string as in the printf() function. Can be nil or an empty string but must be present.
 @param ... A variable number of arguments to the format string. Can be absent.
 */
#define GHAssertOperation(a1, a2, op, description, ...) \
do { \
@try {\
if (strcmp(@encode(__typeof__(a1)), @encode(__typeof__(a2))) != 0) { \
[self failWithException:[NSException ghu_failureInFile:[NSString stringWithUTF8String:__FILE__] \
atLine:__LINE__ \
withDescription:[@"Type mismatch -- " stringByAppendingString:GHComposeString(description, ##__VA_ARGS__)]]]; \
} else { \
__typeof__(a1) a1value = (a1); \
__typeof__(a2) a2value = (a2); \
if (!(a1value op a2value)) { \
double a1DoubleValue = a1value; \
double a2DoubleValue = a2value; \
NSString *_expression = [NSString stringWithFormat:@"%s (%lg) %s %s (%lg)", #a1, a1DoubleValue, #op, #a2, a2DoubleValue]; \
if (description) { \
_expression = [NSString stringWithFormat:@"%@: %@", _expression, GHComposeString(description, ##__VA_ARGS__)]; \
} \
[self failWithException:[NSException ghu_failureInFile:[NSString stringWithUTF8String:__FILE__] \
atLine:__LINE__ \
withDescription:_expression]]; \
} \
} \
} \
@catch (id anException) {\
[self failWithException:[NSException \
ghu_failureInRaise:[NSString stringWithFormat:@"(%s) %s (%s)", #a1, #op, #a2] \
exception:anException \
inFile:[NSString stringWithUTF8String:__FILE__] \
atLine:__LINE__ \
withDescription:GHComposeString(description, ##__VA_ARGS__)]]; \
}\
} while(0)

/*! 
 Generates a failure when a1 is not > a2. This test is for C scalars. 

 @param a1 argument 1
 @param a2 argument 2
 @param op operation
 @param description A format string as in the printf() function. Can be nil or an empty string but must be present.
 @param ... A variable number of arguments to the format string. Can be absent. 
 */
#define GHAssertGreaterThan(a1, a2, description, ...) \
GHAssertOperation(a1, a2, >, description, ##__VA_ARGS__)

/*! 
 Generates a failure when a1 is not >= a2. This test is for C scalars. 

 @param a1 argument 1
 @param a2 argument 2
 @param op operation
 @param description A format string as in the printf() function. Can be nil or an empty string but must be present.
 @param ... A variable number of arguments to the format string. Can be absent. 
 */
#define GHAssertGreaterThanOrEqual(a1, a2, description, ...) \
GHAssertOperation(a1, a2, >=, description, ##__VA_ARGS__)

/*! 
 Generates a failure when a1 is not < a2. This test is for C scalars. 

 @param a1 argument 1
 @param a2 argument 2
 @param op operation
 @param description A format string as in the printf() function. Can be nil or an empty string but must be present.
 @param ... A variable number of arguments to the format string. Can be absent.
 */
#define GHAssertLessThan(a1, a2, description, ...) \
GHAssertOperation(a1, a2, <, description, ##__VA_ARGS__)

/*! Generates a failure when a1 is not <= a2. This test is for C scalars. 

 @param a1 argument 1
 @param a2 argument 2
 @param op operation
 @param description A format string as in the printf() function. Can be nil or an empty string but must be present.
 @param ... A variable number of arguments to the format string. Can be absent.
 */
#define GHAssertLessThanOrEqual(a1, a2, description, ...) \
GHAssertOperation(a1, a2, <=, description, ##__VA_ARGS__)

/*! 
 Generates a failure when string a1 is not equal to string a2. This call
 differs from GHAssertEqualObjects in that strings that are different in
 composition (precomposed vs decomposed) will compare equal if their final
 representation is equal.
 ex O + umlaut decomposed is the same as O + umlaut composed.

 @param a1 string 1
 @param a2 string 2
 @param description A format string as in the printf() function. Can be nil or an empty string but must be present.
 @param ... A variable number of arguments to the format string. Can be absent.
 */
#define GHAssertEqualStrings(a1, a2, description, ...) \
do { \
@try {\
id a1value = (a1); \
id a2value = (a2); \
if (a1value == a2value) continue; \
if ([a1value isKindOfClass:[NSString class]] && \
[a2value isKindOfClass:[NSString class]] && \
[a1value compare:a2value options:0] == NSOrderedSame) continue; \
[self failWithException:[NSException ghu_failureInEqualityBetweenObject: a1value \
andObject: a2value \
inFile: [NSString stringWithUTF8String:__FILE__] \
atLine: __LINE__ \
withDescription: GHComposeString(description, ##__VA_ARGS__)]]; \
}\
@catch (id anException) {\
[self failWithException:[NSException ghu_failureInRaise:[NSString stringWithFormat: @"(%s) == (%s)", #a1, #a2] \
exception:anException \
inFile:[NSString stringWithUTF8String:__FILE__] \
atLine:__LINE__ \
withDescription:GHComposeString(description, ##__VA_ARGS__)]]; \
}\
} while(0)

/*! 
 Generates a failure when string a1 is equal to string a2. This call
 differs from GHAssertEqualObjects in that strings that are different in
 composition (precomposed vs decomposed) will compare equal if their final
 representation is equal.
 ex O + umlaut decomposed is the same as O + umlaut composed.

 @param a1 string 1
 @param a2 string 2
 @param description A format string as in the printf() function. Can be nil or an empty string but must be present.
 @param ... A variable number of arguments to the format string. Can be absent.
 */
#define GHAssertNotEqualStrings(a1, a2, description, ...) \
do { \
@try {\
id a1value = (a1); \
id a2value = (a2); \
if (([a1value isKindOfClass:[NSString class]] && \
[a2value isKindOfClass:[NSString class]] && \
[a1value compare:a2value options:0] != NSOrderedSame) || \
(a1value == nil && [a2value isKindOfClass:[NSString class]]) || \
(a2value == nil && [a1value isKindOfClass:[NSString class]]) \
) continue; \
[self failWithException:[NSException ghu_failureInInequalityBetweenObject: a1value \
andObject: a2value \
inFile: [NSString stringWithUTF8String:__FILE__] \
atLine: __LINE__ \
withDescription: GHComposeString(description, ##__VA_ARGS__)]]; \
}\
@catch (id anException) {\
[self failWithException:[NSException ghu_failureInRaise:[NSString stringWithFormat: @"(%s) != (%s)", #a1, #a2] \
exception:anException \
inFile:[NSString stringWithUTF8String:__FILE__] \
atLine:__LINE__ \
withDescription:GHComposeString(description, ##__VA_ARGS__)]]; \
}\
} while(0)

/*! 
 Generates a failure when c-string a1 is not equal to c-string a2.

 @param a1 string 1
 @param a2 string 2
 @param description A format string as in the printf() function. Can be nil or an empty string but must be present.
 @param ... A variable number of arguments to the format string. Can be absent.
 */
#define GHAssertEqualCStrings(a1, a2, description, ...) \
do { \
@try {\
const char* a1value = (a1); \
const char* a2value = (a2); \
if (a1value == a2value) continue; \
if (strcmp(a1value, a2value) == 0) continue; \
[self failWithException:[NSException ghu_failureInEqualityBetweenObject: [NSString stringWithUTF8String:a1value] \
andObject: [NSString stringWithUTF8String:a2value] \
inFile: [NSString stringWithUTF8String:__FILE__] \
atLine: __LINE__ \
withDescription: GHComposeString(description, ##__VA_ARGS__)]]; \
}\
@catch (id anException) {\
[self failWithException:[NSException ghu_failureInRaise:[NSString stringWithFormat: @"(%s) == (%s)", #a1, #a2] \
exception:anException \
inFile:[NSString stringWithUTF8String:__FILE__] \
atLine:__LINE__ \
withDescription:GHComposeString(description, ##__VA_ARGS__)]]; \
}\
} while(0)

/*! 
 Generates a failure when c-string a1 is equal to c-string a2.

 @param a1 string 1
 @param a2 string 2
 @param description A format string as in the printf() function. Can be nil or an empty string but must be present.
 @param ... A variable number of arguments to the format string. Can be absent.
 */
#define GHAssertNotEqualCStrings(a1, a2, description, ...) \
do { \
@try {\
const char* a1value = (a1); \
const char* a2value = (a2); \
if (strcmp(a1value, a2value) != 0) continue; \
[self failWithException:[NSException ghu_failureInEqualityBetweenObject: [NSString stringWithUTF8String:a1value] \
andObject: [NSString stringWithUTF8String:a2value] \
inFile: [NSString stringWithUTF8String:__FILE__] \
atLine: __LINE__ \
withDescription: GHComposeString(description, ##__VA_ARGS__)]]; \
}\
@catch (id anException) {\
[self failWithException:[NSException ghu_failureInRaise:[NSString stringWithFormat: @"(%s) != (%s)", #a1, #a2] \
exception:anException \
inFile:[NSString stringWithUTF8String:__FILE__] \
atLine:__LINE__ \
withDescription:GHComposeString(description, ##__VA_ARGS__)]]; \
}\
} while(0)

// GTM_END

// SENTE_BEGIN
/*! Generates a failure when !{ [a1 isEqualTo:a2] } is false 
 (or one is nil and the other is not). 

 @param a1    The object on the left
 @param a2    The object on the right
 @param description A format string as in the printf() function. Can be nil or an empty string but must be present
 @param ... A variable number of arguments to the format string. Can be absent
 */
#define GHAssertEqualObjects(a1, a2, description, ...) \
do { \
@try {\
id a1value = (a1); \
id a2value = (a2); \
if (a1value == a2value) continue; \
if ( (strcmp(@encode(__typeof__(a1value)), @encode(id)) == 0) && \
(strcmp(@encode(__typeof__(a2value)), @encode(id)) == 0) && \
[(id)a1value isEqual: (id)a2value] ) continue; \
[self failWithException:[NSException ghu_failureInEqualityBetweenObject: a1value \
andObject: a2value \
inFile: [NSString stringWithUTF8String:__FILE__] \
atLine: __LINE__ \
withDescription: GHComposeString(description, ##__VA_ARGS__)]]; \
}\
@catch (id anException) {\
[self failWithException:[NSException ghu_failureInRaise:[NSString stringWithFormat: @"(%s) == (%s)", #a1, #a2] \
exception:anException \
inFile:[NSString stringWithUTF8String:__FILE__] \
atLine:__LINE__ \
withDescription:GHComposeString(description, ##__VA_ARGS__)]]; \
}\
} while(0)


/*! Generates a failure when a1 is not equal to a2. This test is for
 C scalars, structs and unions.

 @param a1    The argument on the left
 @param a2    The argument on the right
 @param description A format string as in the printf() function. Can be nil or an empty string but must be present
 @param ... A variable number of arguments to the format string. Can be absent
 */
#define GHAssertEquals(a1, a2, description, ...) \
do { \
@try {\
if ( strcmp(@encode(__typeof__(a1)), @encode(__typeof__(a2))) != 0 ) { \
[self failWithException:[NSException ghu_failureInFile:[NSString stringWithUTF8String:__FILE__] \
atLine:__LINE__ \
withDescription:[@"Type mismatch -- " stringByAppendingString:GHComposeString(description, ##__VA_ARGS__)]]]; \
} else { \
__typeof__(a1) a1value = (a1); \
__typeof__(a2) a2value = (a2); \
NSValue *a1encoded = [NSValue value:&a1value withObjCType: @encode(__typeof__(a1))]; \
NSValue *a2encoded = [NSValue value:&a2value withObjCType: @encode(__typeof__(a2))]; \
if (![a1encoded isEqualToValue:a2encoded]) { \
[self failWithException:[NSException ghu_failureInEqualityBetweenValue: a1encoded \
andValue: a2encoded \
withAccuracy: nil \
inFile: [NSString stringWithUTF8String:__FILE__] \
atLine: __LINE__ \
withDescription: GHComposeString(description, ##__VA_ARGS__)]]; \
} \
} \
} \
@catch (id anException) {\
[self failWithException:[NSException ghu_failureInRaise:[NSString stringWithFormat: @"(%s) == (%s)", #a1, #a2] \
exception:anException \
inFile:[NSString stringWithUTF8String:__FILE__] \
atLine:__LINE__ \
withDescription:GHComposeString(description, ##__VA_ARGS__)]]; \
}\
} while(0)

//! Absolute difference
#define GHAbsoluteDifference(left,right) (MAX(left,right)-MIN(left,right))


/*! 
 Generates a failure when a1 is not equal to a2 within + or - accuracy is false. 
 This test is for scalars such as floats and doubles where small differences 
 could make these items not exactly equal, but also works for all scalars.

 @param a1    The scalar on the left
 @param a2    The scalar on the right
 @param accuracy  The maximum difference between a1 and a2 for these values to be considered equal
 @param description A format string as in the printf() function. Can be nil or an empty string but must be present
 @param ... A variable number of arguments to the format string. Can be absent
 */
#define GHAssertEqualsWithAccuracy(a1, a2, accuracy, description, ...) \
do { \
@try {\
if (strcmp(@encode(__typeof__(a1)), @encode(__typeof__(a2))) != 0) { \
[self failWithException:[NSException ghu_failureInFile:[NSString stringWithUTF8String:__FILE__] \
atLine:__LINE__ \
withDescription:[@"Type mismatch -- " stringByAppendingString:GHComposeString(description, ##__VA_ARGS__)]]]; \
} else { \
__typeof__(a1) a1value = (a1); \
__typeof__(a2) a2value = (a2); \
__typeof__(accuracy) accuracyvalue = (accuracy); \
if (GHAbsoluteDifference(a1value, a2value) > accuracyvalue) { \
NSValue *a1encoded = [NSValue value:&a1value withObjCType:@encode(__typeof__(a1))]; \
NSValue *a2encoded = [NSValue value:&a2value withObjCType:@encode(__typeof__(a2))]; \
NSValue *accuracyencoded = [NSValue value:&accuracyvalue withObjCType:@encode(__typeof__(accuracy))]; \
[self failWithException:[NSException ghu_failureInEqualityBetweenValue: a1encoded \
andValue: a2encoded \
withAccuracy: accuracyencoded \
inFile: [NSString stringWithUTF8String:__FILE__] \
atLine: __LINE__ \
withDescription: GHComposeString(description, ##__VA_ARGS__)]]; \
} \
} \
} \
@catch (id anException) {\
[self failWithException:[NSException ghu_failureInRaise:[NSString stringWithFormat: @"(%s) == (%s)", #a1, #a2] \
exception:anException \
inFile:[NSString stringWithUTF8String:__FILE__] \
atLine:__LINE__ \
withDescription:GHComposeString(description, ##__VA_ARGS__)]]; \
}\
} while(0)



/*! 
 Generates a failure unconditionally. 

 @param description A format string as in the printf() function. Can be nil or an empty string but must be present
 @param ... A variable number of arguments to the format string. Can be absent
 */
#define GHFail(description, ...) \
[self failWithException:[NSException ghu_failureInFile: [NSString stringWithUTF8String:__FILE__] \
atLine: __LINE__ \
withDescription: GHComposeString(description, ##__VA_ARGS__)]]



/*! 
 Generates a failure when a1 is not nil.

 @param a1    An object
 @param description A format string as in the printf() function. Can be nil or an empty string but must be present
 @param ... A variable number of arguments to the format string. Can be absent
 */
#define GHAssertNil(a1, description, ...) \
do { \
@try {\
id a1value = (a1); \
if (a1value != nil) { \
NSString *_a1 = [NSString stringWithUTF8String: #a1]; \
NSString *_expression = [NSString stringWithFormat:@"((%@) == nil)", _a1]; \
[self failWithException:[NSException ghu_failureInCondition: _expression \
isTrue: NO \
inFile: [NSString stringWithUTF8String:__FILE__] \
atLine: __LINE__ \
withDescription: GHComposeString(description, ##__VA_ARGS__)]]; \
} \
}\
@catch (id anException) {\
[self failWithException:[NSException ghu_failureInRaise:[NSString stringWithFormat: @"(%s) == nil fails", #a1] \
exception:anException \
inFile:[NSString stringWithUTF8String:__FILE__] \
atLine:__LINE__ \
withDescription:GHComposeString(description, ##__VA_ARGS__)]]; \
}\
} while(0)


/*! 
 Generates a failure when a1 is nil.

 @param a1    An object
 @param description A format string as in the printf() function. Can be nil or an empty string but must be present
 @param ... A variable number of arguments to the format string. Can be absent
 */
#define GHAssertNotNil(a1, description, ...) \
do { \
@try {\
id a1value = (a1); \
if (a1value == nil) { \
NSString *_a1 = [NSString stringWithUTF8String: #a1]; \
NSString *_expression = [NSString stringWithFormat:@"((%@) != nil)", _a1]; \
[self failWithException:[NSException ghu_failureInCondition: _expression \
isTrue: NO \
inFile: [NSString stringWithUTF8String:__FILE__] \
atLine: __LINE__ \
withDescription: GHComposeString(description, ##__VA_ARGS__)]]; \
} \
}\
@catch (id anException) {\
[self failWithException:[NSException ghu_failureInRaise:[NSString stringWithFormat: @"(%s) != nil fails", #a1] \
exception:anException \
inFile:[NSString stringWithUTF8String:__FILE__] \
atLine:__LINE__ \
withDescription:GHComposeString(description, ##__VA_ARGS__)]]; \
}\
} while(0)


/*! 
 Generates a failure when expression evaluates to false. 

 @param expr    The expression that is tested
 @param description A format string as in the printf() function. Can be nil or an empty string but must be present
 @param ... A variable number of arguments to the format string. Can be absent
 */
#define GHAssertTrue(expr, description, ...) \
do { \
BOOL _evaluatedExpression = (expr);\
if (!_evaluatedExpression) {\
NSString *_expression = [NSString stringWithUTF8String: #expr];\
[self failWithException:[NSException ghu_failureInCondition: _expression \
isTrue: YES \
inFile: [NSString stringWithUTF8String:__FILE__] \
atLine: __LINE__ \
withDescription: GHComposeString(description, ##__VA_ARGS__)]]; \
} \
} while (0)


/*! 
 Generates a failure when expression evaluates to false and in addition will 
 generate error messages if an exception is encountered. 
 
 @param expr    The expression that is tested
 @param description A format string as in the printf() function. Can be nil or an empty string but must be present
 @param ... A variable number of arguments to the format string. Can be absent
 */
#define GHAssertTrueNoThrow(expr, description, ...) \
do { \
@try {\
BOOL _evaluatedExpression = (expr);\
if (!_evaluatedExpression) {\
NSString *_expression = [NSString stringWithUTF8String: #expr];\
[self failWithException:[NSException ghu_failureInCondition: _expression \
isTrue: NO \
inFile: [NSString stringWithUTF8String:__FILE__] \
atLine: __LINE__ \
withDescription: GHComposeString(description, ##__VA_ARGS__)]]; \
} \
} \
@catch (id anException) {\
[self failWithException:[NSException ghu_failureInRaise:[NSString stringWithFormat: @"(%s) ", #expr] \
exception:anException \
inFile:[NSString stringWithUTF8String:__FILE__] \
atLine:__LINE__ \
withDescription:GHComposeString(description, ##__VA_ARGS__)]]; \
}\
} while (0)


/*! 
 Generates a failure when the expression evaluates to true. 

 @param expr    The expression that is tested
 @param description A format string as in the printf() function. Can be nil or an empty string but must be present
 @param ... A variable number of arguments to the format string. Can be absent
 */
#define GHAssertFalse(expr, description, ...) \
do { \
BOOL _evaluatedExpression = (expr);\
if (_evaluatedExpression) {\
NSString *_expression = [NSString stringWithUTF8String: #expr];\
[self failWithException:[NSException ghu_failureInCondition: _expression \
isTrue: NO \
inFile: [NSString stringWithUTF8String:__FILE__] \
atLine: __LINE__ \
withDescription: GHComposeString(description, ##__VA_ARGS__)]]; \
} \
} while (0)


/*! 
 Generates a failure when the expression evaluates to true and in addition 
 will generate error messages if an exception is encountered.
 
 @param expr    The expression that is tested
 @param description A format string as in the printf() function. Can be nil or an empty string but must be present
 @param ... A variable number of arguments to the format string. Can be absent
 */
#define GHAssertFalseNoThrow(expr, description, ...) \
do { \
@try {\
BOOL _evaluatedExpression = (expr);\
if (_evaluatedExpression) {\
NSString *_expression = [NSString stringWithUTF8String: #expr];\
[self failWithException:[NSException ghu_failureInCondition: _expression \
isTrue: YES \
inFile: [NSString stringWithUTF8String:__FILE__] \
atLine: __LINE__ \
withDescription: GHComposeString(description, ##__VA_ARGS__)]]; \
} \
} \
@catch (id anException) {\
[self failWithException:[NSException ghu_failureInRaise:[NSString stringWithFormat: @"!(%s) ", #expr] \
exception:anException \
inFile:[NSString stringWithUTF8String:__FILE__] \
atLine:__LINE__ \
withDescription:GHComposeString(description, ##__VA_ARGS__)]]; \
}\
} while (0)


/*! 
 Generates a failure when expression does not throw an exception. 

 @param expression    The expression that is evaluated
 @param description A format string as in the printf() function. Can be nil or an empty string but must be present
 @param ... A variable number of arguments to the format string. Can be absent.
 */
#define GHAssertThrows(expr, description, ...) \
do { \
@try { \
(expr);\
} \
@catch (id anException) { \
continue; \
}\
[self failWithException:[NSException ghu_failureInRaise: [NSString stringWithUTF8String:#expr] \
exception: nil \
inFile: [NSString stringWithUTF8String:__FILE__] \
atLine: __LINE__ \
withDescription: GHComposeString(description, ##__VA_ARGS__)]]; \
} while (0)


/*! 
 Generates a failure when expression does not throw an exception of a 
 specific class. 

 @param expression    The expression that is evaluated
 @param specificException    The specified class of the exception
 @param description A format string as in the printf() function. Can be nil or an empty string but must be present
 @param ... A variable number of arguments to the format string. Can be absent
 */
#define GHAssertThrowsSpecific(expr, specificException, description, ...) \
do { \
@try { \
(expr);\
} \
@catch (specificException *anException) { \
continue; \
}\
@catch (id anException) {\
NSString *_descrip = GHComposeString(@"(Expected exception: %@) %@", NSStringFromClass([specificException class]), description);\
[self failWithException:[NSException ghu_failureInRaise: [NSString stringWithUTF8String:#expr] \
exception: anException \
inFile: [NSString stringWithUTF8String:__FILE__] \
atLine: __LINE__ \
withDescription: GHComposeString(_descrip, ##__VA_ARGS__)]]; \
continue; \
}\
NSString *_descrip = GHComposeString(@"(Expected exception: %@) %@", NSStringFromClass([specificException class]), description);\
[self failWithException:[NSException ghu_failureInRaise: [NSString stringWithUTF8String:#expr] \
exception: nil \
inFile: [NSString stringWithUTF8String:__FILE__] \
atLine: __LINE__ \
withDescription: GHComposeString(_descrip, ##__VA_ARGS__)]]; \
} while (0)


/*! Generates a failure when expression does not throw an exception of a 
 specific class with a specific name.  Useful for those frameworks like
 AppKit or Foundation that throw generic NSException w/specific names 
 (NSInvalidArgumentException, etc).

 @param expression    The expression that is evaluated
 @param specificException    The specified class of the exception
 @param aName    The name of the specified exception
 @param description A format string as in the printf() function. Can be nil or an empty string but must be present
 @param ... A variable number of arguments to the format string. Can be absent
 */
#define GHAssertThrowsSpecificNamed(expr, specificException, aName, description, ...) \
do { \
@try { \
(expr);\
} \
@catch (specificException *anException) { \
if ([aName isEqualToString: [anException name]]) continue; \
NSString *_descrip = GHComposeString(@"(Expected exception: %@ (name: %@)) %@", NSStringFromClass([specificException class]), aName, description);\
[self failWithException: \
[NSException ghu_failureInRaise: [NSString stringWithUTF8String:#expr] \
exception: anException \
inFile: [NSString stringWithUTF8String:__FILE__] \
atLine: __LINE__ \
withDescription: GHComposeString(_descrip, ##__VA_ARGS__)]]; \
continue; \
}\
@catch (id anException) {\
NSString *_descrip = GHComposeString(@"(Expected exception: %@) %@", NSStringFromClass([specificException class]), description);\
[self failWithException: \
[NSException ghu_failureInRaise: [NSString stringWithUTF8String:#expr] \
exception: anException \
inFile: [NSString stringWithUTF8String:__FILE__] \
atLine: __LINE__ \
withDescription: GHComposeString(_descrip, ##__VA_ARGS__)]]; \
continue; \
}\
NSString *_descrip = GHComposeString(@"(Expected exception: %@) %@", NSStringFromClass([specificException class]), description);\
[self failWithException: \
[NSException ghu_failureInRaise: [NSString stringWithUTF8String:#expr] \
exception: nil \
inFile: [NSString stringWithUTF8String:__FILE__] \
atLine: __LINE__ \
withDescription: GHComposeString(_descrip, ##__VA_ARGS__)]]; \
} while (0)


/*! 
 Generates a failure when expression does throw an exception. 

 @param expression    The expression that is evaluated
 @param description A format string as in the printf() function. Can be nil or an empty string but must be present
 @param ... A variable number of arguments to the format string. Can be absent
 */
#define GHAssertNoThrow(expr, description, ...) \
do { \
@try { \
(expr);\
} \
@catch (id anException) { \
[self failWithException:[NSException ghu_failureInRaise: [NSString stringWithUTF8String:#expr] \
exception: anException \
inFile: [NSString stringWithUTF8String:__FILE__] \
atLine: __LINE__ \
withDescription: GHComposeString(description, ##__VA_ARGS__)]]; \
}\
} while (0)


/*! 
 Generates a failure when expression does throw an exception of the specitied
 class. Any other exception is okay (i.e. does not generate a failure).

 @param expression    The expression that is evaluated
 @param specificException    The specified class of the exception
 @param description A format string as in the printf() function. Can be nil or an empty string but must be present
 @param ... A variable number of arguments to the format string. Can be absent
 */
#define GHAssertNoThrowSpecific(expr, specificException, description, ...) \
do { \
@try { \
(expr);\
} \
@catch (specificException *anException) { \
[self failWithException:[NSException ghu_failureInRaise: [NSString stringWithUTF8String:#expr] \
exception: anException \
inFile: [NSString stringWithUTF8String:__FILE__] \
atLine: __LINE__ \
withDescription: GHComposeString(description, ##__VA_ARGS__)]]; \
}\
@catch (id anythingElse) {\
; \
}\
} while (0)


/*! 
 Generates a failure when expression does throw an exception of a 
 specific class with a specific name.  Useful for those frameworks like
 AppKit or Foundation that throw generic NSException w/specific names 
 (NSInvalidArgumentException, etc).

 @param expression The expression that is evaluated.
 @param specificException    The specified class of the exception
 @param aName    The name of the specified exception
 @param description A format string as in the printf() function. Can be nil or an empty string but must be present
 @param ... A variable number of arguments to the format string. Can be absent
 */
#define GHAssertNoThrowSpecificNamed(expr, specificException, aName, description, ...) \
do { \
@try { \
(expr);\
} \
@catch (specificException *anException) { \
if ([aName isEqualToString: [anException name]]) { \
NSString *_descrip = GHComposeString(@"(Expected exception: %@ (name: %@)) %@", NSStringFromClass([specificException class]), aName, description);\
[self failWithException: \
[NSException ghu_failureInRaise: [NSString stringWithUTF8String:#expr] \
exception: anException \
inFile: [NSString stringWithUTF8String:__FILE__] \
atLine: __LINE__ \
withDescription: GHComposeString(_descrip, ##__VA_ARGS__)]]; \
} \
continue; \
}\
@catch (id anythingElse) {\
; \
}\
} while (0)


@interface NSException(GHTestMacros_GTMSenTestAdditions)
+ (NSException *)ghu_failureInFile:(NSString *)filename 
                        atLine:(int)lineNumber 
               withDescription:(NSString *)formatString, ...;
+ (NSException *)ghu_failureInCondition:(NSString *)condition 
                             isTrue:(BOOL)isTrue 
                             inFile:(NSString *)filename 
                             atLine:(int)lineNumber 
                    withDescription:(NSString *)formatString, ...;
+ (NSException *)ghu_failureInEqualityBetweenObject:(id)left
                                      andObject:(id)right
                                         inFile:(NSString *)filename
                                         atLine:(int)lineNumber
                                withDescription:(NSString *)formatString, ...;
+ (NSException *)ghu_failureInInequalityBetweenObject:(id)left
                                            andObject:(id)right
                                               inFile:(NSString *)filename
                                               atLine:(int)lineNumber
                                      withDescription:(NSString *)formatString, ...;
+ (NSException *)ghu_failureInEqualityBetweenValue:(NSValue *)left 
                                      andValue:(NSValue *)right 
                                  withAccuracy:(NSValue *)accuracy 
                                        inFile:(NSString *)filename 
                                        atLine:(int) ineNumber
                               withDescription:(NSString *)formatString, ...;
+ (NSException *)ghu_failureInRaise:(NSString *)expression 
                         inFile:(NSString *)filename 
                         atLine:(int)lineNumber
                withDescription:(NSString *)formatString, ...;
+ (NSException *)ghu_failureInRaise:(NSString *)expression 
                      exception:(NSException *)exception 
                         inFile:(NSString *)filename 
                         atLine:(int)lineNumber 
                withDescription:(NSString *)formatString, ...;
+ (NSException *)ghu_failureWithName:(NSString *)name
                              inFile:(NSString *)filename
                              atLine:(int)lineNumber
                              reason:(NSString *)reason;
@end

// SENTE_END
