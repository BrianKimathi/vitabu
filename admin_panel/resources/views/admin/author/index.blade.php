@extends('admin.layout.page-app')
@section('page_title', __('label.authors'))
@section('tab_title', __('label.authors'))

@section('content')
@include('admin.layout.sidebar')

<div class="right-content">
    @include('admin.layout.header')

    <div class="body-content">
        <h1 class="page-title-sm">{{__('label.authors')}}</h1>

        <div class="card border-0 shadow-sm mb-3" style="border-radius:12px;">
            <div class="card-body p-3">
                <div class="d-flex flex-wrap align-items-center justify-content-between" style="gap:12px;">
                    <div class="d-flex align-items-center" style="gap:8px;flex-wrap:wrap;">
                        <div class="input-group" style="width:220px;">
                            <div class="input-group-prepend">
                                <span class="input-group-text" style="background:#F9FAFB;border:1px solid #E5E7EB;border-right:none;border-radius:8px 0 0 8px;">
                                    <i class="fa-solid fa-magnifying-glass" style="color:#9CA3AF;font-size:14px;"></i>
                                </span>
                            </div>
                            <input type="text" id="input_search" class="form-control" placeholder="{{__('label.search')}}" style="border-left:none;border-radius:0 8px 8px 0;">
                        </div>
                        <select class="form-control" id="input_type" style="width:140px;">
                            <option value="all">{{__('label.all')}}</option>
                            <option value="today">{{__('label.today')}}</option>
                            <option value="month">{{__('label.month')}}</option>
                            <option value="year">{{__('label.year')}}</option>
                        </select>
                        <select class="form-control" id="input_login_type" style="width:140px;">
                            <option value="all">{{__('label.all_login_type')}}</option>
                            <option value="1">OTP</option>
                            <option value="2">Google</option>
                            <option value="3">Apple</option>
                            <option value="4">Normal</option>
                        </select>
                    </div>
                    <div class="d-flex" style="gap:6px;">
                        <button id="ms_excel" class="btn btn-sm" style="background:#E8F5E9;color:#2E7D32;font-weight:600;border-radius:8px;">
                            <i class="fa-solid fa-file-excel mr-1"></i> Excel
                        </button>
                        <button id="csv" class="btn btn-sm" style="background:#EEF0FF;color:#4E45B8;font-weight:600;border-radius:8px;">
                            <i class="fa-solid fa-file-csv mr-1"></i> CSV
                        </button>
                        <button id="pdf" class="btn btn-sm" style="background:#FFF0EE;color:#E54B4B;font-weight:600;border-radius:8px;">
                            <i class="fa-solid fa-file-pdf mr-1"></i> PDF
                        </button>
                        <a href="{{ route('admin.author.create') }}" class="btn btn-sm" style="background:#4E45B8;color:#fff;font-weight:600;border-radius:8px;">
                            <i class="fa-solid fa-plus mr-1"></i> {{__('label.add_authors')}}
                        </a>
                    </div>
                </div>
            </div>
        </div>

        <div class="card border-0 shadow-sm" style="border-radius:12px;">
            <div class="card-body p-3">
                <div class="table-responsive">
                    <table class="table table-hover" id="datatable" style="min-width:900px;">
                        <thead>
                            <tr>
                                <th style="font-size:12px;font-weight:600;color:#6B7280;border-bottom:1px solid #F3F4F6;padding:10px 12px;">#</th>
                                <th style="font-size:12px;font-weight:600;color:#6B7280;border-bottom:1px solid #F3F4F6;padding:10px 12px;">{{__('label.image')}}</th>
                                <th style="font-size:12px;font-weight:600;color:#6B7280;border-bottom:1px solid #F3F4F6;padding:10px 12px;">{{__('label.name')}}</th>
                                <th style="font-size:12px;font-weight:600;color:#6B7280;border-bottom:1px solid #F3F4F6;padding:10px 12px;">{{__('label.contact')}}</th>
                                <th style="font-size:12px;font-weight:600;color:#6B7280;border-bottom:1px solid #F3F4F6;padding:10px 12px;">{{__('label.wallet_amount')}}</th>
                                <th style="font-size:12px;font-weight:600;color:#6B7280;border-bottom:1px solid #F3F4F6;padding:10px 12px;">{{__('label.register_date')}}</th>
                                <th style="font-size:12px;font-weight:600;color:#6B7280;border-bottom:1px solid #F3F4F6;padding:10px 12px;">{{__('label.login_type')}}</th>
                                <th style="font-size:12px;font-weight:600;color:#6B7280;border-bottom:1px solid #F3F4F6;padding:10px 12px;">{{__('label.status')}}</th>
                                <th style="font-size:12px;font-weight:600;color:#6B7280;border-bottom:1px solid #F3F4F6;padding:10px 12px;">{{__('label.action')}}</th>
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
<script src="https://cdnjs.cloudflare.com/ajax/libs/jszip/3.1.3/jszip.min.js"></script>
<script src="https://cdn.datatables.net/buttons/1.3.1/js/buttons.html5.min.js"></script>
<script src="https://cdn.datatables.net/buttons/1.4.2/js/dataTables.buttons.min.js"></script>
<script src="https://cdnjs.cloudflare.com/ajax/libs/pdfmake/0.1.32/pdfmake.min.js"></script>
<script src="https://cdnjs.cloudflare.com/ajax/libs/pdfmake/0.1.32/vfs_fonts.js"></script>

