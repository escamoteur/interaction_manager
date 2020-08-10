import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:interaction_manager/src/interaction_manager.dart';

class MessageDialogConfig {
  final String title;
  final String message;
  final Map<MessageDialogResults, String> buttonDefinitions;

  MessageDialogConfig({this.title, this.message, this.buttonDefinitions});
}

class MessageDialog {
  static const dialogId = 'Message';
  static Widget build(BuildContext context, MessageDialogConfig dialogConfig) {
    assert(dialogConfig.buttonDefinitions.isNotEmpty,
        'You have to provide at least one button definition');

    return WillPopScope(
      onWillPop: () async {
        Navigator.of(context).pop(MessageDialogResults.cancel);
        return true;
      },
      child: !Platform.isIOS
          ? AlertDialog(
              title: Text(dialogConfig.title ?? ''),
              content: Text(dialogConfig.message ?? ''),
              actions: [
                for (final buttonDefinition
                    in dialogConfig.buttonDefinitions.entries)
                  FlatButton(
                    onPressed: () {
                      Navigator.of(context)
                          .pop<MessageDialogResults>(buttonDefinition.key);
                    },
                    child: Text(buttonDefinition.value),
                  ),
              ],
            )
          : CupertinoAlertDialog(
              title: Text(dialogConfig.title ?? ''),
              content: Text(dialogConfig.message ?? ''),
              actions: [
                for (final buttonDefinition
                    in dialogConfig.buttonDefinitions.entries)
                  FlatButton(
                    onPressed: () {
                      Navigator.of(context)
                          .pop<MessageDialogResults>(buttonDefinition.key);
                    },
                    child: Text(buttonDefinition.value),
                  ),
              ],
            ),
    );
  }
}
