# Tài Liệu REST API KKPhim — Chi Tiết Phim, Diễn Viên, Hình Ảnh & Phát Video (Movie Detail & Sub-Resources API)

> **Mục đích document**: Tài liệu hướng dẫn sử dụng API Lấy thông tin chi tiết phim, danh sách tập phim, link streaming HLS `.m3u8`, link embed iFrame, cũng như các API sub-resource lấy **Hình ảnh HD (TMDB Backdrops/Posters)**, **Diễn viên & Ê-kíp**, và **Từ khóa (Keywords)** của bộ phim.

---

## 1. Các Endpoint Chi Tiết Phim & Sub-Resources

| Loại Endpoint | URL Path | Định dạng Response | Công dụng |
| :--- | :--- | :--- | :--- |
| **Chi tiết Phim (Cũ)** | `GET https://phimapi.com/phim/{slug}` | Root `movie` + Root `episodes` | Lấy chi tiết + tập (Full URL ảnh) |
| **Chi tiết Phim (v1) [NÊN DÙNG ⭐]** | `GET https://phimapi.com/v1/api/phim/{slug}` | Wrapped `data.item` (Gồm cả `episodes`) | **Tốt nhất**, bổ sung Breadcrumb & SEO |
| **Hình Ảnh HD (Images)** | `GET https://phimapi.com/v1/api/phim/{slug}/images` | Wrapped `data.images` | Bộ sưu tập Backdrops & Posters HD từ TMDB |
| **Diễn Viên & Ê-kíp (Peoples)** | `GET https://phimapi.com/v1/api/phim/{slug}/peoples` | Wrapped `data.peoples` | Danh sách Diễn viên, Đạo diễn kèm ảnh chân dung |
| **Từ Khóa Phim (Keywords)** | `GET https://phimapi.com/v1/api/phim/{slug}/keywords` | Wrapped `data.keywords` | Danh sách từ khóa (Keywords/Tags) của phim |

---

## 2. Cấu Trúc Response Chi Tiết Phim v1 (`GET /v1/api/phim/{slug}`)

```json
{
  "status": "success",
  "message": "",
  "data": {
    "seoOnPage": {
      "titleHead": "Cuộc Chiến Sinh Tồn - Rust Creek (2018)",
      "descriptionHead": "Nội dung tóm tắt phim...",
      "og_image": ["https://phimimg.com/upload/..."]
    },
    "breadCrumb": [
      { "name": "Trang chủ", "slug": "/" },
      { "name": "Phim Lẻ", "slug": "danh-sach/phim-le" },
      { "name": "Cuộc Chiến Sinh Tồn", "isCurrent": true }
    ],
    "item": {
      "_id": "65c7...89a",
      "name": "Cuộc Chiến Sinh Tồn",
      "slug": "cuoc-chien-sinh-ton",
      "origin_name": "Rust Creek",
      "alternative_names": ["Rust Creek 2018"],
      "content": "<p>Nội dung chi tiết của bộ phim...</p>",
      "type": "single",
      "status": "completed",
      "thumb_url": "upload/vod/20240210/thumb.jpg",
      "poster_url": "upload/vod/20240210/poster.jpg",
      "is_copyright": false,
      "sub_docquyen": false,
      "chieurap": false,
      "trailer_url": "https://www.youtube.com/watch?v=...",
      "time": "108 phút",
      "episode_current": "Full",
      "episode_total": "1 Tập",
      "quality": "FHD",
      "lang": "Vietsub",
      "lang_key": ["vs"],
      "notify": "",
      "showtimes": "",
      "year": 2018,
      "view": 12500,
      "actor": ["Hermione Corfield", "Jay Paulson", "Sean O'Bryan"],
      "director": ["Jen McGowan"],
      "category": [
        { "id": "6a49...", "name": "Kinh Dị", "slug": "kinh-di" },
        { "id": "6a49...", "name": "Chính Kịch", "slug": "chinh-kich" }
      ],
      "country": [
        { "id": "6a49...", "name": "Âu Mỹ", "slug": "au-my" }
      ],
      "tmdb": { "id": "553830", "type": "movie", "season": null, "vote_average": 6.1, "vote_count": 450 },
      "imdb": { "id": "tt6610158", "vote_average": 5.9, "vote_count": 8900 },
      "episodes": [
        {
          "server_name": "Vietsub",
          "server_data": [
            {
              "name": "Full",
              "slug": "full",
              "filename": "Cuộc Chiến Sinh Tồn - Vietsub - Full",
              "link_embed": "https://player.phimapi.com/player/?url=https://s2.phim1280.tv/20240210/FDu1cOEe/index.m3u8",
              "link_m3u8": "https://s2.phim1280.tv/20240210/FDu1cOEe/index.m3u8"
            }
          ]
        }
      ]
    },
    "APP_DOMAIN_CDN_IMAGE": "https://phimimg.com"
  }
}
```

---

## 3. Cấu Trúc Đối Tượng Tập Phim (`episodes` & Streaming)

Mỗi phim có thể có nhiều server phát (ví dụ: `Vietsub`, `Thuyết Minh`, `Lồng Tiếng`).

