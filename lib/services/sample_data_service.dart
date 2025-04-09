import 'dart:math';
import '../models/book.dart';
import '../models/author.dart';
import '../models/category.dart';
import 'library_database_helper.dart';

class SampleDataService {
  static final Random _random = Random();

  // Tạo dữ liệu mẫu ban đầu cho ứng dụng
  static Future<void> initializeSampleData() async {
    final dbHelper = LibraryDatabaseHelper.instance;

    // Kiểm tra xem đã có dữ liệu chưa
    final books = await dbHelper.getAllBooks();
    if (books.isNotEmpty) {
      print(
        'Đã có ${books.length} sách trong database, không thêm dữ liệu mẫu.',
      );
      return;
    }

    print('Đang tạo dữ liệu mẫu...');

    // Tạo tác giả
    final authorIds = await _createSampleAuthors();

    // Tạo thể loại
    final categoryIds = await _createSampleCategories();

    // Tạo sách
    await _createSampleBooks(authorIds, categoryIds, 500);

    print('Đã tạo xong dữ liệu mẫu.');
  }

  // Tạo các tác giả mẫu
  static Future<List<int>> _createSampleAuthors() async {
    final dbHelper = LibraryDatabaseHelper.instance;
    List<int> authorIds = [];

    final authors = [
      Author(
        name: 'Nguyễn Nhật Ánh',
        email: 'nna@example.com',
        country: 'Việt Nam',
      ),
      Author(
        name: 'Paulo Coelho',
        email: 'paulo@example.com',
        country: 'Brazil',
      ),
      Author(name: 'J.K. Rowling', email: 'jk@example.com', country: 'UK'),
      Author(
        name: 'Haruki Murakami',
        email: 'haruki@example.com',
        country: 'Japan',
      ),
      Author(
        name: 'George R.R. Martin',
        email: 'grrm@example.com',
        country: 'USA',
      ),
      Author(name: 'Tố Hữu', email: 'tohuu@example.com', country: 'Việt Nam'),
      Author(
        name: 'Xuân Diệu',
        email: 'xuandieu@example.com',
        country: 'Việt Nam',
      ),
      Author(
        name: 'Hồ Xuân Hương',
        email: 'hxh@example.com',
        country: 'Việt Nam',
      ),
      Author(
        name: 'Stephen King',
        email: 'stephen@example.com',
        country: 'USA',
      ),
      Author(name: 'Dan Brown', email: 'dan@example.com', country: 'USA'),
      Author(
        name: 'Agatha Christie',
        email: 'agatha@example.com',
        country: 'UK',
      ),
      Author(
        name: 'Trần Đăng Khoa',
        email: 'tdk@example.com',
        country: 'Việt Nam',
      ),
      Author(name: 'Ngô Tất Tố', email: 'ntt@example.com', country: 'Việt Nam'),
      Author(name: 'Nam Cao', email: 'namcao@example.com', country: 'Việt Nam'),
      Author(
        name: 'Ernest Hemingway',
        email: 'ernest@example.com',
        country: 'USA',
      ),
    ];

    for (final author in authors) {
      final id = await dbHelper.insertAuthor(author);
      authorIds.add(id);
    }

    return authorIds;
  }

