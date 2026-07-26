@extends('admin.layout.page-app')
@section('page_title', __('label.author_request'))
@section('tab_title', __('label.author_request'))

@section('content')
@include('admin.layout.sidebar')

<div class="right-content">
    @include('admin.layout.header')

    <div class="body-content">
        <!-- mobile title -->
        <h1 class="page-title-sm">{{__('label.author_request')}}</h1>

        <div class="card border-0 shadow-sm" style="border-radius:14px;">
            <div class="card-body p-4">
                <div class="d-flex justify-content-between align-items-center mb-3">
                    <h5 class="mb-0 font-weight-bold" style="color:#1F2937;">
                        <i class="fa-solid fa-user-clock mr-2" style="color:#4E45B8;"></i>
                        {{__('label.author_request')}}
                    </h5>
                </div>

                <div class="table-responsive">
                    <table class="table table-hover" id="datatable" style="min-width:800px;">
                        <thead>
                            <tr style="background:#F8F9FF;">
                                <th style="border:none;font-size:13px;font-weight:600;color:#6B7280;">#</th>
                                <th style="border:none;font-size:13px;font-weight:600;color:#6B7280;">{{__('label.name')}}</th>
                                <th style="border:none;font-size:13px;font-weight:600;color:#6B7280;">{{__('label.contact')}}</th>
                                <th style="border:none;font-size:13px;font-weight:600;color:#6B7280;">Role</th>
                                <th style="border:none;font-size:13px;font-weight:600;color:#6B7280;">Payment</th>
                                <th style="border:none;font-size:13px;font-weight:600;color:#6B7280;">OTP</th>
                                <th style="border:none;font-size:13px;font-weight:600;color:#6B7280;">KYC</th>
                                <th style="border:none;font-size:13px;font-weight:600;color:#6B7280;">{{__('label.date')}}</th>
                                <th style="border:none;font-size:13px;font-weight:600;color:#6B7280;">{{__('label.action')}}</th>
                            </tr>
                        </thead>
                        <tbody></tbody>
                    </table>
                </div>
            </div>
        </div>
    </div>
</div>
@endsection

@section('pagescript')
<script>
    $(document).ready(function() {
        var table = $('#datatable').DataTable({
            ...dataTableDefaults,
            ajax: "{{ route('admin.authorrequest.index') }}",
            columns: [
                { data: 'DT_RowIndex', name: 'DT_RowIndex', orderable: false, searchable: false },
                {
                    data: 'name',
                    name: 'name',
                    render: function(data, type, row) {
                        if (!row.user) return '-';
                        const img = row.image || '{{ asset("assets/imgs/default.png") }}';
                        const name = (row.user.first_name ?? '') + ' ' + (row.user.last_name || '');
                        const uname = row.user.user_name || '';
                        return `
                            <div class="d-flex align-items-center" style="gap:10px;">
                                <img src="${img}" style="width:36px;height:36px;border-radius:50%;object-fit:cover;">
                                <div>
                                    <div style="font-weight:600;color:#1F2937;font-size:14px;">${name || uname}</div>
                                    <div style="font-size:12px;color:#9CA3AF;">@${uname}</div>
                                </div>
                            </div>
                        `;
                    }
                },
                {
                    data: 'contact',
                    name: 'contact',
                    render: function(data, type, row) {
                        if (!row.user) return '-';
                        return `
                            <div>
                                <div style="font-size:13px;color:#1F2937;">${row.user.email || '-'}</div>
                                <div style="font-size:12px;color:#6B7280;">${row.user.mobile_number || '-'}</div>
                            </div>
                        `;
                    }
                },
                {
                    data: 'role',
                    name: 'role',
                    render: function(data) {
                        const role = data ? data.charAt(0).toUpperCase() + data.slice(1) : 'Author';
                        return `<span class="badge" style="background:#EEF0FF;color:#4E45B8;font-size:12px;font-weight:600;padding:4px 12px;border-radius:6px;">${role}</span>`;
                    }
                },
                {
                    data: 'payment_method',
                    name: 'payment_method',
                    render: function(data) {
                        if (!data) return '-';
                        const method = data.charAt(0).toUpperCase() + data.slice(1);
                        return `<span style="font-size:13px;color:#1F2937;">${method}</span>`;
                    }
                },
                {
                    data: 'otp_verified_text',
                    name: 'is_otp_verified',
                    orderable: false,
                    searchable: false
                },
                {
                    data: 'kyc_docs',
                    name: 'kyc_docs',
                    orderable: false,
                    searchable: false
                },
                {
                    data: 'date',
                    name: 'date',
                    render: function(data) { return data ? data : '-'; }
                },
                {
                    data: 'action',
                    name: 'action',
                    orderable: false,
                    searchable: false
                },
            ],
            columnDefs: [
                { targets: '_all', className: 'align-middle' }
            ],
            dom: "<'row mb-3'<'col-sm-12 col-md-6'l><'col-sm-12 col-md-6'f>>" +
                 "<'row'<'col-sm-12'tr>>" +
                 "<'row mt-3'<'col-sm-12 col-md-5'i><'col-sm-12 col-md-7'p>>",
        });
    });

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