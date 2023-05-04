import 'dart:convert';
import 'dart:developer';

export 'dart:convert';

Future<void> debugLog(Object? Function() message, {String? name,}) async {
  log('${message()}', name: name ?? '',);
}

Future<void> jsonLog(Map<String, dynamic> Function() builder, {String? name,}) async {
  debugLog(
    () => const JsonEncoder.withIndent('\t',).convert(builder(),),
    name: name,
  );
}

String jsonEncodePretty(Object object,) {
  return const JsonEncoder.withIndent('\t',).convert(object,);
}