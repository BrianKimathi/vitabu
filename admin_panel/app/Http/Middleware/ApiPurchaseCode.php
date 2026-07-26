<?php

namespace App\Http\Middleware;

use Closure;
use Illuminate\Http\Request;
use Exception;
use Illuminate\Support\Facades\Artisan;

class ApiPurchaseCode
{
    public function handle(Request $request, Closure $next)
    {
        try {

            Artisan::call('config:clear');

            $verflyDomain = Demo_Domain();
            if ($verflyDomain == 1) {

                return $next($request);
            } else {

                $pc = env(base64_decode('UFVSQ0hBU0VfQ09ERQ=='));
                $un = env(base64_decode('QlVZRVJfVVNFUk5BTUU='));
                $status = env(base64_decode('UFVSQ0hBU0VfU1RBVFVT'));

                // If the DB is already initialized (admin row exists), skip purchase-code verification.
                $conn = @mysqli_connect(env('DB_HOST'), env('DB_USERNAME'), env('DB_PASSWORD'), env('DB_DATABASE'));
                if ($conn) {
                    try { 
                        $checkTables = @mysqli_query($conn, "SHOW TABLES LIKE 'tbl_admin'");
                        if ($checkTables && mysqli_num_rows($checkTables) > 0) {
                            $countRes = @mysqli_query($conn, "SELECT COUNT(*) AS c FROM tbl_admin");
                            $countRow = $countRes ? mysqli_fetch_assoc($countRes) : null;
                            $count = (int)($countRow['c'] ?? 0);
                            if ($count > 0) {
                                return $next($request);
                            }
                        }
                    } catch (Exception $e) {
                        // Fall back to purchase-code env checks below.
                    }
                }

                if (!empty($pc) && !empty($un) && $status == 1) {
                    return $next($request);
                } else {
                    return response()->json(['status' => 400, 'errors' =>  __('label.purchase_code_is_not_verifly')]);
                }
            }
        } catch (Exception $e) {
            return response()->json(['status' => 400, 'errors' => $e->getMessage()]);
        }
    }
}
