import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'favorites_screen.dart';
import 'song_screen.dart';

final RouteObserver<ModalRoute<void>> routeObserver = RouteObserver<ModalRoute<void>>();

void main() {
  runApp(const MusicApp());
}

class MusicApp extends StatelessWidget {
  const MusicApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      navigatorObservers: [routeObserver],
      home: const MusicScreen(),
    );
  }
}

class MusicScreen extends StatefulWidget {
  const MusicScreen({super.key});

  @override
  _MusicScreenState createState() => _MusicScreenState();
}

class _MusicScreenState extends State<MusicScreen> with WidgetsBindingObserver, RouteAware {
  final AudioPlayer _player = AudioPlayer();
  bool isPlaying = false;
  bool isFavorite = false;
  bool showControls = false;
  String songName = "";
  int currentSongIndex = 0;

  List<Map<String, String>> songs = [
    {
      'name': 'Fur Elise - Beethoven',
      'asset': 'assets/fur elise.mp3',
    },
    {
      'name': 'Alhamdulilah - Khabib',
      'asset': 'assets/khabib.mp3',
    },
    {
      'name': 'Nasheed - Nasheed',
      'asset': 'assets/nasheed.mp3',
    },
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _loadSong(currentSongIndex);
  }

  Future<void> _loadSong(int index) async {
    // Load the asset
    await _player.setAsset(songs[index]['asset']!);
    setState(() {
      songName = songs[index]['name']!;
      showControls = true;
      // When loading a song, we assume it should play:
      isPlaying = true;
    });
    _loadFavoriteStatus();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    // Pause the player when the app goes background
    if (state == AppLifecycleState.paused) {
      _player.pause();
    } else if (state == AppLifecycleState.resumed) {
      // Resume playing if we believe the song was playing.
      if (isPlaying) {
        _player.play();
      }
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    routeObserver.subscribe(this, ModalRoute.of(context)!);
  }

  @override
  void dispose() {
    _player.dispose();
    routeObserver.unsubscribe(this);
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didPopNext() {
    // When coming back to MusicScreen, resume playback and update the UI.
    _player.play();
    setState(() {
      isPlaying = true;
      showControls = true;
    });
  }

  @override
  void didPushNext() {
    // Pause music when navigating away to any screen.
    _player.pause();
    setState(() {
      isPlaying = false;
    });
  }

  void _togglePlayPause() {
    // Manually toggle play/pause and update the icon accordingly.
    if (isPlaying) {
      _player.pause();
      setState(() {
        isPlaying = false;
      });
    } else {
      _player.play();
      setState(() {
        isPlaying = true;
      });
    }
  }

  void _toggleFavorite() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      isFavorite = !isFavorite;
      prefs.setBool(songName, isFavorite);
    });
  }

  void _loadFavoriteStatus() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      isFavorite = prefs.getBool(songName) ?? false;
    });
  }

  void _goToFavorites() {
    _player.stop();
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FavoritesScreen(
          onSongDeleted: (deletedSongName) {
            setState(() {
              if (deletedSongName == songName) {
                isFavorite = false;
              }
            });
          },
        ),
      ),
    );
  }

  void _goToSongList() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SongScreen(
          songs: songs,
          onSongSelected: (int index) {
            setState(() {
              currentSongIndex = index;
              _loadSong(currentSongIndex).then((_) {
                // After loading, play the song.
                _player.play();
                setState(() {
                  isPlaying = true;
                });
              });
            });
          },
        ),
      ),
    );
  }

  void _playNext() {
    if (currentSongIndex < songs.length - 1) {
      currentSongIndex++;
      _loadSong(currentSongIndex).then((_) {
        _player.play();
        setState(() {
          isPlaying = true;
        });
      });
    }
  }

  void _playPrevious() {
    if (currentSongIndex > 0) {
      currentSongIndex--;
      _loadSong(currentSongIndex).then((_) {
        _player.play();
        setState(() {
          isPlaying = true;
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blueGrey,
        title: const Text(
          "Lecteur de Musique",
          style: TextStyle(fontSize: 24, color: Colors.white),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.favorite, color: Colors.red),
            onPressed: _goToFavorites,
          ),
          IconButton(
            icon: const Icon(Icons.library_music, color: Colors.white),
            onPressed: _goToSongList,
          ),
        ],
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isLandscape = constraints.maxWidth > constraints.maxHeight;
          double imageSize = isLandscape ? 180 : 250;
          double iconSize = isLandscape ? 30 : 36;
          double textSize = isLandscape ? 14 : 18;
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Flexible(
                  child: Image.asset(
                    'assets/image1.png',
                    width: imageSize,
                    height: imageSize,
                  ),
                ),
                const SizedBox(height: 20),
                showControls
                    ? Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              IconButton(
                                icon: const Icon(
                                  Icons.skip_previous,
                                  color: Colors.blueGrey,
                                ),
                                onPressed: _playPrevious,
                              ),
                              IconButton(
                                icon: Icon(
                                  isPlaying ? Icons.pause : Icons.play_arrow,
                                  color: Colors.blue,
                                ),
                                onPressed: _togglePlayPause,
                                iconSize: iconSize,
                              ),
                              IconButton(
                                icon: const Icon(
                                  Icons.skip_next,
                                  color: Colors.blueGrey,
                                ),
                                onPressed: _playNext,
                              ),
                            ],
                          ),
                          const SizedBox(height: 15),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                songName,
                                style: TextStyle(fontSize: textSize, color: Colors.black87),
                              ),
                              IconButton(
                                icon: Icon(
                                  isFavorite ? Icons.favorite : Icons.favorite_border,
                                  color: Colors.red,
                                ),
                                onPressed: _toggleFavorite,
                              ),
                            ],
                          ),
                        ],
                      )
                    : const Center(child: CircularProgressIndicator()),
              ],
            ),
          );
        },
      ),
    );
  }
}
