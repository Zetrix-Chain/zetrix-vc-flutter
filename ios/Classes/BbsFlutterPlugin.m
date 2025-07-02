#import "BbsFlutterPlugin.h"
#import "bbs_signature_proof.h"

// ProofMessage interface declaration
@interface ProofMessage : NSObject

@property (nonatomic, assign) int type;
@property (nonatomic, strong) NSData *message;
@property (nonatomic, strong) NSData *blinding_factor;

- (instancetype)initWithType:(int)type
                    message:(NSData *)message
                   blinding:(NSData *)blinding_factor;

@end

// ProofMessage implementation
@implementation ProofMessage

- (instancetype)initWithType:(int)type
                    message:(NSData *)message
                   blinding:(NSData *)blinding_factor {
    self = [super init];
    if (self) {
        _type = type;
        _message = message;
        _blinding_factor = blinding_factor;
    }
    return self;
}

@end

// Constants
static const int PROOF_MESSAGE_TYPE_REVEALED = 1;
static const int PROOF_MESSAGE_TYPE_HIDDEN_PROOF_SPECIFIC_BLINDING = 2;
static const int PROOF_MESSAGE_TYPE_HIDDEN_EXTERNAL_BLINDING = 3;

@implementation BbsFlutterPlugin

+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
    FlutterMethodChannel* channel = [FlutterMethodChannel
            methodChannelWithName:@"bbs_flutter"
                  binaryMessenger:[registrar messenger]];
    BbsFlutterPlugin* instance = [[BbsFlutterPlugin alloc] init];
    [registrar addMethodCallDelegate:instance channel:channel];
}

- (void)handleMethodCall:(FlutterMethodCall*)call result:(FlutterResult)result {
    if ([@"blsCreateProof" isEqualToString:call.method]) {
        [self blsCreateProof:call result:result];
    } else {
        result(FlutterMethodNotImplemented);
    }
}

// Add after your existing code but before @end

- (NSData *)blsCreateProof:(NSData *)publicKey
                    nonce:(NSData *)nonce
               signature:(NSData *)signature
                messages:(NSArray *)messages {
    bbs_signature_error_t error;
    
    // Convert public key to BBS public key
    bbs_signature_byte_buffer_t bbsPublicKeyBuffer;
    bbs_signature_byte_buffer_t inputPubKey = {
        .data = (uint8_t *)publicKey.bytes,
        .len = publicKey.length
    };
    
    if (bls_public_key_to_bbs_key(inputPubKey, (uint32_t)messages.count, &bbsPublicKeyBuffer, &error) != 0) {
        NSString *errorMsg = error.message ? @(error.message) : @"Unable to convert public key";
        @throw [NSException exceptionWithName:@"BBSError" reason:errorMsg userInfo:nil];
    }
    
    // Initialize proof context
    uint64_t handle = bbs_create_proof_context_init(&error);
    if (handle == 0) {
        @throw [NSException exceptionWithName:@"BBSError"
                                    reason:@"Unable to create proof context"
                                  userInfo:nil];
    }
    
    // Set public key
    if (bbs_create_proof_context_set_public_key(handle, bbsPublicKeyBuffer, &error) != 0) {
        bbs_byte_buffer_free(bbsPublicKeyBuffer);
        @throw [NSException exceptionWithName:@"BBSError"
                                    reason:@"Unable to set public key"
                                  userInfo:nil];
    }
    
    // Set nonce
    bbs_signature_byte_buffer_t nonceBuffer = {
        .data = (uint8_t *)nonce.bytes,
        .len = nonce.length
    };
    if (bbs_create_proof_context_set_nonce_bytes(handle, nonceBuffer, &error) != 0) {
        bbs_byte_buffer_free(bbsPublicKeyBuffer);
        @throw [NSException exceptionWithName:@"BBSError"
                                    reason:@"Unable to set nonce"
                                  userInfo:nil];
    }
    
    // Set signature
    bbs_signature_byte_buffer_t sigBuffer = {
        .data = (uint8_t *)signature.bytes,
        .len = signature.length
    };
    if (bbs_create_proof_context_set_signature(handle, sigBuffer, &error) != 0) {
        bbs_byte_buffer_free(bbsPublicKeyBuffer);
        @throw [NSException exceptionWithName:@"BBSError"
                                    reason:@"Unable to set signature"
                                  userInfo:nil];
    }
    
    // Add messages
    for (ProofMessage *msg in messages) {
        bbs_signature_byte_buffer_t msgBuffer = {
            .data = (uint8_t *)msg.message.bytes,
            .len = msg.message.length
        };
        bbs_signature_byte_buffer_t blindBuffer = {
            .data = (uint8_t *)msg.blinding_factor.bytes,
            .len = msg.blinding_factor.length
        };
        
        if (bbs_create_proof_context_add_proof_message_bytes(handle, msgBuffer, msg.type, blindBuffer, &error) != 0) {
            bbs_byte_buffer_free(bbsPublicKeyBuffer);
            @throw [NSException exceptionWithName:@"BBSError"
                                        reason:@"Unable to add proof message"
                                      userInfo:nil];
        }
    }
    
    // Finish and get proof
    bbs_signature_byte_buffer_t proofBuffer;
    if (bbs_create_proof_context_finish(handle, &proofBuffer, &error) != 0) {
        bbs_byte_buffer_free(bbsPublicKeyBuffer);
        @throw [NSException exceptionWithName:@"BBSError"
                                    reason:@"Unable to create proof"
                                  userInfo:nil];
    }
    
    // Convert to NSData and clean up
    NSData *proof = [NSData dataWithBytes:proofBuffer.data length:proofBuffer.len];
    bbs_byte_buffer_free(proofBuffer);
    bbs_byte_buffer_free(bbsPublicKeyBuffer);
    
    return proof;
}

