@extends('admin.layout.page-app')
@section('page_title', __('label.customer_report'))
@section('tab_title', __('label.customer_report'))

@section('content')
@include('admin.layout.sidebar')

<div class="right-content">
    @include('admin.layout.header')

    <div class="body-content">
        <!-- mobile title -->
        <h1 class="page-title-sm">{{__('label.customer_report')}}</h1>

        <div class="border-bottom row mb-3">
            <div class="col-sm-12">
                <ol class="breadcrumb">
                    <li class="breadcrumb-item"><a href="{{ route('admin.dashboard') }}">{{__('label.dashboard')}}</a></li>
                    <li class="breadcrumb-item active" aria-current="page">{{__('label.customer_report')}}</li>
                </ol>
            </div>
        </div>

        <!-- Active Users -->
        <div class="row pl-3 mb-4">
            <div class="col-12 earning-cart-bg">
                <div class="box-title">
                    <h2 class="title"><i class="fa-solid fa-bolt fa-lg mr-2"></i>{{__('label.user_author_login_activity')}}</h2>
                </div>
                <div class="row">
                    <div class="col-12 col-sm-12 mt-2">
                        <Button id="year" class="btn btn-default">{{__('label.this_year')}}</Button>
                        <Button id="month" class="btn btn-default">{{__('label.this_month')}}</Button>
                        <Button id="week" class="btn btn-default">{{__('label.this_week')}}</Button>
                        <Button id="today" class="btn btn-default">{{__('label.today')}}</Button>
                    </div>
                </div>
                <div class="summary-table-card mt-2">
                    <div id="Active_User_Chart"></div>
                </div>
            </div>
        </div>
        <!--  Users table -->
        <div class="custom-border-card">
            <h5 class="card-header">{{__('label.users_with_most_book_purchases')}}</h5>

            <!-- Export Files -->
            <div class="page-search mb-3 mt-3">
                <div class="col-8">
                    <label class="text-gray pt-2 font-weight-bold"><i class="fa-solid fa-circle-info fa-2xl mr-3"></i>{{__('label.only_the_following_data_will_be_captured_in_this_file')}}</label>
                </div>
                <div class="col-4">
                    <div class="d-flex justify-content-around">
                        <button id="ms-excel" class="btn btn-default"><i class="fa-sharp fa-solid fa-file-excel mr-2 font-weight-bold"></i>{{__('label.ms_excel')}}</button>
                        <button id="csv" class="btn btn-default"><i class="fa-solid fa-file-csv mr-2 font-weight-bold f-18"></i>{{__('label.csv')}}</button>
                        <button id="pdf" class="btn btn-default"><i class="fa-solid fa-file-pdf mr-2 font-weight-bold f-18"></i>{{__('label.pdf')}}</button>
                    </div>
                </div>
            </div>

            <!-- Search  -->
            <div class="page-search mb-3">
                <div class="input-group">
                    <div class="input-group-prepend">
                        <span class="input-group-text" id="basic-addon1"><i class="fa-solid fa-magnifying-glass fa-xl light-gray"></i></span>
                    </div>
                    <input type="text" id="input_search" class="form-control" placeholder="{{__('label.search')}}" aria-label="Search" aria-describedby="basic-addon1">
                </div>
            </div>

            <!-- table  -->
            <div class="table-responsive table">
                <table class="table table-striped text-center table-bordered" id="datatable">
                    <thead>
                        <tr class="table-bg">
                            <th>{{__('label.#')}}</th>
                            <th>{{__('label.image')}}</th>
                            <th>{{__('label.name')}}</th>
                            <th>{{__('label.email')}}</th>
                            <th>{{__('label.mobile_number')}}</th>
                            <th>{{__('label.total_purchases')}}</th>
                        </tr>
                    </thead>
                    <tbody></tbody>
                </table>
            </div>
        </div>
        <!--  Authors table -->
        <div class="custom-border-card">
            <h5 class="card-header">{{__('label.authors_with_most_books')}}</h5>

            <!-- Export Files -->
            <div class="page-search mb-3 mt-3">
                <div class="col-8">
                    <label class="text-gray pt-2 font-weight-bold"><i class="fa-solid fa-circle-info fa-2xl mr-3"></i>{{__('label.only_the_following_data_will_be_captured_in_this_file')}}</label>
                </div>
                <div class="col-4">
                    <div class="d-flex justify-content-around">
                        <button id="ms-excel1" class="btn btn-default"><i class="fa-sharp fa-solid fa-file-excel mr-2 font-weight-bold"></i>{{__('label.ms_excel')}}</button>
                        <button id="csv1" class="btn btn-default"><i class="fa-solid fa-file-csv mr-2 font-weight-bold f-18"></i>{{__('label.csv')}}</button>
                        <button id="pdf1" class="btn btn-default"><i class="fa-solid fa-file-pdf mr-2 font-weight-bold f-18"></i>{{__('label.pdf')}}</button>
                    </div>
                </div>
            </div>

            <!-- Search  -->
            <div class="page-search mb-3">
                <div class="input-group">
                    <div class="input-group-prepend">
                        <span class="input-group-text" id="basic-addon1"><i class="fa-solid fa-magnifying-glass fa-xl light-gray"></i></span>
                    </div>
                    <input type="text" id="author_search" class="form-control" placeholder="{{__('label.search')}}" aria-label="Search" aria-describedby="basic-addon1">
                </div>
            </div>

            <!-- table  -->
            <div class="table-responsive table">
                <table class="table table-striped text-center table-bordered" id="author_datatable">
                    <thead>
                        <tr class="table-bg">
                            <th>{{__('label.#')}}</th>
                            <th>{{__('label.image')}}</th>
                            <th>{{__('label.name')}}</th>
                            <th>{{__('label.contact')}}</th>
                            <th>{{__('label.total_books')}}</th>
                            <th>{{__('label.total_author_earning')}}</th>
                        </tr>
                    </thead>
                    <tbody></tbody>
                </table>
            </div>
        </div>
    </div>
