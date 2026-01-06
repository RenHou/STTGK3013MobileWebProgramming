import 'package:flutter/material.dart';
import 'package:pawpal/myconfig.dart';

import 'package:pawpal/user.dart';
import 'package:webview_flutter/webview_flutter.dart';

class PaymentPage extends StatefulWidget {
  final User? user;
  final int topUpCents;
  const PaymentPage({super.key, required this.user, required this.topUpCents});

  @override
  State<PaymentPage> createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> {
  late WebViewController _webcontroller;
  late double screenHeight, screenWidth, resWidth;
  late String userName, userEmail, userPhone, userID;

  @override
  void initState() {
    userEmail = widget.user!.email.toString();
    userPhone = widget.user!.phone.toString();
    userName = widget.user!.name.toString();
    userID = widget.user!.userId.toString();
    final int amountToPay = widget.topUpCents;

    super.initState();
    _webcontroller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..loadRequest(
        Uri.parse(
          '${Myconfig.baseURL}/pawpal/api/payment.php?email=$userEmail&phone=$userPhone&userid=$userID&name=$userName&amount=$amountToPay',
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Payment"),
        backgroundColor: const Color(0xFF1F3C88),
      ),
      body: WebViewWidget(controller: _webcontroller),
    );
  }
}
