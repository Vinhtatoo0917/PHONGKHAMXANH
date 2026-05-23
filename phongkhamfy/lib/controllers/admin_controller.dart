// ═══════════════════════════════════════════════════════════════
// FILE: admin_controller.dart
// MÔ TẢ: Controller quản lý các chức năng admin
// ═══════════════════════════════════════════════════════════════

import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../services/session_manager.dart';

// ═══════════════════════════════════════════════════════════════
// MODEL: Bác sĩ
// ═══════════════════════════════════════════════════════════════
class BacSi {
  final int maBacSi;
  final String hoTen;
  final String ho;
  final String ten;
  final String? ngaySinh;
  final String? gioiTinh;
  final String? chuyenKhoa;
  final String? bangCap;
  final String? kinhNghiem;
  final int? maTaiKhoan;

  // Thông tin từ bảng taikhoan (nếu có join)
  final String? email;
  final String? sdt;
  final String? trangThaiHoatDong;

  BacSi({
    required this.maBacSi,
    required this.hoTen,
    required this.ho,
    required this.ten,
    this.ngaySinh,
    this.gioiTinh,
    this.chuyenKhoa,
    this.bangCap,
    this.kinhNghiem,
    this.maTaiKhoan,
    this.email,
    this.sdt,
    this.trangThaiHoatDong,
  });

  factory BacSi.fromJson(Map<String, dynamic> json) {
    // Xử lý SĐT: có thể là int hoặc string từ API
    String? sdtStr;
    if (json['sdt'] != null) {
      sdtStr = json['sdt'].toString();
    }

    return BacSi(
      maBacSi: json['MaBacSi'] is int
          ? json['MaBacSi']
          : int.parse(json['MaBacSi'].toString()),
      hoTen: json['HoTen'] ?? '${json['ho']} ${json['ten']}',
      ho: json['ho'] ?? '',
      ten: json['ten'] ?? '',
      ngaySinh: json['ngaysinh'],
      gioiTinh: json['gioitinh'],
      chuyenKhoa: json['ChuyenKhoa'],
      bangCap: json['BangCap'],
      kinhNghiem: json['KinhNghiem'],
      maTaiKhoan: json['MaTaiKhoan'],
      email: json['email'],
      sdt: sdtStr,
      trangThaiHoatDong: json['trangthaihoatdong'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'MaBacSi': maBacSi,
      'HoTen': hoTen,
      'ho': ho,
      'ten': ten,
      'ngaysinh': ngaySinh,
      'gioitinh': gioiTinh,
      'ChuyenKhoa': chuyenKhoa,
      'BangCap': bangCap,
      'KinhNghiem': kinhNghiem,
      'MaTaiKhoan': maTaiKhoan,
      'email': email,
      'sdt': sdt,
      'trangthaihoatdong': trangThaiHoatDong,
    };
  }
}

// ═══════════════════════════════════════════════════════════════
// ADMIN CONTROLLER
// ═══════════════════════════════════════════════════════════════
class AdminController {
  final _sessionManager = SessionManager();

  /// Reuse HTTP client để giữ kết nối (keep-alive) => giảm thời gian load
  /// so với việc tạo kết nối mới mỗi request.
  static final http.Client _client = http.Client();

  /// Cache token trong vòng đời app để tránh đọc storage lặp lại quá nhiều
  /// (đặc biệt màn admin gọi nhiều API liên tục).
  String? _cachedToken;

  /// Timeout cho API admin để tránh “treo” lâu gây cảm giác load chậm.
  static const Duration _timeout = Duration(seconds: 12);

  // ─────────────────────────────────────────────────────────────
  // LẤY TOKEN
  // ─────────────────────────────────────────────────────────────
  Future<String?> _getToken() async {
    _cachedToken ??= await _sessionManager.getToken();
    return _cachedToken;
  }

  /// Khi logout/đổi user nên gọi để tránh dùng token cũ
  void clearCachedToken() {
    _cachedToken = null;
  }

  // ─────────────────────────────────────────────────────────────
  // LẤY HEADERS VỚI TOKEN
  // ─────────────────────────────────────────────────────────────
  Future<Map<String, String>> _getHeaders() async {
    final token = await _getToken();
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'Authorization': 'Bearer ${token ?? ''}',
    };
  }

  // ─────────────────────────────────────────────────────────────
  // FORMAT TIME
  // ─────────────────────────────────────────────────────────────
  String _formatTime(String time) {
    // Chuyển đổi HH:mm sang HH:mm:ss
    if (time.length == 5 && time.contains(':')) {
      return '$time:00';
    }
    return time;
  }

  // ═══════════════════════════════════════════════════════════════
  // QUẢN LÝ BÁC SĨ
  // ═══════════════════════════════════════════════════════════════

