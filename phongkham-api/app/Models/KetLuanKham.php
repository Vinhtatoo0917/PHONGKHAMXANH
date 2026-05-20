<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class KetLuanKham extends Model
{
    use HasFactory;

    protected $table = 'ketluankham';
    protected $primaryKey = 'MaKetLuanKham';
    public $timestamps = false;

    protected $fillable = [
        'MaLichKham',
        'MaBacSi',
        'MaBenh',
        'ChanDoan',
        'TinhTrang',
        'HuongDieuTri',
        'NgayKetLuan',
    ];

    public function lichKham()
    {
        return $this->belongsTo(LichKham::class, 'MaLichKham', 'MaLichKham');
    }

    public function bacSi()
    {
        return $this->belongsTo(BacSi::class, 'MaBacSi', 'MaBacSi');
    }

    public function benh()
    {
        return $this->belongsTo(Benh::class, 'MaBenh', 'MaBenh');
    }
}
