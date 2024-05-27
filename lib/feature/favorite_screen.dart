import 'package:flutter/material.dart';
import 'package:tugasakhirtpm/services/api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tugasakhirtpm/main_page/register_screen.dart';
import 'detail_screen.dart';

class FavoriteScreen extends StatefulWidget {
  final Set<int> favoriteHeroIds;

  FavoriteScreen({required this.favoriteHeroIds});

  @override
  _FavoriteScreenState createState() => _FavoriteScreenState();
}

class _FavoriteScreenState extends State<FavoriteScreen> {
  final ApiService apiService = ApiService();
  List<Map<String, dynamic>> _favoriteHeroDataList = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _fetchFavoriteHeroDetails();
  }

  Future<void> _fetchFavoriteHeroDetails() async {
    setState(() {
      _isLoading = true;
    });

    try {
      for (int id in widget.favoriteHeroIds) {
        final data = await apiService.fetchHeroById(id);
        setState(() {
          _favoriteHeroDataList.add(data);
        });
      }
      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            content: Text('Failed to load favorite hero details: $e'),
          );
        },
      );
    }
  }

  Future<void> _logout(BuildContext context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => RegisterScreen()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Favorites'),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () => _logout(context),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: _isLoading
            ? CircularProgressIndicator()
            : _favoriteHeroDataList.isEmpty
                ? Center(child: Text('No favorite heroes yet'))
                : ListView.builder(
                    itemCount: _favoriteHeroDataList.length,
                    itemBuilder: (context, index) {
                      final heroData = _favoriteHeroDataList[index];
                      return GestureDetector(
                        onTap: () {
                          Navigator.of(context).push(MaterialPageRoute(
                              builder: (context) =>
                                  DetailScreen(heroId: heroData['id'])));
                        },
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              heroData['name'] ?? 'No name',
                              style: TextStyle(
                                  fontSize: 20, fontWeight: FontWeight.bold),
                            ),
                            SizedBox(height: 10),
                            heroData['image'] != null
                                ? Image.network(heroData['image'])
                                : SizedBox(),
                            SizedBox(height: 10),
                            Text('Full Name: ${heroData['biography']}'),
                            SizedBox(height: 10),
                            Text('Publisher: ${heroData['publisher']}'),
                            Divider(),
                          ],
                        ),
                      );
                    },
                  ),
      ),
    );
  }
}