### 📌 Cấu trúc mảng `episodes`:
```json
[
  {
    "server_name": "Tên Server (vd: Vietsub / Thuyết Minh)",
    "server_data": [
      {
        "name": "Số tập (vd: Tập 1, Tập 2 hoặc Full)",
        "slug": "Slug tập (vd: tap-1)",
        "filename": "Tên file gốc",
        "link_embed": "Link nhúng iFrame Player (dùng cho WebView)",
        "link_m3u8": "Link Stream HLS trực tiếp (.m3u8 - dùng cho Native Video Player)"
      }
    ]
  }
]
```

### 💡 Hướng Dẫn Tích Hợp Video Player Trong App Flutter:
1. **Dùng Native Player (Khuyên Dùng)**:
   - Thư viện: `video_player`, `chewie` hoặc `media_kit`.
   - Truyền URL HLS trực tiếp từ trường `link_m3u8` (ví dụ: `https://s2.phim1280.tv/.../index.m3u8`).
2. **Dùng WebView Embed**:
   - Thư viện: `flutter_inappwebview` hoặc `webview_flutter`.
   - Truyền URL từ trường `link_embed`.

---

## 4. Chi Tiết Các API Sub-Resources (Hình Ảnh, Diễn Viên, Từ Khóa)

Ngoài thông tin chi tiết phim cơ bản, KKPhim cung cấp 3 API bổ trợ để làm đẹp màn hình Chi Tiết Phim:

### 🖼️ A. API Hình Ảnh HD (`GET /v1/api/phim/{slug}/images`)
- **URL**: `GET https://phimapi.com/v1/api/phim/{slug}/images`
- **Response Format**:
  ```json
  {
    "success": true,
    "message": "success",
    "status_code": 200,
    "data": {
      "tmdb_id": 718789,
      "slug": "lightyear-canh-sat-vu-tru",
      "image_sizes": {
        "backdrop": {
          "original": "https://image.tmdb.org/t/p/original",
          "w1280": "https://image.tmdb.org/t/p/w1280",
          "w780": "https://image.tmdb.org/t/p/w780",
          "w300": "https://image.tmdb.org/t/p/w300"
        },
        "poster": {
          "original": "https://image.tmdb.org/t/p/original",
          "w500": "https://image.tmdb.org/t/p/w500",
          "w342": "https://image.tmdb.org/t/p/w342",
          "w185": "https://image.tmdb.org/t/p/w185"
        }
      },
      "images": [
        {
          "width": 3840,
          "height": 2160,
          "aspect_ratio": 1.778,
          "type": "backdrop",
          "file_path": "/hwUxHPkuUleJeoick4uZsrKDXxF.jpg"
        }
      ]
    }
  }
  ```
- **Cách Nối URL Ảnh**:
  `full_url = data.image_sizes.backdrop.w1280 + item.file_path`
  *(Ví dụ: `https://image.tmdb.org/t/p/w1280/hwUxHPkuUleJeoick4uZsrKDXxF.jpg`)*.

---

### 👤 B. API Diễn Viên & Ê-kíp (`GET /v1/api/phim/{slug}/peoples`)
- **URL**: `GET https://phimapi.com/v1/api/phim/{slug}/peoples`
- **Response Format**:
  ```json
  {
    "success": true,
    "message": "success",
    "status_code": 200,
    "data": {
      "tmdb_id": 718789,
      "slug": "lightyear-canh-sat-vu-tru",
      "profile_sizes": {
        "original": "https://image.tmdb.org/t/p/original",
        "h632": "https://image.tmdb.org/t/p/h632",
        "w185": "https://image.tmdb.org/t/p/w185"
      },
      "peoples": [
        {
          "name": "Chris Evans",
          "character": "Buzz Lightyear (voice)",
          "profile_path": "/3bOGNsHZeG7Bd3wuRjGf8nyYEVu.jpg"
        }
      ]
    }
  }
  ```
- **Cách Nối URL Avatar Diễn Viên**:
  `avatar_url = data.profile_sizes.w185 + item.profile_path`
  *(Ví dụ: `https://image.tmdb.org/t/p/w185/3bOGNsHZeG7Bd3wuRjGf8nyYEVu.jpg`)*.

---

### 🏷️ C. API Từ Khóa Phim (`GET /v1/api/phim/{slug}/keywords`)
- **URL**: `GET https://phimapi.com/v1/api/phim/{slug}/keywords`
- **Response Format**:
  ```json
  {
    "success": true,
    "message": "success",
    "status_code": 200,
    "data": {
      "slug": "lightyear-canh-sat-vu-tru",
      "keywords": [
        { "name": "space travel", "name_vn": "space travel" },
        { "name": "time travel", "name_vn": "time travel" },
        { "name": "alien planet", "name_vn": "alien planet" }
      ]
    }
  }
  ```
- **Ứng dụng**: Hiển thị các Chip Tags chủ đề dưới phần mô tả phim để người dùng bấm tìm kiếm các phim có cùng từ khóa.
