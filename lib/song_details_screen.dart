import 'package:flutter/material.dart';

class SongDetailsScreen extends StatelessWidget {
  final String songName;

  const SongDetailsScreen({super.key, required this.songName});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(songName, style: TextStyle(fontSize: 24,color:Colors.white)),
        backgroundColor: Colors.blueGrey,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(
              Icons.music_note,
              color: Colors.blueGrey,
              size: 120,
            ),
            SizedBox(height: 20),
            Text(
              songName,
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.blueGrey,
              ),
            ),
            SizedBox(height: 10),
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
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text("Back",style: TextStyle(color: Colors.white),),
              style: ButtonStyle(
                backgroundColor: WidgetStateProperty.all( Colors.blueGrey),
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
