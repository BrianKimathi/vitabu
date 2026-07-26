<!DOCTYPE html>
<html>

<head>
    <meta charset="utf-8">
    <title>{{ $details['title'] }}</title>
</head>

<body style="margin: 0; padding: 20px; font-family: 'Segoe UI', sans-serif; background: linear-gradient(135deg, #f4f4f4, #e0e7ff);">

    <table align="center" width="100%" cellpadding="0" cellspacing="0">
        <tr>
            <td>
                <table align="center" cellpadding="0" cellspacing="0"
                    style="max-width: 600px; width: 100%; background-color: #ffffff; border-radius: 12px; box-shadow: 0 10px 30px rgba(0,0,0,0.1); overflow: hidden;">
                    
                    <!-- Header -->
                    <tr>
                        <td style="padding: 25px; background-color: #4e45b8; color: #ffffff; text-align: center;">
                            <h2 style="margin: 0;">{{ $details['title'] }}</h2>
                        </td>
                    </tr>

                    <!-- Body -->
                    <tr>
                        <td style="padding: 30px; color: #333333;">
                            <div style="font-size: 17px; line-height: 1.6;">
                                <p>Hi {{ $details['username'] ?? 'User' }},</p>

                                <p>
                                    We’ve received your <strong>withdrawal request</strong> on {{ now()->format('d M Y') }}.
                                    Our team will review and process it soon.
                                </p>

                                <p>You’ll be notified once the transaction is complete.</p>

                                <p style="margin-top: 30px;">Thank you,<br><strong>{{ App_Name() }}</strong> Team</p>
                            </div>
                        </td>
                    </tr>

                    <!-- Footer -->
                    <tr>
                        <td style="padding: 20px; background-color: #f8f8f8; text-align: center; font-size: 13px; color: #777;">
                            &copy; {{ date('Y') }} {{ App_Name() }}. All rights reserved.
                        </td>
                    </tr>

                </table>
            </td>
        </tr>
    </table>

</body>

</html>
