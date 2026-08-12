# Hướng Dẫn Thu Thập & Tạo Dữ Liệu Phim JSON (CineTicket App)

Tài liệu này cung cấp **Quy chuẩn Schema JSON** và **System Prompt cho AI/Crawler Bot** để tự động trích xuất thông tin phim từ các trang web (CGV, Lotte Cinema, Galaxy Cinema, IMDb, TMDB...) và chuyển đổi thành định dạng JSON chuẩn dùng cho ứng dụng CineTicket (SQLite Database).

---

## 1. Cấu Trúc JSON Schema (JSON Specification)

Dữ liệu đầu ra **BẮT BUỘC** phải là một **mảng JSON (`Array of Objects`)**. Mỗi phần tử mô tả thông tin chi tiết của 1 bộ phim theo chuẩn sau:

```json
[
  {
    "id": 1,
    "title": "Tên Phim (Tiếng Việt hoặc Gốc)",
    "genre": "Thể Loại Chính",
    "durationMinutes": 120,
    "rating": 8.5,
    "posterUrl": "https://domain.com/path/to/poster.jpg",
    "bannerUrl": "https://domain.com/path/to/banner.jpg",
    "synopsis": "Nội dung tóm tắt chi tiết bộ phim...",
    "releaseDate": "01/03/2026",
    "isNowShowing": true,
    "isTopFeatured": true,
    "topRank": 1,
    "ageRating": "C16",
    "director": "Tên Đạo Diễn",
    "trailerUrl": "https://www.youtube.com/watch?v=xxx",
    "cast": [
      {
        "name": "Tên Diễn Viên 1",
        "role": "Tên Nhân Vật 1",
        "avatarUrl": "https://domain.com/path/to/actor1.jpg"
      },
      {
        "name": "Tên Diễn Viên 2",
        "role": "Tên Nhân Vật 2",
        "avatarUrl": "https://domain.com/path/to/actor2.jpg"
      }
    ]
  }
]
```

---

## 2. Chi Tiết Kiểu Dữ Liệu & Quy Định Ràng Buộc

| Tên Trường (`Key`) | Kiểu Dữ Liệu (`Type`) | Bắt Buộc | Mô Tả & Quy Định Giá Trị |
| :--- | :--- | :--- | :--- |
| `id` | `Integer` | **Có** | ID duy nhất dạng số (1, 2, 3...). |
| `title` | `String` | **Có** | Tên đầy đủ của bộ phim (Ví dụ: `"Dune: Hành Tinh Cát 2"`). |
| `genre` | `String` | **Có** | Chọn 1 thể loại chuẩn: `"Hành Động"`, `"Viễn Tưởng"`, `"Hoạt Hình"`, `"Kinh Dị"`, `"Tình Cảm"`, `"Hài Hước"`, `"Tâm Lý"`, `"Gia Đình"`, `"Phiêu Lưu"`. |
| `durationMinutes` | `Integer` | **Có** | Thời lượng tính theo phút (số nguyên, ví dụ: `127`). |
| `rating` | `Float/Double` | **Có** | Đánh giá sao từ `0.0` đến `10.0` (ví dụ: `8.9`). |
| `posterUrl` | `String (URL)` | **Có** | URL ảnh poster đứng (Tỷ lệ 2:3, ảnh rõ nét). |
| `bannerUrl` | `String (URL)` | **Có** | URL ảnh banner ngang (Tỷ lệ 16:9, ảnh đẹp tràn viền). |
| `synopsis` | `String` | **Có** | Đoạn văn tóm tắt nội dung phim (từ 50 - 200 từ). |
| `releaseDate` | `String` | **Có** | Ngày khởi chiếu dạng `DD/MM/YYYY` (ví dụ: `"15/08/2026"`). |
| `isNowShowing` | `Boolean` | **Có** | `true` nếu phim đang chiếu tại rạp, `false` nếu sắp chiếu. |
| `isTopFeatured` | `Boolean` | **Có** | `true` để đưa lên Carousel Phim Nổi Bật ở trang chủ. |
| `topRank` | `Integer` / `null` | Không | Thứ hạng nổi bật (`1`, `2`, `3`...) hoặc `null` nếu không nằm trong Top. |
| `ageRating` | `String` | **Có** | Độ tuổi cho phép: `"P"` (Mọi lứa tuổi), `"C13"` (13+), `"C16"` (16+), `"C18"` (18+). |
| `director` | `String` | **Có** | Tên đạo diễn bộ phim. |
| `trailerUrl` | `String (URL)` | Không | Link YouTube Trailer phim (có thể để `null`). |
| `cast` | `Array of Objects` | **Có** | Danh sách diễn viên (tối thiểu 2 - 5 diễn viên). |
| `cast[].name` | `String` | **Có** | Tên thật của diễn viên. |
| `cast[].role` | `String` | **Có** | Tên vai diễn trong phim. |
| `cast[].avatarUrl` | `String (URL)` | **Có** | URL ảnh chân dung diễn viên. |

