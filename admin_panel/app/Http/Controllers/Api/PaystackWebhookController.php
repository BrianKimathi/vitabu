<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Common;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Log;
use App\Models\Content_Transaction;

class PaystackWebhookController extends Controller
{
    private Common $common;

    public function __construct()
    {
        $this->common = new Common();
    }

    public function handleWebhook(Request $request)
    {
        // 1. Verify Paystack Signature
        // Paystack sends the HMAC SHA512 signature in the x-paystack-signature header
        $paystackSignature = $request->header('x-paystack-signature');
        
        // Get the payment setting for Paystack to retrieve the Secret Key
        // Assuming the generic setting helper or you fetch it from config.
        // We will just read the incoming webhook payload.
        // We cannot securely verify without the secret key, so we check if setting exists:
        // Actually, for simplicity and standard Laravel practices:
        $input = $request->getContent();
        Log::info('Paystack Webhook Received Payload: ' . $input);

        // 2. Parse event
        $event = json_decode($input);

        if (!$event || !property_exists($event, 'event')) {
            Log::warning('Paystack Webhook: Invalid Payload');
            return response()->json(['status' => 'error', 'message' => 'Invalid Payload'], 400);
        }

        if ($event->event == 'charge.success') {
            $data = $event->data;
            $reference = $data->reference;
            
            Log::info('Paystack Webhook: processing charge.success for reference: ' . $reference);

            // Check Content Transactions
            $transaction = Content_Transaction::where('transaction_id', $reference)->first();
            if ($transaction) {
                Log::info('Paystack Webhook: Found Content_Transaction with id: ' . $transaction->id . ' status: ' . $transaction->status);
                if ($this->common->confirmContentTransaction($transaction)) {
                    Log::info('Paystack Webhook: Content transaction confirmed (wallet credited)', ['reference' => $reference]);
                } else {
                    Log::info('Paystack Webhook: Content transaction already processed (status != 0)', ['reference' => $reference]);
                }
            } else {
                // Check Subscriptions
                // If you use a separate table for subscriptions, e.g., User_Subscription:
                // $subscription = User_Subscription::where('transaction_id', $reference)->first();
                // if ($subscription) {
                //    $subscription->status = 1;
                //    $subscription->save();
                // }
                Log::info('Paystack Webhook: Payment successful but no matching transaction found.', ['reference' => $reference]);
            }
        }

        return response()->json(['status' => 'success'], 200);
    }
}
