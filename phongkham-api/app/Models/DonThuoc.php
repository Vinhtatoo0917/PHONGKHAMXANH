<?php
namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class DonThuoc extends Model
{
    protected $table = 'donthuoc';
    protected $primaryKey = 'MaDonThuoc';
    public $timestamps = false;

    protected $fillable = [
        'MaLichKham',
        'MaBacSi',
        'NgayKe',
    ];

    public function chiTiet()
    {
        return $this->hasMany(CtDonThuoc::class, 'MaDonThuoc', 'MaDonThuoc');
    }
}
