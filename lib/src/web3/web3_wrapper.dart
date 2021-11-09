@JS()
library web3wrapper;

import 'dart:convert';
import 'dart:js_util';

import 'package:js/js.dart';

import 'abi.dart';

class Call {
  String address = '';
  String name = '';
  List<dynamic> abi = [];
  List<dynamic> params = [];

  Map toJson() => {
        'address': address,
        'name': name,
        'abi': abi,
        'params': params,
      };
}

@JS('JSON.stringify')
// ignore: avoid_annotating_with_dynamic
external String stringify(dynamic obj);
// ignore: type_annotate_public_apis
Map<String, dynamic> jsObjectToMap(jsObject) =>
    json.decode(stringify(jsObject));

List<Map<String, dynamic>> jsObjectToList(jsList) {
  final ret = <Map<String, dynamic>>[];
  if (jsList is List) {
    for (final jsObject in jsList) {
      ret.add(json.decode(stringify(jsObject)));
    }
  }
  return ret;
}

@JS('Web3Wrapper')
class Web3WrapperRaw {
  external factory Web3WrapperRaw(
      int netId, String multiCallAddress, String rcpAddress);

  external dynamic multicall(List<dynamic> calls);
}

class Web3Wrapper {
  Web3Wrapper(this.netId, this.multiCallAddress, this.rcpAddress) {
    _web3wrapperRaw = Web3WrapperRaw(netId, multiCallAddress, rcpAddress);
  }

  bool debug = false;

  late Web3WrapperRaw _web3wrapperRaw;
  late int netId;
  late String multiCallAddress;
  late String rcpAddress;

  Future<List<dynamic>> multicall(List<Call> calls,
      {batchSize = 700, maxThreads = 8}) async {
    if (calls.isEmpty) {
      return <String>[];
    }
    final callResult = [];
    final jsfyCalls = calls.map((call) => jsify(call.toJson())).toList();
    try {
      final chunks = groupByBatch(jsfyCalls, batchSize, maxThreads);
      for (final chunk in chunks) {
        final futureList = <Future>[];
        for (final batch in chunk) {
          final fut = promiseToFuture(_web3wrapperRaw.multicall(batch));
          futureList.add(fut);
        }
        final chankResult = await Future.wait(futureList);
        if (chankResult is List) {
          for (final chankResultRow in chankResult) {
            callResult.addAll(chankResultRow);
          }
        }
      }
    } catch (e) {
      print(e.toString());
      // if (debug) {
      //   for (final call in calls) {
      //     try {
      //       final callResult = await promiseToFuture(
      //           _web3wrapperRaw.multicall([jsify(call.toJson())]));
      //     } catch (e) {
      //       print('bad call ${call.address}.${call.name} ${call.params}');
      //       rethrow;
      //     }
      //   }
      //   throw Exception('too big batch size $batchSize');
      // }
      throw Exception('execution multicall error ($netId): ${e.toString()}');
    }
    if (callResult is List) {
      return callResult;
    } else {
      throw Exception('Unknown multicall result type');
    }
  }

  Future<List<List<dynamic>>> multicall2(List<List<Call>> callsList,
      {batchSize = 700}) async {
    final calls = <Call>[];
    for (final list in callsList) {
      calls.addAll(list);
    }
    final result0 = await multicall(calls, batchSize: batchSize);
    final res = <List<dynamic>>[];
    var callNum = 0;
    for (final list in callsList) {
      final resultRow = [];
      for (var i = 0; i < list.length; i++) {
        resultRow.add(result0[callNum]);
        callNum++;
      }
      res.add(resultRow);
    }
    return res;
  }

  Future<List<List<List<dynamic>>>> multicall3(List<List<List<Call>>> callsList,
      {batchSize = 700}) async {
    final calls = <Call>[];
    for (final list0 in callsList) {
      for (final list1 in list0) {
        calls.addAll(list1);
      }
    }
    final result0 = await multicall(calls, batchSize: batchSize);
    final res = <List<List<dynamic>>>[];
    var callNum = 0;
    for (final list0 in callsList) {
      final resultRow0 = <List<dynamic>>[];
      for (final list1 in list0) {
        final resultRow1 = [];
        for (var i = 0; i < list1.length; i++) {
          resultRow1.add(result0[callNum]);
          callNum++;
        }
        resultRow0.add(resultRow1);
      }
      res.add(resultRow0);
    }
    return res;
  }

  Future<List<BigInt>> getBalances(List<String> addresses) async {
    final calls = addresses
        .map((address) => Call()
          ..address = multiCallAddress
          ..name = 'getEthBalance'
          ..params = [address]
          ..abi = multiCallGetEthBalance)
        .toList();
    final res = await multicall(calls);
    return res.map((e) => BigInt.parse(e[0].toString())).toList();
  }
}

List<List<List<dynamic>>> groupByBatch(
    List<dynamic> calls, int batchSize, int maxThreads) {
  final chanks = <List<dynamic>>[];
  for (var i = 0; i < calls.length; i += batchSize) {
    var lastIdx = i + batchSize;
    if (lastIdx > calls.length) {
      lastIdx = calls.length;
    }
    chanks.add(calls.getRange(i, lastIdx).toList());
  }
  final ret = <List<List<dynamic>>>[];
  for (var j = 0; j < chanks.length; j += maxThreads) {
    var lastIdx = j + maxThreads;
    if (lastIdx > chanks.length) {
      lastIdx = chanks.length;
    }
    ret.add(chanks.getRange(j, lastIdx).toList());
  }
  return ret;
}
