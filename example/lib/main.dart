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
                var result =
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
                var result = await GetIt.I<InteractionManager>().showFormDialog(
                    title: 'Form Dialog',
                    header: 'Please enter all Fields',
                    footer: 'This Process takes a little time',
                    onValidationError: () async =>
                        await GetIt.I<InteractionManager>().showMessageDialog(
                            'There are invalid values in your Form'),
                    fields: [
                      FormFieldConfig<String>(
                        tag: 'name', 
                        label: 'Name',
                        validator: (s) => s.isEmpty ? 'You have to fill out this field' : null
                      ),
                      FormFieldConfig<String>(
                        tag: 'pwd', 
                        label: 'Password',
                        isPassword: true,
                        validator: (s) => s.isEmpty ? 'You have to fill out this field' : null
                      ),
                      FormFieldConfig<int>(
                        tag: 'int', 
                        label: 'Integer',
                        isPassword: true,
//                        validator: (i) => i>0 ? 'Only positive Numbers' : null
                      ),
                      FormFieldConfig<double>(
                        tag: 'double', 
                        label: 'Double',
                        isPassword: true,
                        validator: (s) => int.tryParse(s) > 0 ? 'Only positive Numbers' : null
                      ),
                      FormFieldConfig<bool>(
                        tag: 'bool', 
                        label: 'Bool',
                        isPassword: true,
//                        validator: (b) => !bas  ? 'You have to select' : null
                      ),
                    ]);
                print(result);
              },
              child: Text(
                'Form Dialog:',
              ),
            ),
          ],
        ),
      ),
    );
  }
}
