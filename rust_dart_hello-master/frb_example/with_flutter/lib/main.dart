import 'dart:async';
import 'dart:ffi';
import 'dart:io';
import 'dart:typed_data';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_rust_bridge_example/bridge_generated.dart';
import 'package:flutter_rust_bridge_example/off_topic_code.dart';
import 'package:path_provider/path_provider.dart';
import 'package:vector_math/vector_math.dart';

// Simple Flutter code. If you are not familiar with Flutter, this may sounds a bit long. But indeed
// it is quite trivial and Flutter is just like that. Please refer to Flutter's tutorial to learn Flutter.

const base = 'dartkeriox';
final path = Platform.isWindows ? '$base.dll' : 'lib$base.so';
late final dylib = Platform.isIOS
    ? DynamicLibrary.process()
    : Platform.isMacOS
        ? DynamicLibrary.executable()
        : DynamicLibrary.open(path);
late final api = DartImpl(dylib);

void main() => runApp(MaterialApp(home: MyApp(),debugShowCheckedModeBanner: false,));

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  Uint8List? exampleImage;
  String? exampleText;
  late Socket socket;
  var platform = const MethodChannel('samples.flutter.dev/getkey');
  var key_pub_1='';
  var key_pub_2='';
  var icp_event;
  var signature = '';
  var controller;
  var kel;
  var sig2;
  var isVerified;
  var rotated;
  var attachment = '{"v":"ACDC10JSON00019e_","d":"EzSVC7-SuizvdVkpXmHQx5FhUElLjUOjCbgN81ymeWOE","s":"EWCeT9zTxaZkaC_3-amV2JtG6oUxNA36sCC0P5MI7Buw","i":"Ew-o5dU5WjDrxDBK4b4HrF82_rYb6MX6xsegjq4n0Y7M","a":{"d":"EbFNz3vOMBbzp5xmYRd6rijvq08DCe07bOR-DA5fzO6g","i":"EeWTHzoGK_dNn71CmJh-4iILvqHGXcqEoKGF4VUc6ZXI","dt":"2022-04-11T20:50:23.722739+00:00","LEI":"5493001KJTIIGC8Y1R17"},"e":{},"ri":"EoLNCdag8PlHpsIwzbwe7uVNcPE1mTr-e1o9nCIDPWgM"}-JAB6AABAAA--FABEw-o5dU5WjDrxDBK4b4HrF82_rYb6MX6xsegjq4n0Y7M0AAAAAAAAAAAAAAAAAAAAAAAEw-o5dU5WjDrxDBK4b4HrF82_rYb6MX6xsegjq4n0Y7M-AABAAKcvAE-GzYu4_aboNjC0vNOcyHZkm5Vw9-oGGtpZJ8pNdzVEOWhnDpCWYIYBAMVvzkwowFVkriY3nCCiBAf8JDw';
  String stream = '{"v":"KERI10JSON0001b7_","t":"icp","d":"Ew-o5dU5WjDrxDBK4b4HrF82_rYb6MX6xsegjq4n0Y7M","i":"Ew-o5dU5WjDrxDBK4b4HrF82_rYb6MX6xsegjq4n0Y7M","s":"0","kt":"1","k":["DruZ2ykSgEmw2EHm34wIiEGsUa_1QkYlsCAidBSzUkTU"],"nt":"1","n":["Eao8tZQinzilol20Ot-PPlVz6ta8C4z-NpDOeVs63U8s"],"bt":"3","b":["BGKVzj4ve0VSd8z_AmvhLg4lqcC_9WYX90k03q-R_Ydo","BuyRFMideczFZoapylLIyCjSdhtqVb31wZkRKvPfNqkw","Bgoq68HCmYNUDgOz4Skvlu306o_NY-NrYuKAVhk3Zh9c"],"c":[],"a":[]}-VBq-AABAA0EpZtBNLxOIncUDeLgwX3trvDXFA5adfjpUwb21M5HWwNuzBMFiMZQ9XqM5L2bFUVi6zXomcYuF-mR7CFpP8DQ-BADAAWUZOb17DTdCd2rOaWCf01ybl41U7BImalPLJtUEU-FLrZhDHls8iItGRQsFDYfqft_zOr8cNNdzUnD8hlSziBwABmUbyT6rzGLWk7SpuXGAj5pkSw3vHQZKQ1sSRKt6x4P13NMbZyoWPUYb10ftJlfXSyyBRQrc0_TFqfLTu_bXHCwACKPLkcCa_tZKalQzn3EgZd1e_xImWdVyzfYQmQvBpfJZFfg2c-sYIL3zl1WHpMQQ_iDmxLSmLSQ9jZ9WAjcmDCg-EAB0AAAAAAAAAAAAAAAAAAAAAAA1AAG2022-04-11T20c50c16d643400p00c00{"v":"KERI10JSON00013a_","t":"ixn","d":"Ek48ahzTIUA1ynJIiRd3H0WymilgqDbj8zZp4zzrad-w","i":"Ew-o5dU5WjDrxDBK4b4HrF82_rYb6MX6xsegjq4n0Y7M","s":"1","p":"Ew-o5dU5WjDrxDBK4b4HrF82_rYb6MX6xsegjq4n0Y7M","a":[{"i":"EoLNCdag8PlHpsIwzbwe7uVNcPE1mTr-e1o9nCIDPWgM","s":"0","d":"EoLNCdag8PlHpsIwzbwe7uVNcPE1mTr-e1o9nCIDPWgM"}]}-VBq-AABAAZZlCpwL0QwqF-eTuqEgfn95QV9S4ruh4wtxKQbf1-My60Nmysprv71y0tJGEHkMsUBRz0bf-JZsMKyZ3N8m7BQ-BADAA6ghW2PpLC0P9CxmW13G6AeZpHinH-_HtVOu2jWS7K08MYkDPrfghmkKXzdsMZ44RseUgPPty7ZEaAxZaj95bAgABKy0uBR3LGMwg51xjMZeVZcxlBs6uARz6quyl0t65BVrHX3vXgoFtzwJt7BUl8LXuMuoM9u4PQNv6yBhxg_XEDwACJe4TwVqtGy1fTDrfPxa14JabjsdRxAzZ90wz18-pt0IwG77CLHhi9vB5fF99-fgbYp2Zoa9ZVEI8pkU6iejcDg-EAB0AAAAAAAAAAAAAAAAAAAAAAQ1AAG2022-04-11T20c50c22d909900p00c00{"v":"KERI10JSON00013a_","t":"ixn","d":"EPYT0dEpoc_5QKIGnRYFRqpXHGpeYOhveJTmHoVC6LMU","i":"Ew-o5dU5WjDrxDBK4b4HrF82_rYb6MX6xsegjq4n0Y7M","s":"2","p":"Ek48ahzTIUA1ynJIiRd3H0WymilgqDbj8zZp4zzrad-w","a":[{"i":"EzSVC7-SuizvdVkpXmHQx5FhUElLjUOjCbgN81ymeWOE","s":"0","d":"EQ6RIFoVUDmmyuoMDMPPHDm14GtXaIf98j4AG2vNfZ1U"}]}-VBq-AABAAYycRM_VyvV2fKyHdUceMcK8ioVrBSixEFqY1nEO9eTZQ2NV8hrLc_ux9_sKn1p58kyZv5_y2NW3weEiqn-5KAA-BADAAQl22xz4Vzkkf14xsHMAOm0sDkuxYY8SAgJV-RwDDwdxhN4WPr-3Pi19x57rDJAE_VkyYwKloUuzB5Dekh-JzCQABk98CK_xwG52KFWt8IEUU-Crmf058ZJPB0dCffn-zjiNNgjv9xyGVs8seb0YGInwrB351JNu0sMHuEEgPJLKxAgACw556h2q5_BG6kPHAF1o9neMLDrZN_sCaJ-3slWWX-y8M3ddPN8Zp89R9A36t3m2rq-sbC5h_UDg5qdnrZ-ZxAw-EAB0AAAAAAAAAAAAAAAAAAAAAAg1AAG2022-04-11T20c50c23d726188p00c00';
  var parsedAttachment;
  var acdc;
  var keyForAcdc;
  var signatureForAcdc;
  var id;


  @override
  void initState() {
    super.initState();
    _initACDC();
    //_callExampleFfiTwo();
    // socketConn().then((value) {
    //   _callExampleFfiTwo();
    // });

  }

  Future<void> socketConn()async{
    socket = await Socket.connect('192.168.1.30', 23);
    print('connected');
    // listen to the received data event stream
    socket.listen((List<int> event) {
      print(utf8.decode(event));
    });

    // send hello
    //socket.add(utf8.encode('hello'));
  }

  Future<String> _getPublicKey1() async {
    try {
      var result = await platform.invokeMethod('getKey1');
      return result;
    } on PlatformException catch (e) {
      return '';
    }
  }

  Future<String> _getPublicKey2() async {
    try {
      var result = await platform.invokeMethod('getKey2');
      return result;
    } on PlatformException catch (e) {
      return '';
    }
  }

  Future<String> _sign(String message) async{
    try {
      var result = await platform.invokeMethod('sign', {'message': message});
      return result;
    } on PlatformException catch (e) {
      return '';
    }
  }

  Future<bool> _verify(String message, String signature, String key) async{
    var result = await platform.invokeMethod('verify', {'message': message, 'signature': signature, 'key' : key});
    return result;
  }
  
  Future<void> _generateNewKeys() async{
    var x = await platform.invokeMethod('generateKeys');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(height: 80,),
            Text('Got ACDC:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),),
            Text(attachment),
            RawMaterialButton(
            onPressed: () async{
              var splitList = splitMessage(attachment);
              print(splitList);
              //print(splitList[1].split('-FAB'));
              acdc = splitList[0] +"}";
              //id = acdc.toString().en
              print(id);
              var theRest = splitList[1].split('-FAB');
              var attachmentNew = '-FAB' + theRest[1];
              //print(attachment);
              parsedAttachment = await api.parseAttachment(attachment: attachmentNew);
              print(parsedAttachment[0].key);
              id = 'Ew-o5dU5WjDrxDBK4b4HrF82_rYb6MX6xsegjq4n0Y7M';
              keyForAcdc = parsedAttachment?[0].key.key;
              signatureForAcdc = parsedAttachment?[0].signature.key;
              setState(() {

              });
              isVerified = await _verify(acdc.toString(), signatureForAcdc.toString(), keyForAcdc.toString());
              setState(() {

              });
            },
              child: Text("Verify ACDC", style: TextStyle(fontWeight: FontWeight.bold),),
              shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18.0),
                      side: BorderSide(width: 2)
              )
            ),
            SizedBox(height: 20,),
            id != null ? Text("Getting kel for:", style: TextStyle(fontWeight: FontWeight.bold),) : Container(),
            id != null ? Text("$id") : Container(),
            SizedBox(height: 10,),
            keyForAcdc!= null ?  Text("Public key:", style: TextStyle(fontWeight: FontWeight.bold),) : Container(),
            keyForAcdc!= null ?  Text("$keyForAcdc") : Container(),
            SizedBox(height: 10,),
            signatureForAcdc!= null ?  Text("Signature:" , style: TextStyle(fontWeight: FontWeight.bold),) : Container(),
            signatureForAcdc!= null ?  Text("$signatureForAcdc") : Container(),
            SizedBox(height: 10,),
            isVerified != null ? (isVerified ? Text("Verification successful", style: TextStyle(color: Color(0xff21821e)),) : Text("Verification error", style: TextStyle(color: Color(0xff781a22)),)): Container(),
            // Text("Aktualne klucze:"),
            // Text(key_pub_1),
            // Text(key_pub_2),
            // Divider(),
            // Text("ICP event:"),
            // Text(icp_event ?? ""),
            // Divider(),
            // RawMaterialButton(
            //   onPressed: () async{
            //     signature = await _sign(icp_event);
            //     controller = await api.finalizeInception(event: icp_event, signature: Signature(algorithm: SignatureType.Ed25519Sha512, key: signature));
            //     kel = await api.getKel(id: controller.identifier);
            //     print(kel);
            //     socket.add(utf8.encode(kel));
            //     setState(() {
            //
            //     });
            //   },
            //   child: Text("Podpisz"),
            // ),
            // Text(signature),
            // Divider(),
            // RawMaterialButton(
            //     onPressed: () async{
            //       //ROTATION
            //       rotated = await localRotate(controller);
            //       print("rotacja: $rotated");
            //       sig2 = await _sign(rotated);
            //       print("podpisana rotacja: $sig2");
            //       await api.finalizeEvent(event: rotated, signature: Signature(algorithm: SignatureType.Ed25519Sha512, key: sig2));
            //       var toPrint2 = await api.getKel(id: controller.identifier);
            //       socket.add(utf8.encode(toPrint2));
            //       setState(() {});
            //     },
            //   child: Text("Rotacja"),
            // ),
            // Text(sig2 ?? ""),
            // Divider(),
            // Text("Kel"),
            // Text(kel ?? ""),
            // Divider(),
            // RawMaterialButton(
            //   onPressed: () async{
            //     isVerified = await _verify(acdc.toString(), signatureForAcdc.toString(), keyForAcdc.toString());
            //     setState(() {
            //
            //     });
            //   },
            //   child: Text("Zweryfikuj"),
            // ),
            // Text(isVerified.toString()),
            // Divider(),
            // Text("Attachment"),
            // Text(attachment),
            // RawMaterialButton(
            //   onPressed: () async{
            //     var splitList = splitMessage(attachment);
            //     print(splitList);
            //     //print(splitList[1].split('-FAB'));
            //     acdc = splitList[0] +"}";
            //     var theRest = splitList[1].split('-FAB');
            //     attachment = '-FAB' + theRest[1];
            //     print(attachment);
            //     parsedAttachment = await api.parseAttachment(attachment: attachment);
            //     print(parsedAttachment[0].key);
            //     keyForAcdc = parsedAttachment?[0].key.key;
            //     signatureForAcdc = parsedAttachment?[0].signature.key;
            //     setState(() {
            //
            //     });
            //   },
            //   child: Text("Parse"),
            // ),
            // Text("key: ${keyForAcdc ?? ""}"),
            // Text("signature: ${signatureForAcdc ?? ""}"),
          ],
        ),
      ),
    );
  }

  Future<dynamic> _callExampleFfiTwo() async {
    String dbPath = await getLocalPath();
    await api.initKel(inputAppDir: dbPath);
    key_pub_1 = await _getPublicKey1();
    key_pub_2 = await _getPublicKey2();
    List<PublicKey> vec1 = [];
    vec1.add(PublicKey(algorithm: KeyType.Ed25519, key: key_pub_1));
    List<PublicKey> vec2 = [];
    vec2.add(PublicKey(algorithm: KeyType.Ed25519, key: key_pub_2));
    List<String> vec3 = [];
    icp_event = await api.incept(publicKeys: vec1, nextPubKeys: vec2, witnesses: vec3, witnessThreshold: 0);
    //var signature = await _sign(icp_event);
    await api.processStream(stream: stream);
    setState(() {});

  }

  Future<void> _initACDC() async{
    String dbPath = await getLocalPath();
    await api.initKel(inputAppDir: dbPath);
    await api.processStream(stream: stream);
  }

  List<String> splitMessage(String message){
    return message.split("}-");
  }
  
  Future<String> localRotate(Controller controller) async{
    await _generateNewKeys();
    key_pub_1 = await _getPublicKey1();
    key_pub_2 = await _getPublicKey2();
    setState(() {});
    List<PublicKey> currentKeys = [];
    List<PublicKey> newNextKeys = [];
    currentKeys.add(PublicKey(algorithm: KeyType.Ed25519, key: key_pub_1));
    newNextKeys.add(PublicKey(algorithm: KeyType.Ed25519, key: key_pub_2));

    var result = await api.rotate(controller: controller, currentKeys: currentKeys, newNextKeys: newNextKeys, witnessToAdd: [], witnessToRemove: [], witnessThreshold: 0);
    return result;
  }

  Future<String> getLocalPath() async {
    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }


}
