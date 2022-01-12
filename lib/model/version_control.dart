import 'dart:convert';

class VersionController {
  final String repoTitle;
  final String repoDesc;
  final String language;
  final int openIssues;
  final int watchersCount;

  VersionController(this.repoTitle, this.repoDesc, this.language,
      this.openIssues, this.watchersCount);

  factory VersionController.fromJson(Map<String, dynamic> json) =>
      VersionController(
          json['name'],
          json['description'] ?? 'No Description',
          json['language'] ?? '',
          json['open_issues_count'],
          json['watchers_count']);
}
