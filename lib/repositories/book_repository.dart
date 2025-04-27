import 'package:bitirmeprojesi/models/book.dart';

abstract class BookRepository {
  Future<List<Book>> fetchRecommendations({String query = ''});
  Future<List<Book>> fetchLibraryBooks();
}
