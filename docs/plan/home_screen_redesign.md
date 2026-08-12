# 🎬 Redesign Home Screen - AppMovie Yuki

> **Mục tiêu:** Xóa toàn bộ code cũ trong `presentation/`, xây lại Home Screen từ đầu theo SRP (mỗi section = 1 component riêng), dùng Material 3 + dark cinema theme hiện có.

---

## 1. Design Read

| Thuộc tính | Giá trị |
|---|---|
| **Loại app** | App phim di động (Netflix-style) |
| **Audience** | Người xem phim Việt Nam |
| **Theme** | Dark Cinema - Background `#0D0C11`, Accent `#E50914` (Crimson Red) |
| **Card style** | Poster dọc compact (kiểu Netflix/TMDB) |
| **Carousel** | Full-width backdrop ~50% màn hình |
| **Data** | Mock data (UI-only, API call sau) |

---

## 2. Cấu trúc trang Home (từ trên xuống dưới)

```
┌─────────────────────────────────────────┐
│          HERO CAROUSEL                  │  ← 50% màn hình
│   Backdrop Image + Gradient Overlay     │
│   Title + Mô tả + [Xem Ngay] [+ DS]    │
│              ● ○ ○ ○ ○                  │  ← dot indicator
├─────────────────────────────────────────┤
│  [Tất cả] [Hành động] [Kinh dị] [...]  │  ← Category Chips
├─────────────────────────────────────────┤
│  Phim Đang Hot                 Tất cả > │
│  ┌──────┐ ┌──────┐ ┌──────┐           │
│  │Poster│ │Poster│ │Poster│  ──→ scroll│
│  │ ★8.6 │ │ ★7.9 │ │ ★9.1 │           │
│  │Title │ │Title │ │Title │           │
│  └──────┘ └──────┘ └──────┘           │
├─────────────────────────────────────────┤
│  Mới Cập Nhật                  Tất cả > │
│  ┌──────┐ ┌──────┐ ┌──────┐           │
│  │Poster│ │Poster│ │Poster│  ──→ scroll│
│  └──────┘ └──────┘ └──────┘           │
├─────────────────────────────────────────┤
│  Top 10 Phim                   Tất cả > │
│  ┌─┬──────┐ ┌─┬──────┐               │
│  │1│Poster│ │2│Poster│   ──→ scroll    │
│  │ │      │ │ │      │               │
│  └─┴──────┘ └─┴──────┘               │
├─────────────────────────────────────────┤
│                                         │
│  ┌─────────────────────────────────┐    │
│  │  🏠    🔍    ❤    👤              │    │  ← Floating Bottom Nav
│  │  Home  Search Fav  Profile      │    │
│  └─────────────────────────────────┘    │
└─────────────────────────────────────────┘
```

---

## 3. Chi tiết từng Section

### 3.1 Hero Carousel (`HeroCarousel`)

| Thuộc tính | Chi tiết |
|---|---|
| **Widget chính** | `PageView.builder` + `Timer.periodic` |
| **Auto-slide** | Mỗi 5 giây chuyển slide |
| **Chiều cao** | `MediaQuery.of(context).size.height * 0.5` |
| **Overlay** | `Stack` → backdrop image → gradient đen fade từ dưới lên → Column(title, description, buttons) |
| **Buttons** | `Xem Ngay` (filled red) + `+ Danh sách` (outlined/ghost) |
| **Indicator** | Row dots bên dưới, dot active = đỏ, còn lại = xám mờ |
| **Data** | Nhận `List<Movie>` (5 phim featured) |

### 3.2 Category Chip Bar (`CategoryChipBar`)

| Thuộc tính | Chi tiết |
|---|---|
| **Widget** | `SingleChildScrollView(horizontal)` + `Row` chứa các `ChoiceChip` |
| **Categories** | Tất cả, Hành động, Kinh dị, Hài hước, Tình cảm, Hoạt hình, Khoa học viễn tưởng |
| **Selected** | Background `AppColors.primary` (đỏ), text trắng |
| **Unselected** | Background `AppColors.surfaceLight`, text `textSecondary`, border mờ |
| **Callback** | `onCategorySelected(int index)` |

### 3.3 Movie Section (`MovieSection`) — **REUSABLE**

| Thuộc tính | Chi tiết |
|---|---|
| **Params** | `title: String`, `movies: List<Movie>`, `onSeeAll: VoidCallback?` |
| **Header** | Row: Text bold bên trái + "Tất cả >" bên phải (InkWell) |
| **Body** | `SizedBox(height: 220)` + `ListView.builder(horizontal)` |
| **Item** | `MovieCard` (xem 3.4) |
| **Spacing** | `separatorBuilder` → `SizedBox(width: 12)` |
| **Padding** | Left/Right 16px |

> **Mở rộng sau này:** Thêm section Anime, Phim Hàn chỉ cần gọi thêm 1 `MovieSection(title: "Phim Anime", movies: animeList)` trong `HomeScreen`.

### 3.4 Movie Card (`MovieCard`) — Poster dọc compact

| Thuộc tính | Chi tiết |
|---|---|
| **Chiều rộng** | `120px` cố định |
| **Poster** | `ClipRRect(borderRadius: 12)` + `Image.network` với `fit: BoxFit.cover` |
| **Rating badge** | Positioned góc trên phải: Container nhỏ background đen mờ, icon sao vàng + số rating |
| **Text** | Bên dưới poster: Tên phim (maxLines 1, ellipsis), Năm + Thể loại (text muted, fontSize 12) |
| **Tap** | `onTap` callback → navigate tới detail (sau này) |

