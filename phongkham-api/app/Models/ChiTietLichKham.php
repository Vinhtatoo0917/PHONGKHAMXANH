<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class ChiTietLichKham extends Model
{
    protected $table = 'chitietlichkham';
    protected $primaryKey = 'MaChiTiet';
    public $timestamps = false;

    protected $fillable = [
        'MaLichKham',
        'MaDichVu',
        'SoLuong',
        'DonGia',
        'ThanhTien'
    ];

    protected $casts = [
        'DonGia' => 'decimal:2',
        'ThanhTien' => 'decimal:2',
    ];

    public function lichKham(): BelongsTo
    {
        return $this->belongsTo(LichKham::class, 'MaLichKham', 'MaLichKham');
    }

    public function dichVu(): BelongsTo
    {
        return $this->belongsTo(DichVu::class, 'MaDichVu', 'MaDichVu');
    }
}
