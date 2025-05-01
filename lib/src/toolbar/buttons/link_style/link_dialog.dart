@internal
@visibleForTesting
library;

import 'package:flutter/material.dart';
import 'package:meta/meta.dart';

import '../../../common/utils/link_validator.dart';
import '../../../editor/widgets/link.dart';
import '../../../l10n/extensions/localizations_ext.dart';
import '../../../rules/insert.dart';
import '../../structs/link_dialog_action.dart';
import '../../structs/link_text_action.dart';
import '../../structs/link_url_action.dart';
import '../../theme/quill_dialog_theme.dart';

class LinkDialog extends StatefulWidget {
  const LinkDialog(
      {required this.validateLink,
      this.dialogColors,
      super.key,
      this.dialogTheme,
      this.link,
      this.text,
      this.legacyLinkRegExp,
      this.action,
      this.textAction,
      this.urlAction});

  final QuillDialogTheme? dialogTheme;
  final String? link;
  final String? text;
  final List<Color>? dialogColors;
  final RegExp? legacyLinkRegExp;
  final LinkValidationCallback? validateLink;
  final LinkDialogAction? action;
  final LinkTextAction? textAction;
  final LinkUrlAction? urlAction;

  @override
  LinkDialogState createState() => LinkDialogState();
}

class LinkDialogState extends State<LinkDialog> {
  late String _link;
  late String _text;

  @Deprecated(
      'Will be removed in future-releases, please migrate to QuillToolbarLinkStyleButtonOptions.validateLink.')
  RegExp get linkRegExp {
    return widget.legacyLinkRegExp ??
        AutoFormatMultipleLinksRule.singleLineUrlRegExp;
  }

  late TextEditingController _linkController;
  late TextEditingController _textController;

  @override
  void initState() {
    super.initState();
    _link = widget.link ?? '';
    _text = widget.text ?? '';
    _linkController = TextEditingController(text: _link);
    _textController = TextEditingController(text: _text);
  }

  @override
  void dispose() {
    _linkController.dispose();
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    print(widget.dialogTheme);
    return Dialog(
        insetPadding: const EdgeInsets.all(16),
        child: IntrinsicHeight(
          child: Container(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment.center,
                  radius: 1,
                  colors: widget.dialogColors ?? [Colors.white, Colors.white],
                ),
                borderRadius: const BorderRadius.all(Radius.circular(30)),
              ),
              padding: const EdgeInsets.only(
                  left: 16, right: 16, top: 32, bottom: 60),
              child: Expanded(
                  child: SingleChildScrollView(
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minWidth: MediaQuery.of(context).size.width - 32,
                  ),
                  child: Form(
                    child: Column(
                      spacing: 16,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (widget.textAction != null)
                          widget.textAction!.builder(
                              context.loc.text,
                              context.loc.pleaseEnterTextForYourLink,
                              _textChanged,
                              _textController,
                              TextInputAction.next, const [
                            AutofillHints.name,
                            AutofillHints.url,
                          ])
                        else
                          TextFormField(
                            keyboardType: TextInputType.text,
                            style: widget.dialogTheme?.inputTextStyle,
                            decoration: InputDecoration(
                              labelText: context.loc.text,
                              hintText: context.loc.pleaseEnterTextForYourLink,
                              labelStyle: widget.dialogTheme?.labelTextStyle,
                              floatingLabelStyle:
                                  widget.dialogTheme?.labelTextStyle,
                            ),
                            autofocus: true,
                            onChanged: _textChanged,
                            controller: _textController,
                            textInputAction: TextInputAction.next,
                            autofillHints: const [
                              AutofillHints.name,
                              AutofillHints.url,
                            ],
                          ),
                        if (widget.urlAction != null)
                          widget.urlAction!.builder(
                              context.loc.link,
                              context.loc.pleaseEnterTheLinkURL,
                              _linkChanged,
                              _linkController,
                              const [AutofillHints.url],
                              TextInputAction.done, () {
                            if (!canPress()) {
                              return;
                            }
                            _applyLink();
                          })
                        else
                          TextFormField(
                            keyboardType: TextInputType.url,
                            style: widget.dialogTheme?.inputTextStyle,
                            decoration: InputDecoration(
                              labelText: context.loc.link,
                              hintText: context.loc.pleaseEnterTheLinkURL,
                              labelStyle: widget.dialogTheme?.labelTextStyle,
                              floatingLabelStyle:
                                  widget.dialogTheme?.labelTextStyle,
                            ),
                            onChanged: _linkChanged,
                            controller: _linkController,
                            textInputAction: TextInputAction.done,
                            autofillHints: const [AutofillHints.url],
                            autocorrect: false,
                            onEditingComplete: () {
                              if (!canPress()) {
                                return;
                              }
                              _applyLink();
                            },
                          ),
                        _okButton(),
                      ],
                    ),
                  ),
                ),
              ))),
        ));
  }

  Widget _okButton() {
    if (widget.action != null) {
      return widget.action!.builder(
        canPress(),
        _applyLink,
      );
    }

    return TextButton(
      onPressed: canPress() ? _applyLink : null,
      child: Text(
        context.loc.ok,
        style: widget.dialogTheme?.buttonTextStyle,
      ),
    );
  }

  bool get _isLinkValid => LinkValidator.validate(
        _link,
        customValidateLink: widget.validateLink,
        // Implemented for backward compatibility, clients should use validateLink instead.
        legacyRegex: widget.legacyLinkRegExp,
      );

  @visibleForTesting
  @internal
  bool canPress() {
    if (_text.isEmpty || _link.isEmpty) {
      return false;
    }
    return _isLinkValid;
  }

  void _linkChanged(String value) {
    setState(() {
      _link = value;
    });
  }

  void _textChanged(String value) {
    setState(() {
      _text = value;
    });
  }

  void _applyLink() {
    Navigator.pop(context, QuillTextLink(_text.trim(), _link.trim()));
  }
}
