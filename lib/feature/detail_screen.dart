import 'package:flutter/material.dart';
import 'package:tugasakhirtpm/services/api_service.dart';

class DetailScreen extends StatelessWidget {
  final int heroId;

  DetailScreen({required this.heroId});

  final ApiService apiService = ApiService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Hero Detail'),
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: apiService.fetchHeroById(heroId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(
                child: Text('Failed to load hero details: ${snapshot.error}'));
          } else {
            final heroData = snapshot.data!;
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    heroData['name'] ?? 'No name',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 10),
                  heroData['image'] != null
                      ? Image.network(heroData['image'])
                      : SizedBox(),
                  SizedBox(height: 10),
                  Text('Full Name: ${heroData['biography']}'),
                  SizedBox(height: 10),
                  Text('Publisher: ${heroData['publisher']}'),
                  SizedBox(height: 10),
                  Text('Power Stats:'),
                  Text(
                      'Intelligence: ${heroData['powerstats']['intelligence']}'),
                  Text('Strength: ${heroData['powerstats']['strength']}'),
                  Text('Speed: ${heroData['powerstats']['speed']}'),
                  Text('Durability: ${heroData['powerstats']['durability']}'),
                  Text('Power: ${heroData['powerstats']['power']}'),
                  Text('Combat: ${heroData['powerstats']['combat']}'),
                ],
              ),
            );
          }
        },
      ),
    );
  }
}
