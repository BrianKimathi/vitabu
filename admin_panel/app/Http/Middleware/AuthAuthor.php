<?php

namespace App\Http\Middleware;

use Closure;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;

class AuthAuthor
{
    public function handle(Request $request, Closure $next)
    {
        if (Auth::guard('author')->guest()) {
            if (!$request->ajax() || !$request->wantsJson()) {
                return redirect(route('author.login'));
            }
        }
        $response = $next($request);
        return $response;
    }
}
