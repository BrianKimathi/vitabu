@extends('author.layout.page-app')
@section('page_title', __('label.subscription_payout'))
@section('tab_title', __('label.subscription_payout'))

@section('content')
@include('author.layout.sidebar')

<!-- Select2 -->
<link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/select2/4.0.13/css/select2.min.css" />

<div class="right-content">
    @include('author.layout.header')

    <div class="body-content">
        <!-- mobile title -->
        <h1 class="page-title-sm"> {{__('label.subscription_payout')}} </h1>

        <div class="border-bottom row mb-3">
            <div class="col-sm-12">
                <ol class="breadcrumb">
                    <li class="breadcrumb-item"><a href="{{ route('author.dashboard') }}">{{__('label.dashboard')}}</a></li>
                    <li class="breadcrumb-item active" aria-current="page">{{__('label.subscription_payout')}}</li>
                </ol>
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
    $("#input_year").select2();
    $("#input_month").select2();
    $(document).ready(function() {
        var table = $('#datatable').DataTable({
            ...dataTableDefaults,
            ajax: {
                url: "{{ route('author.subscription_payout.index') }}",
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
                    data: 'total_read_time',
                    name: 'total_read_time',
                    render: function(data) {
                        return data ? data : "00:00:00";
                    }
                },
                {
                    data: 'gross_earning',
                    name: 'gross_earning',
                    render: function(data) {
                        return data ? data : "0";
                    }
                },
                {
                    data: 'admin_commission',
                    name: 'admin_commission',
                    render: function(data) {
                        return data ? data : "0";
                    }
                },
                {
                    data: 'total_payable_amount',
                    name: 'total_payable_amount',
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
                    render: function(data) {
                        return data ? data : "";
                    }
                },
                {
                    data: 'date',
                    name: 'date'
                },
                {
                    data: 'status',
                    name: 'status',
                    orderable: false,
                    searchable: false
                },
            ],
            buttons: [{
                    extend: 'excel',
                    filename: "{{App_Name()}} - {{__('label.subscription_payout')}}",
                    exportOptions: {
                        columns: [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10]
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
                        columns: [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10]
                    },
                },
                {
                    extend: 'pdf',
                    title: "{{App_Name()}} - {{__('label.subscription_payout')}}",
                    filename: "{{App_Name()}} - {{__('label.subscription_payout')}}",
                    pageSize: 'A4',
                    exportOptions: {
                        columns: [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10],
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
                        doc.content[1].table.widths = ['5%', '10%', '10%', '7%', '10%', '10%', '10%', '10%', '10%', '10%', '8%'];
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
</script>
@endsection