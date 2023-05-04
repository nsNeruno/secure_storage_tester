part of '../home.dart';

class _AndroidOptions extends StatefulWidget {

  const _AndroidOptions({this.onOptionSet,});

  @override
  State<_AndroidOptions> createState() => _AndroidOptionsState();

  final ValueChanged<AndroidOptions>? onOptionSet;
}

class _AndroidOptionsState extends State<_AndroidOptions> {
  @override
  Widget build(BuildContext context) {

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ValueListenableBuilder(
            valueListenable: _encryptedSharedPreferences,
            builder: (_, useSp, __,) {
              return SwitchListTile.adaptive(
                value: useSp,
                onChanged: (_) => _encryptedSharedPreferences.value = _,
                title: const Text('Use Encrypted Shared Preferences',),
              );
            }
        ),
        ValueListenableBuilder(
          valueListenable: _resetOnError,
          builder: (_, reset, __,) {
            return SwitchListTile.adaptive(
              value: reset,
              onChanged: (_) => _resetOnError.value = _,
              title: const Text('Reset on Error',),
            );
          },
        ),
        Container(
          padding: const EdgeInsets.all(24.0,),
          decoration: BoxDecoration(
            border: Border.all(),
          ),
          width: double.infinity,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Key Cipher Algorithm'),
              ...KeyCipherAlgorithm.values.map(
                (kca) => ValueListenableBuilder(
                  valueListenable: _keyCipherAlgorithm,
                  builder: (_, alg, __,) {
                    return RadioListTile(
                      value: kca,
                      groupValue: alg,
                      onChanged: (_) => _keyCipherAlgorithm.value = _!,
                      title: Text(describeEnum(kca,),),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.all(24.0,),
          decoration: BoxDecoration(
            border: Border.all(),
          ),
          width: double.infinity,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Storage Cipher Algorithm'),
              ...StorageCipherAlgorithm.values.map(
                (kca) => ValueListenableBuilder(
                  valueListenable: _storageCipherAlgorithm,
                  builder: (_, alg, __,) {
                    return RadioListTile(
                      value: kca,
                      groupValue: alg,
                      onChanged: (_) => _storageCipherAlgorithm.value = _!,
                      title: Text(describeEnum(kca,),),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
        TextField(
          controller: _spNameController,
          decoration: const InputDecoration(
            labelText: 'Shared Preferences Name',
            hintText: 'Only when enabling Shared Preferences',
          ),
        ),
        TextField(
          controller: _prefixController,
          decoration: const InputDecoration(
            labelText: 'Shared Preferences Prefix',
            hintText: 'Only when enabling Shared Preferences',
          ),
        ),
        ElevatedButton(
          onPressed: _submit,
          child: const Text('Submit',),
        ),
      ],
    );
  }

  void _submit() {
    final useSp = _encryptedSharedPreferences.value;
    widget.onOptionSet?.call(
      AndroidOptions(
        encryptedSharedPreferences: useSp,
        resetOnError: _resetOnError.value,
        keyCipherAlgorithm: _keyCipherAlgorithm.value,
        storageCipherAlgorithm: _storageCipherAlgorithm.value,
        sharedPreferencesName: useSp ? _spNameController.text : null,
        preferencesKeyPrefix: useSp ? _prefixController.text : null,
      ),
    );
  }

  late final _encryptedSharedPreferences = ValueNotifier(false,);
  late final _resetOnError = ValueNotifier(false,);
  late final _keyCipherAlgorithm = ValueNotifier(
    KeyCipherAlgorithm.RSA_ECB_PKCS1Padding,
  );
  late final _storageCipherAlgorithm = ValueNotifier(
    StorageCipherAlgorithm.AES_CBC_PKCS7Padding,
  );

  late final _spNameController = TextEditingController(
    text: 'do-not-edit',
  );
  late final _prefixController = TextEditingController(
    text: 'x-',
  );

  @override
  void dispose() {
    _encryptedSharedPreferences.dispose();
    _resetOnError.dispose();
    _keyCipherAlgorithm.dispose();
    _storageCipherAlgorithm.dispose();
    _spNameController.dispose();
    _prefixController.dispose();
    super.dispose();
  }
}