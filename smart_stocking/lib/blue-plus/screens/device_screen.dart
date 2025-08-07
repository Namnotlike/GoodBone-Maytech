import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

import '../widgets/service_tile.dart';
import '../widgets/characteristic_tile.dart';
import '../widgets/descriptor_tile.dart';
import '../utils/snackbar.dart';
import '../utils/extra.dart';

class DeviceScreen extends StatefulWidget {
  final BluetoothDevice device;
  final ScanResult result;

  const DeviceScreen({Key? key, required this.device, required this.result}) : super(key: key);

  @override
  State<DeviceScreen> createState() => _DeviceScreenState();
}

class _DeviceScreenState extends State<DeviceScreen> {
  int? _rssi;
  int? _mtuSize;
  BluetoothConnectionState _connectionState = BluetoothConnectionState.disconnected;
  List<BluetoothService> _services = [];
  bool _isDiscoveringServices = false;
  bool _isConnecting = false;
  bool _isDisconnecting = false;
  String results = "Results";

  late StreamSubscription<BluetoothConnectionState> _connectionStateSubscription;
  late StreamSubscription<bool> _isConnectingSubscription;
  late StreamSubscription<bool> _isDisconnectingSubscription;
  late StreamSubscription<int> _mtuSubscription;

  @override
  void initState() {
    super.initState();

    _connectionStateSubscription = widget.device.connectionState.listen((state) async {
      _connectionState = state;
      if (state == BluetoothConnectionState.connected) {
        _services = []; // must rediscover services
      }
      if (state == BluetoothConnectionState.connected && _rssi == null) {
        _rssi = await widget.device.readRssi();
      }
      setState(() {});
    });

    _mtuSubscription = widget.device.mtu.listen((value) {
      _mtuSize = value;
      setState(() {});
    });

    _isConnectingSubscription = widget.device.isConnecting.listen((value) {
      _isConnecting = value;
      setState(() {});
    });

    _isDisconnectingSubscription = widget.device.isDisconnecting.listen((value) {
      _isDisconnecting = value;
      setState(() {});
    });
  }

  @override
  void dispose() {
    _connectionStateSubscription.cancel();
    _mtuSubscription.cancel();
    _isConnectingSubscription.cancel();
    _isDisconnectingSubscription.cancel();
    super.dispose();
  }

  bool get isConnected {
    return _connectionState == BluetoothConnectionState.connected;
  }

  Future onConnectPressed() async {
    try {
      
      await widget.device.connectAndUpdateStream();
      // SerialService service;
      // SerialSocket socket = new SerialSocket(getActivity().getApplicationContext(), device);
      // service.connect(socket);
      Snackbar.show(ABC.c, "Connect: Success", success: true);
    } catch (e) {
      if (e is FlutterBluePlusException && e.code == FbpErrorCode.connectionCanceled.index) {
        // ignore connections canceled by the user
      } else {
        Snackbar.show(ABC.c, prettyException("Connect Error:", e), success: false);
      }
    }
  }

  Future onCancelPressed() async {
    try {
      await widget.device.disconnectAndUpdateStream(queue: false);
      Snackbar.show(ABC.c, "Cancel: Success", success: true);
    } catch (e) {
      Snackbar.show(ABC.c, prettyException("Cancel Error:", e), success: false);
    }
  }

  Future onDisconnectPressed() async {
    try {
      await widget.device.disconnectAndUpdateStream();
      Snackbar.show(ABC.c, "Disconnect: Success", success: true);
    } catch (e) {
      Snackbar.show(ABC.c, prettyException("Disconnect Error:", e), success: false);
    }
  }

  Future onDiscoverServicesPressed() async {
    setState(() {
      _isDiscoveringServices = true;
    });
    try {
      _services = await widget.device.discoverServices();
      Snackbar.show(ABC.c, "Discover Services: Success", success: true);
    } catch (e) {
      Snackbar.show(ABC.c, prettyException("Discover Services Error:", e), success: false);
    }
    setState(() {
      _isDiscoveringServices = false;
    });
  }

  Future onRequestMtuPressed() async {
    try {
      await widget.device.requestMtu(223);
      Snackbar.show(ABC.c, "Request Mtu: Success", success: true);
    } catch (e) {
      Snackbar.show(ABC.c, prettyException("Change Mtu Error:", e), success: false);
    }
  }

  List<Widget> _buildServiceTiles(BuildContext context, BluetoothDevice d) {
    return _services
        .map(
          (s) => ServiceTile(
            service: s,
            characteristicTiles: s.characteristics.map((c) => _buildCharacteristicTile(c)).toList(),
          ),
        )
        .toList();
  }

  CharacteristicTile _buildCharacteristicTile(BluetoothCharacteristic c) {
    return CharacteristicTile(
      characteristic: c,
      descriptorTiles: c.descriptors.map((d) => DescriptorTile(descriptor: d)).toList(),
    );
  }