  /// Lấy danh sách bác sĩ
  /// GET /admin/bac-si
  Future<List<Map<String, dynamic>>> layDanhSachBacSi({String? search}) async {
    try {
      final headers = await _getHeaders();
      var url = '${ApiConfig.baseUrl}/admin/bac-si';

      if (search != null && search.isNotEmpty) {
        url += '?search=$search';
      }

      print('🔵 [ADMIN] Lấy danh sách bác sĩ: $url');

      final response = await _client
          .get(Uri.parse(url), headers: headers)
          .timeout(_timeout);

      print('🔵 [ADMIN] Status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          final List<dynamic> bacSiList = data['data'] ?? [];
          return bacSiList.cast<Map<String, dynamic>>();
        } else {
          print('❌ [ADMIN] API trả về success=false: ${data['message']}');
        }
      } else {
        print('❌ [ADMIN] Status code: ${response.statusCode}, Body: ${response.body}');
      }

      return [];
    } catch (e) {
      print('❌ [ADMIN] Lỗi lấy danh sách bác sĩ: $e');
      return [];
    }
  }

  /// Lấy chi tiết bác sĩ
  /// GET /admin/bac-si/{id}
  Future<BacSi?> layChiTietBacSi(int maBacSi) async {
    try {
      final headers = await _getHeaders();
      final url = '${ApiConfig.baseUrl}/admin/bac-si/$maBacSi';

      print('🔵 [ADMIN] Lấy chi tiết bác sĩ: $url');

      final response = await _client
          .get(Uri.parse(url), headers: headers)
          .timeout(_timeout);

      print('🔵 [ADMIN] Status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          return BacSi.fromJson(data['data']);
        }
      }

      return null;
    } catch (e) {
      print('❌ [ADMIN] Lỗi lấy chi tiết bác sĩ: $e');
      return null;
    }
  }

  /// Thêm bác sĩ mới
  /// POST /admin/bac-si
  /// Lưu ý: API Laravel sẽ tự động tạo tài khoản và bác sĩ
  Future<Map<String, dynamic>> themBacSi({
    required String ho,
    required String ten,
    required String ngaySinh,
    required String gioiTinh,
    required String chuyenKhoa,
    required String bangCap,
    String? kinhNghiem,
    required String email,
    required String sdt,
    required String matKhau,
  }) async {
    try {
      final headers = await _getHeaders();
      final url = '${ApiConfig.baseUrl}/admin/bac-si';

      // Chuyển SĐT thành số (bỏ ký tự không phải số)
      final sdtNumber = sdt.replaceAll(RegExp(r'[^0-9]'), '');

      final body = {
        'ho': ho,
        'ten': ten,
        'ngaysinh': ngaySinh,
        'gioitinh': gioiTinh,
        'ChuyenKhoa': chuyenKhoa,
        'BangCap': bangCap,
        'KinhNghiem': kinhNghiem ?? '',
        'email': email,
        'sdt': sdtNumber, // Gửi dạng string, Laravel sẽ convert sang int
        'MatKhau': matKhau,
      };

      print('🔵 [ADMIN] Thêm bác sĩ: $url');
      print('🔵 [ADMIN] Body: ${jsonEncode(body)}');

      final response = await _client
          .post(
            Uri.parse(url),
            headers: headers,
            body: jsonEncode(body),
          )
          .timeout(_timeout);

      print('🔵 [ADMIN] Status: ${response.statusCode}');
      print('🔵 [ADMIN] Response: ${response.body}');

      final data = jsonDecode(response.body);

      if (response.statusCode == 201 || response.statusCode == 200) {
        return {
          'success': true,
          'message': data['message'] ?? 'Thêm bác sĩ thành công',
          'data': data['data'],
        };
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Thêm bác sĩ thất bại',
        };
      }
    } catch (e) {
      print('❌ [ADMIN] Lỗi thêm bác sĩ: $e');
      return {'success': false, 'message': 'Không thể kết nối đến server'};
    }
  }

  /// Cập nhật thông tin bác sĩ
  /// PUT /admin/bac-si/{id}
  Future<Map<String, dynamic>> capNhatBacSi({
    required int maBacSi,
    String? ho,
    String? ten,
    String? ngaySinh,
    String? gioiTinh,
    String? chuyenKhoa,
    String? bangCap,
    String? kinhNghiem,
    String? email,
    String? sdt,
    String? matKhau,
  }) async {
    try {
      final headers = await _getHeaders();
      final url = '${ApiConfig.baseUrl}/admin/bac-si/$maBacSi';

      final body = <String, dynamic>{};
      if (ho != null) body['ho'] = ho;
      if (ten != null) body['ten'] = ten;
      if (ngaySinh != null) body['ngaysinh'] = ngaySinh;
      if (gioiTinh != null) body['gioitinh'] = gioiTinh;
      if (chuyenKhoa != null) body['ChuyenKhoa'] = chuyenKhoa;
      if (bangCap != null) body['BangCap'] = bangCap;
      if (kinhNghiem != null) body['KinhNghiem'] = kinhNghiem;
      if (email != null) body['email'] = email;
      if (sdt != null) body['sdt'] = sdt;
      if (matKhau != null) body['MatKhau'] = matKhau;

      print('🔵 [ADMIN] Cập nhật bác sĩ: $url');
      print('🔵 [ADMIN] Body: ${jsonEncode(body)}');

      final response = await http.put(
        Uri.parse(url),
        headers: headers,
        body: jsonEncode(body),
      );

      print('🔵 [ADMIN] Status: ${response.statusCode}');

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return {
          'success': true,
          'message': data['message'] ?? 'Cập nhật bác sĩ thành công',
        };
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Cập nhật bác sĩ thất bại',
        };
      }
    } catch (e) {
      print('❌ [ADMIN] Lỗi cập nhật bác sĩ: $e');
      return {'success': false, 'message': 'Không thể kết nối đến server'};
    }
  }

  /// Xóa bác sĩ
  /// DELETE /admin/bac-si/{id}
  Future<Map<String, dynamic>> xoaBacSi(int maBacSi) async {
    try {
      final headers = await _getHeaders();
      final url = '${ApiConfig.baseUrl}/admin/bac-si/$maBacSi';

      print('🔵 [ADMIN] Xóa bác sĩ: $url');

      final response = await http.delete(Uri.parse(url), headers: headers);

      print('🔵 [ADMIN] Status: ${response.statusCode}');

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return {
          'success': true,
          'message': data['message'] ?? 'Xóa bác sĩ thành công',
        };
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Xóa bác sĩ thất bại',
        };
      }
    } catch (e) {
      print('❌ [ADMIN] Lỗi xóa bác sĩ: $e');
      return {'success': false, 'message': 'Không thể kết nối đến server'};
    }
  }

  /// Khóa/Mở khóa tài khoản bác sĩ
  /// PATCH /admin/bac-si/{id}/trang-thai
  Future<Map<String, dynamic>> capNhatTrangThaiBacSi({
    required int maBacSi,
    required String trangThai, // 'active' hoặc 'inactive'
  }) async {
    try {
      final headers = await _getHeaders();
      final url = '${ApiConfig.baseUrl}/admin/bac-si/$maBacSi/trang-thai';

      final body = {'trangthaihoatdong': trangThai};

      print('🔵 [ADMIN] Cập nhật trạng thái bác sĩ: $url');

      final response = await http.patch(
        Uri.parse(url),
        headers: headers,
        body: jsonEncode(body),
      );

      print('🔵 [ADMIN] Status: ${response.statusCode}');

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return {
          'success': true,
          'message': data['message'] ?? 'Cập nhật trạng thái thành công',
        };
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Cập nhật trạng thái thất bại',
        };
      }
    } catch (e) {
      print('❌ [ADMIN] Lỗi cập nhật trạng thái: $e');
      return {'success': false, 'message': 'Không thể kết nối đến server'};
    }
  }

  // ═══════════════════════════════════════════════════════════════
  // QUẢN LÝ PHÒNG KHÁM
  // ═══════════════════════════════════════════════════════════════

  /// Lấy danh sách tất cả phòng khám
  /// GET /admin/phong-kham/danh-sach
  Future<List<Map<String, dynamic>>> layDanhSachPhongKham({
    String? search,
    String? khu,
  }) async {
    try {
      final headers = await _getHeaders();
      var url = '${ApiConfig.baseUrl}/admin/phong-kham/danh-sach';

      final params = <String>[];
      if (search != null && search.isNotEmpty) {
        params.add('search=$search');
      }
      if (khu != null && khu.isNotEmpty) {
        params.add('Khu=$khu');
      }

      if (params.isNotEmpty) {
        url += '?${params.join('&')}';
      }

      print('🔵 [ADMIN] Lấy danh sách phòng khám: $url');

      final response = await _client
          .get(Uri.parse(url), headers: headers)
          .timeout(_timeout);

      print('🔵 [ADMIN] Status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          final List<dynamic> phongList = data['data'] ?? [];
          return phongList.cast<Map<String, dynamic>>();
        }
      }

      return [];
    } catch (e) {
      print('❌ [ADMIN] Lỗi lấy danh sách phòng khám: $e');
      return [];
    }
  }

  /// Danh sách khu theo thực tế bệnh viện
  static const List<String> _danhSachKhuMacDinh = [
    'Tầng 1 - Phòng Khám Ngoại Trú',
    'Tầng 2 - Phòng Khám Nội Trú',
    'Tầng 3 - Phòng Khám Tim Mạch',
    'Tầng 4 - Phòng Khám Nhi Khoa',
    'Tầng 5 - Phòng Khám Sản Phụ Khoa',
    'Tầng 6 - Phòng Khám Ngoại Khoa',
    'Tầng 7 - Phòng Khám Da Liễu',
    'Tầng 8 - Phòng Khám Mắt',
    'Tầng 9 - Phòng Khám Tai Mũi Họng',
    'Tầng 10 - Phòng Khám Thần Kinh',
    'Tầng 11 - Phòng Khám Hô Hấp',
    'Tầng 12 - Phòng Khám Tiêu Hóa',
    'Tầng 13 - Phòng Khám Cơ Xương Khớp',
    'Tầng 14 - Phòng Khám Tâm Thần',
    'Tầng 15 - Phòng Khám Nha Khoa',
    'Phòng Khám Cấp Cứu',
    'Phòng Khám Chuyên Sâu',
    'Phòng Khám Tư Vấn',
  ];

  /// Lấy hoá đơn của bác sĩ
  /// GET /bacsi/hoa-don/{maLichKham}
  Future<Map<String, dynamic>> layHoaDonBacSi(int maLichKham) async {
    try {
      final headers = await _getHeaders();
      final url = '${ApiConfig.baseUrl}/bacsi/hoa-don/$maLichKham';

      print('🔵 [DOCTOR] Lấy hoá đơn: $url');

      final response = await _client
          .get(Uri.parse(url), headers: headers)
          .timeout(_timeout);

      print('🔵 [DOCTOR] Status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          return {'success': true, 'data': data['data']};
        }
      }

      return {'success': false, 'message': 'Không thể lấy hoá đơn'};
    } catch (e) {
      print('❌ [DOCTOR] Lỗi lấy hoá đơn: $e');
      return {'success': false, 'message': 'Không thể kết nối đến server'};
    }
  }

  /// Thêm khu mới
  /// POST /admin/phong-kham/khu/tao-moi
  Future<Map<String, dynamic>> themKhuMoi(String tenKhu) async {
    try {
      final headers = await _getHeaders();
      final url = '${ApiConfig.baseUrl}/admin/phong-kham/khu/tao-moi';

      final body = {'Khu': tenKhu};

      print('🔵 [ADMIN] Thêm khu mới: $url');
      print('🔵 [ADMIN] Body: ${jsonEncode(body)}');

      final response = await http.post(
        Uri.parse(url),
        headers: headers,
        body: jsonEncode(body),
      );

      print('🔵 [ADMIN] Status: ${response.statusCode}');
      print('🔵 [ADMIN] Response: ${response.body}');

      final data = jsonDecode(response.body);

      if (response.statusCode == 201 || response.statusCode == 200) {
        return {
          'success': true,
          'message': data['message'] ?? 'Thêm khu thành công',
          'data': data['data'],
        };
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Thêm khu thất bại',
        };
      }
    } catch (e) {
      print('❌ [ADMIN] Lỗi thêm khu: $e');
      return {'success': false, 'message': 'Không thể kết nối đến server'};
    }
  }

  /// Lấy danh sách các khu
  /// GET /admin/phong-kham/khu/danh-sach
  Future<List<String>> layDanhSachKhu() async {
    try {
      final headers = await _getHeaders();
      final url = '${ApiConfig.baseUrl}/admin/phong-kham/khu/danh-sach';

      print('🔵 [ADMIN] Lấy danh sách khu: $url');

      final response = await http.get(Uri.parse(url), headers: headers);

      print('🔵 [ADMIN] Status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          final List<dynamic> khuList = data['data'] ?? [];
          return khuList.map((e) => e.toString()).toList();
        }
      }

      // Nếu API không trả về, sử dụng danh sách mặc định
      return _danhSachKhuMacDinh;
    } catch (e) {
      print('❌ [ADMIN] Lỗi lấy danh sách khu: $e');
      // Trả về danh sách mặc định khi lỗi
      return _danhSachKhuMacDinh;
    }
  }

  /// Lấy chi tiết phòng khám
  /// GET /admin/phong-kham/{id}
  Future<Map<String, dynamic>?> layChiTietPhongKham(int maPhong) async {
    try {
      final headers = await _getHeaders();
      final url = '${ApiConfig.baseUrl}/admin/phong-kham/$maPhong';

      print('🔵 [ADMIN] Lấy chi tiết phòng khám: $url');

      final response = await http.get(Uri.parse(url), headers: headers);

      print('🔵 [ADMIN] Status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          return data['data'];
        }
      }

      return null;
    } catch (e) {
      print('❌ [ADMIN] Lỗi lấy chi tiết phòng khám: $e');
      return null;
    }
  }

  /// Thêm phòng khám mới
  /// POST /admin/phong-kham
  Future<Map<String, dynamic>> themPhongKham({
    required String tenPhong,
    required String khu,
  }) async {
    try {
      final headers = await _getHeaders();
      final url = '${ApiConfig.baseUrl}/admin/phong-kham';

      final body = {'TenPhong': tenPhong, 'Khu': khu};

      print('🔵 [ADMIN] Thêm phòng khám: $url');
      print('🔵 [ADMIN] Body: ${jsonEncode(body)}');

      final response = await http.post(
        Uri.parse(url),
        headers: headers,
        body: jsonEncode(body),
      );

      print('🔵 [ADMIN] Status: ${response.statusCode}');
      print('🔵 [ADMIN] Response: ${response.body}');

      final data = jsonDecode(response.body);

      if (response.statusCode == 201 || response.statusCode == 200) {
        return {
          'success': true,
          'message': data['message'] ?? 'Thêm phòng khám thành công',
          'data': data['data'],
        };
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Thêm phòng khám thất bại',
        };
      }
    } catch (e) {
      print('❌ [ADMIN] Lỗi thêm phòng khám: $e');
      return {'success': false, 'message': 'Không thể kết nối đến server'};
    }
  }

  /// Cập nhật phòng khám
  /// PUT /admin/phong-kham/{id}
  Future<Map<String, dynamic>> capNhatPhongKham({
    required int maPhong,
    String? tenPhong,
    String? khu,
  }) async {
    try {
      final headers = await _getHeaders();
      final url = '${ApiConfig.baseUrl}/admin/phong-kham/$maPhong';

      final body = <String, dynamic>{};
      if (tenPhong != null) body['TenPhong'] = tenPhong;
      if (khu != null) body['Khu'] = khu;

      print('🔵 [ADMIN] Cập nhật phòng khám: $url');
      print('🔵 [ADMIN] Body: ${jsonEncode(body)}');

      final response = await http.put(
        Uri.parse(url),
        headers: headers,
        body: jsonEncode(body),
      );

      print('🔵 [ADMIN] Status: ${response.statusCode}');

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return {
          'success': true,
          'message': data['message'] ?? 'Cập nhật phòng khám thành công',
        };
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Cập nhật phòng khám thất bại',
        };
      }
    } catch (e) {
      print('❌ [ADMIN] Lỗi cập nhật phòng khám: $e');
      return {'success': false, 'message': 'Không thể kết nối đến server'};
    }
  }

  /// Xóa phòng khám
  /// DELETE /admin/phong-kham/{id}
  Future<Map<String, dynamic>> xoaPhongKham(int maPhong) async {
    try {
      final headers = await _getHeaders();
      final url = '${ApiConfig.baseUrl}/admin/phong-kham/$maPhong';

      print('🔵 [ADMIN] Xóa phòng khám: $url');

      final response = await http.delete(Uri.parse(url), headers: headers);

      print('🔵 [ADMIN] Status: ${response.statusCode}');

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return {
          'success': true,
          'message': data['message'] ?? 'Xóa phòng khám thành công',
        };
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Xóa phòng khám thất bại',
        };
      }
    } catch (e) {
      print('❌ [ADMIN] Lỗi xóa phòng khám: $e');
      return {'success': false, 'message': 'Không thể kết nối đến server'};
    }
  }

  /// Lấy thống kê phòng khám
  /// GET /admin/phong-kham/thong-ke
  Future<Map<String, dynamic>?> layThongKePhongKham() async {
    try {
      final headers = await _getHeaders();
      final url = '${ApiConfig.baseUrl}/admin/phong-kham/thong-ke';

      print('🔵 [ADMIN] Lấy thống kê phòng khám: $url');

      final response = await http.get(Uri.parse(url), headers: headers);

      print('🔵 [ADMIN] Status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          return data['data'];
        }
      }

      return null;
    } catch (e) {
      print('❌ [ADMIN] Lỗi lấy thống kê phòng khám: $e');
      return null;
    }
  }

  /// Lấy phòng khám trống trong ca nào đó
  /// GET /admin/phong-kham/trong
  Future<List<Map<String, dynamic>>> layPhongKhamTrong({
    required String ngay,
    required int maCa,
  }) async {
    try {
      final headers = await _getHeaders();
      final url =
          '${ApiConfig.baseUrl}/admin/phong-kham/trong?Ngay=$ngay&MaCa=$maCa';

      print('🔵 [ADMIN] Lấy phòng khám trống: $url');

      final response = await http.get(Uri.parse(url), headers: headers);

      print('🔵 [ADMIN] Status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          final List<dynamic> phongList = data['data'] ?? [];
          return phongList.cast<Map<String, dynamic>>();
        }
      }

      return [];
    } catch (e) {
      print('❌ [ADMIN] Lỗi lấy phòng khám trống: $e');
      return [];
    }
  }

  /// Lấy phòng khám đang sử dụng trong ca nào đó
  /// GET /admin/phong-kham/dang-su-dung
  Future<List<Map<String, dynamic>>> layPhongKhamDangSuDung({
    required String ngay,
    required int maCa,
  }) async {
    try {
      final headers = await _getHeaders();
      final url =
          '${ApiConfig.baseUrl}/admin/phong-kham/dang-su-dung?Ngay=$ngay&MaCa=$maCa';

      print('🔵 [ADMIN] Lấy phòng khám đang sử dụng: $url');

      final response = await http.get(Uri.parse(url), headers: headers);

      print('🔵 [ADMIN] Status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          final List<dynamic> phongList = data['data'] ?? [];
          return phongList.cast<Map<String, dynamic>>();
        }
      }

      return [];
    } catch (e) {
      print('❌ [ADMIN] Lỗi lấy phòng khám đang sử dụng: $e');
      return [];
    }
  }

  /// Lấy danh sách phòng khám theo khu
  /// GET /admin/phong-kham/khu/{khu}
  Future<List<Map<String, dynamic>>> layPhongKhamTheoKhu(String khu) async {
    try {
      final headers = await _getHeaders();
      final url = '${ApiConfig.baseUrl}/admin/phong-kham/khu/$khu';

      print('🔵 [ADMIN] Lấy phòng khám theo khu: $url');

      final response = await http.get(Uri.parse(url), headers: headers);

      print('🔵 [ADMIN] Status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          final List<dynamic> phongList = data['data'] ?? [];
          return phongList.cast<Map<String, dynamic>>();
        }
      }

      return [];
    } catch (e) {
      print('❌ [ADMIN] Lỗi lấy phòng khám theo khu: $e');
      return [];
    }
  }

  /// Lấy lịch sử sử dụng phòng khám
  /// GET /admin/phong-kham/{id}/lich-su
  Future<List<Map<String, dynamic>>> layLichSuPhongKham({
    required int maPhong,
    String? tuNgay,
    String? denNgay,
  }) async {
    try {
      final headers = await _getHeaders();
      var url = '${ApiConfig.baseUrl}/admin/phong-kham/$maPhong/lich-su';

      final params = <String>[];
      if (tuNgay != null) params.add('tu_ngay=$tuNgay');
      if (denNgay != null) params.add('den_ngay=$denNgay');

      if (params.isNotEmpty) {
        url += '?${params.join('&')}';
      }

      print('🔵 [ADMIN] Lấy lịch sử phòng khám: $url');

      final response = await http.get(Uri.parse(url), headers: headers);

      print('🔵 [ADMIN] Status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          final List<dynamic> lichSuList = data['data'] ?? [];
          return lichSuList.cast<Map<String, dynamic>>();
        }
      }

      return [];
    } catch (e) {
      print('❌ [ADMIN] Lỗi lấy lịch sử phòng khám: $e');
      return [];
    }
  }

  /// Kiểm tra trạng thái phòng khám
  /// GET /admin/phong-kham/{id}/trang-thai
  Future<Map<String, dynamic>?> kiemTraTrangThaiPhongKham({
    required int maPhong,
    required String ngay,
    required int maCa,
  }) async {
    try {
      final headers = await _getHeaders();
      final url =
          '${ApiConfig.baseUrl}/admin/phong-kham/$maPhong/trang-thai?Ngay=$ngay&MaCa=$maCa';

      print('🔵 [ADMIN] Kiểm tra trạng thái phòng khám: $url');

      final response = await http.get(Uri.parse(url), headers: headers);

      print('🔵 [ADMIN] Status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          return data['data'];
        }
      }

      return null;
    } catch (e) {
      print('❌ [ADMIN] Lỗi kiểm tra trạng thái phòng khám: $e');
      return null;
    }
  }

  // ═══════════════════════════════════════════════════════════════
  // QUẢN LÝ CA KHÁM
  // ═══════════════════════════════════════════════════════════════

  /// Lấy danh sách ca khám
  /// GET /admin/ca-kham
  Future<List<Map<String, dynamic>>> layDanhSachCaKham() async {
    try {
      final headers = await _getHeaders();
      final url = '${ApiConfig.baseUrl}/admin/ca-kham';

      print('🔵 [ADMIN] Lấy danh sách ca khám: $url');

      final response = await http.get(Uri.parse(url), headers: headers);

      print('🔵 [ADMIN] Status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          final List<dynamic> caList = data['data'] ?? [];
          return caList.cast<Map<String, dynamic>>();
        }
      }

      return [];
    } catch (e) {
      print('❌ [ADMIN] Lỗi lấy danh sách ca khám: $e');
      return [];
    }
  }

  /// Lấy danh sách ca khám đang hoạt động
  /// GET /admin/ca-kham/active
  Future<List<Map<String, dynamic>>> layDanhSachCaKhamActive() async {
    try {
      final headers = await _getHeaders();
      final url = '${ApiConfig.baseUrl}/admin/ca-kham/active';

      print('🔵 [ADMIN] Lấy danh sách ca khám active: $url');

      final response = await http.get(Uri.parse(url), headers: headers);

      print('🔵 [ADMIN] Status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          final List<dynamic> caList = data['data'] ?? [];
          return caList.cast<Map<String, dynamic>>();
        }
      }

      return [];
    } catch (e) {
      print('❌ [ADMIN] Lỗi lấy danh sách ca khám active: $e');
      return [];
    }
  }

  /// Lấy chi tiết ca khám
  /// GET /admin/ca-kham/{id}
  Future<Map<String, dynamic>?> layChiTietCaKham(int maCa) async {
    try {
      final headers = await _getHeaders();
      final url = '${ApiConfig.baseUrl}/admin/ca-kham/$maCa';

      print('🔵 [ADMIN] Lấy chi tiết ca khám: $url');

      final response = await http.get(Uri.parse(url), headers: headers);

      print('🔵 [ADMIN] Status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          return data['data'];
        }
      }

      return null;
    } catch (e) {
      print('❌ [ADMIN] Lỗi lấy chi tiết ca khám: $e');
      return null;
    }
  }

  /// Thêm ca khám mới
  /// POST /admin/ca-kham
  Future<Map<String, dynamic>> themCaKham({
    required String tenCa,
    required String gioBatDau,
    required String gioKetThuc,
    required int soLuongToiDa,
    required int thoiLuongKham,
    String trangThai = 'active', // Mặc định là active
  }) async {
    try {
      final headers = await _getHeaders();
      final url = '${ApiConfig.baseUrl}/admin/ca-kham';

      // Chuyển đổi giờ từ HH:mm sang HH:mm:ss
      final gioBatDauFormatted = _formatTime(gioBatDau);
      final gioKetThucFormatted = _formatTime(gioKetThuc);

      final body = {
        'TenCa': tenCa,
        'GioBatDau': gioBatDauFormatted,
        'GioKetThuc': gioKetThucFormatted,
        'SoLuongToiDa': soLuongToiDa,
        'ThoiLuongKham': thoiLuongKham,
        'TrangThai': trangThai,
      };

      print('🔵 [ADMIN] Thêm ca khám: $url');
      print('🔵 [ADMIN] Body: ${jsonEncode(body)}');

      final response = await http.post(
        Uri.parse(url),
        headers: headers,
        body: jsonEncode(body),
      );

      print('🔵 [ADMIN] Status: ${response.statusCode}');

      final data = jsonDecode(response.body);

      if (response.statusCode == 201 || response.statusCode == 200) {
        return {
          'success': true,
          'message': data['message'] ?? 'Thêm ca khám thành công',
          'data': data['data'],
        };
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Thêm ca khám thất bại',
        };
      }
    } catch (e) {
      print('❌ [ADMIN] Lỗi thêm ca khám: $e');
      return {'success': false, 'message': 'Không thể kết nối đến server'};
    }
  }

  /// Cập nhật ca khám
  /// PUT /admin/ca-kham/{id}
  Future<Map<String, dynamic>> capNhatCaKham({
    required int maCa,
    String? tenCa,
    String? gioBatDau,
    String? gioKetThuc,
    int? soLuongToiDa,
    int? thoiLuongKham,
    String? trangThai,
  }) async {
    try {
      final headers = await _getHeaders();
      final url = '${ApiConfig.baseUrl}/admin/ca-kham/$maCa';

      final body = <String, dynamic>{};
      if (tenCa != null) body['TenCa'] = tenCa;
      if (gioBatDau != null) body['GioBatDau'] = _formatTime(gioBatDau);
      if (gioKetThuc != null) body['GioKetThuc'] = _formatTime(gioKetThuc);
      if (soLuongToiDa != null) body['SoLuongToiDa'] = soLuongToiDa;
      if (thoiLuongKham != null) body['ThoiLuongKham'] = thoiLuongKham;
      if (trangThai != null) body['TrangThai'] = trangThai;

      print('🔵 [ADMIN] Cập nhật ca khám: $url');
      print('🔵 [ADMIN] Body: ${jsonEncode(body)}');

      final response = await http.put(
        Uri.parse(url),
        headers: headers,
        body: jsonEncode(body),
      );

      print('🔵 [ADMIN] Status: ${response.statusCode}');

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return {
          'success': true,
          'message': data['message'] ?? 'Cập nhật ca khám thành công',
        };
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Cập nhật ca khám thất bại',
        };
      }
    } catch (e) {
      print('❌ [ADMIN] Lỗi cập nhật ca khám: $e');
      return {'success': false, 'message': 'Không thể kết nối đến server'};
    }
  }

  /// Xóa ca khám
  /// DELETE /admin/ca-kham/{id}
  Future<Map<String, dynamic>> xoaCaKham(int maCa) async {
    try {
      final headers = await _getHeaders();
      final url = '${ApiConfig.baseUrl}/admin/ca-kham/$maCa';

      print('🔵 [ADMIN] Xóa ca khám: $url');

      final response = await http.delete(Uri.parse(url), headers: headers);

      print('🔵 [ADMIN] Status: ${response.statusCode}');

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return {
          'success': true,
          'message': data['message'] ?? 'Xóa ca khám thành công',
        };
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Xóa ca khám thất bại',
        };
      }
    } catch (e) {
      print('❌ [ADMIN] Lỗi xóa ca khám: $e');
      return {'success': false, 'message': 'Không thể kết nối đến server'};
    }
  }

  // ═══════════════════════════════════════════════════════════════
  // QUẢN LÝ LỊCH LÀM VIỆC
  // ═══════════════════════════════════════════════════════════════

  /// Lấy danh sách lịch làm việc
  /// GET /admin/lich-lam-viec
  Future<List<Map<String, dynamic>>> layDanhSachLichLamViec({
    String? ngay,
    int? maBacSi,
    int? maCa,
    int? maPhong,
    String? tuNgay,
    String? denNgay,
  }) async {
    try {
      final headers = await _getHeaders();
      var url = '${ApiConfig.baseUrl}/admin/lich-lam-viec';

      final params = <String>[];
      if (ngay != null) params.add('ngay=$ngay');
      if (maBacSi != null) params.add('MaBacSi=$maBacSi');
      if (maCa != null) params.add('MaCa=$maCa');
      if (maPhong != null) params.add('MaPhong=$maPhong');
      if (tuNgay != null) params.add('tu_ngay=$tuNgay');
      if (denNgay != null) params.add('den_ngay=$denNgay');

      if (params.isNotEmpty) {
        url += '?${params.join('&')}';
      }

      print('🔵 [ADMIN] Lấy danh sách lịch làm việc: $url');

      final response = await http.get(Uri.parse(url), headers: headers);

      print('🔵 [ADMIN] Status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          final List<dynamic> lichList = data['data'] ?? [];
          return lichList.cast<Map<String, dynamic>>();
        } else {
          print('❌ [ADMIN] API trả về success=false: ${data['message']}');
        }
      } else {
        print('❌ [ADMIN] Status code: ${response.statusCode}, Body: ${response.body}');
      }

      return [];
    } catch (e) {
      print('❌ [ADMIN] Lỗi lấy danh sách lịch làm việc: $e');
      return [];
    }
  }

  /// Lấy chi tiết lịch làm việc
  /// GET /admin/lich-lam-viec/{id}
  Future<Map<String, dynamic>?> layChiTietLichLamViec(int maLichLamViec) async {
    try {
      final headers = await _getHeaders();
      final url = '${ApiConfig.baseUrl}/admin/lich-lam-viec/$maLichLamViec';

      print('🔵 [ADMIN] Lấy chi tiết lịch làm việc: $url');

      final response = await http.get(Uri.parse(url), headers: headers);

      print('🔵 [ADMIN] Status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          return data['data'];
        }
      }

      return null;
    } catch (e) {
      print('❌ [ADMIN] Lỗi lấy chi tiết lịch làm việc: $e');
      return null;
    }
  }

  /// Thêm lịch làm việc mới
  /// POST /admin/lich-lam-viec
  Future<Map<String, dynamic>> themLichLamViec({
    required int maBacSi,
    required String ngay,
    required int maCa,
    required int maPhong,
  }) async {
    try {
      final headers = await _getHeaders();
      final url = '${ApiConfig.baseUrl}/admin/lich-lam-viec';

      final body = {
        'MaBacSi': maBacSi,
        'Ngay': ngay,
        'MaCa': maCa,
        'MaPhong': maPhong,
      };

      print('🔵 [ADMIN] Thêm lịch làm việc: $url');
      print('🔵 [ADMIN] Body: ${jsonEncode(body)}');

      final response = await http.post(
        Uri.parse(url),
        headers: headers,
        body: jsonEncode(body),
      );

      print('🔵 [ADMIN] Status: ${response.statusCode}');

      final data = jsonDecode(response.body);

      if (response.statusCode == 201 || response.statusCode == 200) {
        return {
          'success': true,
          'message': data['message'] ?? 'Thêm lịch làm việc thành công',
          'data': data['data'],
        };
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Thêm lịch làm việc thất bại',
        };
      }
    } catch (e) {
      print('❌ [ADMIN] Lỗi thêm lịch làm việc: $e');
      return {'success': false, 'message': 'Không thể kết nối đến server'};
    }
  }

  /// Cập nhật lịch làm việc
  /// PUT /admin/lich-lam-viec/{id}
  Future<Map<String, dynamic>> capNhatLichLamViec({
    required int maLichLamViec,
    int? maBacSi,
    String? ngay,
    int? maCa,
    int? maPhong,
  }) async {
    try {
      final headers = await _getHeaders();
      final url = '${ApiConfig.baseUrl}/admin/lich-lam-viec/$maLichLamViec';

      final body = <String, dynamic>{};
      if (maBacSi != null) body['MaBacSi'] = maBacSi;
      if (ngay != null) body['Ngay'] = ngay;
      if (maCa != null) body['MaCa'] = maCa;
      if (maPhong != null) body['MaPhong'] = maPhong;

      print('🔵 [ADMIN] Cập nhật lịch làm việc: $url');
      print('🔵 [ADMIN] Body: ${jsonEncode(body)}');

      final response = await http.put(
        Uri.parse(url),
        headers: headers,
        body: jsonEncode(body),
      );

      print('🔵 [ADMIN] Status: ${response.statusCode}');

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return {
          'success': true,
          'message': data['message'] ?? 'Cập nhật lịch làm việc thành công',
        };
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Cập nhật lịch làm việc thất bại',
        };
      }
    } catch (e) {
      print('❌ [ADMIN] Lỗi cập nhật lịch làm việc: $e');
      return {'success': false, 'message': 'Không thể kết nối đến server'};
    }
  }

  /// Xóa lịch làm việc
  /// DELETE /admin/lich-lam-viec/{id}
  Future<Map<String, dynamic>> xoaLichLamViec(int maLichLamViec) async {
    try {
      final headers = await _getHeaders();
      final url = '${ApiConfig.baseUrl}/admin/lich-lam-viec/$maLichLamViec';

      print('🔵 [ADMIN] Xóa lịch làm việc: $url');

      final response = await http.delete(Uri.parse(url), headers: headers);

      print('🔵 [ADMIN] Status: ${response.statusCode}');

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return {
          'success': true,
          'message': data['message'] ?? 'Xóa lịch làm việc thành công',
        };
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Xóa lịch làm việc thất bại',
        };
      }
    } catch (e) {
      print('❌ [ADMIN] Lỗi xóa lịch làm việc: $e');
      return {'success': false, 'message': 'Không thể kết nối đến server'};
    }
  }

  /// Lấy lịch làm việc của bác sĩ
  /// GET /admin/lich-lam-viec/bac-si/{MaBacSi}
  Future<List<Map<String, dynamic>>> layLichLamViecBacSi({
    required int maBacSi,
    String? tuNgay,
    String? denNgay,
  }) async {
    try {
      final headers = await _getHeaders();
      var url = '${ApiConfig.baseUrl}/admin/lich-lam-viec/bac-si/$maBacSi';

      final params = <String>[];
      if (tuNgay != null) params.add('tu_ngay=$tuNgay');
      if (denNgay != null) params.add('den_ngay=$denNgay');

      if (params.isNotEmpty) {
        url += '?${params.join('&')}';
      }

      print('🔵 [ADMIN] Lấy lịch làm việc bác sĩ: $url');

      final response = await http.get(Uri.parse(url), headers: headers);

      print('🔵 [ADMIN] Status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          final List<dynamic> lichList = data['data'] ?? [];
          return lichList.cast<Map<String, dynamic>>();
        } else {
          print('❌ [ADMIN] API trả về success=false: ${data['message']}');
        }
      } else {
        print('❌ [ADMIN] Status code: ${response.statusCode}, Body: ${response.body}');
      }

      return [];
    } catch (e) {
      print('❌ [ADMIN] Lỗi lấy lịch làm việc bác sĩ: $e');
      return [];
    }
  }

  /// Lấy danh sách bác sĩ làm việc trong ngày
  /// GET /admin/lich-lam-viec/ngay/{ngay}
  Future<List<Map<String, dynamic>>> layLichLamViecNgay(String ngay) async {
    try {
      final headers = await _getHeaders();
      final url = '${ApiConfig.baseUrl}/admin/lich-lam-viec/ngay/$ngay';

      print('🔵 [ADMIN] Lấy lịch làm việc ngày: $url');

      final response = await http.get(Uri.parse(url), headers: headers);

      print('🔵 [ADMIN] Status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          final List<dynamic> lichList = data['data'] ?? [];
          return lichList.cast<Map<String, dynamic>>();
        } else {
          print('❌ [ADMIN] API trả về success=false: ${data['message']}');
        }
      } else {
        print('❌ [ADMIN] Status code: ${response.statusCode}, Body: ${response.body}');
      }

      return [];
    } catch (e) {
      print('❌ [ADMIN] Lỗi lấy lịch làm việc ngày: $e');
      return [];
    }
  }

  /// Lấy danh sách bác sĩ làm việc trong ca
  /// GET /admin/lich-lam-viec/ca/{maCa}
  Future<List<Map<String, dynamic>>> layLichLamViecCa({
    required int maCa,
    required String ngay,
  }) async {
    try {
      final headers = await _getHeaders();
      final url =
          '${ApiConfig.baseUrl}/admin/lich-lam-viec/ca/$maCa?Ngay=$ngay';

      print('🔵 [ADMIN] Lấy lịch làm việc ca: $url');

      final response = await http.get(Uri.parse(url), headers: headers);

      print('🔵 [ADMIN] Status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          final List<dynamic> lichList = data['data'] ?? [];
          return lichList.cast<Map<String, dynamic>>();
        } else {
          print('❌ [ADMIN] API trả về success=false: ${data['message']}');
        }
      } else {
        print('❌ [ADMIN] Status code: ${response.statusCode}, Body: ${response.body}');
      }

      return [];
    } catch (e) {
      print('❌ [ADMIN] Lỗi lấy lịch làm việc ca: $e');
      return [];
    }
  }

  // ═══════════════════════════════════════════════════════════════
  // QUẢN LÝ KHOA
  // ═══════════════════════════════════════════════════════════════

  /// Lấy danh sách khoa
  /// GET /admin/khoa
  Future<List<Map<String, dynamic>>> layDanhSachKhoa({String? search}) async {
    try {
      final headers = await _getHeaders();
      var url = '${ApiConfig.baseUrl}/admin/khoa';

      if (search != null && search.isNotEmpty) {
        url += '?search=$search';
      }

      print('🔵 [ADMIN] Lấy danh sách khoa: $url');

      final response = await http.get(Uri.parse(url), headers: headers);

      print('🔵 [ADMIN] Status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          final List<dynamic> khoaList = data['data'] ?? [];
          return khoaList.cast<Map<String, dynamic>>();
        }
      }

      return [];
    } catch (e) {
      print('❌ [ADMIN] Lỗi lấy danh sách khoa: $e');
      return [];
    }
  }

  /// Lấy chi tiết khoa
  /// GET /admin/khoa/{id}
  Future<Map<String, dynamic>?> layChiTietKhoa(String maKhoa) async {
    try {
      final headers = await _getHeaders();
      final url = '${ApiConfig.baseUrl}/admin/khoa/$maKhoa';

      print('🔵 [ADMIN] Lấy chi tiết khoa: $url');

      final response = await http.get(Uri.parse(url), headers: headers);

      print('🔵 [ADMIN] Status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          return data['data'];
        }
      }

      return null;
    } catch (e) {
      print('❌ [ADMIN] Lỗi lấy chi tiết khoa: $e');
      return null;
    }
  }

  /// Thêm khoa mới
  /// POST /admin/khoa
  /// Lưu ý: Mã khoa (MaKhoa) sẽ được tự động tạo bởi server
  Future<Map<String, dynamic>> themKhoa({
    required String tenKhoa,
    required String maChuyenKhoa,
  }) async {
    try {
      final headers = await _getHeaders();
      final url = '${ApiConfig.baseUrl}/admin/khoa';

      final body = {'TenKhoa': tenKhoa, 'machuyenkhoa': maChuyenKhoa};

      print('🔵 [ADMIN] Thêm khoa: $url');
      print('🔵 [ADMIN] Body: ${jsonEncode(body)}');

      final response = await http.post(
        Uri.parse(url),
        headers: headers,
        body: jsonEncode(body),
      );

      print('🔵 [ADMIN] Status: ${response.statusCode}');

      final data = jsonDecode(response.body);

      if (response.statusCode == 201 || response.statusCode == 200) {
        return {
          'success': true,
          'message': data['message'] ?? 'Thêm khoa thành công',
          'data': data['data'],
        };
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Thêm khoa thất bại',
        };
      }
    } catch (e) {
      print('❌ [ADMIN] Lỗi thêm khoa: $e');
      return {'success': false, 'message': 'Không thể kết nối đến server'};
    }
  }

  /// Cập nhật khoa
  /// PUT /admin/khoa/{id}
  Future<Map<String, dynamic>> capNhatKhoa({
    required String maKhoa,
    required String tenKhoa,
  }) async {
    try {
      final headers = await _getHeaders();
      final url = '${ApiConfig.baseUrl}/admin/khoa/$maKhoa';

      final body = {'TenKhoa': tenKhoa};

      print('🔵 [ADMIN] Cập nhật khoa: $url');
      print('🔵 [ADMIN] Body: ${jsonEncode(body)}');

      final response = await http.put(
        Uri.parse(url),
        headers: headers,
        body: jsonEncode(body),
      );

      print('🔵 [ADMIN] Status: ${response.statusCode}');

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return {
          'success': true,
          'message': data['message'] ?? 'Cập nhật khoa thành công',
        };
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Cập nhật khoa thất bại',
        };
      }
    } catch (e) {
      print('❌ [ADMIN] Lỗi cập nhật khoa: $e');
      return {'success': false, 'message': 'Không thể kết nối đến server'};
    }
  }

  /// Xóa khoa
  /// DELETE /admin/khoa/{id}
  Future<Map<String, dynamic>> xoaKhoa(String maKhoa) async {
    try {
      final headers = await _getHeaders();
      final url = '${ApiConfig.baseUrl}/admin/khoa/$maKhoa';

      print('🔵 [ADMIN] Xóa khoa: $url');

      final response = await http.delete(Uri.parse(url), headers: headers);

      print('🔵 [ADMIN] Status: ${response.statusCode}');

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return {
          'success': true,
          'message': data['message'] ?? 'Xóa khoa thành công',
        };
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Xóa khoa thất bại',
        };
      }
    } catch (e) {
      print('❌ [ADMIN] Lỗi xóa khoa: $e');
      return {'success': false, 'message': 'Không thể kết nối đến server'};
    }
  }

  // ═══════════════════════════════════════════════════════════════
  // QUẢN LÝ BỆNH
  // ═══════════════════════════════════════════════════════════════

  /// Lấy danh sách bệnh
  /// GET /admin/benh
  Future<List<Map<String, dynamic>>> layDanhSachBenh({String? search}) async {
    try {
      final headers = await _getHeaders();
      var url = '${ApiConfig.baseUrl}/admin/benh';

      if (search != null && search.isNotEmpty) {
        url += '?search=$search';
      }

      print('🔵 [ADMIN] Lấy danh sách bệnh: $url');

      final response = await http.get(Uri.parse(url), headers: headers);

      print('🔵 [ADMIN] Status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          final List<dynamic> benhList = data['data'] ?? [];
          return benhList.cast<Map<String, dynamic>>();
        }
      }

      return [];
    } catch (e) {
      print('❌ [ADMIN] Lỗi lấy danh sách bệnh: $e');
      return [];
    }
  }

  /// Lấy chi tiết bệnh
  /// GET /admin/benh/{id}
  Future<Map<String, dynamic>?> layChiTietBenh(String maBenh) async {
    try {
      final headers = await _getHeaders();
      final url = '${ApiConfig.baseUrl}/admin/benh/$maBenh';

      print('🔵 [ADMIN] Lấy chi tiết bệnh: $url');

      final response = await http.get(Uri.parse(url), headers: headers);

      print('🔵 [ADMIN] Status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          return data['data'];
        }
      }

      return null;
    } catch (e) {
      print('❌ [ADMIN] Lỗi lấy chi tiết bệnh: $e');
      return null;
    }
  }

  /// Thêm bệnh mới
  /// POST /admin/benh
  /// Lưu ý: Mã bệnh (MaBenh) sẽ được tự động tạo bởi server
  Future<Map<String, dynamic>> themBenh({
    required String tenBenh,
    required String maBenhLy,
    String? moTa,
  }) async {
    try {
      final headers = await _getHeaders();
      final url = '${ApiConfig.baseUrl}/admin/benh';

      final body = {
        'TenBenh': tenBenh,
        'mabenhly': maBenhLy,
        'MoTa': moTa ?? '',
      };

      print('🔵 [ADMIN] Thêm bệnh: $url');
      print('🔵 [ADMIN] Body: ${jsonEncode(body)}');

      final response = await http.post(
        Uri.parse(url),
        headers: headers,
        body: jsonEncode(body),
      );

      print('🔵 [ADMIN] Status: ${response.statusCode}');

      final data = jsonDecode(response.body);

      if (response.statusCode == 201 || response.statusCode == 200) {
        return {
          'success': true,
          'message': data['message'] ?? 'Thêm bệnh thành công',
          'data': data['data'],
        };
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Thêm bệnh thất bại',
        };
      }
    } catch (e) {
      print('❌ [ADMIN] Lỗi thêm bệnh: $e');
      return {'success': false, 'message': 'Không thể kết nối đến server'};
    }
  }

  /// Cập nhật bệnh
  /// PUT /admin/benh/{id}
  Future<Map<String, dynamic>> capNhatBenh({
    required String maBenh,
    required String tenBenh,
    String? moTa,
  }) async {
    try {
      final headers = await _getHeaders();
      final url = '${ApiConfig.baseUrl}/admin/benh/$maBenh';

      final body = {'TenBenh': tenBenh, 'MoTa': moTa ?? ''};

      print('🔵 [ADMIN] Cập nhật bệnh: $url');
      print('🔵 [ADMIN] Body: ${jsonEncode(body)}');

      final response = await http.put(
        Uri.parse(url),
        headers: headers,
        body: jsonEncode(body),
      );

      print('🔵 [ADMIN] Status: ${response.statusCode}');

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return {
          'success': true,
          'message': data['message'] ?? 'Cập nhật bệnh thành công',
        };
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Cập nhật bệnh thất bại',
        };
      }
    } catch (e) {
      print('❌ [ADMIN] Lỗi cập nhật bệnh: $e');
      return {'success': false, 'message': 'Không thể kết nối đến server'};
    }
  }

  /// Xóa bệnh
  /// DELETE /admin/benh/{id}
  Future<Map<String, dynamic>> xoaBenh(String maBenh) async {
    try {
      final headers = await _getHeaders();
      final url = '${ApiConfig.baseUrl}/admin/benh/$maBenh';

      print('🔵 [ADMIN] Xóa bệnh: $url');

      final response = await http.delete(Uri.parse(url), headers: headers);

      print('🔵 [ADMIN] Status: ${response.statusCode}');

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return {
          'success': true,
          'message': data['message'] ?? 'Xóa bệnh thành công',
        };
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Xóa bệnh thất bại',
        };
      }
    } catch (e) {
      print('❌ [ADMIN] Lỗi xóa bệnh: $e');
      return {'success': false, 'message': 'Không thể kết nối đến server'};
    }
  }

  // ═══════════════════════════════════════════════════════════════
  // QUẢN LÝ DỊCH VỤ
  // ═══════════════════════════════════════════════════════════════

  /// Lấy danh sách dịch vụ
  /// GET /admin/dich-vu
  Future<List<Map<String, dynamic>>> layDanhSachDichVu({
    String? search,
    String? maKhoa,
  }) async {
    try {
      final headers = await _getHeaders();
      var url = '${ApiConfig.baseUrl}/admin/dich-vu';

      final params = <String>[];
      if (search != null && search.isNotEmpty) {
        params.add('search=$search');
      }
      if (maKhoa != null && maKhoa.isNotEmpty) {
        params.add('MaKhoa=$maKhoa');
      }

      if (params.isNotEmpty) {
        url += '?${params.join('&')}';
      }

      print('🔵 [ADMIN] Lấy danh sách dịch vụ: $url');

      final response = await http.get(Uri.parse(url), headers: headers);

      print('🔵 [ADMIN] Status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          final List<dynamic> dichVuList = data['data'] ?? [];
          return dichVuList.cast<Map<String, dynamic>>();
        }
      }

      return [];
    } catch (e) {
      print('❌ [ADMIN] Lỗi lấy danh sách dịch vụ: $e');
      return [];
    }
  }

  /// Lấy chi tiết dịch vụ
  /// GET /admin/dich-vu/{id}
  Future<Map<String, dynamic>?> layChiTietDichVu(String maDichVu) async {
    try {
      final headers = await _getHeaders();
      final url = '${ApiConfig.baseUrl}/admin/dich-vu/$maDichVu';

      print('🔵 [ADMIN] Lấy chi tiết dịch vụ: $url');

      final response = await http.get(Uri.parse(url), headers: headers);

      print('🔵 [ADMIN] Status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          return data['data'];
        }
      }

      return null;
    } catch (e) {
      print('❌ [ADMIN] Lỗi lấy chi tiết dịch vụ: $e');
      return null;
    }
  }

  /// Thêm dịch vụ mới
  /// POST /admin/dich-vu
  /// Lưu ý: Mã dịch vụ (MaDichVu) sẽ được tự động tạo bởi server
  Future<Map<String, dynamic>> themDichVu({
    required String tenDichVu,
    required double gia,
    required String maDichVuYte,
    int? maKhoa,
  }) async {
    try {
      final headers = await _getHeaders();
      final url = '${ApiConfig.baseUrl}/admin/dich-vu';

      final body = {
        'TenDichVu': tenDichVu,
        'Gia': gia,
        'madichvuyte': maDichVuYte,
        'MaKhoa': maKhoa,
      };

      print('🔵 [ADMIN] Thêm dịch vụ: $url');
      print('🔵 [ADMIN] Body: ${jsonEncode(body)}');

      final response = await http.post(
        Uri.parse(url),
        headers: headers,
        body: jsonEncode(body),
      );

      print('🔵 [ADMIN] Status: ${response.statusCode}');

      final data = jsonDecode(response.body);

      if (response.statusCode == 201 || response.statusCode == 200) {
        return {
          'success': true,
          'message': data['message'] ?? 'Thêm dịch vụ thành công',
          'data': data['data'],
        };
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Thêm dịch vụ thất bại',
        };
      }
    } catch (e) {
      print('❌ [ADMIN] Lỗi thêm dịch vụ: $e');
      return {'success': false, 'message': 'Không thể kết nối đến server'};
    }
  }

  /// Cập nhật dịch vụ
  /// PUT /admin/dich-vu/{id}
  Future<Map<String, dynamic>> capNhatDichVu({
    required String maDichVu,
    required String tenDichVu,
    required double gia,
    String? maKhoa,
  }) async {
    try {
      final headers = await _getHeaders();
      final url = '${ApiConfig.baseUrl}/admin/dich-vu/$maDichVu';

      final body = {'TenDichVu': tenDichVu, 'Gia': gia, 'MaKhoa': maKhoa};

      print('🔵 [ADMIN] Cập nhật dịch vụ: $url');
      print('🔵 [ADMIN] Body: ${jsonEncode(body)}');

      final response = await http.put(
        Uri.parse(url),
        headers: headers,
        body: jsonEncode(body),
      );

      print('🔵 [ADMIN] Status: ${response.statusCode}');

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return {
          'success': true,
          'message': data['message'] ?? 'Cập nhật dịch vụ thành công',
        };
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Cập nhật dịch vụ thất bại',
        };
      }
    } catch (e) {
      print('❌ [ADMIN] Lỗi cập nhật dịch vụ: $e');
      return {'success': false, 'message': 'Không thể kết nối đến server'};
    }
  }

  /// Xóa dịch vụ
  /// DELETE /admin/dich-vu/{id}
  Future<Map<String, dynamic>> xoaDichVu(String maDichVu) async {
    try {
      final headers = await _getHeaders();
      final url = '${ApiConfig.baseUrl}/admin/dich-vu/$maDichVu';

      print('🔵 [ADMIN] Xóa dịch vụ: $url');

      final response = await http.delete(Uri.parse(url), headers: headers);

      print('🔵 [ADMIN] Status: ${response.statusCode}');

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return {
          'success': true,
          'message': data['message'] ?? 'Xóa dịch vụ thành công',
        };
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Xóa dịch vụ thất bại',
        };
      }
    } catch (e) {
      print('❌ [ADMIN] Lỗi xóa dịch vụ: $e');
      return {'success': false, 'message': 'Không thể kết nối đến server'};
    }
  }

  /// Lấy dịch vụ theo khoa
  /// GET /admin/dich-vu/khoa/{maKhoa}
  Future<List<Map<String, dynamic>>> layDichVuTheoKhoa(String maKhoa) async {
    try {
      final headers = await _getHeaders();
      final url = '${ApiConfig.baseUrl}/admin/dich-vu/khoa/$maKhoa';

      print('🔵 [ADMIN] Lấy dịch vụ theo khoa: $url');

      final response = await http.get(Uri.parse(url), headers: headers);

      print('🔵 [ADMIN] Status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          final List<dynamic> dichVuList = data['data'] ?? [];
          return dichVuList.cast<Map<String, dynamic>>();
        }
      }

      return [];
    } catch (e) {
      print('❌ [ADMIN] Lỗi lấy dịch vụ theo khoa: $e');
      return [];
    }
  }

  /// Lấy dịch vụ theo bệnh
  /// GET /admin/dich-vu/benh/{maBenh}
  Future<List<Map<String, dynamic>>> layDichVuTheoBenh(String maBenh) async {
    try {
      final headers = await _getHeaders();
      final url = '${ApiConfig.baseUrl}/admin/dich-vu/benh/$maBenh';

      print('🔵 [ADMIN] Lấy dịch vụ theo bệnh: $url');

      final response = await http.get(Uri.parse(url), headers: headers);

      print('🔵 [ADMIN] Status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          final List<dynamic> dichVuList = data['data'] ?? [];
          return dichVuList.cast<Map<String, dynamic>>();
        }
      }

      return [];
    } catch (e) {
      print('❌ [ADMIN] Lỗi lấy dịch vụ theo bệnh: $e');
      return [];
    }
  }

}
