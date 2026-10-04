import 'package:flutter_test/flutter_test.dart';
import 'package:muse_frontend/services/logic.dart';

Map<String, dynamic> item(String id, String category,
        {String season = 'all', List<String> occasions = const []}) =>
    {
      'id': id,
      'name': id,
      'category': category,
      'season': season,
      'occasions': occasions,
      'archived': false,
    };

void main() {
  test('recommend builds top+bottom+shoes and dress+shoes', () {
    final result = recommend([
      item('t1', 'top'),
      item('b1', 'bottom'),
      item('s1', 'shoes'),
      item('d1', 'dress'),
    ]);

    expect(result.map((r) => r['itemIds']), [
      ['d1', 's1'],
      ['t1', 'b1', 's1'],
    ]);
  });

  test('recommend skips archived and wrong season', () {
    final archived = item('t1', 'top')..['archived'] = true;

    final result = recommend(
      [
        archived,
        item('t2', 'top', season: 'winter'),
        item('b1', 'bottom'),
        item('s1', 'shoes'),
      ],
      season: 'summer',
    );

    expect(result, isEmpty);
  });

  test('packingItems dedupes and sorts', () {
    final items = packingItems(
      [
        {'itemIds': ['b1', 't1']},
        {'itemIds': ['t1']},
      ],
      [item('t1', 'top'), item('b1', 'bottom'), item('x', 'shoes')],
      ['x'],
    );

    expect(items.map((i) => i['itemId']), ['b1', 'x', 't1']);
  });
}
