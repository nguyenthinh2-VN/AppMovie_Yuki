# Tài Liệu REST API KKPhim — Danh Sách Phim Theo Loại (Danh Sách API)

> **Mục đích document**: Tài liệu hướng dẫn sử dụng API Lấy danh sách phim theo loại (`phim-le`, `phim-bo`, `hoat-hinh`, `tv-shows`, `phim-chieu-rap`, `phim-vietsub`, `phim-thuyet-minh`,...) của hệ thống KKPhim dành cho Dev & AI Assistant.

---

## 1. Các Endpoint Danh Sách Phim

KKPhim cung cấp 2 dạng endpoint chính để lấy danh sách phim theo phân loại:

| Loại API | Endpoint | Định dạng Response | Đặc điểm chính |
| :--- | :--- | :--- | :--- |
| **API Cũ** | `GET https://phimapi.com/danh-sach/{type}` | Root `items` + Root `pagination` | Đã ghép sẵn Full URL ảnh, nhưng ít field thông tin. |
| **API v1 [NÊN DÙNG ⭐]** | `GET https://phimapi.com/v1/api/danh-sach/{type}` | Wrapped trong `data` + `params.pagination` | **22 fields đầy đủ nhất**, hỗ trợ query bộ lọc & sort. |

---

## 2. Các Giá Trị `type` Phổ Biến

Tham số `{type}` trên URL có thể nhận các slug phân loại sau:
- `phim-bo`: Phim Bộ / TV Series
- `phim-le`: Phim Lẻ / Phim Điện Ảnh
- `hoat-hinh`: Phim Hoạt Hình / Anime
- `tv-shows`: TV Shows / Chương trình truyền hình
- `phim-chieu-rap`: Phim Chiếu Rạp
- `phim-vietsub`: Phim Phụ Đề
- `phim-thuyet-minh`: Phim Thuyết Minh
- `phim-long-tieng`: Phim Lồng Tiếng
- `phim-bo-dang-chieu`: Phim Bộ Đang Chiếu
- `phim-bo-hoan-thanh`: Phim Bộ Đã Hoàn Thành

---

## 3. Chi Tiết Endpoint API v1 (`GET /v1/api/danh-sach/{type}`)

### 🔹 Request Parameters
- **Path Parameter**: `{type}` (bắt buộc) - Ví dụ: `phim-bo`, `phim-le`.
- **Query Parameters**:
  - `page` (int, default `1`): Trang hiện tại.
  - `limit` (int, default `24`, max `64`): Số phim mỗi trang.
  - `sort_field` (string): `modified.time` | `_id` | `year` (Mặc định: `modified.time`).
  - `sort_type` (string): `desc` | `asc` (Mặc định: `desc`).
  - `sort_lang` (string): `vietsub` | `thuyet-minh` | `long-tieng`.
  - `category` (string): Slug thể loại (ví dụ: `hanh-dong`).
  - `country` (string): Slug quốc gia (ví dụ: `han-quoc`).
  - `year` (int/string): Năm phát hành (ví dụ: `2024`).

### 🔹 Response Schema (Rút gọn)
```json
{
  "status": "success",
  "message": "",
  "data": {
    "titlePage": "Phim Bộ",
    "breadCrumb": [
      { "name": "Trang chủ", "slug": "/" },
      { "name": "Phim Bộ", "slug": "danh-sach/phim-bo" }
    ],
    "items": [
      {
        "_id": "5694b3b8e68d534f207261f9217afb73",
        "name": "A Mạch Tòng Quân",
        "slug": "a-mach-tong-quan",
        "origin_name": "Fighting For Love",
        "alternative_names": ["A Mach Tong Quan"],
        "type": "series",
        "thumb_url": "upload/vod/20250626-1/e1e5b9...jpg",
        "poster_url": "upload/vod/20250626-1/e1e5b9...jpg",
        "sub_docquyen": false,
        "chieurap": false,
        "time": "45 phút/tập",
        "episode_current": "Hoàn Tất (36/36)",
        "quality": "FHD",
        "lang": "Vietsub",
        "lang_key": ["vs"],
        "year": 2024,
        "category": [
          { "id": "6a49273...", "name": "Cổ Trang", "slug": "co-trang" }
        ],
        "country": [
          { "id": "6a49273...", "name": "Trung Quốc", "slug": "trung-quoc" }
        ],
        "tmdb": { "id": "233968", "type": "tv", "season": 1, "vote_average": 9.0, "vote_count": 2 },
        "imdb": { "id": null, "vote_average": 0, "vote_count": 0 },
        "last_episodes": [
          { "server_name": "Vietsub", "name": "Tập 36", "is_ai": false }
        ]
      }
    ],
    "params": {
      "type_slug": "phim-bo",
      "pagination": {
        "totalItems": 15400,
        "totalItemsPerPage": 24,
        "currentPage": 1,
        "totalPages": 642
      }
    },
    "APP_DOMAIN_CDN_IMAGE": "https://phimimg.com"
  }
}
```

---

## 4. Xử Lý Ghép Ảnh CDN (`APP_DOMAIN_CDN_IMAGE`)

Đối với API v1 (`/v1/api/danh-sach/{type}`):
- `thumb_url` và `poster_url` là **đường dẫn tương đối**.
- Domain CDN được cung cấp trong `data.APP_DOMAIN_CDN_IMAGE` (`https://phimimg.com`).

**Công thức ghép URL trong Flutter/Dart**:
```dart
String getFullImageUrl(String? relativePath, String cdnDomain) {
  if (relativePath == null || relativePath.isEmpty) return '';
  if (relativePath.startsWith('http://') || relativePath.startsWith('https://')) {
    return relativePath;
  }
  final path = relativePath.startsWith('/') ? relativePath.substring(1) : relativePath;
  return '$cdnDomain/$path';
}
```

---

## 5. Bảng So Sánh API Cũ vs API v1

| Tiêu chí | API Cũ (`/danh-sach/{type}`) | API v1 (`/v1/api/danh-sach/{type}`) ⭐ |
| :--- | :---: | :---: |
| **Response Root** | Root `items` | Wrap trong `data` |
| **Độ đầy đủ dữ liệu** | 10 - 12 fields cơ bản | **22 fields đầy đủ (cả Rating, Quality, Sub, Chiếu rạp)** |
| **URL Ảnh** | Nối sẵn Full URL | Đưa về Path tương đối + CDN Domain |
| **Bộ lọc & Sắp xếp** | Không | Hỗ trợ `category`, `country`, `year`, `sort_field`, `sort_type` |
| **Phân trang** | `pagination.totalPages` | `data.params.pagination.totalPages` |
