import 'package:flutter/foundation.dart';
import '../models/hn_item.dart';
import '../services/hn_api_service.dart';

class CommentNode {
  final HnItem item;
  List<CommentNode> children;
  bool isExpanded;

  CommentNode({
    required this.item,
    this.children = const [],
    this.isExpanded = true,
  });
}

class StoryDetailProvider extends ChangeNotifier {
  final _api = HnApiService();

  HnItem? _story;
  List<CommentNode> _commentTree = [];
  bool _isLoading = false;
  String? _errorMessage;

  HnItem? get story => _story;
  List<CommentNode> get commentTree => _commentTree;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> loadDetail(HnItem storyItem) async {
    _story = storyItem;
    _commentTree = [];
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final fresh = await _api.fetchItem(storyItem.id);
      _story = fresh ?? storyItem;

      // load first-level comments
      final firstLevel = await _api.fetchComments(_story!.kids);

      // build first level immediately, then load nested in background
      _commentTree = firstLevel
          .map((c) => CommentNode(item: c, children: []))
          .toList();
      _isLoading = false;
      notifyListeners();

      // now fetch nested children progressively
      for (var i = 0; i < _commentTree.length; i++) {
        if (_commentTree[i].item.kids.isNotEmpty) {
          _commentTree[i].children =
              await _buildChildren(_commentTree[i].item.kids, 1);
          notifyListeners();
        }
      }
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<List<CommentNode>> _buildChildren(List<int> kidIds, int depth) async {
    if (depth >= 4 || kidIds.isEmpty) return [];

    final items = await _api.fetchChildComments(kidIds);
    final nodes = <CommentNode>[];

    for (final item in items) {
      final children = item.kids.isNotEmpty
          ? await _buildChildren(item.kids, depth + 1)
          : <CommentNode>[];
      nodes.add(CommentNode(item: item, children: children));
    }

    return nodes;
  }

  void toggleComment(int commentId) {
    _toggleInTree(_commentTree, commentId);
    notifyListeners();
  }

  void _toggleInTree(List<CommentNode> nodes, int id) {
    for (final node in nodes) {
      if (node.item.id == id) {
        node.isExpanded = !node.isExpanded;
        return;
      }
      _toggleInTree(node.children, id);
    }
  }
}
