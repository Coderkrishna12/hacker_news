import 'package:flutter/foundation.dart';
import '../models/hn_item.dart';
import '../services/hn_api_service.dart';

enum LoadState { idle, loading, loaded, error }

class StoriesProvider extends ChangeNotifier {
  final _api = HnApiService();

  List<HnItem> _stories = [];
  LoadState _state = LoadState.idle;
  String? _errorMessage;

  List<HnItem> get stories => _stories;
  LoadState get state => _state;
  String? get errorMessage => _errorMessage;

  Future<void> loadStories() async {
    _state = LoadState.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      final ids = await _api.fetchTopStoryIds();

      // load in batches and show results progressively
      _stories = [];
      const batchSize = 10;
      for (var i = 0; i < ids.length; i += batchSize) {
        final batch = ids.skip(i).take(batchSize).toList();
        final items = await _api.fetchItems(batch);
        _stories.addAll(items);
        _state = LoadState.loaded;
        notifyListeners();
      }
    } catch (e) {
      _errorMessage = e.toString();
      _state = LoadState.error;
      notifyListeners();
    }
  }

  Future<void> refresh() async {
    _api.clearCache();
    return loadStories();
  }
}
