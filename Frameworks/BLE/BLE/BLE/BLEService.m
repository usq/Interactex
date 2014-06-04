/*
 BLEService.h
 BLE
 
 Created by Juan Haladjian on 11/06/2013.
 
 BLE is a library used to send and receive data from/to a device over Bluetooth 4.0.
 
 www.interactex.org
 
 Copyright (C) 2013 TU Munich, Munich, Germany; DRLab, University of the Arts Berlin, Berlin, Germany; Telekom Innovation Laboratories, Berlin, Germany
 
 Contacts:
 juan.haladjian@cs.tum.edu
 katharina.bredies@udk-berlin.de
 opensource@telekom.de
 
 
 It has been created with funding from EIT ICT, as part of the activity "Connected Textiles".
 
 
 This program is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.
 
 This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more details.
 
 You should have received a copy of the GNU General Public License along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

#import "BLEService.h"
#import "BLEDiscovery.h"
#import "BLEHelper.h"
#import <QuartzCore/QuartzCore.h>

uint8_t const kBleCrcStart = 170;

/*
NSString * const kBleSupportedServices[kBleNumSupportedServices] = {@"F9266FD7-EF07-45D6-8EB6-BD74F13620F9"};

NSString * const kBleCharacteristics[kBleNumSupportedServices][2] = {
    {@"4585C102-7784-40B4-88E1-3CB5C4FD37A3",@"E788D73B-E793-4D9E-A608-2F2BAFC59A00"}};
 */

NSString * const kBleSupportedServices[kBleNumSupportedServices] = {@"F9266FD7-EF07-45D6-8EB6-BD74F13620F9",@"ffe0",@"713D0000-503E-4C75-BA94-3148F18D941E"};//Dr. Kroll Shield, Jennic Module, RedBearLab Shield

NSString * const kBleCharacteristics[kBleNumSupportedServices][2] = {
    {@"4585C102-7784-40B4-88E1-3CB5C4FD37A3",@"E788D73B-E793-4D9E-A608-2F2BAFC59A00"},
    {@"ffe1",@"ffe1"},
    {@"713D0002-503E-4C75-BA94-3148F18D941E",@"713d0003-503e-4C75-BA94-3148F18D941E"}};//RX; TX


const NSTimeInterval kFlushInterval = 1.0f/10.0f;
const NSTimeInterval kBleSendOverCommandInterval = 1.0f/10.0f;

@implementation BLEService

static NSMutableArray * supportedServiceUUIDs;
static NSMutableArray * supportedCharacteristicUUIDs;

#pragma mark Static Methods

+(NSMutableArray*) supportedServiceUUIDs{
    return supportedServiceUUIDs;
}

+(NSMutableArray*) supportedCharacteristicUUIDs{
    return supportedCharacteristicUUIDs;
}

#pragma mark Init

- (id) initWithPeripheral:(CBPeripheral *)peripheral {
    self = [super init];
    if (self) {
        _peripheral = peripheral;
        [self.peripheral setDelegate:self];
        
        supportedServiceUUIDs =  [NSMutableArray array];
        supportedCharacteristicUUIDs = [NSMutableArray array];
        
        for (int i = 0; i < kBleNumSupportedServices; i++) {
            CBUUID * rxCharacteristic = [CBUUID UUIDWithString:kBleCharacteristics[i][0]];
            CBUUID * txCharacteristic = [CBUUID UUIDWithString:kBleCharacteristics[i][1]];
            NSArray * characteristics = [NSArray arrayWithObjects:rxCharacteristic,txCharacteristic, nil];
            [supportedCharacteristicUUIDs addObject:characteristics];
            
            CBUUID * service = [CBUUID UUIDWithString:kBleSupportedServices[i]];
            [supportedServiceUUIDs addObject:service];
        }
	}
    return self;
}


- (void) dealloc {
	if (self.peripheral) {
		[self.peripheral setDelegate:[BLEDiscovery sharedInstance]];
		_peripheral = nil;
    }
}

-(CBUUID*) uuid{
    return bleService.UUID;
}

#pragma mark Service interaction

- (void) start {
    
    sendBufferCount = 0;
    sendBufferStart = 0;
    shouldSend = YES;
    
    [_peripheral discoverServices:supportedServiceUUIDs];
    
}

- (void) stop {
    
    [timer invalidate];
    timer = nil;
    
	if (self.peripheral) {
		_peripheral = nil;
	}
}

