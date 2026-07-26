<!DOCTYPE html>
<html>

<head>
    <meta charset="utf-8">
    <title>{{ $details['title'] }}</title>
</head>

<body style="margin: 0; padding: 20px; font-family: 'Segoe UI', sans-serif; background: linear-gradient(135deg, #e0f7ff, #f5f7fa);">

    <table align="center" width="100%" cellpadding="0" cellspacing="0">
        <tr>
            <td>
                <table align="center" cellpadding="0" cellspacing="0"
                    style="max-width: 600px; width: 100%; background-color: #ffffff; border-radius: 16px; box-shadow: 0 10px 30px rgba(0,0,0,0.1); overflow: hidden;">

                    <!-- Header -->
                    <tr>
                        <td
                            style="padding: 30px; background: linear-gradient(135deg, #4caf50, #388e3c); color: #ffffff; text-align: center;">
                            <h1 style="margin: 0; font-size: 24px;">
                                {{ $details['title'] }}
                            </h1>
                        </td>
                    </tr>

                    <!-- Body -->
                    <tr>
                        <td style="padding: 30px; color: #000000;">
                            <div style="font-size: 18px; line-height: 1.7; color: #000000;">

                                <p style="margin-bottom: 20px;">
                                    Hi {{ $details['user_name'] ?? '' }},<br><br>
                                    We’re happy to inform you that your <strong>subscription payout</strong> has been
                                    successfully processed on <strong>{{ App_Name(); }}</strong>. 💰
                                </p>

                                <p style="margin-bottom: 15px;">
                                    Here are the payout details:
                                </p>

                                <ul style="font-size: 16px; padding-left: 20px;">
                                    <li><strong>Total Earnings:</strong> {{Currency_Code()}}{{ $details['payout'] ?? '-' }}</li>
                                    <li><strong>Subscription Earnings:</strong> {{Currency_Code()}}{{ $details['subscription_earnings'] ?? '-' }}</li>
                                    <li><strong>Content Earnings:</strong> {{Currency_Code()}}{{ $details['content_earnings'] ?? '-' }}</li>
                                    <li><strong>Payout Period:</strong> {{ $details['payout_period'] ?? '-' }}</li>
                                    <li><strong>Payout Date:</strong> {{ $details['payout_date'] ?? date('d M Y') }}</li>
                                </ul>

                                <p style="margin-top: 20px;">
                                    The amount has been credited in your bank account.
                                </p>

                                <p style="margin-top: 30px;">
                                    Thank you for being a valued creator on our platform.<br>
                                    <strong>{{ App_Name(); }}</strong> Team
                                </p>

                            </div>
                        </td>
                    </tr>

                    <!-- Footer -->
                    <tr>
                        <td
                            style="padding: 20px; background-color: #f8f8f8; text-align: center; font-size: 14px; color: #999;">
                            &copy; {{ date('Y') }} {{ App_Name(); }}. All rights reserved.
                        </td>
                    </tr>

                </table>
            </td>
        </tr>
    </table>

</body>

</html>