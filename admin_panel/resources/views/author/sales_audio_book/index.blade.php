@extends('author.layout.page-app')
@section('page_title', __('label.audio_book_sales_report'))
@section('tab_title', __('label.audio_book_sales_report'))

@section('content')
@include('author.layout.sidebar')

<div class="right-content">
    @include('author.layout.header')

    <!-- Select2 -->
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/select2/4.0.13/css/select2.min.css" />

    <div class="body-content">
        <!-- mobile title -->
        <h1 class="page-title-sm">{{__('label.audio_book_sales_report')}}</h1>

        <div class="border-bottom row mb-3">
            <div class="col-sm-12">
                <ol class="breadcrumb">
                    <li class="breadcrumb-item"><a href="{{ route('author.dashboard') }}">{{__('label.dashboard')}}</a></li>
                    <li class="breadcrumb-item active" aria-current="page">{{__('label.audio_book_sales_report')}}</li>
                </ol>
            </div>
        </div>

        <!-- Earning Cards -->
        <div class="row">
            <div class="col-sm-12 col-md-6 col-lg-4">
                <div class="card-earning">
                    <p class="earning-title">{{__('label.total_earning_today')}}</p>
                    <div class="card-align">
                        <div>
                            <p class="earning-amount">{{ Currency_Code() }}{{ $today_sum['total_commission'] ?? 00 }}</p>
                            <p class="earning-title">{{__('label.admin_commission')}}</p>
                        </div>
                        <div class="earning-divider"></div>
                        <div>
                            <p class="earning-amount">{{ Currency_Code() }}{{ $today_sum['total_author_earning'] ?? 00 }}</p>
                            <p class="earning-title">{{__('label.author_earnings')}}</p>
                        </div>
                    </div>
                </div>
            </div>
            <div class="col-sm-12 col-md-6 col-lg-4">
                <div class="card-earning">
                    <p class="earning-title">{{__('label.total_earning_current_month')}}</p>
                    <div class="card-align">
                        <div>
                            <p class="earning-amount">{{ Currency_Code() }}{{ $month_sum['total_commission'] ?? 00 }}</p>
                            <p class="earning-title">{{__('label.admin_commission')}}</p>
                        </div>
                        <div class="earning-divider"></div>
                        <div>
                            <p class="earning-amount">{{ Currency_Code() }}{{ $month_sum['total_author_earning'] ?? 00 }}</p>
                            <p class="earning-title">{{__('label.author_earnings')}}</p>
                        </div>
                    </div>
                </div>
            </div>
            <div class="col-sm-12 col-md-6 col-lg-4">
                <div class="card-earning">
                    <p class="earning-title">{{__('label.total_earning_current_year')}}</p>
                    <div class="card-align">
                        <div>
                            <p class="earning-amount">{{ Currency_Code() }}{{ $year_sum['total_commission'] ?? 00 }}</p>
                            <p class="earning-title">{{__('label.admin_commission')}}</p>
                        </div>
                        <div class="earning-divider"></div>
                        <div>
                            <p class="earning-amount">{{ Currency_Code() }}{{ $year_sum['total_author_earning'] ?? 00 }}</p>
                            <p class="earning-title">{{__('label.author_earnings')}}</p>
                        </div>
                    </div>
                </div>
            </div>
        </div>

        <!-- Search -->
        <div class="page-search mb-3 mt-3">
            <div class="sorting mr-2 w-50">
                <label>{{__('label.sort_by')}}</label>
                <select class="form-control" name="input_audio_book" id="input_audio_book">
                    <option value="0" selected>{{__('label.all_audio_books')}}</option>
                    @for ($i = 0; $i < count($audio_books); $i++)
                        <option value="{{ $audio_books[$i]['id'] }}">
                        {{ $audio_books[$i]['title'] }}
                        </option>
                        @endfor
                </select>
            </div>
        </div>

        <div class="table-responsive table">
            <table class="table table-striped text-center table-bordered" id="datatable">
                <thead>
                    <tr class="table-bg">
                        <th>{{__('label.#')}}</th>
                        <th>{{__('label.user')}}</th>
                        <th>{{__('label.audiobooks')}}</th>
                        <th>{{__('label.price')}}</th>
                        <th>{{__('label.admin_commission')}}</th>
                        <th>{{__('label.tax_amount')}}</th>
                        <th>{{__('label.author_earnings')}}</th>
                        <th>{{__('label.purchase_date')}}</th>
                        <th>{{__('label.status')}}</th>
                        <th>{{__('label.action')}}</th>
                    </tr>
                </thead>
                <tbody></tbody>
                <tfoot>
                    <tr class="table-bg">
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
    $("#input_audio_book").select2();

    $(document).ready(function() {
        var table = $('#datatable').DataTable({
            ...dataTableDefaults,
            ajax: {
                url: "{{ route('author.salesaudiobooks.index') }}",
                data: function(d) {
                    d.input_audio_book = $('#input_audio_book').val();
                },
            },
            columns: [{
                    data: 'DT_RowIndex',
                    name: 'DT_RowIndex',
                    orderable: false,
                    searchable: false
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
                    data: 'audio_book',
                    name: 'audio_book',
                    render: function(data, type, row, meta) {
                        if (data) {
                            let bookTitle = data.title || '';
                            let episodeTitle = row.episode?.title || '';
                            return `
                                    <div class="text-left">${bookTitle}<br>
                                        <span class="f-14 font-weight-bold">${episodeTitle}</span>
                                    </div>
                                `;
                        } else {
                            return "-";
                        }
                    }
                },
                {
                    data: 'price',
                    name: 'price',
                    render: function(data) {
                        return '<h6>' + data ?? 0 + '</h6>';
                    }
                },
                {
                    data: 'commission',
                    name: 'commission',
                    render: function(data) {
                        return '<h6>' + data ?? 0 + '</h6>';
                    }
                },
                {
                    data: 'total_tax',
                    name: 'total_tax',
                    render: function(data) {
                        return '<h6>' + data ?? 0 + '</h6>';
                    }
                },
                {
                    data: 'author_earning',
                    name: 'author_earning',
                    render: function(data) {
                        return '<h6>' + data ?? 0 + '</h6>';
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

                // converting to interger to find total
                var intVal = function(i) {
                    return typeof i === 'string' ? i.replace(/[\$,]/g, '') * 1 : typeof i === 'number' ? i : 0;
                };

                // computing column Total of the complete result 
                var Price = api.column(3).data().reduce(function(a, b) {
                    return intVal(a) + intVal(b);
                }, 0);
                var Commission = api.column(4).data().reduce(function(a, b) {
                    return intVal(a) + intVal(b);
                }, 0);
                var Author_Earning = api.column(5).data().reduce(function(a, b) {
                    return intVal(a) + intVal(b);
                }, 0);

                // Update footer by showing the total with the reference of the column index 
                $(api.column(3).footer()).html("<h6 class='primary-color'>{{Currency_Code() }}" + " " + Price + "</h6>");
                $(api.column(4).footer()).html("<h6 class='primary-color'>{{Currency_Code() }}" + " " + Commission + "</h6>");
                $(api.column(5).footer()).html("<h6 class='primary-color'>{{Currency_Code() }}" + " " + Author_Earning + "</h6>");
            },
        });

        $('#input_audio_book').change(function() {
            table.draw();
        });

        $('#datatable').on('click', '.download-invoice-btn', function() {
            var table = $('#datatable').DataTable();
            var data = table.row($(this).closest('tr')).data();
            // Base table rows
            let tableBody = [
                [{
                        text: 'Name',
                        style: 'tableHeader',
                        alignment: 'center',
                        color: 'white'
                    },
                    {
                        text: 'Price',
                        style: 'tableHeader',
                        alignment: 'center',
                        color: 'white'
                    },
                ],
                [{
                        text: data.title + '(' + 'Audio Book' + ')',
                        alignment: 'center'
                    },
                    {
                        text: '{{Currency_code()}}' + data.original_price,
                        alignment: 'center'
                    },
                ]
            ];

            if (data.coupon_code) {
                tableBody.push([{
                        text: 'Coupon (' + data.coupon_code + ')',
                        alignment: 'right',
                    },
                    {
                        text: '- {{Currency_code()}}' + data.coupon_discount,
                        alignment: 'center',
                    },
                ]);
            }
            if (data.taxes) {
                data.taxes.forEach(tax => {
                    tableBody.push([{
                            text: tax.name + '(' + tax.percentage + '%' + ')',
                            alignment: 'right',
                        },
                        {
                            text: '+ {{Currency_code()}}' + (tax.amount ?? 0),
                            alignment: 'center',
                        },
                    ]);

                });
            }
            tableBody.push([{
                    text: 'Total Amount',
                    alignment: 'right',
                },
                {
                    text: '{{Currency_code()}}' + data.price,
                    alignment: 'center',
                },
            ]);

            var docDefinition = {
                pageSize: 'A4',
                pageMargins: [0, 0, 0, 50],
                content: [{
                        table: {
                            widths: ['*', '*', '*'],
                            body: [
                                [{
                                        text: 'Invoice ID: ' + data.id,
                                        style: 'header',
                                        alignment: 'left',
                                        margin: [40, 50, 40, 10]
                                    }, {
                                        text: '<?php echo App_Name() ?>',
                                        bold: true,
                                        fontSize: 20,
                                        alignment: 'center',
                                        margin: [0, 10]
                                    },
                                    {
                                        text: 'Date: ' + data.date,
                                        style: 'header',
                                        alignment: 'right',
                                        margin: [40, 50, 40, 10]
                                    }
                                ],
                            ],
                        },
                        layout: 'noBorders',
                        fillColor: '#14532d',
                        color: '#ffffff',
                    },
                    {
                        columns: [{
                                width: '70%',
                                stack: [{
                                        text: 'Author:',
                                        style: 'userData',
                                        alignment: 'left'
                                    },
                                    {
                                        text: data.author.first_name + ' ' + data.author.last_name,
                                        style: 'userName',
                                        alignment: 'left'
                                    },
                                    {
                                        text: 'Phone: ' + data.author.mobile_number,
                                        style: 'userData',
                                        alignment: 'left'
                                    },
                                    {
                                        text: 'Email: ' + data.author.email,
                                        style: 'userData',
                                        alignment: 'left'
                                    },
                                    {
                                        text: 'Address: ' + data.author.address,
                                        style: 'userData',
                                        alignment: 'left'
                                    }
                                ],
                                margin: [40, 30, 40, 10],
                            },
                            {
                                width: '30%',
                                stack: [{
                                        text: 'User:',
                                        style: 'userData',
                                        alignment: 'left'
                                    },
                                    {
                                        text: data.user.first_name + ' ' + data.user.last_name,
                                        style: 'userName',
                                        alignment: 'left'
                                    },
                                    {
                                        text: 'Phone: ' + data.user.mobile_number,
                                        style: 'userData',
                                        alignment: 'left'
                                    },
                                    {
                                        text: 'Email: ' + data.user.email,
                                        style: 'userData',
                                        alignment: 'left'
                                    },
                                    {
                                        text: 'Address: ' + data.user.address,
                                        style: 'userData',
                                        alignment: 'left'
                                    }
                                ],
                                margin: [40, 30, 20, 10],
                            }
                        ]
                    },

                    {
                        table: {
                            widths: ['75%', '25%'],
                            body: tableBody
                        },
                        margin: [40, 40, 40, 0]
                    },
                    {
                        text: 'Thank You For Purchasing !!',
                        alignment: 'center',
                        fontSize: 13,
                        bold: true,
                        margin: [0, 100, 0, 0]
                    }
                ],
                styles: {
                    header: {
                        fontSize: 12,
                        bold: true
                    },
                    tableHeader: {
                        fillColor: '#0e3d21',

                    },
                    userData: {
                        fontSize: 10,
                    },
                    userName: {
                        bold: true,
                        margin: [0, 0, 0, 5]
                    },
                    amount: {
                        fontSize: 10,
                        alignment: 'right',
                        margin: [0, 0, 8, 0],
                    },
                    totalPrice: {
                        fontSize: 11,
                        fillColor: '#0e3d21',
                        alignment: 'right',
                        color: 'white',
                        margin: [0, 1, 8, 1]
                    },
                }
            };

            pdfMake.createPdf(docDefinition).download('{{__("label.audiobook_sales_invoice")}}' + data.id + '.pdf');
        });

    });
</script>
@endsection