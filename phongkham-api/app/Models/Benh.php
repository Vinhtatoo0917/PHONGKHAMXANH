<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Benh extends Model
{
    use HasFactory;

    protected $table = 'benh';
    protected $primaryKey = 'MaBenh';
    public $timestamps = false;

    protected $fillable = [
        'TenBenh',
        'MoTa',
        'mabenhly',
    ];

    public function ketLuanKham()
    {
        return $this->hasMany(KetLuanKham::class, 'MaBenh', 'MaBenh');
    }

    public function dichVu()
    {
        return $this->belongsToMany(DichVu::class, 'dichvu_benh', 'MaBenh', 'MaDichVu');
    }
}
