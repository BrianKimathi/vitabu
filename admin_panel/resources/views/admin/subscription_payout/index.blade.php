@extends('admin.layout.page-app')
@section('page_title', __('label.subscription_payout'))
@section('tab_title', __('label.subscription_payout'))

@section('content')
@include('admin.layout.sidebar')

<!-- Select2 -->
<link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/select2/4.0.13/css/select2.min.css" />

<div class="right-content">
    @include('admin.layout.header')

    <div class="body-content">
        <!-- mobile title -->
        <h1 class="page-title-sm"> {{__('label.subscription_payout')}} </h1>

        <div class="border-bottom row mb-3">
            <div class="col-sm-12">
                <ol class="breadcrumb">
                    <li class="breadcrumb-item"><a href="{{ route('admin.dashboard') }}">{{__('label.dashboard')}}</a></li>
                    <li class="breadcrumb-item active" aria-current="page">{{__('label.subscription_payout')}}</li>
                </ol>
            </div>
        </div>

        <!-- Earning Cards -->
        <div class="row mb-4">
            <div class="col-sm-12 col-md-6 col-lg-4">
                <div class="card-earning pb-1">
                    <div class="card-align">
                        <div>
                            <p class="earning-amount" id="subscription_revenue">{{ Currency_Code() }}</p>
                        </div>
                    </div>
                    <p class="earning-title text-left">{{__('label.total_subscription_revenue')}}</p>
                </div>
            </div>
            <div class="col-sm-12 col-md-6 col-lg-4">
                <div class="card-earning pb-1">
                    <div class="card-align ">
                        <div>
                            <p class="earning-amount" id="admin_share">{{ Currency_Code() }}</p>
                        </div>
                    </div>
                    <p class="earning-title text-left">{{__('label.admin_share')}}</p>
                </div>
            </div>
            <div class="col-sm-12 col-md-6 col-lg-4">
                <div class="card-earning pb-1">
                    <div class="card-align">
                        <div>
                            <p class="earning-amount" id="author_pool">{{ Currency_Code() }}</p>
                        </div>
                    </div>
                    <p class="earning-title text-left">{{__('label.total_author_pool')}}</p>
                </div>
            </div>
        </div>
        <div class="row mb-4">
            <div class="col-sm-12 col-md-6 col-lg-4">
                <div class="card-earning pb-1">
                    <div class="card-align">
                        <div>
                            <p class="earning-amount" id="content_earnings">{{ Currency_Code() }}</p>
                        </div>
                    </div>
                    <p class="earning-title text-left">{{__('label.total_content_earnings')}}</p>
                </div>
            </div>
            <div class="col-sm-12 col-md-6 col-lg-4">
                <div class="card-earning pb-1">
                    <div class="card-align">
                        <div>
                            <p class="earning-amount" id="payout_period"></p>
                        </div>
                    </div>
                    <p class="earning-title text-left">{{__('label.payout_period')}}</p>
                </div>
            </div>
            <div class="col-sm-12 col-md-6 col-lg-4">
                <div class="card-earning pb-1">
                    <div class="card-align">
                        <div>
                            <p class="earning-amount" id="payout_date"></p>
                        </div>
                    </div>
                    <p class="earning-title text-left">{{__('label.payout_date')}}</p>
                </div>
            </div>
        </div>

        <!-- Export Files -->
        <div class="page-search mb-3">
            <div class="col-8">
                <label class="text-gray pt-2 font-weight-bold"><i class="fa-solid fa-circle-info fa-2xl mr-3"></i>{{__('label.only_the_following_data_will_be_captured_in_this_file')}}</label>
            </div>
            <div class="col-4">
                <div class="d-flex justify-content-around">
                    <button id="ms_excel" class="btn btn-default"><i class="fa-sharp fa-solid fa-file-excel mr-2 font-weight-bold"></i>{{__('label.ms_excel')}}</button>
                    <button id="csv" class="btn btn-default"><i class="fa-solid fa-file-csv mr-2 font-weight-bold f-18"></i>{{__('label.csv')}}</button>
                    <button id="pdf" class="btn btn-default"><i class="fa-solid fa-file-pdf mr-2 font-weight-bold f-18"></i>{{__('label.pdf')}}</button>
                </div>
            </div>
        </div>

        <!-- Search -->
        <div class="page-search mb-3">
            <div class="sorting mr-2 w-25">
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
            <div class="sorting w-25 mr-2">
                <select class="form-control" id="input_status">
                    <option value="all">{{__('label.all_status')}}</option>
                    <option value="0">{{__('label.pending')}}</option>
                    <option value="1">{{__('label.paid')}}</option>
                    <option value="2">{{__('label.hold')}}</option>
                </select>
            </div>
            <div class="sorting w-25 mr-2">
                <select class="form-control" id="input_month">
                    @foreach($months as $key =>$value)
                    <option value="{{$key}}" {{$current_month == $key ? "selected" : ""}}>{{$value}}</option>
                    @endforeach
                </select>
            </div>
            <div class="sorting w-25 mr-2">
                <select class="form-control" id="input_year">
                    @foreach($years as $key =>$value)
                    <option value="{{$value}}" {{$current_year == $value ? "selected" : ""}}>{{$value}}</option>
                    @endforeach
                </select>
            </div>
        </div>

        <div class="table-responsive table">
            <table class="table table-striped text-center table-bordered" id="datatable">
                <thead>
                    <tr class="table-bg">
                        <th>{{__('label.#')}}</th>
                        <th>{{__('label.author')}}</th>
                        <th title="HH:MM:SS">{{__('label.total_reading_time')}}</th>
                        <th>{{__('label.total_subscription_revenue')}}</th>
                        <th>{{__('label.admin_share')}}</th>
                        <th>{{__('label.total_author_pool')}}</th>
                        <th>{{__('label.subscription_earnings')}}</th>
                        <th>{{__('label.content_earnings')}}</th>
                        <th>{{__('label.total_earnings')}}</th>
                        <th>{{__('label.payout_period')}}</th>
                        <th>{{__('label.payout_date')}}</th>
                        <th>{{__('label.status')}}</th>
                        <th>{{__('label.action')}}</th>
                    </tr>
                </thead>
                <tbody></tbody>
            </table>
        </div>

        <!-- Details Modal -->
        <div class="modal fade" id="detailsModal" tabindex="-1" data-backdrop="static" role="dialog" aria-labelledby="detailsModalLabel" aria-hidden="true">
            <div class="modal-dialog modal-lg" role="document">
                <div class="modal-content">
                    <div class="modal-header">
                        <h5 class="modal-title w-100" id="detailsModalLabel">{{__('label.author_bank_details')}}</h5>
                        <button type="button" class="close" data-dismiss="modal" aria-label="Close" id="close">
                            <span aria-hidden="true" class="text-dark">&times;</span>
                        </button>
                    </div>
                    <div class="modal-body justify-content-center">
                        <div class="col-12">
                            <div class="form-row">
                                <div class="col-md-6">
                                    <div class="form-group">
                                        <label>{{__('label.author')}}</label>
                                        <input type="text" class="form-control" value="" id="name" readonly>
                                    </div>
                                </div>
                                <div class="col-md-6">
                                    <div class="form-group">
                                        <label>{{__('label.total_earnings')}}</label>
                                        <input type="text" class="form-control" value="" id="earnings" readonly>
                                    </div>
                                </div>
                            </div>
                            <div class="form-row">
                                <div class="col-md-6">
                                    <div class="form-group">
                                        <label>{{__('label.bank_name')}}</label>
                                        <input type="text" class="form-control" value="" id="bank_name" readonly>
                                    </div>
                                </div>
                                <div class="col-md-6">
                                    <div class="form-group">
                                        <label>{{__('label.bank_holder_name')}}</label>
                                        <input type="text" class="form-control" value="" id="bank_holder_name" readonly>
                                    </div>
                                </div>
                            </div>
                            <div class="form-row">
                                <div class="col-md-6">
                                    <div class="form-group">
                                        <label>{{__('label.account_no')}}</label>
                                        <input type="text" class="form-control" value="" id="account_no" readonly>
                                    </div>
                                </div>
                                <div class="col-md-6">
                                    <div class="form-group">
                                        <label>{{__('label.ifsc_code')}}</label>
                                        <input type="text" class="form-control" value="" id="ifsc_code" readonly>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>
