# VC Support Operations

### Get access token

Before user (holder or issuer) can perform any operation, they are required to generate and sign the
blob in order to generate the access token.

Instantiate the ZetrixVcService and Encryption class

```
final service = ZetrixVcService(false);
final encryption = Encryption();
```

#### 1. Generate the blob

```

VcRegisterBlobReq req = VcRegisterBlobReq();
req.address = <USER_ADDRESS>;
ZetrixSDKResult<VcRegisterBlobResp> resp = await service.getRegisterBlob(req);
```

#### 2. Sign the blob

```
SignBlobResp signResp = await encryption.signBlob(<BLOB>, <USER_PRIV_KEY>);
```

#### 3. Submit the blob to generate token

```
VcRegisterSubmitReq req = VcRegisterSubmitReq();
req.blobId = <BLOB_ID>;
req.blobSign = <SIGNED_BLOB>;
req.publicKey = <PUBLIC_KEY>;
req.address = <USER_ADDRESS>;

ZetrixSDKResult<VcRegisterSubmitResp> resp = await service.getRegisterToken(req);
```

### Apply VC

Before certificate can be applied or issued, issuer must register himself and perform KYC operation
using https://credential.zetrix.com. After KYC approved, issuer can create new template which
include attributes required for the verification. The template address must be shared to the holder
who interested to apply for the certificate.

Holder can apply the certificate by providing relevant information such as holder, effective date (
in form of year/month/day), expiration date (in form of year/month/day), certificate number (must be
unique), additional attributes as stated in the templates.

```
List<AttributeKeyValue> attributes = [
    AttributeKeyValue(key: "holder", value: holder["address"]),
    AttributeKeyValue(key: "effectiveDate", value: "2023/09/23"),
    AttributeKeyValue(key: "expirationDate", value: "2123/09/23"),
    AttributeKeyValue(key: "certificateNo", value: "cert01"),
    AttributeKeyValue(key: "k_1", value: "Sekolah Kebangsaan Johor Ria"),
    AttributeKeyValue(key: "k_2", value: "Pengawas"),
];

VcAttributeContent content = VcAttributeContent();
content.attributes = attributes;

VcApplyReq req = VcApplyReq();
req.content = content;
req.templateId = <TEMPLATE_ADDRESS>;
req.publicKey = <HOLDER_PUBLIC_KEY>;

ZetrixSDKResult<VcApplyResult> resp = await service.applyVc(<ACCESS_TOKEN>, req);
```

### Issue VC

VC issuance is done by the issuer. Issuer can issue the VC by using SDK in the mobile or directly
through the https://credential.zetrix.com.

To issue the VC, issuer must obtained the application number from holder who applied, create blob,
sign and submit the blob for issuing VC.

#### 1. Generate the blob

```
ZetrixSDKResult<VcAuditBlobResult> resp = await service.issueVcBlob(<ISSUER_ACCESS_TOKEN>, <APPLY_NO>);
```

#### 2. Sign the blob

After receiving the bcTxBlob and payload from issueVcBlob API, issuer must sign both parameters.

```
SignBlobResp signBcTxBlob = await encryption.signBlob(<BC_TX_BLOB>, <ISSUER_PRIV_KEY>);

SignMessageResp signPayload = await encryption.signMessage(<PAYLOAD>, <ISSUER_PRIV_KEY>);
```

#### 3. Submit to issue VC

```
VcAuditSubmitReq req = VcAuditSubmitReq();
req.payloadId = <PAYLOAD_ID>;
req.signBcTxBlob = <SIGNED_BC_TX_BLOB>;
req.signPayload = <SIGNED_PAYLOAD>;
req.publicKey = <ISSUER_PUBLIC_KEY>;
req.border = 0;

ZetrixSDKResult<VcAuditSubmitResult> resp = await service.issueVcSubmit(<ISSUER_TOKEN>, req);
```

### View VC list

Holder or issuer can view the vc list by calling

```
VcInfoReq req = VcInfoReq();
req.userAddress = <HOLDER_ADDRESS>;
req.pageStart = 1;
req.pageSize = 10;
req.status = 0; // 0: apply, 1: approved, 2: rejected

ZetrixSDKResult<VcInfoResp> resp = await service.getVcList(<HOLDER_TOKEN>, req);
```

### VC Download

Holder can download the VC and store in local device.

```
VcDownloadReq req = VcDownloadReq();
req.userAddress = <HOLDER_ADDRESS>;
req.credentialId = <VC_ID>;

ZetrixSDKResult<VcDownloadResult> resp = await service.downloadVc(<HOLDER_TOKEN>, req);
```

### Reject VC Application

Issuer can reject VC application via SDK or website https://credential.zetrix.com.

```
ZetrixSDKResult<bool> resp = await service.rejectVc(<ISSUER_TOKEN>, <ISSUER_ADDRESS>, <APPLICATION_NUMBER>);
```

### QR Code Generation

For verification, holder can generate the QR code and share with the verifier. To generate the QR
code, holder must create the blob, sign and submit the blob for QR generation.

#### 1. Generate the blob

Holder must provide the content to present to the verifier (form of JSON string) along with the VC
ID and JWS that have been downloaded.

```
var contentAssert = {"k_2": "Pengawas"};

VcGenerateQrBlobReq req = VcGenerateQrBlobReq();
req.vcId = <VC_ID>;
req.contentAssert = json.encode(contentAssert);
req.jws = <JWS>;

ZetrixSDKResult<VcGenerateQrBlobResult> resp = await service.generateQrBlob(<HOLDER_TOKEN>, req);
```

#### 2. Sign the blob

Holder must sign the blob obtained from generateQrBlob API.

```
SignBlobResp sign = await encryption.signBlob(<BLOB>, <HOLDER_KEY>);
```

#### 3. Submit QR code generation

Holder must sign the blob obtained from generateQrBlob API.

```
VcGenerateQrReq req = VcGenerateQrReq();
req.blobId = <BLOB_ID>;
req.signBlob = <SIGNED_BLOB>;
req.publicKey = <PUBLIC_KEY>;
req.userAddress = "";

ZetrixSDKResult<String> resp = await service.generateQrSubmit(<HOLDER_TOKEN>, req);
```

### Verify VC

Verifier can verify VC by using the QR code (UUID) value obtained from the holder.

```
ZetrixSDKResult<VcVerificationResult> resp = await service.verifyQrCode(<QR_CODE>);
```
