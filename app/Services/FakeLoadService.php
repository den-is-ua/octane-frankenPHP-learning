<?php

namespace App\Services;

use Illuminate\Support\Facades\Log;

class FakeLoadService
{
    /**
     * Burn CPU for roughly the given duration (milliseconds).
     */
    public function fakeCPULoader(int $durationMs = 100): void
    {
        $durationMs = max(0, $durationMs);

        $started = microtime(true);
        $end = $started + ($durationMs / 1000);
        $x = random_bytes(16);

        while (microtime(true) < $end) {
            $x = hash('sha256', $x, true);
        }

        Log::debug('FakeLoadService::fakeCPULoader finished', [
            'duration_ms' => $durationMs,
            'elapsed_ms' => round((microtime(true) - $started) * 1000, 2),
        ]);
    }

    /**
     * Allocate heap memory for the duration of this call (default 1 MiB, max 64 MiB).
     * $megabytes uses binary mebibytes (1024² bytes per MiB).
     */
    public function fakeMemoryLoader(float $megabytes = 1.0): void
    {

        $megabytes = max(0.0, min($megabytes, 64.0));
        $bytes = (int) round($megabytes * 1024 * 1024);

        if ($bytes <= 0) {
            Log::debug('FakeLoadService::fakeMemoryLoader skipped', ['effective_megabytes' => 0.0]);

            return;
        }

        $chunk = str_repeat('x', $bytes);
        unset($chunk);

        Log::debug('FakeLoadService::fakeMemoryLoader finished', [
            'effective_megabytes' => $megabytes,
            'effective_bytes' => $bytes,
        ]);
    }

    /**
     * Block the request for the given delay (seconds). Max 60 seconds.
     */
    public function fakeSpeedLoader(float $seconds = 0.05): void
    {
        $seconds = max(0.0, min($seconds, 60.0));

        if ($seconds <= 0.0) {
            Log::debug('FakeLoadService::fakeSpeedLoader skipped', ['seconds' => $seconds]);

            return;
        }

        $microseconds = (int) ($seconds * 1_000_000);
        usleep($microseconds);

        Log::debug('FakeLoadService::fakeSpeedLoader finished', ['seconds' => $seconds]);
    }
}
