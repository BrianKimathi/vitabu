<?php

namespace App\Console\Commands;

use App\Models\Common;
use App\Models\Transaction;
use Illuminate\Console\Command;

class updatePlan extends Command
{
    /**
     * The name and signature of the console command.
     *
     * @var string
     */
    protected $signature = 'app:update-plan';

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
        $common = new Common();

        $check = $common->BasicNotiConfiguration('plan-status-change');

        // expire transaction
        $active_transactions = Transaction::with(['user:id,device_token', 'plan:id,name'])->where('status', 1)->where('expiry_date', '<=', now())->get();
        foreach ($active_transactions as $transaction) {
            $transaction->update(['status' => 0]);

            $title = "Plan Expired";
            $message = "Your " . $transaction->plan?->name . " plan has expired.";

            if ($check['status'] == 1 && $check['send_notification'] == 1) {
                $common->send_user_push_notification(0, $transaction->user?->device_token, $title, $message);
            }
        }

        // activate upcoming transaction
        $upcoming_transactions = Transaction::with(['user:id,device_token', 'plan:id,name'])->where('status', 2)->where('starts_at', '<=', now())->get();
        foreach ($upcoming_transactions as $transaction) {
            $transaction->update(['status' => 1]);

            $title = "Plan Activated";
            $message = "Your " . $transaction->plan?->name . " plan is now active.";

            if ($check['status'] == 1 && $check['send_notification'] == 1) {
                $common->send_user_push_notification(0, $transaction->user?->device_token, $title, $message);
            }
        }

        return Command::SUCCESS;
    }
}
