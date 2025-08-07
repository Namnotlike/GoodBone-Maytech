import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

import "../utils/snackbar.dart";

import "descriptor_tile.dart";

class CharacteristicTile extends StatefulWidget {
  final BluetoothCharacteristic characteristic;
  final List<DescriptorTile> descriptorTiles;

  const CharacteristicTile({Key? key, required this.characteristic, required this.descriptorTiles}) : super(key: key);

  @override
  State<CharacteristicTile> createState() => _CharacteristicTileState();
}

class _CharacteristicTileState extends State<CharacteristicTile> {
  List<int> _value = [];

  late StreamSubscription<List<int>> _lastValueSubscription;

  @override
  void initState() {
    super.initState();
    _lastValueSubscription = widget.characteristic.lastValueStream.listen((value) {
      _value = value;
      var r = _onDataReceived(value);//new String.fromCharCodes(value); //utf8.decode(value);
      // Snackbar.show(ABC.c, "Write: Success", success: true);
      setState(() {});
      Snackbar.show(ABC.c, "listen: Success. Read value: $value. Translate: $r", success: true);
    });
  }

  @override
  void dispose() {
    _lastValueSubscription.cancel();
    super.dispose();
  }

  BluetoothCharacteristic get c => widget.characteristic;

  List<int> _getRandomBytes() {
    // final math = Random();
    // return [math.nextInt(255), math.nextInt(255), math.nextInt(255), math.nextInt(255)];
    String data = "LTE"; //
    return data.codeUnits;
  }

  Future onReadPressed() async {
    try {
      List<int> value = await c.read();
      print('Read value: $value');
      // print(new String.fromCharCodes(c.characteristicUuid.bytes));
      // print(new String.fromCharCodes(value));
      var r = _onDataReceived(value);//new String.fromCharCodes(value); //utf8.decode(value);
      Snackbar.show(ABC.c, "Read: Success. Read value: $value. Translate: $r", success: true);
    } catch (e) {
      Snackbar.show(ABC.c, prettyException("Read Error:", e), success: false);
    }
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

  Future onWritePressed() async {
    try {
      final command = "LTE";
      final convertedCommand = AsciiEncoder().convert(command);
      await c.write(convertedCommand, withoutResponse: c.properties.writeWithoutResponse);//, allowLongWrite: true);
      // await c.write(_getRandomBytes(), withoutResponse: c.properties.writeWithoutResponse);
      // Snackbar.show(ABC.c, "Write: Success", success: true);
      // if (c.properties.read) {
      //   await c.read();
      // }
    } catch (e) {
      Snackbar.show(ABC.c, prettyException("Write Error:", e), success: false);
    }
  }

  Future onSubscribePressed() async {
    try {
      String op = c.isNotifying == false ? "Subscribe" : "Unubscribe";
      await c.setNotifyValue(c.isNotifying == false);
      Snackbar.show(ABC.c, "$op : Success", success: true);
      if (c.properties.read) {
        await c.read();
      }
      setState(() {});
    } catch (e) {
      Snackbar.show(ABC.c, prettyException("Subscribe Error:", e), success: false);
    }
  }

  Widget buildUuid(BuildContext context) {
    String uuid = '0x${widget.characteristic.uuid.toString().toUpperCase()}';
    return Text(uuid, style: TextStyle(fontSize: 13));
  }

  Widget buildValue(BuildContext context) {
    String data = _value.toString();
    return Text(data, style: TextStyle(fontSize: 13, color: Colors.grey));
  }

  Widget buildReadButton(BuildContext context) {
    return TextButton(
        child: Text("Readd"),
        onPressed: () async {
          await onReadPressed();
          setState(() {});
        });
  }

  Widget buildWriteButton(BuildContext context) {
    bool withoutResp = widget.characteristic.properties.writeWithoutResponse;
    return TextButton(
        child: Text(withoutResp ? "WriteNoResp" : "Writee"),
        onPressed: () async {
          await onWritePressed();
          setState(() {});
        });
  }

  Widget buildSubscribeButton(BuildContext context) {
    bool isNotifying = widget.characteristic.isNotifying;
    return TextButton(
        child: Text(isNotifying ? "Unsubscribe" : "Subscribe"),
        onPressed: () async {
          await onSubscribePressed();
          setState(() {});
        });
  }

  Widget buildButtonRow(BuildContext context) {
    bool read = widget.characteristic.properties.read;
    bool write = widget.characteristic.properties.write || widget.characteristic.properties.writeWithoutResponse;
    bool notify = widget.characteristic.properties.notify;
    bool indicate = widget.characteristic.properties.indicate;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // buildReadButton(context),
        // buildWriteButton(context),
        // buildSubscribeButton(context),
        if (read) buildReadButton(context),
        if (write) buildWriteButton(context),
        if (notify || indicate) buildSubscribeButton(context),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return widget.descriptorTiles.length > 0
        ? ExpansionTile(
            title: ListTile(
              title: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  const Text('Characteristic'),
                  buildUuid(context),
                  buildValue(context),
                ],
              ),
              subtitle: buildButtonRow(context),
              contentPadding: const EdgeInsets.all(0.0),
            ),
            children: widget.descriptorTiles,
          )
        : ListTile(
            title: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                const Text('Characteristic'),
                buildUuid(context),
                buildValue(context),
              ],
            ),
            subtitle: buildButtonRow(context),
            contentPadding: const EdgeInsets.all(0.0),
          );
  }

  _parsehr(List<int> value) {
// first sort the values in the list to interpret correctly the bytes
    List<int> valuesorted = [];
    valuesorted.insert(0, value[0]);
    valuesorted.insert(1, value[1]);
    for (var i = 0; i < (value.length - 3); i++) {
      valuesorted.insert(i + 2, value[i + 3]);
      valuesorted.insert(i + 3, value[i + 2]);
    }

// get flags directly from list
    var flags = valuesorted[0];

// get the bytebuffer view of the data to recode it later
    var buffer = new Uint8List.fromList(valuesorted).buffer; // buffer bytes from list

    if (flags == 0) {
      // hr
      var hrbuffer = new ByteData.view(buffer, 1, 1); // get second byte
      var hr = hrbuffer.getUint8(0); // recode as uint8
      print(hr);
    }

    if (flags == 16) {
      // hr
      var hrbuffer = new ByteData.view(buffer, 1, 1); // get second byte
      var hr = hrbuffer.getUint8(0); // recode as uint8

      // rr (more than one can be retrieved in the list)
      var nrr = (valuesorted.length - 2) /
          2; // remove flags and hr from byte count; then split in two since rr is coded as uint16
      List<int> rrs = [];
      for (var i = 0; i < nrr; i++) {
        var rrbuffer = new ByteData.view(buffer, 2 + (i * 2), 2); // get pairs of bytes counting since the 3rd byte
        var rr = rrbuffer.getUint16(0); // recode as uint16
        rrs.insert(i, rr);
      }
      print(rrs);
    }
  }
}
