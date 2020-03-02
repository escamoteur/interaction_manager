import 'package:flutter/material.dart';
import 'package:interaction_manager/interaction_manager.dart';

void registerDialogs(InteractionManager ia)
{
  ia.registerCustomDialog<Map<String,dynamic>>(buildMessageDialog, 'MessageDialog');     
}

Widget buildMessageDialog(context, data) => AlertDialog(
                        title: Text(data['title']),
                        content: Text(data['message']),
                        actions: [
                          FlatButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            child: Text(data['buttonText']),
                          ),
                        ],
                      );