# Tài Liệu REST API KKPhim — Phim Mới & Trang Chủ (Home Screen)

> **Mục đích document**: Tài liệu dành cho các Lập trình viên & AI Assistant để hiểu rõ cấu trúc, so sánh các phiên bản API Trang Chủ/Phim Mới của dịch vụ KKPhim (`https://www.kkphim1.com/api-document`), từ đó tích hợp chính xác vào ứng dụng (Flutter/React Native/Web).

---

## 1. Tổng Quan Về Các Endpoint Trang Chủ (Phim Mới)

Trang tài liệu KKPhim cung cấp **3 mục chính** để lấy dữ liệu Phim Mới / Trang Chủ:

| Endpoint | Đường dẫn (Path) | Định dạng Response | Mục đích sử dụng |
| :--- | :--- | :--- | :--- |
| **1. Phim mới cập nhật (Cũ)** | `GET /danh-sach/phim-moi-cap-nhat` | Direct Array & Root Pagination | Tương thích ngược (Cung cấp v1, v2, v3) |
| **2. Phim mới cập nhật (Mới)** | `GET /v1/api/home` | Object Wrapper `data` | Dữ liệu giao diện Trang chủ Web KKPhim |
| **3. Phim mới (v1)** | `GET /v1/api/danh-sach` | Object Wrapper `data` + Params/Filters | **[KHUYÊN DÙNG ⭐]** Đầy đủ thông tin nhất & hỗ trợ phân trang/bộ lọc |

---

## 2. Chi Tiết Các Endpoint & So Sánh Các Phiên Bản (v1, v2, v3)

### 🔴 Endpoint 1: Phim mới cập nhật (Cũ) (`/danh-sach/phim-moi-cap-nhat`)
Chủ web duy trì **3 biến thể (sub-versions)** cho endpoint này:

#### 🔹 Sub-version 1 (v1 Base)
- **URL**: `GET https://phimapi.com/danh-sach/phim-moi-cap-nhat?page={page}`
- **Số trường dữ liệu của mỗi Movie**: **10 fields** (`tmdb`, `imdb`, `modified`, `_id`, `name`, `slug`, `origin_name`, `poster_url`, `thumb_url`, `year`).
- **Ưu điểm**: Ảnh `poster_url` và `thumb_url` đã được nối sẵn Full Domain (`https://phimimg.com/...`).
- **Nhược điểm**: Thất thoát nhiều thông tin (Không có `category`, `country`, `quality`, `lang`, `episode_current`, `time`, `sub_docquyen`, `chieurap`).

#### 🔹 Sub-version 2 (v2)
- **URL**: `GET https://phimapi.com/danh-sach/phim-moi-cap-nhat-v2?page={page}`
- **Số trường dữ liệu của mỗi Movie**: **12 fields** (Bổ sung `status` và `episode_current`).
- **Nhược điểm**: Vẫn thiếu `category`, `country`, `quality`, `lang`, `time`. Mặc định chỉ trả về 10 phim/trang.

#### 🔹 Sub-version 3 (v3)
- **URL**: `GET https://phimapi.com/danh-sach/phim-moi-cap-nhat-v3?page={page}`
- **Số trường dữ liệu của mỗi Movie**: **18 fields** (`tmdb`, `imdb`, `modified`, `_id`, `name`, `slug`, `origin_name`, `type`, `poster_url`, `thumb_url`, `sub_docquyen`, `time`, `episode_current`, `quality`, `lang`, `year`, `category`, `country`).
- **Ưu điểm**: Đã bổ sung mảng `category`, `country`, thông tin `quality`, `lang`, `time` và ảnh đã nối sẵn URL CDN.

---

### 🟡 Endpoint 2: Phim mới cập nhật (Mới) / Trang chủ (`/v1/api/home`)
- **URL**: `GET https://phimapi.com/v1/api/home`
- **Cấu trúc Response**:
  ```json
  {
    "status": true,
    "message": "",
    "data": {
      "seoOnPage": { ... },
      "items": [ ... ],
      "itemsSportsVideos": [ ... ],
      "params": { ... },
      "APP_DOMAIN_CDN_IMAGE": "https://phimimg.com"
    }
  }
  ```
