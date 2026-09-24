import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:csbouira_app/data/services/file_cache_service.dart';
import 'package:csbouira_app/data/services/http_download.dart';
import 'package:csbouira_app/data/services/qr_share_service.dart';

void main() {
  late Directory dir;

  setUp(() async => dir = await Directory.systemTemp.createTemp('http_dl_test'));
  tearDown(() => dir.delete(recursive: true));

  group('downloadToFile', () {
    test('writes the body and returns its size', () async {
      final client = MockClient((_) async => http.Response.bytes(
            [1, 2, 3, 4],
            200,
            headers: {'content-type': 'application/pdf'},
          ));
      final dest = File('${dir.path}/a.pdf');
      final bytes = await downloadToFile(client, Uri.parse('https://x/a'), dest);
      expect(bytes, 4);
      expect(await dest.readAsBytes(), [1, 2, 3, 4]);
      expect(await File('${dest.path}.part').exists(), isFalse);
    });

    test('rejects HTML pages and leaves no file behind', () async {
      final client = MockClient((_) async => http.Response(
            '<html>virus scan warning</html>',
            200,
            headers: {'content-type': 'text/html; charset=utf-8'},
          ));
      final dest = File('${dir.path}/a.pdf');
      await expectLater(
        downloadToFile(client, Uri.parse('https://x/a'), dest),
        throwsA(isA<HttpException>()),
      );
      expect(await dest.exists(), isFalse);
    });

    test('allows HTML when asked to', () async {
      final client = MockClient((_) async => http.Response(
            '<html></html>',
            200,
            headers: {'content-type': 'text/html'},
          ));
      final dest = File('${dir.path}/page.html');
      await downloadToFile(client, Uri.parse('https://x/a'), dest, rejectHtml: false);
      expect(await dest.exists(), isTrue);
    });

    test('fails on non-200 responses', () async {
      final client = MockClient((_) async => http.Response('nope', 404));
      await expectLater(
        downloadToFile(client, Uri.parse('https://x/a'), File('${dir.path}/a')),
        throwsA(isA<HttpException>()),
      );
    });
  });

  group('extractDriveFileId', () {
    test('reads /d/<id>/ and ?id=<id> links', () {
      expect(
        extractDriveFileId('https://drive.google.com/file/d/18PpUPrc_cy-K/view'),
        '18PpUPrc_cy-K',
      );
      expect(
        extractDriveFileId('https://drive.google.com/uc?export=download&id=abc_123'),
        'abc_123',
      );
      expect(extractDriveFileId('https://example.com/file.pdf'), isNull);
    });
  });

  group('QR share data (legacy format)', () {
    test('round-trips through encode and parse', () {
      final text = encodeFileShareData(
        grade: 'Licence 1',
        semester: 'S01',
        module: 'Analyse 1',
        folder: 'Cours',
        fileIndex: 3,
        subpath: 'Chapitre 01',
      );
      final data = parseFileShareData(text)!;
      expect(data.fileIndex, 3);
      expect(data.toPathSegments(),
          ['Licence 1', 'S01', 'Analyse 1', 'Cours', 'Chapitre 01']);
    });

    test('rejects unrelated codes', () {
      expect(parseFileShareData('https://example.com'), isNull);
      expect(parseFileShareData('csbouira://file/abcdefghijk'), isNull);
    });
  });
}
