# Tài Liệu REST API KKPhim — Thể Loại, Quốc Gia & Năm Phát Hành (Metadata & Filter APIs)

> **Mục đích document**: Tài liệu hướng dẫn khai thác các danh mục Bộ lọc Metadata (Danh sách Thể Loại, Quốc Gia, Năm Phát Hành) và lấy danh sách phim phân loại theo từng Thể Loại, Quốc Gia, Năm Phát Hành trên KKPhim.

---

## 1. Tổng Quan Các Endpoint Metadata

| Loại Metadata | Endpoint Lấy Danh Sách Master | Endpoint Lấy Phim Theo Filter (v1 ⭐) |
| :--- | :--- | :--- |
| **Thể Loại** | `GET https://phimapi.com/the-loai` | `GET https://phimapi.com/v1/api/the-loai/{slug}?page={page}` |
| **Quốc Gia** | `GET https://phimapi.com/quoc-gia` | `GET https://phimapi.com/v1/api/quoc-gia/{slug}?page={page}` |
| **Năm Phát Hành** | `GET https://phimapi.com/nam` | `GET https://phimapi.com/v1/api/nam/{year}?page={page}` |

---

## 2. API Danh Sách Master (Thể Loại / Quốc Gia / Năm)

### 📂 1. Lấy Danh Sách Tất Cả Thể Loại (`GET /the-loai`)
- **URL**: `GET https://phimapi.com/the-loai`
- **Response Format**:
  ```json
  {
    "status": "success",
    "message": "",
    "data": {
      "items": [
        { "_id": "2fb53017b3be83cd754a08adab3e916c", "name": "Bí Ẩn", "slug": "bi-an" },
        { "_id": "...", "name": "Hành Động", "slug": "hanh-dong" },
        { "_id": "...", "name": "Tình Cảm", "slug": "tinh-cam" }
      ]
    }
  }
  ```
- **Danh sách slug thể loại phổ biến**: `hanh-dong`, `co-trang`, `chinh-kich`, `hai-huoc`, `kinh-di`, `tinh-cam`, `vien-tuong`, `vo-thuat`, `tam-ly`, `hoc-duong`, `bi-an`, `hoat-hinh`, `tai-lieu`, `phim-18`.

---

### 🌐 2. Lấy Danh Sách Tất Cả Quốc Gia (`GET /quoc-gia`)
- **URL**: `GET https://phimapi.com/quoc-gia`
- **Response Format**:
  ```json
  {
    "status": "success",
    "message": "",
    "data": {
      "items": [
        { "_id": "932bbaca386ee0436ad0159117eabae4", "name": "Anh", "slug": "anh" },
        { "_id": "...", "name": "Trung Quốc", "slug": "trung-quoc" },
        { "_id": "...", "name": "Hàn Quốc", "slug": "han-quoc" },
        { "_id": "...", "name": "Âu Mỹ", "slug": "au-my" },
        { "_id": "...", "name": "Việt Nam", "slug": "viet-nam" }
      ]
    }
  }
  ```
- **Danh sách slug quốc gia phổ biến**: `trung-quoc`, `han-quoc`, `au-my`, `nhat-ban`, `thai-lan`, `viet-nam`, `hong-kong`, `tai-loan`, `anh`, `phap`, `duc`, `an-do`.

---

### 📅 3. Lấy Danh Sách Năm Phát Hành (`GET /nam`)
- **URL**: `GET https://phimapi.com/nam`
- **Trả về**: Danh sách các năm phát hành từ trước đến nay (ví dụ: `2026`, `2025`, `2024`, `2023`,..., `2010`, `2000`).

---

## 3. API Lấy Phim Theo Thể Loại / Quốc Gia / Năm (v1)

### 🔹 Endpoint Lấy Phim Theo Thể Loại:
`GET https://phimapi.com/v1/api/the-loai/{slug}?page={page}&limit={limit}&sort_field={sort_field}&sort_type={sort_type}`

- **Ví dụ**: `GET https://phimapi.com/v1/api/the-loai/hanh-dong?page=1`
- **Response**: Trả về `data.titlePage` (ví dụ: "Hành Động"), danh sách 22 fields movie items trong `data.items`, và thông tin phân trang `data.params.pagination`.

### 🔹 Endpoint Lấy Phim Theo Quốc Gia:
`GET https://phimapi.com/v1/api/quoc-gia/{slug}?page={page}&limit={limit}`

- **Ví dụ**: `GET https://phimapi.com/v1/api/quoc-gia/han-quoc?page=1`

### 🔹 Endpoint Lấy Phim Theo Năm:
`GET https://phimapi.com/v1/api/nam/{year}?page={page}&limit={limit}`

- **Ví dụ**: `GET https://phimapi.com/v1/api/nam/2024?page=1`
- Có thể truyền dải năm: `GET https://phimapi.com/v1/api/nam/2020,2024?page=1`

---

## 4. Ứng Dụng Trong Xây Dựng UI App

1. **Thanh Filter / Dropdown Lọc Phim**:
   - Gọi `GET /the-loai` và `GET /quoc-gia` ngay khi khởi động App hoặc mở màn hình Tìm kiếm/Bộ lọc để cache lại danh sách Chip / Dropdown thể loại & quốc gia.
2. **Màn Hình Lưới Phim Theo Thể Loại / Quốc Gia**:
   - Khi người dùng click vào thể loại (vd: "Hành Động"), gọi API `GET /v1/api/the-loai/hanh-dong?page=1` để render danh sách phim có đầy đủ thông tin rating TMDB, chất lượng, vietsub/thuyết minh.
