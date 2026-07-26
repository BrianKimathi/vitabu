<?php

namespace App\Http\Middleware;

use Closure;
use Illuminate\Http\Request;

class CheckAdminRole
{
    public function handle(Request $request, Closure $next)
    {
        $user = auth()->guard('admin')->user();
        if (!$user) {
            return $next($request);
        }

        $role = $user->role ?? 'admin';
        if ($role === 'admin') {
            return $next($request);
        }

        $routeName = $request->route() ? $request->route()->getName() : '';
        if (empty($routeName)) {
            return $next($request);
        }

        // 1. Restricted ONLY to super admin
        if (str_starts_with($routeName, 'admin.system.setting') || str_starts_with($routeName, 'admin.subadmin')) {
            return redirect()->route('admin.dashboard')->with('error', 'Only Super-Admins can access this page.');
        }

        // 2. Editor Restrictions
        if ($role === 'editor') {
            $restricted = [
                'admin.salesreport',
                'admin.financereport',
                'admin.coupon',
                'admin.tax',
                'admin.salesnovels',
                'admin.salesmagazines',
                'admin.salesaudiobooks',
                'admin.plan',
                'admin.transaction',
                'admin.subscription_payout',
                'admin.withdrawal',
                'admin.appsetting',
                'admin.payment',
                'admin.admob',
                'admin.notificationconfigurations',
            ];
            foreach ($restricted as $prefix) {
                if (str_starts_with($routeName, $prefix)) {
                    return redirect()->route('admin.dashboard')->with('error', 'Editors do not have access to this financial/configuration page.');
                }
            }
        }

        // 3. Accounts Restrictions
        if ($role === 'accounts') {
            $restricted = [
                'admin.category',
                'admin.language',
                'admin.user',
                'admin.author',
                'admin.authorrequest',
                'admin.novels',
                'admin.novelsection',
                'admin.novels_request',
                'admin.magazines',
                'admin.magazinessection',
                'admin.magazines_request',
                'admin.audiobooks',
                'admin.audiobooksection',
                'admin.audio_books_request',
                'admin.reviews',
                'admin.notification',
                'admin.contact_us',
                'admin.homesection',
                'admin.pages',
                'admin.panelsetting',
            ];
            foreach ($restricted as $prefix) {
                if (str_starts_with($routeName, $prefix)) {
                    return redirect()->route('admin.dashboard')->with('error', 'Accounts users do not have access to this content management page.');
                }
            }
        }

        return $next($request);
    }
}
