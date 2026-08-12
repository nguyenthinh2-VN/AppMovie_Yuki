# KKPhim API Specification — Bảng Mục Lục & Tổng Quan Hệ Thống API

> **Dành cho Lập Trình Viên & AI Coding Assistant**: Đây là tài liệu điều hướng tổng thể cho bộ API KKPhim (`https://www.kkphim1.com/api-document`). Toàn bộ API đã được nghiên cứu, test thực tế response JSON và phân chia thành các bộ tài liệu chuyên biệt dưới đây.

---

## 📑 Danh Sách Tài Liệu API Chuyên Biệt

| STT | Tên Tài Liệu | File Markdown | Phạm Vi API |
| :---: | :--- | :--- | :--- |
| 1 | **Phim Mới / Trang Chủ** | [KKPHIM_HOME_API_DOCS.md](file:///d:/flutter/flutter_lt_android/docs/KKPHIM_HOME_API_DOCS.md) | So sánh v1/v2/v3, Home API & API `/v1/api/danh-sach` tốt nhất cho Trang Chủ |
| 2 | **Danh Sách Phim Theo Loại** | [KKPHIM_DANH_SACH_API_DOCS.md](file:///d:/flutter/flutter_lt_android/docs/KKPHIM_DANH_SACH_API_DOCS.md) | Phim Bộ, Phim Lẻ, Hoạt Hình, TV Shows, Chiếu Rạp, Vietsub, Thuyết Minh |
| 3 | **Chi Tiết, Diễn Viên, Hình Ảnh & Stream** | [KKPHIM_CHI_TIET_PHIM_API_DOCS.md](file:///d:/flutter/flutter_lt_android/docs/KKPHIM_CHI_TIET_PHIM_API_DOCS.md) | Thông tin phim, Link m3u8/Embed, **Hình ảnh HD (Images)**, **Diễn viên (Peoples)**, **Từ khóa (Keywords)** |
| 4 | **Bộ Lọc Metadata** | [KKPHIM_METADATA_FILTERS_API_DOCS.md](file:///d:/flutter/flutter_lt_android/docs/KKPHIM_METADATA_FILTERS_API_DOCS.md) | Danh mục Thể loại, Quốc gia, Năm phát hành & API lọc theo danh mục |
| 5 | **Tìm Kiếm Phim** | [KKPHIM_TIM_KIEM_API_DOCS.md](file:///d:/flutter/flutter_lt_android/docs/KKPHIM_TIM_KIEM_API_DOCS.md) | Search Page v1 & Quick Search API cho Auto-complete Popup |

---

## ⚡ Tóm Tắt Quy Chuẩn Kỹ Thuật (Cheatsheet)

1. **Base URL chính**: `https://phimapi.com`
2. **Domain Ảnh CDN Phim**: `https://phimimg.com` (Được cung cấp động trong `data.APP_DOMAIN_CDN_IMAGE`)
3. **Domain Ảnh TMDB (Diễn viên / HD Backdrops)**: `https://image.tmdb.org/t/p/...` (Cung cấp trong `data.image_sizes` / `data.profile_sizes`)
4. **Quy tắc ghép ảnh đối với API v1**:
   ```dart
   String imageFullUrl = relativePath.startsWith('http') 
       ? relativePath 
       : 'https://phimimg.com/${relativePath.startsWith('/') ? relativePath.substring(1) : relativePath}';
   ```
5. **Phương thức phát Video**:
   - Link `.m3u8` (Trường `link_m3u8`): Phát trực tiếp bằng Native Player (`video_player`, `chewie`, `media_kit`).
   - Link Embed (Trường `link_embed`): Phát thông qua WebView (`flutter_inappwebview`).
