<?php

namespace App\Http\Controllers\cashier;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Cache;
use Carbon\Carbon;

class VNPayController extends Controller
{
    private $vnp_TmnCode = "NCXQSKDA";
    private $vnp_HashSecret = "3JZUEQJSDQTNQE1I0S2XUKH4WHWNE8L8";
    private $vnp_Url = "https://sandbox.vnpayment.vn/paymentv2/vpcpay.html";
    private $vnp_Returnurl = "http://127.0.0.1:8000/vnpay/return";

    /**
     * Tạo payment link VNPay
     * POST /vnpay/create-payment
     */
    public function createPayment(Request $request)
    {
        try {
            $validated = $request->validate([
                'maHoaDon' => 'required|string',
                'soTien' => 'required|numeric|min:1000',
                'app_return_url' => 'nullable|string',
            ]);

            $maHoaDon = $validated['maHoaDon'];
            $soTien = (int)($validated['soTien'] * 100); // VNPay dùng đơn vị 100 VND
            $appReturnUrl = $validated['app_return_url'] ?? null;

            $vnp_TxnRef = $maHoaDon . '_' . time();

            // Cache app return URL để dùng khi VNPay redirect về
            if ($appReturnUrl) {
                Cache::put("vnpay_app_return_{$vnp_TxnRef}", $appReturnUrl, now()->addMinutes(30));
            }
            $vnp_OrderInfo = "Thanh toan hoa don: " . $maHoaDon;

            $inputData = array(
                "vnp_Version" => "2.1.0",
                "vnp_TmnCode" => $this->vnp_TmnCode,
                "vnp_Amount" => $soTien,
                "vnp_Command" => "pay",
                "vnp_CreateDate" => date('YmdHis'),
                "vnp_CurrCode" => "VND",
                "vnp_IpAddr" => $request->ip(),
                "vnp_Locale" => "vn",
                "vnp_OrderInfo" => $vnp_OrderInfo,
                "vnp_OrderType" => "other",
                "vnp_ReturnUrl" => $this->vnp_Returnurl,
                "vnp_TxnRef" => $vnp_TxnRef,
            );

            ksort($inputData);
            $query = "";
            $i = 0;
            $hashdata = "";
            foreach ($inputData as $key => $value) {
                if ($i == 1) {
                    $hashdata .= "&" . urlencode($key) . "=" . urlencode($value);
                } else {
                    $hashdata .= urlencode($key) . "=" . urlencode($value);
                    $i = 1;
                }
                $query .= urlencode($key) . "=" . urlencode($value) . '&';
            }

            $vnp_Url = $this->vnp_Url . "?" . $query;
            if (isset($this->vnp_HashSecret)) {
                $vnpSecureHash = hash_hmac('sha512', $hashdata, $this->vnp_HashSecret);
                $vnp_Url .= 'vnp_SecureHash=' . $vnpSecureHash;
            }

            return response()->json([
                'success' => true,
                'data' => [
                    'payment_url' => $vnp_Url,
                    'vnp_TxnRef' => $vnp_TxnRef,
                    'MaHoaDon' => $maHoaDon,
                ]
            ]);
        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => $e->getMessage(),
            ], 500);
        }
    }

    /**
     * Return URL - Người dùng quay lại từ VNPay
     * GET /vnpay/return
     */
    public function handleReturn(Request $request)
    {
        try {
            $vnp_SecureHash = $request->get('vnp_SecureHash');
            $vnp_HashSecret = $this->vnp_HashSecret;

            $inputData = $request->all();
            unset($inputData['vnp_SecureHash']);
            ksort($inputData);

            $hashdata = "";
            $i = 0;
            foreach ($inputData as $key => $value) {
                if ($i == 1) {
                    $hashdata .= "&" . urlencode($key) . "=" . urlencode($value);
                } else {
                    $hashdata .= urlencode($key) . "=" . urlencode($value);
                    $i = 1;
                }
            }

            $secureHash = hash_hmac('sha512', $hashdata, $vnp_HashSecret);

            $vnp_TxnRef = $request->get('vnp_TxnRef');
            $vnp_ResponseCode = $request->get('vnp_ResponseCode');
            $vnp_Amount = $request->get('vnp_Amount') ? (int)$request->get('vnp_Amount') / 100 : 0;

            $appReturnUrl = Cache::get("vnpay_app_return_{$vnp_TxnRef}");

            if ($secureHash == $vnp_SecureHash) {
                if ($vnp_ResponseCode == "00") {
                    // Thanh toán thành công - extract MaHoaDon từ TxnRef
                    $parts = explode('_', $vnp_TxnRef);
                    $maHoaDon = $parts[0];

                    // Kiểm tra chưa paid để tránh duplicate từ IPN + Return
                    $hoaDon = DB::table('hoadon')->where('MaHoaDon', (int)$maHoaDon)->first();
                    if ($hoaDon && $hoaDon->TrangThai !== 'paid') {
                        DB::table('thanhtoan')->insert([
                            'MaHoaDon' => (int)$maHoaDon,
                            'MaThuNgan' => null,
                            'SoTien' => $vnp_Amount,
                            'PhuongThuc' => 'vnpay',
                            'TrangThai' => 'completed',
                            'ThoiDiem' => Carbon::now(),
                        ]);

                        DB::table('hoadon')
                            ->where('MaHoaDon', (int)$maHoaDon)
                            ->update(['TrangThai' => 'paid']);
                    }

                    Cache::forget("vnpay_app_return_{$vnp_TxnRef}");

                    $redirectUrl = $appReturnUrl ? $appReturnUrl . '?payment=success&maHoaDon=' . $maHoaDon : null;

                    return response('<!DOCTYPE html>
<html lang="vi">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>Thanh toán thành công</title>
<style>
  * { margin: 0; padding: 0; box-sizing: border-box; }
  body {
    font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", sans-serif;
    background: linear-gradient(135deg, #e8f5e9 0%, #f1f8e9 100%);
    min-height: 100vh;
    display: flex; align-items: center; justify-content: center;
  }
  .card {
    background: white;
    border-radius: 24px;
    padding: 48px 40px;
    text-align: center;
    box-shadow: 0 20px 60px rgba(0,0,0,0.08);
    max-width: 400px; width: 90%;
  }
  .icon {
    width: 80px; height: 80px;
    background: #43A047;
    border-radius: 50%;
    display: flex; align-items: center; justify-content: center;
    margin: 0 auto 24px;
    font-size: 40px;
  }
  h2 { color: #1b5e20; font-size: 24px; margin-bottom: 12px; }
  .invoice { color: #555; font-size: 16px; margin-bottom: 8px; }
  .amount { color: #43A047; font-size: 22px; font-weight: bold; margin-bottom: 24px; }
  .countdown-wrap { color: #888; font-size: 14px; margin-bottom: 20px; }
  .countdown { font-weight: bold; color: #43A047; font-size: 18px; }
  .progress {
    width: 100%; height: 4px;
    background: #e8f5e9;
    border-radius: 2px; overflow: hidden;
  }
  .progress-bar {
    height: 100%; background: #43A047;
    width: 100%; border-radius: 2px;
    transition: width linear;
  }
  .btn {
    display: inline-block; margin-top: 20px;
    padding: 12px 28px; background: #43A047; color: white;
    border-radius: 12px; text-decoration: none; font-weight: 600;
    font-size: 15px;
  }
</style>
</head>
<body>
<div class="card">
  <div class="icon">✓</div>
  <h2>Thanh toán thành công!</h2>
  <p class="invoice">Hóa đơn <b>#' . $maHoaDon . '</b></p>
  <div class="countdown-wrap">
    Tự động quay lại ứng dụng sau <span class="countdown" id="cd">5</span> giây
  </div>
  <div class="progress"><div class="progress-bar" id="bar"></div></div>
  ' . ($redirectUrl ? '<a class="btn" href="' . $redirectUrl . '">Quay lại ngay</a>' : '') . '
</div>
<script>
  var seconds = 5;
  var bar = document.getElementById("bar");
  var cd = document.getElementById("cd");
  bar.style.transition = "width " + seconds + "s linear";
  setTimeout(function() { bar.style.width = "0%"; }, 50);
  var timer = setInterval(function() {
    seconds--;
    cd.textContent = seconds;
    if (seconds <= 0) {
      clearInterval(timer);
      ' . ($redirectUrl ? 'window.location.href = "' . $redirectUrl . '";' : 'window.close();') . '
    }
  }, 1000);
</script>
</body>
</html>');
                } else {
                    $failUrl = $appReturnUrl ? $appReturnUrl . '?payment=failed' : null;
                    return response('<!DOCTYPE html>
<html lang="vi">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>Thanh toán thất bại</title>
<style>
  * { margin: 0; padding: 0; box-sizing: border-box; }
  body {
    font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", sans-serif;
    background: linear-gradient(135deg, #ffebee 0%, #fce4ec 100%);
    min-height: 100vh;
    display: flex; align-items: center; justify-content: center;
  }
  .card {
    background: white; border-radius: 24px;
    padding: 48px 40px; text-align: center;
    box-shadow: 0 20px 60px rgba(0,0,0,0.08);
    max-width: 400px; width: 90%;
  }
  .icon {
    width: 80px; height: 80px; background: #e53935;
    border-radius: 50%; display: flex; align-items: center;
    justify-content: center; margin: 0 auto 24px; font-size: 40px;
  }
  h2 { color: #b71c1c; font-size: 24px; margin-bottom: 12px; }
  p { color: #555; font-size: 15px; margin-bottom: 24px; }
  .btn {
    display: inline-block; padding: 12px 28px;
    background: #e53935; color: white; border-radius: 12px;
    text-decoration: none; font-weight: 600; font-size: 15px;
  }
</style>
</head>
<body>
<div class="card">
  <div class="icon">✗</div>
  <h2>Thanh toán thất bại</h2>
  <p>Giao dịch không thành công. Vui lòng thử lại.</p>
  ' . ($failUrl ? '<a class="btn" href="' . $failUrl . '">Quay lại ứng dụng</a>' : '<a class="btn" href="javascript:window.close()">Đóng trang này</a>') . '
</div>
</body>
</html>');
                }
            } else {
                return response('<html><body style="font-family:sans-serif;text-align:center;padding:60px">
                    <h2 style="color:#e53935">✗ Chữ ký không hợp lệ</h2>
                    <p>Vui lòng quay lại ứng dụng.</p>
                </body></html>', 400);
            }
        } catch (\Exception $e) {
            return response('<html><body style="font-family:sans-serif;text-align:center;padding:60px">
                <h2 style="color:#e53935">✗ Lỗi hệ thống</h2>
                <p>Vui lòng quay lại ứng dụng.</p>
            </body></html>', 500);
        }
    }

    /**
     * IPN Callback - VNPay gửi thông báo thanh toán
     * POST /vnpay/ipn
     */
    public function handleIPN(Request $request)
    {
        try {
            $vnp_SecureHash = $request->get('vnp_SecureHash');
            $vnp_HashSecret = $this->vnp_HashSecret;

            $inputData = $request->all();
            unset($inputData['vnp_SecureHash']);
            ksort($inputData);

            $hashdata = "";
            $i = 0;
            foreach ($inputData as $key => $value) {
                if ($i == 1) {
                    $hashdata .= "&" . urlencode($key) . "=" . urlencode($value);
                } else {
                    $hashdata .= urlencode($key) . "=" . urlencode($value);
                    $i = 1;
                }
            }

            $secureHash = hash_hmac('sha512', $hashdata, $vnp_HashSecret);

            if ($secureHash != $vnp_SecureHash) {
                return response()->json(['RspCode' => '97', 'Message' => 'Invalid signature']);
            }

            $vnp_TxnRef = $request->get('vnp_TxnRef');
            $vnp_ResponseCode = $request->get('vnp_ResponseCode');
            $vnp_Amount = $request->get('vnp_Amount') ? (int)$request->get('vnp_Amount') / 100 : 0;

            if ($vnp_ResponseCode == "00") {
                $parts = explode('_', $vnp_TxnRef);
                $maHoaDon = $parts[0];

                $hoaDon = DB::table('hoadon')->where('MaHoaDon', (int)$maHoaDon)->first();
                if ($hoaDon && $hoaDon->TrangThai !== 'paid') {
                    DB::table('thanhtoan')->insert([
                        'MaHoaDon' => (int)$maHoaDon,
                        'MaThuNgan' => null,
                        'SoTien' => $vnp_Amount,
                        'PhuongThuc' => 'vnpay',
                        'TrangThai' => 'completed',
                        'ThoiDiem' => Carbon::now(),
                    ]);

                    DB::table('hoadon')
                        ->where('MaHoaDon', (int)$maHoaDon)
                        ->update(['TrangThai' => 'paid']);
                }

                return response()->json(['RspCode' => '00', 'Message' => 'Confirm Success']);
            } else {
                return response()->json(['RspCode' => '01', 'Message' => 'Payment failed']);
            }
        } catch (\Exception $e) {
            return response()->json(['RspCode' => '99', 'Message' => 'System error']);
        }
    }
}