- **Số trường dữ liệu của mỗi Movie**: **18 fields**.
- **Lưu ý đặc biệt về Ảnh**: `poster_url` là đường dẫn tương đối (vd: `uploads/movies/20260803/abc.webp`). `thumb_url` có thể bị `null`. Bắt buộc client phải tự ghép với `APP_DOMAIN_CDN_IMAGE`.

---

### 🟢 Endpoint 3: Phim mới (v1) / Danh sách lọc (`/v1/api/danh-sach`) — **[RECOMMENDED]**
- **URL**: `GET https://phimapi.com/v1/api/danh-sach?page={page}`
- **Query Parameters Hỗ Trợ**:
  - `page` (int): Trang hiện tại (Mặc định `1`).
  - `limit` (int): Số lượng item/trang (Mặc định `24`, tối đa `64`).
  - `category` (string): Slug thể loại (ví dụ: `hanh-dong`, `tinh-cam`).
  - `country` (string): Slug quốc gia (ví dụ: `han-quoc`, `au-my`).
  - `year` (int|string): Năm phát hành (ví dụ: `2024` hoặc `2020,2024`).
  - `sort_field` (string): Trường sắp xếp (`modified.time` | `_id` | `year`).
  - `sort_type` (string): Thứ tự (`desc` | `asc`).
  - `sort_lang` (string): Lọc bản dịch (`vietsub` | `thuyet-minh` | `long-tieng`).

- **Số trường dữ liệu của mỗi Movie**: **22 fields (ĐẦY ĐỦ VÀ PHONG PHÚ NHẤT)**:
  1. `_id`: ID phim (String Mongo ObjectID).
  2. `name`: Tên phim tiếng Việt (String).
  3. `slug`: Slug duy nhất dùng để query thông tin chi tiết phim (String).
  4. `origin_name`: Tên gốc / tên tiếng Anh (String).
  5. `alternative_names`: Các tên gọi khác (Array of String).
  6. `type`: Loại phim (`series` | `single` | `hoathinh` | `tvshows`).
  7. `thumb_url`: Đường dẫn tương đối của ảnh Thumb (String).
  8. `poster_url`: Đường dẫn tương đối của ảnh Poster (String).
  9. `sub_docquyen`: Cờ Sub độc quyền (Boolean).
  10. `chieurap`: Cờ Phim chiếu rạp (Boolean).
  11. `time`: Thời lượng phim, ví dụ: `"45 phút/tập"` hoặc `"120 phút"` (String).
  12. `episode_current`: Trạng thái tập, ví dụ: `"Hoàn Tất (50/50)"`, `"Tập 12 Vietsub"` (String).
  13. `quality`: Chất lượng video, ví dụ: `"FHD"`, `"HD"`, `"CAM"` (String).
  14. `lang`: Ngôn ngữ / Bản dịch, ví dụ: `"Vietsub"`, `"Lồng Tiếng"` (String).
  15. `lang_key`: Mã ngôn ngữ rút gọn, ví dụ: `["vs"]`, `["lt"]` (Array of String).
  16. `year`: Năm phát hành (Int).
  17. `category`: Danh sách thể loại `[{"id": "...", "name": "...", "slug": "..."}]` (Array of Object).
  18. `country`: Danh sách quốc gia `[{"id": "...", "name": "...", "slug": "..."}]` (Array of Object).
  19. `tmdb`: Thông tin TMDB `{"id": "...", "type": "...", "vote_average": 6.8, "vote_count": 3700}` (Object).
  20. `imdb`: Thông tin IMDB `{"id": "...", "vote_average": 0, "vote_count": 0}` (Object).
  21. `modified`: Thời gian cập nhật `{"time": "2026-08-03T09:07:25.000Z"}` (Object).
  22. `last_episodes`: Danh sách các bản tập mới cập nhật `[{"server_name": "Lồng Tiếng", "name": "Full", "is_ai": false}]` (Array of Object).

---

