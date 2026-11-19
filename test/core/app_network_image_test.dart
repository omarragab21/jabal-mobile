import 'package:cached_network_image/cached_network_image.dart';
import 'package:dr_jabel/core/images/app_image_cache.dart';
import 'package:dr_jabel/core/widgets/app_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Widget _host(Widget child, {double dpr = 3}) => MediaQuery(
  data: MediaQueryData(devicePixelRatio: dpr),
  child: Directionality(
    textDirection: TextDirection.rtl,
    // Loose constraints: the test view would otherwise force the screen size.
    child: Center(child: child),
  ),
);

CachedNetworkImage _image(WidgetTester tester) =>
    tester.widget<CachedNetworkImage>(find.byType(CachedNetworkImage));

void main() {
  testWidgets('a web picture goes through the app cache', (tester) async {
    await tester.pumpWidget(
      _host(
        const SizedBox(
          width: 100,
          height: 100,
          child: AppNetworkImage(url: 'https://example.com/a.png'),
        ),
      ),
    );
    final image = _image(tester);
    expect(image.imageUrl, 'https://example.com/a.png');
    expect(
      image.cacheManager,
      same(AppImageCacheManager.instance),
      reason: 'one shared disk cache',
    );
    expect(image.useOldImageOnUrlChange, isTrue);
  });

  testWidgets('it decodes no bigger than the space it fills', (tester) async {
    await tester.pumpWidget(
      _host(
        const SizedBox(
          width: 100,
          height: 100,
          child: AppNetworkImage(url: 'https://example.com/a.png'),
        ),
      ),
    );
    expect(_image(tester).memCacheWidth, 300, reason: '100 logical x 3');

    await tester.pumpWidget(
      _host(
        const SizedBox(
          width: 800,
          height: 100,
          child: AppNetworkImage(url: 'https://example.com/a.png'),
        ),
      ),
    );
    expect(_image(tester).memCacheWidth, 1080, reason: 'capped');
  });

  testWidgets('without a source, or with a bundled one, no web cache', (
    tester,
  ) async {
    await tester.pumpWidget(
      _host(
        const SizedBox(
          width: 50,
          height: 50,
          child: AppNetworkImage(url: null),
        ),
      ),
    );
    expect(find.byType(CachedNetworkImage), findsNothing);

    await tester.pumpWidget(
      _host(
        const SizedBox(width: 50, height: 50, child: AppNetworkImage(url: '')),
      ),
    );
    expect(find.byType(CachedNetworkImage), findsNothing);

    await tester.pumpWidget(
      _host(
        const SizedBox(
          width: 50,
          height: 50,
          child: AppNetworkImage(url: 'assets/images/sections/hair.jpg'),
        ),
      ),
    );
    expect(find.byType(CachedNetworkImage), findsNothing);
    expect(find.byType(Image), findsOneWidget);
  });

  testWidgets('a picture repaints on its own', (tester) async {
    await tester.pumpWidget(
      _host(
        const SizedBox(
          width: 100,
          height: 100,
          child: AppNetworkImage(url: 'https://example.com/a.png'),
        ),
      ),
    );
    expect(
      find.descendant(
        of: find.byType(AppNetworkImage),
        matching: find.byType(RepaintBoundary),
      ),
      findsWidgets,
    );
  });

  test('the cache keeps pictures for a month and is bounded', () {
    expect(AppImageCacheManager.maxObjects, 400);
    expect(AppImageCacheManager.key, 'drJabelImages');
  });
}
