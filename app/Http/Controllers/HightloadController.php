<?php

namespace App\Http\Controllers;

use Illuminate\Http\JsonResponse;

class HightloadController extends Controller
{
    public function index(): JsonResponse
    {
        return response()->json([
            'status' => 'ok',
            'server' => 'octane-frankenphp',
            'time' => now()->toIso8601String(),
        ]);
    }
}
