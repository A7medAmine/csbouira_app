import 'package:flutter_test/flutter_test.dart';
import 'package:csbouira_app/core/deep_links.dart';

void main() {
  group('parseAppLink', () {
    test('parses file links', () {
      final link = parseAppLink(Uri.parse('csbouira://file/1SJSYrQcCrx7o7-kcKX'));
      expect(link, const FileLink('1SJSYrQcCrx7o7-kcKX'));
    });

    test('round-trips fileDeepLink', () {
      const id = '18PpUPrc_cyKE-lRQasMRBDO_pfrO6Xxt';
      expect(parseAppLink(Uri.parse(fileDeepLink(id))), const FileLink(id));
    });

    test('parses the what\'s new link', () {
      expect(parseAppLink(Uri.parse('csbouira://new')), const WhatsNewLink());
    });

    test('rejects other schemes, hosts and malformed IDs', () {
      expect(parseAppLink(Uri.parse('https://file/abcdefghijk')), isNull);
      expect(parseAppLink(Uri.parse('csbouira://folder/abcdefghijk')), isNull);
      expect(parseAppLink(Uri.parse('csbouira://file/')), isNull);
      expect(parseAppLink(Uri.parse('csbouira://file/short')), isNull);
      expect(parseAppLink(Uri.parse('csbouira://file/abc/def/ghi')), isNull);
      expect(parseAppLink(Uri.parse('csbouira://file/..%2F..%2Fetc')), isNull);
    });
  });

  group('routeForLink', () {
    test('maps links to routes', () {
      expect(routeForLink(const FileLink('abcdefghijkl')), '/open/file/abcdefghijkl');
      expect(routeForLink(const WhatsNewLink()), '/whats-new');
    });

    test('maps browse links to year, semester and module routes', () {
      expect(routeForLink(const BrowseLink('Licence 3 SI')), '/year/Licence%203%20SI');
      expect(
        routeForLink(const BrowseLink('Licence 1', semester: '2024-2025>subfolders>S1')),
        '/year/Licence%201/semester/2024-2025%3Esubfolders%3ES1',
      );
      expect(
        routeForLink(const BrowseLink('Licence 3 SI', semester: 'S05', module: 'Génie Logiciel')),
        '/year/Licence%203%20SI/semester/S05/module/G%C3%A9nie%20Logiciel',
      );
    });
  });

  group('browseDeepLink', () {
    test('round-trips through parseAppLink', () {
      const cases = [
        BrowseLink('Licence 3 SI'),
        BrowseLink('Licence 1', semester: '2024-2025>subfolders>S1'),
        BrowseLink('Master 1 IA', semester: 'S07', module: 'Machine Learning & IA'),
      ];
      for (final link in cases) {
        final uri = Uri.parse(browseDeepLink(
          link.year,
          semester: link.semester,
          module: link.module,
        ));
        expect(parseAppLink(uri), link);
      }
    });

    test('rejects empty or too deep paths', () {
      expect(parseAppLink(Uri.parse('csbouira://browse')), isNull);
      expect(parseAppLink(Uri.parse('csbouira://browse/a/b/c/d')), isNull);
    });
  });

  group('DeepLinkService', () {
    test('queues a link until attach, then routes directly', () {
      final service = DeepLinkService.instance;
      final routes = <String>[];

      service.handleUri(Uri.parse('csbouira://new'));
      expect(routes, isEmpty);

      service.attach(routes.add);
      expect(routes, ['/whats-new']);

      service.handleUri(Uri.parse('csbouira://file/abcdefghijkl'));
      service.handleUri(Uri.parse('https://example.com'));
      expect(routes, ['/whats-new', '/open/file/abcdefghijkl']);
    });
  });
}
