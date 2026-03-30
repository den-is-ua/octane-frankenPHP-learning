<?php

use App\Http\Controllers\HightloadController;
use Illuminate\Support\Facades\Route;

Route::get('/', [HightloadController::class, 'index']);

Route::get('/hightload', [HightloadController::class, 'index']);
