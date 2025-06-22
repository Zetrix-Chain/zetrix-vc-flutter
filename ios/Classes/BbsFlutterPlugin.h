#import <Flutter/Flutter.h>

// Import the BBS library header file
#import "bbs.h"
#import "bbs_signature.h"
#import "bbs_signature_proof.h"

@interface BbsFlutterPlugin : NSObject<FlutterPlugin>

// Declaration of methods to interface with Flutter and BBS library
// These act as Objective-C wrappers for the C functions in bbs.h

/**
 * Initializes a blind commitment context.
 * Calls `bbs_blind_commitment_context_init` from the BBS library.
 */
- (uint64_t)blindCommitmentContextInit:(FlutterResult)result;

/**
 * Creates a BBS signature from messages and a key pair.
 */
- (void)createBbsSignature:(NSArray *_Nonnull)messages
                   keyPair:(NSDictionary *_Nonnull)keyPair
                    result:(FlutterResult)result;

/**
 * Verifies a BBS signature with messages and a key pair.
 */
- (void)verifyBbsSignature:(NSDictionary *_Nonnull)keyPair
                  messages:(NSArray *_Nonnull)messages
                 signature:(NSData *_Nonnull)signature
                    result:(FlutterResult)result;

/**
 * Creates a BBS signature proof with revealed messages.
 */
- (void)createBbsSignatureProof:(NSData *_Nonnull)signature
                        keyPair:(NSDictionary *_Nonnull)keyPair
                          nonce:(NSData *_Nonnull)nonce
                       messages:(NSArray *_Nonnull)messages
                       revealed:(NSArray *_Nonnull)revealed
                         result:(FlutterResult)result;

/**
 * Verifies a signature proof for messages and key pair.
 */
- (void)verifyBbsSignatureProof:(NSDictionary *_Nonnull)keyPair
                       messages:(NSArray *_Nonnull)messages
                          nonce:(NSData *_Nonnull)nonce
                          proof:(NSData *_Nonnull)proof
                         result:(FlutterResult)result;

/**
 * Finishes the blind commitment by calling `bbs_blind_commitment_context_finish`.
 */
- (void)blindCommitmentContextFinish:(uint64_t)handle
        resultBuffer:(bbs_signature_byte_buffer_t *_Nullable)commitment
        outContext:(bbs_signature_byte_buffer_t *_Nullable)outContext
        blindingFactor:(bbs_signature_byte_buffer_t *_Nullable)blindingFactor
        result:(FlutterResult)result;

/**
 * Adds a message string to the blind commitment context.
 * Calls `bbs_blind_commitment_context_add_message_string`.
 */
- (void)addMessageString:(uint64_t)handle
        index:(uint32_t)index
        message:(NSString *_Nullable)message
        result:(FlutterResult)result;

/**
 * Adds a message from bytes to the blind commitment context.
 * Calls `bbs_blind_commitment_context_add_message_bytes`.
 */
- (void)addMessageBytes:(uint64_t)handle
        index:(uint32_t)index
        message:(bbs_signature_byte_buffer_t)message
        result:(FlutterResult)result;

/**
 * Sets the public key for the blind commitment context.
 * Calls `bbs_blind_commitment_context_set_public_key`.
 */
- (void)setPublicKey:(uint64_t)handle
        publicKey:(bbs_signature_byte_buffer_t)publicKey
        result:(FlutterResult)result;

/**
 * Frees a string allocated by BBS library.
 * Calls `bbs_string_free`.
 */
- (void)freeString:(char *_Nullable)string;

/**
 * Frees a byte buffer allocated by BBS library.
 * Calls `bbs_byte_buffer_free`.
 */
- (void)freeByteBuffer:(bbs_signature_byte_buffer_t)buffer;

+ (NSDictionary *)bls_generate_g2_key;


@end