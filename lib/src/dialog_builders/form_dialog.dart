import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class FormFieldConfig<T> {
  final String tag;
  final String label;
  final T initialValue;
  final EdgeInsets padding;
  final bool obscureText;
  final Type type;
  final String Function(String val) validator;
  final TextStyle labelStyle;
  final TextStyle fieldStyle;

  FormFieldConfig(
      {@required this.tag,
      @required this.label,
      this.initialValue,
      this.padding = EdgeInsets.zero,
      this.obscureText = false,
      this.validator,
      this.labelStyle,
      this.fieldStyle})
      : type = T;
}

class FormDialogConfig {
  final String title;
  final String header;
  final String footer;
  final List<FormFieldConfig> fields;
  final String okButtonText;
  final String cancelButtonText;
  final EdgeInsets defaultFieldPadding;
  final double labelSpacing;
  final TextStyle labelStyle;
  final TextStyle fieldStyle;
  final VoidCallback onValidationError;

  FormDialogConfig({
    this.title,
    this.header,
    this.footer,
    this.fields,
    this.defaultFieldPadding = const EdgeInsets.only(bottom: 16),
    this.okButtonText,
    this.cancelButtonText,
    this.labelSpacing = 8,
    this.fieldStyle,
    this.labelStyle,
    this.onValidationError,
  });
}

class FormDialog {
  static const String dialogId = 'FormDialog';
  static Widget build(BuildContext context, FormDialogConfig config) =>
      FormDialogWidget(
        dialogConfig: config,
      );
}

class FormDialogWidget extends StatefulWidget {
  final FormDialogConfig dialogConfig;
  const FormDialogWidget({Key key, this.dialogConfig}) : super(key: key);

  @override
  _FormDialogWidgetState createState() => _FormDialogWidgetState();
}

class _FormDialogWidgetState extends State<FormDialogWidget> {
  final Map<String, Object> _formResults = <String, Object>{};

  GlobalKey<FormState> _formKey = GlobalKey();

  Widget _fieldFactory(
      FormFieldConfig<Object> fieldConfig, FormDialogConfig dialogConfig) {
    Widget field;
    switch (fieldConfig.type) {
      case String:
        field = TextFormField(
          initialValue: fieldConfig.initialValue as String ?? '',
          style: fieldConfig.fieldStyle ?? dialogConfig.fieldStyle,
          obscureText: fieldConfig.obscureText ?? false,
          onSaved: (s) => _formResults[fieldConfig.tag] = s,
          validator: fieldConfig.validator,
        );
        break;
      case int:
        field = TextFormField(
          initialValue: fieldConfig.initialValue?.toString() ?? '',
          style: fieldConfig.fieldStyle ?? dialogConfig.fieldStyle,
          obscureText: fieldConfig.obscureText ?? false,
          keyboardType: TextInputType.numberWithOptions(decimal: false),
          onSaved: (s) => _formResults[fieldConfig.tag] = int.tryParse(s),
          validator: fieldConfig.validator ??
              (s) =>
                  int.tryParse(s) != null ? 'Please only whole numbers.' : null,
        );
        break;
      case double:
        field = TextFormField(
          initialValue:
              (fieldConfig.initialValue as double)?.toStringAsFixed(2) ?? '',
          style: fieldConfig.fieldStyle ?? dialogConfig.fieldStyle,
          obscureText: fieldConfig.obscureText ?? false,
          keyboardType: TextInputType.numberWithOptions(decimal: true),
          onSaved: (s) => _formResults[fieldConfig.tag] = double.tryParse(s),
          validator: fieldConfig.validator ??
              (s) => double.tryParse(s) != null ? 'Please only numbers.' : null,
        );
        break;
      case bool:
        field = SizedBox();
        break;
      default:
    }
    return Padding(
      padding: dialogConfig.defaultFieldPadding,
      child: Padding(
        padding: fieldConfig.padding,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (fieldConfig.type == bool)
              Padding(
                padding: EdgeInsets.only(right: 8),
                child: CheckboxFormField(
                  context: context,
                  title: Text(dialogConfig.title ?? '',
                      style: fieldConfig.labelStyle),
                  initialValue: fieldConfig.initialValue ?? false,
                  validator: (b) {
                    return fieldConfig.validator(b ? 'true' : 'false');
                  },
                  onSaved: (b) => _formResults[fieldConfig.tag] = b,
                ),
              ),
            if (fieldConfig.type != bool) ...[
              Text(fieldConfig.label,
                  style: fieldConfig.labelStyle ?? dialogConfig.labelStyle),
              SizedBox(height: dialogConfig.labelSpacing),
              field,
            ],
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final dlgConfig = widget.dialogConfig;
    var content = SingleChildScrollView(
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (dlgConfig.header != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 24),
                child: Text(dlgConfig.header),
              ),
            for (final field in dlgConfig.fields)
              _fieldFactory(
                field,
                dlgConfig,
              ),
            if (dlgConfig.footer != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 24),
                child: Text(dlgConfig.footer),
              ),
          ],
        ),
      ),
    );
    if (Platform.isIOS) {
      return CupertinoAlertDialog(
        title: Text(dlgConfig.title ?? ''),
        content: content,
        actions: <Widget>[
          if (dlgConfig.cancelButtonText != null)
            FlatButton(
              onPressed: () {
                Navigator.of(context).pop(null);
              },
              child: Text(dlgConfig.cancelButtonText),
            ),
          FlatButton(
            onPressed: () {
              onOk();
              Navigator.of(context).pop(_formResults);
            },
            child: Text(dlgConfig.okButtonText),
          ),
        ],
      );
    } else {
      return AlertDialog(
        title: Text(dlgConfig.title ?? ''),
        content: content,
        actions: <Widget>[
          if (dlgConfig.cancelButtonText != null)
            FlatButton(
              onPressed: () {
                Navigator.of(context).pop(null);
              },
              child: Text(dlgConfig.cancelButtonText),
            ),
          FlatButton(
            onPressed: () {
              onOk();
              Navigator.of(context).pop(_formResults);
            },
            child: Text(dlgConfig.okButtonText),
          ),
        ],
      );
    }
  }

  void onOk() {
    final formState = _formKey.currentState;
    if (formState.validate()) {
      formState.save();
    } else {
      widget.dialogConfig.onValidationError?.call();
    }
  }
}

class CheckboxFormField extends FormField<bool> {
  CheckboxFormField({
    Widget title,
    @required BuildContext context,
    FormFieldSetter<bool> onSaved,
    FormFieldValidator<bool> validator,
    bool initialValue = false,
    bool autovalidate = false,
  }) : super(
          onSaved: onSaved,
          validator: validator,
          initialValue: initialValue,
          autovalidate: autovalidate,
          builder: (FormFieldState<bool> state) {
            return Transform.translate(transformHitTests: true,
                          offset: const Offset(-24, 0),
                          child: CheckboxListTile(
                dense: state.hasError,
                title: title,
                value: state.value ?? false,
                onChanged: state.didChange,
                subtitle: state.hasError
                    ? Text(
                        state.errorText,
                        style: TextStyle(
                            color: Theme.of(context).errorColor),
                      )
                    : null,
                controlAffinity: ListTileControlAffinity.leading,
              ),
            );
          },
        );
}
