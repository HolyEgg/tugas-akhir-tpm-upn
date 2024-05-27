import 'package:flutter/material.dart';
import 'package:tugasakhirtpm/main_page/register_screen.dart';
import 'package:tugasakhirtpm/services/api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'favorite_screen.dart';
import 'detail_screen.dart';

class DashboardScreen extends StatefulWidget {
  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final TextEditingController _controller = TextEditingController();
  final ApiService apiService = ApiService();
  List<Map<String, dynamic>> _heroDataList = [];
  bool _isLoading = false;
  Set<int> _favoriteHeroIds = Set<int>();

  @override
  void initState() {
    super.initState();
    _loadFavoriteHeroIds();
    _fetchHeroData();
  }

  Future<void> _loadFavoriteHeroIds() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String>? favoriteIds = prefs.getStringList('favoriteHeroIds');
    if (favoriteIds != null) {
      setState(() {
        _favoriteHeroIds = favoriteIds.map((id) => int.parse(id)).toSet();
      });
    }
  }

  Future<void> _toggleFavorite(int id) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (_favoriteHeroIds.contains(id)) {
      setState(() {
        _favoriteHeroIds.remove(id);
      });
    } else {
      setState(() {
        _favoriteHeroIds.add(id);
      });
    }
    await prefs.setStringList('favoriteHeroIds',
        _favoriteHeroIds.map((id) => id.toString()).toList());
  }

  Future<void> _fetchHeroData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final data = await apiService.fetchHeroes();
      setState(() {
        _heroDataList = data;
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
            content: Text('Failed to load hero details: $e'),
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

  List<Map<String, dynamic>> _searchHeroes(String query) {
    return _heroDataList.where((hero) {
      final heroName = hero['name'].toLowerCase();
      final input = query.toLowerCase();
      return heroName.contains(input);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Dashboard'),
        actions: [
          IconButton(
            icon: Icon(Icons.favorite),
            onPressed: () {
              Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) =>
                      FavoriteScreen(favoriteHeroIds: _favoriteHeroIds)));
            },
          ),
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () => _logout(context),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _controller,
              decoration: InputDecoration(
                labelText: 'Enter Hero Name',
                border: OutlineInputBorder(),
              ),
              onChanged: (query) {
                setState(() {
                  _heroDataList = _searchHeroes(query);
                });
              },
            ),
            SizedBox(height: 20),
            _isLoading
                ? CircularProgressIndicator()
                : Expanded(
                    child: ListView.builder(
                      itemCount: _heroDataList.length,
                      itemBuilder: (context, index) {
                        final heroData = _heroDataList[index];
                        final isFavorite =
                            _favoriteHeroIds.contains(heroData['id']);
                        return GestureDetector(
                          onTap: () {
                            Navigator.of(context).push(MaterialPageRoute(
                                builder: (context) =>
                                    DetailScreen(heroId: heroData['id'])));
                          },
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    heroData['name'] ?? 'No name',
                                    style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  IconButton(
                                    icon: Icon(
                                      isFavorite
                                          ? Icons.favorite
                                          : Icons.favorite_border,
                                      color: isFavorite ? Colors.red : null,
                                    ),
                                    onPressed: () =>
                                        _toggleFavorite(heroData['id']),
                                  ),
                                ],
                              ),
                              SizedBox(height: 10),
                              heroData['image'] != null
                                  ? Image.network(heroData['image'])
                                  : SizedBox(),
                              Divider(), // Add a divider between each hero data
                            ],
                          ),
                        );
                      },
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}