<script>
    $(document).ready(function() {
        var table = $('#datatable').DataTable({
            ...dataTableDefaults,
            ajax: {
                url: "{{ route('admin.author.index') }}",
                data: function(d) {
                    d.input_type = $('#input_type').val();
                    d.input_login_type = $('#input_login_type').val();
                    d.input_search = $('#input_search').val();
                },
            },
            columns: [
                { data: 'DT_RowIndex', name: 'DT_RowIndex', orderable: false, searchable: false },
                {
                    data: 'image', name: 'image', orderable: false, searchable: false,
                    render: function(data) {
                        return "<a href='" + data + "' target='_blank'><img src='" + data + "' style='width:36px;height:36px;border-radius:50%;object-fit:cover;'></a>";
                    },
                },
                {
                    data: 'name', name: 'name',
                    render: function(data, type, row) {
                        return `<div style="font-weight:600;color:#1F2937;font-size:14px;">${row.first_name || ''} ${row.last_name || ''}</div><div style="font-size:12px;color:#9CA3AF;">@${row.user_name || ''}</div>`;
                    }
                },
                {
                    data: 'email', name: 'email',
                    render: function(data, type, row) {
                        return `<div style="font-size:13px;color:#1F2937;">${row.email || '-'}</div><div style="font-size:12px;color:#6B7280;">${row.mobile_number || '-'}</div>`;
                    }
                },
                {
                    data: 'wallet_amount', name: 'wallet_amount', orderable: false, searchable: false,
                    render: function(data) {
                        return `<span style="font-weight:700;color:#4E45B8;">${data || '0'}</span>`;
                    }
                },
                {
                    data: 'date', name: 'date',
                    render: function(data) { return data ? data : '-'; }
                },
                {
                    data: 'type', name: 'type', orderable: false, searchable: false,
                    render: function(data) {
                        const icons = {1:'fa-solid fa-mobile-screen',2:'fa-brands fa-google',3:'fa-brands fa-apple',4:'fa-solid fa-lock'};
                        const labels = {1:'OTP',2:'Google',3:'Apple',4:'Normal'};
                        const icon = icons[data] || 'fa-solid fa-question';
                        return `<span class="badge" style="background:#EEF0FF;color:#4E45B8;font-size:11px;padding:4px 10px;border-radius:6px;"><i class="${icon} mr-1" style="font-size:11px;"></i> ${labels[data] || '-'}</span>`;
                    }
                },
                {
                    data: 'status', name: 'status', orderable: false, searchable: false
                },
                {
                    data: 'action', name: 'action', orderable: false, searchable: false
                },
            ],
            columnDefs: [{ targets: '_all', className: 'align-middle' }],
            buttons: [
                {
                    extend: 'excel', filename: "{{App_Name()}} - {{__('label.authors')}}",
                    exportOptions: { columns: [0, 2, 3, 4, 6] },
                },
                {
                    extend: 'csv', filename: "{{App_Name()}} - {{__('label.authors')}}",
                    exportOptions: { columns: [0, 2, 3, 4, 6] },
                },
                {
                    extend: 'pdf', title: "{{App_Name()}} - {{__('label.authors')}}",
                    filename: "{{App_Name()}} - {{__('label.authors')}}",
                    pageSize: 'A4',
                    exportOptions: { columns: [0, 2, 3, 4, 6] },
                    customize: function(doc) {
                        doc.styles.tableHeader.fontSize = 10;
                        doc.defaultStyle.fontSize = 8;
                        doc.content[1].table.widths = ['5%', '20%', '25%', '20%', '15%', '15%'];
                        doc.styles.title.fontSize = 22;
                        doc.styles.title.alignment = 'center';
                        doc.defaultStyle.alignment = 'center';
                    }
                }
            ],
        });

        $('#ms_excel').on('click', function() { if('{{Demo_Mode()}}'==1) { table.button('0').trigger(); } else { showError(); } });
        $('#csv').on('click', function() { if('{{Demo_Mode()}}'==1) { table.button('1').trigger(); } else { showError(); } });
        $('#pdf').on('click', function() { if('{{Demo_Mode()}}'==1) { table.button('2').trigger(); } else { showError(); } });

        $('#input_type, #input_login_type').change(function() { table.draw(); });
        $('#input_search').keyup(function() { table.draw(); });
    });

    function change_status(id) {
        var Demo_Mode = '<?php echo Demo_Mode(); ?>';
        if(Demo_Mode == 1) {
            $("#dvloader").show();
            $.ajax({
                type: "GET",
                url: `{{ route('admin.author.show', '') }}/${id}`,
                headers: { 'X-CSRF-TOKEN': $('meta[name="csrf-token"]').attr('content') },
                success: function(resp) {
                    $("#dvloader").hide();
                    if(resp.status == 200) toastr.success(resp.success);
                    else toastr.error(resp.errors);
                },
                error: function(XMLHttpRequest, textStatus, errorThrown) {
                    $("#dvloader").hide();
                    toastr.error(errorThrown, textStatus);
                }
            });
        } else { showError(); }
    };
    $(document).on('change', '.status-checkbox', function() {
        id = $(this).attr('data-id');
        change_status(id);
    })
</script>
@endsection