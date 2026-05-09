import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/hn_item.dart';

class HnApiService {
  static const _base = 'https://hacker-news.firebaseio.com/v0';
  static const _pageSize = 30;
  static const _batchSize = 10;

  // reuse a single HTTP client for connection pooling
  static final _client = http.Client();

  // in-memory cache to avoid refetching the same item
  static final Map<int, HnItem> _cache = {};

  Future<List<int>> fetchTopStoryIds() async {
    final res = await _client.get(Uri.parse('$_base/topstories.json'));
    if (res.statusCode != 200) throw Exception('Failed to load top stories');
    final List<dynamic> ids = json.decode(res.body);
    return ids.cast<int>().take(_pageSize).toList();
  }

  Future<HnItem?> fetchItem(int id) async {
    if (_cache.containsKey(id)) return _cache[id];

    final res = await _client.get(Uri.parse('$_base/item/$id.json'));
    if (res.statusCode != 200) return null;
    final data = json.decode(res.body);
    if (data == null) return null;

    final item = HnItem.fromJson(data as Map<String, dynamic>);
    _cache[id] = item;
    return item;
  }

  // fetch in batches of _batchSize to avoid flooding the network
  Future<List<HnItem>> fetchItems(List<int> ids) async {
    final results = <HnItem>[];

    for (var i = 0; i < ids.length; i += _batchSize) {
      final batch = ids.skip(i).take(_batchSize);
      final batchResults = await Future.wait(batch.map(fetchItem));
      results.addAll(
        batchResults
            .whereType<HnItem>()
            .where((item) => !item.isDeleted && !item.isDead),
      );
    }

    return results;
  }

  Future<List<HnItem>> fetchComments(List<int> kidIds) async {
    if (kidIds.isEmpty) return [];
    return fetchItems(kidIds.take(20).toList());
  }

  Future<List<HnItem>> fetchChildComments(List<int> kidIds) async {
    if (kidIds.isEmpty) return [];
    return fetchItems(kidIds.take(10).toList());
  }

  void clearCache() => _cache.clear();
}
