import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:provider/provider.dart';
import 'package:wordpress_app/blocs/config_bloc.dart';
import 'package:wordpress_app/config/config.dart';
import 'package:wordpress_app/models/article.dart';
import 'package:wordpress_app/utils/empty_image.dart';
import 'package:flutter/material.dart';

class OldRemoteTab extends StatefulWidget {
  const OldRemoteTab({Key? key}) : super(key: key);

  @override
  State<OldRemoteTab> createState() => _OldRemoteTabState();
}

class _OldRemoteTabState extends State<OldRemoteTab>
    with AutomaticKeepAliveClientMixin {
  final List<Article> _articles = [];
  ScrollController? _controller;
  bool _loading = false;
  bool? _hasData = false;
  bool _isOn = false;
  var scaffoldKey = GlobalKey<ScaffoldState>();
  List<bool> _selectedFruits = <bool>[true, false, false, false];
  List<Widget> modes = <Widget>[
    Text('M1'),
    Text('M2'),
    Text('M3'),
    Text('Massage')
  ];
  List<int> times = <int>[5, 10, 15, 20, 30, 45, 60];
  int timeSelect = 10;
  int currentMode = 0;
  List<Widget> statusList = <Widget>[
    Text('ON'),
    Text('OFF'),
  ];
  List<bool> _selectedStatus = <bool>[true, false];

  @override
  void initState() {
    _hasData = true;
    _loading = true;
    _loading = false;
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    if (_controller != null) _controller!.dispose();
  }

  _onRefresh() async {
    setState(() {
      timeSelect = 10;
      currentMode = 0;
      _selectedFruits = <bool>[true, false, false, false];
    });
  }

  final MaterialStateProperty<Icon?> thumbIcon =
      MaterialStateProperty.resolveWith<Icon?>(
    (Set<MaterialState> states) {
      if (states.contains(MaterialState.selected)) {
        return const Icon(Icons.check);
      }
      return const Icon(Icons.close);
    },
  );

  @override
  Widget build(BuildContext context) {
    final configs = context.read<ConfigBloc>().configs!;
    super.build(context);
    return Scaffold(
      backgroundColor: Color.fromRGBO(201, 201, 201, 1),
      key: scaffoldKey,
      appBar: AppBar(
        title: const Text('Smart Socks Info').tr(),
        actions: [
          IconButton(
            icon: const Icon(
              Feather.rotate_cw,
              size: 22,
            ),
            onPressed: _onRefresh,
          ),
          const SizedBox(
            width: 10,
          )
        ],
      ),
      body: SingleChildScrollView(
        controller: _controller,
        child: _hasData == false
            ? Container(
                alignment: Alignment.center,
                height: MediaQuery.of(context).size.height * 0.80,
                width: double.infinity,
                child: const EmptyPageWithImage(
                    image: Config.noDeviceImage, title: 'No Device Connected'),
              )
            : Container(
                padding: const EdgeInsets.only(
                    top: 80, bottom: 80, left: 10, right: 5),
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage(Config.product),
                    fit: BoxFit.cover,
                  ),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    if (currentMode != 3)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "${getLevelNumber(1)} mmHg --",
                            style: TextStyle(color: Colors.red[900]),
                          ),
                          const SizedBox(
                            height: 100,
                          ),
                          Text(
                            "${getLevelNumber(2)} mmHg ------",
                            style: TextStyle(color: Colors.red[900]),
                          ),
                          const SizedBox(
                            height: 100,
                          ),
                          Text(
                            "${getLevelNumber(3)} mmHg ------------",
                            style: TextStyle(color: Colors.red[900]),
                          ),
                          const SizedBox(
                            height: 100,
                          ),
                          Text(
                            "${getLevelNumber(4)} mmHg  ------",
                            style: TextStyle(color: Colors.red[900]),
                          ),
                        ],
                      ),
                    Spacer(),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Switch(
                          // This bool value toggles the switch.
                          value: _isOn,
                          thumbIcon: thumbIcon,
                          activeColor: Colors.green,
                          onChanged: (bool value) {
                            // This is called when the user toggles the switch.
                            setState(() {
                              _isOn = value;
                            });
                          },
                        ),
                        Text(_isOn ? "ON" : "OFF"),
                        const SizedBox(
                          height: 20,
                        ),
                        ToggleButtons(
                          direction: Axis.vertical,
                          onPressed: !_isOn
                              ? null
                              : (int index) {
                                  setState(() {
                                    // The button that is tapped is set to true, and the others to false.
                                    for (int i = 0;
                                        i < _selectedFruits.length;
                                        i++) {
                                      _selectedFruits[i] = i == index;
                                    }
                                    currentMode = index;
                                  });
                                },
                          borderRadius:
                              const BorderRadius.all(Radius.circular(8)),
                          selectedBorderColor: Colors.blue[700],
                          selectedColor: Colors.white,
                          fillColor: Colors.blue[300],
                          color: Colors.blue[900],
                          // disabledColor:Color.fromRGBO(201, 201, 201, 0),
                          textStyle:
                              const TextStyle(fontWeight: FontWeight.bold),
                          constraints: const BoxConstraints(
                            minHeight: 60.0,
                            minWidth: 80.0,
                          ),
                          isSelected: _selectedFruits,
                          children: modes,
                        ),
                        // Spacer(),
                        const SizedBox(
                          height: 20,
                        ),
                        timeSelectWidget()
                      ],
                    ),
                  ],
                ),
              ), // ),
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;

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

  Widget timeSelectWidget() {
    return DropdownButton<int>(
      value: timeSelect,
      icon: Icon(Icons.timer_outlined, color: Colors.blue[900]),
      elevation: 20,
      style: TextStyle(color: Colors.blue[800], fontWeight: FontWeight.bold),
      underline: Container(
        height: 1,
        color: Colors.blue[700],
      ),
      onChanged: !_isOn
          ? null
          : (int? value) {
              // This is called when the user selects an item.
              setState(() {
                timeSelect = value!;
              });
            },
      items: times.map<DropdownMenuItem<int>>((int value) {
        return DropdownMenuItem<int>(
          value: value,
          child: Text("  ${value}s "),
        );
      }).toList(),
    );
  }
}
