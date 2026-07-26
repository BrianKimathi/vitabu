@extends('admin.layout.page-app')
@section('page_title', __('label.sales_report'))
@section('tab_title', __('label.sales_report'))

@section('content')
@include('admin.layout.sidebar')

<div class="right-content">
    @include('admin.layout.header')

    <div class="body-content">
        <!-- mobile title -->
        <h1 class="page-title-sm">{{__('label.sales_report')}}</h1>

        <div class="border-bottom row mb-3">
            <div class="col-sm-12">
                <ol class="breadcrumb">
                    <li class="breadcrumb-item"><a href="{{ route('admin.dashboard') }}">{{__('label.dashboard')}}</a></li>
                    <li class="breadcrumb-item active" aria-current="page">{{__('label.sales_report')}}</li>
                </ol>
            </div>
        </div>

        <!-- User & Author Statistice && Best Category -->
        <div class="row pl-3">
            <div class="col-12 col-xl-8 earning-cart-bg">
                <div class="box-title">
                    <h2 class="title"><i class="fa-solid fa-chart-line fa-lg mr-2"></i>{{__('label.content_sales_analytics')}}</h2>
                </div>
                <div class="row">
                    <div class="col-12 col-sm-12 mt-2">
                        <Button id="year" class="btn btn-default mr-2">{{__('label.this_year')}}</Button>
                        <Button id="month" class="btn btn-default mr-2">{{__('label.this_month')}}</Button>
                        <Button id="week" class="btn btn-default mr-2">{{__('label.this_week')}}</Button>
                        <Button id="today" class="btn btn-default mr-2">{{__('label.today')}}</Button>
                    </div>
                </div>
                <div class="summary-table-card mt-2">
                    <div id="Sales_Analytics_Chart"></div>
                </div>
            </div>
            <div class="col-12 col-xl-4">
                <div class="category-box">
                    <div class="box-title mt-0">
                        <h2 class="title"><i class="fa-solid fa-chart-pie fa-lg mr-2"></i>{{__('label.sales_by_content')}}</h2>
                    </div>
                    <div class="summary-table-card mt-2">
                        <div id="Sales_by_Content_Chart"></div>
                    </div>
                </div>
            </div>
        </div>
        <!-- novel  -->
        <div class="custom-border-card mt-4">
            <h5 class="card-header">{{__('label.most_selling_novels')}}</h5>

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
                    <input type="text" id="novel_search" class="form-control" placeholder="{{__('label.search')}}" aria-label="Search" aria-describedby="basic-addon1">
                </div>
            </div>

            <!-- Novel table  -->
            <div class="table-responsive table">
                <table class="table table-striped text-center table-bordered" id="novel_datatable">
                    <thead>
                        <tr class="table-bg">
                            <th>{{__('label.#')}}</th>
                            <th>{{__('label.image')}}</th>
                            <th>{{__('label.title')}}</th>
                            <th>{{__('label.author')}}</th>
                            <th>{{__('label.info')}}</th>
                            <th>{{__('label.total_sales')}}</th>
                            <th>{{__('label.total_commission')}}</th>
                            <th>{{__('label.total_author_earning')}}</th>
                        </tr>
                    </thead>
                    <tbody></tbody>
                </table>
            </div>
        </div>
        <!-- audiobook  -->
        <div class="custom-border-card mt-4">
            <h5 class="card-header">{{__('label.most_selling_audiobooks')}}</h5>

            <!-- Export Files -->
            <div class="page-search mb-3 mt-3">
                <div class="col-8">
                    <label class="text-gray pt-2 font-weight-bold"><i class="fa-solid fa-circle-info fa-2xl mr-3"></i>{{__('label.only_the_following_data_will_be_captured_in_this_file')}}</label>
                </div>
                <div class="col-4">
                    <div class="d-flex justify-content-around">
                        <button id="ms_excel2" class="btn btn-default"><i class="fa-sharp fa-solid fa-file-excel mr-2 font-weight-bold"></i>{{__('label.ms_excel')}}</button>
                        <button id="csv2" class="btn btn-default"><i class="fa-solid fa-file-csv mr-2 font-weight-bold f-18"></i>{{__('label.csv')}}</button>
                        <button id="pdf2" class="btn btn-default"><i class="fa-solid fa-file-pdf mr-2 font-weight-bold f-18"></i>{{__('label.pdf')}}</button>
                    </div>
                </div>
            </div>

            <!-- Search  -->
            <div class="page-search mb-3">
                <div class="input-group">
                    <div class="input-group-prepend">
                        <span class="input-group-text" id="basic-addon1"><i class="fa-solid fa-magnifying-glass fa-xl light-gray"></i></span>
                    </div>
                    <input type="text" id="audiobook_search" class="form-control" placeholder="{{__('label.search')}}" aria-label="Search" aria-describedby="basic-addon1">
                </div>
            </div>

            <!-- Audiobook table  -->
            <div class="table-responsive table">
                <table class="table table-striped text-center table-bordered" id="audiobook_datatable">
                    <thead>
                        <tr class="table-bg">
                            <th>{{__('label.#')}}</th>
                            <th>{{__('label.image')}}</th>
                            <th>{{__('label.title')}}</th>
                            <th>{{__('label.author')}}</th>
                            <th>{{__('label.info')}}</th>
                            <th>{{__('label.total_sales')}}</th>
                            <th>{{__('label.total_commission')}}</th>
                            <th>{{__('label.total_author_earning')}}</th>
                        </tr>
                    </thead>
                    <tbody></tbody>
                </table>
            </div>
        </div>
        <!-- magazine  -->
        <div class="custom-border-card mt-4">
            <h5 class="card-header">{{__('label.most_selling_magazines')}}</h5>

            <!-- Export Files -->
            <div class="page-search mb-3 mt-3">
                <div class="col-8">
                    <label class="text-gray pt-2 font-weight-bold"><i class="fa-solid fa-circle-info fa-2xl mr-3"></i>{{__('label.only_the_following_data_will_be_captured_in_this_file')}}</label>
                </div>
                <div class="col-4">
                    <div class="d-flex justify-content-around">
                        <button id="ms_excel3" class="btn btn-default"><i class="fa-sharp fa-solid fa-file-excel mr-2 font-weight-bold"></i>{{__('label.ms_excel')}}</button>
                        <button id="csv3" class="btn btn-default"><i class="fa-solid fa-file-csv mr-2 font-weight-bold f-18"></i>{{__('label.csv')}}</button>
                        <button id="pdf3" class="btn btn-default"><i class="fa-solid fa-file-pdf mr-2 font-weight-bold f-18"></i>{{__('label.pdf')}}</button>
                    </div>
                </div>
            </div>

            <!-- Search  -->
            <div class="page-search mb-3">
                <div class="input-group">
                    <div class="input-group-prepend">
                        <span class="input-group-text" id="basic-addon1"><i class="fa-solid fa-magnifying-glass fa-xl light-gray"></i></span>
                    </div>
                    <input type="text" id="magazine_search" class="form-control" placeholder="{{__('label.search')}}" aria-label="Search" aria-describedby="basic-addon1">
                </div>
            </div>
            <!-- Magazine table  -->
            <div class="table-responsive table">
                <table class="table table-striped text-center table-bordered" id="magazine_datatable">
                    <thead>
                        <tr class="table-bg">
                            <th>{{__('label.#')}}</th>
                            <th>{{__('label.image')}}</th>
                            <th>{{__('label.title')}}</th>
                            <th>{{__('label.author')}}</th>
                            <th>{{__('label.info')}}</th>
                            <th>{{__('label.total_sales')}}</th>
                            <th>{{__('label.total_commission')}}</th>
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
    // Get data from your Laravel controller
    let magazine_sales_year = JSON.parse(`<?php echo $magazine_sales_year ?>`);
    let novel_sales_year = JSON.parse(`<?php echo $novel_sales_year ?>`);
    let audiobook_sales_year = JSON.parse(`<?php echo $audiobook_sales_year ?>`);
    let magazine_sales_month = JSON.parse(`<?php echo $magazine_sales_month ?>`);
    let novel_sales_month = JSON.parse(`<?php echo $novel_sales_month ?>`);
    let audiobook_sales_month = JSON.parse(`<?php echo $audiobook_sales_month ?>`);
    let magazine_sales_week = JSON.parse(`<?php echo $magazine_sales_week ?>`);
    let novel_sales_week = JSON.parse(`<?php echo $novel_sales_week ?>`);
    let audiobook_sales_week = JSON.parse(`<?php echo $audiobook_sales_week ?>`);
    let magazine_sales_today = JSON.parse(`<?php echo $magazine_sales_today ?>`);
    let novel_sales_today = JSON.parse(`<?php echo $novel_sales_today ?>`);
    let audiobook_sales_today = JSON.parse(`<?php echo $audiobook_sales_today ?>`);
    let totalSales = JSON.parse(`<?php echo $total_sales ?>`);

    let chartOptions = {
        chart: {
            type: 'bar',
            height: 350,
            toolbar: {
                show: false
            }
        },
        dataLabels: {
            enabled: false
        },
        plotOptions: {
            bar: {
                horizontal: false,
                columnWidth: '70%',
                endingShape: 'rounded'
            }
        },
        markers: {
            size: 5,
        },
        fill: {
            type: 'gradient',
            gradient: {
                shade: 'light',
                type: 'vertical',
                shadeIntensity: 0.5,
                gradientToColors: ['#4e45b8'],
                inverseColors: false,
                opacityFrom: 1,
                opacityTo: 0.8,
                stops: [0, 100]
            }

        },
        colors: ['#283e50', '#E53935', '#f7971e'],
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

    let chart = new ApexCharts(document.querySelector("#Sales_Analytics_Chart"), chartOptions);
    chart.render();

    // Function to load chart data
    function loadChartData(type) {
        if (type === 'year') {
            chart.updateOptions({
                series: [{
                        name: "{{ __('label.audiobook_sales') }}",
                        data: audiobook_sales_year.sum
                    },
                    {
                        name: "{{ __('label.novel_sales') }}",
                        data: novel_sales_year.sum
                    },
                    {
                        name: "{{ __('label.magazine_sales') }}",
                        data: magazine_sales_year.sum
                    },
                ],
                xaxis: {
                    categories: audiobook_sales_year.month,
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
                        name: "{{ __('label.audiobook_sales') }}",
                        data: audiobook_sales_month.sum
                    },
                    {
                        name: "{{ __('label.novel_sales') }}",
                        data: novel_sales_month.sum
                    },
                    {
                        name: "{{ __('label.magazine_sales') }}",
                        data: magazine_sales_month.sum
                    },
                ],
                xaxis: {
                    categories: audiobook_sales_month.day
                },
            });
        } else if (type == 'week') {
            chart.updateOptions({
                series: [{
                        name: "{{ __('label.audiobook_sales') }}",
                        data: audiobook_sales_week.sum
                    },
                    {
                        name: "{{ __('label.novel_sales') }}",
                        data: novel_sales_week.sum
                    },
                    {
                        name: "{{ __('label.magazine_sales') }}",
                        data: magazine_sales_week.sum
                    },
                ],
                xaxis: {
                    categories: audiobook_sales_week.dates
                }

            });
        } else if (type == 'today') {
            chart.updateOptions({
                series: [{
                        name: "{{ __('label.audiobook_sales') }}",
                        data: audiobook_sales_today.sum
                    },
                    {
                        name: "{{ __('label.novel_sales') }}",
                        data: novel_sales_today.sum
                    },
                    {
                        name: "{{ __('label.magazine_sales') }}",
                        data: magazine_sales_today.sum
                    },
                ],
                xaxis: {
                    categories: audiobook_sales_today.time
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

    var options = {
        chart: {
            type: 'pie'
        },
        labels: totalSales.name,
        series: totalSales.sum,
        colors: ['#283e50', '#E53935', '#FB8C00', ],
        legend: {
            position: 'bottom',
            fontSize: '18'
        }
    }

    let pieChart = new ApexCharts(document.querySelector('#Sales_by_Content_Chart'), options);
    pieChart.render();



    $(function() {
        var table1 = $('#novel_datatable').DataTable({
            ...dataTableDefaults,
            ajax: {
                url: "{{ route('admin.salesreport.get_novel') }}",
                data: function(d) {
                    d.input_search = $('#novel_search').val();
                },
            },
            columns: [{
                    data: 'DT_RowIndex',
                    name: 'DT_RowIndex',
                    orderable: false,
                    searchable: false
                },
                {
                    data: 'portrait_img',
                    name: 'portrait_img',
                    orderable: false,
                    searchable: false,
                    render: function(data, type, full, meta) {
                        return `<a href='${data}' target='_blank'>
                                            <img src='${data}' class='img-thumbnail size-55'>
                                        </a>`;
                    },
                },
                {
                    data: 'title',
                    name: 'title',
                    render: function(data) {
                        return data ? '<div class="text-left f-14">' + data + '</div>' : "-";
                    }
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
                    data: 'info',
                    name: 'info',
                    render: function(data, type, row) {
                        return `<div class="text-left">${row.category?.name || ''}<br><span class="f-14 font-weight-bold">${row.language?.name || ''}</span>`;
                    }
                },
                {
                    data: 'total_sales',
                    name: 'total_sales',
                    orderable: false,
                    searchable: false
                },
                {
                    data: 'total_commission',
                    name: 'total_commission',
                    orderable: false,
                    searchable: false
                },
                {
                    data: 'total_author_earning',
                    name: 'total_author_earning',
                    orderable: false,
                    searchable: false
                },
            ],
            buttons: [{
                    extend: 'excel',
                    filename: "{{App_Name()}} - {{__('label.novel_sales_report')}}",
                    exportOptions: {
                        columns: [0, 2, 3, 4, 5, 6, 7]
                    },
                    customize: function(xlsx) {
                        var sheet = xlsx.xl.worksheets['sheet1.xml'];
                        $('row:first c', sheet).attr('s', '2');
                    },
                },
                {
                    extend: 'csv',
                    filename: "{{App_Name()}} - {{__('label.novel_sales_report')}}",
                    exportOptions: {
                        columns: [0, 2, 3, 4, 5, 6, 7]

                    },
                },
                {
                    extend: 'pdf',
                    title: "{{App_Name()}} - {{__('label.novel_sales_report')}}",
                    filename: "{{App_Name()}} - {{__('label.novel_sales_report')}}",
                    pageSize: 'A4',
                    exportOptions: {
                        columns: [0, 2, 3, 4, 5, 6, 7]

                    },
                    customize: function(doc) {
                        doc.styles.tableHeader.fontSize = 10;
                        doc.defaultStyle.fontSize = 8;
                        doc.content[1].table.widths = ['5%', '20%', '25%', '20%', '10%', '10%', '10%'];
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
                var table1 = $('#novel_datatable').DataTable();
                table1.button('0').trigger();
            } else {
                showError();
            }
        });
        $('#csv1').on('click', function() {

            var Demo_Mode = '{{Demo_Mode()}}';
            if (Demo_Mode == 1) {
                var table1 = $('#novel_datatable').DataTable();
                table1.button('1').trigger();
            } else {
                showError();
            }
        });
        $('#pdf1').on('click', function() {

            var Demo_Mode = '{{Demo_Mode()}}';
            if (Demo_Mode == 1) {
                var table1 = $('#novel_datatable').DataTable();
                table1.button('2').trigger();
            } else {
                showError();
            }
        });

        $('#novel_search').keyup(function() {
            table1.draw();
        });


        var table2 = $('#audiobook_datatable').DataTable({
            ...dataTableDefaults,
            ajax: {
                url: "{{ route('admin.salesreport.get_audiobook') }}",
                data: function(d) {
                    d.input_search = $('#audiobook_search').val();
                },
            },
            columns: [{
                    data: 'DT_RowIndex',
                    name: 'DT_RowIndex',
                    orderable: false,
                    searchable: false
                },
                {
                    data: 'portrait_img',
                    name: 'portrait_img',
                    orderable: false,
                    searchable: false,
                    render: function(data, type, full, meta) {
                        return `<a href='${data}' target='_blank'>
                                            <img src='${data}' class='img-thumbnail size-55'>
                                        </a>`;
                    },
                },
                {
                    data: 'title',
                    name: 'title',
                    render: function(data) {
                        return data ? '<div class="text-left f-14">' + data + '</div>' : "-";
                    }
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
                    data: 'info',
                    name: 'info',
                    render: function(data, type, row) {
                        return `<div class="text-left">${row.category?.name || ''}<br><span class="f-14 font-weight-bold">${row.language?.name || ''}</span>`;
                    }
                },
                {
                    data: 'total_sales',
                    name: 'total_sales',
                    orderable: false,
                    searchable: false
                },
                {
                    data: 'total_commission',
                    name: 'total_commission',
                    orderable: false,
                    searchable: false
                },
                {
                    data: 'total_author_earning',
                    name: 'total_author_earning',
                    orderable: false,
                    searchable: false
                },
            ],
            buttons: [{
                    extend: 'excel',
                    filename: "{{App_Name()}} - {{__('label.audiobook_sales_report')}}",
                    exportOptions: {
                        columns: [0, 2, 3, 4, 5, 6, 7]
                    },
                    customize: function(xlsx) {
                        var sheet = xlsx.xl.worksheets['sheet1.xml'];
                        $('row:first c', sheet).attr('s', '2');
                    },
                },
                {
                    extend: 'csv',
                    filename: "{{App_Name()}} - {{__('label.audiobook_sales_report')}}",
                    exportOptions: {
                        columns: [0, 2, 3, 4, 5, 6, 7]
                    },
                },
                {
                    extend: 'pdf',
                    title: "{{App_Name()}} - {{__('label.audiobook_sales_report')}}",
                    filename: "{{App_Name()}} - {{__('label.audiobook_sales_report')}}",
                    pageSize: 'A4',
                    exportOptions: {
                        columns: [0, 2, 3, 4, 5, 6, 7]
                    },
                    customize: function(doc) {
                        doc.styles.tableHeader.fontSize = 10;
                        doc.defaultStyle.fontSize = 8;
                        doc.content[1].table.widths = ['5%', '20%', '25%', '20%', '10%', '10%', '10%'];
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
        $('#ms_excel2').on('click', function() {

            var Demo_Mode = '{{Demo_Mode()}}';
            if (Demo_Mode == 1) {
                var table2 = $('#audiobook_datatable').DataTable();
                table2.button('0').trigger();
            } else {
                showError();
            }
        });
        $('#csv2').on('click', function() {

            var Demo_Mode = '{{Demo_Mode()}}';
            if (Demo_Mode == 1) {
                var table2 = $('#audiobook_datatable').DataTable();
                table2.button('1').trigger();
            } else {
                showError();
            }
        });
        $('#pdf2').on('click', function() {

            var Demo_Mode = '{{Demo_Mode()}}';
            if (Demo_Mode == 1) {
                var table2 = $('#audiobook_datatable').DataTable();
                table2.button('2').trigger();
            } else {
                showError();
            }
        });

        $('#audiobook_search').keyup(function() {
            table2.draw();
        });


        var table3 = $('#magazine_datatable').DataTable({
            ...dataTableDefaults,
            ajax: {
                url: "{{ route('admin.salesreport.get_magazine') }}",
                data: function(d) {
                    d.input_search = $('#magazine_search').val();
                },
            },
            columns: [{
                    data: 'DT_RowIndex',
                    name: 'DT_RowIndex',
                    orderable: false,
                    searchable: false
                },
                {
                    data: 'portrait_img',
                    name: 'portrait_img',
                    orderable: false,
                    searchable: false,
                    render: function(data, type, full, meta) {
                        return `<a href='${data}' target='_blank'>
                                            <img src='${data}' class='img-thumbnail size-55'>
                                        </a>`;
                    },
                },
                {
                    data: 'title',
                    name: 'title',
                    render: function(data) {
                        return data ? '<div class="text-left f-14">' + data + '</div>' : "-";
                    }
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
                    data: 'info',
                    name: 'info',
                    render: function(data, type, row) {
                        return `<div class="text-left">${row.category?.name || ''}<br><span class="f-14 font-weight-bold">${row.language?.name || ''}</span>`;
                    }
                },
                {
                    data: 'total_sales',
                    name: 'total_sales',
                    orderable: false,
                    searchable: false
                },
                {
                    data: 'total_commission',
                    name: 'total_commission',
                    orderable: false,
                    searchable: false
                },
                {
                    data: 'total_author_earning',
                    name: 'total_author_earning',
                    orderable: false,
                    searchable: false
                },
            ],
            buttons: [{
                    extend: 'excel',
                    filename: "{{App_Name()}} - {{__('label.magazine_sales_report')}}",
                    exportOptions: {
                        columns: [0, 2, 3, 4, 5, 6, 7]
                    },
                    customize: function(xlsx) {
                        var sheet = xlsx.xl.worksheets['sheet1.xml'];
                        $('row:first c', sheet).attr('s', '2');
                    },
                },
                {
                    extend: 'csv',
                    filename: "{{App_Name()}} - {{__('label.magazine_sales_report')}}",
                    exportOptions: {
                        columns: [0, 2, 3, 4, 5, 6, 7]
                    },
                },
                {
                    extend: 'pdf',
                    title: "{{App_Name()}} - {{__('label.magazine_sales_report')}}",
                    filename: "{{App_Name()}} - {{__('label.magazine_sales_report')}}",
                    pageSize: 'A4',
                    exportOptions: {
                        columns: [0, 2, 3, 4, 5, 6, 7]
                    },
                    customize: function(doc) {
                        doc.styles.tableHeader.fontSize = 10;
                        doc.defaultStyle.fontSize = 8;
                        doc.content[1].table.widths = ['5%', '20%', '25%', '20%', '10%', '10%', '10%'];
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
        $('#ms_excel3').on('click', function() {

            var Demo_Mode = '{{Demo_Mode()}}';
            if (Demo_Mode == 1) {
                var table3 = $('#magazine_datatable').DataTable();
                table3.button('0').trigger();
            } else {
                showError();
            }
        });
        $('#csv3').on('click', function() {

            var Demo_Mode = '{{Demo_Mode()}}';
            if (Demo_Mode == 1) {
                var table3 = $('#magazine_datatable').DataTable();
                table3.button('1').trigger();
            } else {
                showError();
            }
        });
        $('#pdf3').on('click', function() {

            var Demo_Mode = '{{Demo_Mode()}}';
            if (Demo_Mode == 1) {
                var table3 = $('#magazine_datatable').DataTable();
                table3.button('2').trigger();
            } else {
                showError();
            }
        });
        $('#magazine_search').keyup(function() {
            table3.draw();
        });
    });
</script>
@endsection