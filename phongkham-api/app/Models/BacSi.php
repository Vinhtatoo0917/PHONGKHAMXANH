<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\HasMany;

class BacSi extends Model
{
    protected $table = 'bacsi';
    protected $primaryKey = 'MaBacSi';
    public $timestamps = false;

    protected $fillable = [
        'MaTaiKhoan',
        'ho',
        'ten',
        'ngaysinh',
        'gioitinh',
        'ChuyenKhoa',
        'BangCap',
        'KinhNghiem'
    ];

    public function taiKhoan(): BelongsTo
    {
        return $this->belongsTo(TaiKhoan::class, 'MaTaiKhoan', 'MaTaiKhoan');
    }

    public function lichLamViec(): HasMany
    {
        return $this->hasMany(LichLamViec::class, 'MaBacSi', 'MaBacSi');
    }

    public function ketLuanKham(): HasMany
    {
        return $this->hasMany(KetLuanKham::class, 'MaBacSi', 'MaBacSi');
    }

    public function donThuoc(): HasMany
    {
        return $this->hasMany(DonThuoc::class, 'MaBacSi', 'MaBacSi');
    }
}
