import 'package:flutter/material.dart';

class SongDetailsScreen extends StatelessWidget {
  final String songName;

  const SongDetailsScreen({super.key, required this.songName});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(songName),
        backgroundColor: Colors.deepPurpleAccent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Music Icon
            Icon(
              Icons.music_note,
              color: Colors.deepPurple,
              size: 120,
            ),
            SizedBox(height: 20),

            // Song Name with styling
            Text(
              songName,
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.deepPurpleAccent,
              ),
            ),
            SizedBox(height: 10),

            // Description text with more info
            Text(
              "This is a detailed description of the song. Here you can provide more information about the artist, album, or genre of the song.",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: Colors.black54,
                height: 1.5,
              ),
            ),
            SizedBox(height: 20),

            // Play button (No 'primary' used here)
            ElevatedButton(
              onPressed: () {
                // Add action to play song or show more details
              },
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.play_arrow),
                  SizedBox(width: 8),
                  Text("Play Song"),
                ],
              ),
              style: ButtonStyle(
                backgroundColor: WidgetStateProperty.all(Colors.deepPurpleAccent),
                padding: WidgetStateProperty.all(EdgeInsets.symmetric(horizontal: 20, vertical: 12)),
                shape: WidgetStateProperty.all(RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                )),
              ),
            ),
            SizedBox(height: 20),

            // Back Button (No 'primary' used here either)
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context); // Go back to the previous screen
              },
              child: Text("Back"),
              style: ButtonStyle(
                backgroundColor: WidgetStateProperty.all(Colors.grey[600]),
                padding: WidgetStateProperty.all(EdgeInsets.symmetric(horizontal: 30, vertical: 12)),
                shape: WidgetStateProperty.all(RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                )),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
