<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Thuoc extends Model
{
    use HasFactory;

    protected $table = 'thuoc';
    protected $primaryKey = 'MaThuoc';
    public $timestamps = false;

    protected $fillable = [
        'TenThuoc',
        'DonViTinh',
        'HamLuong',
        'Gia',
        'MoTa',
        'TrangThai',
    ];
}
