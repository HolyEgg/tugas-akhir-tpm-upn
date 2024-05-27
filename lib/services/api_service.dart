import 'package:http/http.dart' as http;
import 'dart:convert';

class ApiService {
  final String baseUrl =
      'https://cdn.jsdelivr.net/gh/akabab/superhero-api@0.3.0/api/all.json';

  Future<List<Map<String, dynamic>>> fetchHeroes() async {
    final response = await http.get(Uri.parse(baseUrl));

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data
          .map((hero) => {
                'id': hero['id'],
                'name': hero['name'],
                'image': hero['images']['md'],
                'biography': hero['biography']['fullName'],
                'publisher': hero['biography']['publisher'],
                'powerstats': hero['powerstats'],
              })
          .toList();
    } else {
      throw Exception('Failed to load heroes');
    }
  }

  Future<Map<String, dynamic>> fetchHeroById(int id) async {
    final response = await http.get(Uri.parse(baseUrl));

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.firstWhere((hero) => hero['id'] == id,
          orElse: () => throw Exception('Hero not found'));
    } else {
      throw Exception('Failed to load hero');
    }
  }
}
