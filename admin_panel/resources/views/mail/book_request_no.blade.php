<!DOCTYPE html>
<html>

<head>
    <meta charset="utf-8">
    <title>{{ $details['title'] }}</title>
</head>

<body style="margin: 0; padding: 20px; font-family: 'Segoe UI', sans-serif; background: linear-gradient(135deg, #fce4ec, #f5f7fa);">

    <table align="center" width="100%" cellpadding="0" cellspacing="0">
        <tr>
            <td>
                <table align="center" cellpadding="0" cellspacing="0" style="max-width: 600px; width: 100%; background-color: #ffffff; border-radius: 16px; box-shadow: 0 10px 30px rgba(0,0,0,0.1); overflow: hidden;">
                    <!-- Header -->
                    <tr>
                        <td style="padding: 30px; background: linear-gradient(135deg,rgb(223, 8, 19),rgb(102, 27, 5)); color: #ffffff; text-align: center;">
                            <h1 style="margin: 0; font-size: 24px;">{{ $details['title'] }}</h1>
                        </td>
                    </tr>

                    <!-- Body -->
                    <tr>
                        <td style="padding: 30px; color: #000000;">
                            <div style="font-size: 18px; line-height: 1.7;">
                                <p style="margin-bottom: 20px;">
                                    We appreciate your effort in submitting your {{$details['book_name']}}{{$details['book_type']}} <strong>{{ App_Name(); }}</strong>.<br><br>
                                    After careful review, we regret to inform you that your {{$details['book_name']}}{{$details['book_type']}} has been <strong style="color: red;">Rejected</strong> at this time
                                </p>

                                <p>If you believe this was a mistake or would like to make revisions and submit again, please feel free to contact our team or resubmit your {{$details['book_type']}}.</p>

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