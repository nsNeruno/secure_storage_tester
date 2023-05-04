part of '../home.dart';

class _IosOptions extends StatefulWidget {

  const _IosOptions({this.onOptionSet,});

  @override
  State<_IosOptions> createState() => _IosOptionsState();

  final ValueChanged<IOSOptions>? onOptionSet;
}

class _IosOptionsState extends State<_IosOptions> {
  @override
  Widget build(BuildContext context) {

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 20.0,),
        const Text('Group ID (optional)',),
        CupertinoTextField(
          controller: _groupIdController,
        ),
        const SizedBox(height: 20.0,),
        const Text('Account Name (optional)',),
        CupertinoTextField(
          controller: _accountNameController,
        ),
        const SizedBox(height: 20.0,),
        Container(
          padding: const EdgeInsets.all(24.0,),
          decoration: BoxDecoration(
            border: Border.all(),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Keychain Accessibility',),
              ...KeychainAccessibility.values.map(
                (ka,) => ValueListenableBuilder(
                  valueListenable: _accessibility,
                  builder: (_, acc, __) => RadioListTile(
                    value: ka,
                    groupValue: acc,
                    onChanged: (_) => _accessibility.value = _!,
                    title: Text(describeEnum(ka,),),
                  ),
                ),
              ),
            ],
          ),
        ),
        ValueListenableBuilder(
          valueListenable: _synchronizable,
          builder: (_, sync, __,) => SwitchListTile.adaptive(
            value: sync,
            onChanged: (_) => _synchronizable.value = _,
            title: const Text('Synchronizable',),
          ),
        ),
        Center(
          child: CupertinoButton(
            onPressed: _submit,
            child: const Text('Submit',),
          ),
        ),
      ],
    );
  }

  late final _groupIdController = TextEditingController();
  late final _accountNameController = TextEditingController();

  late final _accessibility = ValueNotifier(KeychainAccessibility.unlocked,);
  late final _synchronizable = ValueNotifier(false,);

  void _submit() {
    final groupId = _groupIdController.text.trim();
    final accountName = _accountNameController.text.trim();
    widget.onOptionSet?.call(
      IOSOptions(
        groupId: groupId.isNotEmpty ? groupId : null,
        accountName: accountName.isNotEmpty ? accountName : null,
        accessibility: _accessibility.value,
        synchronizable: _synchronizable.value,
      ),
    );
  }
}