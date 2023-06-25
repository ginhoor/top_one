import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:common_utils/common_utils.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_tool_kit/log/logger.dart';
import 'package:top_one/app/app_navigator_observer.dart';
import 'package:top_one/app/app_preference.dart';
import 'package:top_one/app/theme_config.dart';
import 'package:top_one/model/tt_result.dart';
import 'package:top_one/service/ad/ad_service.dart';
import 'package:top_one/service/photo_library_service.dart';
import 'package:top_one/theme/app_theme.dart';
import 'package:top_one/tool/store_kit.dart';
import 'package:top_one/view/dialog.dart';
import 'package:video_player/video_player.dart';

class VideoPreviewPage extends StatefulWidget {
  final TTResult metaData;
  final String? localFilePath;
  const VideoPreviewPage({super.key, required this.metaData, this.localFilePath});
  @override
  State<VideoPreviewPage> createState() => _VideoPreviewPageState();
}

class _VideoPreviewPageState extends State<VideoPreviewPage> {
  late VideoPlayerController playerCtrl;
  double progressValue = 0; //进度
  String labelProgress = "00:00"; //tip内容

  bool playEnd = false;
  @override
  void dispose() {
    ADService().videoPlayINTAdService.show((p0) => null);
    playerCtrl.removeListener(listen);
    playerCtrl.dispose();
    super.dispose();
  }

  void handlePlayAction() {
    setState(() {
      playerCtrl.value.isPlaying ? playerCtrl.pause() : playerCtrl.play();
    });
  }

  void listen() {
    if (!playerCtrl.value.isPlaying) {
      if (mounted) setState(() {});
    } else {
      playEnd = false;
    }
    int position = playerCtrl.value.position.inMilliseconds;
    int duration = playerCtrl.value.duration.inMilliseconds;
    if (position == duration && !playEnd) {
      playEnd = true;
      logDebug("播放完毕");
      showCustomRateView(context, AppPreferenceKey.latest_play_complete_rate_date);
    }
    setState(() {
      progressValue = position / duration * 100;
      if (progressValue.isNaN || progressValue.isInfinite) {
        progressValue = 0.0;
      }
      labelProgress = DateUtil.formatDateMs(progressValue.toInt(), format: 'mm:ss');
    });
  }

