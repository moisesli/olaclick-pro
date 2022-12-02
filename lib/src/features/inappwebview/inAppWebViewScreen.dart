import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'dart:ui';
import 'package:diacritic/diacritic.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_ble_lib/flutter_ble_lib.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
// ignore: import_of_legacy_library_into_null_safe
import 'package:location/location.dart';
import 'package:olaclick/src/controllers/notification_controller.dart';
import 'package:olaclick/src/features/printer/configPrinterScreen.dart';
import 'package:olaclick/src/model/ticketFormat.dart';
import 'package:olaclick/src/provider/language_provider.dart';
import 'package:olaclick/src/utils/diacritismoney.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
// ignore: import_of_legacy_library_into_null_safe
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart' hide Image;
// ignore: import_of_legacy_library_into_null_safe
import 'package:esc_pos_bluetooth/esc_pos_bluetooth.dart';
// ignore: import_of_legacy_library_into_null_safe
import 'package:esc_pos_utils/esc_pos_utils.dart';
// ignore: import_of_legacy_library_into_null_safe
import 'package:flutter_bluetooth_basic/flutter_bluetooth_basic.dart';
import 'dart:io' show Platform;
// ignore: import_of_legacy_library_into_null_safe
// ignore: import_of_legacy_library_into_null_safe
import 'package:url_launcher/url_launcher.dart';
import 'dart:io';
import 'package:image/image.dart' as ImageTrans;

// ignore: must_be_immutable
class InAppWebViewScreen extends StatefulWidget {
  late final String url;
  late final String urlAPI;
  InAppWebViewScreen({required this.url, required this.urlAPI});
  @override
  _InAppWebViewScreenState createState() => _InAppWebViewScreenState();
}

