import 'package:flutter/material.dart';
import 'package:wordpress_app/blocs/tab_scroll_controller.dart';
import 'package:wordpress_app/models/app_config_model.dart';
import 'package:wordpress_app/widgets/featured.dart';
import 'package:wordpress_app/widgets/popular_articles.dart';
import '../blocs/config_bloc.dart';
import '../blocs/featured_bloc.dart';
import 'package:provider/provider.dart';
import '../blocs/latest_articles_bloc.dart';
import '../blocs/popular_articles_bloc.dart';
import '../widgets/lattest_articles.dart';

class Tab0 extends StatefulWidget {
  const Tab0({Key? key, required this.sc}) : super(key: key);
  final ScrollController sc;

  @override
  State<Tab0> createState() => _Tab0State();
}

class _Tab0State extends State<Tab0> {
  Future _onRefresh(ConfigModel configs) async {
    if (configs.featuredPostEnabled) {
      context.read<FeaturedBloc>().saveDotIndex(0);
      context.read<FeaturedBloc>().fetchData();
    }
    if (configs.popularPostEnabled) {
      context.read<PopularArticlesBloc>().fetchData();
    }
    context.read<LatestArticlesBloc>().onReload(configs.blockedCategories);
  }

  @override
  void initState() {
    super.initState();
    widget.sc.addListener(_scrollListener);
  }

  void _scrollListener() {
    bool isEnd = TabScrollController().isEnd(widget.sc);
    debugPrint('isEnd: $isEnd');
    if (mounted) {
      final lb = context.read<LatestArticlesBloc>();
      if (isEnd && lb.articles.isNotEmpty) {
        lb.pageIncreament();
        lb.setLoading(true);
        lb
            .fetchData(context.read<ConfigBloc>().configs!.blockedCategories)
            .then((value) {
          lb.setLoading(false);
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final configs = context.read<ConfigBloc>().configs!;
    return RefreshIndicator(
      backgroundColor: Theme.of(context).primaryColor,
      color: Colors.white,
      onRefresh: () async => _onRefresh(configs),
      child: SingleChildScrollView(
        key: const PageStorageKey('key0'),
        padding: const EdgeInsets.all(0),
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          children: [
            const Featured(),
            const PopularArticles(),
            //Latest Posts
            const LattestArticles(),
          ],
        ),
      ),
    );
  }
}
