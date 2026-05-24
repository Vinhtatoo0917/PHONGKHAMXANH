<!DOCTYPE html>
<html lang="vi">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Đặt lại mật khẩu</title>
  <style>
    body { margin: 0; padding: 0; background-color: #F2F2F7; font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', sans-serif; }
    .wrapper { max-width: 480px; margin: 40px auto; background: #ffffff; border-radius: 16px; overflow: hidden; box-shadow: 0 2px 12px rgba(0,0,0,0.08); }
    .header { background: #0D47A1; padding: 32px 24px; text-align: center; }
    .header h1 { margin: 0; color: #ffffff; font-size: 20px; font-weight: 700; letter-spacing: -0.3px; }
    .header p { margin: 6px 0 0; color: rgba(255,255,255,0.75); font-size: 13px; }
    .body { padding: 32px 24px; }
    .body p { color: #3A3A3C; font-size: 15px; line-height: 1.6; margin: 0 0 16px; }
    .otp-box { background: #F2F2F7; border-radius: 12px; padding: 20px; text-align: center; margin: 24px 0; }
    .otp-code { font-size: 40px; font-weight: 700; letter-spacing: 12px; color: #0D47A1; font-variant-numeric: tabular-nums; }
    .otp-note { margin: 8px 0 0; font-size: 13px; color: #8E8E93; }
    .warning { background: #FFF3E0; border-left: 3px solid #FF9500; border-radius: 8px; padding: 12px 16px; margin: 20px 0; }
    .warning p { margin: 0; font-size: 13px; color: #7A4F00; }
    .footer { padding: 16px 24px 28px; text-align: center; }
    .footer p { margin: 0; font-size: 12px; color: #8E8E93; }
  </style>
</head>
<body>
  <div class="wrapper">
    <div class="header">
      <h1>Phòng Khám FY</h1>
      <p>Đặt lại mật khẩu tài khoản</p>
    </div>
    <div class="body">
      <p>Xin chào,</p>
      <p>Chúng tôi nhận được yêu cầu đặt lại mật khẩu cho tài khoản của bạn. Sử dụng mã xác nhận bên dưới để tiếp tục:</p>
      <div class="otp-box">
        <div class="otp-code">{{ $otpCode }}</div>
        <p class="otp-note">Mã có hiệu lực trong <strong>10 phút</strong></p>
      </div>
      <div class="warning">
        <p>Nếu bạn không yêu cầu đặt lại mật khẩu, hãy bỏ qua email này. Tài khoản của bạn vẫn an toàn.</p>
      </div>
      <p>Trân trọng,<br><strong>Phòng Khám FY</strong></p>
    </div>
    <div class="footer">
      <p>Email này được gửi tự động, vui lòng không trả lời.</p>
    </div>
  </div>
</body>
</html>
