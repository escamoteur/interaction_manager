import 'package:flutter/material.dart';

class NetworkConfiguration {
  final bool useSSL;
  final String serverAdress;
  final int port;

  NetworkConfiguration({this.useSSL, this.serverAdress, this.port});
}

class NetworkConfigurationDialogConfig {
  final String title;
  final String message;
  final String serverAdressLabel;
  final String portLabel;
  final bool showProtocolSelection;
  final String portFormatErrorMessage;
  final String buttonText;
  final NetworkConfiguration netWorkConfiguration;

  NetworkConfigurationDialogConfig({
    this.portFormatErrorMessage,
    this.buttonText,
    this.title,
    this.message,
    this.serverAdressLabel,
    this.portLabel ,
    this.showProtocolSelection,
    this.netWorkConfiguration,
  });
}

class NetworkConfigurationDialog {
  static const String dialogId = 'NetWorkConfiguration'; 
  static Widget build(BuildContext context,NetworkConfigurationDialogConfig config) => _NetWorkConfigurationWidget(dialogConfig: config,);
}

class _NetWorkConfigurationWidget extends StatefulWidget {
  final NetworkConfigurationDialogConfig dialogConfig;
  const _NetWorkConfigurationWidget({Key key, this.dialogConfig})
      : super(key: key);

  @override
  _NetWorkConfigurationWidgetState createState() => _NetWorkConfigurationWidgetState();
}

class _NetWorkConfigurationWidgetState extends State<_NetWorkConfigurationWidget> {
  TextEditingController ipController;
  TextEditingController portController;

  String portErrorText;
  int port;
  String serverAddress;
  bool useSSL;

  @override
  void initState() {
    serverAddress = widget.dialogConfig.netWorkConfiguration.serverAdress ?? '';
    port = widget.dialogConfig.netWorkConfiguration.port;
    useSSL = widget.dialogConfig.netWorkConfiguration.useSSL ?? false;
    ipController = TextEditingController(text: serverAddress);
    portController = TextEditingController(text: port?.toString() ?? '');
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final dlgConfig = widget.dialogConfig;
    return AlertDialog(
      title: Text(dlgConfig.title ?? ''),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(dlgConfig.serverAdressLabel),
            TextField(
              keyboardType: TextInputType.url,
              controller: ipController,
              onChanged: (s) => serverAddress = s,
            ),
            const SizedBox(height: 16.0),
            Text(dlgConfig.portLabel),
            TextField(
              keyboardType: const TextInputType.numberWithOptions(),
              controller: portController,
              onChanged: (portAsString) {
                port = int.tryParse(portAsString);
                if (port == null) {
                  setState(() {
                    portErrorText = 'Only Numbers';
                  });
                } else {
                  setState(() {
                    portErrorText = null;
                  });
                }
              },
              decoration: InputDecoration(errorText: portErrorText),
            ),
          ],
        ),
      ),
      actions: <Widget>[
        FlatButton(
          onPressed: () {
            final netWorkConfig = NetworkConfiguration(
                port: port,
                serverAdress: serverAddress.trim(),
                useSSL: useSSL);

            Navigator.of(context).pop(netWorkConfig);
          },
          child: Text(dlgConfig.buttonText),
        ),
      ],
    );
  }
}
