import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'favorites_screen.dart';

final RouteObserver<ModalRoute<void>> routeObserver = RouteObserver<ModalRoute<void>>();

void main() {
  runApp(MusicApp());
}

class MusicApp extends StatelessWidget {
  const MusicApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      navigatorObservers: [routeObserver],
      home: MusicScreen(),
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
      'name': 'Rani 3ayan - Abdou Gumbetta ',
      'asset': 'assets/abdou22.mp3',
    },
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _loadSong(currentSongIndex);
  }

  Future<void> _loadSong(int index) async {
    await _player.setAsset(songs[index]['asset']!);
    setState(() {
      songName = songs[index]['name']!;
      showControls = true;
      isPlaying = false;
    });
    _loadFavoriteStatus();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.paused) {
      _player.pause();
    } else if (state == AppLifecycleState.resumed) {
      final route = ModalRoute.of(context);
      if (route != null && route.isCurrent) {
        if (isPlaying) {
          _player.play();
        }
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
    if (isPlaying) {
      _player.play();
    }
    setState(() {
      isPlaying = true;
      showControls = true;
    });
  }

  void _togglePlayPause() {
    setState(() {
      if (isPlaying) {
        _player.pause();
      } else {
        _player.play();
      }
      isPlaying = !isPlaying;
    });
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
          onSongDeleted: (songName) {
            setState(() {
              if (songName == this.songName) {
                isFavorite = false;
              }
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
        setState(() {
          isPlaying = true;
        });
        _player.play();
      });
    }
  }

  void _playPrevious() {
    if (currentSongIndex > 0) {
      currentSongIndex--;
      _loadSong(currentSongIndex).then((_) {
        setState(() {
          isPlaying = true;
        });
        _player.play();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Determine the screen orientation
    bool isPortrait = MediaQuery.of(context).orientation == Orientation.portrait;

    // Define the layout for portrait and landscape
    return Scaffold(
      appBar: AppBar(
        title: Text("Lecteur de Musique"),
        actions: [
          IconButton(
            icon: Icon(Icons.favorite),
            onPressed: _goToFavorites,
          ),
        ],
      ),
      body: Center(
        child: isPortrait
            ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset('assets/image1.png', width: 250, height: 250),
                  SizedBox(height: 20),
                  showControls
                      ? Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                IconButton(
                                    icon: Icon(Icons.skip_previous),
                                    onPressed: _playPrevious),
                                IconButton(
                                  icon: Icon(isPlaying
                                      ? Icons.pause
                                      : Icons.play_arrow),
                                  onPressed: _togglePlayPause,
                                ),
                                IconButton(
                                    icon: Icon(Icons.skip_next),
                                    onPressed: _playNext),
                              ],
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(songName),
                                IconButton(
                                  icon: Icon(isFavorite
                                      ? Icons.favorite
                                      : Icons.favorite_border),
                                  color: Colors.red,
                                  onPressed: _toggleFavorite,
                                ),
                              ],
                            ),
                          ],
                        )
                      : IconButton(
                          icon: Icon(Icons.play_arrow, size: 30),
                          onPressed: () {
                            _player.play();
                            setState(() {
                              isPlaying = true;
                              showControls = true;
                            });
                          },
                        ),
                ],
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset('assets/image1.png', width: 250, height: 250),
                  SizedBox(width: 20),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      showControls
                          ? Column(
                              children: [
                                Row(
                                  children: [
                                    IconButton(
                                        icon: Icon(Icons.skip_previous),
                                        onPressed: _playPrevious),
                                    IconButton(
                                      icon: Icon(isPlaying
                                          ? Icons.pause
                                          : Icons.play_arrow),
                                      onPressed: _togglePlayPause,
                                    ),
                                    IconButton(
                                        icon: Icon(Icons.skip_next),
                                        onPressed: _playNext),
                                  ],
                                ),
                                Row(
                                  children: [
                                    Text(songName),
                                    IconButton(
                                      icon: Icon(isFavorite
                                          ? Icons.favorite
                                          : Icons.favorite_border),
                                      color: Colors.red,
                                      onPressed: _toggleFavorite,
                                    ),
                                  ],
                                ),
                              ],
                            )
                          : IconButton(
                              icon: Icon(Icons.play_arrow, size: 30),
                              onPressed: () {
                                _player.play();
                                setState(() {
                                  isPlaying = true;
                                  showControls = true;
                                });
                              },
                            ),
                    ],
                  ),
                ],
              ),
      ),
    );
  }
}
