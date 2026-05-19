<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\HasMany;

class Khoa extends Model
{
    protected $table = 'khoa';
    protected $primaryKey = 'MaKhoa';
    public $timestamps = false;

    protected $fillable = [
        'TenKhoa',
        'machuyenkhoa'
    ];

    public function dichVu(): HasMany
    {
        return $this->hasMany(DichVu::class, 'MaKhoa', 'MaKhoa');
    }
}
