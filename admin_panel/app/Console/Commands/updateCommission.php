<?php

namespace App\Console\Commands;

use App\Models\General_Setting;
use Illuminate\Console\Command;

class updateCommission extends Command
{
    /**
     * The name and signature of the console command.
     *
     * @var string
     */
    protected $signature = 'app:update-commission';

    /**
     * The console command description.
     *
     * @var string
     */
    protected $description = 'Update Active Commission From Commission';

    /**
     * Execute the console command.
     */
    public function handle()
    {
        $settings = General_Setting::get();
        $config = [];
        foreach ($settings as $item) {
            $config[$item->key] = $item->value;
        }
        $commission = $config['commission'] ?? 0;
        General_Setting::where('key', 'active_commission')->update(['value' => $commission]);

        return Command::SUCCESS;
    }
}
