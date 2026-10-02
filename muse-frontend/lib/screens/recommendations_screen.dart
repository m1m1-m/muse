import 'package:flutter/material.dart';
import '../services/api_service.dart';

class RecommendationsScreen extends StatefulWidget {
  const RecommendationsScreen({super.key});

  @override
  State<RecommendationsScreen> createState() =>
      _RecommendationsScreenState();
}

class _RecommendationsScreenState
    extends State<RecommendationsScreen> {
  final ApiService apiService = ApiService();

  List<dynamic> recommendations = [];

  bool loading = true;
  String? error;

  String? selectedOccasion;
  String? selectedSeason;

  final List<String> occasions = [
    'casual',
    'work',
    'formal',
    'sport',
    'travel',
  ];

  final List<String> seasons = [
    'spring',
    'summer',
    'autumn',
    'winter',
    'all',
  ];

  @override
  void initState() {
    super.initState();
    loadRecommendations();
  }

  Future<void> loadRecommendations() async {
    setState(() {
      loading = true;
      error = null;
    });

    try {
      final result = await apiService.getRecommendations(
        occasion: selectedOccasion,
        season: selectedSeason,
      );

      if (!mounted) return;

      setState(() {
        recommendations = result;
        loading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        error = e.toString();
        loading = false;
      });
    }
  }

  String getValue(dynamic item, String key) {
    if (item is Map<String, dynamic>) {
      return item[key]?.toString() ?? '';
    }

    return '';
  }

  String getRecommendationName(dynamic item) {
    if (item is Map<String, dynamic>) {
      return item['name']?.toString() ??
          item['outfitName']?.toString() ??
          'Recommended Outfit';
    }

    return 'Recommended Outfit';
  }

  String getRecommendationId(dynamic item) {
    if (item is Map<String, dynamic>) {
      return item['id']?.toString() ??
          item['outfitId']?.toString() ??
          '';
    }

    return '';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Recommendations'),
      ),
      body: Column(
        children: [
          _buildFilters(),
          Expanded(
            child: _buildBody(),
          ),
        ],
      ),
    );
  }

  Widget _buildFilters() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<String>(
                  initialValue: selectedOccasion,
                  decoration: const InputDecoration(
                    labelText: 'Occasion',
                    border: OutlineInputBorder(),
                  ),
                  items: occasions.map(
                    (occasion) {
                      return DropdownMenuItem<String>(
                        value: occasion,
                        child: Text(
                          occasion[0].toUpperCase() +
                              occasion.substring(1),
                        ),
                      );
                    },
                  ).toList(),
                  onChanged: (value) {
                    setState(() {
                      selectedOccasion = value;
                    });

                    loadRecommendations();
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: DropdownButtonFormField<String>(
                  initialValue: selectedSeason,
                  decoration: const InputDecoration(
                    labelText: 'Season',
                    border: OutlineInputBorder(),
                  ),
                  items: seasons.map(
                    (season) {
                      return DropdownMenuItem<String>(
                        value: season,
                        child: Text(
                          season[0].toUpperCase() +
                              season.substring(1),
                        ),
                      );
                    },
                  ).toList(),
                  onChanged: (value) {
                    setState(() {
                      selectedSeason = value;
                    });

                    loadRecommendations();
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () {
                setState(() {
                  selectedOccasion = null;
                  selectedSeason = null;
                });

                loadRecommendations();
              },
              icon: const Icon(Icons.clear),
              label: const Text('Clear Filters'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBody() {
    if (loading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.error_outline,
                size: 50,
              ),
              const SizedBox(height: 15),
              Text(
                error!,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 15),
              ElevatedButton(
                onPressed: loadRecommendations,
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    if (recommendations.isEmpty) {
      return RefreshIndicator(
        onRefresh: loadRecommendations,
        child: ListView(
          children: const [
            SizedBox(height: 150),
            Icon(
              Icons.auto_awesome,
              size: 60,
            ),
            SizedBox(height: 15),
            Center(
              child: Text(
                'No recommendations available.',
                style: TextStyle(fontSize: 18),
                textAlign: TextAlign.center,
              ),
            ),
            SizedBox(height: 8),
            Center(
              child: Text(
                'Try adding more outfits or changing the filters.',
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: loadRecommendations,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: recommendations.length,
        itemBuilder: (context, index) {
          final recommendation =
              recommendations[index];

          final name =
              getRecommendationName(recommendation);

          final id =
              getRecommendationId(recommendation);

          final occasion =
              getValue(recommendation, 'occasion');

          final season =
              getValue(recommendation, 'season');

          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: ListTile(
              leading: const CircleAvatar(
                child: Icon(Icons.auto_awesome),
              ),
              title: Text(
                name,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
              subtitle: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  if (occasion.isNotEmpty)
                    Text('Occasion: $occasion'),
                  if (season.isNotEmpty)
                    Text('Season: $season'),
                  if (id.isNotEmpty)
                    Text('Outfit ID: $id'),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}