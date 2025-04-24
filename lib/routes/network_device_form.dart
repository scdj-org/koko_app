import 'package:flutter/material.dart';
import 'package:koko/enums/protocol_enum.dart';
import 'package:koko/l10n/l10n.dart';
import 'package:koko/models/entity/index.dart';
import 'package:koko/models/model/net_devices_model.dart';
import 'package:koko/widgets/overlay/status_toast.dart';
import 'package:koko/widgets/ui_widgets/setting_dropdown_menu.dart';
import 'package:provider/provider.dart';
import 'package:webdav_client/webdav_client.dart';

class NetworkDeviceForm extends StatefulWidget {
  const NetworkDeviceForm({super.key, required this.onSubmit});

  final void Function() onSubmit;

  @override
  State<NetworkDeviceForm> createState() => _NetworkDeviceFormState();
}

class _NetworkDeviceFormState extends State<NetworkDeviceForm> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _baseUrlController = TextEditingController();
  final TextEditingController _rootPathController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _portController = TextEditingController();
  final TextEditingController _accountController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  ProtocolEnum _selectedProtocol = ProtocolEnum.webdav;

  void _submit() {
    if (_formKey.currentState!.validate()) {
      try {
        var netList = Provider.of<NetDevicesModel>(context, listen: false);
        final device =
            NetDevice()
              ..id = netList.netDevices.last.id + 1
              ..baseurl = _baseUrlController.text
              ..protocol = _selectedProtocol
              ..rootPath =
                  _rootPathController.text.isEmpty
                      ? null
                      : _rootPathController.text
              ..name =
                  _nameController.text.isEmpty ? null : _nameController.text
              ..port = int.tryParse(_portController.text)
              ..account =
                  _accountController.text.isEmpty
                      ? null
                      : _accountController.text
              ..password =
                  _passwordController.text.isEmpty
                      ? null
                      : _passwordController.text;
        netList.appendNetDevice = device;
        _baseUrlController.clear();
        _rootPathController.clear();
        _nameController.clear();
        _accountController.clear();
        _passwordController.clear();
        _portController.clear();
        widget.onSubmit();
      } catch (e) {
        StatusToast.show(
          context: context,
          message: e.toString(),
          isSuccess: false,
        );
      }
    }
  }

  void _testConnection() async {
    if (_formKey.currentState!.validate()) {
      try {
        var uri = _baseUrlController.text;
        var port = int.tryParse(_portController.text);
        var rootPath = _rootPathController.text;
        var account = _accountController.text;
        var password = _passwordController.text;
        if (uri.isEmpty) return;
        var url = "$uri${port == null ? "" : ":$port"}";
        var client = newClient(
          "$url/$rootPath",
          user: account,
          password: password,
          debug: true,
        )..setHeaders({"accept-charset": "utf-8"});
        await client.ping();
        if (context.mounted) {
          StatusToast.show(
            context: context,
            message: AppLocalizations.of(context).connectSuccess,
            isSuccess: true,
          );
        }
      } catch (e) {
        if (context.mounted) {
          StatusToast.show(
            context: context,
            message: AppLocalizations.of(context).connectFaild,
            isSuccess: false,
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    var protocolList = List<ProtocolEnum>.from(ProtocolEnum.values)
      ..remove(ProtocolEnum.local);
    return Form(
      key: _formKey,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          InputDecorator(
            decoration: const InputDecoration(isDense: true),
            child: ListTile(
              contentPadding: EdgeInsets.all(0),
              leading: Icon(Icons.document_scanner),
              title: Text(
                AppLocalizations.of(context).protocol,
                overflow: TextOverflow.ellipsis,
              ),
              trailing: SettingDropdownMenu(
                width: 100,
                dropDownItems: protocolList,
                initSelection: ProtocolEnum.webdav,
                onSelected: (protocol) {
                  if (protocol != null) {
                    _selectedProtocol = protocol;
                  }
                },
              ),
            ),
          ),

          /// name
          TextFormField(
            controller: _nameController,
            decoration: InputDecoration(
              labelText: AppLocalizations.of(context).netName,
            ),
          ),

          /// host
          TextFormField(
            controller: _baseUrlController,
            decoration: InputDecoration(
              labelText: '${AppLocalizations.of(context).netHost} *',
              hintText: "https://www.kokoapp.top",
            ),
            validator: validateBaseUrl,
          ),

          /// rootPath
          TextFormField(
            controller: _rootPathController,
            decoration: InputDecoration(
              labelText: AppLocalizations.of(context).netPath,
              hintText: "dav/漫画/小林家的龙女仆",
            ),
            validator: validateRootPath,
          ),

          /// port
          TextFormField(
            controller: _portController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              labelText: AppLocalizations.of(context).netPort,
              hintText: "5244",
            ),
            validator: validatePort,
          ),

          /// account
          TextFormField(
            controller: _accountController,
            decoration: InputDecoration(
              labelText: AppLocalizations.of(context).netAccount,
            ),
            validator: validateOptionalNonEmpty,
          ),

          /// password
          TextFormField(
            controller: _passwordController,
            obscureText: true,
            decoration: InputDecoration(
              labelText: AppLocalizations.of(context).netPassword,
            ),
            validator: validateOptionalNonEmpty,
          ),

          const SizedBox(height: 24),

          Row(
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: ElevatedButton(
                    onPressed: _testConnection,
                    child: Text(AppLocalizations.of(context).connectionTest),
                  ),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: ElevatedButton(
                    onPressed: _submit,
                    child: Text(AppLocalizations.of(context).confirmText),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// 验证 baseurl 是否为合法 host（https://domain/）
  String? validateBaseUrl(String? value) {
    if (value == null || value.trim().isEmpty) {
      return AppLocalizations.of(context).hostEmptyWarning;
    }

    final uri = Uri.tryParse(value.trim());
    if (uri == null || !(uri.hasScheme && uri.hasAuthority)) {
      return AppLocalizations.of(context).hostEmptyWarning;
    }

    if (uri.path != '/' && uri.path.isNotEmpty) {
      return AppLocalizations.of(context).hostNoPath;
    }

    return null;
  }

  /// 验证 rootPath（不能包含 host、不能以 http 开头）
  String? validateRootPath(String? value) {
    if (value == null || value.trim().isEmpty) return null; // 可选
    final v = value.trim();

    if (v.startsWith('http://') || v.startsWith('https://')) {
      return AppLocalizations.of(context).pathNoHost;
    }

    if (v.contains('://') || v.contains(RegExp(r'^https?://'))) {
      return AppLocalizations.of(context).pathErrorWarning;
    }

    return null;
  }

  /// 账号密码：可选，若填不能全是空
  String? validateOptionalNonEmpty(String? value) {
    if (value != null && value.isNotEmpty && value.trim().isEmpty) {
      return AppLocalizations.of(context).optionNotEmpty;
    }
    return null;
  }

  /// 验证端口（1~65535 的整数）
  String? validatePort(String? value) {
    if (value == null || value.trim().isEmpty) return null; // 可选
    final port = int.tryParse(value.trim());
    if (port == null || port <= 0 || port > 65535) {
      return AppLocalizations.of(context).vaildPort;
    }
    return null;
  }

  @override
  void dispose() {
    _baseUrlController.dispose();
    _rootPathController.dispose();
    _nameController.dispose();
    _portController.dispose();
    _accountController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}
