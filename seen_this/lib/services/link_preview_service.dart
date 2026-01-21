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
  static const Duration _timeout = Duration(seconds: 10);

  /// Extract Open Graph metadata from a URL
  static Future<LinkMetadata?> getMetadata(String url) async {
    try {
      // Validate URL
      if (!url.startsWith('http://') && !url.startsWith('https://')) {
        return null;
      }

      // Fetch the page
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'User-Agent':
              'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36',
        },
      ).timeout(_timeout);

      if (response.statusCode != 200) {
        return null;
      }

      // Parse the HTML
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

      final siteName =
          _getMetaContent(document, 'og:site_name') ?? _extractDomain(url);

      return LinkMetadata(
        title: title,
        description: description,
        imageUrl: imageUrl,
        siteName: siteName,
      );
    } catch (e) {
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
