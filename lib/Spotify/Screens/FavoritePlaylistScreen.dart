import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../Service/SpotifyService.dart';

class FavoritePlaylistScreen extends StatefulWidget {
  @override
  _FavoritePlaylistScreenState createState() => _FavoritePlaylistScreenState();
}

class _FavoritePlaylistScreenState extends State<FavoritePlaylistScreen> {
  final SpotifyService _spotifyService = SpotifyService();
  List<Map<String, dynamic>>? playlists;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _authenticateAndFetchPlaylists();
  }

  Future<void> _authenticateAndFetchPlaylists() async {
    setState(() {
      isLoading = true;
    });
    await _spotifyService.authenticate();
    final userPlaylists = await _spotifyService.getUserPlaylists();
    setState(() {
      playlists = userPlaylists;
      isLoading = false;
    });
  }

  Future<void> _saveFavoritePlaylist(Map<String, dynamic> playlist) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .update({'favoritePlaylist': playlist});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Select Favorite Playlist'),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : playlists == null
          ? Center(child: Text('No playlists found'))
          : ListView.builder(
        itemCount: playlists!.length,
        itemBuilder: (context, index) {
          final playlist = playlists![index];
          return ListTile(
            leading: playlist['imageUrl'] != null
                ? Image.network(playlist['imageUrl'])
                : Icon(Icons.music_note),
            title: Text(playlist['name']),
            onTap: () {
              _saveFavoritePlaylist(playlist);
              Navigator.pop(context);
            },
          );
        },
      ),
    );
  }
}
