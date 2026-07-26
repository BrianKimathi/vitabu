@extends('admin.layout.page-app')
@section('page_title', __('label.transactions'))

@section('content')
@include('admin.layout.sidebar')

<!-- Select2 -->
<link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/select2/4.0.13/css/select2.min.css" />

<div class="right-content">
    @include('admin.layout.header')

    <div class="body-content">
        <!-- mobile title -->
        <h1 class="page-title-sm"> {{__('label.transactions')}} </h1>

        <div class="border-bottom row mb-3">
            <div class="col-sm-10">
                <ol class="breadcrumb">
                    <li class="breadcrumb-item"><a href="{{ route('admin.dashboard') }}">{{__('label.dashboard')}}</a>
                    </li>
                    <li class="breadcrumb-item active" aria-current="page">
                        {{__('label.transactions')}}
                    </li>
                </ol>
            </div>
            <div class="col-sm-2 d-flex align-items-center justify-content-end">
                <a href="{{ route('admin.transaction.create') }}" class="btn btn-default mw-120 mt-14">{{__('label.add_transaction')}}</a>
            </div>
        </div>
        <!-- Earning Cards -->
        <div class="row mb-4">
            <div class="col-sm-12 col-md-6 col-lg-4">
                <div class="card-earning pb-1">
                    <div class="card-align">
                        <div>
                            <p class="earning-amount">{{ Currency_Code() }}{{ $today ?? 00 }}</p>
                        </div>
                    </div>
                    <p class="earning-title text-left">{{__('label.total_transaction_today')}}</p>
                </div>
            </div>
            <div class="col-sm-12 col-md-6 col-lg-4">
                <div class="card-earning pb-1">
                    <div class="card-align">
                        <div>
                            <p class="earning-amount">{{ Currency_Code() }}{{ $month ?? 00 }}</p>
                        </div>
                    </div>
                    <p class="earning-title text-left">{{__('label.total_transaction_current_month')}}</p>
                </div>
            </div>
            <div class="col-sm-12 col-md-6 col-lg-4">
                <div class="card-earning pb-1">
                    <div class="card-align ">
                        <div>
                            <p class="earning-amount">{{ Currency_Code() }}{{ $year ?? 00 }}</p>
                        </div>
                    </div>
                    <p class="earning-title text-left">{{__('label.total_transaction_current_year')}}</p>
                </div>
            </div>
        </div>

        <!-- Search -->
        <div class="page-search">
            <div class="input-group" title="Search">
                <div class="input-group-prepend">
                    <span class="input-group-text" id="basic-addon1"><i class="fa-solid fa-magnifying-glass fa-xl light-gray"></i></span>
                </div>
                <input type="text" id="input_search" class="form-control" placeholder="{{__('label.search_transactions')}}" aria-label="Search" aria-describedby="basic-addon1">
            </div>
            <div class="sorting col-md-3">
                <label>{{__('label.sort_by')}}</label>
                <select class="form-control" id="input_user_id">
                    <option value="">{{__('label.all_users')}}</option>
                    @foreach($users as $user)
                    <option value="{{ $user->id }}">{{ $user->first_name }} {{ $user->last_name }}</option>
                    @endforeach
                </select>
            </div>
            <div class="sorting mr-4 col-md-3">
                <select class="form-control" id="input_plan_id">
                    <option value="">{{__('label.all_plan')}}</option>
                    @foreach($plans as $plan)
                    <option value="{{ $plan->id }}">{{ $plan->name }}</option>
                    @endforeach
                </select>
            </div>
        </div>
        <div class="page-search mb-3">
            <div class="sorting mr-4 col-md-3 py-0 ">
                <label>{{__('label.start_date')}}</label>
                <input type="date" id="input_start_date" class="form-control">
            </div>
            <div class="sorting mr-4 col-md-3  py-0 ">
                <label>{{__('label.end_date')}}</label>
                <input type="date" id="input_end_date" class="form-control">
            </div>
            <div class="sorting mr-4 col-md-2">
                <select class="form-control " id="input_type">
                    <option value="">{{__('label.all_type')}}</option>
                    <option value="today">{{__('label.today')}}</option>
                    <option value="month">{{__('label.month')}}</option>
                    <option value="year">{{__('label.year')}}</option>
                </select>
            </div>
            <div class="sorting col-md-3">
                <select class="form-control " id="input_status">
                    <option value="">{{__('label.all_status')}}</option>
                    <option value="0">{{__('label.expire')}}</option>
                    <option value="1">{{__('label.active')}}</option>
                    <option value="2">{{__('label.upcoming')}}</option>
                </select>
            </div>
        </div>

        <div class="table-responsive table">
            <table class="table table-striped text-center table-bordered" id="datatable">
                <thead>
                    <tr class="table-bg">
                        <th> {{__('label.#')}} </th>
                        <th> {{__('label.coupon_code')}} </th>
                        <th> {{__('label.user_name')}} </th>
                        <th> {{__('label.plan')}} </th>
                        <th> {{__('label.price')}} </th>
                        <th> {{__('label.tax_amount')}} </th>
                        <th> {{__('label.transaction_id')}} </th>
                        <th> {{__('label.buy_date')}} </th>
                        <th> {{__('label.starts_at')}} </th>
                        <th> {{__('label.expiry_date')}} </th>
                        <th>{{__('label.status')}}</th>
                        <th> {{__('label.action')}} </th>
                    </tr>
                </thead>
                <tbody>
                </tbody>
                <tfoot>
                    <tr>
                        <td></td>
                        <td></td>
                        <td></td>
                        <td></td>
                        <td></td>
                        <td></td>
                        <td></td>
                        <td></td>
                        <td></td>
                        <td></td>
                        <td></td>
                        <td></td>
                    </tr>
                </tfoot>
            </table>
        </div>
    </div>
