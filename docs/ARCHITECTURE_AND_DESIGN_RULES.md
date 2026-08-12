# 🎬 Documentation & Architecture Guide - AppMovie Yuki

Tài liệu này tổng hợp toàn bộ kiến trúc, thiết kế, quy chuẩn và lý do xây dựng hệ thống của dự án **AppMovie Yuki** để bất kỳ AI Agent hoặc Developer nào tiếp quản đều có thể hiểu và mở rộng dễ dàng.

---

## 📌 1. Tổng quan dự án

* **Tên dự án:** AppMovie Yuki
* **Công nghệ:** Flutter (Clean Architecture + Material 3)
* **Mục tiêu:** Ứng dụng xem phim cao cấp (Cinema Dark Theme) phong cách Netflix/TMDB. Hiện tại tập trung hoàn thiện giao diện (UI-first), sẵn sàng tích hợp REST API / GraphQL trong tương lai.
* **Tối ưu hóa:** Tối ưu bộ nhớ với lazy load (`CustomScrollView`, `ListView.builder`), resize hình ảnh (`cacheWidth`, `cacheHeight`) và hiệu ứng mượt mà.

---

## 🛠️ 2. Cấu trúc thư mục (`lib/`) & Nguyên lý thiết kế (SRP)

Dự án áp dụng chặt chẽ **Single Responsibility Principle (SRP)**. Mỗi Widget/Component nằm riêng ở 1 file duy nhất và chỉ chịu trách nhiệm cho 1 tác vụ duy nhất.

```text
lib/
├── main.dart                                  # Entry point của ứng dụng
├── core/                                      # Thành phần cốt lõi dùng chung
│   ├── constants/
│   │   └── app_colors.dart                    # Hệ thống màu sắc (Color Palette)
│   └── theme/
│       └── app_theme.dart                     # Cấu hình ThemeData (Material 3 Dark)
├── domain/                                    # Nghiệp vụ & Entity (Thuần Dart)
│   └── entities/
│       └── movie.dart                         # Entity dữ liệu Phim
├── data/                                      # Dữ liệu
│   └── mock/
│       └── mock_movies.dart                   # Dữ liệu giả lập (Mock Data) theo danh mục
└── presentation/                              # Tầng giao diện người dùng
    ├── screens/
    │   └── home/
    │       └── home_screen.dart               # Màn hình chính (Lắp ghép các sections)
    └── widgets/                               # Các Widget tái sử dụng
        ├── common/
        │   └── app_network_image.dart         # Widget load ảnh tối ưu + Loading + Error
        ├── cards/
        │   ├── movie_card.dart                # Card poster dọc compact
        │   └── top10_card.dart                # Card xếp hạng Top 10 kèm số đè
        ├── carousel/
        │   └── hero_carousel.dart             # Banner Carousel tự động chuyển slide
        ├── chips/
        │   └── category_chip_bar.dart         # Thanh chọn thể loại cuộn ngang
        ├── sections/
        │   ├── movie_section.dart             # Section phim nằm ngang (Tái sử dụng)
        │   └── top10_section.dart             # Section Top 10 phim
        └── navigation/
            └── main_navigation_bar.dart       # Bottom Navigation Bar nổi (Floating)
```

---

## 🎨 3. Quy chuẩn Thiết kế & Bảng màu (Design System & Color Rules)

Dự án sử dụng phong cách **Cinema Dark Theme** với tone màu chính:

### 🎨 Bảng màu (`AppColors`)
* **Background (`0xFF0D0C11`):** Nền đen xám cinema, tạo chiều sâu cho nội dung.
* **Surface (`0xFF1A1821`):** Nền cho card, navbar và container nổi.
* **Surface Light (`0xFF24222E`):** Nền cho chip chưa chọn, khung placeholder.
* **Primary Crimson Red (`0xFFE50914`):** Màu đỏ chủ đạo (Netflix Style) dùng cho nút bấm active, chỉ báo, viền làm nổi bật.
* **Secondary Electric Purple (`0xFF8A2BE2`):** Màu phụ trợ dùng cho các gradient hoặc điểm nhấn đặc biệt.
* **Accent Gold (`0xFFFFC107`):** Màu vàng dành riêng cho sao đánh giá (Rating star).
* **Text Primary (`0xFFF5F5F7`):** Màu chữ chính (Trắng kem sáng).
* **Text Secondary (`0xFF8E8E93`):** Màu chữ phụ (Xám nhạt).
* **Text Muted (`0xFF5B5B60`):** Màu chữ mờ cho năm sản xuất, phân loại.

