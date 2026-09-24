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
