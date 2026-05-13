<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\HasMany;

class PhongKham extends Model
{
    protected $table = 'phongkham';
    protected $primaryKey = 'MaPhong';
    public $timestamps = false;

    protected $fillable = [
        'TenPhong',
        'Khu'
    ];

    public function lichLamViec(): HasMany
    {
        return $this->hasMany(LichLamViec::class, 'MaPhong', 'MaPhong');
    }
}