- (void)blsCreateProof:(FlutterMethodCall*)call result:(FlutterResult)result {
    @try {
        NSDictionary *args = call.arguments;

        id publicKeyObject = args[@"publicKey"];

        NSData *publicKey = nil;

        if ([publicKeyObject isKindOfClass:[FlutterStandardTypedData class]]) {
            FlutterStandardTypedData *flutterData = (FlutterStandardTypedData *)publicKeyObject;
            publicKey = flutterData.data; // Access the .data property
            NSLog(@"Successfully extracted NSData from FlutterStandardTypedData. Length: %lu", (unsigned long)publicKey.length);
        } else if ([publicKeyObject isKindOfClass:[NSArray class]]) {
            // This is your OLD way, keep it if some calls might still send a list of numbers
            NSLog(@"Warning: publicKey received as NSArray, converting using byteListToArray. This might be an older data format.");
            publicKey = [self byteListToArray:(NSArray<NSNumber *> *)publicKeyObject];
        } else if (publicKeyObject) {
            // Handle other unexpected types or log an error
            NSLog(@"Error: publicKey is of unexpected type: %@", [publicKeyObject class]);
        } else {
            NSLog(@"Error: publicKey is nil in args.");
        }

        id nonceObject = args[@"nonce"];

        NSData *nonce = nil;

        if ([nonceObject isKindOfClass:[FlutterStandardTypedData class]]) {
            FlutterStandardTypedData *flutterData = (FlutterStandardTypedData *)nonceObject;
            nonce = flutterData.data; // Access the .data property
            NSLog(@"Successfully extracted NSData from FlutterStandardTypedData. Length: %lu", (unsigned long)nonce.length);
        } else if ([nonceObject isKindOfClass:[NSArray class]]) {
            // This is your OLD way, keep it if some calls might still send a list of numbers
            NSLog(@"Warning: nonce received as NSArray, converting using byteListToArray. This might be an older data format.");
            nonce = [self byteListToArray:(NSArray<NSNumber *> *)nonceObject];
        } else if (nonceObject) {
            // Handle other unexpected types or log an error
            NSLog(@"Error: nonce is of unexpected type: %@", [nonceObject class]);
        } else {
            NSLog(@"Error: nonce is nil in args.");
        }

        id signatureObject = args[@"signature"];

        NSData *signature = nil;

        if ([signatureObject isKindOfClass:[FlutterStandardTypedData class]]) {
            FlutterStandardTypedData *flutterData = (FlutterStandardTypedData *)signatureObject;
            signature = flutterData.data; // Access the .data property
            NSLog(@"Successfully extracted NSData from FlutterStandardTypedData. Length: %lu", (unsigned long)signature.length);
        } else if ([signatureObject isKindOfClass:[NSArray class]]) {
            // This is your OLD way, keep it if some calls might still send a list of numbers
            NSLog(@"Warning: signature received as NSArray, converting using byteListToArray. This might be an older data format.");
            signature = [self byteListToArray:(NSArray<NSNumber *> *)signatureObject];
        } else if (signatureObject) {
            // Handle other unexpected types or log an error
            NSLog(@"Error: signature is of unexpected type: %@", [signatureObject class]);
        } else {
            NSLog(@"Error: signature is nil in args.");
        }

        NSArray *msgList = args[@"messages"];

        NSMutableArray *messages = [NSMutableArray arrayWithCapacity:msgList.count];
        for (NSDictionary *msg in msgList) {

            id messageObject = msg[@"message"];

            NSData *message = nil;

            if ([messageObject isKindOfClass:[FlutterStandardTypedData class]]) {
                FlutterStandardTypedData *flutterData = (FlutterStandardTypedData *)messageObject;
                message = flutterData.data; // Access the .data property
                NSLog(@"Successfully extracted NSData from FlutterStandardTypedData. Length: %lu", (unsigned long)message.length);
            } else if ([messageObject isKindOfClass:[NSArray class]]) {
                // This is your OLD way, keep it if some calls might still send a list of numbers
                NSLog(@"Warning: message received as NSArray, converting using byteListToArray. This might be an older data format.");
                message = [self byteListToArray:(NSArray<NSNumber *> *)messageObject];
            } else if (messageObject) {
                // Handle other unexpected types or log an error
                NSLog(@"Error: message is of unexpected type: %@", [messageObject class]);
            } else {
                NSLog(@"Error: message is nil in args.");
            }

            id blindingFactorObject = msg[@"blinding_factor"];

            NSData *blindingFactor = nil;

            if ([blindingFactorObject isKindOfClass:[FlutterStandardTypedData class]]) {
                FlutterStandardTypedData *flutterData = (FlutterStandardTypedData *)blindingFactorObject;
                blindingFactor = flutterData.data; // Access the .data property
                NSLog(@"Successfully extracted NSData from FlutterStandardTypedData. Length: %lu", (unsigned long)blindingFactor.length);
            } else if ([blindingFactorObject isKindOfClass:[NSArray class]]) {
                // This is your OLD way, keep it if some calls might still send a list of numbers
                NSLog(@"Warning: blindingFactor received as NSArray, converting using byteListToArray. This might be an older data format.");
                blindingFactor = [self byteListToArray:(NSArray<NSNumber *> *)blindingFactorObject];
            } else if (blindingFactorObject) {
                // Handle other unexpected types or log an error
                NSLog(@"Error: blindingFactor is of unexpected type: %@", [blindingFactorObject class]);
            } else {
                NSLog(@"Error: blindingFactor is nil in args.");
            }

            ProofMessage *proofMsg = [[ProofMessage alloc] initWithType:[msg[@"type"] intValue]
                                                              message:message
                                                             blinding:blindingFactor];
            [messages addObject:proofMsg];
        }

        NSData *proof = [self blsCreateProof:publicKey
                                     nonce:nonce
                                signature:signature
                                 messages:messages];
        result([self toList:proof]);
    } @catch (NSException *exception) {
        result([FlutterError errorWithCode:@"BLS_CREATE_PROOF_FAILED"
                                 message:exception.reason
                                 details:nil]);
    }
}

#pragma mark - Helper Methods

- (NSArray<NSNumber *> *)toList:(NSData *)data {
    NSMutableArray<NSNumber *> *list = [NSMutableArray arrayWithCapacity:data.length];
    const uint8_t *bytes = data.bytes;
    for (NSUInteger i = 0; i < data.length; i++) {
        [list addObject:@(bytes[i] & 0xFF)];
    }
    return list;
}

- (NSData *)byteListToArray:(NSArray<NSNumber *> *)list {
    NSMutableData *data = [NSMutableData dataWithCapacity:list.count];
    for (NSNumber *num in list) {
        uint8_t byte = num.unsignedCharValue;
        [data appendBytes:&byte length:1];
    }
    return data;
}

@end