- (void) peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error {
	NSArray		*services	= nil;
	//NSArray		*uuids	= [NSArray arrayWithObjects:rxUUID,   rxCountUUID,   rxClearUUID, txUUID, nil];

	if (peripheral != _peripheral) {
        [self.delegate reportMessage:@"Wrong Peripheral"];
		return ;
	}
    
    if (error != nil) {
        //NSString * message = [NSString stringWithFormat:@"Error: %@",error];
        //[self.delegate reportMessage:message];
		return ;
	}

	services = [peripheral services];
	if (!services || ![services count]) {
		return ;
	}

	bleService = nil;
    
	for (CBService *service in services) {
        
        NSLog(@"service found is: %@", [BLEHelper UUIDToString:service.UUID]);
        
        for (int i = 0; i < supportedServiceUUIDs.count; i++) {
            CBUUID * serviceUUID = [supportedServiceUUIDs objectAtIndex:i];
            
            if([service.UUID isEqual:serviceUUID]){
                
                NSLog(@"service connected is: %@", [BLEHelper UUIDToString:service.UUID]);
                self.deviceType = i;
                
                self.currentCharacteristicUUIDs = [supportedCharacteristicUUIDs objectAtIndex:i];
                bleService = service;
                break;
            }
        }
	}

	if (bleService) {
        [peripheral discoverCharacteristics:nil forService:bleService];
		//[peripheral discoverCharacteristics:self.currentCharacteristicUUIDs forService:bleService];
	}
}

- (void) peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error{
    
	if (peripheral != _peripheral) {
        [self.delegate reportMessage:@"Wrong Peripheral"];
		return ;
	}
	
	if (service != bleService) {
        [self.delegate reportMessage:@"Wrong Service"];
		return ;
	}
    
    if (error != nil) {
        NSString * message = [NSString stringWithFormat:@"Error: %@",error];
        [self.delegate reportMessage:message];
		return ;
	}
    
	for (CBCharacteristic *characteristic in service.characteristics) {
        
        NSLog(@"discovered characteristic %@",[characteristic UUID]);
        
        if ([[characteristic UUID] isEqual:self.currentCharacteristicUUIDs[0]]) {
            
			self.rxCharacteristic = characteristic;
			[peripheral setNotifyValue:YES forCharacteristic:self.rxCharacteristic];
		}
        
        if ([[characteristic UUID] isEqual:self.currentCharacteristicUUIDs[1]]) {
            
			self.txCharacteristic = characteristic;
            
            timer = [NSTimer scheduledTimerWithTimeInterval:kFlushInterval target:self selector:@selector(flushData) userInfo:nil repeats:YES];
            
            [self.delegate bleServiceIsReady:self];
		}
	}
}

#pragma mark Characteristics interaction
/*
-(void) clearRx{
    if(self.peripheral.isConnected){
        short byte = 1;
        NSData * data = [NSData dataWithBytes:&byte length:1];
        [_peripheral writeValue:data forCharacteristic:self.rxClearCharacteristic type:CBCharacteristicWriteWithResponse];
    }
}*/

-(uint16_t) calculateCRCForBytes:(uint8_t*) bytes count:(NSInteger) count{
    uint16_t crc = 0;
    
    for (int i = 0; i < count; i++) {
        uint8_t b = bytes[i];
        
        crc = (uint8_t)(crc >> 8) | (crc << 8);
        crc ^= b;
        crc ^= (uint8_t)(crc & 0xff) >> 4;
        crc ^= crc << 12;
        crc ^= (crc & 0xff) << 5;
    }
    return crc;
}

-(NSData*) crcPackageForBytes:(const uint8_t*) bytes count:(NSInteger) count{
    
    uint8_t crcBytes[count+4];
    crcBytes[0] = kBleCrcStart;
    crcBytes[1] = count;
    
    memcpy(crcBytes + 2, bytes, count);
    
    uint16_t crcValue = [self calculateCRCForBytes:crcBytes+1 count:count+1];
    
    //NSLog(@"crc value: %d",crcValue);
    
    uint8_t firstByte = (crcValue & 0xFF00) >> 8;
    uint8_t secondByte = (crcValue & 0x00FF);
    
    crcBytes[count+2] = firstByte;
    crcBytes[count+3] = secondByte;
    
    return [NSData dataWithBytes:crcBytes length:count + 4];
}