---

## 3. Prompt Mẫu Cho AI (Dùng Cho ChatGPT / Claude / Gemini Crawl Data)

Nếu bạn crawl dữ liệu thô từ trang web rạp chiếu hoặc Wikipedia / IMDb, hãy **copy toàn bộ prompt dưới đây** và gửi kèm dữ liệu thô cho AI:

```text
Bạn là một trợ lý chuyển đổi dữ liệu phim chuyên nghiệp.
Hãy chuyển đổi dữ liệu thô về phim dưới đây thành danh sách mảng JSON hợp lệ theo đúng JSON Schema sau:

Dữ liệu cần trả về duy nhất là mảng JSON [ ... ] không chứa thêm văn bản giải thích.

Quy định dữ liệu:
- "genre" phải thuộc một trong các giá trị: ["Hành Động", "Viễn Tưởng", "Hoạt Hình", "Kinh Dị", "Tình Cảm", "Hài Hước", "Tâm Lý", "Gia Đình", "Phiêu Lưu"].
- "ageRating" thuộc một trong các giá trị: ["P", "C13", "C16", "C18"].
- "durationMinutes" là số phút (nguyên).
- "rating" là số thực từ 0.0 đến 10.0.
- "isNowShowing" là true (nếu đang chiếu) hoặc false (nếu sắp chiếu).
- Ảnh posterUrl và bannerUrl nếu dữ liệu thô không có thì tự động dùng ảnh chất lượng cao từ Unsplash thích hợp với thể loại phim.

Dữ liệu thô:
---
[DÁN DỮ LIỆU CRAWL HOẶC DANH SÁCH TÊN PHIM VÀO ĐÂY]
---
```

---

## 4. Ví Dụ Output Mẫu Chuẩn 100%

```json
[
  {
    "id": 1,
    "title": "Dune: Hành Tinh Cát 2",
    "genre": "Viễn Tưởng",
    "durationMinutes": 166,
    "rating": 8.9,
    "posterUrl": "https://images.unsplash.com/photo-1534447677768-be436bb09401?q=80&w=800&auto=format&fit=crop",
    "bannerUrl": "https://images.unsplash.com/photo-1518709268805-4e9042af9f23?q=80&w=1200&auto=format&fit=crop",
    "synopsis": "Paul Atreides tái hợp cùng Chani và người Fremen để thực hiện cuộc trả thù kẻ đã hủy hoại gia đình mình.",
    "releaseDate": "01/03/2026",
    "isNowShowing": true,
    "isTopFeatured": true,
    "topRank": 1,
    "ageRating": "C16",
    "director": "Denis Villeneuve",
    "trailerUrl": "https://www.youtube.com/watch?v=Way9Dexny3w",
    "cast": [
      {
        "name": "Timothée Chalamet",
        "role": "Paul Atreides",
        "avatarUrl": "https://images.unsplash.com/photo-1500648767791-00dcc994a43e?q=80&w=300&auto=format&fit=crop"
      },
      {
        "name": "Zendaya",
        "role": "Chani",
        "avatarUrl": "https://images.unsplash.com/photo-1494790108377-be9c29b29330?q=80&w=300&auto=format&fit=crop"
      }
    ]
  }
]
```
