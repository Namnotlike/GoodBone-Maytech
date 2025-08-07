import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:provider/provider.dart';

import 'package:wordpress_app/blocs/config_bloc.dart';
import 'package:wordpress_app/blue-plus/utils/extra.dart';
import 'package:wordpress_app/blue-plus/utils/snackbar.dart';
import 'package:wordpress_app/blue-plus/widgets/connected_device_tile.dart';
import 'package:wordpress_app/blue-plus/widgets/scan_result_tile.dart';
import 'package:wordpress_app/config/config.dart';
import 'package:wordpress_app/constants/constant.dart';
import 'package:wordpress_app/pages/AccountScreen.dart';
import 'package:wordpress_app/utils/empty_image.dart';

import 'package:flutter/foundation.dart' show defaultTargetPlatform, TargetPlatform, kIsWeb;
class RemoteTab extends StatefulWidget {
  const RemoteTab({Key? key}) : super(key: key);

  @override
  State<RemoteTab> createState() => _RemoteTabState();
}

class _RemoteTabState extends State<RemoteTab>
    with AutomaticKeepAliveClientMixin {
  bool _hasConnectedDevice = false;

  ScrollController? _controller;
  var scaffoldKey = GlobalKey<ScaffoldState>();
  List<bool> _selectedModes = <bool>[true, false, false, false];
  List<Widget> modes = <Widget>[
    const Text('C1'),
    const Text('C2'),
    const Text('C3'),
    const Text('C4'),
    const Text('C5'),
    const Text('C6'),
    const Text('C7'),
    const Text('C8'),
    const Text('C9'),
    const Text('C10'),
    const Text('C11'),
    const Text('C12'),
  ];
  List<int> times = <int>[0, 3, 5, 10, 30, 60];
  int timeSelect = 0;
  int currentMode = 0;
  List<Widget> statusList = <Widget>[
    const Text('ON'),
    const Text('OFF'),
  ];

  List<bool> _selectedStatus = <bool>[true, false];
  List<BluetoothDevice> _connectedDevices = [];
  List<ScanResult> _scanResults = [];
  bool _isScanning = false;
  late StreamSubscription<List<ScanResult>> _scanResultsSubscription;
  late StreamSubscription<bool> _isScanningSubscription;
  BluetoothDevice? connectedDevice;
  BluetoothCharacteristic? connectedCharacteristic;
  String responseMsg = "";
  late StreamSubscription<List<int>> _lastValueSubscription;

  int? _rssi;
  int? _mtuSize;
  BluetoothConnectionState _connectionState = BluetoothConnectionState.disconnected;
  List<BluetoothService> _services = [];
  List<BluetoothCharacteristic> _characteristices = [];
  bool _isConnecting = false;
  bool _isDisconnecting = false;
  late StreamSubscription<BluetoothConnectionState>
      _connectionStateSubscription;
  late StreamSubscription<bool> _isConnectingSubscription;
  late StreamSubscription<bool> _isDisconnectingSubscription;
  bool _isON = false;
  List<double> levelNumber = [10, 14, 17, 20];
  bool _isPause = false;
  bool _isRunning = false;

  bool get isConnected {
    return _connectionState == BluetoothConnectionState.connected;
  }

  bool get isON {
    return _isON &&_connectionState == BluetoothConnectionState.connected;
  }

  final fakeDevice = BluetoothDevice(
    remoteId: const DeviceIdentifier("GBM01"),
  );

// tạo dữ liệu quảng cáo giả
  final fakeAdData = AdvertisementData(
    appearance: 0,
    connectable: true,
    manufacturerData: {},
    serviceData: {},
    serviceUuids: [],
    txPowerLevel: 0,
    advName: "GBM01",
  );

// tạo ScanResult
  late ScanResult fakeResult;

  @override
  void initState() {
    super.initState();

    fakeResult = ScanResult(
      device: fakeDevice,
      advertisementData: fakeAdData,
      rssi: -60,
      timeStamp: DateTime.now(),
    );

    _scanResults.add(fakeResult);
    if (!kIsWeb) {
      FlutterBluePlus.systemDevices([]).then((devices) {
        _connectedDevices = devices;
        setState(() {});
      });

      _scanResultsSubscription = FlutterBluePlus.scanResults.listen((results) {
        final filtered = results.where((e) =>
        e.advertisementData.advName.isNotEmpty).toList();
        _scanResults = [
          fakeResult,
          ...filtered.where((r) => r.device.remoteId !=
              fakeResult.device.remoteId)
        ];
        setState(() {});
      }, onError: (e) {
        Snackbar.show(ABC.b, prettyException("Scan Error:", e), success: false);
      });

      _isScanningSubscription = FlutterBluePlus.isScanning.listen((state) {
        _isScanning = state;
        setState(() {});
      });
    }
    Timer.periodic(Duration(seconds: 10), (timer) {
      setState(() {
        sensorValues.updateAll((key, value) => Random().nextInt(21) - 10);
      });
    });
  }

  @override
  void dispose() {
    _scanResultsSubscription.cancel();
    _isScanningSubscription.cancel();
    _connectionStateSubscription.cancel();
    _isConnectingSubscription.cancel();
    _isDisconnectingSubscription.cancel();
    _lastValueSubscription.cancel();
    super.dispose();
  }

  Future onScanPressed() async {
    try {
      // android is slow when asking for all advertisments,
      // so instead we only ask for 1/8 of them
      int divisor = 1;
      if (kIsWeb) {
      } else if (defaultTargetPlatform == TargetPlatform.android) {
        divisor = 8;
      } else if (defaultTargetPlatform == TargetPlatform.iOS) {

      }
      if (!kIsWeb) {
        await FlutterBluePlus.startScan(
            timeout: const Duration(seconds: 15),
            continuousUpdates: true,
            continuousDivisor: divisor);
      }
    } catch (e) {
      Snackbar.show(ABC.b, prettyException("Start Scan Error:", e),
          success: false);
    }
    setState(() {}); // force refresh of systemDevices
  }

  Future onStopPressed() async {
    try {
      if (!kIsWeb) {
        FlutterBluePlus.stopScan();
      }
    } catch (e) {
      Snackbar.show(ABC.b, prettyException("Stop Scan Error:", e),
          success: false);
    }
  }

  Future onConnectPressed(BluetoothDevice device) async {
    // connectedDevice = device;
    // _hasConnectedDevice = true;
    // _connectionStateSubscription = device.connectionState.listen((state) async {
    //   _connectionState = state;
    //   if (state == BluetoothConnectionState.connected) {
    //     _services = []; // must rediscover services
    //     _services = await connectedDevice!.discoverServices();
    //     getBluetoothCharacteristicList();
    //   }
    //   if (state == BluetoothConnectionState.connected && _rssi == null) {
    //     _rssi = await device.readRssi();
    //   }
    //   if (state == BluetoothConnectionState.disconnected) {
    //     setState(() {
    //       _isON = false;
    //     });
    //     updateDeviceMode();
    //     this._lastValueSubscription.cancel();
    //     connectedCharacteristic = null;
    //   }
    //   setState(() {});
    // });

    // _isConnectingSubscription = device.isConnecting.listen((value) {
    //   _isConnecting = value;
    //   setState(() {});
    // });
    //
    // _isDisconnectingSubscription = device.isDisconnecting.listen((value) {
    //   _isDisconnecting = value;
    //   setState(() {});
    // });

    // device.connectAndUpdateStream().catchError((e) {
    //   Snackbar.show(ABC.c, prettyException("Connect Error:", e),
    //       success: false);
    // });

    //TODO: save local
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const AccountScreen(true, true)),
    );
  }

  getBluetoothCharacteristicList() async {
    if (connectedDevice != null &&
        connectedDevice!.isConnected &&
        connectedCharacteristic == null) {
      //CHECK valid service
      //Check if characteristic valid

      for (BluetoothService service in _services) {
        for (BluetoothCharacteristic c in service.characteristics) {
          // final isWrite = characteristic.properties.write;
          bool read = c.properties.read;
          bool write = c.properties.write || c.properties.writeWithoutResponse;
          bool notify = c.properties.notify;
          if (read && write && notify) {
            try {
              await c.setNotifyValue(true);
              var _tmpSup = c.lastValueStream.listen((value) async {
                var msg = _onDataReceived(value);
                // debugPrint('Read value: $msg\n');
                responseMsg += msg + "\n";
                // await c.setNotifyValue(false);
                if (msg.contains(Constants.command_LTE_Result)) {
                  // await c.setNotifyValue(true);
                  connectedCharacteristic = c;
                  // await connectedCharacteristic!.setNotifyValue(true);
                  // this._lastValueSubscription =
                  //     c.lastValueStream.listen((value) async {
                  //   responseMsg += _onDataReceived(value);
                  //   setState(() {});
                  // });
                }
                setState(() {});
              });

              await c.write(getCommandEndcode(Constants.command_LTE),
                  withoutResponse: c.properties.writeWithoutResponse);
            } catch (e) {
              debugPrint('ERROR: ' + e.toString());
            }
          }
        }
      }
    }
  }

  Future onReConnectPressed() async {
    if (connectedDevice != null)
      connectedDevice!.connectAndUpdateStream().catchError((e) {
        Snackbar.show(ABC.c, prettyException("Connect Error:", e),
            success: false);
      });
  }

  Future onRefresh() {
    if (_isScanning == false) {
      if (!kIsWeb) {
        FlutterBluePlus.startScan(timeout: const Duration(seconds: 15));
      }
    }
    setState(() {});
    return Future.delayed(const Duration(milliseconds: 500));
  }

  Widget? buildScanButton(BuildContext context) {
    if (!kIsWeb) {
      if (FlutterBluePlus.isScanningNow) {
        return FloatingActionButton(
          child: const Icon(Icons.stop),
          onPressed: onStopPressed,
          backgroundColor: Colors.red,
        );
      } else {
        return FloatingActionButton(
          child: const Text("SCAN"),
          onPressed: onScanPressed,
          backgroundColor: Config.appThemeColor,
        );
      }
    }
    return null;
  }

  List<Widget> _buildConnectedDeviceTiles(BuildContext context) {
    return _connectedDevices
        .map(
          (d) => ConnectedDeviceTile(
              device: d,
              onOpen: () {},
              // => Navigator.of(context).push(
              //   MaterialPageRoute(
              //     builder: (context) => DeviceScreen(device: d, BluetoothDevice()),
              //     settings: RouteSettings(name: '/DeviceScreen'),
              //   ),
              // ),
              onConnect: () => {} // onConnectPressed(d),
              ),
        )
        .toList();
  }

  List<Widget> _buildScanResultTiles(BuildContext context) {
    return _scanResults
        .map(
          (r) => ScanResultTile(
            result: r,
            onTap: () => onConnectPressed(r.device),
          ),
        )
        .toList();
  }

  _onRefresh() async {
    setState(() {
      timeSelect = 0;
      currentMode = 0;
      _selectedModes = <bool>[true, false, false, false];
    });
  }

  Widget buildConnectButtonConnectButton(BuildContext context) {
    return Row(children: [
      if (_isConnecting || _isDisconnecting) buildSpinner(context),
      if (connectedDevice != null)
        TextButton(
            onPressed: () {
              // if (_isConnecting)
              //   onCancelPressed();
              // else if (isConnected)
              //   onDisconnectPressed();
              // else
              //   onReConnectPressed();
            },
            child: Text(
              _isConnecting
                  ? "CONNECTING"
                  : (isConnected ? "CONNECTED" : "DISCONNECTED"),
              style: TextStyle(
                  fontSize: 8,
                  color: (isConnected ? Colors.green : Colors.red)),
            ))
    ]);
  }

  Future onDisconnectPressed() async {
    try {
      await connectedDevice!.disconnectAndUpdateStream();
      Snackbar.show(ABC.c, "Disconnect: Success", success: true);
    } catch (e) {
      Snackbar.show(ABC.c, prettyException("Disconnect Error:", e),
          success: false);
    }
  }

  Widget buildSpinner(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.all(14.0),
      child: AspectRatio(
        aspectRatio: 1.0,
        child: CircularProgressIndicator(
          backgroundColor: Colors.black12,
          color: Colors.black26,
        ),
      ),
    );
  }

  Future onCancelPressed() async {
    try {
      await connectedDevice!.disconnectAndUpdateStream(queue: false);
      Snackbar.show(ABC.c, "Cancel: Success", success: true);
    } catch (e) {
      Snackbar.show(ABC.c, prettyException("Cancel Error:", e), success: false);
    }
  }

  _reScan() {
    _hasConnectedDevice = false;
    onDisconnectPressed();
    connectedDevice = null;
    connectedCharacteristic = null;
    onScanPressed();
  }

  @override
  Widget build(BuildContext context) {
    final configs = context.read<ConfigBloc>().configs!;
    super.build(context);
    return Scaffold(
      backgroundColor: const Color.fromRGBO(201, 201, 201, 1),
      key: scaffoldKey,
      appBar: AppBar(
        title: const Text('GoodBones Remote'),
        actions: [
          if (_isConnecting || _isDisconnecting) buildSpinner(context),
          IconButton(
            icon: const Icon(
              Feather.rotate_cw,
              size: 22,
            ),
            onPressed: () {
              if (!isConnected) {
                onReConnectPressed();
              }
            },
          ),
          IconButton(
            icon: const Icon(
              Feather.bluetooth,
              size: 22,
            ),
            onPressed: _reScan,
          ),
        ],
      ),
      body: connectedDevice != null
          ? /*SingleChildScrollView(
              controller: _controller,
              child: Container(
                padding: const EdgeInsets.only(
                    top: 80, bottom: 80, left: 10, right: 5),
                decoration: true //Platform.isAndroid
                    ? const BoxDecoration(
                      image: DecorationImage(
                        image: AssetImage(Config.product),
                        fit: BoxFit.contain,
                      ))
                    : const BoxDecoration(),
                child: ConstrainedBox(
                  constraints: new BoxConstraints(
                    minHeight: widthInPercent(context, 100),
                  ),
                  child: Stack(
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          if (currentMode != 3 && _isON)
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _levelLabel(levelNumber[0]),
                                SizedBox(
                                  height: widthInPercent(context, 20),
                                ),
                                _levelLabel(levelNumber[1]),
                                SizedBox(
                                  height: widthInPercent(context, 20),
                                ),
                                _levelLabel(levelNumber[2]),
                                SizedBox(
                                  height: widthInPercent(context, 20),
                                ),
                                _levelLabel(levelNumber[3]),
                              ],
                            ),
                          const Spacer(),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text(
                                _isConnecting
                                    ? "CONNECTING"
                                    : (isConnected
                                        ? "CONNECTED"
                                        : "DISCONNECTED"),
                                style: TextStyle(
                                    color:
                                        isConnected ? Colors.green : Colors.red,
                                    fontSize: getScreenUnit(context, 8)),
                              ),
                              // SizedBox(
                              //   height: getScreenUnit(context, 10),
                              // ),
                              SizedBox(
                                  width: getScreenUnit(context, 60),
                                  height: getScreenUnit(context, 40),
                                  child: FittedBox(
                                      fit: BoxFit.fill,
                                      child: Switch(
                                        // This bool value toggles the switch.
                                        value: isON,
                                        thumbIcon: thumbIcon,
                                        activeColor: Colors.green,
                                        onChanged: (bool value) {
                                          // This is called when the user toggles the switch.
                                          if (value) {
                                            if (!isConnected) {
                                              onReConnectPressed();
                                            }
                                            // getBluetoothCharacteristic();
                                          } else {
                                            responseMsg = "";
                                          }
                                          setState(() {
                                            _isON = value;
                                          });
                                          updateDeviceMode();
                                          // setState(() {});
                                        },
                                      ))),
                              // SizedBox(
                              //   height: getScreenUnit(context, 10),
                              // ),
                              Text(isON ? "ON" : "OFF",
                                  style: TextStyle(
                                      fontSize: getScreenUnit(context, 10))),
                              SizedBox(
                                height: getScreenUnit(context, 20),
                              ),
                              ToggleButtons(
                                direction: Axis.vertical,
                                onPressed: !_isON
                                    ? null
                                    : (int index) {
                                        // The button that is tapped is set to true, and the others to false.
                                        for (int i = 0;
                                            i < _selectedModes.length;
                                            i++) {
                                          _selectedModes[i] = i == index;
                                        }
                                        setState(() {
                                          currentMode = index;
                                        });
                                        // updateDeviceMode();
                                      },
                                borderRadius:
                                    const BorderRadius.all(Radius.circular(8)),
                                selectedBorderColor: Colors.blue[700],
                                selectedColor: Colors.white,
                                fillColor: Colors.blue[300],
                                color: Colors.blue[900],
                                // disabledColor:Color.fromRGBO(201, 201, 201, 0),
                                textStyle: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: getScreenUnit(context, 14)),
                                constraints: BoxConstraints(
                                  minHeight: getScreenUnit(context, 60),
                                  minWidth: getScreenUnit(context, 80),
                                ),
                                isSelected: _selectedModes,
                                children: modes,
                              ),
                              // Spacer(),
                              SizedBox(
                                height: getScreenUnit(context, 20),
                              ),
                              timeSelectWidget(),
                            ],
                          ),
                        ],
                      ),
                      // Text(
                      //   "R: $responseMsg",
                      //   style: const TextStyle(fontSize: 7),
                      // ),
                    ],
                  ),
                ), // ),
              ))*/
            SingleChildScrollView(
              controller: _controller,
              child: Column(
                children: [
                  // Nửa trên: Hiển thị ghế và cảm biến
                  Container(
                    height: MediaQuery.of(context).size.height * 0.45, // Chiếm 50% màn hình
                    decoration: const BoxDecoration(
                      image: DecorationImage(
                        image: AssetImage(Config.product1), // Ảnh ghế
                        fit: BoxFit.contain,
                      ),
                    ),
                    child: Stack(
                      children: [
                        // Hiển thị vị trí cảm biến tương ứng với mode đã chọn
                        if (currentMode >= 0)
                          Positioned(
                            left: getSensorPosition(currentMode).dx,
                            top: getSensorPosition(currentMode).dy,
                            child: const Icon(Icons.circle, color: Colors.red, size: 20),
                          ),
                      ],
                    ),
                  ),

                  // Nửa dưới: Bảng điều khiển
                  Container(
                    height: MediaQuery.of(context).size.height * 0.55, // Chiếm 50% màn hình
                    padding: const EdgeInsets.all(10),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                      boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 5)],
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Row(
                              children: [
                                Text(
                                  _isConnecting
                                      ? "CONNECTING"
                                      : (isConnected ? "CONNECTED" : "DISCONNECTED"),
                                  style: TextStyle(
                                    color: isConnected ? Colors.green : Colors.red,
                                    fontSize: getScreenUnit(context, 8),
                                  ),
                                ),
                                SizedBox(width: 5),
                                SizedBox(
                                  width: getScreenUnit(context, 60),
                                  height: getScreenUnit(context, 40),
                                  child: FittedBox(
                                    fit: BoxFit.fill,
                                    child: Switch(
                                      value: isON,
                                      thumbIcon: thumbIcon,
                                      activeColor: Colors.green,
                                      onChanged: (bool value) {
                                        if (value) {
                                          if (!isConnected) {
                                            onReConnectPressed();
                                          }
                                        } else {
                                          responseMsg = "";
                                        }
                                        setState(() {
                                          _isON = value;
                                        });
                                        updateDeviceMode();
                                      },
                                    ),
                                  ),
                                ),
                                Text(
                                  isON ? "ON" : "OFF",
                                  style: TextStyle(fontSize: getScreenUnit(context, 10)),
                                ),
                              ],
                            ),

                            const Text(
                              "Select Sitting Mode",
                              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                        SizedBox(height: 10),

                        // Hiển thị chế độ ngồi theo dạng GridView
                        Expanded(
                          child: Opacity(
                            opacity: isON ? 1.0 : 0.5, // Làm mờ nếu isON = false
                            child: AbsorbPointer(
                              absorbing: !isON, // Chặn thao tác khi isON = false
                              child: GridView.builder(
                                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 4, // Hiển thị 4 mode trên mỗi hàng
                                  childAspectRatio: 1.2,
                                  crossAxisSpacing: 10,
                                  mainAxisSpacing: 10,
                                ),
                                itemCount: modes.length,
                                itemBuilder: (context, index) {
                                  return GestureDetector(
                                    onTap: () {
                                      if (isON) {
                                        setState(() {
                                          currentMode = index;
                                          updateDeviceMode(); // Cập nhật mode trên ghế
                                        });
                                      }
                                    },
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: currentMode == index ? Colors.blue[200] : Colors.white,
                                        borderRadius: BorderRadius.circular(10),
                                        border: Border.all(color: Colors.blue),
                                      ),
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Text(
                                            "C${index + 1}",
                                            style: const TextStyle(fontWeight: FontWeight.bold),
                                          ),
                                          Text(
                                            modeDescriptions[index],
                                            textAlign: TextAlign.center,
                                            style: const TextStyle(fontSize: 12),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            )
          : RefreshIndicator(
              onRefresh: onRefresh,
              child: _scanResults.isNotEmpty
                  ? ListView(
                      children: <Widget>[
                        ..._buildConnectedDeviceTiles(context),
                        ..._buildScanResultTiles(context),
                      ],
                    )
                  : Container(
                      alignment: Alignment.center,
                      height: MediaQuery.of(context).size.height * 0.80,
                      width: double.infinity,
                      child: const EmptyPageWithImage(
                        image: Config.noDeviceImage,
                        title: 'No Device Connected',
                        description:
                            "Please click \"SCAN\" button to connect the device.",
                      ),
                    ),
            ),
      floatingActionButton:
          _hasConnectedDevice ? null : buildScanButton(context),
    );
  }

  @override
  bool get wantKeepAlive => true;

  final MaterialStateProperty<Icon?> thumbIcon =
      MaterialStateProperty.resolveWith<Icon?>(
    (Set<MaterialState> states) {
      if (states.contains(MaterialState.selected)) {
        return const Icon(Icons.check);
      }
      return const Icon(Icons.close);
    },
  );

  _levelLabel(value) {
    return Text(
      _isPause ? "Pause" : "${value} mmHg --",
      style: TextStyle(
          color: Colors.red[900],
          fontWeight: FontWeight.w700,
          fontSize: getScreenUnit(context, 12)),
    );
  }

  getLevelNumber(level) {
    var min = 10;
    var max = 20;
    if (currentMode == 1) {
      //mode 2
      min = 20;
      max = 30;
    }
    if (currentMode == 2) {
      //mode 3
      min = 30;
      max = 40;
    }
    switch (level) {
      case 1:
        return min;
      case 2:
        return min + 4;
      case 3:
        return min + 7;
      case 4:
        return max;
    }
  }

  loadLevelNumber() {
    if (_isRunning) {
      Random random = new Random();
      var min = 10;
      var max = 20;
      if (currentMode == 1) {
        //mode 2
        min = 20;
        max = 30;
      }
      if (currentMode == 2) {
        //mode 3
        min = 30;
        max = 40;
      }
      levelNumber[0] = min + (random.nextInt(100) - 50) / 100;
      levelNumber[1] = min + 4 + (random.nextInt(100) - 50) / 100;
      levelNumber[2] = min + 7 + (random.nextInt(100) - 50) / 100;
      levelNumber[3] = min + 10 + (random.nextInt(100) - 50) / 100;
      setState(() {});

      Future.delayed(Duration(seconds: 1)).then((value) {
        loadLevelNumber();
      });
    }
  }

  updateDeviceMode() {
    if (!_isON) {
      _commandTimer(0);
      _commandWOUT(0);
      setState(() {
        _isRunning = false;
      });
      return;
    }
    if (!_isRunning) {
      _isRunning = true;
      loadLevelNumber();
    }
    var tmpMode = currentMode;
    switch (currentMode) {
      case 0:
        //mode 1
        _commandTimer(5);
        _commandWOUT(100);
        break;
      case 1:
        //mode 2
        _commandTimer(10);
        _commandWOUT(100);
        break;
      case 2:
        //mode 3
        _commandTimer(15);
        _commandWOUT(100);
        break;
      case 3:
        //massage
        _commandTimer(20);
        _commandWOUT(100);
        break;
    }
    if (timeSelect != 0) {
      Future.delayed(Duration(seconds: timeSelect)).then((value) {
        _commandTimer(0);
        _commandWOUT(0);
        _isPause = true;
        setState(() {});
        Future.delayed(Duration(seconds: timeSelect)).then((value) {
          _isPause = false;
          setState(() {});
          updateDeviceMode();
        });
      });
    } else {
      Future.delayed(Duration(seconds: 1)).then((value) {
        updateDeviceMode();
      });
    }
    // }
  }

  Widget timeSelectWidget() {
    return Container(
        height: getScreenUnit(context, 40),
        width: getScreenUnit(context, 80),
        child: DropdownButton<int>(
          value: timeSelect,
          icon: Icon(
            Icons.timer_outlined,
            color: Colors.blue[900],
          ),
          iconSize: getScreenUnit(context, 24),
          elevation: 16,
          isExpanded: true,
          style: TextStyle(
              color: Colors.blue[800],
              fontWeight: FontWeight.bold,
              fontSize: getScreenUnit(context, 14)),
          underline: Container(
            height: getScreenUnit(context, 1),
            color: Colors.blue[700],
          ),
          onChanged: !_isON
              ? null
              : (int? value) {
                  // This is called when the user selects an item.
                  setState(() {
                    timeSelect = value!;
                    // updateDeviceMode();
                  });
                },
          items: times.map<DropdownMenuItem<int>>((int value) {
            return DropdownMenuItem<int>(
              value: value,
              child: value == 0 ? Text("Default") : Text("${value}s "),
            );
          }).toList(),
        ));
  }

  _commandTimer(int value) {
    writeCommand("WRHZ=$value"); //10s=0.1hz
  }

  _commandWOUT(int value) {
    writeCommand("WOUT=$value"); //10s=0.1hz
  }

  writeCommand(command) async {
    debugPrint('writeCommand>>> $command ');
    if (connectedCharacteristic != null && isConnected) {
      final convertedCommand = getCommandEndcode(command);
      await connectedCharacteristic!.write(convertedCommand,
          withoutResponse:
              connectedCharacteristic!.properties.writeWithoutResponse);
    }
  }

  getCommandEndcode(command) {
    return const AsciiEncoder().convert(command);
  }

  String _onDataReceived(List<int> data) {
    // Allocate buffer for parsed data
    int backspacesCounter = 0;
    data.forEach((byte) {
      if (byte == 8 || byte == 127) {
        backspacesCounter++;
      }
    });
    Uint8List buffer = Uint8List(data.length - backspacesCounter);
    int bufferIndex = buffer.length;

    // Apply backspace control character
    backspacesCounter = 0;
    for (int i = data.length - 1; i >= 0; i--) {
      if (data[i] == 8 || data[i] == 127) {
        backspacesCounter++;
      } else {
        if (backspacesCounter > 0) {
          backspacesCounter--;
        } else {
          buffer[--bufferIndex] = data[i];
        }
      }
    }

    // Create message if there is new line character
    String dataString = String.fromCharCodes(buffer);
    return dataString;
  }

  static getScreenUnit(context, value) {
    return (MediaQuery.of(context).size.width * value / 390);
  }

  static double widthInPercent(BuildContext context, double percent) {
    final toDouble = percent / 100;
    return MediaQuery.of(context).size.width * toDouble;
  }

  static isMobile(context) {
    return (MediaQuery.of(context).size.width < 600);
  }

  Offset getSensorPosition(int mode) {
    switch (mode) {
      case 0: return Offset(148, 130); // C1: Sit upright
      case 1: return Offset(130, 130); // C2: Slouching forward
      case 2: return Offset(148, 190); // C3: Looking down
      case 3: return Offset(148, 50);  // C4: Leaning back
      case 4: return Offset(148, 230);  // C5: Sliding down
      case 5: return Offset(80, 130);  // C6: Reaching left
      case 6: return Offset(80, 180);  // C7: Leaning left
      case 7: return Offset(110, 130);  // C8: Slightly leaning left
      case 8: return Offset(210, 130); // C9: Reaching right
      case 9: return Offset(210, 180); // C10: Leaning right
      case 10: return Offset(183, 130);// C11: Slightly leaning right
      case 11: return Offset(-100000, -100000);    // C12: No user detected
      default: return Offset(100, 200);
    }
  }

  final List<String> modeDescriptions = [
    "Sit upright",
    "Slouching forward",
    "Looking down",
    "Leaning back",
    "Sliding down",
    "Reaching left",
    "Leaning left",
    "Slightly leaning left",
    "Reaching right",
    "Leaning right",
    "Slightly leaning right",
    "No user detected"
  ];

  Map<String, int> sensorValues = {
    "neck": 0,
    "upperBack": 0,
    "midBack": 0,
    "lowerBack": 0,
    "leftShoulder": 0,
    "rightShoulder": 0,
    "leftHip": 0,
    "rightHip": 0,
  };

  Map<String, Offset> sensorPositions = {
    "neck": Offset(100, 50),
    "upperBack": Offset(100, 100),
    "midBack": Offset(100, 150),
    "lowerBack": Offset(100, 200),
    "leftShoulder": Offset(50, 75),
    "rightShoulder": Offset(150, 75),
    "leftHip": Offset(50, 225),
    "rightHip": Offset(150, 225),
  };

  String selectedSensor = "";

  Color getSensorColor(int value) {
    if (value >= 5) return Colors.red;
    if (value <= -5) return Colors.purple;
    return Colors.green;
  }
}
