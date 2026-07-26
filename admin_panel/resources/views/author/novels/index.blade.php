@extends('author.layout.page-app')
@section('page_title', __('label.novels'))
@section('tab_title', __('label.novels'))

@section('content')
@include('author.layout.sidebar')

<div class="right-content">
    @include('author.layout.header')

    <!-- Select2 -->
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/select2/4.0.13/css/select2.min.css" />

    <div class="body-content">
        <h1 class="page-title-sm">{{__('label.novels')}}</h1>

        <!-- Search & Filters Bar -->
        <div class="card border-0 shadow-sm mb-3" style="border-radius:12px;">
            <div class="card-body p-3">
                <div class="row align-items-center">
                    <div class="col">
                        <div class="d-flex align-items-center" style="gap:8px;overflow-x:auto;">
                            <div class="input-group flex-shrink-0" style="width:180px;min-width:140px;">
                                <div class="input-group-prepend">
                                    <span class="input-group-text" style="background:#F9FAFB;border:1px solid #E5E7EB;border-right:none;border-radius:8px 0 0 8px;padding:0 10px;">
                                        <i class="fa-solid fa-magnifying-glass" style="color:#9CA3AF;font-size:13px;"></i>
                                    </span>
                                </div>
                                <input type="text" id="input_search" class="form-control" placeholder="{{__('label.search')}}" style="border-left:none;border-radius:0 8px 8px 0;">
                            </div>
                            <div style="min-width:130px;">
                                <select class="form-control" id="input_category">
                                    <option value="0">{{__('label.all_category')}}</option>
                                    @foreach($category ?? [] as $c)
                                    <option value="{{ $c['id'] }}">{{ $c['name'] }}</option>
                                    @endforeach
                                </select>
                            </div>
                            <div style="min-width:130px;">
                                <select class="form-control" id="input_language">
                                    <option value="0">{{__('label.all_language')}}</option>
                                    @foreach($language ?? [] as $l)
                                    <option value="{{ $l['id'] }}">{{ $l['name'] }}</option>
                                    @endforeach
                                </select>
                            </div>
                            <div style="min-width:120px;">
                                <select class="form-control" id="input_status">
                                    <option value="">{{__('label.all_status')}}</option>
                                    <option value="0">{{__('label.under_review')}}</option>
                                    <option value="1">{{__('label.show')}}</option>
                                    <option value="2">{{__('label.hide')}}</option>
                                </select>
                            </div>
                            <div style="min-width:140px;">
                                <select class="form-control" id="input_access_type">
                                    <option value="all">{{__('label.all_access_types')}}</option>
                                    <option value="0">{{__('label.free')}}</option>
                                    <option value="1">{{__('label.paid')}}</option>
                                    <option value="2">{{__('label.subscription_included')}}</option>
                                </select>
                            </div>
                        </div>
                    </div>
                    <div class="col-auto flex-shrink-0">
                        <a href="{{ route('author.novels.create') }}" class="btn" style="background:#4E45B8;color:#fff;font-weight:600;border-radius:8px;padding:7px 20px;font-size:13px;border:none;white-space:nowrap;">
                            <i class="fa-solid fa-plus mr-1"></i> {{__('label.add_novel')}}
                        </a>
                    </div>
                </div>
            </div>
        </div>

        <!-- Novels Table -->
        <div class="card border-0 shadow-sm" style="border-radius:12px;">
            <div class="card-body p-0">
                <div class="table-responsive">
                    <table class="table table-hover mb-0" id="datatable" style="min-width:850px;">
                        <thead>
                            <tr>
                                <th style="font-size:12px;font-weight:600;color:#6B7280;padding:12px 14px;border-bottom:1px solid #F3F4F6;">#</th>
                                <th style="font-size:12px;font-weight:600;color:#6B7280;padding:12px 14px;border-bottom:1px solid #F3F4F6;">{{__('label.image')}}</th>
                                <th style="font-size:12px;font-weight:600;color:#6B7280;padding:12px 14px;border-bottom:1px solid #F3F4F6;">{{__('label.title')}}</th>
                                <th style="font-size:12px;font-weight:600;color:#6B7280;padding:12px 14px;border-bottom:1px solid #F3F4F6;">{{__('label.info')}}</th>
                                <th style="font-size:12px;font-weight:600;color:#6B7280;padding:12px 14px;border-bottom:1px solid #F3F4F6;">{{__('label.access_type')}}</th>
                                <th style="font-size:12px;font-weight:600;color:#6B7280;padding:12px 14px;border-bottom:1px solid #F3F4F6;">{{__('label.chapters')}}</th>
                                <th style="font-size:12px;font-weight:600;color:#6B7280;padding:12px 14px;border-bottom:1px solid #F3F4F6;">{{__('label.status')}}</th>
                                <th style="font-size:12px;font-weight:600;color:#6B7280;padding:12px 14px;border-bottom:1px solid #F3F4F6;">{{__('label.action')}}</th>
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
<!-- Select2 -->
<script src="https://cdnjs.cloudflare.com/ajax/libs/select2/4.0.13/js/select2.min.js"></script>