</div>
@endsection

@section('pagescript')
<!-- Chart -->
<script src="https://cdn.jsdelivr.net/npm/apexcharts"></script>
<!-- Export Files LInk (PDF, CSV, MS-Excel) -->
<script src="https://cdnjs.cloudflare.com/ajax/libs/jszip/3.1.3/jszip.min.js"></script>
<script src="https://cdn.datatables.net/buttons/1.3.1/js/buttons.html5.min.js"></script>
<script src="https://cdn.datatables.net/buttons/1.4.2/js/dataTables.buttons.min.js"></script>
<script src="https://cdnjs.cloudflare.com/ajax/libs/pdfmake/0.1.32/pdfmake.min.js"></script>
<script src="https://cdnjs.cloudflare.com/ajax/libs/pdfmake/0.1.32/vfs_fonts.js"></script>

<script>
    let activeUserYear = JSON.parse(`<?php echo $active_users_year ?>`);
    let activeUserMonth = JSON.parse(`<?php echo $active_users_month ?>`);
    let activeUserWeek = JSON.parse(`<?php echo $active_users_week ?>`);
    let activeUserToday = JSON.parse(`<?php echo $active_users_today ?>`);

    let activeAuthorYear = JSON.parse(`<?php echo $active_authors_year ?>`);
    let activeAuthorMonth = JSON.parse(`<?php echo $active_authors_month ?>`);
    let activeAuthorWeek = JSON.parse(`<?php echo $active_authors_week ?>`);
    let activeAuthorToday = JSON.parse(`<?php echo $active_authors_today ?>`);


    let chartOptions = {
        chart: {
            type: 'bar',
            height: 350,
            stacked: true,
            toolbar: {
                show: false
            }
        },
        plotOptions: {
            bar: {
                horizontal: false,
                columnWidth: '100%',
                endingShape: 'rounded'
            }
        },
        markers: {
            size: 5,
        },
        colors: ['#283e50', '#f7971e'],
        grid: {
            borderColor: '#e0e0e0',
            strokeDashArray: 4
        },
        tooltip: {
            theme: 'dark',
            style: {
                fontSize: '14px'
            }
        },
        series: [],
        xaxis: {
            categories: []
        },
        legend: {
            position: 'bottom',
            fontSize: '16px',
            fontWeight: 'bold',
            labels: {
                colors: ['#333'],
                useSeriesColors: false
            }
        },
    };

    let chart = new ApexCharts(document.querySelector("#Active_User_Chart"), chartOptions);
    chart.render();

    // Function to load chart data
    function loadChartData(type) {
        if (type === 'year') {
            chart.updateOptions({
                series: [{
                        name: "{{ __('label.users') }}",
                        data: activeUserYear.sum
                    },
                    {
                        name: "{{ __('label.authors') }}",
                        data: activeAuthorYear.sum
                    },
                ],
                xaxis: {
                    categories: activeUserYear.month,
                    labels: {
                        style: {
                            fontSize: '14px',
                            fontWeight: 'bold'
                        }
                    }
                },
                yaxis: {
                    labels: {
                        style: {
                            fontSize: '14px',
                            fontWeight: 'bold'
                        }
                    }
                },
            });
        } else if (type == 'month') {
            chart.updateOptions({
                series: [{
                        name: "{{ __('label.users') }}",
                        data: activeUserMonth.sum
                    },
                    {
                        name: "{{ __('label.authors') }}",
                        data: activeAuthorMonth.sum
                    },
                ],
                xaxis: {
                    categories: activeUserMonth.day
                },
            });
        } else if (type == 'week') {
            chart.updateOptions({
                series: [{
                        name: "{{ __('label.users') }}",
                        data: activeUserWeek.sum
                    },
                    {
                        name: "{{ __('label.authors') }}",
                        data: activeAuthorWeek.sum
                    },
                ],
                xaxis: {
                    categories: activeUserWeek.date
                }

            });
        } else if (type == 'today') {
            chart.updateOptions({
                series: [{
                        name: "{{ __('label.users') }}",
                        data: activeUserToday.sum
                    },
                    {
                        name: "{{ __('label.authors') }}",
                        data: activeAuthorToday.sum
                    },
                ],
                xaxis: {
                    categories: activeUserToday.hour
                }

            });
        }
    }

    loadChartData('year');
    document.getElementById('year').addEventListener('click', function() {
        loadChartData('year');
    });
    document.getElementById('month').addEventListener('click', function() {
        loadChartData('month');
    });
    document.getElementById('week').addEventListener('click', function() {
        loadChartData('week');
    });
    document.getElementById('today').addEventListener('click', function() {
        loadChartData('today');
    });


    $(function() {
        var table = $('#datatable').DataTable({
            ...dataTableDefaults,
            ajax: {
                url: "{{ route('admin.customerreport.get_user_transactions') }}",
                data: function(d) {
                    d.input_search = $('#input_search').val();
                },
            },
            columns: [{
                    data: 'DT_RowIndex',
                    name: 'DT_RowIndex',
                    orderable: false,
                    searchable: false
                },
                {
                    data: 'image',
                    name: 'image',
                    orderable: false,
                    searchable: false,
                    render: function(data, type, full, meta) {
                        return "<a href='" + data + "' target='_blank'><img src='" + data + "' class='rounded-circle size-55' ></a>";
                    },
                },

                {
                    data: 'name',
                    name: 'name',
                    render: function(data, type, row) {
                        return `<div class="text-left">${row.first_name || ''} ${row.last_name || ''}<br><span class="f-14 font-weight-bold">${row.user_name || ''}</span>`;
                    }
                },
                {
                    data: 'email',
                    name: 'email',
                    orderable: false,
                    searchable: false,
                    render: function(data, type, row) {
                        return data ? data : "-";
                    }
                },
                {
                    data: 'mobile_number',
                    name: 'mobile_number',
                    orderable: false,
                    searchable: false,
                    render: function(data, type, row) {
                        return data ? data : "-";
                    }
                },
                {
                    data: 'total_transaction',
                    name: 'total_transaction',
                }
            ],
            buttons: [{
                    extend: 'excel',
                    filename: "{{App_Name()}} - {{__('label.users_with_most_transactions')}}",
                    exportOptions: {
                        columns: [0, 2, 3, 4, 5]
                    },
                    customize: function(xlsx) {
                        var sheet = xlsx.xl.worksheets['sheet1.xml'];
                        $('row:first c', sheet).attr('s', '2');
                    },
                },
                {
                    extend: 'csv',
                    filename: "{{App_Name()}} - {{__('label.users_with_most_transactions')}}",
                    exportOptions: {
                        columns: [0, 2, 3, 4, 5]

                    },
                },
                {
                    extend: 'pdf',
                    title: "{{App_Name()}} - {{__('label.users_with_most_transactions')}}",
                    filename: "{{App_Name()}} - {{__('label.users_with_most_transactions')}}",
                    pageSize: 'A4',
                    exportOptions: {
                        columns: [0, 2, 3, 4, 5]

                    },
                    customize: function(doc) {
                        doc.styles.tableHeader.fontSize = 10;
                        doc.defaultStyle.fontSize = 8;
                        doc.content[1].table.widths = ['10%', '30%', '20%', '20%', '20%'];
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

        $('#input_search').keyup(function() {
            table.draw();
        });

        var table2 = $('#author_datatable').DataTable({
            ...dataTableDefaults,
            ajax: {
                url: "{{ route('admin.customerreport.get_authors') }}",
                data: function(d) {
                    d.author_search = $('#author_search').val();
                },
            },
            columns: [{
                    data: 'DT_RowIndex',
                    name: 'DT_RowIndex',
                    orderable: false,
                    searchable: false
                },
                {
                    data: 'image',
                    name: 'image',
                    orderable: false,
                    searchable: false,
                    render: function(data, type, full, meta) {
                        return "<a href='" + data + "' target='_blank'><img src='" + data + "' class='rounded-circle size-55' ></a>";
                    },
                },
                {
                    data: 'name',
                    name: 'name',
                    render: function(data, type, row) {
                        return `<div class="text-left">${row.first_name || ''} ${row.last_name || ''}<br><span class="f-14 font-weight-bold">${row.user_name || ''}</span>`;
                    }
                },
                {
                    data: 'email',
                    name: 'email',
                    render: function(data, type, row) {
                        return `<div class="text-left">${row.mobile_number || ''}<br><span class="f-14 font-weight-bold">${row.email || ''}</span>`;
                    }
                },
                {
                    data: 'total_books',
                    name: 'total_books',
                    orderable: false,
                    searchable: false
                },
                {
                    data: 'total_earnings',
                    name: 'total_earnings',
                    orderable: false,
                    searchable: false
                },
            ],
            buttons: [{
                    extend: 'excel',
                    filename: "{{App_Name()}} - {{__('label.authors_with_most_books')}}",
                    exportOptions: {
                        columns: [0, 2, 3, 4, 5]
                    },
                    customize: function(xlsx) {
                        var sheet = xlsx.xl.worksheets['sheet1.xml'];
                        $('row:first c', sheet).attr('s', '2');
                    },
                },
                {
                    extend: 'csv',
                    filename: "{{App_Name()}} - {{__('label.authors_with_most_books')}}",
                    exportOptions: {
                        columns: [0, 2, 3, 4, 5]
                    },
                },
                {
                    extend: 'pdf',
                    title: "{{App_Name()}} - {{__('label.authors_with_most_books')}}",
                    filename: "{{App_Name()}} - {{__('label.authors_with_most_books')}}",
                    pageSize: 'A4',
                    exportOptions: {
                        columns: [0, 2, 3, 4, 5]
                    },
                    customize: function(doc) {
                        doc.styles.tableHeader.fontSize = 10;
                        doc.defaultStyle.fontSize = 8;
                        doc.content[1].table.widths = ['5%', '40%', '35%', '10%', '10%'];
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

        $('#ms_excel1').on('click', function() {

            var Demo_Mode = '{{Demo_Mode()}}';
            if (Demo_Mode == 1) {
                var table2 = $('#author_datatable').DataTable();
                table2.button('0').trigger();
            } else {
                showError();
            }
        });
        $('#csv1').on('click', function() {

            var Demo_Mode = '{{Demo_Mode()}}';
            if (Demo_Mode == 1) {
                var table2 = $('#author_datatable').DataTable();
                table2.button('1').trigger();
            } else {
                showError();
            }
        });
        $('#pdf1').on('click', function() {

            var Demo_Mode = '{{Demo_Mode()}}';
            if (Demo_Mode == 1) {
                var table2 = $('#author_datatable').DataTable();
                table2.button('2').trigger();
            } else {
                showError();
            }
        });

        $('#author_search').keyup(function() {
            table2.draw();
        });
    });
</script>
@endsection