# LivePoised Mobile — News & Articles Integration Guide

> **App**: `livepoised_mobile` (Flutter / Dart)  
> **Source Service**: `livepoisedcore` (Spring Boot API Backend)  
> **Endpoint**: `GET /api/news/trending`  
> **Updated**: 2026-08-25  

---

## 1. Feature Specifications & UI Behavior

The Dashboard's **News & Articles** component displays a horizontally scrolling list of trending medical news, recovery stories, and articles concerning spinal cord injuries (SCI), paralysis, and rehabilitation.

### Web Behavior (Ref: `NewsFeeds.tsx`)
- Displays article title, source publication name, date, description, and preview image.
- Clicking an article redirects the user to the original publisher's website in a new tab/browser.
- Implements fallback mock articles in case the GNews API limit is exceeded or server offline.

---

## 2. API Endpoint Details

The mobile app should query the Spring Boot backend instance directly:

```http
GET /api/news/trending?category={optional_category_or_keyword}
```

### 2.1 Context-Based Category Filtering
To filter the trending articles based on the user's specific context or interest, pass the `category` query parameter. The backend matches keywords against the articles' titles and descriptions:

| Category Value | Filtered Topics | Matches Keyword |
| :--- | :--- | :--- |
| `spinal` | Spinal Cord Injuries, Paralysis, Neurorehabilitation | `spinal`, `spine`, `paralysis`, `neuro`, `injury`, `quadripleg`, `parapleg` |
| `stroke` | Brain Stroke Recovery, Autoimmune, Metabolic conditions | `stroke`, `brain`, `autoimmune`, `metabolic`, `neurolog` |
| `innovation` | Medical breakthroughs, new treatments, clinical trials | `innovation`, `breakthrough`, `treatment`, `trial`, `clinical`, `tech` |
| `wellness` | Nutrition, fitness, wellness, exercise, and recovery | `nutrition`, `fitness`, `wellness`, `diet`, `recovery`, `health`, `exercise` |
| *(Any custom word)* | Custom keyword matching | Matches exact keyword search dynamically |

#### Example Context Requests:
- Get Spinal Injury Articles: `GET /api/news/trending?category=spinal`
- Get Stroke Recovery Articles: `GET /api/news/trending?category=stroke`
- Get Nutrition & Fitness Articles: `GET /api/news/trending?category=wellness`

### 2.2 Request Headers
Include standard Keycloak authorization if required (though public endpoints may bypass authorization checking):
```http
Authorization: Bearer <access_token>
Accept: application/json
```

---

## 3. Data Transfer Object (DTO) Schema

The endpoint returns a JSON array of articles. Below is the field structure:

| Field Name | Type | Description | Example |
| :--- | :--- | :--- | :--- |
| `title` | `String` | Title / Headline of the article | `"New Therapy Promotes Nerve Regeneration in Spine Injuries"` |
| `description` | `String` | Short summary / snippet of the content | `"Researchers have developed a target bio-gel showing promising spinal recovery..."` |
| `url` | `String` | Direct web link to the original publisher | `"https://sciencedaily.com/releases/2026/08/..."` |
| `imageUrl` | `String` | URL of the cover / banner image | `"https://gnews.io/images/spine-recovery.jpg"` |
| `sourceName` | `String` | The original source publisher | `"ScienceDaily"` |
| `publishedAt` | `String` | ISO 8601 formatted publication timestamp | `"2026-08-25T11:45:00Z"` |

### 3.1 JSON Response Payload Example
```json
[
  {
    "title": "New rehabilitation therapy shows promise for spinal injuries",
    "description": "A novel combination of physical training and neurostimulation has helped patients regain partial motor function.",
    "url": "https://www.medgadget.com/2026/08/spinal-injury-rehab-update.html",
    "imageUrl": "https://images.unsplash.com/photo-1576091160399-112ba8d25d1d",
    "sourceName": "Medgadget",
    "publishedAt": "2026-08-24T08:30:00Z"
  }
]
```

---

## 4. Flutter/Dart Implementation Guide

### 4.1 Dart Model class (`NewsArticle.dart`)

**File**: `lib/features/dashboard/domain/models/news_article.dart`

```dart
class NewsArticle {
  final String title;
  final String description;
  final String url;
  final String imageUrl;
  final String sourceName;
  final DateTime publishedAt;

  NewsArticle({
    required this.title,
    required this.description,
    required this.url,
    required this.imageUrl,
    required this.sourceName,
    required this.publishedAt,
  });

  factory NewsArticle.fromJson(Map<String, dynamic> json) {
    return NewsArticle(
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      url: json['url'] ?? '',
      imageUrl: json['imageUrl'] ?? '',
      sourceName: json['sourceName'] ?? 'Unknown Source',
      publishedAt: DateTime.parse(json['publishedAt'] ?? DateTime.now().toIso8601String()),
    );
  }
}
```

### 4.2 Flutter Data Source API Call

**File**: `lib/features/dashboard/data/news_repository.dart`

Use the `Dio` HTTP client to query `/api/news/trending`:

```dart
import 'package:dio/dio.dart';
import '../domain/models/news_article.dart';

class NewsRepository {
  final Dio _dio;

  NewsRepository(this._dio);

  Future<List<NewsArticle>> fetchTrendingNews({String? category}) async {
    try {
      final response = await _dio.get(
        '/api/news/trending',
        queryParameters: category != null ? {'category': category} : null,
      );
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        return data.map((json) => NewsArticle.fromJson(json)).toList();
      }
      throw Exception('Failed to load news');
    } catch (e) {
      print('[NewsRepository] Error fetching news: $e');
      return []; // Return empty list to degrade gracefully
    }
  }
}
```

### 4.3 UI Component: News Carousel Card (`news_card.dart`)

Render articles in a horizontal `ListView` on the home dashboard screen. Use the `url_launcher` package to open the link when clicked:

```dart
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../domain/models/news_article.dart';

class NewsCard extends StatelessWidget {
  final NewsArticle article;

  const NewsCard({super.key, required this.article});

  Future<void> _launchUrl() async {
    final Uri uri = Uri.parse(article.url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      throw Exception('Could not launch ${article.url}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: _launchUrl,
        child: Container(
          width: 280,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Banner Image
              AspectRatio(
                aspectRatio: 16 / 9,
                child: Image.network(
                  article.imageUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    color: Colors.teal.shade900,
                    child: const Icon(Icons.article, color: Colors.white, size: 40),
                  ),
                ),
              ),
              // Article Metadata & Title
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.between,
                      children: [
                        Text(
                          article.sourceName,
                          style: const TextStyle(fontSize: 10, color: Colors.teal, fontWeight: FontWeight.bold),
                        ),
                        Text(
                          "${article.publishedAt.day}/${article.publishedAt.month}/${article.publishedAt.year}",
                          style: const TextStyle(fontSize: 10, color: Colors.grey),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      article.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      article.description,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 11, color: Colors.black54),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
```

---

## 5. Mobile Integration Checklist

- [ ] Add `url_launcher: ^6.2.5` to `pubspec.yaml` for opening article links.
- [ ] Create data model `NewsArticle.dart`.
- [ ] Implement `NewsRepository.dart` to fetch from `/api/news/trending`.
- [ ] Bind a state controller (GetX/Riverpod) to fetch and store news articles at dashboard page initialize.
- [ ] Implement the horizontal scroll UI layout matching the web mockup design.
