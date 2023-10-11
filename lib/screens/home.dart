import 'dart:convert';
import 'dart:io' show Platform;
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:spm_mobile/services/api.service.dart';

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey(debugLabel: 'Scaffold');
  QRViewController? controller;

  FlutterTts flutterTts = FlutterTts();

  dynamic product;

  bool loading = false;

  List<String> scannedIds = [];

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }

  void fetchAndSetProduct(String id) async {
    if (!scannedIds.contains(id)) {
      scannedIds.add(id);
      setState(() {
        loading = true;
      });
      final response = await ProductService.getProduct(id);
      setState(() {
        loading = false;
        product = response["data"];
      });
      scaffoldKey.currentState!.openDrawer();
      await flutterTts.speak("Product Scanned. You're looking at ${product['name']}. It's price is ${product['selling_price']} rupees. More details about the product are as follows. ${product['description']}. This product is sold by"
          "${product['seller']['name']}. You can contact the seller on the number ${product['seller']['mobile']}. You can find this product in the ${product['type']} category.");
    }
  }

  void _onQRViewCreated(QRViewController controller) {
    this.controller = controller;
    controller.scannedDataStream.listen((scanData) {
      if (scanData.code == null) return;
      fetchAndSetProduct(scanData.code!);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      appBar: AppBar(
        title: const Text(
          'Scan Product',
          style: TextStyle(color: Colors.black, fontSize: 22, fontWeight: FontWeight.w600),
        ),
        backgroundColor: Colors.white,
        centerTitle: true,
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            flex: 10,
            child: Stack(
              children: [
                QRView(
                  key: qrKey,
                  onQRViewCreated: _onQRViewCreated,
                ),
                if (loading)
                  Container(
                    alignment: Alignment.center,
                    width: double.infinity,
                    height: double.infinity,
                    color: Colors.black.withOpacity(0.4),
                    child: const CircularProgressIndicator(
                      color: Colors.white,
                    ),
                  )
              ],
            ),
          ),
          const Expanded(
            flex: 1,
            child: Center(
              child: Text(
                'Scan a product tag',
                style: TextStyle(color: Colors.black, fontSize: 24, fontWeight: FontWeight.w500),
              ),
            ),
          )
        ],
      ),
      drawer: SizedBox(
        width: MediaQuery.of(context).size.width * 0.9,
        child: Drawer(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 25),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(
                    height: 80,
                  ),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.memory(
                      const Base64Decoder().convert(product != null ? product['image'].toString().split(",")[1] : ''),
                    ),
                  ),
                  const SizedBox(
                    height: 30,
                  ),
                  Text(
                    'Product Name - ${product != null ? product['name'] : ''}',
                    style: const TextStyle(color: Colors.black, fontSize: 22, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  Text(
                    'Price - LKR ${product != null ? product['selling_price'] : ''}',
                    style: const TextStyle(color: Colors.black, fontSize: 21, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  Text(
                    'Category - ${product != null ? product['type'] : ''}',
                    style: const TextStyle(color: Colors.black, fontSize: 20, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  Text(
                    'Unit - ${product != null ? product['measurement_unit'] : ''}',
                    style: const TextStyle(color: Colors.black, fontSize: 18, fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  Text(
                    'Description - ${product != null ? product['description'] : ''}',
                    style: const TextStyle(color: Colors.black, fontSize: 18, fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  Text(
                    'Seller name - ${product != null ? product['seller']['name'] : ''}',
                    style: const TextStyle(color: Colors.black, fontSize: 18, fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  Text(
                    'Seller mobile - ${product != null ? product['seller']['mobile'] : ''}',
                    style: const TextStyle(color: Colors.black, fontSize: 18, fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
