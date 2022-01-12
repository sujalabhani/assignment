import 'dart:convert';
import 'dart:io';
import 'package:assignment/components.dart';
import 'package:local_auth/local_auth.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:assignment/model/version_control.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:http/http.dart' as http;

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final httpClient = http.Client();
  int countOfRequest = 0;
  List<VersionControl> dataList = [];
  bool _loading = false;
  late final Box hiveBox;
  late ConnectivityResult connectivityResult;
  late bool canCheckBiometrics;
  @override
  void initState() {
    super.initState();
    checkConnectivity();
  }

  Future checkConnectivity() async {
    canCheckBiometrics = await LocalAuthentication().canCheckBiometrics;
    if (!canCheckBiometrics) {
      await showDialog(
          context: context,
          barrierDismissible: false,
          builder: (_) => const Alert(
                message: 'No Fingerprint Set',
              ));
    }

    bool didAuthenticate = await LocalAuthentication().authenticate(
        localizedReason: 'Please Use FingerPrint to Open', biometricOnly: true);
    if (!didAuthenticate) {
      await showDialog(
          barrierDismissible: false,
          context: context,
          builder: (_) => const Alert(message: 'Didn\'t Scan Fingerprint'));
    }
    hiveBox = await Hive.openBox('localData');
    //connectivity check before loading data
    Connectivity().checkConnectivity().then((value) {
      connectivityResult = value;
      if (value == ConnectivityResult.none) {
        if (hiveBox.isNotEmpty) {
          parseJson(hiveBox.getAt(0) as String);
          setState(() {});
        }
        showSnackBar('Connect To Internet To Get Latest Data');
      }
    });
    //connectivity check after opening app
    Connectivity().onConnectivityChanged.listen((event) async {
      connectivityResult = event;
      if (event != ConnectivityResult.none) {
        getData();
        showSnackBar('Showing latest data from API');
      } else {
        if (hiveBox.isNotEmpty) {
          parseJson(hiveBox.get('jsonData') as String);
        }
        showSnackBar('Connect To Internet To Get Latest Data');
      }
    });
  }

  void showSnackBar(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg),
      duration: const Duration(seconds: 3),
    ));
  }

  Future<void> getData() async {
    _loading = !_loading;
    countOfRequest += 15;
    final response = await httpClient.get(Uri.parse(
        'https://api.github.com/users/JakeWharton/repos?page=1&per_page=$countOfRequest'));
    parseJson(response.body);
    hiveBox.put('jsonData', response.body);
    _loading = !_loading;
    setState(() {});
  }

  void parseJson(String jsonData) {
    final data = json.decode(jsonData) as List<dynamic>;
    if (dataList.isEmpty) {
      dataList
          .addAll(data.map((item) => VersionControl.fromJson(item)).toList());
    } else {
      //filtering to avoid duplication if user turned on data after opening App
      List<VersionControl> filteredList =
          data.map((item) => VersionControl.fromJson(item)).toList();
      dataList.clear();
      dataList.addAll(filteredList);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          systemOverlayStyle: SystemUiOverlayStyle.light,
          title: const Text(
            'Assignment',
            style: TextStyle(color: Colors.white),
          ),
        ),
        body: ListView.builder(
          itemCount: _loading ? dataList.length + 1 : dataList.length,
          itemBuilder: (context, index) {
            if (index >= dataList.length - 1 &&
                connectivityResult != ConnectivityResult.none) {
              if (!_loading) {
                getData();
              }
              return const Center(
                child: CircularProgressIndicator(),
              );
            }
            return InfoTile(
              title: dataList[index].repoTitle,
              description: dataList[index].repoDesc,
              language: dataList[index].language,
              openIssues: dataList[index].openIssues.toString(),
              watchersCount: dataList[index].watchersCount.toString(),
            );
          },
        ));
  }
}
