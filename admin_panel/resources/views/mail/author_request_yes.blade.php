<!DOCTYPE html>
<html>

<head>
    <meta charset="utf-8">
    <title>{{ $details['title'] }}</title>
</head>

<body style="margin: 0; padding: 20px; font-family: 'Segoe UI', sans-serif; background: linear-gradient(135deg, #ffe7e7, #f5f7fa);">

    <table align="center" width="100%" cellpadding="0" cellspacing="0">
        <tr>
            <td>
                <table align="center" cellpadding="0" cellspacing="0" style="max-width: 600px; width: 100%; background-color: #ffffff; border-radius: 16px; box-shadow: 0 10px 30px rgba(0,0,0,0.1); overflow: hidden;">
                    <!-- Header -->
                    <tr>
                        <td style="padding: 30px; background: linear-gradient(135deg, #ff0000, #b30000); color: #ffffff; text-align: center;">
                            <h1 style="margin: 0; font-size: 24px;">{{ $details['title'] }}</h1>
                        </td>
                    </tr>

                    <!-- Body -->
                    <tr>
                        <td style="padding: 30px; color: #000000;">
                            <div style="font-size: 18px; line-height: 1.7; color: #000000;">
                                <p style="margin-bottom: 20px;">
                                    Congratulations! 🎉<br><br>
                                    Your request on <strong>{{ App_Name() }}</strong> has been
                                    <strong style="color: #0b8f2f;">Approved</strong>.
                                    You can now access your creator dashboard and start publishing.
                                </p>

                                <p style="margin: 18px 0;">Click below to login and get started:</p>
                                <p style="text-align:center; margin: 25px 0;">
                                    <a href="https://console.vitabu.online/public/author/login"
                                       style="display:inline-block;padding:12px 22px;background:#ff0000;color:#fff;text-decoration:none;border-radius:8px;font-weight:600;">
                                        Open Author Dashboard
                                    </a>
                                </p>

                                <p>We are excited to have you onboard and look forward to your amazing contributions.</p>

                                <p style="margin-top: 30px;">Welcome aboard,<br><strong>{{ App_Name() }}</strong> Team</p>
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