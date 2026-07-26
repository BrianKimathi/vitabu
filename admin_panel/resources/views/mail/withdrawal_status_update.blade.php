<!DOCTYPE html>
<html>

<head>
    <meta charset="utf-8">
    <title>{{ $details['title'] }}</title>
</head>

<body style="margin: 0; padding: 20px; font-family: 'Segoe UI', sans-serif; background: linear-gradient(135deg, #f0f4ff, #e8f0fe);">

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
                        <td style="padding: 30px; color: #000000;">
                            <div style="font-size: 17px; line-height: 1.6; color: #000000;">
                                <p>Hi {{ $details['username'] ?? 'Guest' }},</p>

                                <p>
                                    Your withdrawal request has been <strong style="color: {{ $details['status'] === 'Approved' ? 'green' : 'red' }};">{{ ucfirst($details['status']) }}</strong> by the admin.
                                </p>

                                @if($details['status'] === 'Approved')
                                <p>The amount will be credited to your account shortly.</p>
                                @else
                                <p>We regret to inform you that your request has been rejected. Please contact support if you have questions.</p>
                                @endif

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