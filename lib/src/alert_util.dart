import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

export 'package:flutter/cupertino.dart';

Future<T?> showAdaptiveDialog<T>({
  required BuildContext context,
  required WidgetBuilder builder,
  WidgetBuilder? iosBuilder,
}) {
  if (Platform.isIOS) {
    return showCupertinoDialog<T>(
      context: context,
      builder: iosBuilder ?? builder,
    );
  }
  return showDialog<T>(
    context: context,
    builder: builder,
  );
}