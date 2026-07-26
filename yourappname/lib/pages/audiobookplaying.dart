import 'dart:async';

import 'package:yourappname/pages/bottombar.dart';
import 'package:yourappname/provider/audioplayprovider.dart';
import 'package:yourappname/subscription/allpayment.dart';
import 'package:yourappname/utils/color.dart';
import 'package:yourappname/utils/constant.dart';
import 'package:yourappname/utils/dimens.dart';
import 'package:yourappname/utils/utils.dart';
import 'package:yourappname/widget/circularrevealclipper.dart';
import 'package:yourappname/widget/customwidget.dart';
import 'package:yourappname/widget/musicmaneger.dart';
import 'package:yourappname/widget/myimage.dart';
import 'package:yourappname/widget/mymarqueetext.dart';
import 'package:yourappname/widget/mynetworkimg.dart';
import 'package:yourappname/widget/mytext.dart';
import 'package:yourappname/widget/nodata.dart';
import 'package:yourappname/widget/seekbar.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:just_audio/just_audio.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:audio_video_progress_bar/audio_video_progress_bar.dart';
import 'package:miniplayer/miniplayer.dart';
import 'package:provider/provider.dart';
import 'package:responsive_grid_list/responsive_grid_list.dart';
import 'package:rxdart/rxdart.dart';

AudioPlayer audioPlayer = AudioPlayer();

/* Audio Progress bar show */
Stream<PositionData> get positionDataStream {
  return Rx.combineLatest3<Duration, Duration, Duration?, PositionData>(
          audioPlayer.positionStream,
          audioPlayer.bufferedPositionStream,
          audioPlayer.durationStream,
          (position, bufferedPosition, duration) => PositionData(
              position, bufferedPosition, duration ?? Duration.zero))
      .asBroadcastStream();
}

final ValueNotifier<double> playerExpandProgress =
    ValueNotifier(playerMinHeight);

final MiniplayerController controller = MiniplayerController();

class AudioBookPlaying extends StatefulWidget {
  const AudioBookPlaying({super.key});

  @override
  State<AudioBookPlaying> createState() => _AudioBookPlayingState();
}

