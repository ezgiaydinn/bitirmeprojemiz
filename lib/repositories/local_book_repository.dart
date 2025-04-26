// lib/repositories/local_book_repository.dart

import 'dart:async';
import 'package:bitirmeprojesi/models/book.dart';
import 'book_repository.dart';

class LocalBookRepository implements BookRepository {
  final List<Book> _dummy = List<Book>.generate(
    20,
        (i) => Book(
      id: '$i',
      title: 'Demo Kitap $i',
      authors: ['Yazar $i'],
      thumbnailUrl: '',
      description: 'Demo açıklama $i',
      publishedDate: '2025',   // artık nullable ama biz dolduruyoruz
      averageRating: null,
      ratingsCount: null,
    ),
  );

  @override
  Future<List<Book>> fetchRecommendations({String query = ''}) async {
    await Future.delayed(const Duration(milliseconds: 500));
    return _dummy;
  }

  @override
  Future<List<Book>> fetchLibraryBooks() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return <Book>[];
  }
}
