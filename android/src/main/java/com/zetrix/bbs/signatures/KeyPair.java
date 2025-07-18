package com.zetrix.bbs.signatures;

public class KeyPair {
    public byte[] secretKey;
    public byte[] publicKey;

    public KeyPair(byte[] publicKey, byte[] secretKey) {
        this.publicKey = publicKey;
        this.secretKey = secretKey;
    }

    public byte[] getPublicKey() {
        return publicKey;
    }

    public byte[] getSecretKey() {
        return secretKey;
    }
}
