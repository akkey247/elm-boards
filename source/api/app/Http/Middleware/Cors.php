<?php

namespace App\Http\Middleware;

use Illuminate\Support\Facades\Log;
use Closure;

class Cors
{
    /**
     * Handle an incoming request.
     *
     * @param  \Illuminate\Http\Request  $request
     * @param  \Closure  $next
     * @return mixed
     */
    public function handle($request, Closure $next)
    {   
        $response = $next($request);

        $http_origin = isset($_SERVER['HTTP_ORIGIN']) ? $_SERVER['HTTP_ORIGIN'] : "";

        Log::debug("http_origin = " . $http_origin);
        if ($http_origin == "http://localhost:8080") {
            $response
                ->header("Access-Control-Allow-Origin" , "http://localhost:8080")
                ->header('Access-Control-Allow-Methods', 'GET, POST, PUT, DELETE, OPTIONS')
                ->header('Access-Control-Allow-Headers', 'Authorization, Content-Type');
        }

        return $response;
    }
}