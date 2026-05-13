<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\HasMany;

class BenhNhan extends Model
{
    protected $table = 'benhnhan';
    protected $primaryKey = 'MaBenhNhan';
    public $timestamps = false;

    protected $fillable = [
        'MaTaiKhoan',
        'ho',
        'ten',
        'ngaysinh',
        'gioitinh',
        'cccd',
        'diachi',
        'BHYT'
    ];

    public function taiKhoan(): BelongsTo
    {
        return $this->belongsTo(TaiKhoan::class, 'MaTaiKhoan', 'MaTaiKhoan');
    }

    public function lichKham(): HasMany
    {
        return $this->hasMany(LichKham::class, 'MaBenhNhan', 'MaBenhNhan');
    }

    public function bhyt(): HasMany
    {
        return $this->hasMany(BHYT::class, 'MaBenhNhan', 'MaBenhNhan');
    }

    public function hoaDon(): HasMany
    {
        return $this->hasMany(HoaDon::class, 'MaBenhNhan', 'MaBenhNhan');
    }
}
