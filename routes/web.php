<?php

use Illuminate\Support\Facades\Route;

Route::get('/', function () {
    return view('welcome');
});

Route::get('ai/knowledge', function () {
    $filePath = storage_path('ai/knowledge.md');

    if (!file_exists($filePath)) {
        abort(404);
    }

    return response()->file($filePath, [
        'Content-Type' => 'text/plain'
    ]);
});
