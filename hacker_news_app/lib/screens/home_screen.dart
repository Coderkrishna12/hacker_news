import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/stories_provider.dart';
import '../providers/story_detail_provider.dart';
import '../widgets/story_tile.dart';
import '../widgets/loading_indicator.dart';
import '../widgets/error_widget.dart';
import 'detail_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<StoriesProvider>().loadStories();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFFFF6600),
        title: const Text(
          'Hacker News',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
      ),
      body: Consumer<StoriesProvider>(
        builder: (context, provider, _) {
          switch (provider.state) {
            case LoadState.loading:
              return const LoadingIndicator(message: 'Loading top stories...');

            case LoadState.error:
              return ErrorDisplay(
                message: provider.errorMessage ?? 'Unknown error',
                onRetry: provider.loadStories,
              );

            case LoadState.loaded:
              return RefreshIndicator(
                color: const Color(0xFFFF6600),
                onRefresh: provider.refresh,
                child: ListView.separated(
                  physics: const AlwaysScrollableScrollPhysics(),
                  itemCount: provider.stories.length,
                  separatorBuilder: (_, __) =>
                      const Divider(height: 1, indent: 52, endIndent: 16),
                  itemBuilder: (context, index) {
                    final story = provider.stories[index];
                    return StoryTile(
                      story: story,
                      rank: index + 1,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => ChangeNotifierProvider(
                              create: (_) => StoryDetailProvider(),
                              child: DetailScreen(story: story),
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              );

            default:
              return const SizedBox.shrink();
          }
        },
      ),
    );
  }
}