-(void) writeToTx:(NSData*) data{
    
    if(self.txCharacteristic){
        if(self.deviceType == kBleDeviceTypeKroll){
            //Kroll shield needs to write with response
            [_peripheral writeValue:data forCharacteristic:self.txCharacteristic type:CBCharacteristicWriteWithResponse];
        } else {
            [_peripheral writeValue:data forCharacteristic:self.txCharacteristic type:CBCharacteristicWriteWithoutResponse];
        }
        
        printf("Sending:\n");
        for (int i = 0; i < data.length; i++) {
            printf("%X ",((uint8_t*)data.bytes)[i]);
        }
        printf("\n");
    }
}

-(void) addBytesToBuffer:(const uint8_t*) bytes count:(NSInteger) count{
    
    int idx = (sendBufferStart + sendBufferCount) % SEND_BUFFER_SIZE;
    for (int i = 0; i < count; i++) {
        sendBuffer[idx] = bytes[i];
        idx = (idx + 1) % SEND_BUFFER_SIZE;
    }
    
    sendBufferCount += count;
    if(sendBufferCount >= SEND_BUFFER_SIZE){
        NSLog(@"Warning, reaching limits of ble send buffer");
        sendBufferCount = SEND_BUFFER_SIZE;
    }
}

-(void) sendData:(const uint8_t*) bytes count:(NSInteger) count{
    
    if(self.shouldUseCRC){
        NSData * crcData = [self crcPackageForBytes:bytes count:count];
        bytes = crcData.bytes;
        count = crcData.length;
    }
    
    [self addBytesToBuffer:bytes count:count];
    
    double currentTime = CACurrentMediaTime();
    
    if(currentTime - lastTimeFlushed > kFlushInterval){
        
        [self flushData];
    }
    
    /*
    printf("Sending:\n");
    for (int i = 0; i < count; i++) {
        printf("%X ",bytes[i]);
    }
    printf("\n");*/
}

-(void) sendOverCommand{
    if(sendBufferCount == 0){
        
        uint8_t buf[2];
        buf[0] = kBleCrcStart;
        buf[1] = 0;
        NSData * data = [NSData dataWithBytes:buf length:2];
        [self writeToTx:data];
        shouldSend = NO;
    }
}

-(void) flushData {
    
    if(shouldSend){
        if(sendBufferCount > 0){
            
            char buf[TX_BUFFER_SIZE];
            int numBytesSend = MIN(TX_BUFFER_SIZE, sendBufferCount);
            
            if(sendBufferStart + numBytesSend > SEND_BUFFER_SIZE){
                
                char firstPartSize = SEND_BUFFER_SIZE - sendBufferStart ;
                
                memcpy(buf,&sendBuffer[0] + sendBufferStart,firstPartSize);
                memcpy(&buf[0] + firstPartSize,&sendBuffer[0],numBytesSend-firstPartSize);
                
            } else {
                
                memcpy(buf,&sendBuffer[0] + sendBufferStart,numBytesSend);
            }
            
            NSData * data = [NSData dataWithBytes:buf length:numBytesSend];
            [self writeToTx:data];
            
            sendBufferCount -= numBytesSend;
            sendBufferStart = (sendBufferStart + numBytesSend) % SEND_BUFFER_SIZE;
            
            /*
            if(self.shouldUseTurnBasedCommunication){
                [self sendOverCommand];
            }*/
            
            lastTimeFlushed = CACurrentMediaTime();
            
        } else {
            
            if(self.shouldUseTurnBasedCommunication){
                static int bleTimeOutCount = 0;
                
                if(bleTimeOutCount++ > 2 && sendBufferCount == 0)///XXX dirty!
                {
                    bleTimeOutCount = 0;
                    [self sendOverCommand];
                }
            }
        }
    }
}

- (void)enteredBackground
{
    [_peripheral setNotifyValue:NO forCharacteristic:self.rxCharacteristic];
}

- (void)enteredForeground
{
    [_peripheral setNotifyValue:YES forCharacteristic:self.rxCharacteristic];
}

-(void) updateRx{
    
    [self.peripheral readValueForCharacteristic:self.rxCharacteristic];
}

-(void) updateTx{
    
    [self.peripheral readValueForCharacteristic:self.txCharacteristic];
}

-(void) updateCharacteristic:(CBCharacteristic*) characteristic{
    [self.peripheral readValueForCharacteristic:characteristic];
}

