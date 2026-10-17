import 'dart:developer';
import 'dart:io';
import 'dart:typed_data';

import 'package:chiphell/net/download_file.dart';
import 'package:chiphell/theme/theme_provider.dart';
import 'package:chiphell/utils/Toast.dart';
import 'package:crypto/crypto.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:intl/intl.dart';
import 'package:collection/collection.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import 'certificate_constants.dart';

class CertificateInfoPopup extends StatefulWidget {
  final WebUri url;
  final InAppWebViewController? webViewController;
  const CertificateInfoPopup({super.key, required this.url, required this.webViewController});

  @override
  State<CertificateInfoPopup> createState() => _CertificateInfoPopupState();
}

class _CertificateInfoPopupState extends State<CertificateInfoPopup> {
  final List<X509Certificate> _otherCertificates = [];
  X509Certificate? _topMainCertificate;
  X509Certificate? _selectedCertificate;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var themeProvider = Provider.of<ThemeProvider>(context, listen: true);
    return _build(context, themeProvider);
  }

  Color get titleColor => ThemeProvider().isDarkTheme() ? Colors.white54 : Colors.black54;

  Widget _build(BuildContext context, ThemeProvider themeProvider) {
    if (_topMainCertificate == null) {
      return FutureBuilder(
        future: widget.webViewController?.getCertificate(),
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return SizedBox(width: 20, height: 20, child: const CircularProgressIndicator(strokeWidth: 4.0));
          }
          if (snapshot.hasError) {
            return SizedBox(width: 40, height: 40, child: Icon(Icons.error_outline, color: Colors.red));
          }
          if (!snapshot.hasData) {
            return SizedBox(width: 40, height: 40, child: Icon(Icons.not_interested, color: Colors.red));
          }

          SslCertificate sslCertificate = snapshot.data as SslCertificate;
          _topMainCertificate = sslCertificate.x509Certificate;
          _selectedCertificate = _topMainCertificate!;
          return FutureBuilder(
            future: _getOtherCertificatesFromTopMain(_otherCertificates, _topMainCertificate!),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.done) {
                return _buildCertificatesInfoAlertDialog();
              }
              return Center(
                child: Container(
                  decoration: BoxDecoration(
                    color: themeProvider.isDarkTheme() ? const Color.fromARGB(255, 53, 51, 51) : const Color.fromARGB(255, 186, 184, 184),
                    borderRadius: BorderRadius.all(Radius.circular(2.5)),
                  ),
                  padding: const EdgeInsets.all(25.0),
                  width: 100.0,
                  height: 100.0,
                  child: const CircularProgressIndicator(strokeWidth: 4.0),
                ),
              );
            },
          );
        },
      );
    } else {
      return _buildCertificatesInfoAlertDialog();
    }
  }

  Future<void> _getOtherCertificatesFromTopMain(List<X509Certificate> otherCertificates, X509Certificate x509certificate) async {
    var authorityInfoAccess = x509certificate.authorityInfoAccess;
    if (authorityInfoAccess != null && authorityInfoAccess.infoAccess != null) {
      for (var i = 0; i < authorityInfoAccess.infoAccess!.length; i++) {
        try {
          var caIssuerUrl = authorityInfoAccess.infoAccess![i].location; // [OID.caIssuers.toValue()];
          HttpClientRequest request = await HttpClient().getUrl(Uri.parse(caIssuerUrl));
          HttpClientResponse response = await request.close();
          var certData = Uint8List.fromList(await response.first);
          var cert = X509Certificate.fromData(data: certData);
          otherCertificates.add(cert);
          await _getOtherCertificatesFromTopMain(otherCertificates, cert);
        } catch (e) {
          log(e.toString());
        }
      }
    }

    var cRLDistributionPoints = x509certificate.cRLDistributionPoints;
    if (cRLDistributionPoints != null && cRLDistributionPoints.crls != null) {
      for (var i = 0; i < cRLDistributionPoints.crls!.length; i++) {
        var crlUrl = cRLDistributionPoints.crls![i];
        try {
          HttpClientRequest request = await HttpClient().getUrl(Uri.parse(crlUrl));
          HttpClientResponse response = await request.close();
          var certData = Uint8List.fromList(await response.first);
          var cert = X509Certificate.fromData(data: certData);
          otherCertificates.add(cert);
          await _getOtherCertificatesFromTopMain(otherCertificates, cert);
        } catch (e) {
          log(e.toString());
        }
      }
    }
  }

  AlertDialog _buildCertificatesInfoAlertDialog() {
    var url = widget.url;
    return AlertDialog(
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Container(
                decoration: const BoxDecoration(color: Colors.green, borderRadius: BorderRadius.all(Radius.circular(5.0))),
                padding: const EdgeInsets.all(5.0),
                child: const Icon(Icons.lock, color: Colors.white, size: 20.0),
              ),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(url.host, style: const TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 15.0),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Expanded(
                            child: Text(
                              "浏览器已验证 ${_topMainCertificate?.issuer(dn: ASN1DistinguishedNames.COMMON_NAME)} 已发出网站证书。",
                              softWrap: true,
                              style: const TextStyle(fontSize: 12.0),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 15.0),
                      RichText(
                        text: TextSpan(
                          text: CertificateConstants.certificateInfo,
                          style: const TextStyle(color: Colors.blue, fontSize: 12.0),
                          recognizer: TapGestureRecognizer()
                            ..onTap = () {
                              showDialog(
                                context: context,
                                builder: (context) {
                                  List<X509Certificate> certificates = [_topMainCertificate!];
                                  certificates.addAll(_otherCertificates);

                                  return AlertDialog(
                                    content: Container(
                                      constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width / 2.5),
                                      child: StatefulBuilder(
                                        builder: (context, setState) {
                                          List<DropdownMenuItem<X509Certificate>> dropdownMenuItems = [];
                                          for (var certificate in certificates) {
                                            var name =
                                                _findCommonName(x509certificate: certificate, isSubject: true) ??
                                                _findOrganizationName(x509certificate: certificate, isSubject: true) ??
                                                "";
                                            if (name != "") {
                                              dropdownMenuItems.add(
                                                DropdownMenuItem<X509Certificate>(value: certificate, child: Text(name)),
                                              );
                                            }
                                          }

                                          return Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            mainAxisSize: MainAxisSize.min,
                                            children: <Widget>[
                                              Text(
                                                CertificateConstants.zs,
                                                //"Certificate Viewer",
                                                style: TextStyle(
                                                  fontSize: 24.0,
                                                  //color: titleColor,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              const SizedBox(height: 15.0),
                                              DropdownButton<X509Certificate>(
                                                isExpanded: true,
                                                onChanged: (value) {
                                                  setState(() {
                                                    _selectedCertificate = value;
                                                  });
                                                },
                                                value: _selectedCertificate,
                                                items: dropdownMenuItems,
                                              ),
                                              const SizedBox(height: 15.0),
                                              Flexible(child: SingleChildScrollView(child: _buildCertificateInfo(_selectedCertificate!))),
                                            ],
                                          );
                                        },
                                      ),
                                    ),
                                  );
                                },
                              );
                            },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCertificateInfo(X509Certificate x509certificate) {
    var issuedToSection = _buildIssuedToSection(x509certificate);
    var issuedBySection = _buildIssuedBySection(x509certificate);
    var validityPeriodSection = _buildValidityPeriodSection(x509certificate);
    var publicKeySection = _buildPublicKeySection(x509certificate);
    var fingerprintSection = _buildFingerprintSection(x509certificate);
    var extensionSection = _buildExtensionSection(x509certificate);

    var children = <Widget>[];
    children.addAll(issuedToSection);
    children.addAll(issuedBySection);
    children.addAll(validityPeriodSection);
    children.addAll(publicKeySection);
    children.addAll(fingerprintSection);
    children.addAll(extensionSection);

    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: children);
  }

  String? _findCountryName({required X509Certificate x509certificate, required bool isSubject}) {
    try {
      return (isSubject
              ? x509certificate.subject(dn: ASN1DistinguishedNames.COUNTRY_NAME)
              : x509certificate.issuer(dn: ASN1DistinguishedNames.COUNTRY_NAME)) ??
          x509certificate.block1?.findOid(oid: OID.countryName)?.parent?.sub?.last.value;
    } catch (e) {
      log(e.toString());
    }
    return null;
  }

  String? _findStateOrProvinceName({required X509Certificate x509certificate, required bool isSubject}) {
    try {
      return (isSubject
              ? x509certificate.subject(dn: ASN1DistinguishedNames.STATE_OR_PROVINCE_NAME)
              : x509certificate.issuer(dn: ASN1DistinguishedNames.STATE_OR_PROVINCE_NAME)) ??
          x509certificate.block1?.findOid(oid: OID.stateOrProvinceName)?.parent?.sub?.last.value;
    } catch (e) {
      log(e.toString());
    }
    return null;
  }

  String? _findCommonName({required X509Certificate x509certificate, required bool isSubject}) {
    try {
      return (isSubject
              ? x509certificate.subject(dn: ASN1DistinguishedNames.COMMON_NAME)
              : x509certificate.issuer(dn: ASN1DistinguishedNames.COMMON_NAME)) ??
          x509certificate.block1?.findOid(oid: OID.commonName)?.parent?.sub?.last.value;
    } catch (e) {
      log(e.toString());
    }
    return null;
  }

  String? _findOrganizationName({required X509Certificate x509certificate, required bool isSubject}) {
    try {
      return (isSubject
              ? x509certificate.subject(dn: ASN1DistinguishedNames.ORGANIZATION_NAME)
              : x509certificate.issuer(dn: ASN1DistinguishedNames.ORGANIZATION_NAME)) ??
          x509certificate.block1?.findOid(oid: OID.organizationName)?.parent?.sub?.last.value;
    } catch (e) {
      log(e.toString());
    }
    return null;
  }

  String? _findOrganizationUnitName({required X509Certificate x509certificate, required bool isSubject}) {
    try {
      return (isSubject
              ? x509certificate.subject(dn: ASN1DistinguishedNames.ORGANIZATIONAL_UNIT_NAME)
              : x509certificate.issuer(dn: ASN1DistinguishedNames.ORGANIZATIONAL_UNIT_NAME)) ??
          x509certificate.block1?.findOid(oid: OID.organizationalUnitName)?.parent?.sub?.last.value;
    } catch (e) {
      log(e.toString());
    }
    return null;
  }

  List<Widget> _buildIssuedToSection(X509Certificate x509certificate) {
    var subjectCountryName =
        _findCountryName(x509certificate: x509certificate, isSubject: true) ?? CertificateConstants.notPartOfCertificate;
    var subjectStateOrProvinceName =
        _findStateOrProvinceName(x509certificate: x509certificate, isSubject: true) ?? CertificateConstants.notPartOfCertificate;
    var subjectCN = _findCommonName(x509certificate: x509certificate, isSubject: true) ?? CertificateConstants.notPartOfCertificate;
    var subjectO = _findOrganizationName(x509certificate: x509certificate, isSubject: true) ?? CertificateConstants.notPartOfCertificate;
    var subjectU =
        _findOrganizationUnitName(x509certificate: x509certificate, isSubject: true) ?? CertificateConstants.notPartOfCertificate;

    return <Widget>[
      const Text(
        CertificateConstants.bfg,
        //"ISSUED TO",
        style: TextStyle(fontSize: 14.0, fontWeight: FontWeight.bold),
      ),
      const SizedBox(height: 5.0),
      const Text(
        CertificateConstants.tymc,
        //"Common Name (CN)",
        style: TextStyle(fontSize: 14.0, fontWeight: FontWeight.bold),
      ),
      Text(subjectCN, style: TextStyle(fontSize: 14.0, color: titleColor)),
      const SizedBox(height: 5.0),
      const Text(
        CertificateConstants.zzhi,
        // "Organization (O)",
        style: TextStyle(fontSize: 14.0, fontWeight: FontWeight.bold),
      ),
      Text(subjectO, style: TextStyle(fontSize: 14.0, color: titleColor)),
      const SizedBox(height: 5.0),
      const Text(
        CertificateConstants.zzdw, // "组织单位（U）",
        // "Organizational Unit (U)",
        style: TextStyle(fontSize: 14.0, fontWeight: FontWeight.bold),
      ),
      Text(subjectU, style: TextStyle(fontSize: 14.0, color: titleColor)),
      const SizedBox(height: 5.0),
      const Text(
        CertificateConstants.guojia,
        // "Country",
        style: TextStyle(fontSize: 14.0, fontWeight: FontWeight.bold),
      ),
      Text(subjectCountryName, style: TextStyle(fontSize: 14.0, color: titleColor)),
      const SizedBox(height: 5.0),
      const Text(
        CertificateConstants.zhousheng,
        //"State/Province",
        style: TextStyle(fontSize: 14.0, fontWeight: FontWeight.bold),
      ),
      Text(subjectStateOrProvinceName, style: TextStyle(fontSize: 14.0, color: titleColor)),
    ];
  }

  List<Widget> _buildIssuedBySection(X509Certificate x509certificate) {
    var issuerCountryName =
        _findCountryName(x509certificate: x509certificate, isSubject: false) ?? CertificateConstants.notPartOfCertificate;
    var issuerStateOrProvinceName =
        _findStateOrProvinceName(x509certificate: x509certificate, isSubject: false) ?? CertificateConstants.notPartOfCertificate;
    var issuerCN = _findCommonName(x509certificate: x509certificate, isSubject: false) ?? CertificateConstants.notPartOfCertificate;
    var issuerO = _findOrganizationName(x509certificate: x509certificate, isSubject: false) ?? CertificateConstants.notPartOfCertificate;
    var issuerU =
        _findOrganizationUnitName(x509certificate: x509certificate, isSubject: false) ?? CertificateConstants.notPartOfCertificate;
    var serialNumber =
        x509certificate.serialNumber
            ?.map((byte) {
              var hexValue = byte.toRadixString(16);
              if (byte == 0 || hexValue.length == 1) {
                hexValue = "0$hexValue";
              }
              return hexValue.toUpperCase();
            })
            .toList()
            .join(":") ??
        CertificateConstants.notPartOfCertificate;
    var version = x509certificate.version?.toString() ?? CertificateConstants.notPartOfCertificate;
    var sigAlgName = x509certificate.sigAlgName ?? CertificateConstants.notPartOfCertificate;

    return <Widget>[
      const SizedBox(height: 15.0),
      const Text(
        CertificateConstants.qf,
        //"ISSUED BY",
        style: TextStyle(fontSize: 14.0, fontWeight: FontWeight.bold),
      ),
      const SizedBox(height: 5.0),
      const Text(
        CertificateConstants.tymc,
        //"Common Name (CN)",
        style: TextStyle(fontSize: 14.0, fontWeight: FontWeight.bold),
      ),
      Text(issuerCN, style: TextStyle(fontSize: 14.0, color: titleColor)),
      const SizedBox(height: 5.0),
      const Text(
        CertificateConstants.zzhi,
        //"Organization (O)",
        style: TextStyle(fontSize: 14.0, fontWeight: FontWeight.bold),
      ),
      Text(issuerO, style: TextStyle(fontSize: 14.0, color: titleColor)),
      const SizedBox(height: 5.0),
      const Text(
        CertificateConstants.zzdw, //"组织单位（U）",
        //"Organizational Unit (U)",
        style: TextStyle(fontSize: 14.0, fontWeight: FontWeight.bold),
      ),
      Text(issuerU, style: TextStyle(fontSize: 14.0, color: titleColor)),
      const SizedBox(height: 5.0),
      const Text(
        CertificateConstants.guojia,
        // "Country",
        style: TextStyle(fontSize: 14.0, fontWeight: FontWeight.bold),
      ),
      Text(issuerCountryName, style: TextStyle(fontSize: 14.0, color: titleColor)),
      const SizedBox(height: 5.0),
      const Text(
        CertificateConstants.zhousheng,
        //"State/Province",
        style: TextStyle(fontSize: 14.0, fontWeight: FontWeight.bold),
      ),
      Text(issuerStateOrProvinceName, style: TextStyle(fontSize: 14.0, color: titleColor)),
      const SizedBox(height: 5.0),
      const Text(
        CertificateConstants.xlh,
        //"Serial Number",
        style: TextStyle(fontSize: 14.0, fontWeight: FontWeight.bold),
      ),
      Text(serialNumber, style: TextStyle(fontSize: 14.0, color: titleColor)),
      const SizedBox(height: 5.0),
      const Text(
        CertificateConstants.version, //"版本",
        //"Version",
        style: TextStyle(fontSize: 14.0, fontWeight: FontWeight.bold),
      ),
      Text(version, style: TextStyle(fontSize: 14.0, color: titleColor)),
      const SizedBox(height: 5.0),
      const Text(
        CertificateConstants.qmsf,
        //"Signature Algorithm",
        style: TextStyle(fontSize: 14.0, fontWeight: FontWeight.bold),
      ),
      Text(sigAlgName, style: TextStyle(fontSize: 14.0, color: titleColor)),
    ];
  }

  List<Widget> _buildValidityPeriodSection(X509Certificate x509certificate) {
    var issuedOnDate = x509certificate.notBefore != null
        ? DateFormat("dd MMM yyyy HH:mm:ss").format(x509certificate.notBefore!)
        : CertificateConstants.notPartOfCertificate;
    var expiresOnDate = x509certificate.notAfter != null
        ? DateFormat("dd MMM yyyy HH:mm:ss").format(x509certificate.notAfter!)
        : CertificateConstants.notPartOfCertificate;

    return <Widget>[
      const SizedBox(height: 15.0),
      const Text(
        CertificateConstants.yxq,
        // "VALIDITY PERIOD",
        style: TextStyle(fontSize: 14.0, fontWeight: FontWeight.bold),
      ),
      const SizedBox(height: 5.0),
      const Text(
        CertificateConstants.fbrq,
        // "Issued on date",
        style: TextStyle(fontSize: 14.0, fontWeight: FontWeight.bold),
      ),
      Text(issuedOnDate, style: TextStyle(fontSize: 14.0, color: titleColor)),
      const SizedBox(height: 5.0),
      const Text(
        CertificateConstants.dqrq,
        // "Expires on date",
        style: TextStyle(fontSize: 14.0, fontWeight: FontWeight.bold),
      ),
      Text(expiresOnDate, style: TextStyle(fontSize: 14.0, color: titleColor)),
    ];
  }

  List<Widget> _buildPublicKeySection(X509Certificate x509certificate) {
    var publicKey = x509certificate.publicKey;
    var publicKeyAlg = CertificateConstants.notPartOfCertificate;
    var publicKeyAlgParams = CertificateConstants.notPartOfCertificate;
    if (publicKey != null) {
      if (publicKey.algOid != null) {
        //1.2.840.10045.2.1
        publicKeyAlg = "${OID.fromValue(publicKey.algOid)!.name()} ( ${publicKey.algOid} )";
      }
      if (publicKey.algParams != null) {
        //1.3.132.0.34
        var v = OID.fromValue(publicKey.algParams);
        publicKeyAlgParams = "${v != null ? v.name() : ''} ( ${publicKey.algParams} )";
      }
    }

    return <Widget>[
      const SizedBox(height: 15.0),
      const Text(
        CertificateConstants.gy,
        // "PUBLIC KEY",
        style: TextStyle(fontSize: 14.0, fontWeight: FontWeight.bold),
      ),
      const SizedBox(height: 5.0),
      const Text(
        CertificateConstants.sf,
        //"Algorithm",
        style: TextStyle(fontSize: 14.0, fontWeight: FontWeight.bold),
      ),
      Text(publicKeyAlg, style: TextStyle(fontSize: 14.0, color: titleColor)),
      const SizedBox(height: 5.0),
      const Text(
        CertificateConstants.cs,
        //"Parameters",
        style: TextStyle(fontSize: 14.0, fontWeight: FontWeight.bold),
      ),
      Text(publicKeyAlgParams, style: TextStyle(fontSize: 14.0, color: titleColor)),
    ];
  }

  List<Widget> _buildFingerprintSection(X509Certificate x509certificate) {
    return <Widget>[
      const SizedBox(height: 15.0),
      const Text(
        CertificateConstants.zw,
        //"FINGERPRINT",
        style: TextStyle(fontSize: 14.0, fontWeight: FontWeight.bold),
      ),
      const SizedBox(height: 5.0),
      const Text(
        CertificateConstants.zwSha256,
        // "Fingerprint SHA-256",
        style: TextStyle(fontSize: 14.0, fontWeight: FontWeight.bold),
      ),
      FutureBuilder(
        future: x509certificate.encoded != null ? sha256.bind(Stream.value(x509certificate.encoded!)).first : null,
        builder: (context, snapshot) {
          if (!snapshot.hasData || snapshot.connectionState != ConnectionState.done) {
            return const Text("");
          }

          Digest digest = snapshot.data as Digest;
          return Text(
            digest.bytes
                .map((byte) {
                  var hexValue = byte.toRadixString(16);
                  if (byte == 0 || hexValue.length == 1) {
                    hexValue = "0$hexValue";
                  }
                  return hexValue.toUpperCase();
                })
                .toList()
                .join(" "),
            style: TextStyle(fontSize: 14.0, color: titleColor),
          );
        },
      ),
      const SizedBox(height: 5.0),
      const Text(
        CertificateConstants.zwSha1,
        // "Fingerprint SHA-1",
        style: TextStyle(fontSize: 14.0, fontWeight: FontWeight.bold),
      ),
      FutureBuilder(
        future: sha1.bind(Stream.value(x509certificate.encoded!)).first,
        builder: (context, snapshot) {
          if (!snapshot.hasData || snapshot.connectionState != ConnectionState.done) {
            return const Text("");
          }

          Digest digest = snapshot.data as Digest;
          return Text(
            digest.bytes
                .map((byte) {
                  var hexValue = byte.toRadixString(16);
                  if (byte == 0 || hexValue.length == 1) {
                    hexValue = "0$hexValue";
                  }
                  return hexValue.toUpperCase();
                })
                .toList()
                .join(" "),
            style: TextStyle(fontSize: 14.0, color: titleColor),
          );
        },
      ),
    ];
  }

  List<Widget> _buildExtensionSection(X509Certificate x509certificate) {
    var extensionSection = <Widget>[
      const SizedBox(height: 15.0),
      const Text(
        CertificateConstants.extern,
        // "EXTENSIONS",
        style: TextStyle(fontSize: 14.0, fontWeight: FontWeight.bold),
      ),
    ];

    extensionSection.addAll(_buildKeyUsageSection(x509certificate));
    extensionSection.addAll(_buildBasicConstraints(x509certificate));
    extensionSection.addAll(_buildExtendedKeyUsage(x509certificate));
    extensionSection.addAll(_buildSubjectKeyIdentifier(x509certificate));
    extensionSection.addAll(_buildAuthorityKeyIdentifier(x509certificate));
    extensionSection.addAll(_buildCertificatePolicies(x509certificate));
    extensionSection.addAll(_buildCRLDistributionPoints(x509certificate));
    extensionSection.addAll(_buildAuthorityInfoAccess(x509certificate));
    extensionSection.addAll(_buildSubjectAlternativeNames(x509certificate));

    return extensionSection;
  }

  List<Widget> _buildKeyUsageSection(X509Certificate x509certificate) {
    var criticalExtensionOIDs = x509certificate.criticalExtensionOIDs;
    var keyUsage = x509certificate.keyUsage;

    var keyUsageSection = <Widget>[
      const SizedBox(height: 15.0),
      Text(
        "密钥用途 ( ${OID.keyUsage.toValue()} )",
        //"Key Usage ( ${OID.keyUsage.toValue()} )",
        style: const TextStyle(fontSize: 14.0, fontWeight: FontWeight.bold),
      ),
    ];

    var keyUsageIsCritical = criticalExtensionOIDs.map((e) => e).firstWhereOrNull((oid) => oid == OID.keyUsage.toValue()) != null
        ? CertificateConstants.yes
        : CertificateConstants.no;

    if (keyUsage.isNotEmpty) {
      for (var i = 0; i < keyUsage.length; i++) {
        if (keyUsage[i]) {
          keyUsageSection.addAll(<Widget>[
            const SizedBox(height: 5.0),
            RichText(
              text: TextSpan(
                children: [
                  TextSpan(
                    text: CertificateConstants.gj, //"Critical ",
                    style: TextStyle(fontSize: 12.0, fontWeight: FontWeight.bold, color: titleColor),
                  ),
                  TextSpan(
                    text: keyUsageIsCritical,
                    style: TextStyle(fontSize: 12.0, color: titleColor),
                  ),
                ],
              ),
            ),
            RichText(
              text: TextSpan(
                children: [
                  TextSpan(
                    text: CertificateConstants.usage, //"Usage ",
                    style: TextStyle(fontSize: 12.0, fontWeight: FontWeight.bold, color: titleColor),
                  ),
                  TextSpan(
                    text: KeyUsage.fromIndex(i)!.name(),
                    style: TextStyle(fontSize: 12.0, color: titleColor),
                  ),
                ],
              ),
            ),
          ]);
        }
      }
    } else {
      keyUsageSection.addAll(<Widget>[
        const SizedBox(height: 5.0),
        const Text(CertificateConstants.notPartOfCertificate, style: TextStyle(fontSize: 14.0)),
      ]);
    }

    return keyUsageSection;
  }

  List<Widget> _buildBasicConstraints(X509Certificate x509certificate) {
    var criticalExtensionOIDs = x509certificate.criticalExtensionOIDs;
    var basicConstraints = x509certificate.basicConstraints;

    var basicConstraintsSection = <Widget>[
      const SizedBox(height: 15.0),
      Text(
        "基本限制 ( ${OID.basicConstraints.toValue()} )",
        //"Basic Constraints ( ${OID.basicConstraints.toValue()} )",
        style: const TextStyle(fontSize: 14.0, fontWeight: FontWeight.bold),
      ),
    ];
    var basicConstraintsIsCritical =
        criticalExtensionOIDs.map((e) => e).firstWhereOrNull((oid) => oid == OID.basicConstraints.toValue()) != null
        ? CertificateConstants.yes
        : CertificateConstants.no;
    if (basicConstraints != null && basicConstraints.pathLenConstraint == -1) {
      basicConstraintsSection.addAll(<Widget>[
        const SizedBox(height: 5.0),
        RichText(
          text: TextSpan(
            children: [
              TextSpan(
                text: CertificateConstants.gj, //"Critical ",
                style: TextStyle(fontSize: 12.0, fontWeight: FontWeight.bold, color: titleColor),
              ),
              TextSpan(
                text: basicConstraintsIsCritical,
                style: TextStyle(fontSize: 12.0, color: titleColor),
              ),
            ],
          ),
        ),
        RichText(
          text: TextSpan(
            children: [
              TextSpan(
                text: CertificateConstants.zsbfjg, // "Certificate Authority ",
                style: TextStyle(fontSize: 12.0, fontWeight: FontWeight.bold, color: titleColor),
              ),
              TextSpan(
                text: CertificateConstants.no,
                style: TextStyle(fontSize: 12.0, color: titleColor),
              ),
            ],
          ),
        ),
      ]);
    } else {
      basicConstraintsSection.addAll(<Widget>[
        const SizedBox(height: 5.0),
        RichText(
          text: TextSpan(
            children: [
              TextSpan(
                text: CertificateConstants.gj, // "Critical ",
                style: TextStyle(fontSize: 12.0, fontWeight: FontWeight.bold, color: titleColor),
              ),
              TextSpan(
                text: basicConstraintsIsCritical,
                style: TextStyle(fontSize: 12.0, color: titleColor),
              ),
            ],
          ),
        ),
        RichText(
          text: TextSpan(
            children: [
              TextSpan(
                text: CertificateConstants.zsbfjg, // "Certificate Authority ",
                style: TextStyle(fontSize: 12.0, fontWeight: FontWeight.bold, color: titleColor),
              ),
              TextSpan(
                text: CertificateConstants.yes,
                style: TextStyle(fontSize: 12.0, color: titleColor),
              ),
            ],
          ),
        ),
        RichText(
          text: TextSpan(
            children: [
              TextSpan(
                text: CertificateConstants.ljcdxz, //"Path Length Constraints ",
                style: TextStyle(fontSize: 12.0, fontWeight: FontWeight.bold, color: titleColor),
              ),
              TextSpan(
                text: basicConstraints.toString(),
                style: TextStyle(fontSize: 12.0, color: titleColor),
              ),
            ],
          ),
        ),
      ]);
    }

    return basicConstraintsSection;
  }

  List<Widget> _buildExtendedKeyUsage(X509Certificate x509certificate) {
    var criticalExtensionOIDs = x509certificate.criticalExtensionOIDs;
    var extendedKeyUsage = x509certificate.extendedKeyUsage;

    var extendedKeyUsageSection = <Widget>[
      const SizedBox(height: 15.0),
      Text(
        "扩展密钥用法 ( ${OID.extKeyUsage.toValue()} )",
        //"Extended Key Usage ( ${OID.extKeyUsage.toValue()} )",
        style: const TextStyle(fontSize: 14.0, fontWeight: FontWeight.bold),
      ),
    ];
    var extendedKeyUsageIsCritical = criticalExtensionOIDs.map((e) => e).firstWhereOrNull((oid) => oid == OID.extKeyUsage.toValue()) != null
        ? CertificateConstants.yes
        : CertificateConstants.no;
    if (extendedKeyUsage.isNotEmpty) {
      for (var i = 0; i < extendedKeyUsage.length; i++) {
        OID oid = OID.fromValue(extendedKeyUsage[i])!;

        extendedKeyUsageSection.addAll(<Widget>[
          const SizedBox(height: 5.0),
          RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: CertificateConstants.gj, //"Critical ",
                  style: TextStyle(fontSize: 12.0, fontWeight: FontWeight.bold, color: titleColor),
                ),
                TextSpan(
                  text: extendedKeyUsageIsCritical,
                  style: TextStyle(fontSize: 12.0, color: titleColor),
                ),
              ],
            ),
          ),
          RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: "目的 #${i + 1} ", //"Purpose #${i + 1} ",
                  style: TextStyle(fontSize: 12.0, fontWeight: FontWeight.bold, color: titleColor),
                ),
                TextSpan(
                  text: "${oid.name()} ( ${oid.toValue()} )",
                  style: TextStyle(fontSize: 12.0, color: titleColor),
                ),
              ],
            ),
          ),
        ]);
      }
    } else {
      extendedKeyUsageSection.addAll(<Widget>[
        const SizedBox(height: 5.0),
        const Text(CertificateConstants.notPartOfCertificate, style: TextStyle(fontSize: 14.0)),
      ]);
    }

    return extendedKeyUsageSection;
  }

  List<Widget> _buildSubjectKeyIdentifier(X509Certificate x509certificate) {
    var criticalExtensionOIDs = x509certificate.criticalExtensionOIDs;
    var subjectKeyIdentifier = x509certificate.subjectKeyIdentifier;

    var subjectKeyIdentifierSection = <Widget>[
      const SizedBox(height: 15.0),
      Text(
        "主题密钥标识符 ( ${OID.subjectKeyIdentifier.toValue()} )",
        // "Subject Key Identifier ( ${OID.subjectKeyIdentifier.toValue()} )",
        style: const TextStyle(fontSize: 14.0, fontWeight: FontWeight.bold),
      ),
    ];
    var subjectKeyIdentifierIsCritical =
        criticalExtensionOIDs.map((e) => e).firstWhereOrNull((oid) => oid == OID.subjectKeyIdentifier.toValue()) != null
        ? CertificateConstants.yes
        : CertificateConstants.no;
    if (subjectKeyIdentifier?.value != null && subjectKeyIdentifier!.value!.isNotEmpty) {
      var subjectKeyIdentifierToHexValue = subjectKeyIdentifier.value!
          .map((byte) {
            var hexValue = byte.toRadixString(16);
            if (byte == 0 || hexValue.length == 1) {
              hexValue = "0$hexValue";
            }
            return hexValue.toUpperCase();
          })
          .toList()
          .join(" ");

      subjectKeyIdentifierSection.addAll(<Widget>[
        const SizedBox(height: 5.0),
        RichText(
          text: TextSpan(
            children: [
              TextSpan(
                text: CertificateConstants.gj, //"Critical ",
                style: TextStyle(fontSize: 12.0, fontWeight: FontWeight.bold, color: titleColor),
              ),
              TextSpan(
                text: subjectKeyIdentifierIsCritical,
                style: TextStyle(fontSize: 12.0, color: titleColor),
              ),
            ],
          ),
        ),
        RichText(
          text: TextSpan(
            children: [
              TextSpan(
                text: CertificateConstants.keyid, //"Key ID ",
                style: TextStyle(fontSize: 12.0, fontWeight: FontWeight.bold, color: titleColor),
              ),
              TextSpan(
                text: subjectKeyIdentifierToHexValue,
                style: TextStyle(fontSize: 12.0, color: titleColor),
              ),
            ],
          ),
        ),
      ]);
    } else {
      subjectKeyIdentifierSection.addAll(<Widget>[
        const SizedBox(height: 5.0),
        const Text(CertificateConstants.notPartOfCertificate, style: TextStyle(fontSize: 14.0)),
      ]);
    }

    return subjectKeyIdentifierSection;
  }

  List<Widget> _buildAuthorityKeyIdentifier(X509Certificate x509certificate) {
    var criticalExtensionOIDs = x509certificate.criticalExtensionOIDs;
    var authorityKeyIdentifier = x509certificate.authorityKeyIdentifier;

    var authorityKeyIdentifierSection = <Widget>[
      const SizedBox(height: 15.0),
      Text(
        "授权密钥标识符 ( ${OID.authorityKeyIdentifier.toValue()} )",
        //"Authority Key Identifier ( ${OID.authorityKeyIdentifier.toValue()} )",
        style: const TextStyle(fontSize: 14.0, fontWeight: FontWeight.bold),
      ),
    ];
    var authorityKeyIdentifierIsCritical =
        criticalExtensionOIDs.map((e) => e).firstWhereOrNull((oid) => oid == OID.authorityKeyIdentifier.toValue()) != null
        ? CertificateConstants.yes
        : CertificateConstants.no;
    if (authorityKeyIdentifier?.keyIdentifier != null && authorityKeyIdentifier!.keyIdentifier!.isNotEmpty) {
      var authorityKeyIdentifierToHexValue = authorityKeyIdentifier.keyIdentifier!
          .map((byte) {
            var hexValue = byte.toRadixString(16);
            if (byte == 0 || hexValue.length == 1) {
              hexValue = "0$hexValue";
            }
            return hexValue.toUpperCase();
          })
          .toList()
          .join(" ");

      authorityKeyIdentifierSection.addAll(<Widget>[
        const SizedBox(height: 5.0),
        RichText(
          text: TextSpan(
            children: [
              TextSpan(
                text: CertificateConstants.gj, //"Critical ",
                style: TextStyle(fontSize: 12.0, fontWeight: FontWeight.bold, color: titleColor),
              ),
              TextSpan(
                text: authorityKeyIdentifierIsCritical,
                style: TextStyle(fontSize: 12.0, color: titleColor),
              ),
            ],
          ),
        ),
        RichText(
          text: TextSpan(
            children: [
              TextSpan(
                text: CertificateConstants.keyid, //"Key ID ",
                style: TextStyle(fontSize: 12.0, fontWeight: FontWeight.bold, color: titleColor),
              ),
              TextSpan(
                text: authorityKeyIdentifierToHexValue,
                style: TextStyle(fontSize: 12.0, color: titleColor),
              ),
            ],
          ),
        ),
      ]);
    } else {
      authorityKeyIdentifierSection.addAll(<Widget>[
        const SizedBox(height: 5.0),
        const Text(CertificateConstants.notPartOfCertificate, style: TextStyle(fontSize: 14.0)),
      ]);
    }

    return authorityKeyIdentifierSection;
  }

  List<Widget> _buildCertificatePolicies(X509Certificate x509certificate) {
    var criticalExtensionOIDs = x509certificate.criticalExtensionOIDs;
    var certificatePolicies = x509certificate.certificatePolicies;

    var certificatePoliciesIsCritical =
        criticalExtensionOIDs.map((e) => e).firstWhereOrNull((oid) => oid == OID.extKeyUsage.toValue()) != null
        ? CertificateConstants.yes
        : CertificateConstants.no;

    var certificatePoliciesSection = <Widget>[
      const SizedBox(height: 15.0),
      Text(
        "证书策略 ( ${OID.certificatePolicies.toValue()} )",

        // "Certificate Policies ( ${OID.certificatePolicies.toValue()} )",
        style: const TextStyle(fontSize: 14.0, fontWeight: FontWeight.bold),
      ),
      const SizedBox(height: 5.0),
      RichText(
        text: TextSpan(
          children: [
            TextSpan(
              text: CertificateConstants.gj, //"Critical ",
              style: TextStyle(fontSize: 12.0, fontWeight: FontWeight.bold, color: titleColor),
            ),
            TextSpan(
              text: certificatePoliciesIsCritical,
              style: TextStyle(fontSize: 12.0, color: titleColor),
            ),
          ],
        ),
      ),
    ];

    if (certificatePolicies?.policies != null && certificatePolicies!.policies!.isNotEmpty) {
      for (var i = 0; i < certificatePolicies.policies!.length; i++) {
        OID? oid = OID.fromValue(certificatePolicies.policies![i].oid);

        certificatePoliciesSection.addAll(<Widget>[
          RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: "策略ID ${i + 1}", // "ID policy num. ${i + 1} ",
                  style: TextStyle(fontSize: 12.0, fontWeight: FontWeight.bold, color: titleColor),
                ),
                TextSpan(
                  text: (oid != null) ? "${oid.name()} ( ${oid.toValue()} )" : "( ${certificatePolicies.policies![i].oid} )",
                  style: TextStyle(fontSize: 12.0, color: titleColor),
                ),
              ],
            ),
          ),
        ]);
      }
    } else {
      certificatePoliciesSection.addAll(<Widget>[
        const SizedBox(height: 5.0),
        const Text(CertificateConstants.notPartOfCertificate, style: TextStyle(fontSize: 14.0)),
      ]);
    }

    return certificatePoliciesSection;
  }

  List<Widget> _buildCRLDistributionPoints(X509Certificate x509certificate) {
    var criticalExtensionOIDs = x509certificate.criticalExtensionOIDs;
    var cRLDistributionPoints = x509certificate.cRLDistributionPoints;

    var cRLDistributionPointsIsCritical =
        criticalExtensionOIDs.map((e) => e).firstWhereOrNull((oid) => oid == OID.cRLDistributionPoints.toValue()) != null
        ? CertificateConstants.yes
        : CertificateConstants.no;

    var cRLDistributionPointsSection = <Widget>[
      const SizedBox(height: 15.0),
      Text(
        "CRL Distribution Points ( ${OID.cRLDistributionPoints.toValue()} )",
        // "CRL Distribution Points ( ${OID.cRLDistributionPoints.toValue()} )",
        style: const TextStyle(fontSize: 14.0, fontWeight: FontWeight.bold),
      ),
      const SizedBox(height: 5.0),
      RichText(
        text: TextSpan(
          children: [
            TextSpan(
              text: CertificateConstants.gj, //"Critical ",
              style: TextStyle(fontSize: 12.0, fontWeight: FontWeight.bold, color: titleColor),
            ),
            TextSpan(
              text: cRLDistributionPointsIsCritical,
              style: TextStyle(fontSize: 12.0, color: titleColor),
            ),
          ],
        ),
      ),
    ];

    if (cRLDistributionPoints?.crls != null && cRLDistributionPoints!.crls!.isNotEmpty) {
      for (var i = 0; i < cRLDistributionPoints.crls!.length; i++) {
        cRLDistributionPointsSection.addAll(<Widget>[
          RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: CertificateConstants.uri,
                  style: TextStyle(fontSize: 12.0, fontWeight: FontWeight.bold, color: titleColor),
                ),
                TextSpan(
                  text: cRLDistributionPoints.crls![i],
                  style: const TextStyle(fontSize: 12.0, color: Colors.blue),
                  recognizer: TapGestureRecognizer()
                    ..onTap = () async {
                      final crlUrl = cRLDistributionPoints.crls![i];
                      try {
                        await downloadCertificateFile(crlUrl);
                        // Directory? directory =
                        //     await getExternalStorageDirectory();
                        // await FlutterDownloader.enqueue(
                        //   url: crlUrl,
                        //   savedDir: directory!.path,
                        //   showNotification: true,
                        //   // show download progress in status bar (for Android)
                        //   openFileFromNotification:
                        //       true, // click on notification to open downloaded file (for Android)
                        // );
                      } catch (e) {
                        final crlUri = Uri.tryParse(crlUrl);
                        if (crlUri != null && await canLaunchUrl(crlUri)) {
                          launchUrl(crlUri);
                        }
                      }
                    },
                ),
              ],
            ),
          ),
        ]);
      }
    } else {
      cRLDistributionPointsSection.addAll(<Widget>[
        const SizedBox(height: 5.0),
        const Text(CertificateConstants.notPartOfCertificate, style: TextStyle(fontSize: 14.0)),
      ]);
    }

    return cRLDistributionPointsSection;
  }

  List<Widget> _buildAuthorityInfoAccess(X509Certificate x509certificate) {
    var criticalExtensionOIDs = x509certificate.criticalExtensionOIDs;
    var authorityInfoAccess = x509certificate.authorityInfoAccess;

    var authorityInfoAccessIsCritical =
        criticalExtensionOIDs.map((e) => e).firstWhereOrNull((oid) => oid == OID.authorityInfoAccess.toValue()) != null
        ? CertificateConstants.yes
        : CertificateConstants.no;

    var authorityInfoAccessSection = <Widget>[
      const SizedBox(height: 15.0),
      Text(
        "权限信息访问 ( ${OID.authorityInfoAccess.toValue()} )",
        //"Authority Info Access ( ${OID.authorityInfoAccess.toValue()} )",
        style: const TextStyle(fontSize: 14.0, fontWeight: FontWeight.bold),
      ),
      const SizedBox(height: 5.0),
      RichText(
        text: TextSpan(
          children: [
            TextSpan(
              text: CertificateConstants.gj, //"Critical ",
              style: TextStyle(fontSize: 12.0, fontWeight: FontWeight.bold, color: titleColor),
            ),
            TextSpan(
              text: authorityInfoAccessIsCritical,
              style: TextStyle(fontSize: 12.0, color: titleColor),
            ),
          ],
        ),
      ),
    ];

    if (authorityInfoAccess?.infoAccess != null && authorityInfoAccess!.infoAccess!.isNotEmpty) {
      for (var i = 0; i < authorityInfoAccess.infoAccess!.length; i++) {
        var infoAccess = authorityInfoAccess.infoAccess![i];
        var value = infoAccess.location;
        var oid = OID.fromValue(infoAccess.method);

        authorityInfoAccessSection.addAll(<Widget>[
          RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: "方法 #${i + 1} ", // "Method #${i + 1} ",
                  style: TextStyle(fontSize: 12.0, fontWeight: FontWeight.bold, color: titleColor),
                ),
                TextSpan(
                  text: oid != null ? "${oid.name()} ( ${oid.toValue()} )" : infoAccess.method,
                  style: TextStyle(fontSize: 12.0, color: titleColor),
                ),
              ],
            ),
          ),
          RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: CertificateConstants.uri,
                  style: TextStyle(fontSize: 12.0, fontWeight: FontWeight.bold, color: titleColor),
                ),
                TextSpan(
                  text: value,
                  style: const TextStyle(fontSize: 12.0, color: Colors.blue),
                  recognizer: TapGestureRecognizer()
                    ..onTap = () async {
                      downloadCertificateFile(value);
                      // Directory? directory =
                      //     await getExternalStorageDirectory();
                      // await FlutterDownloader.enqueue(
                      //   url: value,
                      //   savedDir: directory!.path,
                      //   showNotification: true,
                      //   // show download progress in status bar (for Android)
                      //   openFileFromNotification:
                      //       true, // click on notification to open downloaded file (for Android)
                      // );
                    },
                ),
              ],
            ),
          ),
        ]);
      }
    } else {
      authorityInfoAccessSection.addAll(<Widget>[
        const SizedBox(height: 5.0),
        const Text(CertificateConstants.notPartOfCertificate, style: TextStyle(fontSize: 14.0)),
      ]);
    }

    return authorityInfoAccessSection;
  }

  List<Widget> _buildSubjectAlternativeNames(X509Certificate x509certificate) {
    var criticalExtensionOIDs = x509certificate.criticalExtensionOIDs;
    var subjectAlternativeNames = x509certificate.subjectAlternativeNames;

    var subjectAlternativeNamesSection = <Widget>[
      const SizedBox(height: 15.0),
      Text(
        "主题备选名称 ( ${OID.subjectAltName.toValue()} )",
        //"Subject Alternative Names ( ${OID.subjectAltName.toValue()} )",
        style: const TextStyle(fontSize: 14.0, fontWeight: FontWeight.bold),
      ),
    ];
    var subjectAlternativeNamesIsCritical =
        criticalExtensionOIDs.map((e) => e).firstWhereOrNull((oid) => oid == OID.subjectAltName.toValue()) != null
        ? CertificateConstants.yes
        : CertificateConstants.no;
    if (subjectAlternativeNames.isNotEmpty) {
      subjectAlternativeNamesSection.addAll(<Widget>[
        const SizedBox(height: 5.0),
        RichText(
          text: TextSpan(
            children: [
              TextSpan(
                text: CertificateConstants.gj, // "Critical ",
                style: TextStyle(fontSize: 12.0, fontWeight: FontWeight.bold, color: titleColor),
              ),
              TextSpan(
                text: subjectAlternativeNamesIsCritical,
                style: TextStyle(fontSize: 12.0, color: titleColor),
              ),
            ],
          ),
        ),
      ]);
      for (var subjectAlternativeName in subjectAlternativeNames) {
        subjectAlternativeNamesSection.addAll(<Widget>[
          const SizedBox(height: 5.0),
          RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: CertificateConstants.dnsName, // "DNS Name ",
                  style: TextStyle(fontSize: 12.0, fontWeight: FontWeight.bold, color: titleColor),
                ),
                TextSpan(
                  text: subjectAlternativeName,
                  style: TextStyle(fontSize: 12.0, color: titleColor),
                ),
              ],
            ),
          ),
        ]);
      }
    } else {
      subjectAlternativeNamesSection.addAll(<Widget>[
        const SizedBox(height: 5.0),
        const Text(CertificateConstants.notPartOfCertificate, style: TextStyle(fontSize: 14.0)),
      ]);
    }

    return subjectAlternativeNamesSection;
  }

  //macos /Users/cjxy/Library/Containers/com.zorro.chiphell/Data/Downloads/SectigoPublicServerAuthenticationCADVE36.crt
  Future<void> downloadCertificateFile(String url) async {
    DownloadFile.downloadHttpFile(
      url,
      callback: (result, other, success) {
        if (success && (result != null)) {
          Toast.toastAtBottom(context, result);
        }
      },
    );
  }
}
