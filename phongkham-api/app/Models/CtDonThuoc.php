<?php
namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class CtDonThuoc extends Model
{
    protected $table = 'ct_donthuoc';
    protected $primaryKey = 'MaChiTiet';
    public $timestamps = false;

    protected $fillable = [
        'MaDonThuoc',
        'MaThuoc',
        'LieuDung',
        'SoLuong',
    ];

    public function thuoc()
    {
        return $this->belongsTo(Thuoc::class, 'MaThuoc', 'MaThuoc');
    }
}
