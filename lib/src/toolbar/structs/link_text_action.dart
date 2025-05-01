import 'package:flutter/material.dart';

@immutable
class LinkTextAction {
  const LinkTextAction({required this.builder});

  final Widget Function(
    String labelText,
    String hintText,
    void Function(String)? onChanged,
    TextEditingController? controller,
    TextInputAction? textInputAction,
    Iterable<String>? autofillHints,
  ) builder;
}
