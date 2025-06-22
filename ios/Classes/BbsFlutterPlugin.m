#import "BbsFlutterPlugin.h"

@implementation BbsFlutterPlugin

+ (void)registerWithRegistrar:(NSObject <FlutterPluginRegistrar> *)registrar {
    FlutterMethodChannel *channel = [FlutterMethodChannel
            methodChannelWithName:@"zetrix_bbs"
                  binaryMessenger:[registrar messenger]];
    BbsFlutterPlugin *instance = [[BbsFlutterPlugin alloc] init];
    [registrar addMethodCallDelegate:instance channel:channel];
}

- (void)handleMethodCall:(FlutterMethodCall *)call result:(FlutterResult)result {
    if ([@"blindCommitmentContextInit" isEqualToString:call.method]) {
        [self blindCommitmentContextInit:result];
    } else if ([@"blindCommitmentContextFinish" isEqualToString:call.method]) {
        uint64_t handle = [call.arguments[@"handle"] unsignedLongLongValue];
        [self blindCommitmentContextFinish:handle result:result];
    } else if ([@"addMessageString" isEqualToString:call.method]) {
        uint64_t handle = [call.arguments[@"handle"] unsignedLongLongValue];
        uint32_t index = [call.arguments[@"index"] unsignedIntValue];
        NSString *message = call.arguments[@"message"];
        [self addMessageString:handle index:index message:message result:result];
    } else if ([@"addMessageBytes" isEqualToString:call.method]) {
        uint64_t handle = [call.arguments[@"handle"] unsignedLongLongValue];
        uint32_t index = [call.arguments[@"index"] unsignedIntValue];
        FlutterStandardTypedData *data = call.arguments[@"message"];
        bbs_signature_byte_buffer_t buffer;
        buffer.len = data.length;
        buffer.data = (uint8_t * )
        [data.data bytes];
        [self addMessageBytes:handle index:index message:buffer result:result];
    } else if ([@"setPublicKey" isEqualToString:call.method]) {
        uint64_t handle = [call.arguments[@"handle"] unsignedLongLongValue];
        FlutterStandardTypedData *data = call.arguments[@"publicKey"];
        bbs_signature_byte_buffer_t publicKey;
        publicKey.len = data.length;
        publicKey.data = (uint8_t * )
        [data.data bytes];
        [self setPublicKey:handle publicKey:publicKey result:result];
    } else {
        result(FlutterMethodNotImplemented);
    }
}

// MARK: - BBS Library Wrappers

- (void)blindCommitmentContextInit:(FlutterResult)result {
    bbs_signature_error_t error;
    uint64_t handle = bbs_blind_commitment_context_init(&error);

    if (handle == 0) {
        if (error.message) {
            result([FlutterError errorWithCode:[@(error.code) stringValue]
                                       message:[NSString stringWithUTF8String:error.message]
                                       details:nil]);
            bbs_string_free(error.message);
        } else {
            result([FlutterError errorWithCode:@"UNKNOWN_ERROR"
                                       message:@"Failed to initialize blind commitment context"
                                       details:nil]);
        }
        return;
    }

    result(@(handle));
}

- (void)blindCommitmentContextFinish:(uint64_t)handle result:(FlutterResult)result {
    bbs_signature_byte_buffer_t commitment;
    bbs_signature_byte_buffer_t outContext;
    bbs_signature_byte_buffer_t blindingFactor;
    bbs_signature_error_t error;

    int32_t status = bbs_blind_commitment_context_finish(handle, &commitment, &outContext,
                                                         &blindingFactor, &error);
    if (status != 0) {
        if (error.message) {
            result([FlutterError errorWithCode:[@(error.code) stringValue]
                                       message:[NSString stringWithUTF8String:error.message]
                                       details:nil]);
            bbs_string_free(error.message);
        } else {
            result([FlutterError errorWithCode:@"UNKNOWN_ERROR"
                                       message:@"Failed to finish blind commitment context"
                                       details:nil]);
        }
        return;
    }

    NSDictionary *response = @{
            @"commitment": [FlutterStandardTypedData typedDataWithBytes:[NSData dataWithBytes:commitment.data length:commitment.len]],
            @"outContext": [FlutterStandardTypedData typedDataWithBytes:[NSData dataWithBytes:outContext.data length:outContext.len]],
            @"blindingFactor": [FlutterStandardTypedData typedDataWithBytes:[NSData dataWithBytes:blindingFactor.data length:blindingFactor.len]]
    };

    // Free allocated memory
    bbs_byte_buffer_free(commitment);
    bbs_byte_buffer_free(outContext);
    bbs_byte_buffer_free(blindingFactor);

    result(response);
}

- (void)addMessageString:(uint64_t)handle index:(uint32_t)index message:(NSString *_Nullable)message result:(FlutterResult)result {
    bbs_signature_error_t error;
    const char *cMessage = [message UTF8String];
    int32_t status = bbs_blind_commitment_context_add_message_string(handle, index, cMessage,
                                                                     &error);

    if (status != 0) {
        if (error.message) {
            result([FlutterError errorWithCode:[@(error.code) stringValue]
                                       message:[NSString stringWithUTF8String:error.message]
                                       details:nil]);
            bbs_string_free(error.message);
        } else {
            result([FlutterError errorWithCode:@"UNKNOWN_ERROR"
                                       message:@"Failed to add message string to context"
                                       details:nil]);
        }
        return;
    }

    result(@(status));
}

