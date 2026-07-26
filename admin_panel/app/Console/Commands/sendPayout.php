<?php

namespace App\Console\Commands;

use App\Models\Author_Payout;
use App\Models\Content_Transaction;
use App\Models\General_Setting;
use App\Models\History;
use App\Models\Transaction;
use App\Models\User;
use Carbon\Carbon;
use Illuminate\Console\Command;

class sendPayout extends Command
{
    /**
     * The name and signature of the console command.
     *
     * @var string
     */
    protected $signature = 'app:send-payout';

    /**
     * The console command description.
     *
     * @var string
     */
    protected $description = 'Command description';

    /**
     * Execute the console command.
     */
    public function handle()
    {
        // previous month data
        $start_date = now()->subMonth()->startOfMonth();
        $end_date = now()->subMonth()->endOfMonth();
        $current_month = $start_date->month;
        $current_year = $start_date->year;
        $total_amount = 0;

        // if already payed for this month return
        if (Author_Payout::where('payout_month', $current_month)->where('payout_year', $current_year)->exists()) {
            return Command::SUCCESS;
        }

        // For subscription payout, use a hardcoded 40/60 split (40% to admin, 60% pool shared among authors)
        $commission = 40;

        //calcuate total amount based on users which have active transaction in this period
        $activeSubscriptions = Transaction::where(function ($q) use ($start_date, $end_date) {
            $q->whereBetween('starts_at', [$start_date, $end_date])
                ->orWhereBetween('expiry_date', [$start_date, $end_date])
                ->orWhere(function ($d) use ($start_date, $end_date) {
                    $d->where('starts_at', '<=', $start_date)
                        ->where('expiry_date', '>=', $end_date);
                });
        })->get();
        foreach ($activeSubscriptions as $sub) {
            $sub_start = Carbon::parse($sub['starts_at']);
            $sub_end = Carbon::parse($sub['expiry_date']);

            $total_seconds = $sub_start->diffInSeconds($sub_end);

            $active_from = $sub_start->max($start_date);
            $active_to = $sub_end->min($end_date);
            $active_seconds = $active_from->lte($active_to)
                ? $active_from->diffInSeconds($active_to)
                : 0;

            if ($total_seconds <= 0) {
                $earned = 0;
            } else {
                $earned = $sub->price * $active_seconds / $total_seconds;
            }

            $total_amount += $earned;
        }

        //calculate admin and author amount
        $admin_amount  = $total_amount * $commission / 100;
        $author_amount = $total_amount - $admin_amount;

        // read history
        $history_data = History::where('is_subscription', 1)->where('activity_month', $current_month)->where('activity_year', $current_year)->groupBy('author_id')->selectRaw('author_id,SUM(time_spend) as total_time')->get();
        $authors_history_data = $history_data->pluck('total_time', 'author_id');
        $total_read_time = $history_data->sum('total_time');

        // book purchase history
        $content_data = Content_Transaction::where('status', 1)->whereYear('created_at', $current_year)->whereMonth('created_at', $current_month)->groupBy('author_id')->selectRaw('author_id,SUM(author_earning) as content_earnings')->get();
        $author_content_data = $content_data->pluck('content_earnings', 'author_id');

        // get all authors ids with author payout and content transaction
        $author_ids = array_unique(array_merge($history_data->pluck('author_id')->toArray(), $content_data->pluck('author_id')->toArray()));

        $author_payout_ids = [];
        $paid_to_authors = 0;
        foreach ($author_ids as $author_id) {

            $author = User::where('is_author', 1)->where('id', $author_id)->first();
            if (!$author) {
                continue;
            }

            // get this author data from whole array
            $author_read_time = $authors_history_data->get($author_id, 0);
            $content_earnings = floor($author_content_data->get($author_id, 0));

            if ($total_read_time <= 0) {
                $author_payout = 0;
            } else {
                $author_payout = floor(($author_read_time * $author_amount) / $total_read_time);
            }

            $paid_to_authors += $author_payout;

            $author_payout_ids[] = Author_Payout::insertGetId([
                'author_id' => $author_id,
                'total_read_time' => $author_read_time,
                'gross_earning' => $total_amount,
                'admin_commission' => $admin_amount,
                'total_payable_amount' => $author_amount,
                'author_payable_amount' => $author_payout,
                'content_earnings' => $content_earnings,
                'payout_month' => $current_month,
                'payout_year' => $current_year,
                'status' => 0
            ]);
        }

        // add the extra amount to admin and remove from author
        $admin_amount += $author_amount - $paid_to_authors;
        $author_amount = $paid_to_authors;

        Author_Payout::whereIn('id', $author_payout_ids)->update([
            'admin_commission' => $admin_amount,
            'total_payable_amount' => $author_amount,
        ]);

        return Command::SUCCESS;
    }
}
