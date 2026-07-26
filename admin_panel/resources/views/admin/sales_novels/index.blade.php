@extends('admin.layout.page-app')
@section('page_title', __('label.novel_sales_report'))
@section('tab_title', __('label.novel_sales_report'))

@section('content')
@include('admin.layout.sidebar')

<div class="right-content">
    @include('admin.layout.header')

    <!-- Select2 -->
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/select2/4.0.13/css/select2.min.css" />

    <div class="body-content">
        <!-- mobile title -->
        <h1 class="page-title-sm">{{__('label.novel_sales_report')}}</h1>

        <div class="border-bottom row mb-3">
            <div class="col-sm-10">
                <ol class="breadcrumb">
                    <li class="breadcrumb-item"><a href="{{ route('admin.dashboard') }}">{{__('label.dashboard')}}</a></li>
                    <li class="breadcrumb-item active" aria-current="page">{{__('label.novel_sales_report')}}</li>
                </ol>
            </div>
            <div class="col-md-2 d-flex align-items-center justify-content-end mb-4">
                <a href="{{route('admin.salesnovels.create')}}" class="btn btn-default mw-120">{{__('label.add_sales_report')}}</a>
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
                            <p class="earning-title">{{__('label.commission')}}</p>
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
                            <p class="earning-title">{{__('label.commission')}}</p>
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
                            <p class="earning-title">{{__('label.commission')}}</p>
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
        <div class="page-search my-3">
            <div class="sorting mr-2 w-25">
                <label>{{__('label.sort_by')}}</label>
                <select class="form-control" name="input_user" id="input_user">
                    <option value="0" selected>{{__('label.all_users')}}</option>
                    @for ($i = 0; $i < count($user); $i++)
                        <option value="{{ $user[$i]['id'] }}">
                        {{ $user[$i]['first_name'] }} {{ $user[$i]['last_name'] }}
                        </option>
                        @endfor
                </select>
            </div>
            <div class="sorting mr-2 w-25">
                <select class="form-control" name="input_author" id="input_author">
                    <option value="0" selected>{{__('label.all_authors')}}</option>
                    @for ($i = 0; $i < count($author); $i++)
                        <option value="{{ $author[$i]['id'] }}">
                        {{ $author[$i]['first_name'] }} {{ $author[$i]['last_name'] }}
                        </option>
                        @endfor
                </select>
            </div>
            <div class="sorting mr-2 w-25">
                <select class="form-control" name="input_novel" id="input_novel">
                    <option value="0" selected>{{__('label.all_novels')}}</option>
                    @for ($i = 0; $i < count($novels); $i++)
                        <option value="{{ $novels[$i]['id'] }}">
                        {{ $novels[$i]['title'] }}
                        </option>
                        @endfor
                </select>
            </div>
            <div class="sorting mr-2 w-25">
                <select class="form-control" name="input_chapter" id="input_chapter">
                    <option value="0" selected>{{__('label.all_chapters')}}</option>
                </select>
            </div>
        </div>

        <div class="table-responsive table">
            <table class="table table-striped text-center table-bordered" id="datatable">
                <thead>
                    <tr class="table-bg">
                        <th>{{__('label.#')}}</th>
                        <th>{{__('label.coupon_code')}}</th>
                        <th>{{__('label.user')}}</th>
                        <th>{{__('label.author')}}</th>
                        <th>{{__('label.novel')}}</th>
                        <th>{{__('label.price')}}</th>
                        <th>{{__('label.commission')}}</th>
                        <th>{{__('label.tax_amount')}}</th>
                        <th>{{__('label.author_earning')}}</th>
                        <th>{{__('label.transaction_id')}}</th>
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
    // Sidebar Scroll Down
    sidebar_down($(document).height());

    $("#input_user").select2();
    $("#input_author").select2();
    $("#input_novel").select2();
    $("#input_chapter").select2();

    $(document).ready(function() {
        var table = $('#datatable').DataTable({
            ...dataTableDefaults,
            ajax: {
                url: "{{ route('admin.salesnovels.index') }}",
                data: function(d) {
                    d.input_user = $('#input_user').val();
                    d.input_author = $('#input_author').val();
                    d.input_novel = $('#input_novel').val();
                    d.input_chapter = $('#input_chapter').val();
                },
            },
            columns: [{
                    data: 'DT_RowIndex',
                    name: 'DT_RowIndex',
                    orderable: false,
                    searchable: false
                },
                {
                    data: 'coupon_code',
                    name: 'coupon_code',
                    orderable: false,
                    render: function(data) {
                        if (data) {
                            return data;
                        } else {
                            return "-";
                        }
                    },
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
                    data: 'novel',
                    name: 'novel',
                    render: function(data, type, row, meta) {
                        if (data) {
                            let bookTitle = data.title || '';
                            let chapterTitle = row.chapter?.title || '';
                            return `
                                    <div class="text-left">${bookTitle}<br>
                                        <span class="f-14 font-weight-bold">${chapterTitle}</span>
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
                    data: 'transaction_id',
                    name: 'transaction_id',
                    orderable: false,
                    render: function(data) {
                        if (data) {
                            return data;
                        } else {
                            return "-";
                        }
                    },
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
                var Price = api.column(5).data().reduce(function(a, b) {
                    return intVal(a) + intVal(b);
                }, 0);
                var Commission = api.column(6).data().reduce(function(a, b) {
                    return intVal(a) + intVal(b);
                }, 0);
                var Author_Earning = api.column(8).data().reduce(function(a, b) {
                    return intVal(a) + intVal(b);
                }, 0);
                var Total_Tax = api.column(7).data().reduce(function(a, b) {
                    return intVal(a) + intVal(b);
                }, 0);

                // Update footer by showing the total with the reference of the column index 
                $(api.column(5).footer()).html("<h6 class='primary-color'>{{Currency_Code() }}" + " " + Price + "</h6>");
                $(api.column(6).footer()).html("<h6 class='primary-color'>{{Currency_Code() }}" + " " + Commission + "</h6>");
                $(api.column(7).footer()).html("<h6 class='primary-color'>{{Currency_Code() }}" + " " + Total_Tax + "</h6>");
                $(api.column(8).footer()).html("<h6 class='primary-color'>{{Currency_Code() }}" + " " + Author_Earning + "</h6>");
            },
        });

        $('#input_user, #input_author, #input_novel, #input_chapter').change(function() {
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
                        text: data.title + '(' + 'Novel' + ')',
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
                        text: '- {{Currency_code()}}' + (data.coupon_discount ?? "0"),
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

            pdfMake.createPdf(docDefinition).download('{{__("label.novel_sales_invoice")}}' + data.id + '.pdf');
        });


        $('#input_novel').change(function() {
            var id = $(this).children("option:selected").val();

            $('#input_chapter').empty('');
            $('#input_chapter').append('<option value="" selected>{{__("label.all_chapters")}}</option>');
            $.ajax({
                headers: {
                    'X-CSRF-TOKEN': $('meta[name="csrf-token"]').attr('content')
                },
                type: 'POST',
                url: '{{ route("admin.salesnovels.get_episode") }}',
                data: {
                    id: id
                },
                success: function(resp) {
                    for (i = 0; i < resp.result.length; i++) {
                        $('#input_chapter').append('<option value="' + resp.result[i]['id'] + '">' + resp.result[i]['title'] + '</option>');
                    }
                },
                error: function(XMLHttpRequest, textStatus, errorThrown) {
                    toastr.error(errorThrown, textStatus);
                }

            })
        });
    });
</script>
@endsection