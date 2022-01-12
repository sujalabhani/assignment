import 'dart:convert';

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
  @override
  void initState() {
    super.initState();
    checkConnectivity();
    WidgetsBinding.instance!.addPostFrameCallback((timeStamp) async {
      hiveBox = await Hive.openBox('localData');

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
    });
  }

  Future checkConnectivity() async {
    Connectivity().onConnectivityChanged.listen((event) async {
      connectivityResult = event;
      if (event != ConnectivityResult.none) {
        showSnackBar('Connected to Internet');

        getData();
      } else {
        if (hiveBox.isNotEmpty) {
          parseJson(hiveBox.get('jsonData') as String);
        }
        showSnackBar('Connect To Internet To Get Latest Data');
      }
    });
  }

  void showSnackBar(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  Future<void> getData() async {
    _loading = !_loading;
    countOfRequest += 10;
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
      List<VersionControl> filteredList =
          data.map((item) => VersionControl.fromJson(item)).toList();
      filteredList.removeRange(0, dataList.length);
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
            style: const TextStyle(color: Colors.white),
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
            return Container(
              padding: const EdgeInsets.only(bottom: 7, top: 3),
              width: MediaQuery.of(context).size.width,
              child: Column(
                children: [
                  Row(
                    children: [
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 8.0),
                        child: Icon(
                          Icons.book_rounded,
                          color: Colors.black,
                          size: 50,
                        ),
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Text(
                              dataList[index].repoTitle,
                              style:
                                  const TextStyle(fontWeight: FontWeight.w500),
                            ),
                            const SizedBox(
                              height: 5,
                            ),
                            Text(
                              dataList[index].repoDesc,
                              overflow: TextOverflow.ellipsis,
                              maxLines: 2,
                              style: const TextStyle(color: Colors.grey),
                            ),
                            const SizedBox(
                              height: 5,
                            ),
                            Row(
                              children: [
                                dataList[index].language != ''
                                    ? BottomIcons(
                                        icon: Icons.code,
                                        text: dataList[index].language)
                                    : Container(),
                                BottomIcons(
                                    icon: Icons.bug_report,
                                    text:
                                        dataList[index].openIssues.toString()),
                                BottomIcons(
                                    icon: Icons.face_sharp,
                                    text: dataList[index]
                                        .watchersCount
                                        .toString()),
                              ],
                            )
                          ],
                        ),
                      )
                    ],
                  ),
                  const Divider(
                    height: 3,
                    thickness: 2,
                  ),
                ],
              ),
            );
          },
        ));
  }
}

class BottomIcons extends StatelessWidget {
  const BottomIcons({Key? key, required this.icon, required this.text})
      : super(key: key);
  final IconData icon;
  final String text;
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon),
        const SizedBox(
          width: 5,
        ),
        Text(
          text,
        ),
        const SizedBox(
          width: 10,
        ),
      ],
    );
  }
}
