import 'package:flutter/material.dart';

class MessageDialog
{
  static const dialogId = 'Message';
  static const fieldTitle = 'title';
  static const fieldMessage = 'message';
  static const fieldCloseButtonText = 'closeButtonText';

  static Widget build(BuildContext context, data) => AlertDialog(
                        title: Text(data[fieldTitle]),
                        content: Text(data[fieldMessage]),
                        actions: [
                          FlatButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            child: Text(data[fieldCloseButtonText]),
                          ),
                        ],
                      );
} 