import '../../domain/entities/movie.dart';

class MockMovies {
  MockMovies._();

  // ── Featured Movies (Hero Carousel) ──
  static const List<Movie> featured = [
    Movie(
      id: '1',
      title: 'Vùng Đất Linh Hồn',
      slug: 'vung-dat-linh-hon',
      posterUrl: 'https://picsum.photos/seed/spirited-away/240/360',
      backdropUrl: 'https://picsum.photos/seed/spirited-away/800/450',
      rating: 9.3,
      year: 2024,
      genre: 'Phiêu lưu',
      overview: 'Một cô bé lạc vào thế giới thần linh kỳ bí, nơi cô phải tìm cách giải cứu cha mẹ và trở về thế giới loài người.',
    ),
    Movie(
      id: '2',
      title: 'Bóng Đêm Gotham',
      slug: 'bong-dem-gotham',
      posterUrl: 'https://picsum.photos/seed/dark-knight/240/360',
      backdropUrl: 'https://picsum.photos/seed/dark-knight/800/450',
      rating: 9.1,
      year: 2024,
      genre: 'Hành động',
      overview: 'Khi một tên tội phạm bí ẩn gieo rắc hỗn loạn khắp thành phố, người hùng trong bóng tối phải đối mặt với thử thách lớn nhất.',
    ),
    Movie(
      id: '3',
      title: 'Giữa Những Vì Sao',
      slug: 'giua-nhung-vi-sao',
      posterUrl: 'https://picsum.photos/seed/interstellar/240/360',
      backdropUrl: 'https://picsum.photos/seed/interstellar/800/450',
      rating: 8.9,
      year: 2025,
      genre: 'Khoa học viễn tưởng',
      overview: 'Một nhóm phi hành gia vượt qua lỗ giun không gian để tìm kiếm hành tinh mới cho nhân loại.',
    ),
    Movie(
      id: '4',
      title: 'Kẻ Trộm Giấc Mơ',
      slug: 'ke-trom-giac-mo',
      posterUrl: 'https://picsum.photos/seed/inception/240/360',
      backdropUrl: 'https://picsum.photos/seed/inception/800/450',
      rating: 8.8,
      year: 2025,
      genre: 'Hành động',
      overview: 'Một tên trộm chuyên đánh cắp bí mật từ tiềm thức nhận nhiệm vụ bất khả thi: cấy một ý tưởng vào tâm trí người khác.',
    ),
    Movie(
      id: '5',
      title: 'Đảo Kinh Hoàng',
      slug: 'dao-kinh-hoang',
      posterUrl: 'https://picsum.photos/seed/shutter-island/240/360',
      backdropUrl: 'https://picsum.photos/seed/shutter-island/800/450',
      rating: 8.7,
      year: 2025,
      genre: 'Kinh dị',
      overview: 'Hai cảnh sát liên bang điều tra vụ mất tích bí ẩn tại một bệnh viện tâm thần trên hòn đảo hẻo lánh.',
    ),
  ];

  // ── Phim Bộ ──
  static const List<Movie> trending = [
    Movie(
      id: '10',
      title: 'Chiến Binh Vĩnh Cửu',
      slug: 'chien-binh-vinh-cuu',
      posterUrl: 'https://picsum.photos/seed/eternal-warrior/240/360',
      backdropUrl: 'https://picsum.photos/seed/eternal-warrior/800/450',
      rating: 8.6,
      year: 2025,
      genre: 'Hành động',
      overview: 'Một chiến binh bất tử phải bảo vệ thế giới khỏi đạo quân bóng tối.',
    ),
    Movie(
      id: '11',
      title: 'Mật Mã Sao Hỏa',
      slug: 'mat-ma-sao-hoa',
      posterUrl: 'https://picsum.photos/seed/mars-code/240/360',
      backdropUrl: 'https://picsum.photos/seed/mars-code/800/450',
      rating: 7.9,
      year: 2025,
      genre: 'Khoa học viễn tưởng',
      overview: 'Phi hành gia mắc kẹt trên sao Hỏa phải tìm cách sinh tồn.',
    ),
    Movie(
      id: '12',
      title: 'Bản Giao Hưởng Máu',
      slug: 'ban-giao-huong-mau',
      posterUrl: 'https://picsum.photos/seed/blood-symphony/240/360',
      backdropUrl: 'https://picsum.photos/seed/blood-symphony/800/450',
      rating: 8.2,
      year: 2024,
      genre: 'Kinh dị',
      overview: 'Một nghệ sĩ violin phát hiện bản nhạc bị nguyền rủa.',
    ),
    Movie(
      id: '13',
      title: 'Đường Đua Tử Thần',
      slug: 'duong-dua-tu-than',
      posterUrl: 'https://picsum.photos/seed/death-race/240/360',
      backdropUrl: 'https://picsum.photos/seed/death-race/800/450',
      rating: 7.5,
      year: 2025,
      genre: 'Hành động',
      overview: 'Cuộc đua sinh tử xuyên sa mạc với giải thưởng tự do.',
    ),
  ];

