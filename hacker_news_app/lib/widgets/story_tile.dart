import 'package:flutter/material.dart';
import 'package:timeago/timeago.dart' as timeago;
import '../models/hn_item.dart';

class StoryTile extends StatelessWidget {
  final HnItem story;
  final int rank;
  final VoidCallback onTap;

  const StoryTile({
    super.key,
    required this.story,
    required this.rank,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _RankBadge(rank: rank),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _TitleText(
                    title: story.title ?? '',
                    domain: story.domain,
                  ),
                  const SizedBox(height: 4),
                  _MetaText(
                    score: story.score ?? 0,
                    author: story.by ?? '',
                    time: story.postedAt,
                    commentCount: story.descendants ?? 0,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RankBadge extends StatelessWidget {
  final int rank;
  const _RankBadge({required this.rank});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 32,
      child: Column(
        children: [
          const Icon(Icons.arrow_drop_up, color: Color(0xFFFF6600), size: 20),
          Text(
            '$rank.',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _TitleText extends StatelessWidget {
  final String title;
  final String domain;
  const _TitleText({required this.title, required this.domain});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return RichText(
      text: TextSpan(
        children: [
          TextSpan(
            text: title,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
              height: 1.3,
            ),
          ),
          if (domain.isNotEmpty)
            TextSpan(
              text: '  ($domain)',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[500],
                fontWeight: FontWeight.normal,
              ),
            ),
        ],
      ),
    );
  }
}

class _MetaText extends StatelessWidget {
  final int score;
  final String author;
  final DateTime time;
  final int commentCount;

  const _MetaText({
    required this.score,
    required this.author,
    required this.time,
    required this.commentCount,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      '$score points by $author'
      '  ${timeago.format(time)}'
      '  |  $commentCount comments',
      style: TextStyle(fontSize: 11, color: Colors.grey[600]),
    );
  }
}
