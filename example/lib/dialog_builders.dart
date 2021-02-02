import 'package:flutter/material.dart';
import 'package:interaction_manager/interaction_manager.dart';

void registerDialogs(InteractionManager ia) {
  ia.registerCustomDialog<Map<String, String>>(buildTestDialog, 'TestDialog');
}

Widget buildTestDialog(BuildContext context, Map<String, String> data) =>
    AlertDialog(
      title: Text(data['title']),
      content: Text(data['message']),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: Text(data['buttonText']),
        ),
      ],
    );
