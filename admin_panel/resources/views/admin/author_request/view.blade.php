@extends('admin.layout.page-app')
@section('page_title', 'Author Request Details')
@section('tab_title', 'Author Request Details')

@section('content')
@include('admin.layout.sidebar')

<div class="right-content">
    @include('admin.layout.header')

    <div class="body-content">
        <h1 class="page-title-sm">Author Request Details</h1>

        <div class="border-bottom row mb-3">
            <div class="col-sm-10">
                <ol class="breadcrumb" style="background:transparent;padding:0;">
                    <li class="breadcrumb-item"><a href="{{ route('admin.dashboard') }}" style="color:#4E45B8;">{{__('label.dashboard')}}</a></li>
                    <li class="breadcrumb-item"><a href="{{ route('admin.authorrequest.index') }}" style="color:#4E45B8;">{{__('label.author_request')}}</a></li>
                    <li class="breadcrumb-item active" aria-current="page" style="color:#6B7280;">Details</li>
                </ol>
            </div>
            <div class="col-sm-2 d-flex align-items-center justify-content-end">
                <a href="{{ route('admin.authorrequest.index') }}" class="btn" style="background:#EEF0FF;color:#4E45B8;font-weight:600;border-radius:10px;">
                    <i class="fa-solid fa-arrow-left mr-1"></i> Back
                </a>
            </div>
        </div>

        @php
            $req = $request;
            $user = $req['user'] ?? null;
        @endphp

        <!-- ============================================================
             User Info Card
        ============================================================ -->
        <div class="card border-0 shadow-sm mb-4" style="border-radius:14px;">
            <div class="card-body p-4">
                <div class="row">
                    <div class="col-auto">
                        <div style="width:72px;height:72px;border-radius:50%;overflow:hidden;border:3px solid #EEF0FF;">
                            <img src="{{ $req['user_image'] ?? asset('assets/imgs/default.png') }}" style="width:100%;height:100%;object-fit:cover;">
                        </div>
                    </div>
                    <div class="col">
                        <h5 class="font-weight-bold mb-1" style="color:#1F2937;">
                            {{ ($user->first_name ?? '') . ' ' . ($user->last_name ?? '') ?: ($user->user_name ?? 'Unknown') }}
                        </h5>
                        <div style="color:#6B7280;font-size:14px;">{{ $user->email ?? '-' }}</div>
                        <div style="color:#6B7280;font-size:14px;">{{ $user->mobile_number ?? '-' }}</div>
                    </div>
                    <div class="col-auto text-right">
                        <span class="badge mb-2" style="background:#EEF0FF;color:#4E45B8;font-size:13px;font-weight:600;padding:5px 16px;border-radius:8px;">
                            {{ ucfirst($req->role ?? 'author') }}
                        </span>
                        <br>
                        <span class="badge" style="background:{{ ($req->is_otp_verified ?? 0) == 1 ? '#E8F5E9' : '#FFF8E5' }};color:{{ ($req->is_otp_verified ?? 0) == 1 ? '#2E7D32' : '#F5A623' }};font-size:12px;font-weight:600;padding:4px 12px;border-radius:6px;">
                            OTP: {{ ($req->is_otp_verified ?? 0) == 1 ? 'Verified' : 'Pending' }}
                        </span>
                        <br>
                        <span style="font-size:12px;color:#9CA3AF;">Requested: {{ date('M d, Y', strtotime($req->created_at)) }}</span>
                    </div>
                </div>
            </div>
        </div>

        <div class="row">
            <!-- ============================================================
                 Payment Details
            ============================================================ -->
            <div class="col-md-6 mb-4">
                <div class="card border-0 shadow-sm h-100" style="border-radius:14px;">
                    <div class="card-body p-4">
                        <h6 class="font-weight-bold mb-3" style="color:#1F2937;">
                            <i class="fa-solid fa-credit-card mr-2" style="color:#4E45B8;"></i>
                            Payment Details
                        </h6>
                        <table style="width:100%;font-size:14px;">
                            <tr>
                                <td style="padding:6px 0;color:#6B7280;width:140px;">Method</td>
                                <td style="padding:6px 0;color:#1F2937;font-weight:500;">
                                    <span class="badge" style="background:#EEF0FF;color:#4E45B8;font-size:12px;padding:3px 12px;border-radius:6px;">
                                        {{ ucfirst($req->payment_method ?? 'bank') }}
                                    </span>
                                </td>
                            </tr>
                            @if(($req->payment_method ?? 'bank') === 'bank')
                            <tr>
                                <td style="padding:6px 0;color:#6B7280;">Bank Name</td>
                                <td style="padding:6px 0;color:#1F2937;font-weight:500;">{{ $req->bank_name ?: '-' }}</td>
                            </tr>
                            <tr>
                                <td style="padding:6px 0;color:#6B7280;">Bank Code</td>
                                <td style="padding:6px 0;color:#1F2937;font-weight:500;">{{ $req->bank_code ?: '-' }}</td>
                            </tr>
                            <tr>
                                <td style="padding:6px 0;color:#6B7280;">Account No.</td>
                                <td style="padding:6px 0;color:#1F2937;font-weight:500;">{{ $req->account_no ?: '-' }}</td>
                            </tr>
                            <tr>
                                <td style="padding:6px 0;color:#6B7280;">Holder Name</td>
                                <td style="padding:6px 0;color:#1F2937;font-weight:500;">{{ $req->bank_holder_name ?: '-' }}</td>
                            </tr>
                            <tr>
                                <td style="padding:6px 0;color:#6B7280;">IFSC Code</td>
                                <td style="padding:6px 0;color:#1F2937;font-weight:500;">{{ $req->ifsc_code ?: '-' }}</td>
                            </tr>
                            @else
                            <tr>
                                <td style="padding:6px 0;color:#6B7280;">M-Pesa Phone</td>
                                <td style="padding:6px 0;color:#1F2937;font-weight:500;">{{ $req->mpesa_phone ?: '-' }}</td>
                            </tr>
                            @endif
                            @if($req->subaccount_code)
                            <tr>
                                <td style="padding:6px 0;color:#6B7280;">Subaccount Code</td>
                                <td style="padding:6px 0;color:#1F2937;font-weight:500;">
                                    <code style="background:#F3F4F6;padding:2px 8px;border-radius:4px;font-size:12px;">{{ $req->subaccount_code }}</code>
                                </td>
                            </tr>
                            @endif
                        </table>
                    </div>
                </div>
            </div>

            <!-- ============================================================
                 KYC Documents
            ============================================================ -->
            <div class="col-md-6 mb-4">
                <div class="card border-0 shadow-sm h-100" style="border-radius:14px;">
                    <div class="card-body p-4">
                        <h6 class="font-weight-bold mb-3" style="color:#1F2937;">
                            <i class="fa-solid fa-folder-open mr-2" style="color:#4E45B8;"></i>
                            {{ ($req->role ?? '') === 'publisher' ? 'Publisher Verification Documents' : 'KYC Documents' }}
                        </h6>
                        <div class="row">
                            <div class="col-4 text-center">
                                <div style="background:#F8F9FF;border-radius:12px;padding:12px;border:1px solid #EEF0FF;min-height:120px;">
                                    @if($req['id_front_url'])
                                        <a href="{{ $req['id_front_url'] }}" target="_blank">
                                            <img src="{{ $req['id_front_url'] }}" style="width:100%;height:80px;object-fit:cover;border-radius:8px;">
                                        </a>
                                    @else
                                        <div style="height:80px;display:flex;align-items:center;justify-content:center;color:#D1D5DB;">
                                            <i class="fa-solid fa-image fa-2x"></i>
                                        </div>
                                    @endif
                                    <div style="font-size:11px;color:#6B7280;margin-top:6px;font-weight:500;">
                                        {{ ($req->role ?? '') === 'publisher' ? 'Reg Certificate' : 'ID Front' }}
                                    </div>
                                </div>
                            </div>
                            <div class="col-4 text-center">
                                <div style="background:#F8F9FF;border-radius:12px;padding:12px;border:1px solid #EEF0FF;min-height:120px;">
                                    @if($req['id_back_url'])
                                        <a href="{{ $req['id_back_url'] }}" target="_blank">
                                            <img src="{{ $req['id_back_url'] }}" style="width:100%;height:80px;object-fit:cover;border-radius:8px;">
                                        </a>
                                    @else
                                        <div style="height:80px;display:flex;align-items:center;justify-content:center;color:#D1D5DB;">
                                            <i class="fa-solid fa-image fa-2x"></i>
                                        </div>
                                    @endif
                                    <div style="font-size:11px;color:#6B7280;margin-top:6px;font-weight:500;">
                                        {{ ($req->role ?? '') === 'publisher' ? 'KRA Pin' : 'ID Back' }}
                                    </div>
                                </div>
                            </div>
                            <div class="col-4 text-center">
                                <div style="background:#F8F9FF;border-radius:12px;padding:12px;border:1px solid #EEF0FF;min-height:120px;">
                                    @if($req['selfie_url'])
                                        <a href="{{ $req['selfie_url'] }}" target="_blank">
                                            <img src="{{ $req['selfie_url'] }}" style="width:100%;height:80px;object-fit:cover;border-radius:8px;">
                                        </a>
                                    @else
                                        <div style="height:80px;display:flex;align-items:center;justify-content:center;color:#D1D5DB;">
                                            <i class="fa-solid fa-camera fa-2x"></i>
                                        </div>
                                    @endif
                                    <div style="font-size:11px;color:#6B7280;margin-top:6px;font-weight:500;">
                                        {{ ($req->role ?? '') === 'publisher' ? 'Rep. ID' : 'Selfie' }}
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>

        <!-- ============================================================
             Actions
        ============================================================ -->
        <div class="card border-0 shadow-sm" style="border-radius:14px;">
            <div class="card-body p-4">
                <h6 class="font-weight-bold mb-3" style="color:#1F2937;">
                    <i class="fa-solid fa-gavel mr-2" style="color:#4E45B8;"></i>
                    Review Decision
                </h6>
                <p style="color:#6B7280;font-size:14px;">
                    Review this author request and approve or reject it. The applicant will be notified via email.
                </p>
                <div class="d-flex gap-3" style="gap:12px;">
                    <button type="button" class="btn" style="background:#E8F5E9;color:#2E7D32;font-weight:600;padding:8px 28px;border-radius:10px;border:none;" onclick="change_status({{ $req->id }}, 1)">
                        <i class="fa-solid fa-check mr-1"></i> Approve Request
                    </button>
                    <button type="button" class="btn" style="background:#FFF0EE;color:#E54B4B;font-weight:600;padding:8px 28px;border-radius:10px;border:none;" onclick="change_status({{ $req->id }}, 0)">
                        <i class="fa-solid fa-xmark mr-1"></i> Reject Request
                    </button>
                </div>
            </div>
        </div>

    </div>
</div>
@endsection

@section('pagescript')
<script>
    function change_status(id, status) {
        var Demo_Mode = '<?php echo Demo_Mode(); ?>';
        if(Demo_Mode == 1){
            $("#dvloader").show();
            var url = "{{route('admin.authorrequest.show', '')}}" + "/" + id;
            $.ajax({
                type: "GET",
                url: url,
                headers: { 'X-CSRF-TOKEN': $('meta[name="csrf-token"]').attr('content') },
                data: { id: id, status: status },
                success: function(resp) {
                    $("#dvloader").hide();
                    get_responce_message(resp, '', '{{ route("admin.authorrequest.index") }}');
                },
                error: function(XMLHttpRequest, textStatus, errorThrown) {
                    $("#dvloader").hide();
                    toastr.error(errorThrown, textStatus);
                }
            });
        } else {
            showError();
        }
    };
</script>
@endsection