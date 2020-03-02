import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:get_it/get_it.dart';
import 'package:interaction_manager/src/dialog_builders/message_dialog.dart';
import 'package:interaction_manager/src/dialog_builders/network_configuration_dialog.dart';

typedef DialogBuilderFunc<T> = Widget Function(BuildContext, T);

class InteractionManager {
  BuildContext _referenceContext;
  int _numOpenDialogs = 0;
  Map<String, DialogRegistration> _dialogRegistry =
      <String, DialogRegistration>{};

  bool allowReasigningDialogs = false;

  void setContext(BuildContext context) => _referenceContext = context;

  void closeDialog<TResult>([TResult result]) {
    if (_numOpenDialogs > 0) {
      Navigator.of(_referenceContext).pop<TResult>(result);
    }
  }

  Future<ResultType> showCustomDialog<DialogDataType, ResultType>(
      {DialogBuilderFunc<DialogDataType> dialogBuilder,
      DialogDataType data,
      bool barrierDismissible = false}) async {
    ResultType result;
    _numOpenDialogs++;
    if (Platform.isAndroid) {
      result = await showDialog<ResultType>(
          context: _referenceContext,
          barrierDismissible: barrierDismissible,
          builder: (context) => dialogBuilder(context, data));
    } else if (Platform.isIOS) {
      result = await showCupertinoDialog<ResultType>(
          context: _referenceContext,
          builder: (context) => dialogBuilder(context, data));
    }

    /// todo add other platforms
    else {
      result = await showDialog<ResultType>(
          context: _referenceContext,
          barrierDismissible: barrierDismissible,
          builder: (context) => dialogBuilder(context, data));
    }
    _numOpenDialogs--;
    return result;
  }

  void registerCustomDialog<DialogDataType>(
      DialogBuilderFunc<DialogDataType> builder, String dialogName) {
    if (!allowReasigningDialogs && _dialogRegistry.containsKey(dialogName)) {
      throw (StateError(
          'There is already a dialog with name: "$dialogName" registered'));
    }
    _dialogRegistry[dialogName] = DialogRegistration<DialogDataType>(builder);
  }

  Future<ResultType> showRegisteredDialog<DialogDataType, ResultType>(
      {String dialogName,
      DialogDataType data,
      bool barrierDismissible = false}) {
    if (!_dialogRegistry.containsKey(dialogName)) {
      throw (StateError(
          'There is no dialog with that name: "$dialogName" registered'));
    }
    var dialogRegistry = _dialogRegistry[dialogName];
    var builderFunc2 = dialogRegistry.builderFunc;
    print(builderFunc2);
    return showCustomDialog<DialogDataType, ResultType>(
        dialogBuilder: builderFunc2,
        data: data,
        barrierDismissible: barrierDismissible);
  }

  Future showMessageDialog({
    String title,
    String message,
    String closeButtonText = 'Ok',
  }) async {
    return await showRegisteredDialog<Map<String, String>, void>(
        dialogName: MessageDialog.dialogId,
        data: {
          MessageDialog.fieldTitle: title,
          MessageDialog.fieldMessage: message,
          MessageDialog.fieldCloseButtonText: closeButtonText
        });
  }

  Future<NetworkConfiguration> showNetworkConfigurationDialog({
    String title = 'Connection Settings',
    String message,
    String serverAdressLabel = 'Server Address',
    String portLabel = 'Server Port',
    bool showProtocolSelection = true,
    String portFormatErrorMessage = 'Only Numbers',
    String closeButtonText = 'Ok',
    NetworkConfiguration netWorkConfiguration,
  }) async {
    return await showRegisteredDialog<NetworkConfigurationDialogConfig,
            NetworkConfiguration>(
        dialogName: NetworkConfigurationDialog.dialogId,
        data: NetworkConfigurationDialogConfig(
            title: title,
            message: message,
            portLabel: portLabel,
            buttonText: closeButtonText,
            portFormatErrorMessage: portFormatErrorMessage,
            showProtocolSelection: showProtocolSelection,
            serverAdressLabel: serverAdressLabel,
            netWorkConfiguration: netWorkConfiguration));
  }

  void _registerStandardDialog() {
    registerCustomDialog<Map<String, dynamic>>(
        MessageDialog.build, MessageDialog.dialogId);
    registerCustomDialog<NetworkConfigurationDialogConfig>(
        NetworkConfigurationDialog.build, NetworkConfigurationDialog.dialogId);
  }
}

class DialogRegistration<T> {
  final DialogBuilderFunc<T> builderFunc;

  DialogRegistration(this.builderFunc);
}

class InteractionConnector extends StatefulWidget {
  final Widget child;

  /// Fire and forget async ApplicationInitFunction that will be called as soon as the
  /// Interaction Manager is ready
  final Future Function() appInitFunction;

  /// Will be called before [appInitFunction] pass here your funtion where you register your custom dialogs.
  final void Function(InteractionManager) dialogsInitFunction;

  const InteractionConnector(
      {this.appInitFunction, this.dialogsInitFunction, this.child, Key key})
      : super(key: key);
  @override
  _InteractionConnectorState createState() => _InteractionConnectorState();
}

class _InteractionConnectorState extends State<InteractionConnector> {
  @override
  void initState() {
    if (!GetIt.I.isRegistered<InteractionManager>()) {
      var interactionManager = InteractionManager();
      GetIt.I.registerSingleton<InteractionManager>(interactionManager);

      interactionManager._registerStandardDialog();
      widget.dialogsInitFunction?.call(interactionManager);
      widget.appInitFunction?.call();
    }
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    GetIt.I<InteractionManager>().setContext(context);
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
