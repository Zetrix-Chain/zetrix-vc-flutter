import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:zetrix_vc_flutter/zetrix_vc_flutter.dart';
import 'qr_code.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'BBS Plugin Demo',
      home: Scaffold(
        appBar: AppBar(title: const Text('BBS+ Proof Test')),
        body: const Center(child: BbsProofTestWidget()),
      ),
    );
  }
}

class BbsProofTestWidget extends StatefulWidget {
  const BbsProofTestWidget({super.key});

  @override
  State<BbsProofTestWidget> createState() => _BbsProofTestWidgetState();
}

class _BbsProofTestWidgetState extends State<BbsProofTestWidget> {
  String _result = 'Tap the button to create a proof.';
  ZetrixVpService zetrixVpService = ZetrixVpService();

  Future<void> _generateVP() async {
    const vcJson = '''{
            "id": "did:zid:6601378b18e96707d25b2070fd7125549ece3f2e3ad4b5e1dda67d262975ba4f",
            "type": [
                "VerifiableCredential",
                "TestPassport"
            ],
            "issuer": "did:zid:a0ef91714f1b84317d395118706796e38f012c48893f5063ebd7db2d9406c9ff",
            "issuanceDate": "2025-06-17T00:00:00Z",
            "expirationDate": "2035-06-17T00:00:00Z",
            "credentialSubject": {
                "id": "did:zid:eff30af3427a38c5cd021f5ac28578d27c3bd1ab53fc4d2789c1f8cb1827e83c",
                "testPassport": {
                    "name": "John Doeee",
                    "dob": "1990-01-01",
                    "gender": "Male",
                    "nationality": "Myanmarese",
                    "identityNo": "A123456789",
                    "passportNo": "P987654321",
                    "citizenType": "Permanent Resident",
                    "dateOfExpiry": "2030-12-31",
                    "countryIssue": "Malaysia",
                    "photo": "google.com"
                }
            },
            "proof": [
                {
                    "type": "BbsBlsSignature2020",
                    "created": "2025-06-18T03:20:49.542446Z",
                    "proofPurpose": "assertionMethod",
                    "proofValue": "uprfR-i_9Apk88cc-UxqYie61cfHoi9TQLj3nvARxJjcL_dDSto2GpP2PI-LARq5jHfjfGw5IZg_yqOGewi9Fd3Iu7BRsh4zq56My7qo28XUOpc5dzaXzoyTUc8yGPUaHzP6V-UgvEhuIpRiBZIjEmQ",
                    "verificationMethod": "did:zid:a0ef91714f1b84317d395118706796e38f012c48893f5063ebd7db2d9406c9ff#delegateKey-1"
                },
                {
                    "type": "Ed25519Signature2020",
                    "created": "2025-06-18T03:20:49.544218Z",
                    "proofPurpose": "assertionMethod",
                    "verificationMethod": "did:zid:a0ef91714f1b84317d395118706796e38f012c48893f5063ebd7db2d9406c9ff#controllerKey",
                    "jws": "eyJhbGciOiJFZERTQSJ9.eyJAY29udGV4dCI6WyJodHRwczovL3d3dy53My5vcmcvMjAxOC9jcmVkZW50aWFscy92MSIsImh0dHBzOi8vdzNpZC5vcmcvc2VjdXJpdHkvYmJzL3YxIiwiaHR0cHM6Ly90ZXN0LW5vZGUuemV0cml4LmNvbS9nZXRBY2NvdW50TWV0YURhdGE_YWRkcmVzcz1aVFgzSnN6cVBnUlV4NzQzU0FwN3E3elVSZmp2a1d1SDJGTUV6JmtleT10ZW1wbGF0ZV9fZGlkOnppZDo5YWE3ZWNlZmMwNzY1ZmU5MzkyMzZiNDQ3N2NiNTI2MjIwNWJkNDNhNDI4MWQ1MWZjYTJjZDdlNDNjMjljODM4Il0sImNyZWRlbnRpYWxTdWJqZWN0Ijp7ImlkIjoiZGlkOnppZDplZmYzMGFmMzQyN2EzOGM1Y2QwMjFmNWFjMjg1NzhkMjdjM2JkMWFiNTNmYzRkMjc4OWMxZjhjYjE4MjdlODNjIiwidGVzdFBhc3Nwb3J0Ijp7ImNpdGl6ZW5UeXBlIjoiUGVybWFuZW50IFJlc2lkZW50IiwiY291bnRyeUlzc3VlIjoiTWFsYXlzaWEiLCJkYXRlT2ZFeHBpcnkiOiIyMDMwLTEyLTMxIiwiZG9iIjoiMTk5MC0wMS0wMSIsImdlbmRlciI6Ik1hbGUiLCJpZGVudGl0eU5vIjoiQTEyMzQ1Njc4OSIsIm5hbWUiOiJKb2huIERvZWVlIiwibmF0aW9uYWxpdHkiOiJNeWFubWFyZXNlIiwicGFzc3BvcnRObyI6IlA5ODc2NTQzMjEiLCJwaG90byI6Imdvb2dsZS5jb20ifX0sImV4cGlyYXRpb25EYXRlIjoiMjAzNS0wNi0xN1QwMDowMDowMFoiLCJpZCI6ImRpZDp6aWQ6NjYwMTM3OGIxOGU5NjcwN2QyNWIyMDcwZmQ3MTI1NTQ5ZWNlM2YyZTNhZDRiNWUxZGRhNjdkMjYyOTc1YmE0ZiIsImlzc3VhbmNlRGF0ZSI6IjIwMjUtMDYtMTdUMDA6MDA6MDBaIiwiaXNzdWVyIjoiZGlkOnppZDphMGVmOTE3MTRmMWI4NDMxN2QzOTUxMTg3MDY3OTZlMzhmMDEyYzQ4ODkzZjUwNjNlYmQ3ZGIyZDk0MDZjOWZmIiwidHlwZSI6WyJWZXJpZmlhYmxlQ3JlZGVudGlhbCIsIlRlc3RQYXNzcG9ydCJdfQ.QjdDQTJGNUU2MTA4MEZCNjEwNzJENzhBQzM4M0E0MUQyQ0U1MEZDQkM1NkMzRDQ5ODAwMEQ2ODBDRTUxNEQyN0IyNTg5M0VDODlBMUI5QjYyMDJDRUMwMUEyOEI3MTk3NjNERDUyMDAzMDgwRkJENzE3QTkxOEI4ODA1NThEMDA"
                }
            ],
            "@context": [
                "https://www.w3.org/2018/credentials/v1",
                "https://w3id.org/security/bbs/v1",
                "https://test-node.zetrix.com/getAccountMetaData?address=ZTX3JszqPgRUx743SAp7q7zURfjvkWuH2FMEz&key=template__did:zid:9aa7ecefc0765fe939236b4477cb5262205bd43a4281d51fca2cd7e43c29c838"
            ]
        }''';

    final reveal = [
      "testPassport.name",
      // "testPassport.gender",
      // "testPassport.nationality",
    ];

    final vcMap = jsonDecode(vcJson) as Map<String, dynamic>;
    final vc = VerifiableCredential.fromJson(vcMap);

    final ZetrixSDKResult<String> vp = await zetrixVpService.createVpMC(
      vc,
      reveal,
      'z23ENzoxDd3PJFWMLQYCoPwJBC7epEKoG3wdEFYLU6JTtznnL4zukArZMEFX4n1DSwi5GmssJnx7gsjsQRi7fcf7seZ3rqQBv48Mef2hHTdtkeDrqV7SHdv4YkAx5o9MxhjLw',
      'b001a0ef91714f1b84317d395118706796e38f012c48893f5063ebd7db2d9406c9ffe3b775cb',
    );

    if (vp is Success<String> && vp.data != null) {
      print(vp.data);
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => QrCodeScreen(data: vp.data!)),
      );
    } else {
      setState(() => _result = 'VP generation failed');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(_result, textAlign: TextAlign.center),
        const SizedBox(height: 20),
        ElevatedButton(
          onPressed: () async {
            final seed = Uint8List(32); // Or use Random()
            final keyPair = await BbsFlutter.generateBls12381G1Key(seed);
            print('Public Key: ${base64.encode(keyPair['publicKey']!)}');
            print('Secret Key: ${base64.encode(keyPair['secretKey']!)}');
          },
          child: const Text("Generate BLS12381G1 Key"),
        ),
        ElevatedButton(
          onPressed: _generateVP,
          child: const Text("Generate Verifiable Presentation"),
        ),
      ],
    );
  }
}
