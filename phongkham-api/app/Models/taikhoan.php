<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\HasOne;

class TaiKhoan extends Model
{
    protected $table = 'taikhoan';
    protected $primaryKey = 'MaTaiKhoan';
    public $timestamps = false;

    protected $fillable = [
        'sdt',
        'email',
        'MatKhau',
        'VaiTro',
        'AccessToken',
        'trangthaihoatdong',
        'dangnhaplancuoi',
        'ngaytao'
    ];

    protected $hidden = ['MatKhau'];

    public function benhNhan(): HasOne
    {
        return $this->hasOne(BenhNhan::class, 'MaTaiKhoan', 'MaTaiKhoan');
    }

    public function bacSi(): HasOne
    {
        return $this->hasOne(BacSi::class, 'MaTaiKhoan', 'MaTaiKhoan');
    }
}
