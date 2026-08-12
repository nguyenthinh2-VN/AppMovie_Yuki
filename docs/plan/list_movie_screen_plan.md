# 🎬 Plan Phase 2 - Màn Hình Danh Sách Phim (List Movie Screen)

> **Mục tiêu:** Xây dựng màn hình hiển thị danh sách phim dạng Lưới (Grid) khi người dùng click vào nút **"Xem thêm"** / **"Tất cả >"** ở bất kỳ section nào (Phim Bộ, Phim Mới, Top 10, Anime, Phim Hàn...) hoặc khi chọn một Thể loại / Quốc gia.

---

## 1. Thiết Kế Màn Hình `MovieListScreen`

### 📐 Giao Diện & Tính Năng
* **AppBar**:
  * Nút Quay lại (`BackIconButton`).
  * Tiêu đề danh mục (ví dụ: *"Phim Bộ"*, *"Phim Hàn Quốc"*, *"Thể loại Hành Động"*).
  * Nút Tìm kiếm / Bộ lọc nhanh (`FilterIconButton`).
* **Lưới Phim (Movie Grid)**:
  * Hiển thị dạng Grid `2 cột` (trên điện thoại) hoặc `3-4 cột` (trên máy tính/màn hình rộng).
  * Mỗi item sử dụng card `MovieCard` đã tối ưu ảnh CDN và nhãn chất lượng / số tập.
* **Tải Trang Cuộn Vô Tận (Infinite Scroll / Pagination)**:
  * Tự động gọi API trang tiếp theo (`page=2`, `page=3`...) khi người dùng cuộn đến 80% chiều dài danh sách.
  * Hiển thị spinner loading nhỏ ở chân trang khi đang nạp trang mới.
* **Bộ Lọc (Filter Sheet - Modal Bottom Sheet)**:
  * Cho phép lọc kết hợp: Sắp xếp (`modified.time`, `year`, `_id`), Định dạng bản dịch (`vietsub`, `thuyet-minh`, `long-tieng`), Năm phát hành.

---

## 2. API Endpoints Tương Ứng

| Loại Danh Sách | Endpoint KKPhim | Tham Số Query |
| :--- | :--- | :--- |
| **Phim Bộ** | `GET /v1/api/danh-sach/phim-bo` | `?page={page}&limit=24&sort_field=modified.time` |
| **Phim Lẻ / Chiếu Rạp** | `GET /v1/api/danh-sach/phim-le` hoặc `phim-chieu-rap` | `?page={page}&limit=24` |
| **Phim Hoạt Hình / Anime** | `GET /v1/api/danh-sach/hoat-hinh` | `?page={page}&limit=24` |
| **Phim Theo Quốc Gia** | `GET /v1/api/quoc-gia/{countrySlug}` | `?page={page}&limit=24` |
| **Phim Theo Thể Loại** | `GET /v1/api/the-loai/{categorySlug}` | `?page={page}&limit=24` |

---

## 3. Cấu Trúc File Kiến Trúc Mới

```text
lib/
├── presentation/
│   ├── screens/
│   │   └── list/
│   │       └── movie_list_screen.dart       # Màn hình danh sách phim Grid
│   └── providers/
│       └── movie_list_provider.dart         # Provider quản lý phân trang, lọc & fetch dữ liệu
```

---

## 4. Các Bước Triển Khai Thực Hiện

1. **Tạo `MovieListProvider`**:
   * Chịu trách nhiệm nạp dữ liệu phân trang (`currentPage`, `totalPages`, `hasMore`).
   * Xử lý nạp trang 1 và nạp nối tiếp (append) danh sách phim khi cuộn.
2. **Xây dựng `MovieListScreen`**:
   * Sử dụng `ScrollController` bắt sự kiện cuộn tới chân trang.
   * Render `GridView.builder` bọc trong `RefreshIndicator`.
3. **Kết Nối Điều Hướng Từ Home**:
   * Cập nhật callback nút **"Tất cả >"** từ `HomeScreen` để mở `MovieListScreen` và truyền tham số `title` + `typeSlug` tương ứng.
