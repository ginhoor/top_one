import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:top_one/module/index/index_screen+download.dart';
import 'package:top_one/module/index/index_screen_vm.dart';
import 'package:top_one/theme/fitness_app_theme.dart';
import 'package:top_one/view/app_top_bar.dart';

import 'view/clipboard_widget.dart';

class IndexScreen extends StatefulWidget {
  const IndexScreen({Key? key}) : super(key: key);

  @override
  _IndexScreenState createState() => _IndexScreenState();
}

class _IndexScreenState extends State<IndexScreen>
    with TickerProviderStateMixin {
  var vm = IndexScreenVM();
  late Animation<double> topBarAnimation;
  List<Widget> staticCells = [];
  // 进入页面后的动效时长
  late AnimationController animationController;
  final scrollController = ScrollController();

  @override
  void initState() {
    vm.state = this;
    animationController = AnimationController(
        duration: const Duration(milliseconds: 1000), vsync: this);

    topBarAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(
            parent: animationController,
            curve: const Interval(0, 0.5, curve: Curves.fastOutSlowIn)));
    scrollController.addListener(handleTopBarWhenScroll);
    setupDownloader();
    setupStaticCells();
    vm.loadTasks;

    super.initState();
  }

  setupDownloader() {
    vm.bindBackgroundIsolate();
    vm.registerDownloaderCallback();
  }

  setupStaticCells() {
    int count = 9;
    staticCells.add(
      ClipboardWidget(
        animation: Tween<double>(begin: 0.0, end: 1.0).animate(
          CurvedAnimation(
            parent: animationController,
            curve: Interval((1 / count) * 1, 1.0, curve: Curves.fastOutSlowIn),
          ),
        ),
        animationController: animationController,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: FitnessAppTheme.background,
      child: ChangeNotifierProvider.value(
        value: vm,
        child: Scaffold(
          backgroundColor: Colors.transparent,
          body: Stack(
            children: <Widget>[
              _buildListView(),
              _buildAppTopBar(),
              SizedBox(
                height: MediaQuery.of(context).padding.bottom,
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAppTopBar() {
    return Selector(
      builder: (context, topBarOpacity, _) {
        return AppTopBar(
          animationController,
          topBarAnimation,
          topBarOpacity,
        );
      },
      selector: (BuildContext context, IndexScreenVM vm) {
        return vm.topBarOpacity;
      },
    );
  }

  Widget _buildListView() {
    return Consumer<IndexScreenVM>(builder: (context, vm, _) {
      return ListView.builder(
        controller: scrollController,
        padding: EdgeInsets.only(
          top: AppBar().preferredSize.height +
              MediaQuery.of(context).padding.top +
              24,
          bottom: 62 + MediaQuery.of(context).padding.bottom,
        ),
        itemCount: staticCells.length + vm.items.length,
        scrollDirection: Axis.vertical,
        itemBuilder: (BuildContext context, int index) {
          animationController.forward();
          if (index < staticCells.length) {
            return staticCells[index];
          }
          var item = vm.items[index - staticCells.length];
          return widget.buildTaskItem(context, item);
        },
      );
    });
  }

  void handleTopBarWhenScroll() {
    if (scrollController.offset >= 24) {
      if (vm.topBarOpacity != 1.0) {
        vm.updateTopBarOpacity(1.0);
      }
    } else if (scrollController.offset <= 24 && scrollController.offset >= 0) {
      if (vm.topBarOpacity != scrollController.offset / 24) {
        vm.updateTopBarOpacity(scrollController.offset / 24);
      }
    } else if (scrollController.offset <= 0) {
      if (vm.topBarOpacity != 0.0) {
        vm.updateTopBarOpacity(0.0);
      }
    }
  }
}
