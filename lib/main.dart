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
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blueGrey,
        title: Text("Lecteur de Musique", style: TextStyle(fontSize: 24, color: Colors.white)),
        actions: [
          IconButton(
            icon: Icon(Icons.favorite, color: Colors.red),
            onPressed: _goToFavorites,
          ),
        ],
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isLandscape = constraints.maxWidth > constraints.maxHeight;

          // Dynamically adjust sizes based on orientation
          double imageSize = isLandscape ? 180 : 250;
          double iconSize = isLandscape ? 30 : 36;
          double textSize = isLandscape ? 14 : 18;

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Adjust the image size for landscape
                Flexible(
                  child: Image.asset('assets/image1.png', width: imageSize, height: imageSize),
                ),
                SizedBox(height: 20),
                showControls
                    ? Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              IconButton(
                                icon: Icon(Icons.skip_previous, color: Colors.blueGrey),
                                onPressed: _playPrevious,
                              ),
                              IconButton(
                                icon: Icon(isPlaying ? Icons.pause : Icons.play_arrow, color: Colors.blue),
                                onPressed: _togglePlayPause,
                                iconSize: iconSize,
                              ),
                              IconButton(
                                icon: Icon(Icons.skip_next, color: Colors.blueGrey),
                                onPressed: _playNext,
                              ),
                            ],
                          ),
                          SizedBox(height: 15),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(songName, style: TextStyle(fontSize: textSize, color: Colors.black87)),
                              IconButton(
                                icon: Icon(
                                  isFavorite ? Icons.favorite : Icons.favorite_border,
                                  color: Colors.red,
                                ),
                                onPressed: _toggleFavorite,
                              )
                            ],
                          ),
                        ],
                      )
                    : IconButton(
                        icon: Icon(Icons.play_arrow, size: iconSize, color: Colors.blue),
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
          );
        },
      ),
      backgroundColor: Colors.grey[100],
    );
  }
}
