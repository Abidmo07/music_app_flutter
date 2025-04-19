import 'package:flutter/material.dart';
import 'song_details_screen.dart';

class SongScreen extends StatefulWidget {
  final List<Map<String, String>> songs;
  final Function(int) onSongSelected;

  const SongScreen({
    super.key,
    required this.songs,
    required this.onSongSelected,
  });

  @override
  _SongScreenState createState() => _SongScreenState();
}

class _SongScreenState extends State<SongScreen> {
  String? selectedSong;

  @override
  Widget build(BuildContext context) {
    final orientation = MediaQuery.of(context).orientation;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Liste des Chansons",style: TextStyle(color: Colors.white),),
        backgroundColor: Colors.blueGrey,
      ),
      body: orientation == Orientation.portrait
          ? _buildPortraitLayout()
          : _buildLandscapeLayout(),
    );
  }

  Widget _buildPortraitLayout() {
    return ListView.builder(
      itemCount: widget.songs.length,
      itemBuilder: (context, index) {
        return GestureDetector(
          onLongPress: () {
            showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: Text("Delete Song"),
                  content: Text("Are you sure you want to delete this song from the list?"),
                  actions: <Widget>[
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: Text("Cancel"),
                    ),
                    TextButton(
                      onPressed: () {
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
            //pass the song to song_details screen
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => SongDetailsScreen(
                  songName: widget.songs[index]['name']!,
                ),
              ),
            );
          },
          child: ListTile(
            title: Text(widget.songs[index]['name']!, style: TextStyle(color: Colors.black87)),
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
            itemCount: widget.songs.length,
            itemBuilder: (context, index) {
              return GestureDetector(
                onTap: () {
                  setState(() {
                    selectedSong = widget.songs[index]['name'];
                  });
                  // No need to play the song, just set it for display
                },
                child: ListTile(
                  title: Text(widget.songs[index]['name']!, style: TextStyle(color: Colors.black87)),
                ),
              );
            },
          ),
        ),
        // Show song details in landscape when selectedSong
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
                    ],
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
