<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class PhieuChiDinh extends Model
{
    protected $table = 'phieuchidinh';
    protected $primaryKey = 'MaPhieu';
    public $timestamps = false; // Based on SQL structure NgayChiDinh has default CURRENT_TIMESTAMP

    protected $fillable = [
        'MaLichKham',
        'MaBacSi',
        'NgayChiDinh',
        'TrangThai',
        'GhiChu'
    ];

    public function lichKham()
    {
        return $this->belongsTo(LichKham::class, 'MaLichKham', 'MaLichKham');
    }

    public function bacSi()
    {
        return $this->belongsTo(BacSi::class, 'MaBacSi', 'MaBacSi');
    }

    public function chiTiet()
    {
        return $this->hasMany(ChiTietPhieuChiDinh::class, 'MaPhieu', 'MaPhieu');
    }
}
