<?php

use Illuminate\Foundation\Application;
use Illuminate\Foundation\Configuration\Exceptions;
use Illuminate\Foundation\Configuration\Middleware;

return Application::configure(basePath: dirname(__DIR__))
    ->withRouting(
        web: __DIR__.'/../routes/web.php',
        commands: __DIR__.'/../routes/console.php',
        health: '/up',
    )
    ->withMiddleware(function (Middleware $middleware): void {
        // Thêm CORS middleware ở đầu tiên
        $middleware->prepend(\App\Http\Middleware\Cors::class);

        // Tắt CSRF cho các route API
        $middleware->validateCsrfTokens(except: [
            '/login',
            '/register',
            '/logout',
            '/me',
            '/forgot-password',
            '/reset-password',
            '/lich-kham/*',
            '/admin/*',
            '/profile/*',
            '/bacsi/*',
            '/cashier/*',
            '/vnpay/*',
        ]);
    })
    ->withExceptions(function (Exceptions $exceptions): void {
        //
    })->create();
