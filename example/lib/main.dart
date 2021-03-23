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
    Key? key,
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
                    .showRegisteredDialog<Map<String, String>, void>(
                  dialogName: 'TestDialog',
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
                    'This is a message!',
                    title: 'Message Dialog',
                    closeButtonText: 'OK');
              },
              child: Text(
                'Message Dialog:',
              ),
            ),
            RaisedButton(
              onPressed: () async {
                MessageDialogResults result =
                    await GetIt.I<InteractionManager>().showQueryDialog(
                  'This is a query dialog!',
                  title: 'Query Dialog',
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
            RaisedButton(
              onPressed: () async {
                await GetIt.I<InteractionManager>().showLoginDialog(
                    okButtonText: 'OK',
                    usernameValidator: (s) {
                      return s.isEmpty ? 'You have to provide a name' : null;
                    });
              },
              child: Text(
                'Login Dialog:',
              ),
            ),
          ],
        ),
      ),
    );
  }
}