class _InAppWebViewScreenState extends State<InAppWebViewScreen>
    with WidgetsBindingObserver {
  //DECLARE CONTROLLERS

  late Locale locale = Locale('pt');

  PrinterBluetoothManager printerManager = PrinterBluetoothManager();

  // blueB.FlutterBlue flutterBlue = blueB.FlutterBlue.instance;

  List<PrinterBluetooth> printers = [];
  late List<FormatModel> orderDetail;
  late String connectedPrinterMacAddress = "";
  late PaperSize paperSizeToPrint = PaperSize.mm58;
  ImageTrans.Image? imgRecovery;

  late PullToRefreshController pullToRefreshController;
  NotificationController authController = NotificationController();

  var phoneValue;
  var textValue;

  late String token;
  late String tokeniOS;

  bool showPrintConfigModal = false;
  bool showPrintDirectConfigModal = false;
  bool bluetoothEnabled = false;
  bool locationEnabled = false;

  bool phoneExits = false;
  bool textExists = false;

  late InAppWebViewController webViewController;
  bool isLoadingWebView = false;
  bool clickPrint = true;

  InAppWebViewGroupOptions options = InAppWebViewGroupOptions(
      crossPlatform: InAppWebViewOptions(
          useOnDownloadStart: true,
          javaScriptCanOpenWindowsAutomatically: true,
          useShouldOverrideUrlLoading: true),
      android: AndroidInAppWebViewOptions(
          //cacheMode: AndroidCacheMode.LOAD_CACHE_ELSE_NETWORK,
          useOnRenderProcessGone: true,
          scrollBarStyle: AndroidScrollBarStyle.SCROLLBARS_INSIDE_OVERLAY,
          supportMultipleWindows: true,
          useHybridComposition: true,
          layoutAlgorithm: AndroidLayoutAlgorithm.NARROW_COLUMNS),
      ios: IOSInAppWebViewOptions(
        allowsInlineMediaPlayback: true,
      ));

  @override
  void initState() {
    isLoadingWebView = true;
    pullToRefreshController = PullToRefreshController(
      options: PullToRefreshOptions(
        enabled: true,
        color: Colors.blue,
      ),
      onRefresh: () async {
        if (Platform.isAndroid) {
          webViewController.reload();
        } else if (Platform.isIOS) {
          webViewController.loadUrl(
              urlRequest: URLRequest(url: Uri.parse(widget.url)));
        }
      },
    );

    isBluetoothEnabled();
    scanPrinters();
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  void findingPhoneOrText(List paramsArray) async {
    for (int i = 0; i < paramsArray.length; i++) {
      var paramSplited = paramsArray[i].toString().split("=");

      if (paramSplited.first == "phone") {
        phoneExits = true;
        phoneValue = paramSplited[1];
      }

      if (paramSplited.first == "text") {
        textExists = true;
        textValue = paramSplited[1];
      }
    }
  }

  openUri(Uri? uri) async {
    print("uri");
    var urlToOpen = "https://wa.me/";
    if (uri.toString().contains('whatsapp.com') ||
        uri.toString().contains('whatsapp://') ||
        uri.toString().contains('wa.me')) {
      var queryParams = uri.toString().split('?')[1];
      List paramsArray = queryParams.split("&");
      findingPhoneOrText(paramsArray);
    } else {
      urlToOpen = uri.toString();
    }
    if (phoneExits) {
      urlToOpen += phoneValue;
    }
    if (textExists) {
      urlToOpen += "?text=" + textValue;
    }
    // if (await canLaunch(urlToOpen)) {
      await launch(urlToOpen);
    // } else {
    //   ScaffoldMessenger.of(context).showSnackBar(
    //       SnackBar(content: new Text("Could not open $urlToOpen")));
    // }
  }

  Future<bool> isLocationEnabled() async {
    var location = new Location();
    return await location.requestService().then((onValue) {
      return onValue;
    });
  }

  Future<bool> isBluetoothEnabled() async {
    if (Platform.isAndroid) {
      BluetoothManager bluetoothManager = BluetoothManager.instance;
      bluetoothManager.state.listen((val) {
        if (val == 12) {
          setState(() {
            bluetoothEnabled = true;
          });
        } else if (val == 10) {
          setState(() {
            bluetoothEnabled = false;
          });
        }
      });
    } else if (Platform.isIOS) {
      BleManager bleManager = BleManager();
      await bleManager.createClient();
      BluetoothState currentState = await bleManager.bluetoothState();
      if (currentState.index == 4) {
        setState(() {
          bluetoothEnabled = false;
        });
      } else {
        setState(() {
          bluetoothEnabled = true;
        });
      }
    }
    return bluetoothEnabled;
  }

  Future<void> scanPrinters() async {
    print("antes del scan" + printers.toString());
    printerManager.startScan(Duration(seconds: 3));
    Timer(Duration(seconds: 4), () async {
      printerManager.scanResults.listen((results) {
        setState(() {
          printers = results;
        });
      });
      print("despues del scan" + printers.toString());
    });
  }

  Future<List<FormatModel>> convertFromJsonToObject(List<dynamic> args) async {
    orderDetail =
        List<FormatModel>.from(args.map((x) => FormatModel.fromJson(x)));
    return orderDetail;
  }

  Future<void> printOrder(data, type) async {
    locationEnabled = await isLocationEnabled();
    bluetoothEnabled = await isBluetoothEnabled();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    connectedPrinterMacAddress = prefs.getString('MAC_ADDRESS') ?? "";

    if (!locationEnabled ||
        !bluetoothEnabled ||
        connectedPrinterMacAddress == "") {
      navigateToCongifRoute();
      return;
    }

    // ignore: unnecessary_null_comparison
    else {
      List<FormatModel> listOrderModelValue =
          await convertFromJsonToObject(data);
      orderDetail = listOrderModelValue;

      PrinterBluetooth? printerFound = await getPrinter(
          connectedPrinterMacAddress); // printers only once time!

      printerManager.selectPrinter(printerFound);
      PosPrintResult result = await printerManager.printTicket(
          await formatTicket(paperSizeToPrint),
          queueSleepTimeMs: 20);

      if (result.msg != "Success") {
        await printerManager.printTicket(await formatTicket(paperSizeToPrint));
      }
    }
    //check when open again the app, apper the config print
  }

  Future<dynamic> getPrinter(String macAddress) async {
    // if (printers.length <= 0) {
    //   scanPrinters();
    // }
    PrinterBluetooth sentImpression =
        printers.firstWhere((printer) => printer.address == macAddress);

    //IF FIND DEVICE - SEND TO PRINT
    if (sentImpression.address != null) {
      return sentImpression;
    }
  }

  Future<void> chooseAndSavePrinter(
      PrinterBluetooth printer, PaperSize paperSizeToPrint) async {
    printerManager.selectPrinter(printer);

    PosPrintResult result =
        await printerManager.printTicket(await formatTicket(paperSizeToPrint));

    if (result.msg == "Success") {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.setString('MAC_ADDRESS', printer.address);
    }
  }

  Future<Ticket> formatTicket(PaperSize paper) async {
    final ticket = Ticket(paper);
    var orderToPrint = orderDetail;
    for (var i = 0; i < orderToPrint.length; i++) {
      if (orderToPrint[i].type == "text" ||
          orderToPrint[i].type == "separator" ||
          orderToPrint[i].type == "image" ||
          orderToPrint[i].type == "qr") {
        if (orderToPrint[i].type == "qr") {
          print("hay qr");
          //CONVERT URL TO STRING64
          var urlImage = orderToPrint[i].value.split("base64,");
          var qrValue = urlImage[1];

          print(qrValue);

          var bytes = base64Decode(qrValue);
          ImageTrans.Image img = ImageTrans.decodePng(bytes);
          ImageTrans.Image resized =
              ImageTrans.copyResize(img, width: 140, height: 140);
          ticket.image(resized);
        }
        if (orderToPrint[i].type == "image") {
          //IMAGE
          String imageFromWeb = orderToPrint[i].value;
          Uint8List bytesT = (await NetworkAssetBundle(Uri.parse(imageFromWeb))
                  .load(imageFromWeb))
              .buffer
              .asUint8List();

          ImageTrans.Image img = ImageTrans.decodeJpg(bytesT);
          ImageTrans.Image resized =
              ImageTrans.copyResize(img, width: 100, height: 100);
          ticket.image(resized);
        }
        //QR - String
        if (orderToPrint[i].type == "text" ||
            orderToPrint[i].type == "separator") {
          ticket.text(
            AppUtils.instance.trimCharacter(orderToPrint[i].value),
            styles: PosStyles(
                bold: orderToPrint[i].bold,
                align: orderToPrint[i].align,
                height: orderToPrint[i].height,
                width: orderToPrint[i].width),
          );
        }
      }
    }

    ticket.cut();
    return ticket;
  }

  void catchWindowEvent(CreateWindowAction createWindowRequest,
      InAppWebViewController webNewController) {
    print(createWindowRequest);
    print(webNewController);
    showDialog(
        barrierColor: Color(0x00ffffff),
        context: context,
        builder: (context) {
          AlertDialog alert = AlertDialog(
              backgroundColor: Colors.transparent,
              elevation: 0,
              content: Container(
                width: 5,
                height: 1,
                child: InAppWebView(
                  windowId: createWindowRequest.windowId,
                  initialOptions: InAppWebViewGroupOptions(
                    crossPlatform: InAppWebViewOptions(
                        javaScriptEnabled: false,
                        javaScriptCanOpenWindowsAutomatically: false),
                  ),
                  onWebViewCreated: (InAppWebViewController controller) {
                    print("controler hijo android" +
                        controller.android.toString());
                    webNewController = controller;
                  },
                  onLoadStart:
                      (InAppWebViewController controller, Uri? uri) async {
                    print("URI" + uri.toString());
                    //await controller.goBack();
                    launch(uri.toString());
                    // openUri(uri);
                    //await controller.reload();
                    Navigator.pop(context);
                  },
                ),
              ));
          return alert;
        });
  }

  void navigateToCongifRoute() async {
    List<PrinterBluetooth> listDevices = [];

    //if push again the button
    if (clickPrint == false) {
      setState(() {
        clickPrint = true;
      });
      return;
      //IF FIRST TIME TO TAP PRINT
      //
    } else {
      setState(() {
        clickPrint = false; //change value
      });
      listDevices = await Navigator.push(
        context,
        MaterialPageRoute(
            fullscreenDialog: true,
            builder: (context) => ConfigPrinterScreen()),
      );
      setState(() {
        printers = listDevices;
      });
    }
  }

  createFileFromBase64(
      String base64content, String fileName, String yourExtension) async {
    var bytes = base64Decode(base64content);

    Directory? directory = Platform.isAndroid
        ? await getExternalStorageDirectory()
        : await getApplicationSupportDirectory(); //FOR iOS
    final output = await directory;
    //variable carga
    final file = File("${output!.path}/$fileName.$yourExtension");
    await file.writeAsBytes(bytes.buffer.asUint8List());
    print("${output.path}/$fileName.$yourExtension");
    await OpenFilex.open("${output.path}/$fileName.$yourExtension");
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () => webViewController.goBack().then((value) => false),
      child: Scaffold(
        body: SafeArea(
          child: Stack(children: [
            //BLOC STRING URL - BLOC - EMITE -  EVENTO(INPUTS) - STADOS(DATOS - CLASES)
            //TODO: URL Initial -
            //emitir evento bloc
            //- add sta e
            //- get  .
            // update

            ///
            InAppWebView(
              initialUrlRequest: URLRequest(
                url: Uri.parse(widget.url),
              ),
              initialOptions: options,
              onCreateWindow: (InAppWebViewController webNewController,
                  CreateWindowAction createWindowRequest) async {
                print("requst url in app padre" +
                    createWindowRequest.request.toString());
                catchWindowEvent(createWindowRequest, webNewController);
                return true;
              },
              onPrint: (InAppWebViewController controller, Uri? url) {
                print(controller);
                print("URL ONPRINT" + url.toString());
              },
              pullToRefreshController: pullToRefreshController,
              onWebViewCreated: (controller) async {
                /////BLOC VERIFICAR IMPRESION DE ORDEN
                //SI EXISTE TICKET -
                //ESTADO
                //ESTADO
                controller.addJavaScriptHandler(
                    handlerName: 'handlePrintKitchenOrder',
                    callback: (args) async {
                      var ticketData = args[0];
                      bool firstClick = true;
                      if (ticketData != null && firstClick) {
                        printOrder(ticketData, "kitchen");
                      }
                    });

                //BLOC CERRADO
                //BLOC handlePrintOrder - INITIAL - // VALIDO SI STATE IS HANDLEPRINTERORDER // RETORNA DATA BOOL TRUE OR FALSE
                controller.addJavaScriptHandler(
                    handlerName: 'handlePrintOrder',
                    callback: (args) async {
                      var ticketData = args[0];
                      //BLOC
                      bool firstClick = true;
                      if (ticketData != null && firstClick) {
                        printOrder(ticketData, "recipt");
                      }
                    });
                //BLOC handleLogin -INITIAL EVENT /INGRESA STRING  -SI ESE
                controller.addJavaScriptHandler(
                    handlerName: 'handleLogin',
                    callback: (args) async {
                      var result = args[0];
                      print("entrando al login" + args[0].toString());
                      var language = result['language'];
                      var companyId = result['id'];

                      SharedPreferences prefs =
                          await SharedPreferences.getInstance();
                      prefs.setString('companyId', companyId);

                      if (Platform.isIOS) {
                        var tokeniOS = "";
                        tokeniOS = prefs.getString('tokenIOS')!;
                        authController.registerTokenPush(
                            widget.urlAPI, companyId, tokeniOS);
                      } else if (Platform.isAndroid) {
                        var token = "";
                        token = prefs.getString('tokenPush')!;
                        authController.registerTokenPush(
                            widget.urlAPI, companyId, token);
                      }

                      //INSTANCE OF PROVIDER
                      var appLanguage =
                          Provider.of<LanguageProvider>(context, listen: false);
                      appLanguage.changeLanguage(Locale(language));
                    });

                controller.addJavaScriptHandler(
                    handlerName: 'handleDownloadUrl',
                    callback: (args) async {
                      // print('si salio url');
                      // print(args[0]['downloadUrl']);
                      // final String _url_files = 'www.google.com';
                      // void _launchURL_files() async =>
                      //     await canLaunch(_url_files) ? await launch(_url_files) : throw 'Could not launch $_url_files';
                      // _launchURL_files();
                      var nameImage = args[0]['downloadFileName'];
                      //CONVERT URL TO STRING64
                      var urlImage =
                          args[0]['downloadUrl'].toString().split("base64,");
                      var string64FromUrl = urlImage[1];
                      //CONVERT ARGS TO FORMAT IMAGE
                      var preFormatImage = nameImage.toString().split(".");
                      var formatTimage = preFormatImage[1];
                      //SEND DATA TO DOWNLOAD
                      createFileFromBase64(
                          string64FromUrl, nameImage, formatTimage);
                    });

                controller.addJavaScriptHandler(
                    handlerName: 'handleConfigurePrinter',
                    callback: (args) async {
                      navigateToCongifRoute();
                    });
                controller.addJavaScriptHandler(
                    handlerName: 'handleLogout',
                    callback: (args) async {
                      SharedPreferences prefs =
                          await SharedPreferences.getInstance();
                      token = prefs.getString('tokenPush')!;
                      tokeniOS = prefs.getString('tokenIOS')!;
                      String companyId = prefs.getString('companyId')!;
                      if (Platform.isIOS) {
                        print("compania deslogeo" + companyId);
                        print("APNS TOKEN ios" + tokeniOS);
                        authController.unRegisterTokenPush(
                            widget.urlAPI, companyId, tokeniOS);
                      } else if (Platform.isAndroid) {
                        print("compania deslogeo" + companyId);
                        print("token android" + token);
                        authController.unRegisterTokenPush(
                            widget.urlAPI, companyId, token);
                      }
                    });
              },
              onDownloadStart: (controller, url,) async {
                final String _url = "$url";
                Future<String> _createFileFromString() async {
                  final encodedStr = _url;
                  Uint8List bytes = base64.decode(encodedStr);
                  String dir = (await getApplicationDocumentsDirectory()).path;
                  File file = File(
                      "$dir/" + DateTime.now().millisecondsSinceEpoch.toString() + ".pdf");
                  await file.writeAsBytes(bytes);
                  return file.path;
                }
                _createFileFromString();
              },
              onLoadStop: (controller, url) async {
                print("ONLOAD HIJO URL" + url.toString());
                print("onloadstop");
                pullToRefreshController.endRefreshing();
                setState(() {
                  isLoadingWebView = false;
                });
              },
              onLoadError: (controller, url, code, message) {
                pullToRefreshController.endRefreshing();
              },
              androidOnPermissionRequest:
                  (controller, origin, resources) async {
                return PermissionRequestResponse(
                    resources: resources,
                    action: PermissionRequestResponseAction.GRANT);
              },
            ),
            isLoadingWebView
                ? Center(child: CircularProgressIndicator())
                : Container(),
          ]),
        ),
        drawerScrimColor: Colors.black,
      ),
    );
  }
}
