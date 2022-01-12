import 'dart:convert';

class VersionControl {
  final String repoTitle;
  final String repoDesc;
  final String language;
  final int openIssues;
  final int watchersCount;

  VersionControl(this.repoTitle, this.repoDesc, this.language, this.openIssues,
      this.watchersCount);

  factory VersionControl.fromJson(Map<String, dynamic> json) => VersionControl(
      json['name'],
      json['description'] ?? 'No Description',
      json['language'] ?? '',
      json['open_issues_count'],
      json['watchers_count']);
}