### 📐 Quy tắc thành phần UI
1. **Movie Poster Card (`MovieCard`):**
   * Kích thước cố định: Width `120px`, Height `170px`.
   * Bo góc: `BorderRadius.circular(12)`.
   * Có Badge Rating đen mờ ở góc trên phải.
   * Tên phim cắt gọn `maxLines: 1`, `overflow: TextOverflow.ellipsis`.
2. **Top 10 Card (`Top10Card`):**
   * Số thứ tự từ 1 - 10 kích thước lớn `72px`, font mỏng viền nét (stroke style) đè lên góc trái của poster phim.
3. **Hero Carousel (`HeroCarousel`):**
   * Chiếm `50%` chiều cao màn hình.
   * Chạy auto-slide mỗi 5 giây với hiệu ứng mượt.
   * Sử dụng Gradient Overlay mờ dần từ đen dưới đáy lên để làm nổi bật Title, Description & Action Button.
4. **Floating Bottom Nav (`MainNavigationBar`):**
   * Nổi cách mép dưới màn hình, bo góc `24px`.
   * Tab active có icon đỏ + dải chấm tròn nhỏ (`dot indicator`) phía dưới.

---

## ⚡ 4. Quy tắc tối ưu hiệu năng (Performance Rules)

1. **Lazy Loading:**
   * Sử dụng `CustomScrollView` + `SliverToBoxAdapter` ở màn hình chính `HomeScreen` để chỉ render phần UI nằm trong hoặc sát khung hình.
   * Sử dụng `ListView.builder` với `scrollDirection: Axis.horizontal` ở các `MovieSection` để không render toàn bộ danh sách poster cùng lúc.
2. **Resize & Memory Cache Image (`AppNetworkImage`):**
   * Tất cả hình ảnh từ mạng đều đi qua `AppNetworkImage`.
   * Ép kích thước cache ảnh trong RAM bằng `cacheWidth` & `cacheHeight` (ví dụ poster 120x170 chỉ cache 240x360px) giúp tránh tràn RAM trên các thiết bị mobile.
   * Tích hợp sẵn `CircularProgressIndicator` khi đang tải và `Icon(Icons.movie_outlined)` khi lỗi.

---

## 🔄 5. Hướng dẫn Tích hợp API sau này (For AI & Dev)

Giao diện đã sẵn sàng để tích hợp API mà không cần sửa cấu trúc UI:

1. **Entity `Movie` (`lib/domain/entities/movie.dart`):**
   * Đã chứa đầy đủ các trường: `id`, `title`, `posterUrl`, `backdropUrl`, `rating`, `year`, `genre`, `overview`.
2. **Tái sử dụng `MovieSection`:**
   * Khi gọi API thành công, chỉ cần truyền danh sách `List<Movie>` thu được vào `MovieSection(title: 'Tên Section', movies: listFromApi)`.
   * Muốn thêm section mới (ví dụ: *Phim chiếu rạp*, *Phim Thái Lan*...), chỉ cần thêm 1 Widget `MovieSection` trong `HomeScreen.dart`.

---

## 📝 6. Lịch sử thay đổi gần nhất (Changelog)

* **Khởi tạo & Tái cấu trúc:** Xóa toàn bộ code cũ rác, phân chia thư mục chuẩn Clean Architecture.
* **Componentization:** Tách toàn bộ các phần của trang Home thành widget độc lập (`HeroCarousel`, `CategoryChipBar`, `MovieCard`, `Top10Card`, `MovieSection`, `Top10Section`, `MainNavigationBar`).
* **Bổ sung Section:** Thêm dữ liệu & hiển thị danh mục *Phim Đang Hot*, *Mới Cập Nhật*, *Top 10 Phim*, *Anime*, *Phim Hàn*.
* **Fix & Build:** Hoàn thiện fix lỗi callback type, chuẩn hóa linting không còn warning.

---
*Tài liệu này được tự động cập nhật để đảm bảo bất kỳ AI nào đọc vào cũng có thể lập tức phát triển tiếp các tính năng mới.*