  Widget buildSpinner(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(14.0),
      child: AspectRatio(
        aspectRatio: 1.0,
        child: CircularProgressIndicator(
          backgroundColor: Colors.black12,
          color: Colors.black26,
        ),
      ),
    );
  }

  Widget buildRemoteId(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Text('${widget.device.remoteId}'),
    );
  }

  Widget buildRssiTile(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        isConnected ? const Icon(Icons.bluetooth_connected) : const Icon(Icons.bluetooth_disabled),
        Text(((isConnected && _rssi != null) ? '${_rssi!} dBm' : ''), style: Theme.of(context).textTheme.bodySmall)
      ],
    );
  }

  Widget buildGetServices(BuildContext context) {
    return IndexedStack(
      index: (_isDiscoveringServices) ? 1 : 0,
      children: <Widget>[
        TextButton(
          child: const Text("Get Services"),
          onPressed: onDiscoverServicesPressed,
        ),
        const IconButton(
          icon: SizedBox(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation(Colors.grey),
            ),
            width: 18.0,
            height: 18.0,
          ),
          onPressed: null,
        )
      ],
    );
  }

  Widget btnTest(BuildContext context) {
    return IndexedStack(
      index: (_isDiscoveringServices) ? 1 : 0,
      children: <Widget>[
        TextButton(
          child: const Text("Get Checks"),
          onPressed: check,
        ),
        const IconButton(
          icon: SizedBox(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation(Colors.grey),
            ),
            width: 18.0,
            height: 18.0,
          ),
          onPressed: null,
        )
      ],
    );
  }

  Future check() async {
    setState(() {
      _isDiscoveringServices = true;
    });
    results = "After check";
    try {
      await widget.device.disconnectAndUpdateStream();
      Snackbar.show(ABC.c, "Disconnect: Success", success: true);
    } catch (e) {
      Snackbar.show(ABC.c, prettyException("Disconnect Error:", e), success: false);
    }
    // try {
      // final command = "LTE";
      // final convertedCommand = AsciiEncoder().convert(command);
      // widget.device.(convertedCommand);
      // _services = await widget.device.discoverServices();
      // String data = "LTE"; //data.codeUnits
      // String command = "55 AA 00 01 50 3C 00"; //command.codeUnits
      //WRITE
//       for (BluetoothService service in _services) {
//         for (BluetoothCharacteristic characteristic in service.characteristics) {
//           final isWrite = characteristic.properties.write;
//           if (isWrite) {
//             await characteristic.write([0x12, 0x34], allowLongWrite: true);
//             // final subscription = characteristic.onValueReceived.listen((value) {
//             //   results = value;
//             //   // onValueReceived is updated:
//             //   //   - anytime read() is called
//             //   //   - anytime a notification arrives (if subscribed)
//             // });

// // // cleanup: cancel subscription when disconnected
// //             device.cancelWhenDisconnected(subscription);

// // // subscribe
// // // Note: If a characteristic supports both **notifications** and **indications**,
// // // it will default to **notifications**. This matches how CoreBluetooth works on iOS.
// //             await characteristic.setNotifyValue(true);
//           }
//         }
//       }
    // } catch (e) {
    //   Snackbar.show(ABC.c, prettyException("Discover Services Error:", e), success: false);
    // }
    // try {
    //READ
    // results = await receiveData() as String;
    // Snackbar.show(ABC.c, "Discover Services: Success", success: true);
    // } catch (e) {
    // Snackbar.show(ABC.c, prettyException("Discover Services Error:", e), success: false);
    // }
    setState(() {
      _isDiscoveringServices = false;
    });
  }

  Future<String?> receiveData() async {
    try {
      final services = await widget.device.discoverServices();
      for (BluetoothService service in services) {
        for (BluetoothCharacteristic characteristic in service.characteristics) {
          final isRead = characteristic.properties.read;
          final isNotify = characteristic.properties.notify;
          if (isRead && isNotify) {
            final value = await characteristic.read();
            return String.fromCharCodes(value);
          }
        }
      }
    } catch (e) {
      return null;
    }
    return null;
  }

  Future sendData(String data) async {
    // final device = BluetoothDevice.fromId(deviceInfo.id, name: deviceInfo.name);
    final services = await widget.device.discoverServices();
    for (BluetoothService service in services) {
      for (BluetoothCharacteristic characteristic in service.characteristics) {
        final isWrite = characteristic.properties.write;
        if (isWrite) {
          await characteristic.write(data.codeUnits);
        }
      }
    }
  }

  Widget buildMtuTile(BuildContext context) {
    return ListTile(
        title: const Text('MTU Size'),
        subtitle: Text('$_mtuSize bytes'),
        trailing: IconButton(
          icon: const Icon(Icons.edit),
          onPressed: onRequestMtuPressed,
        ));
  }

  Widget buildConnectButton(BuildContext context) {
    return Row(children: [
      if (_isConnecting || _isDisconnecting) buildSpinner(context),
      TextButton(
          onPressed: _isConnecting ? onCancelPressed : (isConnected ? onDisconnectPressed : onConnectPressed),
          child: Text(
            _isConnecting ? "CANCEL" : (isConnected ? "DISCONNECT" : "CONNECT"),
            style: Theme.of(context).primaryTextTheme.labelLarge?.copyWith(color: Colors.white),
          ))
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return ScaffoldMessenger(
      key: Snackbar.snackBarKeyC,
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.device.platformName),
          actions: [buildConnectButton(context)],
        ),
        body: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              buildRemoteId(context),
              ListTile(
                leading: Text('Check'),
                title: Text(results),
                trailing: btnTest(context),
              ),
              ListTile(
                leading: buildRssiTile(context),
                title: Text('Device is ${_connectionState.toString().split('.')[1]}.'),
                trailing: buildGetServices(context),
              ),
              buildMtuTile(context),
              ..._buildServiceTiles(context, widget.device),
            ],
          ),
        ),
      ),
    );
  }
}