### 3.5 Top 10 Section (`Top10Section`) + Top 10 Card (`Top10Card`)

| Thuộc tính | Chi tiết |
|---|---|
| **Layout** | Tương tự `MovieSection` nhưng dùng `Top10Card` |
| **Số thứ tự** | Text cực lớn (~60px), `fontWeight: w900`, có stroke/outline text |
| **Vị trí số** | Positioned bên trái poster, đè qua cạnh trái |
| **Poster** | Dịch sang phải 1 chút để nhường chỗ cho số |

### 3.6 Floating Bottom Navigation Bar (`MainNavigationBar`)

| Thuộc tính | Chi tiết |
|---|---|
| **Style** | Floating — có `margin` bottom + horizontal để không dính sát cạnh |
| **Shape** | `borderRadius: 24`, background `AppColors.surface`, border `AppColors.border` mờ |
| **Items** | 4 tabs: Home (`Icons.home_rounded`), Search (`Icons.search_rounded`), Favorites (`Icons.favorite_rounded`), Profile (`Icons.person_rounded`) |
| **Active** | Icon đổi màu `AppColors.primary` (đỏ) + dot nhỏ 4px bên dưới |
| **Inactive** | Icon `AppColors.textMuted` |
| **Elevation** | 0 (flat, dùng border thay shadow) |

---

## 4. Cấu trúc thư mục (SRP)

```
lib/
├── main.dart                                         ← Entry point (đã có)
├── core/
│   ├── constants/
│   │   └── app_colors.dart                           ← Đã có
│   └── theme/
│       └── app_theme.dart                            ← Đã có
├── domain/
│   └── entities/
│       └── movie.dart                                ← [NEW] Movie entity
├── data/
│   └── mock/
│       └── mock_movies.dart                          ← [NEW] Mock data
└── presentation/
    ├── screens/
    │   └── home/
    │       └── home_screen.dart                      ← [NEW] Trang Home chính
    └── widgets/
        ├── carousel/
        │   └── hero_carousel.dart                    ← [NEW] Hero carousel
        ├── sections/
        │   ├── movie_section.dart                    ← [NEW] Reusable section
        │   └── top10_section.dart                    ← [NEW] Top 10 section
        ├── cards/
        │   ├── movie_card.dart                       ← [NEW] Poster card compact
        │   └── top10_card.dart                       ← [NEW] Top 10 card
        ├── chips/
        │   └── category_chip_bar.dart                ← [NEW] Category chips
        └── navigation/
            └── main_navigation_bar.dart              ← [NEW] Floating nav bar
```

**Tổng cộng: 10 files mới**

---

## 5. Movie Entity

```dart
class Movie {
  final int id;
  final String title;
  final String posterUrl;
  final String backdropUrl;
  final double rating;
  final int year;
  final String genre;
  final String overview;

  const Movie({
    required this.id,
    required this.title,
    required this.posterUrl,
    required this.backdropUrl,
    required this.rating,
    required this.year,
    required this.genre,
    required this.overview,
  });
}
```

---

## 6. Thứ tự Implementation

| Bước | Task | Files | Phụ thuộc |
|------|------|-------|-----------|
| 1 | Tạo `Movie` entity | `movie.dart` | Không |
| 2 | Tạo mock data | `mock_movies.dart` | Bước 1 |
| 3 | Tạo `MovieCard` | `movie_card.dart` | Bước 1 |
| 4 | Tạo `Top10Card` | `top10_card.dart` | Bước 1 |
| 5 | Tạo `MovieSection` (reusable) | `movie_section.dart` | Bước 3 |
| 6 | Tạo `Top10Section` | `top10_section.dart` | Bước 4 |
| 7 | Tạo `HeroCarousel` | `hero_carousel.dart` | Bước 1 |
| 8 | Tạo `CategoryChipBar` | `category_chip_bar.dart` | Không |
| 9 | Tạo `MainNavigationBar` | `main_navigation_bar.dart` | Không |
| 10 | Assemble `HomeScreen` | `home_screen.dart` | Tất cả bước trên |

---

## 7. Ghi chú quan trọng

- **Không cần Backend/API** — dùng mock data tạm
- **SRP nghiêm ngặt** — mỗi widget 1 file, 1 nhiệm vụ duy nhất
- **MovieSection reusable** — sau này thêm Anime/Phim Hàn/Phim bộ chỉ cần 1 dòng
- **Material 3** — tận dụng `Theme.of(context)` + `AppColors` đã setup
- **Poster dọc compact** — width 120px, không quá to, scroll mượt
- **Image placeholder** — dùng `picsum.photos` hoặc `placehold.co` cho poster tạm

---

## 8. Verification

- [ ] `flutter run -d chrome` chạy không lỗi
- [ ] Carousel auto-slide đúng 5 giây
- [ ] Scroll ngang mượt mà ở tất cả section
- [ ] Card không bị overflow/tràn
- [ ] Bottom nav chuyển tab được
- [ ] Category chips chọn/bỏ chọn được
- [ ] Top 10 hiển thị số thứ tự đúng
