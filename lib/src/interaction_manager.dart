import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:get_it/get_it.dart';
import 'package:interaction_manager/src/dialog_builders/message_dialog.dart';
import 'package:interaction_manager/src/dialog_builders/network_configuration_dialog.dart';

export 'package:interaction_manager/src/dialog_builders/message_dialog.dart';
export 'package:interaction_manager/src/dialog_builders/network_configuration_dialog.dart';

typedef DialogBuilderFunc<T> = Widget Function(BuildContext, T);

class InteractionManager {
  NavigatorState _rootNavigatorState;
  int _numOpenDialogs = 0;
  Map<String, _DialogRegistration<Object>> _dialogRegistry =
      <String, _DialogRegistration>{};

  bool allowReasigningDialogs = false;

  void setRootNavigator(NavigatorState navigatorState) => _rootNavigatorState = navigatorState;

  Future<T> navigateTo<T>(String routeName) {
    BuildContext childContext;
    _rootNavigatorState.context.visitChildElements((element) => childContext = element);

    return Navigator.of(childContext).pushNamed<T>(routeName);
  }

  void closeDialog<TResult>([TResult result]) {
    if (_numOpenDialogs > 0) {
          BuildContext childContext;
    _rootNavigatorState.context.visitChildElements((element) => childContext = element);

      Navigator.of(childContext).pop<TResult>(result);
    }
  }

  Future<ResultType> showCustomDialog<DialogDataType, ResultType>(
      {DialogBuilderFunc<DialogDataType> dialogBuilder,
      DialogDataType data,
      bool barrierDismissible = false}) async {
    ResultType result;
    _numOpenDialogs++;
        BuildContext childContext;
    _rootNavigatorState.context.visitChildElements((element) => childContext = element);

    if (Platform.isAndroid) {
      result = await showDialog<ResultType>(
          context: childContext,
          barrierDismissible: barrierDismissible,
          builder: (context) => dialogBuilder(context, data));
    } else if (Platform.isIOS) {
      result = await showCupertinoDialog<ResultType>(
          context: childContext,
          builder: (context) => dialogBuilder(context, data));
    }

    /// todo add other platforms
    else {
      result = await showDialog<ResultType>(
          context: childContext,
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
    _dialogRegistry[dialogName] = _DialogRegistration<DialogDataType>(builder);
  }

  Future<ResultType> showRegisteredDialog<DialogDataType, ResultType>(
      {String dialogName,
      DialogDataType data,
      bool barrierDismissible = false}) {
    if (!_dialogRegistry.containsKey(dialogName)) {
      throw (StateError(
          'There is no dialog with that name: "$dialogName" registered'));
    }

    final dialogRegistry =
        _dialogRegistry[dialogName] as _DialogRegistration<DialogDataType>;
    return showCustomDialog<DialogDataType, ResultType>(
        dialogBuilder: dialogRegistry.builderFunc,
        data: data,
        barrierDismissible: barrierDismissible);
  }

  Future showMessageDialog(
    String message, {
    String title,
    String closeButtonText = 'OK',
    bool barrierDismissible = false,
  }) async {
    return await showRegisteredDialog<MessageDialogConfig, void>(
        dialogName: MessageDialog.dialogId,
        data: MessageDialogConfig(
            message: message,
            title: title,
            buttonDefinitions: {MessageDialogResults.ok: closeButtonText}),
        barrierDismissible: barrierDismissible);
  }

  Future<MessageDialogResults> showQueryDialog(
    String message, {
    String title,
    Map<MessageDialogResults, String> buttonDefinitions = const {
      MessageDialogResults.yes: 'Yes',
      MessageDialogResults.no: 'No',
      MessageDialogResults.cancel: 'Cancel',
    },
    bool barrierDismissible = false,
  }) async {
    return await showRegisteredDialog<MessageDialogConfig,
            MessageDialogResults>(
        dialogName: MessageDialog.dialogId,
        data: MessageDialogConfig(
            message: message,
            title: title,
            buttonDefinitions: buttonDefinitions),
        barrierDismissible: barrierDismissible);
  }

  Future<NetworkConfiguration> showNetworkConfigurationDialog({
    String title = 'Connection Settings',
    String message,
    String serverAdressLabel = 'Server Address',
    String portLabel = 'Server Port',
    String sslLabel = 'Use SSL',
    bool showProtocolSelection = true,
    String portFormatErrorMessage = 'Only Numbers',
    String okButtonText = 'Ok',
    String cancelButtonText,
    NetworkConfiguration networkConfiguration = const NetworkConfiguration(),
    bool barrierDismissible = false,
  }) async {
    return await showRegisteredDialog<NetworkConfigurationDialogConfig,
            NetworkConfiguration>(
        dialogName: NetworkConfigurationDialog.dialogId,
        barrierDismissible: barrierDismissible,
        data: NetworkConfigurationDialogConfig(
            title: title,
            message: message,
            portLabel: portLabel,
            okButtonText: okButtonText,
            cancelButtonText: cancelButtonText,
            portFormatErrorMessage: portFormatErrorMessage,
            showProtocolSelection: showProtocolSelection,
            sslLabel: sslLabel,
            serverAdressLabel: serverAdressLabel,
            netWorkConfiguration: networkConfiguration));
  }

  void _registerStandardDialog() {
    registerCustomDialog<MessageDialogConfig>(
        MessageDialog.build, MessageDialog.dialogId);
    registerCustomDialog<NetworkConfigurationDialogConfig>(
        NetworkConfigurationDialog.build, NetworkConfigurationDialog.dialogId);
  }
}

class _DialogRegistration<T> {
  final DialogBuilderFunc<T> builderFunc;

  _DialogRegistration(this.builderFunc);
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
    GetIt.I<InteractionManager>().setRootNavigator(Navigator.of(context,rootNavigator: true));
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
