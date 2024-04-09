import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:xml/xml.dart' as xml;
import 'package:html/parser.dart' as htmlParser;

class RssApi {
  static const String baseUrl = 'https://vnexpress.net/rss/du-lich.rss';

  Future<List<RssItem>> getRssItems() async {
    try {
      final response = await http.get(Uri.parse(baseUrl));

      if (response.statusCode == 200) {
        final xmlContent = response.body;
        
        final rssFeed = xml.XmlDocument.parse(xmlContent);

        final items = rssFeed.findAllElements('item');

        final rssItems = items.map((item) {
          final title = item.findElements('title').first.text;
          final link = item.findElements('link').first.text;
          final description = item.findElements('description').first.text;
          final pubDate = item.findElements('pubDate').first.text;

          final imageUrl = extractImageUrlFromHtml(description);

          return RssItem(
              title: title,
              link: link,
              description: description,
              imageUrl: imageUrl,
              pubDate: pubDate);
        }).toList();

        return rssItems;
      } else {
        throw Exception(
            'Failed to get RSS feed. Status code: ${response.statusCode}');
      }
    } catch (error) {
      throw Exception('Failed to connect to the server. Error: $error');
    }
  }

  String extractImageUrlFromHtml(String htmlContent) {
    final document = htmlParser.parse(htmlContent);
    final imgElement = document.querySelector('img');

    return imgElement?.attributes['src'] ?? '';
  }
}

class RssItem {
  String title;
  String link;
  String description;
  String imageUrl;
  String pubDate; 

  RssItem({
    required this.title,
    required this.link,
    required this.description,
    required this.imageUrl,
    required this.pubDate, 
  });
}
