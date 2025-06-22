package com.zetrix.bbs;

import androidx.annotation.NonNull;
import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;

import java.util.Map;
import java.util.List;
import java.util.ArrayList;
import com.zetrix.bbs.signatures.ProofMessage;

import java.util.HashMap;
import bbs.signatures.Bbs;
import com.zetrix.bbs.signatures.KeyPair;

public class BbsFlutterPlugin implements FlutterPlugin, MethodCallHandler {
    private MethodChannel channel;

    @Override
    public void onAttachedToEngine(@NonNull FlutterPluginBinding binding) {
        channel = new MethodChannel(binding.getBinaryMessenger(), "bbs_flutter");
        channel.setMethodCallHandler(this);
    }

    @Override
    public void onMethodCall(MethodCall call, Result result) {
        if (call.method.equals("generateBls12381G1Key")) {
            try {
                byte[] seed = call.argument("seed");
                KeyPair keyPair = Bbs.generateBls12381G1Key(seed);

                Map<String, Object> response = new HashMap<>();
                response.put("publicKey", keyPair.getPublicKey());
                response.put("secretKey", keyPair.getSecretKey());

                result.success(response);
            } catch (Exception e) {
                result.error("GEN_KEY_ERROR", e.getMessage(), null);
            }
        } else if (call.method.equals("blsCreateProof")) {
            Map<String, Object> args = call.arguments();

            // byte[] publicKey = byteListToArray((List<Integer>) args.get("publicKey"));
            // byte[] nonce = byteListToArray((List<Integer>) args.get("nonce"));
            // byte[] signature = byteListToArray((List<Integer>) args.get("signature"));

            Object pk = args.get("publicKey");
            byte[] publicKey = pk instanceof byte[] ? (byte[]) pk : byteListToArray((List<Integer>) pk);

            Object nc = args.get("nonce");
            byte[] nonce = nc instanceof byte[] ? (byte[]) nc : byteListToArray((List<Integer>) nc);

            Object sig = args.get("signature");
            byte[] signature = sig instanceof byte[] ? (byte[]) sig : byteListToArray((List<Integer>) sig);

            List<Map<String, Object>> msgList = (List<Map<String, Object>>) args.get("messages");
            ProofMessage[] messages = new ProofMessage[msgList.size()];
            for (int i = 0; i < msgList.size(); i++) {
                Map<String, Object> msg = msgList.get(i);
                int type = (int) msg.get("type");
                // byte[] message = byteListToArray((List<Integer>) msg.get("message"));
                Object rawMsg = msg.get("message");
                byte[] message = rawMsg instanceof byte[]
                        ? (byte[]) rawMsg
                        : byteListToArray((List<Integer>) rawMsg);

                // byte[] blinding = byteListToArray((List<Integer>)
                // msg.get("blinding_factor"));
                Object rawBlind = msg.get("blinding_factor");
                byte[] blinding = rawBlind instanceof byte[]
                        ? (byte[]) rawBlind
                        : byteListToArray((List<Integer>) rawBlind);

                // ✅ Correct order of constructor arguments: type, message, blinding
                messages[i] = new ProofMessage(type, message, blinding);
            }

            try {
                byte[] proof = Bbs.blsCreateProof(publicKey, nonce, signature, messages);
                result.success(toList(proof));
            } catch (Exception e) {
                result.error("BLS_CREATE_PROOF_FAILED", e.getMessage(), null);
            }

        } else if (call.method.equals("blsPublicToBbsPublicKey")) {
            try {
                List<Integer> pubKeyList = call.argument("blsPublicKey");
                int messageCount = call.argument("messages");

                byte[] blsPublicKey = byteListToArray(pubKeyList);
                byte[] bbsKey = Bbs.blsPublicToBbsPublicKey(blsPublicKey, messageCount);

                result.success(toList(bbsKey));
            } catch (Exception e) {
                result.error("BLS_TO_BBS_FAILED", e.getMessage(), null);
            }
        } else {
            result.notImplemented();
        }
    }

    @Override
    public void onDetachedFromEngine(@NonNull FlutterPluginBinding binding) {
        channel.setMethodCallHandler(null);
    }

    private byte[] byteListToArray(List<Integer> list) {
        byte[] result = new byte[list.size()];
        for (int i = 0; i < list.size(); i++) {
            result[i] = (byte) (int) list.get(i);
        }
        return result;
    }

    private List<Integer> toList(byte[] bytes) {
        List<Integer> list = new ArrayList<>(bytes.length);
        for (byte b : bytes) {
            list.add((int) b & 0xFF);
        }
        return list;
    }

}
