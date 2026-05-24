<?php

namespace App\Mail;

use Illuminate\Bus\Queueable;
use Illuminate\Mail\Mailable;
use Illuminate\Mail\Mailables\Content;
use Illuminate\Mail\Mailables\Envelope;
use Illuminate\Queue\SerializesModels;

class OtpResetPasswordMail extends Mailable
{
    use Queueable, SerializesModels;

    public function __construct(public string $otpCode) {}

    public function envelope(): Envelope
    {
        return new Envelope(subject: 'Mã xác nhận đặt lại mật khẩu - Phòng Khám FY');
    }

    public function content(): Content
    {
        return new Content(view: 'emails.otp_reset_password');
    }

    public function attachments(): array
    {
        return [];
    }
}
