@extends('admin.layout.page-app')
@section('page_title', __('label.withdrawal_request'))
@section('tab_title', __('label.withdrawal_request'))

@section('content')
@include('admin.layout.sidebar')

<!-- Select2 -->
<link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/select2/4.0.13/css/select2.min.css" />

<div class="right-content">
    @include('admin.layout.header')

    <div class="body-content">
        <!-- mobile title -->
        <h1 class="page-title-sm"> {{__('label.withdrawal_request')}} </h1>

        <div class="border-bottom row mb-3">
            <div class="col-sm-12">
                <ol class="breadcrumb">
                    <li class="breadcrumb-item"><a href="{{ route('admin.dashboard') }}">{{__('label.dashboard')}}</a></li>
                    <li class="breadcrumb-item active" aria-current="page">{{__('label.withdrawal_request')}}</li>
                </ol>
            </div>
        </div>

        <!-- Search -->
        <div class="page-search mb-3">
            <div class="sorting mr-4 w-50">
                <label>{{__('label.sort_by')}}</label>
                <select class="form-control" name="author_id" id="input_author_id">
                    <option value="0">{{__('label.all_authors')}}</option>
                    @foreach ($author as $key => $value)
                    <option value="{{$value->id}}">
                        {{ $value->first_name }} {{ $value->last_name }}
                    </option>
                    @endforeach
                </select>
            </div>
            <div class="sorting w-25">
                <label>{{__('label.sort_by')}}</label>
                <select class="form-control" id="input_status">
                    <option value="all">{{__('label.all_status')}}</option>
                    <option value="0">{{__('label.pending')}}</option>
                    <option value="1">{{__('label.completed')}}</option>
                </select>
            </div>
        </div>

        <div class="table-responsive table">
            <table class="table table-striped text-center table-bordered" id="datatable">
                <thead>
                    <tr class="table-bg">
                        <th>{{__('label.#')}}</th>
                        <th>{{__('label.author')}}</th>
                        <th>{{__('label.requested_amount')}}</th>
                        <th>{{__('label.payment_type')}}</th>
                        <th>{{__('label.payment_details')}}</th>
                        <th>{{__('label.request_date')}}</th>
                        <th>{{__('label.action')}}</th>
                    </tr>
                </thead>
                <tbody></tbody>
            </table>
        </div>
    </div>
</div>
@endsection

@section('pagescript')
<!-- Select2 -->
<script src="https://cdnjs.cloudflare.com/ajax/libs/select2/4.0.13/js/select2.min.js"></script>

<script>
    // Sidebar Scroll Down
    sidebar_down($(document).height());

    $("#input_author_id").select2();
    $(document).ready(function() {
        var table = $('#datatable').DataTable({
            ...dataTableDefaults,
            ajax: {
                url: "{{ route('admin.withdrawal.index') }}",
                data: function(d) {
                    d.input_status = $('#input_status').val();
                    d.input_author_id = $('#input_author_id').val();
                },
            },
            columns: [{
                    data: 'DT_RowIndex',
                    name: 'DT_RowIndex',
                    orderable: false,
                    searchable: false
                },
                {
                    data: 'author',
                    name: 'author',
                    render: function(data) {
                        if (data) {
                            return '<div class="text-left">' + data.first_name + ' ' + data.last_name + '<br><span class="f-14 font-weight-bold">' + data.user_name + '</span></div>';
                        } else {
                            return "-";
                        }
                    }
                },
                {
                    data: 'price',
                    name: 'price',
                    render: function(data) {
                        return data ? data : "-";
                    }
                },
                {
                    data: 'payment_type',
                    name: 'payment_type',
                    render: function(data) {
                        return data ? data : "-";
                    }
                },
                {
                    data: 'payment_detail',
                    name: 'payment_detail',
                    render: function(data) {
                        return data ? data : "-";
                    }
                },
                {
                    data: 'date',
                    name: 'date'
                },
                {
                    data: 'action',
                    name: 'action',
                    orderable: false,
                    searchable: false
                },
            ],
        });

        $('#input_status, #input_author_id').change(function() {
            table.draw();
        });
    });

    function change_status(id, status) {

        var Demo_Mode = '<?php echo Demo_Mode(); ?>';
        if (Demo_Mode == 1) {

            $("#dvloader").show();
            var url = `{{ route('admin.withdrawal.show', '') }}/${id}`;

            $.ajax({
                type: "GET",
                url: url,
                headers: {
                    'X-CSRF-TOKEN': $('meta[name="csrf-token"]').attr('content')
                },
                success: function(resp) {
                    $("#dvloader").hide();

                    if (resp.status == 200) {
                        $('#' + id).val(resp.status_code);
                        toastr.success(resp.success);
                    } else {
                        toastr.error(resp.errors);
                    }
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

    $(document).on('change', '.status-change', function() {
        id = $(this).attr('id');
        status = $(this).val();
        change_status(id, status);
    })
</script>
@endsection