import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:timeago/timeago.dart' as timeago;
import '../models/hn_item.dart';
import '../providers/story_detail_provider.dart';
import '../widgets/comment_widget.dart';
import '../widgets/loading_indicator.dart';

class DetailScreen extends StatefulWidget {
  final HnItem story;
  const DetailScreen({super.key, required this.story});

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<StoryDetailProvider>().loadDetail(widget.story);
    });
  }

  Future<void> _openUrl(String? url) async {
    if (url == null) return;
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFFFF6600),
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(
          widget.story.title ?? 'Story',
          style: const TextStyle(color: Colors.white, fontSize: 14),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),
      body: Consumer<StoryDetailProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading && provider.commentTree.isEmpty) {
            return const LoadingIndicator(message: 'Loading comments...');
          }

          final story = provider.story ?? widget.story;

          return ListView(
            children: [
              _StoryHeader(story: story, onUrlTap: () => _openUrl(story.url)),

              Container(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                decoration: BoxDecoration(
                  border: Border(
                    top: BorderSide(color: Colors.grey.shade200),
                  ),
                ),
                child: Text(
                  'Comments (${story.descendants ?? 0})',
                  style: Theme.of(context)
                      .textTheme
                      .titleSmall
                      ?.copyWith(fontWeight: FontWeight.bold),
                ),
              ),

              if (provider.isLoading)
                const Padding(
                  padding: EdgeInsets.all(24),
                  child: Center(
                    child: CircularProgressIndicator(
                      color: Color(0xFFFF6600),
                    ),
                  ),
                )
              else if (provider.errorMessage != null)
                Padding(
                  padding: const EdgeInsets.all(24),
                  child: Center(
                    child: Text(
                      'Error loading comments:\n${provider.errorMessage}',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                  ),
                )
              else if (provider.commentTree.isEmpty)
                const Padding(
                  padding: EdgeInsets.all(24),
                  child: Center(
                    child: Text(
                      'No comments yet.',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ),
                )
              else
                ...provider.commentTree.map(
                  (node) => CommentWidget(
                    node: node,
                    depth: 0,
                    onToggle: provider.toggleComment,
                  ),
                ),

              const SizedBox(height: 32),
            ],
          );
        },
      ),
    );
  }
}

class _StoryHeader extends StatelessWidget {
  final HnItem story;
  final VoidCallback onUrlTap;
  const _StoryHeader({required this.story, required this.onUrlTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            story.title ?? '',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              height: 1.3,
            ),
          ),
          const SizedBox(height: 6),

          if (story.url != null)
            GestureDetector(
              onTap: onUrlTap,
              child: Row(
                children: [
                  const Icon(Icons.link, size: 14, color: Color(0xFF0066CC)),
                  const SizedBox(width: 4),
                  Flexible(
                    child: Text(
                      story.domain,
                      style: const TextStyle(
                        color: Color(0xFF0066CC),
                        fontSize: 13,
                        decoration: TextDecoration.underline,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),

          const SizedBox(height: 12),

          Wrap(
            spacing: 12,
            runSpacing: 6,
            children: [
              _Meta(
                  icon: Icons.arrow_upward,
                  label: '${story.score ?? 0} points'),
              _Meta(
                  icon: Icons.person_outline,
                  label: story.by ?? 'unknown'),
              _Meta(
                icon: Icons.access_time,
                label: timeago.format(story.postedAt),
              ),
              _Meta(
                icon: Icons.comment_outlined,
                label: '${story.descendants ?? 0} comments',
              ),
            ],
          ),

          if (story.text != null && story.text!.isNotEmpty) ...[
            const SizedBox(height: 12),
            const Divider(),
            const SizedBox(height: 8),
            Html(
              data: story.text!,
              style: {
                "body": Style(
                  fontSize: FontSize(14),
                  lineHeight: const LineHeight(1.6),
                  margin: Margins.zero,
                  padding: HtmlPaddings.zero,
                ),
                "a": Style(
                  color: const Color(0xFF0066CC),
                ),
              },
            ),
          ],
        ],
      ),
    );
  }
}

class _Meta extends StatelessWidget {
  final IconData icon;
  final String label;
  const _Meta({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: Colors.grey[600]),
        const SizedBox(width: 3),
        Text(
          label,
          style: TextStyle(fontSize: 12, color: Colors.grey[700]),
        ),
      ],
    );
  }
}
