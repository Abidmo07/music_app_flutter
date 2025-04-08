import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'song_details_screen.dart';

class FavoritesScreen extends StatefulWidget {
  final Function(String) onSongDeleted;

  const FavoritesScreen({super.key, required this.onSongDeleted});

  @override
  _FavoritesScreenState createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  List<String> favoriteSongs = [];
  String? selectedSong;

  @override
  void initState() {
    super.initState();
    _loadFavorites();
  }

  void _loadFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      favoriteSongs = prefs.getKeys().where((key) => prefs.getBool(key) == true).toList();
    });
  }

  void _deleteFavorite(String songName) async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      prefs.remove(songName);
      favoriteSongs.remove(songName);
      widget.onSongDeleted(songName);
    });
  }

  @override
  Widget build(BuildContext context) {
    final orientation = MediaQuery.of(context).orientation;

    return Scaffold(
      appBar: AppBar(
        title: Text("Mes Favoris", style: TextStyle(fontSize: 24, color: Colors.white)),
        backgroundColor: Colors.blueGrey,
      ),
      body: orientation == Orientation.portrait
          ? _buildPortraitLayout()
          : _buildLandscapeLayout(),
    );
  }

  Widget _buildPortraitLayout() {
    return ListView.builder(
      itemCount: favoriteSongs.length,
      itemBuilder: (context, index) {
        return GestureDetector(
          onLongPress: () {
            showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: Text("Delete Song"),
                  content: Text("Are you sure you want to delete this song from favorites?"),
                  actions: <Widget>[
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: Text("Cancel"),
                    ),
                    TextButton(
                      onPressed: () {
                        _deleteFavorite(favoriteSongs[index]);
                        Navigator.of(context).pop();
                      },
                      child: Text("Delete"),
                    ),
                  ],
                );
              },
            );
          },
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => SongDetailsScreen(songName: favoriteSongs[index]),
              ),
            );
          },
          child: ListTile(
            title: Text(favoriteSongs[index], style: TextStyle(color: Colors.black87)),
          ),
        );
      },
    );
  }

  Widget _buildLandscapeLayout() {
    return Row(
      children: [
        Expanded(
          flex: 2,
          child: ListView.builder(
            itemCount: favoriteSongs.length,
            itemBuilder: (context, index) {
              return GestureDetector(
                onTap: () {
                  setState(() {
                    selectedSong = favoriteSongs[index];
                  });
                },
                child: ListTile(
                  title: Text(favoriteSongs[index], style: TextStyle(color: Colors.black87)),
                ),
              );
            },
          ),
        ),
        // Show song details in landscape when selectedSong is not null
        if (selectedSong != null)
          Expanded(
            flex: 3,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Card(
                elevation: 6,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Song Details",
                        style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Colors.blueGrey),
                      ),
                      SizedBox(height: 16),
                      Text(
                        "Song Name: $selectedSong",
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500, color: Colors.blueGrey[800]),
                      ),
                      SizedBox(height: 20),
                      Text(
                        "This is a detailed description of the song. Here you can provide more information about the artist, album, or genre of the song.",
                        style: TextStyle(fontSize: 16, color: Colors.black54, height: 1.5),
                      ),                   
      ]),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
