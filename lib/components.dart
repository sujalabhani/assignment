import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class InfoTile extends StatelessWidget {
  const InfoTile({
    Key? key,
    required this.title,
    required this.description,
    required this.language,
    required this.openIssues,
    required this.watchersCount,
  }) : super(key: key);
  final String title;
  final String description;
  final String language;
  final String openIssues;
  final String watchersCount;

  @override
  Widget build(BuildContext context) {
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
                      title,
                      style: const TextStyle(fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(
                      height: 5,
                    ),
                    Text(
                      description,
                      overflow: TextOverflow.ellipsis,
                      maxLines: 2,
                      style: const TextStyle(color: Colors.grey),
                    ),
                    const SizedBox(
                      height: 5,
                    ),
                    Row(
                      children: [
                        language != ''
                            ? BottomIcons(icon: Icons.code, text: language)
                            : Container(),
                        BottomIcons(icon: Icons.bug_report, text: openIssues),
                        BottomIcons(
                            icon: Icons.face_sharp, text: watchersCount),
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

class Alert extends StatelessWidget {
  const Alert({Key? key, required this.message}) : super(key: key);
  final String message;
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(message),
      actions: [
        TextButton(
            onPressed: () {
              SystemNavigator.pop();
              exit(0);
            },
            child: const Text('close App'))
      ],
    );
  }
}
