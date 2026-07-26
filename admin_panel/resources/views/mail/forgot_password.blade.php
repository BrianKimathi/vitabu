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
                <table align="center" cellpadding="0" cellspacing="0"
                    style="max-width: 600px; width: 100%; background-color: #ffffff; border-radius: 12px; 
           box-shadow: 0 8px 25px rgba(0,0,0,0.08); overflow: hidden; font-family: Arial, sans-serif;">

                    <!-- Header -->
                    <tr>
                        <td style="padding: 30px; background: linear-gradient(135deg, #6d5dfc, #4e45b8); color: #ffffff; text-align: center;">
                            <h1 style="margin: 0; font-size: 24px;">{{ $details['title'] }}</h1>
                        </td>
                    </tr>

                    <!-- Body -->
                    <tr>
                        <td style="padding: 30px; color: #000000;">
                            <div style="font-size: 16px; line-height: 1.6;">
                                <p style="margin-bottom: 20px;">
                                    Hello <strong>{{ $details['email'] }}</strong>,
                                </p>

                                <p style="margin-bottom: 20px;">
                                    A new password has been generated for your <strong>{{ App_Name(); }}</strong> account.
                                    Please use the password below to log in:
                                </p>

                                <p style="text-align: center; margin: 25px 0;">
                                    <span style="display: inline-block; background-color: #f4f4f4; 
                                 padding: 12px 20px; border-radius: 8px; font-size: 18px; 
                                 font-weight: bold; letter-spacing: 1px; color: #333;">
                                        {{ $details['password'] }}
                                    </span>
                                </p>

                                <p style="margin-bottom: 20px;">
                                    For security reasons, we recommend changing your password immediately after logging in.
                                </p>

                                <p style="margin-top: 30px;">
                                    Best regards,<br>
                                    <strong>{{ App_Name(); }} Team</strong>
                                </p>
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