class _AudioBookPlayingState extends State<AudioBookPlaying>
    with WidgetsBindingObserver {
/* History Logic  */

  int _listenedSeconds = 0;
  bool _isPlaying = false;
  bool _apiStarted = false;
  bool _historySaved = false;
  bool? _prevPlaying;
  bool _pauseConsumed = false;
  static bool _listenerAttached = false;

  StreamSubscription<Duration>? _positionSub;
  StreamSubscription<PlayerState>? _playerStateSub;

  void listenAudioState() {
    if (_listenerAttached) {
      printLog(" =====>>> Audio listener already attached <<<===== ");
      return;
    }

    _listenerAttached = true;
    printLog("=====>>> Audio listener attached <<<===== ");

    _playerStateSub = audioPlayer.playerStateStream.listen((state) {
      final playing = state.playing;
      final processing = state.processingState;

      final prev = _prevPlaying;
      _prevPlaying = playing;

      printLog(
        "🎧=====>>> PLAYER STATE → playing=$playing | processing=$processing | prev=$prev",
      );

      if (prev == false &&
          playing == true &&
          processing == ProcessingState.ready) {
        _onPlay();
      }

      if (prev == true &&
          playing == false &&
          processing == ProcessingState.ready) {
        _onPause();
      }
    });

    _positionSub = audioPlayer.positionStream.listen((position) {
      if (_isPlaying) {
        _listenedSeconds = position.inSeconds;
      }
    });
  }

  void _callHistoryApi() {
    final mediaItem =
        audioPlayer.sequenceState.currentSource?.tag as MediaItem?;

    final artistId = mediaItem?.genre;
    final contentId = mediaItem?.album;
    final episodeId = mediaItem?.id;

    printLog("==================>>> ADD HISTORY API CALL <<<=================");
    printLog("artist_id = $artistId");
    printLog("content_id = $contentId");
    printLog("episode_id = $episodeId");
    printLog("time_spend = $_listenedSeconds sec");

    audioPlayProvider.addhistorydata(
      artistId, // ✅ FIRST FIELD (author id)
      "1",
      contentId,
      episodeId,
      _listenedSeconds,
      Constant.isSubscription,
      0,
    );
  }

  void _onPlay() {
    if (_isPlaying) return;

    _isPlaying = true;
    _apiStarted = true;
    _historySaved = false;
    _pauseConsumed = false;

    printLog(" =====>>> HISTORY STARTED <<<=====");
  }

  void _onPause() {
    if (_pauseConsumed) {
      printLog("=====>>> PAUSE IGNORED (already consumed) <<<===== ");
      return;
    }

    _pauseConsumed = true;

    if (!_isPlaying) return;
    _isPlaying = false;

    if (!_apiStarted || _historySaved || _listenedSeconds <= 0) {
      printLog(" =====>>> PAUSE IGNORED (invalid state) <<<===== ");
      return;
    }

    _historySaved = true;
    _apiStarted = false;

    printLog("=====>>> SAVING HISTORY AND CALLING HISTORT API <<<=====");
    _callHistoryApi();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if ((state == AppLifecycleState.paused ||
            state == AppLifecycleState.inactive) &&
        _isPlaying) {
      printLog("=====>>> APP BACKGROUND");
      audioPlayer.pause();
    }
  }

  bool autoPlay = true;
  late ScrollController _scrollcontroller;
  late AudioPlayProvider audioPlayProvider;
  int currentstoptime = 0;
  final MusicManager _musicManager = MusicManager();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    audioPlayProvider = Provider.of<AudioPlayProvider>(context, listen: false);
    _scrollcontroller = ScrollController();
    _scrollcontroller.addListener(_scrollListener);

    printLog(
        "My Content Ids is ${(audioPlayer.sequenceState.currentSource?.tag as MediaItem?)?.album.toString() ?? ""}");

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchDataPlaylist(0);
    });
    listenAudioState();
  }

/* All Content View Count Api Calling */
  addView(contentType, contentId, subContentId) async {
    if (Constant.userID != null) {
      await audioPlayProvider.setView(contentType, contentId, subContentId);
    }
  }

  _scrollListener() {
    if (!_scrollcontroller.hasClients) return;
    if (_scrollcontroller.offset >=
            _scrollcontroller.position.maxScrollExtent &&
        !_scrollcontroller.position.outOfRange) {
      printLog("I am Scoll the widget Data Sceoll");
      /* Related Music  */

      if ((audioPlayProvider.currentPage ?? 0) <
          (audioPlayProvider.totalPage ?? 0)) {
        audioPlayProvider.setLoadMore(true);
        _fetchDataPlaylist(audioPlayProvider.currentPage ?? 0);
      }
      /* Related Podcast Episode */
    }
  }

  _fetchDataPlaylist(int? nextPage) {
    audioPlayProvider.setLoding(true);
    audioPlayProvider.getChapterbyBook(
        (audioPlayer.sequenceState.currentSource?.tag as MediaItem?)
                ?.album
                .toString() ??
            "",
        (nextPage ?? 0) + 1);
  }

  @override
  void dispose() {
    if (_isPlaying) {
      _isPlaying = false;
      audioPlayer.pause(); // stream will save
    }
    _listenerAttached = false;
    _positionSub?.cancel();
    _playerStateSub?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    audioPlayProvider.clearProvider();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<PositionData>(
        stream: positionDataStream,
        builder: (context, snapshot) {
          final positionData = snapshot.data;
          currentstoptime = positionData?.position.inMilliseconds ?? 0;

          return Miniplayer(
            valueNotifier: playerExpandProgress,
            minHeight: playerMinHeight,
            duration: const Duration(seconds: 1),
            maxHeight: MediaQuery.of(context).size.height,
            controller: controller,
            elevation: 4,
            onDismissed: () async {
              printLog(
                  "is Contiue Watching=>${(audioPlayer.sequenceState.currentSource?.tag as MediaItem?)?.playable}");
              currentlyPlaying.value = null;
              currentlyPlaying.value = null;
              await audioPlayer.pause();
              await audioPlayer.stop();
              audioPlayProvider.notifyListener();

              _musicManager.clearMusicPlayer();
              audioPlayProvider.clearProvider();
            },
            curve: Curves.easeInOutCubicEmphasized,
            builder: (height, percentage) {
              final bool miniplayer =
                  percentage < miniplayerPercentageDeclaration;

              if (!miniplayer) {
                return Scaffold(
                  body: Container(
                    decoration: BoxDecoration(
                      color: Theme.of(context).scaffoldBackgroundColor,
                    ),
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: SingleChildScrollView(
                        child: Column(
                          children: [_buildAppBar(), musicDetailsPageShow()],
                        ),
                      ),
                    ),
                  ),
                );
              }
              //Miniplayer
              final percentageMiniplayer = percentageFromValueInRange(
                  min: playerMinHeight,
                  max: MediaQuery.of(context).size.height,
                  value: height);
              final elementOpacity = 1 - 1 * percentageMiniplayer;
              final progressIndicatorHeight = 2 - 2 * percentageMiniplayer;

              return buildMusicPanel(
                  height, elementOpacity, progressIndicatorHeight);
            },
          );
        });
  }

