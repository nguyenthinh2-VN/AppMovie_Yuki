# Tài Liệu REST API KKPhim — Tìm Kiếm Phim (Search & Quick Search APIs)

> **Mục đích document**: Tài liệu hướng dẫn sử dụng API Tìm kiếm Phim của KKPhim, bao gồm API Tìm kiếm đầy đủ (Search Page v1) và API Tìm kiếm nhanh (Quick Search cho Auto-complete / Search Bar Popup).

---

## 1. So Sánh 2 Endpoint Tìm Kiếm Phim

KKPhim cung cấp **2 endpoint tìm kiếm** tối ưu cho 2 trường hợp sử dụng khác nhau:

| Endpoint | Đường dẫn URL | Mục đích sử dụng | Đặc điểm chính |
| :--- | :--- | :--- | :--- |
| **1. Tìm Kiếm v1 [Màn Search]** | `GET https://phimapi.com/v1/api/tim-kiem` | Màn hình Kết Quả Tìm Kiếm | **22 fields đầy đủ**, phân trang linh hoạt, hỗ trợ bộ lọc kết hợp |
| **2. Tìm Kiếm Nhanh [Auto-complete]** | `GET https://www.kkphim1.com/tim-kiem-nhanh` | Ô nhập liệu / Search Bar Popup | Siêu nhẹ, phản hồi nhanh, **Poster đã nối sẵn Full URL** |

---

## 2. API Tìm Kiếm Phim Chi Tiết v1 (`GET /v1/api/tim-kiem`)

### 🔹 Request Parameters
- **Query Parameters**:
  - `keyword` (string, bắt buộc): Từ khóa tìm kiếm (ví dụ: `dac+nhiem`, `iron+man`).
  - `page` (int, default `1`): Trang hiện tại.
  - `limit` (int, default `10`, max `64`): Số phim trả về mỗi trang.
  - `category` (string, optional): Lọc bổ sung theo thể loại (ví dụ: `hanh-dong`).
  - `country` (string, optional): Lọc bổ sung theo quốc gia (ví dụ: `au-my`).
  - `year` (int, optional): Lọc bổ sung theo năm phát hành.
  - `sort_field` (string, optional): `modified.time` | `_id` | `year`.
  - `sort_type` (string, optional): `desc` | `asc`.

### 🔹 Response Schema (Rút gọn)
```json
{
  "status": "success",
  "message": "",
  "data": {
    "titlePage": "Tìm kiếm: dac nhiem",
    "breadCrumb": [
      { "name": "Trang chủ", "slug": "/" },
      { "name": "Tìm kiếm", "slug": "" }
    ],
    "items": [
      {
        "_id": "66...89",
        "name": "Đặc Nhiệm Thám Tử Wan! (Phần 2)",
        "slug": "dac-nhiem-tham-tu-wan-phan-2",
        "origin_name": "Bungo Stray Dogs WAN! (Season 2)",
        "alternative_names": [],
        "type": "hoathinh",
        "thumb_url": "upload/vod/20260704-1/6eb74d...jpg",
        "poster_url": "upload/vod/20260704-1/6eb74d...jpg",
        "sub_docquyen": false,
        "chieurap": false,
        "time": "24 phút/tập",
        "episode_current": "Tập 5",
        "quality": "FHD",
        "lang": "Vietsub",
        "year": 2026,
        "category": [
          { "id": "...", "name": "Hoạt Hình", "slug": "hoat-hinh" }
        ],
        "country": [
          { "id": "...", "name": "Nhật Bản", "slug": "nhat-ban" }
        ],
        "tmdb": { "id": "...", "vote_average": 7.1, "vote_count": 15 },
        "imdb": { "id": null, "vote_average": 0, "vote_count": 0 }
      }
    ],
    "params": {
      "keyword": "dac nhiem",
      "pagination": {
        "totalItems": 42,
        "totalItemsPerPage": 10,
        "currentPage": 1,
        "totalPages": 5
      }
    },
    "APP_DOMAIN_CDN_IMAGE": "https://phimimg.com"
  }
}
```

---

## 3. API Tìm Kiếm Nhanh Auto-Complete (`GET /tim-kiem-nhanh`)

Dùng cho tính năng gõ từ khóa tự động hiển thị gợi ý (Debounce Search / Live Search Popup) khi người dùng gõ vào Search Textfield.

### 🔹 Request URL
`GET https://www.kkphim1.com/tim-kiem-nhanh?keyword={keyword}`

### 🔹 Response Schema
```json
{
  "total": 42,
  "current_page": 1,
  "last_page": 2,
  "items": [
    {
      "name": "Đặc Nhiệm Thám Tử Wan! (Phần 2)",
      "origin_name": "Bungo Stray Dogs WAN! (Season 2)",
      "year": 2026,
      "quality": "FHD",
      "episode_current": "Tập 5",
      "vote": 7.1,
      "poster": "https://phimimg.com/upload/vod/20260704-1/6eb74d23a4ec3b98fb035361a4daa840.jpg",
      "url": "https://www.kkphim1.com/phim/dac-nhiem-tham-tu-wan-phan-2"
    }
  ]
}
```

### 💡 Ưu Điểm Của API Tìm Kiếm Nhanh:
1. **Trọng lượng nhẹ**: Chỉ trả về 8 trường dữ liệu thiết yếu cho popup gợi ý.
2. **Poster Full URL**: Trường `poster` đã được ghép sẵn đường dẫn CDN full (`https://phimimg.com/upload/...`), không cần xử lý ghép domain thủ công.
3. **Trích xuất Slug đơn giản**: Lấy slug từ cuối đường dẫn `url` hoặc cắt chuỗi từ `url.split('/phim/').last`.

---

## 4. Hướng Dẫn Tích Hợp Tìm Kiếm Trong App Mobile (Flutter)

1. **Khởi tạo Search Bar với Debounce**:
   - Sử dụng kỹ thuật Debounce 300ms - 500ms khi gõ từ khóa.
   - Khi đang gõ: Gọi `GET https://www.kkphim1.com/tim-kiem-nhanh?keyword={query}` để hiển thị danh sách Popup gợi ý nhanh dưới thanh tìm kiếm.
2. **Khi nhấn Enter / nút Tìm kiếm / Xem tất cả kết quả**:
   - Chuyển sang Màn hình Kết quả Tìm kiếm (Search Results Screen).
   - Gọi API `GET https://phimapi.com/v1/api/tim-kiem?keyword={query}&page=1` để render giao diện grid kết quả tìm kiếm với đầy đủ thẻ thông tin (Chất lượng, Thuyết minh, Tập, Thể loại, Quốc gia, Phân trang).
