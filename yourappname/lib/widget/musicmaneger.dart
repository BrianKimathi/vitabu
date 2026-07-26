import 'dart:developer';

import 'package:yourappname/pages/audiobookplaying.dart';
import 'package:yourappname/pages/bottombar.dart';
import 'package:yourappname/widget/seekbar.dart';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';

class MusicManager {
  List<AudioSource> audioSources = [];
  dynamic episodeDataList;
  MusicManager();

/* PodCast */
  void setInitialPodcast(
      BuildContext context,
      String episodeId,
      int cPosition,
      dynamic podcastEpisodeList,
      String podcastId,
      dynamic callApi,
      dynamic isContinueWatching,
      String artistId,
      int stoptime,
      String artistName,
      {String? subaccount}) async {
    currentlyPlaying.value = audioPlayer;
    audioSources.clear();

    episodeDataList = podcastEpisodeList;
    for (int i = 0; i < (episodeDataList?.length ?? 0); i++) {
      final Map<String, dynamic> extras = Map<String, dynamic>.from(episodeDataList[i].toMap() ?? {});
      if (subaccount != null && subaccount.isNotEmpty) {
        extras['author_subaccount'] = subaccount;
      }
      audioSources.add(
        buildAudioSource(
          artistId: artistId,
          image: episodeDataList[i].image.toString(),
          audioUrl: episodeDataList[i].audio.toString(),
          extraDetails: extras,
          episodeId: episodeDataList[i].id.toString(),
          artistName: artistName,
          displaydiscription: episodeDataList[i].description.toString(),
          title: episodeDataList[i].title.toString(),
          contentId: episodeDataList[i].audioBookId.toString(),
          isContinueWatching: isContinueWatching,
        ),
      );
    }

    try {
      await audioPlayer.setAudioSources(audioSources,
          initialIndex: cPosition, initialPosition: Duration.zero);
      if (isContinueWatching == true) {
        seek(Duration(milliseconds: stoptime));
        play();
      } else {
        play();
      }

      audioPlayer.positionStream.listen((position) {});

      callApi();
    } catch (e) {
      log("Error loading audio source: $e");
    }
  }
/* Single music play Code */

  void setSingleAudio({
    required String audioUrl,
    required String title,
    required String episodeId,
    required String description,
    required String image,
    required String contentId,
    required String artistName,
    required String artistId,
    dynamic extraDetails,
    required bool isContinueWatching,
    int stoptime = 0,
  }) async {
    currentlyPlaying.value = audioPlayer;
    try {
      audioSources.clear(); // optional: clear previous list
      final singleSource = buildAudioSource(
        artistId: artistId,
        image: image,
        audioUrl: audioUrl,
        extraDetails: extraDetails,
        episodeId: episodeId,
        artistName: artistName,
        displaydiscription: description,
        title: title,
        contentId: contentId,
        isContinueWatching: isContinueWatching,
      );

      await audioPlayer.setAudioSource(singleSource,
          initialIndex: 0, initialPosition: Duration.zero);

      if (!isContinueWatching && stoptime > 0) {
        seek(Duration(milliseconds: stoptime));
      }

      play();

      audioPlayer.positionStream.listen((position) {
        if (!isContinueWatching &&
            audioPlayer.duration?.inMilliseconds == position.inMilliseconds) {
          log('Playback Complete');
        }
      });
    } catch (e) {
      log("Error loading single audio source: $e");
    }
  }

  void play() async {
    audioPlayer.play();
  }

  void pause() {
    audioPlayer.pause();
  }

  void seek(Duration position) {
    audioPlayer.seek(position);
  }

  void dispose() {
    audioPlayer.dispose();
  }

  clearMusicPlayer() async {
    episodeDataList = [];

    audioPlayer.clearAudioSources();
    audioSources.clear();
    await audioPlayer.stop();
  }
}
