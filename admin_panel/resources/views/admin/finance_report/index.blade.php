@extends('admin.layout.page-app')
@section('page_title', __('label.finance_report'))
@section('tab_title', __('label.finance_report'))

@section('content')
@include('admin.layout.sidebar')

<div class="right-content">
    @include('admin.layout.header')

    <div class="body-content">
        <!-- mobile title -->
        <h1 class="page-title-sm">{{__('label.finance_report')}}</h1>

        <div class="border-bottom row mb-3">
            <div class="col-sm-12">
                <ol class="breadcrumb">
                    <li class="breadcrumb-item"><a href="{{ route('admin.dashboard') }}">{{__('label.dashboard')}}</a></li>
                    <li class="breadcrumb-item active" aria-current="page">{{__('label.finance_report')}}</li>
                </ol>
            </div>
        </div>
        <!-- Card -->
        <div class="row counter-row">
            <div class="col-xl-4 col-sm-6 col-12 mb-4">
                <div class="card custom-card card-color-primary">
                    <div class="card-body">
                        <div class="card-icon-primary card-color-primary">
                            <i class="fa-solid fa-coins fa-2x"></i>
                        </div>
                        <div class="text-right">
                            <h3>{{NO_Format($CommissionCount ?? 0)}}</h3>
                            <span>{{__('label.total_commission_earning')}}</span>
                        </div>
                    </div>
                </div>
            </div>
            <div class="col-xl-4 col-sm-6 col-12 mb-4">
                <div class="card custom-card card-color-primary">
                    <div class="card-body">
                        <div class="card-icon-primary card-color-primary">
                            <i class="fa-solid fa-percentage fa-2x"></i>
                        </div>
                        <div class="text-right">
                            <h3>{{No_Format($TaxCount ?? 0)}}</h3>
                            <span>{{__('label.total_tax_payout')}}</span>
                        </div>
                    </div>
                </div>
            </div>
            <!-- temporary hidden  -->
            <!-- <div class="col-xl-4 col-sm-6 col-12 mb-4">
                <div class="card custom-card card-color-primary">
                    <div class="card-body">
                        <div class="card-icon-primary card-color-primary">
                            <i class="fa-solid fa-money-bill-transfer fa-2x"></i>
                        </div>
                        <div class="text-right">
                            <h3>{{No_Format($WithdrawelCount ?? 0)}}</h3>
                            <span>{{__('label.total_withdrawal_request')}}</span>
                        </div>
                    </div>
                </div>
            </div> -->
        </div>
        <!-- Commission Overview -->
        <div class="row pl-3 mb-4">
            <div class="col-12 earning-cart-bg">
                <div class="box-title">
                    <h2 class="title"><i class="fa-solid fa-coins fa-lg mr-2"></i>{{__('label.commission_overview')}}</h2>
                </div>
                <div class="row">
                    <div class="col-12 col-sm-12 mt-2">
                        <Button id="year1" class="btn btn-default">{{__('label.this_year')}}</Button>
                        <Button id="month1" class="btn btn-default">{{__('label.this_month')}}</Button>
                        <Button id="week1" class="btn btn-default">{{__('label.this_week')}}</Button>
                        <Button id="today1" class="btn btn-default">{{__('label.today')}}</Button>
                    </div>
                </div>
                <div class="summary-table-card mt-2">
                    <div id="Commission_Overview_Chart"></div>
                </div>
            </div>
        </div>
        <div class="row pl-3 mb-4">
            <div class="col-12 earning-cart-bg">
                <div class="box-title">
                    <h2 class="title"><i class="fa-solid fa-percentage fa-lg mr-2"></i>{{__('label.tax_payout_overview')}}</h2>
                </div>
                <div class="summary-table-card mt-2">
                    <div id="tax_payout_Overview_Chart"></div>
                </div>
            </div>
        </div>
        <!-- temporary hidden -->
        <!-- Withdrawel  -->
        <!-- <div class="custom-border-card">
            <h5 class="card-header">{{__('label.recent_withdrawals')}}</h5>

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

            <div class="page-search mb-3">
                <div class="input-group">
                    <div class="input-group-prepend">
                        <span class="input-group-text" id="basic-addon1"><i class="fa-solid fa-magnifying-glass fa-xl light-gray"></i></span>
                    </div>
                    <input type="text" id="novel_search" class="form-control" placeholder="{{__('label.search')}}" aria-label="Search" aria-describedby="basic-addon1">
                </div>
            </div>

            <div class="table-responsive table">
                <table class="table table-striped text-center table-bordered" id="datatable">
                    <thead>
                        <tr class="table-bg">
                            <th>{{__('label.#')}}</th>
                            <th>{{__('label.authors')}}</th>
                            <th>{{__('label.price')}}</th>
                            <th>{{__('label.type')}}</th>
                            <th>{{__('label.details')}}</th>
                            <th>{{__('label.date')}}</th>
                            <th>{{__('label.status')}}</th>
                        </tr>
                    </thead>
                    <tbody></tbody>
                </table>
            </div>
        </div> -->
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
    let commissionYear = JSON.parse(`<?php echo $commission_year ?>`);
    let commissionMonth = JSON.parse(`<?php echo $commission_month ?>`);
    let commissionWeek = JSON.parse(`<?php echo $commission_week ?>`);
    let commissionToday = JSON.parse(`<?php echo $commission_today ?>`);
    let taxArray = JSON.parse(`<?php echo $tax_array ?>`);

    let chartOptions = {
        chart: {
            type: 'area',
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
        colors: ['#283e50'],
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

    let chart = new ApexCharts(document.querySelector("#Commission_Overview_Chart"), chartOptions);
    chart.render();

    // Function to load chart data
    function loadChartData(type) {
        if (type === 'year') {
            chart.updateOptions({
                series: [{
                    name: "{{ __('label.commission') }}",
                    data: commissionYear.sum
                }, ],
                xaxis: {
                    categories: commissionYear.month,
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
                    name: "{{ __('label.commission') }}",
                    data: commissionMonth.sum
                }, ],
                xaxis: {
                    categories: commissionMonth.day
                },
            });
        } else if (type == 'week') {
            chart.updateOptions({
                series: [{
                    name: "{{ __('label.commission') }}",
                    data: commissionWeek.sum
                }, ],
                xaxis: {
                    categories: commissionWeek.dates
                }

            });
        } else if (type == 'today') {
            chart.updateOptions({
                series: [{
                    name: "{{ __('label.commission') }}",
                    data: commissionToday.sum
                }, ],
                xaxis: {
                    categories: commissionToday.hour
                }

            });
        }
    }

    loadChartData('year');
    document.getElementById('year1').addEventListener('click', function() {
        loadChartData('year');
    });
    document.getElementById('month1').addEventListener('click', function() {
        loadChartData('month');
    });
    document.getElementById('week1').addEventListener('click', function() {
        loadChartData('week');
    });
    document.getElementById('today1').addEventListener('click', function() {
        loadChartData('today');
    });

    let chart2Options = {
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
                columnWidth: 100,
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
                inverseColors: false,
                opacityFrom: 1,
                opacityTo: 0.8,
                stops: [0, 100]
            }
        },
        colors: ['#283e50', '#f7971e', '#f54ea2', '#2af598'],
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
        series: taxArray.series,
        xaxis: {
            categories: taxArray.months
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
    let chart2 = new ApexCharts(document.querySelector("#tax_payout_Overview_Chart"), chart2Options);
    chart2.render();

    // temporary hidden
    // $(function() {
    //     var table1 = $('#datatable').DataTable({
    //         ...dataTableDefaults,
    //         ajax: {
    //             url: "{{ route('admin.financereport.get_withdrawels') }}",
    //             data: function(d) {
    //                 d.input_search = $('#novel_search').val();
    //             },
    //         },
    //         columns: [{
    //                 data: 'DT_RowIndex',
    //                 name: 'DT_RowIndex',
    //                 orderable: false,
    //                 searchable: false
    //             },
    //             {
    //                 data: 'author',
    //                 name: 'author',
    //                 render: function(data) {
    //                     if (data) {
    //                         return '<div class="text-left">' + data.first_name + ' ' + data.last_name + '<br><span class="f-14 font-weight-bold">' + data.user_name + '</span></div>';
    //                     } else {
    //                         return "-";
    //                     }
    //                 }
    //             },
    //             {
    //                 data: 'price',
    //                 name: 'price',
    //                 render: function(data) {
    //                     return data ? data : "-";
    //                 }
    //             },
    //             {
    //                 data: 'payment_type',
    //                 name: 'payment_type',
    //                 render: function(data) {
    //                     return data ? data : "-";
    //                 }
    //             },
    //             {
    //                 data: 'payment_detail',
    //                 name: 'payment_detail',
    //                 render: function(data) {
    //                     return data ? data : "-";
    //                 }
    //             },
    //             {
    //                 data: 'date',
    //                 name: 'date'
    //             },
    //             {
    //                 data: 'status',
    //                 name: 'status',
    //                 orderable: false,
    //                 searchable: false,
    //             },
    //         ],
    //         buttons: [{
    //                 extend: 'excel',
    //                 filename: "{{App_Name()}} - {{__('label.recent_withdrawal_request')}}",
    //                 exportOptions: {
    //                     columns: [0, 1, 2, 3, 4, 5]
    //                 },
    //                 customize: function(xlsx) {
    //                     var sheet = xlsx.xl.worksheets['sheet1.xml'];
    //                     $('row:first c', sheet).attr('s', '2');
    //                 },
    //             },
    //             {
    //                 extend: 'csv',
    //                 filename: "{{App_Name()}} - {{__('label.recent_withdrawal_request')}}",
    //                 exportOptions: {
    //                     columns: [0, 1, 2, 3, 4, 5]


    //                 },
    //             },
    //             {
    //                 extend: 'pdf',
    //                 title: "{{App_Name()}} - {{__('label.recent_withdrawal_request')}}",
    //                 filename: "{{App_Name()}} - {{__('label.recent_withdrawal_request')}}",
    //                 pageSize: 'A4',
    //                 exportOptions: {
    //                     columns: [0, 1, 2, 3, 4, 5]


    //                 },
    //                 customize: function(doc) {
    //                     doc.styles.tableHeader.fontSize = 10;
    //                     doc.defaultStyle.fontSize = 8;
    //                     doc.content[1].table.widths = ['5%', '30%', '25%', '20%', '10%', '10%'];
    //                     doc.content[1].layout = "borders";
    //                     doc.styles.title.fontSize = 22;
    //                     doc.styles.title.alignment = 'center';
    //                     doc.defaultStyle.alignment = 'center';

    //                     // Create a header
    //                     doc['header'] = (function(page, pages) {
    //                         return {
    //                             columns: [{
    //                                     alignment: 'left',
    //                                     bold: true,
    //                                     text: "{{App_Name()}}",
    //                                 },
    //                                 {
    //                                     alignment: 'right',
    //                                     bold: true,
    //                                     text: ['Total Page ', {
    //                                         text: pages.toString()
    //                                     }],
    //                                 }
    //                             ],
    //                             margin: [20, 20],
    //                         }
    //                     });
    //                     // Create a footer
    //                     doc['footer'] = (function(page, pages) {
    //                         return {
    //                             columns: [{
    //                                 alignment: 'center',
    //                                 bold: true,
    //                                 text: ['Page ', {
    //                                     text: page.toString()
    //                                 }, ' of ', {
    //                                     text: pages.toString()
    //                                 }],
    //                             }],
    //                         }
    //                     });
    //                 }
    //             }
    //         ],
    //     });
    //     $('#ms_excel1').on('click', function() {

    //         var Demo_Mode = '{{Demo_Mode()}}';
    //         if (Demo_Mode == 1) {
    //             var table1 = $('#datatable').DataTable();
    //             table1.button('0').trigger();
    //         } else {
    //             showError();
    //         }
    //     });
    //     $('#csv1').on('click', function() {

    //         var Demo_Mode = '{{Demo_Mode()}}';
    //         if (Demo_Mode == 1) {
    //             var table1 = $('#datatable').DataTable();
    //             table1.button('1').trigger();
    //         } else {
    //             showError();
    //         }
    //     });
    //     $('#pdf1').on('click', function() {

    //         var Demo_Mode = '{{Demo_Mode()}}';
    //         if (Demo_Mode == 1) {
    //             var table1 = $('#datatable').DataTable();
    //             table1.button('2').trigger();
    //         } else {
    //             showError();
    //         }
    //     });

    //     $('#novel_search').keyup(function() {
    //         table1.draw();
    //     });

    // });
</script>
@endsection