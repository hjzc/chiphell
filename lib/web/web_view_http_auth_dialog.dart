import 'package:chiphell/common/constants.dart';
import 'package:chiphell/view/widget_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

class WebViewHttpAuthDialog extends StatefulWidget {
  const WebViewHttpAuthDialog({
    super.key,
    required this.challenge,
    required this.onCall,
  });

  final URLAuthenticationChallenge challenge;
  final void Function(HttpAuthResponse response) onCall;

  @override
  State<WebViewHttpAuthDialog> createState() => _WebViewHttpAuthDialogState();
}

class _WebViewHttpAuthDialogState extends State<WebViewHttpAuthDialog> {
  final TextEditingController _httpAuthUsernameController =
      TextEditingController();
  final TextEditingController _httpAuthPasswordController =
      TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _httpAuthUsernameController.dispose();
    _httpAuthPasswordController.dispose();
    super.dispose();
  }

  void _callBackResult(bool isOk) {
    widget.onCall(
      HttpAuthResponse(
        username: _httpAuthUsernameController.text.trim(),
        password: _httpAuthPasswordController.text,
        action: isOk
            ? HttpAuthResponseAction.PROCEED
            : HttpAuthResponseAction.CANCEL,
        permanentPersistence: true,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text(Constants.kTipLogin),
      actionsAlignment: MainAxisAlignment.spaceBetween,
      //barrierDismissible:false,
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Text(widget.challenge.protectionSpace.host),
          TextField(
            decoration: const InputDecoration(labelText: Constants.kTipUser),
            controller: _httpAuthUsernameController,
          ),
          TextField(
            decoration: const InputDecoration(labelText: Constants.kTipPwd),
            controller: _httpAuthPasswordController,
            obscureText: true,
          ),
        ],
      ),
      actions: <Widget>[
        WidgetUtils.fbCancel(
          onPressed: () {
            _callBackResult(false);
            Navigator.of(context).pop();
          },
        ),
        WidgetUtils.ebOk(
          onPressed: () {
            _callBackResult(true);
            Navigator.of(context).pop();
          },
        ),
      ],
    );
  }
}
