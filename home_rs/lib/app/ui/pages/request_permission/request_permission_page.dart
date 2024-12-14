import 'dart:async';
import 'package:flutter/material.dart';
import 'package:home_rs/app/ui/pages/request_permission/request_permission_controller.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../routes/routes.dart';

class RequestPermissionPage extends StatefulWidget {
  const RequestPermissionPage({super.key});
  

  @override
  _RequestPermissionPageState createState() => _RequestPermissionPageState();
}

class _RequestPermissionPageState extends State<RequestPermissionPage>
    with WidgetsBindingObserver {
  final _controller = RequestPermissionController(Permission.locationWhenInUse);
  late StreamSubscription _subscription;
bool _fromSettigns=false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _subscription = _controller.onStatusChanged.listen(
      (status) {
        switch (status) {
          case PermissionStatus.granted:
            _goToHome();
            break;
          case PermissionStatus.permanentlyDenied:
            showDialog(
                context: context,
                builder: (_) => AlertDialog(
                  title: const Text("INFO"),
                  content: const Text("No se pudo obtener permiso de ubicacion, por favor brindelo manualmente"),
                  actions: [
                    TextButton(
                        onPressed: () async{
                          Navigator.pop(context);
                          _fromSettigns=await openAppSettings();
                        },
                        child: const Text("Ir a configuracion"),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: const Text("Cancelar"),
                    )
                  ],
                ),
            );

            break;
          default:
            break;
        }
      },
    );
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) async {
    if (state == AppLifecycleState.resumed && _fromSettigns) {
      final status = await _controller.check();
      if (status == PermissionStatus.granted) {
        _goToHome();
      }
    }
    _fromSettigns=false;
  }

  void _goToHome(){
    Navigator.pushReplacementNamed(context, Routes.HOME);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _subscription.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Container(
          width: double.infinity,
          height: double.infinity,
          alignment: Alignment.center,
          child: ElevatedButton(
            child: const Text("Allow"),
            onPressed: () {
              _controller.request();
            },
          ),
        ),
      ),
    );
  }
}
