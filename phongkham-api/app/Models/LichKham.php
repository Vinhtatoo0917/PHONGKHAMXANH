<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\HasMany;

class LichKham extends Model
{
    protected $table = 'lichkham';
    protected $primaryKey = 'MaLichKham';
    public $timestamps = false;

    protected $fillable = [
        'MaBenhNhan',
        'SoThuTu',
        'TrangThai',
        'TrangThaiThanhToan',
        'TongTien',
        'ThoiDiemCheckIn',
        'ThoiDiemCheckOut',
        'MaNhanVienCheckIn',
        'MaLichLamViec',
        'MAOTP'
    ];

    protected $casts = [
        'ThoiDiemCheckIn' => 'datetime',
        'ThoiDiemCheckOut' => 'datetime',
    ];

    public function benhNhan(): BelongsTo
    {
        return $this->belongsTo(BenhNhan::class, 'MaBenhNhan', 'MaBenhNhan');
    }

    public function lichLamViec(): BelongsTo
    {
        return $this->belongsTo(LichLamViec::class, 'MaLichLamViec', 'MaLichLamViec');
    }

    public function chiTietLichKham(): HasMany
    {
        return $this->hasMany(ChiTietLichKham::class, 'MaLichKham', 'MaLichKham');
    }

    public function ketLuanKham()
    {
        return $this->hasOne(KetLuanKham::class, 'MaLichKham', 'MaLichKham');
    }

    public function donThuoc()
    {
        return $this->hasOne(DonThuoc::class, 'MaLichKham', 'MaLichKham');
    }

    public function phieuChiDinh()
    {
        return $this->hasMany(PhieuChiDinh::class, 'MaLichKham', 'MaLichKham');
    }
}
