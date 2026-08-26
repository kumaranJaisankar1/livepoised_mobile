import 'package:get/get.dart';
import '../../data/models/news_article.dart';
import '../../data/repository/news_repository.dart';

class NewsCategory {
  final String label;
  final String? value; // null = default aggregated feed ("All")

  const NewsCategory(this.label, this.value);
}

class NewsController extends GetxController {
  final NewsRepository _repository;

  NewsController({NewsRepository? repository}) : _repository = repository ?? NewsRepository();

  static const List<NewsCategory> categories = [
    NewsCategory('All', null),
    NewsCategory('Spinal & Rehab', 'spinal'),
    NewsCategory('Stroke Recovery', 'stroke'),
    NewsCategory('Innovations', 'innovation'),
    NewsCategory('Wellness', 'wellness'),
  ];

  final articles = <NewsArticle>[].obs;
  final isLoading = false.obs;
  final selectedCategory = Rxn<String>();

  @override
  void onInit() {
    super.onInit();
    fetchTrendingNews();
  }

  void selectCategory(String? category) {
    if (selectedCategory.value == category) return;
    selectedCategory.value = category;
    fetchTrendingNews();
  }

  Future<void> fetchTrendingNews() async {
    isLoading.value = true;
    try {
      articles.value = await _repository.fetchTrendingNews(category: selectedCategory.value);
    } finally {
      isLoading.value = false;
    }
  }
}