- (NSString*) txString {
	if (self.txCharacteristic) {
        
        return [BLEHelper DataToString:self.txCharacteristic.value];
    }
    
    return nil;
}

- (NSString*) rxString {
	if (self.rxCharacteristic) {
                 
        return [BLEHelper DataToString:self.rxCharacteristic.value];
    }
    
    return nil;
}

-(NSString*) characteristicNameFor:(CBCharacteristic*) characteristic{
    
    if(characteristic == self.rxCharacteristic) {
        return @"RX";
    } else if(characteristic == self.txCharacteristic){
        return @"TX";
    }
    
    return @"Unknown";
}

-(void) peripheral:(CBPeripheral *)peripheral didWriteValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error{
    
    if(characteristic == self.txCharacteristic){
        /*
        Byte * data;
        NSInteger length = [BLEHelper Data:characteristic.value toArray:&data];
        for (int i = 0 ; i < length; i++) {
            int value = data[i];
            printf("%d ",value);
        }
        printf("\n");*/
    }
}

-(NSInteger) receiveBufferSize{
    
    if(receiveDataCurrentIndex > receiveDataStart){
        return receiveDataCurrentIndex - receiveDataStart;
    } else {
        return RECEIVE_BUFFER_SIZE - receiveDataStart + receiveDataCurrentIndex;
    }
    
}

-(NSData*) checkCRCAndNotify:(NSData*) data{
    
    for (int i = 0; i < data.length; i++) {
        
        uint8_t byte = ((uint8_t*)data.bytes)[i];
        
        if(parsingState == BLEReceiveBufferStateNormal){
            
            receiveDataLength = 0;
            receiveDataCount = 0;
            
            if(byte == kBleCrcStart){
                
                parsingState = BLEReceiveBufferStateParsingLength;
            }
            
        } else if(parsingState == BLEReceiveBufferStateParsingLength){
            
            if(byte == 0){
                parsingState = BLEReceiveBufferStateNormal;
                shouldSend = YES;
                
            } else {
                receiveDataLength = byte;
                
                parsingState = BLEReceiveBufferStateParsingData;
            }
            
        } else if(parsingState == BLEReceiveBufferStateParsingData){
            
            receiveBuffer[receiveDataCount++] = byte;

            if(receiveDataCount == receiveDataLength){
                
                parsingState = BLEReceiveBufferStateParsingCrc1;
            }
            
        } else if(parsingState == BLEReceiveBufferStateParsingCrc1){
            
            firstCrcByte = byte;
            parsingState = BLEReceiveBufferStateParsingCrc2;
            
        } else if(parsingState == BLEReceiveBufferStateParsingCrc2){
            
            secondCrcByte = byte;
            
            uint16_t crc = (firstCrcByte << 8) + secondCrcByte;
            
            uint8_t bytesWithLength[receiveDataLength+1];
            bytesWithLength[0] = receiveDataLength;
            memcpy(bytesWithLength+1, receiveBuffer, receiveDataLength);
            
            uint16_t myCrc = [self calculateCRCForBytes:bytesWithLength count:receiveDataLength+1];

            if(crc == myCrc){
                [self.dataDelegate didReceiveData:receiveBuffer lenght:receiveDataLength];
            } else {
                NSLog(@"received wrong crc %d",crc);
            }
            
            parsingState = BLEReceiveBufferStateNormal;
        }
    }
        
    return [NSData dataWithBytes:receiveBuffer length:receiveDataLength];
}

- (void) peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error {
    
	if (peripheral != _peripheral) {
		NSLog(@"Wrong peripheral\n");
		return;
	}

    if ([error code] != 0) {
		NSLog(@"Error %@\n", error);
		return ;
	}
    
    if(characteristic == self.rxCharacteristic){
        
        if(self.shouldUseCRC){
            
            [self checkCRCAndNotify:characteristic.value];
            
        } else {
            
            uint8_t * data;
            NSInteger length = [BLEHelper Data:characteristic.value toArray:&data];
            [self.dataDelegate didReceiveData:data lenght:length];
            free(data);
        }

    } else {
        
        if([self.dataDelegate respondsToSelector:@selector(updatedValueForCharacteristic:)]){
            [self.dataDelegate updatedValueForCharacteristic:characteristic];
        }
    }
    
}

-(NSString*) description{
    return @"BLEService";
}

@end