## 3. Bảng So Sánh Tổng Hợp Các Phiên Bản API Trang Chủ

| Tiêu Chí | `phim-moi-cap-nhat` (v1/v2) | `phim-moi-cap-nhat-v3` | `/v1/api/home` | `/v1/api/danh-sach` ⭐ |
| :--- | :---: | :---: | :---: | :---: |
| **Số lượng Field dữ liệu Movie** | 10 (v1) / 12 (v2) | 18 | 18 | **22 (Đầy đủ nhất)** |
| **Thể loại & Quốc gia (`category`, `country`)** | ❌ Không có | ✅ Có | ✅ Có | ✅ **Có (`id`, `name`, `slug`)** |
| **Cờ Chiếu rạp (`chieurap`) & Sub độc quyền (`sub_docquyen`)** | ❌ Không có | ⚠️ Chỉ `sub_docquyen` | ⚠️ Chỉ `sub_docquyen` | ✅ **Đầy đủ cả 2 cờ** |
| **Tập mới nhất (`last_episodes`) & Lang Key (`lang_key`)** | ❌ Không có | ❌ Không có | ❌ Không có | ✅ **Có chi tiết server & tập** |
| **Điểm Rating TMDB (`vote_average`, `vote_count`)** | ⚠️ Chỉ ID | ⚠️ Chỉ ID | ⚠️ Chỉ ID | ✅ **Có vote_average & vote_count** |
| **Định dạng URL Ảnh** | Full URL CDN | Full URL CDN | Path tương đối (Thumb có thể Null) | **Path tương đối (Có đủ Thumb & Poster)** |
| **Hỗ trợ Bộ Lọc (Filter & Sorting)** | ❌ Không | ❌ Không | ❌ Không | ✅ **Hỗ trợ Filter đa dạng & Sort** |
| **Lựa chọn Đánh giá** | Lỗi thời | Trung bình | Không tối ưu cho App | **HOÀN HẢO CHO APP MOBILE/WEB** |

---

## 4. Hướng Dẫn Xử Lý Ảnh (Image URL Resolution)

Đối với API `/v1/api/danh-sach`, cả `poster_url` và `thumb_url` đều trả về đường dẫn tương đối.
Domain CDN cố định là: **`https://phimimg.com`** (hoặc lấy từ `data.APP_DOMAIN_CDN_IMAGE`).

### 💡 Thuật toán ghép URL Ảnh chuẩn:
```dart
String buildImageUrl(String? path, String cdnDomain) {
  if (path == null || path.isEmpty) return '';
  if (path.startsWith('http://') || path.startsWith('https://')) {
    return path;
  }
  final cleanPath = path.startsWith('/') ? path.substring(1) : path;
  final cleanCdn = cdnDomain.endsWith('/') ? cdnDomain.substring(0, cdnDomain.length - 1) : cdnDomain;
  return '$cleanCdn/$cleanPath';
}
```

---

## 5. Cấu Trúc JSON Model Chuẩn (Dart / Flutter Reference)

Dưới đây là Data Model gợi ý để bất kỳ AI hoặc Lập trình viên nào cũng có thể copy và tạo DTO/Model trong dự án:

