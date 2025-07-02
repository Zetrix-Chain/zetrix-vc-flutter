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

        // Process required data fields
        NSData *publicKey = [self processDataField:args[@"publicKey"] fieldName:@"publicKey"];
        NSData *nonce = [self processDataField:args[@"nonce"] fieldName:@"nonce"];
        NSData *signature = [self processDataField:args[@"signature"] fieldName:@"signature"];

        // Process messages
        NSArray *msgList = args[@"messages"];
        NSMutableArray *messages = [self processMessageList:msgList];

        // Create proof and return result
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

// Helper method to process data fields
- (NSData *)processDataField:(id)dataObject fieldName:(NSString *)fieldName {
    NSData *processedData = nil;

    if ([dataObject isKindOfClass:[FlutterStandardTypedData class]]) {
        FlutterStandardTypedData *flutterData = (FlutterStandardTypedData *)dataObject;
        processedData = flutterData.data;
        NSLog(@"Successfully extracted NSData from FlutterStandardTypedData. Length: %lu", (unsigned long)processedData.length);
    } else if ([dataObject isKindOfClass:[NSArray class]]) {
        NSLog(@"Warning: %@ received as NSArray, converting using byteListToArray. This might be an older data format.", fieldName);
        processedData = [self byteListToArray:(NSArray<NSNumber *> *)dataObject];
    } else if (dataObject) {
        [self logError:fieldName type:[dataObject class]];
    } else {
        NSLog(@"Error: %@ is nil in args.", fieldName);
    }

    return processedData;
}

// Helper method to process message list
- (NSMutableArray *)processMessageList:(NSArray *)msgList {
    NSMutableArray *messages = [NSMutableArray arrayWithCapacity:msgList.count];

    for (NSDictionary *msg in msgList) {
        NSData *message = [self processDataField:msg[@"message"] fieldName:@"message"];
        NSData *blindingFactor = [self processDataField:msg[@"blinding_factor"] fieldName:@"blinding_factor"];

        ProofMessage *proofMsg = [[ProofMessage alloc] initWithType:[msg[@"type"] intValue]
                                                            message:message
                                                           blinding:blindingFactor];
        [messages addObject:proofMsg];
    }

    return messages;
}

// Helper method for error logging
- (void)logError:(NSString *)fieldName type:(Class)class {
    NSLog(@"Error: %@ is of unexpected type: %@", fieldName, class);
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
