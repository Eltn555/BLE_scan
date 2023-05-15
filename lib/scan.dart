import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

import 'device_screen.dart';

late String resultText;

void  main () {
  runApp ( MyApp ());
}

class MyApp extends StatelessWidget {
  final title = 'BLE Set Notification';
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: title,
      home: MyHomePage(title: title),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key? key, required this.title}) : super(key: key);
  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  FlutterBluePlus flutterBlue = FlutterBluePlus.instance;
  List<ScanResult> scanResultList = [];
  bool _isScanning = false;

  @override
  initState () {
    super.initState();
    // reset bluetooth
    initBle();
  }

  void  initBle () {
    // listener to get BLE scan status
    flutterBlue.isScanning.listen((isScanning) {
      _isScanning = isScanning;
      setState (() {});
    });
  }

  /*
  Scan start/stop function
  */
  scan() async {
    if (!_isScanning) {
      // if not scanning
      // Delete the previously scanned list
      scanResultList.clear();
      // start scanning, timeout 4 seconds
      flutterBlue.startScan(timeout: Duration(seconds: 4));
      // scan result listener
      flutterBlue.scanResults.listen((results) {
        scanResultList = results;
        // update the UI
        setState (() {});
      });
    } else {
      // if scanning, stop scanning
      flutterBlue.stopScan();
    }
  }

  /*
   From here, functions for device-specific output
  */
  /* Device signal value widget */
  Widget deviceSignal(ScanResult r) {
    return Text(r.rssi.toString());
  }

  /* Device's MAC address widget */
  Widget deviceMacAddress(ScanResult r) {
    return Text(r.device.id.id);
  }

  /* device name widget */
  Widget deviceName(ScanResult r) {
    String name = '';

    if (r.device.name.isNotEmpty) {
      // if device.name has a value
      name = r.device.name;
    } else if (r.advertisementData.localName.isNotEmpty) {
      // If advertisementData.localName has a value
      name = r.advertisementData.localName;
    } else {
      // If neither exists, the name is unknown...
      name = 'N/A';
    }
    return Text(name);
  }

  /* BLE icon widget */
  Widget leading(ScanResult r) {
    return CircleAvatar(
      child: Icon(
        Icons.bluetooth,
        color: Colors.white,
      ),
      backgroundColor: Colors.cyan,
    );
  }

  /* Function called when a device item is tapped */
  void onTap(ScanResult r) {
    // just print the name
    print('${r.device.name}');
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => DeviceScreen(device: r.device)),
    );
  }

  /* device item widget */
  Widget listItem(ScanResult r) {
    return ListTile(
      onTap: () => onTap(r),
      leading: leading(r),
      title: deviceName(r),
      subtitle: deviceMacAddress(r),
      trailing: deviceSignal(r),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar :  AppBar (
        title: Text(widget.title),
      ),
      body: Center(
        /* Print device list */
        child: ListView.separated(
          itemCount: scanResultList.length,
          itemBuilder: (context, index) {
            return listItem(scanResultList[index]);
          },
          separatorBuilder: (BuildContext context, int index) {
            return  Divider ();
          },
        ),
      ),
      /* Search for devices or stop searching */
      floatingActionButton: FloatingActionButton(
        onPressed: scan,
        // Displays the stop icon if scanning, and the search icon if stopped
        child: Icon(_isScanning ? Icons.stop : Icons.search),
      ),
    );
  }
}