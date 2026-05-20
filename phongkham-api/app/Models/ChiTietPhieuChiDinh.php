<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class ChiTietPhieuChiDinh extends Model
{
    protected $table = 'chitietphieuchidinh';
    protected $primaryKey = 'MaChiTietPhieu';
    public $timestamps = false;

    protected $fillable = [
        'MaPhieu',
        'MaDichVu',
        'TrangThai',
        'KetQua',
        'ChiSo',
        'FileKetQua',
        'NgayCoKetQua'
    ];

    public function phieuChiDinh()
    {
        return $this->belongsTo(PhieuChiDinh::class, 'MaPhieu', 'MaPhieu');
    }

    public function dichVu()
    {
        return $this->belongsTo(DichVu::class, 'MaDichVu', 'MaDichVu');
    }
}
