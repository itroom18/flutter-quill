import 'package:flutter/material.dart';

@immutable
class LinkUrlAction {
  const LinkUrlAction({required this.builder});

  final Widget Function(
      String labelText,
      String hintText,
      void Function(String)? onChanged,
      TextEditingController? controller,
      Iterable<String>? autofillHints,
      TextInputAction? textInputAction,
      void Function()? onEditingComplete) builder;
}
