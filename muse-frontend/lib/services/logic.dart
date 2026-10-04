const categories = ['top', 'bottom', 'dress', 'outerwear', 'shoes', 'accessory'];
const seasons = ['spring', 'summer', 'autumn', 'winter', 'all'];
const occasionList = ['casual', 'work', 'formal', 'sport', 'travel'];

int _score(Map<String, dynamic> item, String? occasion, String? season) {
  final occasions = (item['occasions'] as List?) ?? const [];

  return (occasion != null && occasions.contains(occasion) ? 2 : 0) +
      (season != null && item['season'] == season ? 1 : 0);
}

/// Rule-based outfit suggestions: top+bottom+shoes or dress+shoes.
List<Map<String, dynamic>> recommend(
  List<Map<String, dynamic>> items, {
  String? occasion,
  String? season,
}) {
  final candidates = items.where((i) {
    final occasions = (i['occasions'] as List?) ?? const [];

    return i['archived'] != true &&
        (season == null || i['season'] == 'all' || i['season'] == season) &&
        (occasion == null || occasions.isEmpty || occasions.contains(occasion));
  }).toList();

  List<Map<String, dynamic>> by(String category) {
    final list = candidates.where((i) => i['category'] == category).toList()
      ..sort((a, b) {
        final byScore = _score(b, occasion, season) - _score(a, occasion, season);
        return byScore != 0
            ? byScore
            : (a['id'] as String).compareTo(b['id'] as String);
      });

    return list.take(12).toList();
  }

  final tops = by('top');
  final bottoms = by('bottom');
  final dresses = by('dress');
  final shoes = by('shoes');

  final combinations = <List<Map<String, dynamic>>>[
    for (final top in tops)
      for (final bottom in bottoms)
        for (final shoe in shoes) [top, bottom, shoe],
    for (final dress in dresses)
      for (final shoe in shoes) [dress, shoe],
  ];

  final result = combinations
      .map((group) => {
            'itemIds': group.map((i) => i['id'] as String).toList(),
            'score': group.fold<int>(
              0,
              (sum, i) => sum + _score(i, occasion, season),
            ),
          })
      .toList()
    ..sort((a, b) {
      final byScore = (b['score'] as int) - (a['score'] as int);
      return byScore != 0
          ? byScore
          : (a['itemIds'] as List).join(',').compareTo(
                (b['itemIds'] as List).join(','),
              );
    });

  return result.take(10).toList();
}

List<Map<String, dynamic>> packingItems(
  List<Map<String, dynamic>> outfits,
  List<Map<String, dynamic>> wardrobe,
  List<String> extraIds,
) {
  final used = <String>{
    for (final o in outfits) ...List<String>.from(o['itemIds'] as List),
    ...extraIds,
  };

  return wardrobe
      .where((i) => used.contains(i['id']))
      .map((i) => {
            'itemId': i['id'],
            'name': i['name'],
            'category': i['category'],
            'quantity': 1,
            'packed': false,
          })
      .toList()
    ..sort((a, b) {
      final byCategory =
          (a['category'] as String).compareTo(b['category'] as String);
      return byCategory != 0
          ? byCategory
          : (a['name'] as String).compareTo(b['name'] as String);
    });
}
