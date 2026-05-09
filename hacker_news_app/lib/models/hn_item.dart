class HnItem {
  final int id;
  final String type;
  final String? title;
  final String? url;
  final String? text;
  final String? by;
  final int? score;
  final int time;
  final int? descendants;
  final List<int> kids;
  bool isDeleted;
  bool isDead;

  HnItem({
    required this.id,
    required this.type,
    this.title,
    this.url,
    this.text,
    this.by,
    this.score,
    required this.time,
    this.descendants,
    this.kids = const [],
    this.isDeleted = false,
    this.isDead = false,
  });

  factory HnItem.fromJson(Map<String, dynamic> json) {
    return HnItem(
      id: json['id'] as int,
      type: json['type'] as String? ?? 'story',
      title: json['title'] as String?,
      url: json['url'] as String?,
      text: json['text'] as String?,
      by: json['by'] as String?,
      score: json['score'] as int?,
      time: json['time'] as int? ?? 0,
      descendants: json['descendants'] as int?,
      kids: (json['kids'] as List<dynamic>?)?.cast<int>() ?? [],
      isDeleted: json['deleted'] as bool? ?? false,
      isDead: json['dead'] as bool? ?? false,
    );
  }

  String get domain {
    if (url == null) return '';
    try {
      final uri = Uri.parse(url!);
      final host = uri.host;
      return host.startsWith('www.') ? host.substring(4) : host;
    } catch (_) {
      return '';
    }
  }

  DateTime get postedAt =>
      DateTime.fromMillisecondsSinceEpoch(time * 1000);
}
