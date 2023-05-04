import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:secure_storage_tester/src/alert_util.dart';
import 'package:uuid/uuid.dart';

import 'log_util.dart';

part 'pages/android_options.dart';
part 'pages/ios_options.dart';

class TestHomePage extends StatefulWidget {

  const TestHomePage();

  @override
  State<TestHomePage> createState() => _TestHomePageState();
}

class _TestHomePageState extends State<TestHomePage> {

  @override
  void initState() {
    super.initState();
    _keyNameController.text = 'x-my-secure-data';
    _dataController.text = const Uuid().v1();
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: const Text('Secure Storage Tester',),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0,),
        child: Column(
          children: [
            TextField(
              controller: _keyNameController,
              decoration: const InputDecoration(
                labelText: 'Key Name',
                helperText: '(No need to edit)',
              ),
            ),
            TextField(
              controller: _dataController,
              decoration: InputDecoration(
                labelText: 'Data',
                suffixIcon: IconButton(
                  onPressed: _generateRandomData,
                  icon: const Icon(Icons.edit_note,),
                ),
              ),
            ),
            ValueListenableBuilder(
              valueListenable: _error,
              builder: (_, err, __,) {
                if (err == null) {
                  return const SizedBox.shrink();
                }
                return Padding(
                  padding: const EdgeInsets.all(16.0,),
                  child: Text(
                    '$err',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.red,
                    ),
                  ),
                );
              },
            ),
            ValueListenableBuilder(
              valueListenable: _stackTrace,
              builder: (_, stackTrace, __) {
                if (stackTrace == null) {
                  return const SizedBox.shrink();
                }
                return Padding(
                  padding: const EdgeInsets.all(12.0,),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        stackTrace,
                        style: const TextStyle(
                          color: Colors.red,
                        ),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          Clipboard.setData(
                            ClipboardData(
                              text: stackTrace,
                            ),
                          );
                        },
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: const [
                            Icon(Icons.copy,),
                            SizedBox(width: 8.0,),
                            Text('Copy Stacktrace',),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
            const Divider(),
            if (Platform.isAndroid)
              _AndroidOptions(
                onOptionSet: (_) => _testSave(aOptions: _,),
              )
            else if (Platform.isIOS)
              _IosOptions(
                onOptionSet: (_) => _testSave(iOptions: _,),
              ),
            const Divider(),
            const SizedBox(height: 24.0,),
            ElevatedButton(
              onPressed: _testRead,
              child: const Text('Read',),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
              ),
              onPressed: _testDelete,
              child: const Text('Delete',),
            ),
          ],
        ),
      ),
    );
  }

  late final _dataController = TextEditingController();
  late final _keyNameController = TextEditingController();

  late final _error = ValueNotifier<Object?>(null,);
  late final _stackTrace = ValueNotifier<String?>(null,);

  void _generateRandomData() {
    _dataController.text = const Uuid().v1();
  }

  Future<void> _testSave({AndroidOptions? aOptions, IOSOptions? iOptions,}) async {
    _error.value = null;
    _stackTrace.value = null;
    final storage = FlutterSecureStorage(
      aOptions: aOptions ?? AndroidOptions.defaultOptions,
      iOptions: iOptions ?? IOSOptions.defaultOptions,
    );
    final key = _keyNameController.text;
    final data = _dataController.text;
    try {
      debugLog(
        () => 'Writing $data to $key',
        name: '$runtimeType.testSave',
      );
      await storage.write(key: key, value: data,);
    } catch (_) {
      _error.value = _ is PlatformException
          ? '${_.runtimeType}(code: ${_.code}, message: ${_.message})'
          : _.runtimeType;
      _stackTrace.value = _ is Error
          ? _.stackTrace.toString() : _ is PlatformException
          ? _.stacktrace : null;
    } finally {
      _storage = storage;
    }
  }

  void _alertNotInitialized() {
    showAdaptiveDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Error',),
        content: const Text('Not initialized yet',),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(_,).pop(),
            child: const Text('Close',),
          ),
        ],
      ),
      iosBuilder: (_) => CupertinoAlertDialog(
        title: const Text('Error',),
        content: const Text('Not initialized yet',),
        actions: [
          CupertinoButton(
            onPressed: () => Navigator.of(_,).pop(),
            child: const Text('Close',),
          ),
        ],
      ),
    );
  }

  Future<void> _testRead() async {
    final storage = _storage;
    if (storage == null) {
      _alertNotInitialized();
      return;
    }
    final key = _keyNameController.text;

    showAdaptiveDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: const Text('Read Result',),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              FutureBuilder(
                future: storage.read(key: key,),
                builder: (_, snapshot,) {
                  return Center(
                    child: Text(
                      '$key: ${snapshot.data}',
                    ),
                  );
                },
              ),
              const SizedBox(height: 8.0,),
              const Text('Android Config:',),
              Text(
                jsonEncodePretty(
                  storage.aOptions.toMap(),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(_,).pop(),
              child: const Text('Close',),
            ),
          ],
        );
      },
      iosBuilder: (_) => CupertinoAlertDialog(
        title: const Text('Read Result',),
        content: FutureBuilder(
          future: storage.read(key: key,),
          builder: (_, snapshot,) {
            return Text(
              '$key: ${snapshot.data}',
            );
          },
        ),
        actions: [
          CupertinoButton(
            onPressed: () => Navigator.of(_,).pop(),
            child: const Text('Close',),
          ),
        ],
      ),
    );
  }

  Future<void> _testDelete() async {
    final storage = _storage;
    if (storage == null) {
      _alertNotInitialized();
      return;
    }
    final key = _keyNameController.text;
    storage.delete(
      key: key,
    );
  }

  FlutterSecureStorage? _storage;

  @override
  void dispose() {
    _dataController.dispose();
    _keyNameController.dispose();
    super.dispose();
  }
}