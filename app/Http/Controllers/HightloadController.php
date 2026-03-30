<?php

namespace App\Http\Controllers;

use App\Services\FakeLoadService;
use Illuminate\Http\JsonResponse;
use Laravel\Octane\Facades\Octane;

class HightloadController extends Controller
{
    public function index(): JsonResponse
    {
        $started = microtime(true);
        $fakeLoadService = new FakeLoadService;

        $fakeLoadService->fakeCPULoader(100);
        $fakeLoadService->fakeMemoryLoader(1);
        $fakeLoadService->fakeSpeedLoader(1);

        $ended = microtime(true);
        $duration = $ended - $started;
        $durationMs = $duration * 1000;

        return response()->json([
            'status' => 'ok',
            'time' => now()->toIso8601String(),
            'duration_ms' => $durationMs,
            'duration_s' => $duration,
        ]);
    }

    public function concurrency(): JsonResponse
    {
        $started = microtime(true);
        $fakeLoadService = new FakeLoadService;

        Octane::concurrently([
            function () use ($fakeLoadService) {
                $fakeLoadService->fakeSpeedLoader(1);
            },
            function () use ($fakeLoadService) {
                $fakeLoadService->fakeSpeedLoader(1);
            },
            function () use ($fakeLoadService) {
                $fakeLoadService->fakeSpeedLoader(1);
            },
        ]);

        $fakeLoadService->fakeCPULoader(100);
        $fakeLoadService->fakeMemoryLoader(1);

        $ended = microtime(true);
        $duration = $ended - $started;
        $durationMs = $duration * 1000;

        return response()->json([
            'status' => 'ok',
            'time' => now()->toIso8601String(),
            'duration_ms' => $durationMs,
            'duration_s' => $duration,
        ]);
    }
}
