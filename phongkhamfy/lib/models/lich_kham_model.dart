class LichKhamModel {
  final int? maLichKham;
  final int? maBenhNhan;
  final int? soThuTu;
  final String? trangThai;
  final String? trangThaiThanhToan;
  final double? tongTien;
  final String? ngay;
  final String? tenCa;
  final String? gioBatDau;
  final String? gioKetThuc;
  final String? tenBacSi;
  final String? chuyenKhoa;
  final String? tenPhong;
  final List<DichVuModel>? dichVu;
  final String? thoiDiemCheckIn;
  final String? thoiDiemCheckOut;

  LichKhamModel({
    this.maLichKham,
    this.maBenhNhan,
    this.soThuTu,
    this.trangThai,
    this.trangThaiThanhToan,
    this.tongTien,
    this.ngay,
    this.tenCa,
    this.gioBatDau,
    this.gioKetThuc,
    this.tenBacSi,
    this.chuyenKhoa,
    this.tenPhong,
    this.dichVu,
    this.thoiDiemCheckIn,
    this.thoiDiemCheckOut,
  });

  factory LichKhamModel.fromJson(Map<String, dynamic> json) {
    return LichKhamModel(
      maLichKham: json['MaLichKham'],
      maBenhNhan: json['MaBenhNhan'],
      soThuTu: json['SoThuTu'],
      trangThai: json['TrangThai'],
      trangThaiThanhToan: json['TrangThaiThanhToan'],
      tongTien: (json['TongTien'] as num?)?.toDouble(),
      ngay: json['Ngay'],
      tenCa: json['TenCa'],
      gioBatDau: json['GioBatDau'],
      gioKetThuc: json['GioKetThuc'],
      tenBacSi: json['TenBacSi'],
      chuyenKhoa: json['ChuyenKhoa'],
      tenPhong: json['TenPhong'],
      dichVu: (json['DichVu'] as List?)
          ?.map((e) => DichVuModel.fromJson(e))
          .toList(),
      thoiDiemCheckIn: json['ThoiDiemCheckIn'],
      thoiDiemCheckOut: json['ThoiDiemCheckOut'],
    );
  }
}

class DichVuModel {
  final String? tenDichVu;
  final double? gia;

  DichVuModel({this.tenDichVu, this.gia});

  factory DichVuModel.fromJson(Map<String, dynamic> json) {
    return DichVuModel(
      tenDichVu: json['TenDichVu'],
      gia: (json['Gia'] as num?)?.toDouble(),
    );
  }
}

class LichLamViecModel {
  final int? maLichLamViec;
  final int? maBacSi;
  final String? tenBacSi;
  final String? chuyenKhoa;
  final String? ngay;
  final String? tenCa;
  final String? gioBatDau;
  final String? gioKetThuc;
  final String? tenPhong;
  final int? soChoTrong;
  final int? soLuongToiDa;

  LichLamViecModel({
    this.maLichLamViec,
    this.maBacSi,
    this.tenBacSi,
    this.chuyenKhoa,
    this.ngay,
    this.tenCa,
    this.gioBatDau,
    this.gioKetThuc,
    this.tenPhong,
    this.soChoTrong,
    this.soLuongToiDa,
  });

  factory LichLamViecModel.fromJson(Map<String, dynamic> json) {
    return LichLamViecModel(
      maLichLamViec: json['MaLichLamViec'],
      maBacSi: json['MaBacSi'],
      tenBacSi: json['TenBacSi'],
      chuyenKhoa: json['ChuyenKhoa'],
      ngay: json['Ngay'],
      tenCa: json['TenCa'],
      gioBatDau: json['GioBatDau'],
      gioKetThuc: json['GioKetThuc'],
      tenPhong: json['TenPhong'],
      soChoTrong: json['SoChoTrong'],
      soLuongToiDa: json['SoLuongToiDa'],
    );
  }
}
