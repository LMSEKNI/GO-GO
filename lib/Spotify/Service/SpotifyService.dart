import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_web_auth/flutter_web_auth.dart';

class SpotifyService {
  final String clientId = 'YOUR_SPOTIFY_CLIENT_ID';
  final String clientSecret = 'YOUR_SPOTIFY_CLIENT_SECRET';
  final String redirectUri = 'YOUR_REDIRECT_URI';
  String? accessToken;

  Future<void> authenticate() async {
    final url =
        'https://accounts.spotify.com/authorize?client_id=$clientId&response_type=code&redirect_uri=$redirectUri&scope=user-read-private%20playlist-read-private';
    final result = await FlutterWebAuth.authenticate(
        url: url, callbackUrlScheme: "goandgoapp");

    final code = Uri.parse(result).queryParameters['code'];

    final response = await http.post(
      Uri.parse('https://accounts.spotify.com/api/token'),
      headers: {
        'Authorization': 'Basic ${base64Encode(utf8.encode('$clientId:$clientSecret'))}',
        'Content-Type': 'application/x-www-form-urlencoded'
      },
      body: {
        'grant_type': 'authorization_code',
        'code': code,
        'redirect_uri': redirectUri
      },
    );

    final data = json.decode(response.body);
    accessToken = data['access_token'];
  }

  Future<List<Map<String, dynamic>>> getUserPlaylists() async {
    final response = await http.get(
      Uri.parse('https://api.spotify.com/v1/me/playlists'),
      headers: {
        'Authorization': 'Bearer $accessToken',
      },
    );

    final data = json.decode(response.body);
    return (data['items'] as List)
        .map((item) => {
      'id': item['id'],
      'name': item['name'],
      'imageUrl': item['images'].isNotEmpty ? item['images'][0]['url'] : null
    })
        .toList();
  }
}
