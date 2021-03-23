import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:interaction_manager/interaction_manager.dart';
import 'package:interaction_manager/src/dialog_builders/login_dialog.dart';
import 'package:interaction_manager/src/dialog_builders/message_dialog.dart';
import 'package:interaction_manager/src/dialog_builders/network_configuration_dialog.dart';

export 'package:interaction_manager/src/dialog_builders/message_dialog.dart';
export 'package:interaction_manager/src/dialog_builders/network_configuration_dialog.dart';

class InteractionManagerImplementation implements InteractionManager {
  late NavigatorState _rootNavigatorState;
  int _numOpenDialogs = 0;
  Map<String, _DialogRegistration<Object>> _dialogRegistry =
      <String, _DialogRegistration<Object>>{};

  @override
  bool allowReassigningDialogs = false;

  @override
  void setRootNavigator(NavigatorState navigatorState) =>
      _rootNavigatorState = navigatorState;

  @override
  Future<T?> navigateTo<T>(String routeName, {Object? arguments}) {
    late BuildContext childContext;
    _rootNavigatorState.context
        .visitChildElements((element) => childContext = element);

    return Navigator.of(childContext)
        .pushNamed<T>(routeName, arguments: arguments);
  }

  @override
  void closeDialog<TResult>([TResult? result]) {
    if (_numOpenDialogs > 0) {
      late BuildContext childContext;
      _rootNavigatorState.context
          .visitChildElements((element) => childContext = element);

      Navigator.of(childContext).pop<TResult>(result);
    }
  }

  Future<ResultType?> _showCustomDialog<DialogDataType, ResultType>(
      {required DialogBuilderFunc<DialogDataType> dialogBuilder,
      required DialogDataType data,
      bool barrierDismissible = false}) async {
    ResultType? result;
    _numOpenDialogs++;
    late BuildContext childContext;
    _rootNavigatorState.context
        .visitChildElements((element) => childContext = element);

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

  @override
  void registerCustomDialog<DialogDataType>(
      DialogBuilderFunc<DialogDataType> builder, String dialogName) {
    if (!allowReassigningDialogs && _dialogRegistry.containsKey(dialogName)) {
      throw (StateError(
          'There is already a dialog with name: "$dialogName" registered'));
    }
    _dialogRegistry[dialogName] = _DialogRegistration<DialogDataType>(builder)
        as _DialogRegistration<Object>;
  }

  @override
  Future<ResultType?> showRegisteredDialog<DialogDataType, ResultType>(
      {required String dialogName,
      required DialogDataType data,
      bool barrierDismissible = false}) {
    if (!_dialogRegistry.containsKey(dialogName)) {
      throw (StateError(
          'There is no dialog with that name: "$dialogName" registered'));
    }

    final dialogRegistry =
        _dialogRegistry[dialogName] as _DialogRegistration<DialogDataType>;
    return _showCustomDialog<DialogDataType, ResultType>(
        dialogBuilder: dialogRegistry.builderFunc,
        data: data,
        barrierDismissible: barrierDismissible);
  }

  @override
  Future showMessageDialog(
    String message, {
    String? title,
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

  @override
  Future<UserCredentials?> showLoginDialog({
    String title = 'Login',
    String okButtonText = 'OK',
    String? cancelButtonText,
    String usernameLabel = 'User name',
    String passwordLabel = 'Password',
    String? header,
    String? userNamePrefill,
    String? Function(String)? usernameValidator,
    String? Function(String)? passwordValidator,
    bool barrierDismissible = false,
  }) async {
    return await showRegisteredDialog<LoginDialogConfig, UserCredentials>(
      dialogName: LoginDialog.dialogId,
      data: LoginDialogConfig(
        title: title,
        okButtonText: okButtonText,
        cancelButtonText: cancelButtonText,
        message: header,
        userNameLabel: usernameLabel,
        passwordLabel: passwordLabel,
        usernameValidator: usernameValidator,
        userNamePrefill: userNamePrefill,
        passwordValidator: passwordValidator,
      ),
      barrierDismissible: barrierDismissible,
    );
  }

  @override
  Future<MessageDialogResults> showQueryDialog(
    String message, {
    String? title,
    Map<MessageDialogResults, String> buttonDefinitions = const {
      MessageDialogResults.yes: 'Yes',
      MessageDialogResults.no: 'No',
    },
    bool barrierDismissible = false,
  }) async {
    return (await showRegisteredDialog<MessageDialogConfig,
            MessageDialogResults>(
        dialogName: MessageDialog.dialogId,
        data: MessageDialogConfig(
            message: message,
            title: title,
            buttonDefinitions: buttonDefinitions),
        barrierDismissible: barrierDismissible))!;
  }

  @override
  Future<NetworkConfiguration?> showNetworkConfigurationDialog({
    String title = 'Connection Settings',
    String? message,
    String serverAdressLabel = 'Server Address',
    String portLabel = 'Server Port',
    String sslLabel = 'Use SSL',
    bool showProtocolSelection = true,
    String portFormatErrorMessage = 'Only Numbers',
    String okButtonText = 'Ok',
    String? cancelButtonText,
    NetworkConfiguration? networkConfiguration,
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
    registerCustomDialog<LoginDialogConfig>(
        LoginDialog.build, LoginDialog.dialogId);
  }
}

class _DialogRegistration<T> {
  final DialogBuilderFunc<T> builderFunc;

  _DialogRegistration(this.builderFunc);
}

class InteractionConnectorState extends State<InteractionConnector> {
  @override
  void initState() {
    if (!GetIt.I.isRegistered<InteractionManager>()) {
      var interactionManager = InteractionManagerImplementation();
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
    GetIt.I<InteractionManager>()
        .setRootNavigator(Navigator.of(context, rootNavigator: true));
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