  // ── Mới Cập Nhật ──
  static const List<Movie> newReleases = [
    Movie(
      id: '20',
      title: 'Sương Mù Đen',
      slug: 'suong-mu-den',
      posterUrl: 'https://picsum.photos/seed/black-mist/240/360',
      backdropUrl: 'https://picsum.photos/seed/black-mist/800/450',
      rating: 8.9,
      year: 2025,
      genre: 'Kinh dị',
      overview: 'Thị trấn nhỏ bị bao phủ bởi sương mù kỳ lạ mang theo sinh vật từ chiều không gian khác.',
    ),
    Movie(
      id: '21',
      title: 'Hoàng Hôn Cuối Cùng',
      slug: 'hoang-hon-cuoi-cung',
      posterUrl: 'https://picsum.photos/seed/last-sunset/240/360',
      backdropUrl: 'https://picsum.photos/seed/last-sunset/800/450',
      rating: 8.1,
      year: 2025,
      genre: 'Tình cảm',
      overview: 'Câu chuyện tình yêu giữa hai người trên hòn đảo sắp chìm.',
    ),
  ];

  // ── Top 10 Phim ──
  static const List<Movie> top10 = [
    Movie(
      id: '30',
      title: 'Đế Chế Ngầm',
      slug: 'de-che-ngam',
      posterUrl: 'https://picsum.photos/seed/underworld-empire/240/360',
      backdropUrl: 'https://picsum.photos/seed/underworld-empire/800/450',
      rating: 9.4,
      year: 2025,
      genre: 'Hành động',
      overview: 'Ông trùm mafia xây dựng đế chế từ hai bàn tay trắng.',
    ),
    Movie(
      id: '31',
      title: 'Hồi Ức Mất Tích',
      slug: 'hoi-uc-mat-tich',
      posterUrl: 'https://picsum.photos/seed/lost-memory/240/360',
      backdropUrl: 'https://picsum.photos/seed/lost-memory/800/450',
      rating: 9.2,
      year: 2025,
      genre: 'Tâm lý',
      overview: 'Người đàn ông mất trí nhớ phát hiện mình từng là sát thủ.',
    ),
  ];

  // ── Anime ──
  static const List<Movie> anime = [
    Movie(
      id: '40',
      title: 'Thanh Gươm Diệt Quỷ',
      slug: 'thanh-guom-diet-quy',
      posterUrl: 'https://picsum.photos/seed/demon-slayer/240/360',
      backdropUrl: 'https://picsum.photos/seed/demon-slayer/800/450',
      rating: 9.1,
      year: 2025,
      genre: 'Hoạt hình',
      overview: 'Chàng trai trẻ lên đường tiêu diệt quỷ để cứu em gái.',
    ),
  ];

  // ── Phim Hàn ──
  static const List<Movie> korean = [
    Movie(
      id: '50',
      title: 'Trò Chơi Con Mực',
      slug: 'tro-choi-con-muc',
      posterUrl: 'https://picsum.photos/seed/squid-game/240/360',
      backdropUrl: 'https://picsum.photos/seed/squid-game/800/450',
      rating: 8.8,
      year: 2025,
      genre: 'Kịch tính',
      overview: '456 người chơi tham gia trò chơi sinh tử để giành giải thưởng khổng lồ.',
    ),
  ];
}