</div>
@endsection

@section('pagescript')
<!-- Select2 -->
<script src="https://cdnjs.cloudflare.com/ajax/libs/select2/4.0.13/js/select2.min.js"></script>
<script>
    sidebar_down($(document).height());

    $('#input_user_id').select2();
    $('#input_plan_id').select2();

    $(document).ready(function() {

        var table = $('#datatable').DataTable({
            dom: "<'top'f>rt<'row'<'col-2'i><'col-1'l><'col-9'p>>",
            searching: false,
            responsive: true,
            autoWidth: false,
            processing: true,
            serverSide: true,
            lengthMenu: [
                [10, 100, 1000, -1],
                [10, 100, 1000, "All"]
            ],
            language: {
                paginate: {
                    previous: "<i class='fa-solid fa-chevron-left'></i>",
                    next: "<i class='fa-solid fa-chevron-right'></i>"
                }
            },
            ajax: {
                url: "{{ route('admin.transaction.index') }}",
                data: function(d) {
                    d.input_search = $('#input_search').val();
                    d.input_user_id = $('#input_user_id').val();
                    d.input_plan_id = $('#input_plan_id').val();
                    d.input_type = $('#input_type').val();
                    d.input_start_date = $('#input_start_date').val();
                    d.input_end_date = $('#input_end_date').val();
                    d.input_status = $('#input_status').val();
                },
            },
            columns: [{
                    data: 'DT_RowIndex',
                    name: 'DT_RowIndex'
                },
                {
                    data: 'coupon_code',
                    name: 'coupon_code',
                    render: function(data, type, row, meta) {
                        if (data) {
                            return data;
                        } else {
                            return "-";
                        }
                    }
                },
                {
                    data: 'user',
                    name: 'user',
                    render: function(data) {
                        if (data) {
                            return '<div class="text-left">' + data.first_name + ' ' + data.last_name + '<br><span class="f-14 font-weight-bold">' + data.user_name + '</span></div>';
                        } else {
                            return "-";
                        }
                    }
                },
                {
                    data: 'plan',
                    name: 'plan',
                },
                {
                    data: 'price',
                    name: 'price',
                    render: function(data, type, row, meta) {
                        if (data) {
                            return data;
                        } else {
                            return "0";
                        }
                    }
                },
                {
                    data: 'total_tax',
                    name: 'total_tax',
                    render: function(data, type, row, meta) {
                        if (data) {
                            return data;
                        } else {
                            return "0";
                        }
                    }
                },
                {
                    data: 'transaction_id',
                    name: 'transaction_id',
                    render: function(data, type, row, meta) {
                        if (data) {
                            return data;
                        } else {
                            return "-";
                        }
                    }
                },
                {
                    data: 'buy_date',
                    name: 'buy_date',

                },
                {
                    data: 'starts_at',
                    name: 'starts_at',
                    render: function(data, type, row, meta) {
                        if (data) {
                            return data;
                        } else {
                            return "-";
                        }
                    }

                },
                {
                    data: 'expiry_date',
                    name: 'expiry_date',
                    render: function(data, type, row, meta) {
                        if (data) {
                            return data;
                        } else {
                            return "-";
                        }
                    }

                },
                {
                    data: 'status',
                    name: 'status',
                    orderable: false,
                    searchable: false
                },
                {
                    data: 'action',
                    name: 'action',
                    orderable: false,
                    searchable: false
                },
            ],
            footerCallback: function(row, data, start, end, display) {
                var api = this.api(),
                    data;

                var intVal = function(i) {
                    return typeof i === 'string' ? i.replace(/[\$,]/g, '') * 1 : typeof i === 'number' ? i : 0;
                };

                var Price = api.column(4).data().reduce(function(a, b) {
                    return intVal(a) + intVal(b);
                }, 0)

                var Tax = api.column(5).data().reduce(function(a, b) {
                    return intVal(a) + intVal(b);
                }, 0)

                $(api.column(4).footer()).html("<h6 class='primary-color'>{{Currency_Code()}}" + " " + Price + "</h6>");
                $(api.column(5).footer()).html("<h6 class='primary-color'>{{Currency_Code()}}" + " " + Tax + "</h6>");
            }
        });

        $('#input_user_id,#input_plan_id,#input_type,#input_start_date,#input_end_date,#input_status').change(function() {
            table.draw();
        });
        $('#input_search').keyup(function() {

            table.draw();
        });

    });

    $(document).on('click', 'action-btn', function() {
        id = $(this).data('id');
        $("#" + id).show();
    })
</script>
@endsection