- (void)addMessageBytes:(uint64_t)handle
                  index:(uint32_t)index
                message:(bbs_signature_byte_buffer_t)message
                 result:(FlutterResult)result {
    bbs_signature_error_t error;
    int32_t status = bbs_blind_commitment_context_add_message_bytes(handle, index, message, &error);

    if (status != 0) {
        if (error.message) {
            result([FlutterError errorWithCode:[@(error.code) stringValue]
                                       message:[NSString stringWithUTF8String:error.message]
                                       details:nil]);
            bbs_string_free(error.message);
        } else {
            result([FlutterError errorWithCode:@"UNKNOWN_ERROR"
                                       message:@"Failed to add message bytes to context"
                                       details:nil]);
        }
        return;
    }

    result(@(status));
}

- (void)setPublicKey:(uint64_t)handle
           publicKey:(bbs_signature_byte_buffer_t)publicKey
              result:(FlutterResult)result {
    bbs_signature_error_t error;
    int32_t status = bbs_blind_commitment_context_set_public_key(handle, publicKey, &error);

    if (status != 0) {
        if (error.message) {
            result([FlutterError errorWithCode:[@(error.code) stringValue]
                                       message:[NSString stringWithUTF8String:error.message]
                                       details:nil]);
            bbs_string_free(error.message);
        } else {
            result([FlutterError errorWithCode:@"UNKNOWN_ERROR"
                                       message:@"Failed to set public key for context"
                                       details:nil]);
        }
        return;
    }

    result(@(status));
}

// MARK: Create BBS Signature
- (void)createBbsSignature:(NSArray *_Nonnull)messages
                   keyPair:(NSDictionary *_Nonnull)keyPair
                    result:(FlutterResult)result {
    @try {
        BbsKeyPair *bbsKeyPair = [[BbsKeyPair alloc] initWithPublicKey:keyPair[@"publicKey"]
                                                            privateKey:keyPair[@"privateKey"]];
        BbsSignature *signature = [[BbsSignature alloc] sign:bbsKeyPair
                                                    messages:messages
                                                   withError:nil];
        if (!signature) {
            result([FlutterError errorWithCode:@"ERROR"
                                       message:@"Failed to create BBS signature."
                                       details:nil]);
            return;
        }
        result(signature.value);
    }
    @catch (NSException *exception) {
        result([FlutterError errorWithCode:@"EXCEPTION"
                                   message:exception.reason
                                   details:nil]);
    }
}

// MARK: Verify BBS Signature
- (void)verifyBbsSignature:(NSDictionary *_Nonnull)keyPair
                  messages:(NSArray *_Nonnull)messages
                 signature:(NSData *_Nonnull)signature
                    result:(FlutterResult)result {
    @try {
        BbsKeyPair *bbsKeyPair = [[BbsKeyPair alloc] initWithPublicKey:keyPair[@"publicKey"]
                                                            privateKey:nil];
        BbsSignature *bbsSignature = [[BbsSignature alloc] initWithBytes:signature withError:nil];
        bool isValid = [bbsSignature verify:bbsKeyPair
                                   messages:messages
                                  withError:nil];
        result(@(isValid));
    }
    @catch (NSException *exception) {
        result([FlutterError errorWithCode:@"EXCEPTION"
                                   message:exception.reason
                                   details:nil]);
    }
}

// MARK: Create BBS Signature Proof
- (void)createBbsSignatureProof:(NSData *_Nonnull)signature
                        keyPair:(NSDictionary *_Nonnull)keyPair
                          nonce:(NSData *_Nonnull)nonce
                       messages:(NSArray *_Nonnull)messages
                       revealed:(NSArray *_Nonnull)revealed
                         result:(FlutterResult)result {
    @try {
        BbsKeyPair *bbsKeyPair = [[BbsKeyPair alloc] initWithPublicKey:keyPair[@"publicKey"]
                                                            privateKey:keyPair[@"privateKey"]];
        BbsSignature *bbsSignature = [[BbsSignature alloc] initWithBytes:signature withError:nil];
        BbsSignatureProof *proof = [[BbsSignatureProof alloc] createProof:bbsSignature
                                                                  keyPair:bbsKeyPair
                                                                    nonce:nonce
                                                                 messages:messages
                                                                 revealed:revealed
                                                                withError:nil];
        if (!proof) {
            result([FlutterError errorWithCode:@"ERROR"
                                       message:@"Failed to create BBS signature proof."
                                       details:nil]);
            return;
        }
        result(proof.value);
    }
    @catch (NSException *exception) {
        result([FlutterError errorWithCode:@"EXCEPTION"
                                   message:exception.reason
                                   details:nil]);
    }
}

// MARK: Verify BBS Signature Proof
- (void)verifyBbsSignatureProof:(NSDictionary *_Nonnull)keyPair
                       messages:(NSArray *_Nonnull)messages
                          nonce:(NSData *_Nonnull)nonce
                          proof:(NSData *_Nonnull)proof
                         result:(FlutterResult)result {
    @try {
        BbsKeyPair *bbsKeyPair = [[BbsKeyPair alloc] initWithPublicKey:keyPair[@"publicKey"]
                                                            privateKey:nil];
        BbsSignatureProof *signatureProof = [[BbsSignatureProof alloc] initWithBytes:proof withError:nil];
        bool isValid = [signatureProof verifyProof:bbsKeyPair
                                          messages:messages
                                             nonce:nonce
                                         withError:nil];
        result(@(isValid));
    }
    @catch (NSException *exception) {
        result([FlutterError errorWithCode:@"EXCEPTION"
                                   message:exception.reason
                                   details:nil]);
    }
}


@end