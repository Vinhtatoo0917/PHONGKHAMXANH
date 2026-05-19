<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\HasMany;

class DichVu extends Model
{
    protected $table = 'dichvu';
    protected $primaryKey = 'MaDichVu';
    public $timestamps = false;

    protected $fillable = [
        'TenDichVu',
        'Gia',
        'MaKhoa',
        'madichvuyte'
    ];

    protected $casts = [
        'Gia' => 'decimal:2',
    ];

    public function khoa(): BelongsTo
    {
        return $this->belongsTo(Khoa::class, 'MaKhoa', 'MaKhoa');
    }

    public function chiTietLichKham(): HasMany
    {
        return $this->hasMany(ChiTietLichKham::class, 'MaDichVu', 'MaDichVu');
    }
}
