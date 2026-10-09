import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:csbouira_app/features/preview/widgets/pdf_viewer.dart';

void main() {
  // A4 portrait pages on a 400 x 800 viewport: each page is 400 wide and
  // ~566 tall, plus 4 of spacing.
  const a4 = 842 / 595;
  const viewport = Size(400, 800);
  final pageHeight = 400 * a4 + 4;

  int page(double scrollY, {double zoom = 1}) => pageAtViewportCenter(
        pageAspects: List.filled(5, a4),
        viewport: viewport,
        scrollY: scrollY,
        zoom: zoom,
      );

  test('first page at the top', () => expect(page(0), 1));

  test('counts the page in the middle, not the one at the top edge', () {
    // The end of page 2 is at the top, but page 3 fills the middle.
    expect(page(pageHeight * 2 - 100), 3);
  });

  test('uses the zoomed viewport height', () {
    // Zoomed 2x, only 400 units are visible: the middle is 200 below the top.
    expect(page(pageHeight - 150, zoom: 2), 2);
    expect(page(pageHeight - 250, zoom: 2), 1);
  });

  test('clamps to the last page', () => expect(page(pageHeight * 10), 5));

  test('no pages yet', () {
    expect(
      pageAtViewportCenter(
        pageAspects: const [],
        viewport: viewport,
        scrollY: 0,
        zoom: 1,
      ),
      0,
    );
  });
}
