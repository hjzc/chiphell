import 'package:chiphell/web/web_view_helper.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:provider/provider.dart';
import '../../theme/theme_provider.dart';
import './custom_popup_dialog.dart';
import 'certificate_constants.dart';
import 'certificates_info_popup.dart';

class UrlInfoPopup extends StatefulWidget {
  final WebUri url;
  final bool isSecure;
  final WebViewHelper? help;
  final CustomPopupDialogPageRoute route;
  final Duration transitionDuration;
  final Function()? onWebViewTabSettingsClicked;

  const UrlInfoPopup({
    super.key,
    required this.url,
    required this.isSecure,
    required this.help,
    required this.route,
    required this.transitionDuration,
    this.onWebViewTabSettingsClicked,
  });

  @override
  State<UrlInfoPopup> createState() => _UrlInfoPopupState();
}

class _UrlInfoPopupState extends State<UrlInfoPopup> {
  //"Your connection to this website is not protected";
  var text1 = CertificateConstants.noSecure;
  var text2 = CertificateConstants.noSecureDetail;
  //
  //     "You should not enter sensitive data on this site (e.g. passwords or credit cards) because they could be intercepted by malicious users.";
  bool isdark = ThemeProvider().isDarkThreme();
  var showFullInfoUrl = false;

  late TextStyle defaultTextSpanStyle;

  @override
  void initState() {
    super.initState();
    defaultTextSpanStyle = TextStyle(color: Colors.black54, fontSize: 12.5);
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.isSecure) {
      // "Your connection is protected";
      text1 = CertificateConstants.secure;
      text2 = CertificateConstants.secureDetail;
      // "Your sensitive data (e.g. passwords or credit card numbers) remains private when it is sent to this site.";
    }
    var url = widget.url;
    var themeProvider = Provider.of<ThemeProvider>(context, listen: true);
    Color titleColor = themeProvider.isDarkThreme() ? Colors.white54 : Colors.black54;

    defaultTextSpanStyle = TextStyle(color: titleColor, fontSize: 12.5);

    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          StatefulBuilder(
            builder: (context, setState) {
              return GestureDetector(
                onTap: () {
                  setState(() {
                    showFullInfoUrl = !showFullInfoUrl;
                  });
                },
                child: Container(
                  padding: const EdgeInsets.only(bottom: 15.0),
                  constraints: const BoxConstraints(maxHeight: 100.0),
                  child: RichText(
                    maxLines: showFullInfoUrl ? null : 2,
                    overflow: showFullInfoUrl ? TextOverflow.clip : TextOverflow.ellipsis,
                    text: TextSpan(
                      children: <TextSpan>[
                        TextSpan(
                          text: url.scheme,
                          style: defaultTextSpanStyle.copyWith(
                            color: widget.isSecure ? Colors.green : (themeProvider.isDarkThreme() ? Colors.white54 : Colors.black54),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        TextSpan(text: url.toString() == "about:blank" ? ':' : '://', style: defaultTextSpanStyle),
                        TextSpan(
                          text: url.host,
                          style: defaultTextSpanStyle.copyWith(color: (themeProvider.isDarkThreme() ? Colors.white : Colors.black)),
                        ),
                        TextSpan(text: url.path, style: defaultTextSpanStyle),
                        TextSpan(text: url.query, style: defaultTextSpanStyle),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
          Container(
            // color: bgColor,
            padding: const EdgeInsets.only(bottom: 10.0),
            child: Text(text1, style: const TextStyle(fontSize: 16.0)),
          ),
          RichText(
            text: TextSpan(
              style: TextStyle(fontSize: 12.0, color: titleColor),
              children: [
                TextSpan(text: "$text2 "),
                TextSpan(
                  text: "详细", //"Details",
                  style: const TextStyle(color: Colors.blue),
                  recognizer: TapGestureRecognizer()
                    ..onTap = () async {
                      Navigator.maybePop(context);
                      await widget.route.popped;
                      await Future.delayed(Duration(milliseconds: widget.transitionDuration.inMilliseconds - 400));
                      var uri = widget.url;
                      InAppWebViewController? ctl = widget.help!.webViewController;
                      if (ctl != null && context.mounted) {
                        showDialog(
                          context: context,
                          builder: (context) {
                            return CertificateInfoPopup(url: uri, webViewController: ctl);
                          },
                        );
                      }
                    },
                ),
              ],
            ),
          ),
          //const SizedBox(height: 30.0),
          // Align(
          //   alignment: Alignment.centerRight,
          //   child: ElevatedButton(
          //     child: const Text("WebView Tab Settings"),
          //     onPressed: () async {
          //       Navigator.maybePop(context);

          //       await widget.route.popped;

          //       Future.delayed(widget.transitionDuration, () {
          //         if (widget.onWebViewTabSettingsClicked != null) {
          //           widget.onWebViewTabSettingsClicked!();
          //         }
          //       });
          //     },
          //   ),
          // ),
        ],
      ),
    );
  }
}
