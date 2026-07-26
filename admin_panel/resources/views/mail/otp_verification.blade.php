<!DOCTYPE html>
<html>

<head>
    <meta charset="utf-8">
    <title>{{ $details['title'] }}</title>
</head>

<body style="margin: 0; padding: 20px; font-family: 'Segoe UI', sans-serif; background: linear-gradient(135deg, #e0e7ff, #f5f7fa);">

    <table align="center" width="100%" cellpadding="0" cellspacing="0">
        <tr>
            <td>
                <table align="center" cellpadding="0" cellspacing="0" style="max-width: 600px; width: 100%; background-color: #ffffff; border-radius: 16px; box-shadow: 0 10px 30px rgba(0,0,0,0.1); overflow: hidden;">
                    <!-- Header -->
                    <tr>
                        <td style="padding: 30px; background: linear-gradient(135deg, #6d5dfc, #4e45b8); color: #ffffff; text-align: center;">
                            <h1 style="margin: 0; font-size: 24px;">{{ $details['title'] }}</h1>
                        </td>
                    </tr>

                    <!-- Body -->
                    <tr>
                        <td style="padding: 30px; color: #000000;">
                            <div style="font-size: 18px; line-height: 1.7;">
                                <p style="margin-bottom: 20px;">
                                    You've requested to become an author on <strong>{{ App_Name(); }}</strong>! 🎉<br><br>
                                    Use the OTP below to verify your email address and complete your author registration.
                                </p>

                                <div style="text-align: center; margin: 30px 0;">
                                    <span style="display: inline-block; padding: 15px 40px; font-size: 32px; font-weight: bold; letter-spacing: 8px; background: #f0f0ff; border-radius: 12px; color: #4e45b8;">
                                        {{ $details['otp'] }}
                                    </span>
                                </div>

                                <p style="margin-bottom: 10px;">This OTP expires in <strong>5 minutes</strong>.</p>

                                <p style="margin-top: 30px;">If you didn't request this, you can safely ignore this email.</p>

                                <p style="margin-top: 30px;">Best regards,<br><strong>{{ App_Name(); }}</strong> Team</p>
                            </div>
                        </td>
                    </tr>

                    <!-- Footer -->
                    <tr>
                        <td style="padding: 20px; background-color: #f8f8f8; text-align: center; font-size: 14px; color: #999;">
                            &copy; {{ date('Y') }} {{ App_Name(); }}. All rights reserved.
                        </td>
                    </tr>
                </table>
            </td>
        </tr>
    </table>

</body>

</html>
