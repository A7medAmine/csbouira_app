import 'dart:typed_data';
import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';
import 'package:csbouira_app/data/services/ai_share_service.dart';

Uint8List _pdf(List<String> pages, {Size? lastPageSize}) {
  final doc = PdfDocument();
  final font = PdfStandardFont(PdfFontFamily.helvetica, 20);
  for (final text in pages) {
    final section = doc.sections!.add();
    if (text == pages.last && lastPageSize != null) {
      section.pageSettings
        ..orientation = PdfPageOrientation.landscape
        ..size = lastPageSize;
    }
    section.pages.add().graphics.drawString(text, font,
        bounds: const Rect.fromLTWH(0, 0, 400, 40));
  }
  final bytes = Uint8List.fromList(doc.saveSync());
  doc.dispose();
  return bytes;
}

String _text(Uint8List bytes) {
  final doc = PdfDocument(inputBytes: bytes);
  final text = PdfTextExtractor(doc).extractText();
  doc.dispose();
  return text;
}

void main() {
  group('extractPdfPage', () {
    test('keeps only the requested page', () {
      final page = extractPdfPage((_pdf(['first', 'second', 'third']), 2));
      final doc = PdfDocument(inputBytes: page);
      expect(doc.pages.count, 1);
      doc.dispose();
      final text = _text(page);
      expect(text, contains('second'));
      expect(text, isNot(contains('first')));
      expect(text, isNot(contains('third')));
    });

    test('keeps a landscape page landscape', () {
      final source = _pdf(['a', 'wide'], lastPageSize: const Size(842, 595));
      final doc = PdfDocument(inputBytes: extractPdfPage((source, 2)));
      final size = doc.pages[0].size;
      doc.dispose();
      expect(size.width, greaterThan(size.height));
    });
  });

  test('pageFileName', () {
    expect(pageFileName('Cours 3.pdf', 5), 'Cours 3 (p. 5).pdf');
    expect(pageFileName('TD.PDF', 1), 'TD (p. 1).pdf');
    expect(pageFileName('notes', 2), 'notes (p. 2).pdf');
  });

  test('mimeTypeOf', () {
    expect(AiShareService.mimeTypeOf('a.pdf'), 'application/pdf');
    expect(AiShareService.mimeTypeOf('a.png'), 'image/png');
    expect(AiShareService.mimeTypeOf('a'), 'application/octet-stream');
  });
}
