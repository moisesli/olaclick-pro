import 'dart:async';
import 'dart:ui';
import 'package:async/async.dart';
// ignore: import_of_legacy_library_into_null_safe
import 'package:esc_pos_bluetooth/esc_pos_bluetooth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_ble_lib/flutter_ble_lib.dart';
// ignore: import_of_legacy_library_into_null_safe
import 'package:flutter_blue/flutter_blue.dart' as blueB;
// ignore: import_of_legacy_library_into_null_safe
import 'package:flutter_bluetooth_basic/flutter_bluetooth_basic.dart';
import 'package:geolocator/geolocator.dart';
// ignore: import_of_legacy_library_into_null_safe
import 'package:location/location.dart';
import 'package:olaclick/resources/app_config.dart';
import 'package:olaclick/src/provider/language_provider.dart';
import 'package:provider/provider.dart';
// ignore: import_of_legacy_library_into_null_safe
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'dart:io';

// ignore: must_be_immutable
class ConfigPrinterScreen extends StatefulWidget {
  @override
  _ConfigPrinterScreenState createState() => _ConfigPrinterScreenState();
}

class _ConfigPrinterScreenState extends State<ConfigPrinterScreen> {
  blueB.BluetoothState? bluetoothState = blueB.BluetoothState.off;
  ServiceStatus? locationState = ServiceStatus.disabled;

  String selectedPrintMode = "bluetooth";

  List<PrinterBluetooth> printers = [];
  List<PrinterBluetooth> allDevices = [];
  late String connectedPrinterMacAddress = "";

  blueB.FlutterBlue flutterBlue = blueB.FlutterBlue.instance;
  PrinterBluetoothManager printerManager = PrinterBluetoothManager();

  late RestartableTimer restartableTimer;
  late Timer timer;

  bool isPrintersScanLoading = false;
  bool isLocationActive = false;
  @override
  void initState() {
    isBluetoothEnabled();
    isLocationEnabled();

    flutterBlue.startScan(timeout: Duration(seconds: 4));
    flutterBlue.scanResults.listen((results) {
      for (blueB.ScanResult r in results) {
        print('Device ${r.device.name} found!');
      }
    });

    chargePreferences();
    super.initState();
  }

  @override
  void dispose() {
    restartableTimer.cancel();
    flutterBlue.stopScan();
    printerManager.stopScan();
    super.dispose();
  }

  // FIND DEVICE BEFORE TURN ON BLUETOOH
  void isBluetoothEnabled() async {
    if (Platform.isAndroid) {
      BluetoothManager bluetoothManager = BluetoothManager.instance;
      bluetoothManager.state.listen((val) {
        if (val == 12) {
          scanPrinters();
        } else if (val == 10) {}
      });
    } else if (Platform.isIOS) {
      BleManager bleManager = BleManager();
      await bleManager.createClient();
      BluetoothState currentState = await bleManager.bluetoothState();
      if (currentState.index == 4) {
        //no make nothing
      } else {
        setState(() {
          scanPrinters();
        });
      }
    }
  }

  //TURN ON GPS AUTOMATICALLY
  Future<bool> isLocationEnabled() async {
    var location = new Location();
    await location.requestService().then((onValue) {
      print(onValue);
      isLocationActive = onValue;
      if (isLocationActive == true) {
        locationState = ServiceStatus.enabled;
        return isLocationActive;
      } else if (isLocationActive == false) {
        locationState = ServiceStatus.disabled;
        return isLocationActive;
      }
    });
    return isLocationActive;
  }

  //SCAN PRINTERS
  Future<void> scanPrinters() async {
    //I ADD THIS CONDITIONAL BECAUSE THE RESTARTABLETIMER CONTINIE WITHOUT SELECT PRINTER

    restartableTimer = RestartableTimer(
      const Duration(seconds: 2),
      () {
        print("entrada Buscar impresoras");
        setState(() {
          isPrintersScanLoading = true;
        });
        printerManager.startScan(Duration(seconds: 5));
        new Future.delayed(Duration(seconds: 5), () {
          setState(() {
            isPrintersScanLoading = false;
          });
        });
        timer = Timer.periodic(Duration(seconds: 1), (timer) {
          print(
              "entrada 15 segundos máximo - segundo:" + timer.tick.toString());
          printerManager.scanResults.listen((results) {
            print(results.toList());
          });
          //Stop if second equal to 15ƒ∂∂
          if (timer.tick == 10) {
            restartableTimer.reset();
            timer.cancel();
          }
        });
      },
    );
  }

  chargePreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      connectedPrinterMacAddress = prefs.getString('MAC_ADDRESS') ?? "";
    });
  }

  void connectPrinter(PrinterBluetooth streamPrinters) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('MAC_ADDRESS', streamPrinters.address);
    setState(() {
      connectedPrinterMacAddress = prefs.getString('MAC_ADDRESS')!;
    });
  }

  void desconnectPrinter(PrinterBluetooth streamPrinters) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.remove('MAC_ADDRESS');
    print("valor saved " + connectedPrinterMacAddress);
    setState(() {
      connectedPrinterMacAddress = "";
    });
    print("valor saved luego " + connectedPrinterMacAddress);
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Consumer<LanguageProvider>(builder: (context, provider, snapshot) {
      return Scaffold(
        appBar: AppBar(
            //delete arrow back
            automaticallyImplyLeading: false,
            actions: [
              GestureDetector(
                  onTap: () async {
                    Navigator.pop(context, printers);
                    restartableTimer.cancel();
                    timer.cancel();
                  },
                  child: Icon(Icons.close)),
              SizedBox(
                width: 20,
              ),
            ],
            title: Text(AppLocalizations.of(context)!.configPrinterModalTitle)),
        body: Container(
            padding: EdgeInsets.only(right: 12, left: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  height: 10,
                ),
                Row(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(
                          //add string value const
                          color: selectedPrintMode == "bluetooth"
                              ? Colors.blue
                              : Colors.grey,
                        ),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      width: size.width * 0.49,
                      height: size.height * 0.11,
                      child: Row(
                        children: [
                          Radio(
                            value: "bluetooth",
                            groupValue: selectedPrintMode,
                            onChanged: (value) {
                              setState(() {
                                print(value);
                                selectedPrintMode = value.toString();
                              });
                            },
                          ),
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(AppLocalizations.of(context)!.bluetooth,
                                  style: TextStyle(
                                    color: selectedPrintMode == "bluetooth"
                                        ? Colors.black
                                        : Colors.grey,
                                  )),
                              Container(
                                width: size.width * 0.2,
                                child: Text(
                                  AppLocalizations.of(context)!
                                      .formatsAvailable,
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: selectedPrintMode == "bluetooth"
                                        ? Colors.black
                                        : Colors.grey,
                                  ),
                                ),
                              )
                            ],
                          ),
                        ],
                      ),
                    ),
                    SizedBox(width: 5),
                  ],
                ),
                SizedBox(height: 20),
                Container(
                    child: Text(
                  AppLocalizations.of(context)!.connectPrinterBluetooth,
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
                      fontSize: 18),
                )),
                SizedBox(
                  height: 10,
                ),
                StreamBuilder<blueB.BluetoothState>(
                    stream: flutterBlue.state,
                    initialData: blueB.BluetoothState.off,
                    builder: (context, snapshot) {
                      bluetoothState = snapshot.data;
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          locationState != ServiceStatus.enabled &&
                                  bluetoothState != blueB.BluetoothState.on
                              ? Container(
                                  child: Text(
                                      AppLocalizations.of(context)!
                                          .activeBluetoothAndGps,
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.grey,
                                      )))
                              //TODO:no width no height
                              : SizedBox(),
                          SizedBox(
                            height: 10,
                          ),
                          StreamBuilder<ServiceStatus>(
                              stream: Geolocator.getServiceStatusStream(),
                              initialData: locationState,
                              //check gsp active why not.
                              builder: (context, snapshot) {
                                //locationState = snapshot.data;
                                if (locationState == ServiceStatus.disabled) {
                                  locationState = snapshot.data;
                                  locationState = ServiceStatus.enabled;
                                } else {
                                  locationState = snapshot.data;
                                }
                                return Column(
                                  children: [
                                    Row(
                                      children: [
                                        Row(
                                          children: [
                                            Icon(Icons.bluetooth_connected,
                                                size: 30,
                                                color: bluetoothState ==
                                                        blueB.BluetoothState.on
                                                    ? Colors.green
                                                    : Colors.grey),
                                            Container(
                                              width: size.width * 0.45,
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                      AppLocalizations.of(
                                                              context)!
                                                          .stateBluetooth,
                                                      textAlign:
                                                          TextAlign.center,
                                                      style: TextStyle(
                                                          color: Colors.black,
                                                          fontSize: 14)),
                                                  Text(
                                                      bluetoothState ==
                                                              blueB
                                                                  .BluetoothState
                                                                  .on
                                                          ? AppLocalizations.of(
                                                                  context)!
                                                              .active
                                                          : AppLocalizations.of(
                                                                  context)!
                                                              .inactive,
                                                      style: TextStyle(
                                                          color: bluetoothState ==
                                                                  blueB
                                                                      .BluetoothState
                                                                      .on
                                                              ? Colors.green
                                                              : Colors.red))
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                        Row(
                                          children: [
                                            Icon(Icons.gps_fixed,
                                                size: 30,
                                                color: locationState ==
                                                        ServiceStatus.enabled
                                                    ? Colors.green
                                                    : Colors.grey),
                                            Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                    AppLocalizations.of(
                                                            context)!
                                                        .stateGPS,
                                                    style: TextStyle(
                                                        color: Colors.black,
                                                        fontSize: 14)),
                                                Text(
                                                    locationState ==
                                                            ServiceStatus
                                                                .enabled
                                                        ? AppLocalizations.of(
                                                                context)!
                                                            .active
                                                        : AppLocalizations.of(
                                                                context)!
                                                            .inactive,
                                                    style: TextStyle(
                                                        color: locationState ==
                                                                ServiceStatus
                                                                    .enabled
                                                            ? Colors.green
                                                            : Colors.red))
                                              ],
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                    SizedBox(
                                      height: 15,
                                    ),
                                    isLocationActive == true &&
                                            bluetoothState ==
                                                blueB.BluetoothState.on
                                        ? Container(
                                            child: Text(
                                                AppLocalizations.of(context)!
                                                    .pressButtonPrintterToTurnOn,
                                                style: TextStyle(
                                                    fontSize: 17,
                                                    fontWeight: FontWeight.w600,
                                                    color: Colors.blueGrey)),
                                          )
                                        : SizedBox(),
                                    SizedBox(
                                      height: 10,
                                    ),
                                    isLocationActive == true &&
                                            bluetoothState ==
                                                blueB.BluetoothState.on
                                        ? Container(
                                            width: size.width * 0.90,
                                            height: size.height * 0.44,
                                            child: Column(
                                              children: [
                                                Container(
                                                    decoration: BoxDecoration(
                                                      border: Border.all(
                                                        color: Colors.grey,
                                                      ),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              10),
                                                    ),
                                                    child: StreamBuilder<
                                                            List<
                                                                PrinterBluetooth>>(
                                                        stream: printerManager
                                                            .scanResults,
                                                        initialData: printers,
                                                        builder: (context,
                                                            snapshot) {
                                                          allDevices =
                                                              snapshot.data!;
                                                          // List<PrinterBluetooth> onlyPrinters =
                                                          //     allDevices.where((print) => print.name.contains('PRINT')).toList();
                                                          printers = allDevices;
                                                          return Column(
                                                            crossAxisAlignment:
                                                                CrossAxisAlignment
                                                                    .start,
                                                            children: [
                                                              Padding(
                                                                padding:
                                                                    const EdgeInsets
                                                                            .all(
                                                                        5.0),
                                                                child: Row(
                                                                  mainAxisAlignment:
                                                                      MainAxisAlignment
                                                                          .spaceBetween,
                                                                  children: [
                                                                    Container(
                                                                        child: Text(
                                                                            AppLocalizations.of(context)!.lookingForBluetoothPrinter)),
                                                                    Container(
                                                                        width:
                                                                            20,
                                                                        height:
                                                                            20,
                                                                        child: isPrintersScanLoading ==
                                                                                true
                                                                            ? CircularProgressIndicator()
                                                                            : SizedBox())
                                                                  ],
                                                                ),
                                                              ),
                                                              Divider(
                                                                  height: 2,
                                                                  color: Colors
                                                                      .grey),
                                                              printers.length >
                                                                      0
                                                                  ? Container(
                                                                      width:
                                                                          450,
                                                                      height:
                                                                          size.height *
                                                                              0.3,
                                                                      child: ListView.builder(
                                                                          itemCount: allDevices.length,
                                                                          itemBuilder: (_, i) {
                                                                            return Container(
                                                                              //desing button (Conectar)
                                                                              padding: EdgeInsetsDirectional.all(8),
                                                                              child: Row(
                                                                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                                                children: [
                                                                                  Row(
                                                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                                                    children: [
                                                                                      Icon(Icons.print),
                                                                                      SizedBox(width: 15),
                                                                                      Column(
                                                                                        crossAxisAlignment: CrossAxisAlignment.start,
                                                                                        children: [
                                                                                          Container(
                                                                                            width: 90,
                                                                                            child: Text(allDevices[i].name, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                                                                                          ),
                                                                                          Text(allDevices[i].address == connectedPrinterMacAddress ? AppLocalizations.of(context)!.connected : AppLocalizations.of(context)!.disconnect, style: TextStyle(fontSize: 13, color: allDevices[i].address == connectedPrinterMacAddress ? Colors.green : Colors.red))
                                                                                        ],
                                                                                      ),
                                                                                    ],
                                                                                  ),
                                                                                  // SizedBox(width: 110),
                                                                                  allDevices[i].address != connectedPrinterMacAddress
                                                                                      ? Container(
                                                                                          height: size.height * 0.05,
                                                                                          child: MaterialButton(
                                                                                            color: Colors.blue,
                                                                                            shape: RoundedRectangleBorder(
                                                                                              borderRadius: BorderRadius.circular(5),
                                                                                            ),
                                                                                            onPressed: () async {
                                                                                              connectPrinter(allDevices[i]);
                                                                                            },
                                                                                            child: Text(
                                                                                              AppLocalizations.of(context)!.connect,
                                                                                              style: TextStyle(color: Colors.white),
                                                                                            ),
                                                                                          ),
                                                                                        )
                                                                                      : GestureDetector(
                                                                                          onTap: () async {
                                                                                            desconnectPrinter(allDevices[i]);
                                                                                          },
                                                                                          child: Container(
                                                                                            decoration: BoxDecoration(
                                                                                              border: Border(
                                                                                                bottom: BorderSide(
                                                                                                  color: Colors.blue,
                                                                                                  width: 3,
                                                                                                ),
                                                                                              ),
                                                                                            ),
                                                                                            child: Text(
                                                                                              AppLocalizations.of(context)!.disconnect,
                                                                                              style: TextStyle(
                                                                                                color: Colors.blue,
                                                                                              ),
                                                                                            ),
                                                                                          ),
                                                                                        ),
                                                                                ],
                                                                              ),
                                                                            );
                                                                          }))
                                                                  : Container(
                                                                      width:
                                                                          350,
                                                                      height: size
                                                                              .height *
                                                                          0.35,
                                                                      child: Center(
                                                                          child: Column(
                                                                        mainAxisAlignment:
                                                                            MainAxisAlignment.center,
                                                                        children: [
                                                                          Text(AppLocalizations.of(context)!
                                                                              .noPrinterFound),
                                                                          SizedBox(
                                                                              height: 15),
                                                                          Stack(
                                                                              children: [
                                                                                Icon(Icons.print, size: 80, color: Colors.grey),
                                                                                Padding(
                                                                                  padding: const EdgeInsets.only(left: 60, top: 60),
                                                                                  child: Icon(Icons.sentiment_very_dissatisfied, size: 40, color: Colors.red),
                                                                                )
                                                                              ]),
                                                                          SizedBox(
                                                                              height: 10),
                                                                          Container(
                                                                              width: 180,
                                                                              child: Text(AppLocalizations.of(context)!.checkTheBluetoothIsActivated, textAlign: TextAlign.center))
                                                                        ],
                                                                      )),
                                                                    ),
                                                            ],
                                                          );
                                                        })),
                                              ],
                                            ),
                                          )
                                        : SizedBox(),
                                    Container(
                                        child: Center(
                                            child: Text(
                                                AppConfig.of(context)!.version,
                                                style: TextStyle(
                                                    fontSize:
                                                        size.width * 0.02))))
                                  ],
                                );
                              }),
                        ],
                      );
                    }),
              ],
            )),
      );
    });
  }
}
