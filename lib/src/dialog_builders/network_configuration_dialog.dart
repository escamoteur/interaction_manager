import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class NetworkConfiguration {
  final bool useSSL;
  final String serverAdress;
  final int port;

  const NetworkConfiguration(
      {required this.useSSL, required this.serverAdress, required this.port});
}

class NetworkConfigurationDialogConfig {
  final String? title;
  final String? message;
  final String serverAdressLabel;
  final String portLabel;
  final String? sslLabel;
  final bool showProtocolSelection;
  final String portFormatErrorMessage;
  final String okButtonText;
  final String? cancelButtonText;
  final NetworkConfiguration? netWorkConfiguration;

  NetworkConfigurationDialogConfig({
    required this.portFormatErrorMessage,
    required this.okButtonText,
    this.cancelButtonText,
    this.title,
    this.message,
    required this.serverAdressLabel,
    required this.portLabel,
    this.sslLabel,
    required this.showProtocolSelection,
    this.netWorkConfiguration,
  });
}

class NetworkConfigurationDialog {
  static const String dialogId = 'NetWorkConfiguration';
  static Widget build(
          BuildContext context, NetworkConfigurationDialogConfig? config) =>
      NetWorkConfigurationWidget(
        dialogConfig: config!,
      );
}

class NetWorkConfigurationWidget extends StatefulWidget {
  final NetworkConfigurationDialogConfig dialogConfig;
  const NetWorkConfigurationWidget({Key? key, required this.dialogConfig})
      : super(key: key);

  @override
  NetWorkConfigurationWidgetState createState() =>
      NetWorkConfigurationWidgetState();
}

class NetWorkConfigurationWidgetState
    extends State<NetWorkConfigurationWidget> {
  late TextEditingController ipController;
  late TextEditingController portController;

  String? portErrorText;
  int? port;
  late String serverAddress;
  late bool? useSSL;

  @override
  void initState() {
    serverAddress =
        widget.dialogConfig.netWorkConfiguration?.serverAdress ?? '';
    port = widget.dialogConfig.netWorkConfiguration?.port;
    useSSL = widget.dialogConfig.netWorkConfiguration?.useSSL ?? false;
    ipController = TextEditingController(text: serverAddress);
    portController = TextEditingController(text: port?.toString() ?? '');
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final dlgConfig = widget.dialogConfig;
    var content = SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          if (dlgConfig.message != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 24),
              child: Text(dlgConfig.message!),
            ),
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
                  portErrorText = dlgConfig.portFormatErrorMessage;
                });
              } else {
                setState(() {
                  portErrorText = null;
                });
              }
            },
            decoration: InputDecoration(errorText: portErrorText),
          ),
          if (dlgConfig.showProtocolSelection)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Row(
                children: [
                  Text(dlgConfig.sslLabel!),
                  Checkbox(
                    value: useSSL,
                    onChanged: (b) => setState(() => useSSL = b),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
    if (Platform.isIOS) {
      return CupertinoAlertDialog(
        title: Text(dlgConfig.title ?? ''),
        content: content,
        actions: <Widget>[
          if (dlgConfig.cancelButtonText != null)
            MaterialButton(
              onPressed: () {
                Navigator.of(context).pop(null);
              },
              child: Text(dlgConfig.cancelButtonText!),
            ),
          MaterialButton(
            onPressed: () {
              final netWorkConfig = NetworkConfiguration(
                  port: port!,
                  serverAdress: serverAddress.trim(),
                  useSSL: useSSL!);

              Navigator.of(context).pop(netWorkConfig);
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
            MaterialButton(
              onPressed: () {
                Navigator.of(context).pop(null);
              },
              child: Text(dlgConfig.cancelButtonText!),
            ),
          MaterialButton(
            onPressed: () {
              final netWorkConfig = NetworkConfiguration(
                  port: port ?? -1,
                  serverAdress: serverAddress.trim(),
                  useSSL: useSSL!);

              Navigator.of(context).pop(netWorkConfig);
            },
            child: Text(dlgConfig.okButtonText),
          ),
        ],
      );
    }
  }
}