  @override
  void initState() {
    super.initState();
    var localFilePath = widget.localFilePath;
    if (localFilePath != null) {
      var file = File(localFilePath);
      playerCtrl = VideoPlayerController.file(file);
    } else if (widget.metaData.video != null) {
      playerCtrl = VideoPlayerController.network(widget.metaData.video!);
    } else {
      playerCtrl = VideoPlayerController.asset("");
    }
    playerCtrl.addListener(listen);
    playerCtrl.initialize().then((_) {
      if (!mounted) return;
      setState(() {
        playerCtrl.play();
      });
    });
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: []);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: Stack(
        children: <Widget>[
          Align(alignment: Alignment.center, child: _player),
          Align(alignment: Alignment.center, child: _playAction),
          Align(
            alignment: Alignment.bottomCenter,
            child: Column(
              mainAxisSize: MainAxisSize.min, // 设置 Column 的高度为子项内容的高度
              children: [
                _authInfo,
                SizedBox(height: dPadding_2),
                _timeSlider,
                SizedBox(height: dPadding_2),
                _videoInfo,
              ],
            ),
          ),
          Positioned(left: dPadding, top: (MediaQuery.of(context).padding.top), child: _back),
          if (widget.localFilePath != null)
            Positioned(right: dPadding, top: (MediaQuery.of(context).padding.top), child: _save),
        ],
      ),
    );
  }

  Widget get _player {
    return SizedBox(
      width: double.infinity,
      height: double.infinity,
      child: AspectRatio(
        aspectRatio: playerCtrl.value.aspectRatio,
        child: playerCtrl.value.isInitialized
            ? VideoPlayer(playerCtrl)
            : CachedNetworkImage(imageUrl: widget.metaData.img ?? ""),
      ),
    );
  }

  Widget get _playAction {
    return GestureDetector(
      child: Container(
        width: double.infinity,
        height: double.infinity,
        color: Colors.transparent,
        child: playerCtrl.value.isPlaying
            ? null
            : Stack(
                children: [
                  Center(
                    child: ClipRRect(
                      borderRadius: BorderRadius.all(Radius.circular(60.0)),
                      child: Container(
                        color: Colors.black45,
                        width: 120,
                        height: 120,
                        child: Icon(Icons.play_arrow, size: 120, color: AppTheme.nearlyWhite),
                      ),
                    ),
                  ),
                ],
              ),
      ),
      onTap: () => handlePlayAction(),
    );
  }

  Widget get _back {
    return GestureDetector(
      child: ClipRRect(
        borderRadius: BorderRadius.all(Radius.circular(25.0)),
        child: Container(
          color: Colors.black45,
          width: 50,
          height: 50,
          child: Icon(Icons.arrow_back, size: 30, color: AppTheme.nearlyWhite),
        ),
      ),
      onTap: () {
        playerCtrl.pause();
        AppNavigator.popPage();
      },
    );
  }

  Widget get _save {
    return GestureDetector(
      child: ClipRRect(
        borderRadius: const BorderRadius.all(Radius.circular(25.0)),
        child: Container(
          color: Colors.black45,
          width: 50,
          height: 50,
          child: Icon(Icons.save_alt, size: 30, color: AppTheme.nearlyWhite),
        ),
      ),
      onTap: () {
        DialogManager.instance.showMessageDialog(
          context,
          title: Text('defualt_alert_title'.tr()),
          actions: [
            TextButton(
              child: Text('save'.tr()),
              onPressed: () async {
                if (widget.localFilePath != null) {
                  await PhotoLibraryService().saveVideo(widget.localFilePath!);
                }
                AppNavigator.popPage();
              },
            ),
          ],
        );
      },
    );
  }

  Widget get _videoInfo {
    return Container(
      width: double.infinity,
      color: Colors.black38,
      child: Padding(
        padding: EdgeInsets.all(dPadding),
        child: Text(
          widget.metaData.title ?? "",
          maxLines: 5,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(color: Colors.white, fontSize: 14),
        ),
      ),
    );
  }

  Widget get _authInfo {
    return Padding(
      padding: EdgeInsets.only(left: dPadding, right: dPadding),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.all(Radius.circular(30.0)),
            child: CachedNetworkImage(
              imageUrl: widget.metaData.avatar ?? "",
              errorWidget: (context, url, error) => const Icon(Icons.error),
              width: 40,
              height: 40,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(width: 16),
          Text(
            widget.metaData.name ?? "",
            textAlign: TextAlign.start,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(color: Colors.white, fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget get _timeSlider {
    return SizedBox(
      height: 20,
      child: Slider(
          activeColor: AppTheme.nearlyWhite,
          inactiveColor: AppTheme.dismissibleBackground,
          value: progressValue,
          label: labelProgress,
          divisions: 100,
          onChangeStart: _onChangeStart,
          onChangeEnd: _onChangeEnd,
          onChanged: _onChanged,
          min: 0,
          max: 100),
    );
  }

  void _onChangeEnd(_) {
    int duration = playerCtrl.value.duration.inMilliseconds;
    playerCtrl.seekTo(
      Duration(milliseconds: (progressValue / 100 * duration).toInt()),
    );
    if (!playerCtrl.value.isPlaying) playerCtrl.play();
  }

  void _onChangeStart(_) {
    if (playerCtrl.value.isPlaying) playerCtrl.pause();
  }

  void _onChanged(double value) {
    int duration = playerCtrl.value.duration.inMilliseconds;
    setState(() {
      progressValue = value;
      labelProgress = DateUtil.formatDateMs(
        (value / 100 * duration).toInt(),
        format: 'mm:ss',
      );
    });
  }
}