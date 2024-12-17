import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'OMDb API Demo',
      home: MovieListScreen(),
    );
  }
}

class MovieListScreen extends StatefulWidget {
  @override
  _MovieListScreenState createState() => _MovieListScreenState();
}

class _MovieListScreenState extends State<MovieListScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<Movie> _movies = [];
  final String apiKey = '75b6d53';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('OMDb Recherche des films'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _searchController,
              decoration: const InputDecoration(labelText: 'Chercher un Film'),
              onSubmitted: (value) {
                _searchMovies(value);
              },
            ),
            const SizedBox(height: 16.0),
            Expanded(
              child: ListView.builder(
                itemCount: _movies.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    leading: Image.network(_movies[index].poster, width: 50, errorBuilder: (context, error, stackTrace) => const Icon(Icons.movie)),
                    title: Text(_movies[index].title),
                    subtitle: Text('${_movies[index].year} (${_movies[index].type})'),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => MovieDetailScreen(
                            movieId: _movies[index].imdbID,
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _searchMovies(String query) async {
    const apiKey = '75b6d53';
    final apiUrl = 'http://www.omdbapi.com/?apikey=$apiKey&s=$query';

    final response = await http.get(Uri.parse(apiUrl));

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      final List<dynamic> movies = data['Search'];

      setState(() {
        _movies = movies.map((movie) => Movie.fromJson(movie)).toList();
      });
    } else {
      throw Exception('Failed to load movies');
    }
  }
}

class Movie {
  final String title;
  final String year;
  final String imdbID;
  final String type;
  final String poster;

  Movie({
    required this.title,
    required this.year,
    required this.imdbID,
    required this.type,
    required this.poster,
  });

  factory Movie.fromJson(Map<String, dynamic> json) {
    return Movie(
      title: json['Title'] ?? 'Je ne trouve pas',
      year: json['Year'] ?? 'Je ne trouve pas',
      imdbID: json['imdbID'] ?? '',
      type: json['Type'] ?? 'Je ne trouve pas',
      poster: json['Poster'] ?? '',
    );
  }
}

class MovieDetailScreen extends StatefulWidget {
    final String movieId;

    const MovieDetailScreen({Key? key, required this.movieId}) : super(key: key);


  @override
  _MovieDetailScreenState createState() => _MovieDetailScreenState();
  }
  
  class _MovieDetailScreenState extends State<MovieDetailScreen> {
  Map<String, dynamic>? movieDetails;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _RecupMovieDetails();
  }

  Future<void> _RecupMovieDetails() async {
    final apiKey = '75b6d53';
    final apiUrl = 'http://www.omdbapi.com/?apikey=$apiKey&i=${widget.movieId}';

    final response = await http.get(Uri.parse(apiUrl));

    if (response.statusCode == 200) {
      setState(() {
        movieDetails = json.decode(response.body);
        isLoading = false;
      });
    } else {
      setState(() {
        isLoading = false;
      });
      throw Exception('Failed to load movie details');
    }
  }
    
      @override
      Widget build(BuildContext context) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Details du film'),
          ),
          body: isLoading
              ? const Center(child: CircularProgressIndicator())
              : movieDetails == null
                  ? const Center(child: Text('Erreur de chargement'))
                  : Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Center(
                            child: Image.network(
                              movieDetails!['Poster'] ?? '',
                              height: 300,
                            ),
                          ),
                          
                          Text(
                            '${movieDetails!['Title']}',
                            style: const TextStyle(
                                height: 4,
                                fontSize: 20,
                                fontWeight: FontWeight.bold)
                           ),
                           const SizedBox(height: 10),
                           Text('Année de sortie : ${movieDetails!['Year']}'),
                           const SizedBox(height: 10),
                           Text('Genre : ${movieDetails!['Genre']}'),
                           const SizedBox(height: 10),
                           Text('Réalisateur : ${movieDetails!['Director']}'),
                           const SizedBox(height: 10),
                           Text('Résumé : ${movieDetails!['Plot']}'),
                 ],
                  ),
                ),
    );
  }
}
