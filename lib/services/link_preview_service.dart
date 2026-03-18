import 'package:http/http.dart' as http;
import 'package:html/parser.dart' show parse;

/// Represents metadata extracted from a web link
class LinkMetadata {
  final String? title;
  final String? description;
  final String? imageUrl;
  final String? siteName;

  LinkMetadata({
    this.title,
    this.description,
    this.imageUrl,
    this.siteName,
  });
}

/// Service for extracting Open Graph metadata from links
class LinkPreviewService {
  /// Extract Open Graph metadata from a URL
  static Future<LinkMetadata?> getMetadata(String url) async {
    try {
      // Validate URL
      if (!url.startsWith('http://') && !url.startsWith('https://')) {
        return null;
      }

      // Fetch the page with a reasonable timeout
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36',
          'Accept': 'text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,*/*;q=0.8',
          'Accept-Language': 'en-US,en;q=0.5',
        },
      ).timeout(const Duration(seconds: 8));

      if (response.statusCode != 200) {
        // ignore: avoid_print
        print('⚠️ HTTP ${response.statusCode} for $url');
        return null;
      }

      // Parse the HTML
      try {
        final document = parse(response.body);

        // Extract Open Graph meta tags
        final title = _getMetaContent(document, 'og:title') ??
            _getMetaContent(document, 'twitter:title') ??
            _getTitle(document);

        final description = _getMetaContent(document, 'og:description') ??
            _getMetaContent(document, 'twitter:description') ??
            _getDescription(document);

        final imageUrl = _getMetaContent(document, 'og:image') ??
            _getMetaContent(document, 'twitter:image');

        final siteName = _getMetaContent(document, 'og:site_name') ?? _extractDomain(url);

        // Log what we found
        // ignore: avoid_print
        print('📄 Parsed $url: title="$title", has_desc=${description != null}, has_image=${imageUrl != null}');

        return LinkMetadata(
          title: title,
          description: description,
          imageUrl: imageUrl,
          siteName: siteName,
        );
      } catch (parseError) {
        // ignore: avoid_print
        print('❌ Parse error for $url: $parseError');
        return null;
      }
    } catch (e) {
      // ignore: avoid_print
      print('❌ Network error fetching $url: $e');
      return null;
    }
  }

  /// Get meta tag content by property name
  static String? _getMetaContent(dynamic document, String property) {
    try {
      final element = document.querySelector('meta[property="$property"]') ??
          document.querySelector('meta[name="$property"]');
      return element?.attributes['content'];
    } catch (e) {
      return null;
    }
  }

  /// Get page title
  static String? _getTitle(dynamic document) {
    try {
      return document.querySelector('title')?.text;
    } catch (e) {
      return null;
    }
  }

  /// Get meta description
  static String? _getDescription(dynamic document) {
    try {
      final element = document.querySelector('meta[name="description"]');
      return element?.attributes['content'];
    } catch (e) {
      return null;
    }
  }

  /// Extract domain from URL
  static String _extractDomain(String url) {
    try {
      final uri = Uri.parse(url);
      return uri.host.replaceFirst('www.', '');
    } catch (e) {
      return 'Link';
    }
  }
}
