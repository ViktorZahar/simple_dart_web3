import 'dart:html';

import 'package:simple_dart_web3/simple_dart_web3.dart';

Future<void> main() async {
  final addresses = [
    '0x231314b95736f35dbd7b7e6e3c9c6ef0ffb32a4b',
    '0x89620c8228d50717aab81fea01acb196ab5af179'
  ];
  final web3Wrapper = Web3Wrapper(
      52,
      '0x949f41e8a6197f2a19854f813fd361bab9aa7d2d',
      'https://bsc-dataseed1.binance.org:443',
      'binance-smart-chain');
  final res = await web3Wrapper.getBalances(addresses);
  final body = querySelector('body');
  if (body != null) {
    res.forEach((resultRow) {
      body.children.add(DivElement()..text = resultRow.toString());
    });
  }
}