</div>
@endsection

@section('pagescript')
<!-- Select2 -->
<script src="https://cdnjs.cloudflare.com/ajax/libs/select2/4.0.13/js/select2.min.js"></script>
<!-- Export Files LInk (PDF, CSV, MS-Excel) -->
<script src="https://cdnjs.cloudflare.com/ajax/libs/jszip/3.1.3/jszip.min.js"></script>
<script src="https://cdn.datatables.net/buttons/1.3.1/js/buttons.html5.min.js"></script>
<script src="https://cdn.datatables.net/buttons/1.4.2/js/dataTables.buttons.min.js"></script>
<script src="https://cdnjs.cloudflare.com/ajax/libs/pdfmake/0.1.32/pdfmake.min.js"></script>
<script src="https://cdnjs.cloudflare.com/ajax/libs/pdfmake/0.1.32/vfs_fonts.js"></script>
<script>
    // Sidebar Scroll Down
    sidebar_down($(document).height());

    $("#input_author_id").select2();
    $("#input_month").select2();
    $("#input_year").select2();
    $(document).ready(function() {
        var table = $('#datatable').DataTable({
            ...dataTableDefaults,
            ajax: {
                url: "{{ route('admin.subscription_payout.index') }}",
                data: function(d) {
                    d.input_status = $('#input_status').val();
                    d.input_author_id = $('#input_author_id').val();
                    d.input_year = $('#input_year').val();
                    d.input_month = $('#input_month').val();
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
                    },
                    orderable: false,
                },
                {
                    data: 'total_read_time',
                    name: 'total_read_time',
                    render: function(data) {
                        return data ? data : "00:00:00";
                    }
                },
                {
                    data: 'gross_earning',
                    name: 'gross_earning',
                    orderable: false,
                    searchable: false,
                    visible: false,
                    render: function(data) {
                        return data ? data : "0";
                    }
                },
                {
                    data: 'admin_commission',
                    name: 'admin_commission',
                    orderable: false,
                    searchable: false,
                    visible: false,
                    render: function(data) {
                        return data ? data : "0";
                    }
                },
                {
                    data: 'total_payable_amount',
                    name: 'total_payable_amount',
                    orderable: false,
                    searchable: false,
                    visible: false,
                    render: function(data) {
                        return data ? data : "0";
                    }
                },
                {
                    data: 'author_payable_amount',
                    name: 'author_payable_amount',
                    render: function(data) {
                        return data ? data : "0";
                    }
                },
                {
                    data: 'content_earnings',
                    name: 'content_earnings',
                    render: function(data) {
                        return data ? data : "0";
                    }
                },
                {
                    data: 'total_earnings',
                    name: 'total_earnings',
                    render: function(data, type, row) {
                        return Number(row['author_payable_amount'] ?? 0) + Number(row['content_earnings']);
                    }
                },
                {
                    data: 'payout_period',
                    name: 'payout_period',
                    orderable: false,
                    searchable: false,
                    visible: false
                },
                {
                    data: 'date',
                    name: 'date',
                    orderable: false,
                    searchable: false,
                    visible: false
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
            buttons: [{
                    extend: 'excel',
                    filename: "{{App_Name()}} - {{__('label.subscription_payout')}}",
                    exportOptions: {
                        columns: [0, 1, 2, 3, 4, 5, 6, 7, 8, 9]
                    },
                    customize: function(xlsx) {
                        var sheet = xlsx.xl.worksheets['sheet1.xml'];
                        $('row:first c', sheet).attr('s', '2');
                    },
                },
                {
                    extend: 'csv',
                    filename: "{{App_Name()}} - {{__('label.subscription_payout')}}",
                    exportOptions: {
                        columns: [0, 1, 2, 3, 4, 5, 6, 7, 8, 9]
                    },
                },
                {
                    extend: 'pdf',
                    title: "{{App_Name()}} - {{__('label.subscription_payout')}}",
                    filename: "{{App_Name()}} - {{__('label.subscription_payout')}}",
                    pageSize: 'A4',
                    exportOptions: {
                        columns: [0, 1, 2, 3, 4, 5, 6, 7, 8, 9],
                        format: {
                            body: function(data, row, column, node) {

                                // If column contains a select dropdown
                                if ($(node).find('select').length) {
                                    return $(node).find('select option:selected').text();
                                }

                                // Add Other Data Back
                                return $('<div>').html(data).text();
                            }
                        }
                    },

                    customize: function(doc) {
                        doc.styles.tableHeader.fontSize = 10;
                        doc.defaultStyle.fontSize = 8;
                        doc.content[1].table.widths = ['5%', '15%', '10%', '10%', '10%', '10%', '10%', '10%', '10%', '10%'];
                        doc.content[1].layout = "borders";
                        doc.styles.title.fontSize = 22;
                        doc.styles.title.alignment = 'center';
                        doc.defaultStyle.alignment = 'center';

                        // Create a header
                        doc['header'] = (function(page, pages) {
                            return {
                                columns: [{
                                        alignment: 'left',
                                        bold: true,
                                        text: "{{App_Name()}}",
                                    },
                                    {
                                        alignment: 'right',
                                        bold: true,
                                        text: ['Total Page ', {
                                            text: pages.toString()
                                        }],
                                    }
                                ],
                                margin: [20, 20],
                            }
                        });
                        // Create a footer
                        doc['footer'] = (function(page, pages) {
                            return {
                                columns: [{
                                    alignment: 'center',
                                    bold: true,
                                    text: ['Page ', {
                                        text: page.toString()
                                    }, ' of ', {
                                        text: pages.toString()
                                    }],
                                }],
                            }
                        });
                    }
                }
            ],
        });

        table.on('xhr.dt', function(e, settings, json, xhr) {

            data = Array.isArray(json?.data) ? json.data : [];
            first_row = data[0] ?? {};
            const currency = value => {
                return "{{Currency_Code()}}" + (Number(value) || 0)
            };

            selected_month = $('#input_month').find('option:selected').text();
            selected_year = $('#input_year').find('option:selected').text();
            content_earnings = 0;

            $('#subscription_revenue').text(currency(first_row.gross_earning));
            $('#admin_share').text(currency(first_row.admin_commission));
            $('#author_pool').text(currency(first_row.total_payable_amount));
            $('#payout_period').text(first_row.payout_period ?? (selected_month + " " + selected_year));
            $('#payout_date').text(first_row.date ?? "-");

            data.forEach(sup => {
                content_earnings += Number(sup?.['content_earnings']) || 0;
            });
            $('#content_earnings').text(currency(content_earnings));
        })

        $('#ms_excel').on('click', function() {

            var Demo_Mode = '{{Demo_Mode()}}';
            if (Demo_Mode == 1) {
                var table = $('#datatable').DataTable();
                table.button('0').trigger();
            } else {
                showError();
            }
        });
        $('#csv').on('click', function() {

            var Demo_Mode = '{{Demo_Mode()}}';
            if (Demo_Mode == 1) {
                var table = $('#datatable').DataTable();
                table.button('1').trigger();
            } else {
                showError();
            }
        });
        $('#pdf').on('click', function() {

            var Demo_Mode = '{{Demo_Mode()}}';
            if (Demo_Mode == 1) {
                var table = $('#datatable').DataTable();
                table.button('2').trigger();
            } else {
                showError();
            }
        });
        $('#input_status, #input_author_id,#input_month,#input_year').change(function() {
            table.draw();
        });

    });

    function change_status(id, status) {

        var Demo_Mode = '<?php echo Demo_Mode(); ?>';
        if (Demo_Mode == 1) {

            $("#dvloader").show();
            var url = `{{ route('admin.subscription_payout.show', '') }}/${id}`;

            $.ajax({
                type: "GET",
                url: url,
                headers: {
                    'X-CSRF-TOKEN': $('meta[name="csrf-token"]').attr('content')
                },
                data: {
                    id: id,
                    status: status
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
        status = $(this).val();
        id = $(this).attr('id');

        change_status(id, status);
    });

    $(document).on('click', '.view_details', function() {
        author_name = $(this).data('name');
        earnings = $(this).data('earnings');
        bank_name = $(this).data('bank_name');
        bank_holder_name = $(this).data('bank_holder_name');
        account_no = $(this).data('account_no');
        ifsc_code = $(this).data('ifsc_code');

        $('.modal-body #name').val(author_name);
        $('.modal-body #earnings').val(earnings);
        $('.modal-body #bank_name').val(bank_name);
        $('.modal-body #bank_holder_name').val(bank_holder_name);
        $('.modal-body #account_no').val(account_no);
        $('.modal-body #ifsc_code').val(ifsc_code);
    })
</script>
@endsection