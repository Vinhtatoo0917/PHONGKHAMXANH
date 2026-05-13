<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\HasMany;

class CaKham extends Model
{
    protected $table = 'cakham';
    protected $primaryKey = 'MaCa';
    public $timestamps = false;

    protected $fillable = [
        'TenCa',
        'SoLuongToiDa',
        'ThoiLuongKham',
        'GioBatDau',
        'GioKetThuc',
        'TrangThai'
    ];

    public function lichLamViec(): HasMany
    {
        return $this->hasMany(LichLamViec::class, 'MaCa', 'MaCa');
    }
}
