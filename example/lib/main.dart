import 'package:example/dialog_builders.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:interaction_manager/interaction_manager.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: InteractionConnector(
          dialogsInitFunction: registerDialogs, child: MyHomePage()),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({
    Key key,
  }) : super(key: key);

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('InteractionManager'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            RaisedButton(
              onPressed: () async {
                await GetIt.I<InteractionManager>()
                    .showCustomDialog<Map<String, dynamic>, void>(
                  dialogBuilder: (context, data) => AlertDialog(
                    title: Text(data['title']),
                    content: Text(data['message']),
                    actions: <Widget>[
                      FlatButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        child: Text(data['buttonText']),
                      ),
                    ],
                  ),
                  data: {
                    'title': 'This is the Title',
                    'message': 'Direct Display',
                    'buttonText': 'OK'
                  },
                );
              },
              child: Text(
                'Direct CustomDialogCall:',
              ),
            ),
            RaisedButton(
              onPressed: () async {
                await GetIt.I<InteractionManager>()
                    .showRegisteredDialog<Map<String, String>, void>(
                  dialogName: 'MessageDialog',
                  data: {
                    'title': 'This is the Title',
                    'message': 'Registered Dialog',
                    'buttonText': 'OK'
                  },
                );
              },
              child: Text(
                'Registered CustomDialog:',
              ),
            ),
            RaisedButton(
              onPressed: () async {
                await GetIt.I<InteractionManager>().showMessageDialog(
                    title: 'Message Dialog',
                    message: 'This is a message!',
                    closeButtonText: 'OK');
              },
              child: Text(
                'Message Dialog:',
              ),
            ),
            RaisedButton(
              onPressed: () async {
                var result =
                    await GetIt.I<InteractionManager>().showQueryDialog(
                  title: 'Query Dialog',
                  message: 'This is a query dialog!',
                );
                print(result);
              },
              child: Text(
                'Query Dialog:',
              ),
            ),
            RaisedButton(
              onPressed: () async {
                await GetIt.I<InteractionManager>()
                    .showNetworkConfigurationDialog(
                  title: 'Network Dialog',
                  message: 'This is a message!',
                  okButtonText: 'OK',
                );
              },
              child: Text(
                'Network Dialog:',
              ),
            ),
          ],
        ),
      ),
    );
  }
}
