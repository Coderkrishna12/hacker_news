import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:timeago/timeago.dart' as timeago;
import '../providers/story_detail_provider.dart';

const _depthColors = [
  Color(0xFFFF6600),
  Color(0xFF0066CC),
  Color(0xFF009900),
  Color(0xFF990099),
  Color(0xFF666666),
];

class CommentWidget extends StatelessWidget {
  final CommentNode node;
  final int depth;
  final void Function(int commentId) onToggle;

  const CommentWidget({
    super.key,
    required this.node,
    required this.depth,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    final comment = node.item;
    if (comment.isDeleted || comment.isDead) return const SizedBox.shrink();

    final indent = (depth * 16.0).clamp(0.0, 64.0);
    final color = _depthColors[depth % _depthColors.length];

    return Padding(
      padding: EdgeInsets.only(left: indent),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _CommentHeader(
            author: comment.by ?? '[deleted]',
            time: comment.postedAt,
            isExpanded: node.isExpanded,
            onTap: () => onToggle(comment.id),
          ),
          if (node.isExpanded) ...[
            _CommentBody(html: comment.text ?? '', borderColor: color),
            ...node.children.map(
              (child) => CommentWidget(
                node: child,
                depth: depth + 1,
                onToggle: onToggle,
              ),
            ),
          ],
          if (depth == 0)
            const Divider(height: 1, indent: 8, endIndent: 8),
        ],
      ),
    );
  }
}

class _CommentHeader extends StatelessWidget {
  final String author;
  final DateTime time;
  final bool isExpanded;
  final VoidCallback onTap;

  const _CommentHeader({
    required this.author,
    required this.time,
    required this.isExpanded,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(8, 8, 8, 4),
        child: Row(
          children: [
            const Icon(Icons.arrow_drop_up,
                color: Color(0xFFFF6600), size: 16),
            const SizedBox(width: 2),
            Text(
              author,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Color(0xFF666666),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              timeago.format(time),
              style: const TextStyle(fontSize: 11, color: Color(0xFF999999)),
            ),
            const Spacer(),
            Text(
              isExpanded ? '[−]' : '[+]',
              style: const TextStyle(fontSize: 11, color: Color(0xFF999999)),
            ),
          ],
        ),
      ),
    );
  }
}

class _CommentBody extends StatelessWidget {
  final String html;
  final Color borderColor;

  const _CommentBody({required this.html, required this.borderColor});

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            width: 2,
            margin: const EdgeInsets.only(left: 8, bottom: 4),
            color: borderColor.withValues(alpha: 0.4),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 8, right: 8),
              child: Html(
                data: html,
                style: {
                  "body": Style(
                    fontSize: FontSize(13),
                    margin: Margins.zero,
                    padding: HtmlPaddings.zero,
                    lineHeight: const LineHeight(1.5),
                  ),
                  "a": Style(color: const Color(0xFF0066CC)),
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