/* Music Detail AppBar */

  Widget _buildAppBar() {
    return Container(
      height: 50,
      width: MediaQuery.of(context).size.width,
      color: Theme.of(context).scaffoldBackgroundColor,
      alignment: Alignment.center,
      padding: const EdgeInsets.fromLTRB(18, 0, 18, 0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          FittedBox(
            child: Material(
              type: MaterialType.transparency,
              child: Container(
                width: 30,
                height: 30,
                alignment: Alignment.center,
                child: Transform.rotate(
                  angle: 11,
                  child: Utils.backIcon(context),
                ),
              ),
            ),
          ),

          // Title
          Expanded(
            child: MyText(
              text: "playingstart",
              maxline: 1,
              fontsize: 16,
              multilanguage: true,
              overflow: TextOverflow.ellipsis,
              textalign: TextAlign.center,
              fontstyle: FontStyle.normal,
            ),
          ),

          // Spacer for back button on mobile
          if (!kIsWeb) const SizedBox(width: 45),
        ],
      ),
    );
  }

  Widget musicDetailsPageShow() {
    final screenWidth = MediaQuery.of(context).size.width;
    final isWeb = kIsWeb || screenWidth > 1000;
    // calculate square size dynamically
    final double imageSize = isWeb
        ? screenWidth * 0.3 // web par chhoto
        : screenWidth * 0.8; // mobile par mota

    return StreamBuilder<SequenceState?>(
      stream: audioPlayer.sequenceStateStream,
      builder: (context, snapshot) {
        return Container(
          width: isWeb ? screenWidth : screenWidth,
          constraints: isWeb ? BoxConstraints(maxWidth: 1000) : null,
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(15, 10, 15, 10),
            controller: _scrollcontroller,
            physics: const BouncingScrollPhysics(),
            child: Column(
              children: [
                /* Music Title With Image And All Buttons */
                MyNetworkImage(
                  width: imageSize,
                  height: imageSize, // ✅ height = width => square box
                  radius: 15,
                  imagePath: ((audioPlayer.sequenceState.currentSource?.tag
                              as MediaItem?)
                          ?.artUri)
                      .toString(),
                  fit: BoxFit.cover,
                ),
                const SizedBox(height: 10),

                /// Title
                MyText(
                  text: ((audioPlayer.sequenceState.currentSource?.tag
                              as MediaItem?)
                          ?.title)
                      .toString(),
                  fontsize:
                      isWeb ? Dimens.medium18TextSize : Dimens.medium24TextSize,
                  fontstyle: FontStyle.normal,
                  fontwaight: FontWeight.w700,
                  maxline: 3,
                  overflow: TextOverflow.ellipsis,
                  textalign: TextAlign.center,
                ),
                const SizedBox(height: 8),

                /// Artist
                MyText(
                  text: ((audioPlayer.sequenceState.currentSource?.tag
                              as MediaItem?)
                          ?.artist)
                      .toString(),
                  fontsize:
                      isWeb ? Dimens.medium22TextSize : Dimens.medium18TextSize,
                  fontstyle: FontStyle.normal,
                  fontwaight: FontWeight.w700,
                  maxline: 3,
                  overflow: TextOverflow.ellipsis,
                  textalign: TextAlign.center,
                ),
                const SizedBox(height: 12),

                /// Progress bar
                StreamBuilder<PositionData>(
                  stream: positionDataStream,
                  builder: (context, snapshot) {
                    final positionData = snapshot.data;
                    return ProgressBar(
                      progress: positionData?.position ?? Duration.zero,
                      buffered: positionData?.bufferedPosition ?? Duration.zero,
                      total: positionData?.duration ?? Duration.zero,
                      progressBarColor:
                          Theme.of(context).textTheme.bodyMedium!.color,
                      baseBarColor: gray,
                      bufferedBarColor: gray,
                      thumbColor: black,
                      barHeight: 3.0,
                      thumbRadius: 6.0,
                      timeLabelPadding: 6.0,
                      timeLabelType: TimeLabelType.remainingTime,
                      timeLabelTextStyle: GoogleFonts.inter(
                        fontSize: isWeb ? 14 : 12,
                        fontStyle: FontStyle.normal,
                        color: Theme.of(context).textTheme.bodyLarge!.color,
                        fontWeight: FontWeight.w700,
                      ),
                      onSeek: (duration) {
                        audioPlayer.seek(duration);
                      },
                    );
                  },
                ),
                const SizedBox(height: 16),

                /// Player Controls
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Previous
                    IconButton(
                      iconSize: isWeb ? 45 : 40,
                      icon: Icon(
                        Icons.skip_previous_rounded,
                        color: audioPlayer.hasPrevious
                            ? Theme.of(context).canvasColor
                            : gray,
                      ),
                      onPressed: audioPlayer.hasPrevious
                          ? () => audioPlayer.seekToPrevious()
                          : null,
                    ),
                    const SizedBox(width: 18),

                    // 10s rewind
                    StreamBuilder<PositionData>(
                      stream: positionDataStream,
                      builder: (context, snapshot) {
                        final positionData = snapshot.data;
                        return InkWell(
                          onTap: () {
                            tenSecNextOrPrevious(
                                positionData?.position.inSeconds.toString() ??
                                    "",
                                false);
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(5),
                            child: Icon(
                              Icons.replay_10_sharp,
                              color: Theme.of(context).canvasColor,
                              size: isWeb ? 30 : 25,
                            ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(width: 18),

                    // Play / Pause
                    StreamBuilder<PlayerState>(
                      stream: audioPlayer.playerStateStream,
                      builder: (context, snapshot) {
                        final playerState = snapshot.data;
                        final processingState = playerState?.processingState;
                        final playing = playerState?.playing;
                        if (processingState == ProcessingState.loading ||
                            processingState == ProcessingState.buffering) {
                          return Container(
                            margin: const EdgeInsets.all(8.0),
                            width: isWeb ? 55 : 50,
                            height: isWeb ? 55 : 50,
                            child: CircularProgressIndicator(
                              color: Theme.of(context).canvasColor,
                            ),
                          );
                        } else if (playing != true) {
                          return Container(
                            decoration: BoxDecoration(
                              color: Theme.of(context).primaryColor,
                              borderRadius: BorderRadius.circular(50),
                            ),
                            child: IconButton(
                              icon: const Icon(Icons.play_arrow_rounded),
                              iconSize: isWeb ? 55 : 50,
                              onPressed: audioPlayer.play,
                            ),
                          );
                        } else if (processingState !=
                            ProcessingState.completed) {
                          return Container(
                            decoration: BoxDecoration(
                              color: Theme.of(context).primaryColor,
                              borderRadius: BorderRadius.circular(50),
                            ),
                            child: IconButton(
                              icon: const Icon(Icons.pause_rounded),
                              iconSize: isWeb ? 55 : 50,
                              onPressed: audioPlayer.pause,
                            ),
                          );
                        } else {
                          return IconButton(
                            icon: const Icon(Icons.replay_rounded),
                            iconSize: isWeb ? 65 : 60,
                            onPressed: () => audioPlayer.seek(Duration.zero,
                                index: audioPlayer.effectiveIndices.first),
                          );
                        }
                      },
                    ),
                    const SizedBox(width: 18),

                    // 10s forward
                    StreamBuilder<PositionData>(
                      stream: positionDataStream,
                      builder: (context, snapshot) {
                        final positionData = snapshot.data;
                        return InkWell(
                          onTap: () {
                            tenSecNextOrPrevious(
                                positionData?.position.inSeconds.toString() ??
                                    "",
                                true);
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(5),
                            child: Icon(
                              Icons.forward_10_sharp,
                              size: isWeb ? 30 : 25,
                              color: Theme.of(context).canvasColor,
                            ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(width: 18),

                    // Next
                    IconButton(
                      iconSize: isWeb ? 45 : 40,
                      icon: Icon(
                        Icons.skip_next_rounded,
                        color: audioPlayer.hasNext
                            ? Theme.of(context).canvasColor
                            : gray,
                      ),
                      onPressed: audioPlayer.hasNext
                          ? () => audioPlayer.seekToNext()
                          : null,
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                Align(
                  alignment: Alignment.topLeft,
                  child: MyText(
                    text: "Episodes",
                    maxline: 1,
                    multilanguage: false,
                    fontsize: isWeb
                        ? Dimens.medium22TextSize
                        : Dimens.medium20TextSize,
                    fontwaight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 20),

                buildPodcastEpisode(),
              ],
            ),
          ),
        );
      },
    );
  }

/* Music Pannel show */
  Widget buildMusicPanel(
      dynamicPanelHeight, elementOpacity, progressIndicatorHeight) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(0),
      ),
      child: Column(
        children: [
          Expanded(
            child: Opacity(
              opacity: elementOpacity,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  /* Music Image */
                  StreamBuilder<SequenceState?>(
                    stream: audioPlayer.sequenceStateStream,
                    builder: (context, snapshot) {
                      return Container(
                        width: 80,
                        height: dynamicPanelHeight,
                        padding: const EdgeInsets.fromLTRB(10, 3, 5, 3),
                        margin: const EdgeInsets.only(right: 8),
                        child: MyNetworkImage(
                          radius: 8,
                          width: MediaQuery.of(context).size.width,
                          height: MediaQuery.of(context).size.height,
                          imagePath: ((audioPlayer.sequenceState.currentSource
                                      ?.tag as MediaItem?)
                                  ?.artUri)
                              .toString(),
                          fit: BoxFit.cover,
                        ),
                      );
                    },
                  ),
                  Expanded(
                    child: StreamBuilder<SequenceState?>(
                        stream: audioPlayer.sequenceStateStream,
                        builder: (context, snapshot) {
                          return Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(
                                height: 20,
                                child: MyMarqueeText(
                                  text: ((audioPlayer.sequenceState
                                              .currentSource?.tag as MediaItem?)
                                          ?.title)
                                      .toString(),
                                  fontsize: Dimens.medium18TextSize,
                                ),
                              ),
                              SizedBox(
                                  height: MediaQuery.of(context).size.height *
                                      0.01),
                              MyText(
                                  text: ((audioPlayer.sequenceState
                                              .currentSource?.tag as MediaItem?)
                                          ?.displaySubtitle)
                                      .toString(),
                                  textalign: TextAlign.left,
                                  fontsize: 12,
                                  multilanguage: false,
                                  maxline: 1,
                                  fontwaight: FontWeight.w400,
                                  overflow: TextOverflow.ellipsis,
                                  fontstyle: FontStyle.normal),
                            ],
                          );
                        }),
                  ),
                  SizedBox(width: MediaQuery.of(context).size.width * 0.01),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(0, 0, 15, 0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        StreamBuilder<SequenceState?>(
                          stream: audioPlayer.sequenceStateStream,
                          builder: (context, snapshot) {
                            if (dynamicPanelHeight <= playerMinHeight) {
                              if (audioPlayer.hasPrevious) {
                                return IconButton(
                                  iconSize: 25.0,
                                  icon: const Icon(
                                    Icons.skip_previous_rounded,
                                  ),
                                  onPressed: audioPlayer.hasPrevious
                                      ? audioPlayer.seekToPrevious
                                      : null,
                                );
                              } else {
                                return const SizedBox.shrink();
                              }
                            } else {
                              return const SizedBox.shrink();
                            }
                          },
                        ),
                        /* Play/Pause */
                        StreamBuilder<PlayerState>(
                          stream: audioPlayer.playerStateStream,
                          builder: (context, snapshot) {
                            if (dynamicPanelHeight <= playerMinHeight) {
                              final playerState = snapshot.data;
                              final processingState =
                                  playerState?.processingState;
                              final playing = playerState?.playing;
                              if (processingState == ProcessingState.loading ||
                                  processingState ==
                                      ProcessingState.buffering) {
                                return Container(
                                  margin: const EdgeInsets.all(8.0),
                                  width: 35.0,
                                  height: 35.0,
                                  child: Utils.pageLoader(context),
                                );
                              } else if (playing != true) {
                                return Container(
                                  decoration: BoxDecoration(
                                    color: Theme.of(context).primaryColor,
                                    borderRadius: BorderRadius.circular(50),
                                  ),
                                  child: IconButton(
                                    icon: const Icon(
                                      Icons.play_arrow_rounded,
                                    ),
                                    iconSize: 25.0,
                                    onPressed: audioPlayer.play,
                                  ),
                                );
                              } else if (processingState !=
                                  ProcessingState.completed) {
                                return Container(
                                  decoration: BoxDecoration(
                                    color: Theme.of(context).primaryColor,
                                    borderRadius: BorderRadius.circular(50),
                                  ),
                                  child: IconButton(
                                    icon: const Icon(
                                      Icons.pause_rounded,
                                    ),
                                    iconSize: 25.0,
                                    onPressed: audioPlayer.pause,
                                  ),
                                );
                              } else {
                                return IconButton(
                                  icon: const Icon(
                                    Icons.replay_rounded,
                                  ),
                                  iconSize: 35.0,
                                  onPressed: () => audioPlayer.seek(
                                      Duration.zero,
                                      index:
                                          audioPlayer.effectiveIndices.first),
                                );
                              }
                            } else {
                              return const SizedBox.shrink();
                            }
                          },
                        ),
                        /* Next */
                        StreamBuilder<SequenceState?>(
                          stream: audioPlayer.sequenceStateStream,
                          builder: (context, snapshot) {
                            if (dynamicPanelHeight <= playerMinHeight) {
                              if (audioPlayer.hasNext) {
                                return IconButton(
                                  iconSize: 25.0,
                                  icon: const Icon(
                                    Icons.skip_next_rounded,
                                  ),
                                  onPressed: audioPlayer.hasNext
                                      ? audioPlayer.seekToNext
                                      : null,
                                );
                              } else {
                                return const SizedBox.shrink();
                              }
                            } else {
                              return const SizedBox.shrink();
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                  /* Previous */
                ],
              ),
            ),
          ),
          Opacity(
            opacity: elementOpacity,
            child: StreamBuilder<PositionData>(
              stream: positionDataStream,
              builder: (context, snapshot) {
                final positionData = snapshot.data;
                return ProgressBar(
                  progress: positionData?.position ?? Duration.zero,
                  buffered: positionData?.bufferedPosition ?? Duration.zero,
                  total: positionData?.duration ?? Duration.zero,
                  progressBarColor:
                      Theme.of(context).textTheme.bodyMedium!.color,
                  baseBarColor: gray,
                  bufferedBarColor: gray,
                  thumbColor: black,
                  timeLabelType: TimeLabelType.remainingTime,
                  barHeight: 2.0,
                  onSeek: (duration) {
                    audioPlayer.seek(duration);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

/* Audio Book Episode Data */

  Widget buildPodcastEpisode() {
    return Consumer<AudioPlayProvider>(
        builder: (context, audioPlayProvider, child) {
      if (audioPlayProvider.bookChapterLoading && !audioPlayProvider.loadMore) {
        return _podcastShimmer();
      } else {
        if (audioPlayProvider.chapterModel.status == 200 &&
            audioPlayProvider.chaptersList != null) {
          if ((audioPlayProvider.chaptersList?.length ?? 0) > 0) {
            return ResponsiveGridList(
              minItemWidth: 120,
              minItemsPerRow: 1,
              maxItemsPerRow: 1,
              horizontalGridSpacing: 10,
              verticalGridSpacing: 10,
              listViewBuilderOptions: ListViewBuilderOptions(
                scrollDirection: Axis.vertical,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
              ),
              children: List.generate(
                  audioPlayProvider.chaptersList?.length ?? 0, (index) {
                return InkWell(
                  hoverColor: transparent,
                  highlightColor: transparent,
                  splashColor: transparent,
                  focusColor: transparent,
                  onTap: () async {
                    if (Utils.checkLoginUser(context)) {
                      if ((audioPlayProvider.chaptersList?[index].isEpisodePaid
                                  .toString()) ==
                              "1" &&
                          (audioPlayProvider.chaptersList?[index].isBuy
                                  .toString()) ==
                              "0") {
                        Navigator.of(context).push(PageRouteBuilder(
                          pageBuilder:
                              (context, animation, secondaryAnimation) {
                            return AllPayment(
                                issubscription: 0,
                                price: audioPlayProvider
                                    .chaptersList?[index].price
                                    .toString(),
                                contentType: "1",
                                subContentId: audioPlayProvider
                                    .chaptersList?[index].id
                                    .toString(),
                                itemTitle: audioPlayProvider
                                    .chaptersList?[index].title
                                    .toString(),
                                autherid: ((audioPlayer.sequenceState
                                            .currentSource?.tag as MediaItem)
                                        .genre)
                                    .toString(),
                                itemId: audioPlayProvider
                                    .chaptersList?[index].audioBookId
                                    .toString(),
                                subaccount: ((audioPlayer.sequenceState
                                            .currentSource?.tag as MediaItem)
                                        .extras?['author_subaccount'])
                                    ?.toString());
                          },
                          transitionDuration: Duration(milliseconds: 150),
                          transitionsBuilder:
                              (context, animation, secondaryAnimation, child) {
                            return AnimatedBuilder(
                              animation: animation,
                              builder: (context, child) {
                                return ClipPath(
                                  clipper: CircularRevealClipper(
                                      progress: animation.value),
                                  child: child,
                                );
                              },
                              child: child,
                            );
                          },
                        ));
                      } else {
                        _musicManager.setInitialPodcast(
                            context,
                            ((audioPlayer.sequenceState.currentSource?.tag
                                        as MediaItem)
                                    .id)
                                .toString(),
                            index,
                            audioPlayProvider.chaptersList,
                            ((audioPlayer.sequenceState.currentSource
                                        ?.tag as MediaItem)
                                    .album)
                                .toString(),
                            addView(
                              "1",
                              ((audioPlayer.sequenceState.currentSource?.tag
                                          as MediaItem)
                                      .album)
                                  .toString(),
                              ((audioPlayer.sequenceState.currentSource?.tag
                                          as MediaItem)
                                      .id)
                                  .toString(),
                            ),
                            false,
                            ((audioPlayer.sequenceState.currentSource?.tag
                                        as MediaItem?)
                                    ?.genre)
                                .toString(),
                            0,
                            ((audioPlayer.sequenceState.currentSource?.tag
                                        as MediaItem?)
                                    ?.artist)
                                .toString());
                      }
                    }
                  },
                  child: Row(children: [
                    Stack(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            border: Border.all(width: 1, color: colorPrimary),
                          ),
                          child: MyNetworkImage(
                              fit: BoxFit.cover,
                              width: 70,
                              imagePath: audioPlayProvider
                                      .chaptersList?[index].image
                                      .toString() ??
                                  ""),
                        ),
                        Positioned.fill(
                          child: Align(
                            alignment: Alignment.center,
                            child: ((audioPlayer.sequenceState.currentSource
                                                ?.tag as MediaItem?)
                                            ?.id)
                                        .toString() ==
                                    audioPlayProvider.chaptersList?[index].id
                                        .toString()
                                ? MyImage(
                                    width: 30,
                                    height: 30,
                                    imagePath: "music.gif")
                                : const SizedBox.shrink(),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          MyText(
                              color: ((audioPlayer.sequenceState.currentSource
                                                  ?.tag as MediaItem?)
                                              ?.id)
                                          .toString() ==
                                      audioPlayProvider.chaptersList?[index].id
                                          .toString()
                                  ? colorAccent
                                  : Theme.of(context).canvasColor,
                              multilanguage: false,
                              text: audioPlayProvider.chaptersList?[index].title
                                      .toString() ??
                                  "",
                              textalign: TextAlign.left,
                              fontsize: Dimens.medium14TextSize,
                              maxline: 2,
                              fontwaight: FontWeight.w500,
                              overflow: TextOverflow.ellipsis,
                              fontstyle: FontStyle.normal),
                          MyText(
                              color: ((audioPlayer.sequenceState.currentSource
                                                  ?.tag as MediaItem?)
                                              ?.id)
                                          .toString() ==
                                      audioPlayProvider.chaptersList?[index].id
                                          .toString()
                                  ? colorAccent
                                  : Theme.of(context).canvasColor,
                              multilanguage: false,
                              text: audioPlayProvider
                                      .chaptersList?[index].description
                                      .toString() ??
                                  "",
                              textalign: TextAlign.left,
                              fontsize: Dimens.medium12TextSize,
                              maxline: 1,
                              fontwaight: FontWeight.w400,
                              overflow: TextOverflow.ellipsis,
                              fontstyle: FontStyle.normal),
                        ],
                      ),
                    ),
                  ]),
                );
              }),
            );
          } else {
            return const NoData();
          }
        } else {
          return const NoData();
        }
      }
    });
  }

  Widget _podcastShimmer() {
    return ResponsiveGridList(
      minItemWidth: 120,
      minItemsPerRow: 1,
      maxItemsPerRow: 1,
      horizontalGridSpacing: 10,
      verticalGridSpacing: 10,
      listViewBuilderOptions: ListViewBuilderOptions(
        scrollDirection: Axis.vertical,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
      ),
      children: List.generate(10, (index) {
        return Container(
          height: 75,
          padding: const EdgeInsets.fromLTRB(15, 10, 15, 10),
          decoration: BoxDecoration(
              color: colorPrimaryDark, borderRadius: BorderRadius.circular(10)),
          child: Row(children: [
            Container(
              decoration: BoxDecoration(
                border: Border.all(width: 1, color: colorPrimary),
              ),
              child: CustomWidget.roundcorner(
                height: 50,
                width: 70,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CustomWidget.roundcorner(
                    height: 20,
                    width: MediaQuery.sizeOf(context).width * 0.4,
                  ),
                  CustomWidget.roundcorner(
                    height: 16,
                    width: MediaQuery.sizeOf(context).width,
                  )
                ],
              ),
            ),
          ]),
        );
      }),
    );
  }

  /* 10 Second Next And Previous Functionality */
// bool isnext = true > next Audio Seek
// bool isnext = false > previous Audio Seek
  tenSecNextOrPrevious(String audioposition, bool isnext) {
    dynamic firstHalf = Duration(seconds: int.parse(audioposition));
    const secondHalf = Duration(seconds: 10);
    Duration movePosition;
    if (isnext == true) {
      movePosition = firstHalf + secondHalf;
    } else {
      movePosition = firstHalf - secondHalf;
    }

    _musicManager.seek(movePosition);
  }
}
