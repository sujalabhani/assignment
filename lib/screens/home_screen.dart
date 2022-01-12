import 'dart:convert';
import 'package:lazy_load_scrollview/lazy_load_scrollview.dart';

import 'package:assignment/model/version_control.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late ScrollController scrollController;
  final httpClient = http.Client();
  late Future<List<VersionController>> futureData;
  int countOfRequest = 0;
  List<VersionController> dataList = [];

  bool _loading = false;
  @override
  void initState() {
    super.initState();
    scrollController = ScrollController()..addListener(_scrollListener);
    getData();
  }

  void _scrollListener() async {
    // if (scrollController.position.extentAfter < 500) {
    //   await getData();
    // }
  }
  inverseLoading() {
    _loading = !_loading;
  }

  Future<void> getData() async {
    inverseLoading();
    countOfRequest += 10;
    final response = await httpClient.get(Uri.parse(
        'https://api.github.com/users/JakeWharton/repos?page=1&per_page=$countOfRequest'));
    print(response.body);
    final data = json.decode(response.body) as List<dynamic>;
    dataList
        .addAll(data.map((item) => VersionController.fromJson(item)).toList());
    inverseLoading();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          systemOverlayStyle: SystemUiOverlayStyle.light,
          backgroundColor: Colors.grey,
          title: const Text('Assignment'),
        ),
        body: ListView.builder(
          itemCount: _loading ? dataList.length + 1 : dataList.length,
          itemBuilder: (context, index) {
            if (index >= dataList.length - 1) {
              if (!_loading) {
                getData();
              }
              return Center(
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