<script>
    $(document).ready(function() {
        $("#input_category, #input_language, #input_status, #input_access_type").select2({
            width: '100%',
            minimumResultsForSearch: -1
        });

        var table = $('#datatable').DataTable({
            ...dataTableDefaults,
            ajax: {
                url: "{{ route('author.novels.index') }}",
                data: function(d) {
                    d.input_search = $('#input_search').val();
                    d.input_category = $('#input_category').val();
                    d.input_language = $('#input_language').val();
                    d.input_status = $('#input_status').val();
                    d.input_access_type = $('#input_access_type').val();
                },
            },
            columns: [
                { data: 'DT_RowIndex', name: 'DT_RowIndex', orderable: false, searchable: false },
                {
                    data: 'portrait_img', name: 'portrait_img', orderable: false, searchable: false,
                    render: function(data) {
                        if (!data || data === '' || data.includes('default')) {
                            return '<div style="width:40px;height:40px;background:#EEF0FF;border-radius:8px;display:flex;align-items:center;justify-content:center;margin:0 auto;"><i class="fa-solid fa-book" style="color:#4E45B8;font-size:16px;"></i></div>';
                        }
                        return `<a href='${data}' target='_blank'><img src='${data}' style='width:40px;height:40px;border-radius:8px;object-fit:cover;'></a>`;
                    },
                },
                {
                    data: 'title', name: 'title',
                    render: function(data) {
                        return data ? `<span style="font-weight:500;color:#1F2937;font-size:13.5px;">${data}</span>` : '-';
                    }
                },
                {
                    data: 'info', name: 'info',
                    render: function(data, type, row) {
                        const cat = row.category?.name || '-';
                        const lang = row.language?.name || '-';
                        return `<div><span style="font-size:13px;color:#1F2937;">${cat}</span><br><span style="font-size:12px;color:#6B7280;">${lang}</span></div>`;
                    }
                },
                {
                    data: 'access_type', name: 'access_type',
                    render: function(data, type, row) {
                        const labels = {0:'Free',1:'Paid',2:'Subscription'};
                        const colors = {0:'#059669',1:'#F5A623',2:'#4E45B8'};
                        const label = labels[data] || '-';
                        const color = colors[data] || '#6B7280';
                        let html = `<span class="badge" style="background:${color}15;color:${color};font-size:11px;font-weight:600;padding:3px 10px;border-radius:6px;">${label}</span>`;
                        if (data == 1 && row.price) {
                            html += `<br><span style="font-size:12px;font-weight:600;color:#1F2937;margin-top:2px;display:inline-block;">{{ Currency_Code() }} ${row.price}</span>`;
                        }
                        return html;
                    }
                },
                {
                    data: 'chapter', name: 'chapter', orderable: false, searchable: false,
                    render: function(data) { return data || '0'; }
                },
                {
                    data: 'status', name: 'status', orderable: false, searchable: false
                },
                {
                    data: 'action', name: 'action', orderable: false, searchable: false
                },
            ],
            columnDefs: [{ targets: '_all', className: 'align-middle' }],
            dom: "<'row'<'col-sm-12'tr>>" + "<'row mt-2'<'col-sm-12 col-md-5'i><'col-sm-12 col-md-7'p>>",
        });

        $('#input_category, #input_language, #input_status, #input_access_type').change(function() { table.draw(); });
        $('#input_search').keyup(function() { table.draw(); });
    });
</script>
@endsection