```dart
class MovieItemModel {
  final String id;
  final String name;
  final String slug;
  final String originName;
  final List<String> alternativeNames;
  final String type;
  final String thumbUrl;
  final String posterUrl;
  final bool subDocquyen;
  final bool chieurap;
  final String time;
  final String episodeCurrent;
  final String quality;
  final String lang;
  final List<String> langKey;
  final int year;
  final List<CategoryModel> category;
  final List<CountryModel> country;
  final TmdbModel? tmdb;
  final ImdbModel? imdb;
  final String modifiedTime;

  MovieItemModel({
    required this.id,
    required this.name,
    required this.slug,
    required this.originName,
    required this.alternativeNames,
    required this.type,
    required this.thumbUrl,
    required this.posterUrl,
    required this.subDocquyen,
    required this.chieurap,
    required this.time,
    required this.episodeCurrent,
    required this.quality,
    required this.lang,
    required this.langKey,
    required this.year,
    required this.category,
    required this.country,
    this.tmdb,
    this.imdb,
    required this.modifiedTime,
  });

  factory MovieItemModel.fromJson(Map<String, dynamic> json, String cdnDomain) {
    String formatImg(String? path) {
      if (path == null || path.isEmpty) return '';
      if (path.startsWith('http://') || path.startsWith('https://')) return path;
      return '$cdnDomain/${path.startsWith('/') ? path.substring(1) : path}';
    }

    return MovieItemModel(
      id: json['_id'] ?? '',
      name: json['name'] ?? '',
      slug: json['slug'] ?? '',
      originName: json['origin_name'] ?? '',
      alternativeNames: List<String>.from(json['alternative_names'] ?? []),
      type: json['type'] ?? '',
      thumbUrl: formatImg(json['thumb_url']),
      posterUrl: formatImg(json['poster_url']),
      subDocquyen: json['sub_docquyen'] ?? false,
      chieurap: json['chieurap'] ?? false,
      time: json['time'] ?? '',
      episodeCurrent: json['episode_current'] ?? '',
      quality: json['quality'] ?? '',
      lang: json['lang'] ?? '',
      langKey: List<String>.from(json['lang_key'] ?? []),
      year: json['year'] ?? 0,
      category: (json['category'] as List? ?? [])
          .map((e) => CategoryModel.fromJson(e))
          .toList(),
      country: (json['country'] as List? ?? [])
          .map((e) => CountryModel.fromJson(e))
          .toList(),
      tmdb: json['tmdb'] != null ? TmdbModel.fromJson(json['tmdb']) : null,
      imdb: json['imdb'] != null ? ImdbModel.fromJson(json['imdb']) : null,
      modifiedTime: json['modified']?['time'] ?? '',
    );
  }
}

class CategoryModel {
  final String id;
  final String name;
  final String slug;

  CategoryModel({required this.id, required this.name, required this.slug});

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      slug: json['slug'] ?? '',
    );
  }
}

class CountryModel {
  final String id;
  final String name;
  final String slug;

  CountryModel({required this.id, required this.name, required this.slug});

  factory CountryModel.fromJson(Map<String, dynamic> json) {
    return CountryModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      slug: json['slug'] ?? '',
    );
  }
}

class TmdbModel {
  final String? id;
  final String? type;
  final int? season;
  final double voteAverage;
  final int voteCount;

  TmdbModel({
    this.id,
    this.type,
    this.season,
    required this.voteAverage,
    required this.voteCount,
  });

  factory TmdbModel.fromJson(Map<String, dynamic> json) {
    return TmdbModel(
      id: json['id']?.toString(),
      type: json['type'],
      season: json['season'],
      voteAverage: (json['vote_average'] as num?)?.toDouble() ?? 0.0,
      voteCount: json['vote_count'] ?? 0,
    );
  }
}

class ImdbModel {
  final String? id;
  final double voteAverage;
  final int voteCount;

  ImdbModel({this.id, required this.voteAverage, required this.voteCount});

  factory ImdbModel.fromJson(Map<String, dynamic> json) {
    return ImdbModel(
      id: json['id']?.toString(),
      voteAverage: (json['vote_average'] as num?)?.toDouble() ?? 0.0,
      voteCount: json['vote_count'] ?? 0,
    );
  }
}
```

---

## 6. Kết Luận & Khuyên Dùng Lập Trình

- **Khuyên dùng API nào cho Trang Home?**
  - **Sử dụng API `GET https://phimapi.com/v1/api/danh-sach?page=1`**.
  - Đây là API mới nhất, tối ưu nhất, trả đầy đủ 22 trường dữ liệu cho mỗi phim (chất lượng, ngôn ngữ, tập phim, thẻ chiếu rạp, rating TMDB/IMDB, thể loại, quốc gia).
- **Phân trang**:
  - Lấy thông tin tổng trang từ `data.params.pagination.totalPages` và `currentPage`.
  - Gọi tiếp các trang tiếp theo bằng query `?page=2`, `?page=3`,...