  // Tạo các thể loại mẫu
  static Future<List<int>> _createSampleCategories() async {
    final dbHelper = LibraryDatabaseHelper.instance;
    List<int> categoryIds = [];

    final categories = [
      Category(name: 'Tiểu thuyết', description: 'Tác phẩm văn học hư cấu dài'),
      Category(
        name: 'Truyện ngắn',
        description: 'Tác phẩm văn học hư cấu ngắn',
      ),
      Category(
        name: 'Thơ',
        description: 'Thể loại văn học sử dụng ngôn ngữ hình tượng',
      ),
      Category(
        name: 'Khoa học viễn tưởng',
        description: 'Thể loại hư cấu dựa trên khoa học và công nghệ',
      ),
      Category(
        name: 'Kinh dị',
        description: 'Thể loại gây cảm giác sợ hãi, kinh hoàng',
      ),
      Category(name: 'Trinh thám', description: 'Thể loại về phá án, điều tra'),
      Category(
        name: 'Lãng mạn',
        description: 'Thể loại tập trung vào tình yêu',
      ),
      Category(name: 'Lịch sử', description: 'Tác phẩm về các sự kiện lịch sử'),
      Category(
        name: 'Tự truyện',
        description: 'Tác phẩm kể về cuộc đời tác giả',
      ),
      Category(name: 'Tâm lý học', description: 'Sách về tâm lý con người'),
      Category(name: 'Kinh tế', description: 'Sách về kinh tế, tài chính'),
      Category(
        name: 'Kỹ năng sống',
        description: 'Sách hướng dẫn kỹ năng sống',
      ),
      Category(name: 'Thiếu nhi', description: 'Sách dành cho trẻ em'),
      Category(name: 'Giáo dục', description: 'Sách giáo dục, giáo trình'),
      Category(name: 'Văn hóa', description: 'Sách về văn hóa các dân tộc'),
    ];

    for (final category in categories) {
      final id = await dbHelper.insertCategory(category);
      categoryIds.add(id);
    }

    return categoryIds;
  }

  // Tạo sách mẫu
  static Future<void> _createSampleBooks(
    List<int> authorIds,
    List<int> categoryIds,
    int count,
  ) async {
    final dbHelper = LibraryDatabaseHelper.instance;

    // Danh sách tiền tố tên sách
    final titlePrefixes = [
      'Cuộc phiêu lưu của',
      'Bí mật của',
      'Hành trình',
      'Câu chuyện về',
      'Người thợ',
      'Đứa trẻ',
      'Vùng đất',
      'Thế giới',
      'Giấc mơ',
      'Ngọn lửa',
      'Dòng sông',
      'Ánh trăng',
      'Tiếng gọi',
      'Nỗi nhớ',
      'Giọt nước mắt',
      'Tâm hồn',
      'Tương lai',
      'Quá khứ',
      'Hiện tại',
      'Không gian',
      'Thời gian',
      'Nỗi đau',
      'Niềm vui',
      'Trái tim',
      'Linh hồn',
      'Ký ức',
      'Dấu ấn',
      'Lời hứa',
      'Mùa xuân',
      'Mùa hạ',
      'Mùa thu',
      'Mùa đông',
    ];

    // Danh sách hậu tố tên sách
    final titleSuffixes = [
      'không tên',
      'vô danh',
      'bí ẩn',
      'lãng quên',
      'vĩnh cửu',
      'tạm bợ',
      'cuối cùng',
      'đầu tiên',
      'vô tận',
      'xa xôi',
      'gần gũi',
      'thần thánh',
      'trần gian',
      'cô đơn',
      'hạnh phúc',
      'đau khổ',
      'thương nhớ',
      'mơ ước',
      'hư không',
      'thực tại',
      'ảo mộng',
      'thiên đường',
      'địa ngục',
      'trần thế',
      'kỳ lạ',
      'diệu kỳ',
      'thú vị',
      'buồn tẻ',
      'sôi động',
      'yên tĩnh',
    ];

    for (int i = 0; i < count; i++) {
      final title =
          '${titlePrefixes[_random.nextInt(titlePrefixes.length)]} ${titleSuffixes[_random.nextInt(titleSuffixes.length)]} ${i + 1}';
      final isbn =
          '978-${_random.nextInt(10000)}-${_random.nextInt(10000)}-${_random.nextInt(10)}';
      final authorId = authorIds[_random.nextInt(authorIds.length)];
      final categoryId = categoryIds[_random.nextInt(categoryIds.length)];
      final publishYear =
          2000 + _random.nextInt(24); // Năm xuất bản từ 2000-2023
      final price =
          50000 + _random.nextInt(500) * 1000; // Giá từ 50.000 - 550.000 VND
      final stockQuantity = _random.nextInt(100) + 1; // Số lượng từ 1-100

      final book = Book(
        title: title,
        isbn: isbn,
        authorId: authorId,
        categoryId: categoryId,
        publishYear: publishYear,
        price: price.toDouble(),
        stockQuantity: stockQuantity,
      );

      await dbHelper.insertBook(book);

      // In tiến độ
      if (i % 50 == 0) {
        print('Đã tạo ${i + 1}/$count sách...');
      }
    }
  }
}
