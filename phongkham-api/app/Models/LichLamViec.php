<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\HasMany;

class LichLamViec extends Model
{
    protected $table = 'lichlamviec';
    protected $primaryKey = 'MaLichLamViec';
    public $timestamps = false;

    protected $fillable = [
        'MaBacSi',
        'Ngay',
        'MaCa',
        'MaPhong'
    ];

    protected $casts = [
        'Ngay' => 'date',
    ];

    public function bacSi(): BelongsTo
    {
        return $this->belongsTo(BacSi::class, 'MaBacSi', 'MaBacSi');
    }

    public function caKham(): BelongsTo
    {
        return $this->belongsTo(CaKham::class, 'MaCa', 'MaCa');
    }

    public function phongKham(): BelongsTo
    {
        return $this->belongsTo(PhongKham::class, 'MaPhong', 'MaPhong');
    }

    public function lichKham(): HasMany
    {
        return $this->hasMany(LichKham::class, 'MaLichLamViec', 'MaLichLamViec');
    }
}
