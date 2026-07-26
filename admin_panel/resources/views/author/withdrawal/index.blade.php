@extends('author.layout.page-app')
@section('page_title', __('label.withdrawal_request'))
@section('tab_title', __('label.withdrawal_request'))

@section('content')
    @include('author.layout.sidebar')

    <!-- Select2 & Custom Styles -->
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/select2/4.0.13/css/select2.min.css" />
    <style>
        .withdrawal-hero-card {
            background: linear-gradient(135deg, #1E1B4B 0%, #4E45B8 50%, #312E81 100%);
            border: none;
            border-radius: 16px;
            color: #ffffff;
            box-shadow: 0 10px 25px -5px rgba(78, 69, 184, 0.3);
        }
        .withdrawal-stat-icon {
            width: 56px;
            height: 56px;
            border-radius: 14px;
            background: rgba(255, 255, 255, 0.15);
            backdrop-filter: blur(10px);
            display: flex;
            align-items: center;
            justify-content: center;
            color: #ffffff;
        }
        .modern-card {
            background: #ffffff;
            border: 1px solid #E2E8F0;
            border-radius: 16px;
            box-shadow: 0 4px 6px -1px rgba(15, 23, 42, 0.05);
            overflow: hidden;
            margin-bottom: 24px;
        }
        .modern-card .card-header {
            background: #F8FAFC;
            border-bottom: 1px solid #E2E8F0;
            padding: 16px 24px;
            font-weight: 700;
            color: #0F172A;
            font-size: 1.05rem;
            display: flex;
            align-items: center;
            gap: 10px;
        }
        .modern-card .card-body {
            padding: 24px;
        }
        .form-control-modern {
            border-radius: 10px;
            border: 1px solid #CBD5E1;
            padding: 10px 14px;
            font-size: 0.925rem;
            transition: all 0.2s ease;
        }
        .form-control-modern:focus {
            border-color: #4E45B8;
            box-shadow: 0 0 0 3px rgba(78, 69, 184, 0.15);
        }
        .btn-modern-primary {
            background: linear-gradient(135deg, #4E45B8 0%, #3B3398 100%);
            color: #ffffff;
            border: none;
            border-radius: 10px;
            padding: 10px 24px;
            font-weight: 600;
            transition: all 0.2s ease;
            box-shadow: 0 4px 12px rgba(78, 69, 184, 0.25);
        }
        .btn-modern-primary:hover {
            transform: translateY(-1px);
            box-shadow: 0 6px 16px rgba(78, 69, 184, 0.35);
            color: #ffffff;
        }
        .modern-table-card {
            border-radius: 16px;
            border: 1px solid #E2E8F0;
            background: #ffffff;
            box-shadow: 0 4px 6px -1px rgba(15, 23, 42, 0.05);
            padding: 20px;
        }
    </style>

    <div class="right-content">
        @include('author.layout.header')

        <div class="body-content">
            <!-- Mobile title -->
            <h1 class="page-title-sm">{{ __('label.withdrawal_request') }}</h1>

            <div class="border-bottom row mb-4 pb-2">
                <div class="col-sm-12">
                    <ol class="breadcrumb bg-transparent p-0 m-0">
                        <li class="breadcrumb-item"><a href="{{ route('author.dashboard') }}" class="text-primary">{{ __('label.dashboard') }}</a></li>
                        <li class="breadcrumb-item active" aria-current="page">{{ __('label.withdrawal_request') }}</li>
                    </ol>
                </div>
            </div>

            <!-- Stats Card -->
            <div class="row mb-4">
                <div class="col-xl-4 col-md-6 col-12">
                    <div class="card withdrawal-hero-card">
                        <div class="card-body d-flex align-items-center justify-content-between p-4">
                            <div>
                                <span class="text-uppercase text-white-50 font-weight-bold" style="letter-spacing: 0.5px; font-size: 0.8rem;">
                                    {{ __('label.wallet_amount') }}
                                </span>
                                <h2 class="mb-0 mt-1 font-weight-bold">{{ $authorData['wallet_amount'] ?? 0 }}</h2>
                            </div>
                            <div class="withdrawal-stat-icon">
                                <i class="fa-solid fa-wallet fa-xl"></i>
                            </div>
                        </div>
                    </div>
                </div>
            </div>

            <!-- Add Withdrawal Request Form -->
            <div class="modern-card">
                <div class="card-header">
                    <i class="fa-solid fa-money-bill-transfer text-primary"></i>
                    <span>{{ __('label.add_withdrawal_request') }}</span>
                </div>
                <div class="card-body">
                    <form id="request" enctype="multipart/form-data">
                        <input type="hidden" name="id" value="">
                        <div class="form-row">
                            <div class="col-md-3">
                                <div class="form-group">
                                    <label class="font-weight-600 text-dark">{{ __('label.price') }} <span class="text-danger">*</span></label>
                                    <input type="number" name="price" min="1" class="form-control form-control-modern" placeholder="{{ __('label.price_here') }}" autofocus>
                                </div>
                            </div>
                            <div class="col-md-3">
                                <div class="form-group">
                                    <label class="font-weight-600 text-dark">{{ __('label.payment_type') }}</label>
                                    <input type="text" class="form-control form-control-modern bg-light" readonly id="current_payment_type"
                                        value="{{ ($authorData['payment_method'] ?? '') === 'mpesa' ? 'Mpesa' : 'Bank' }}">
                                </div>
                            </div>
                            <div class="col-md-6">
                                <div class="form-group">
                                    <label class="font-weight-600 text-dark">{{ __('label.payment_detail') }}</label>
                                    <textarea class="form-control form-control-modern bg-light" rows="2" readonly id="current_payment_detail">@if(($authorData['payment_method'] ?? '') === 'mpesa')Mpesa Phone: {{ $authorData['mpesa_phone'] ?? '' }}@else Bank: {{ $authorData['bank_name'] ?? '' }}; Holder: {{ $authorData['bank_holder_name'] ?? '' }}; A/C: {{ $authorData['account_no'] ?? '' }}@endif</textarea>
                                </div>
                            </div>
                        </div>
                        <div class="border-top pt-3 text-right">
                            <button type="button" class="btn btn-modern-primary mw-120" onclick="save_request()">
                                <i class="fa-solid fa-paper-plane mr-1"></i> {{ __('label.save') }}
                            </button>
                            <input type="hidden" name="_token" value="{{ csrf_token() }}">
                        </div>
                    </form>
                </div>
            </div>

            <!-- Update Payout Details Form -->
            <div class="modern-card">
                <div class="card-header">
                    <i class="fa-solid fa-credit-card text-primary"></i>
                    <span>Update Payout Details</span>
                </div>
                <div class="card-body">
                    <form id="payout_details_form" enctype="multipart/form-data">
                        <div class="form-row mb-2">
                            <div class="col-md-4">
                                <div class="form-group">
                                    <label class="font-weight-600 text-dark">Payment Method <span class="text-danger">*</span></label>
                                    <select name="payment_method" id="payment_method" class="form-control form-control-modern">
                                        <option value="bank" {{ ($authorData['payment_method'] ?? 'bank') == 'bank' ? 'selected' : '' }}>Bank</option>
                                        <option value="mpesa" {{ ($authorData['payment_method'] ?? '') == 'mpesa' ? 'selected' : '' }}>Mpesa</option>
                                    </select>
                                </div>
                            </div>
                        </div>

                        <div id="bank_fields" style="{{ ($authorData['payment_method'] ?? 'bank') == 'bank' ? '' : 'display:none;' }}">
                            <div class="form-row">
                                <div class="col-md-4">
                                    <div class="form-group">
                                        <label class="font-weight-600 text-dark">Select Bank <span class="text-danger">*</span></label>
                                        <select class="form-control form-control-modern" name="bank_code" id="bank_code">
                                            <option value="">Select Bank</option>
                                            @foreach(($paystackBanks ?? []) as $bank)
                                                <option value="{{ $bank['code'] ?? '' }}" data-name="{{ $bank['name'] ?? '' }}"
                                                    {{ (($authorData['bank_code'] ?? '') == ($bank['code'] ?? '')) ? 'selected' : '' }}>
                                                    {{ $bank['name'] ?? '' }}
                                                </option>
                                            @endforeach
                                        </select>
                                    </div>
                                </div>
                                <div class="col-md-4">
                                    <div class="form-group">
                                        <label class="font-weight-600 text-dark">{{ __('label.bank_name') }} <span class="text-danger">*</span></label>
                                        <input type="text" class="form-control form-control-modern" id="bank_name" name="bank_name"
                                            value="{{ $authorData['bank_name'] ?? '' }}" placeholder="{{ __('label.bank_name_here') }}">
                                    </div>
                                </div>
                                <div class="col-md-4">
                                    <div class="form-group">
                                        <label class="font-weight-600 text-dark">{{ __('label.bank_holder_name') }} <span class="text-danger">*</span></label>
                                        <input type="text" class="form-control form-control-modern" name="bank_holder_name"
                                            value="{{ $authorData['bank_holder_name'] ?? '' }}" placeholder="{{ __('label.bank_holder_name_here') }}">
                                    </div>
                                </div>
                            </div>
                            <div class="form-row">
                                <div class="col-md-4">
                                    <div class="form-group">
                                        <label class="font-weight-600 text-dark">{{ __('label.account_no') }} <span class="text-danger">*</span></label>
                                        <input type="text" class="form-control form-control-modern" name="account_no"
                                            value="{{ $authorData['account_no'] ?? '' }}" placeholder="{{ __('label.account_no_here') }}">
                                    </div>
                                </div>
                                <div class="col-md-4">
                                    <div class="form-group">
                                        <label class="font-weight-600 text-dark">{{ __('label.ifsc_code') }}</label>
                                        <input type="text" class="form-control form-control-modern" name="ifsc_code"
                                            value="{{ $authorData['ifsc_code'] ?? '' }}" placeholder="{{ __('label.ifsc_code_here') }}">
                                    </div>
                                </div>
                            </div>
                        </div>

                        <div id="mpesa_fields" style="{{ ($authorData['payment_method'] ?? 'bank') == 'mpesa' ? '' : 'display:none;' }}">
                            <div class="form-row">
                                <div class="col-md-4">
                                    <div class="form-group">
                                        <label class="font-weight-600 text-dark">Mpesa Phone <span class="text-danger">*</span></label>
                                        <input type="text" class="form-control form-control-modern" name="mpesa_phone"
                                            value="{{ $authorData['mpesa_phone'] ?? '' }}" placeholder="2547XXXXXXXX">
                                    </div>
                                </div>
                            </div>
                        </div>
                        <div class="border-top pt-3 text-right">
                            <button type="button" class="btn btn-modern-primary mw-120" onclick="update_payout_details()">
                                <i class="fa-solid fa-arrows-rotate mr-1"></i> {{ __('label.update') }}
                            </button>
                            <input type="hidden" name="_token" value="{{ csrf_token() }}">
                        </div>
                    </form>
                </div>
            </div>

            <!-- Withdrawal History Table -->
            <div class="modern-table-card mt-3">
                <h5 class="mb-3 font-weight-700 text-dark"><i class="fa-solid fa-clock-rotate-left text-primary mr-2"></i>Withdrawal History</h5>
                <div class="table-responsive">
                    <table class="table table-striped text-center table-bordered" id="datatable">
                        <thead>
                            <tr class="table-bg">
                                <th>{{ __('label.#') }}</th>
                                <th>{{ __('label.requested_amount') }}</th>
                                <th>{{ __('label.payment_type') }}</th>
                                <th>{{ __('label.payment_details') }}</th>
                                <th>{{ __('label.request_date') }}</th>
                                <th>{{ __('label.action') }}</th>
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
    <script>
        $(document).ready(function() {
            var table = $('#datatable').DataTable({
                ...dataTableDefaults,
                ajax: {
                    url: "{{ route('author.withdrawal.index') }}",
                },
                columns: [
                    { data: 'DT_RowIndex', name: 'DT_RowIndex', orderable: false, searchable: false },
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
                    { data: 'action', name: 'action', orderable: false, searchable: false },
                ],
            });
        });
        
        function save_request(){
            var Demo_Mode = '<?php echo Demo_Mode(); ?>';
            if(Demo_Mode == 1){
                $("#dvloader").show();
                var formData = new FormData($("#request")[0]);
                $.ajax({
                    type:'POST',
                    url:'{{ route("author.withdrawal.store") }}',
                    data:formData,
                    cache:false,
                    contentType: false,
                    processData: false,
                    success:function(resp){
                        $("#dvloader").hide();
                        get_responce_message(resp, 'request', '{{ route("author.withdrawal.index") }}');
                    },
                    error: function(XMLHttpRequest, textStatus, errorThrown) {
                        $("#dvloader").hide();
                        toastr.error(errorThrown, textStatus);
                    }
                });
            } else {
                showError();
            }
        }

        function refreshPaymentPreview() {
            const method = ($('#payment_method').val() || 'bank').toLowerCase();
            if (method === 'mpesa') {
                $('#current_payment_type').val('Mpesa');
                const phone = ($("input[name='mpesa_phone']").val() || '').trim();
                $('#current_payment_detail').val('Mpesa Phone: ' + phone);
            } else {
                $('#current_payment_type').val('Bank');
                const bank = ($('#bank_name').val() || '').trim();
                const holder = ($("input[name='bank_holder_name']").val() || '').trim();
                const account = ($("input[name='account_no']").val() || '').trim();
                $('#current_payment_detail').val('Bank: ' + bank + '; Holder: ' + holder + '; A/C: ' + account);
            }
        }

        function togglePayoutFields() {
            const method = ($('#payment_method').val() || 'bank').toLowerCase();
            if (method === 'mpesa') {
                $('#bank_fields').hide();
                $('#mpesa_fields').show();
            } else {
                $('#mpesa_fields').hide();
                $('#bank_fields').show();
            }
            refreshPaymentPreview();
        }

        $('#payment_method').on('change', togglePayoutFields);
        $('#bank_code').on('change', function() {
            const name = $('#bank_code option:selected').data('name') || '';
            if (name) $('#bank_name').val(name);
            refreshPaymentPreview();
        });
        $("input[name='mpesa_phone'], #bank_name, input[name='bank_holder_name'], input[name='account_no']").on('input', refreshPaymentPreview);

        function update_payout_details() {
            var Demo_Mode = '<?php echo Demo_Mode(); ?>';
            if (Demo_Mode == 1) {
                $("#dvloader").show();
                var formData = new FormData($("#payout_details_form")[0]);
                $.ajax({
                    type: 'POST',
                    url: '{{ route("author.withdrawal.payout.update") }}',
                    data: formData,
                    cache: false,
                    contentType: false,
                    processData: false,
                    success: function(resp) {
                        $("#dvloader").hide();
                        get_responce_message(resp, '', '');
                        refreshPaymentPreview();
                    },
                    error: function(XMLHttpRequest, textStatus, errorThrown) {
                        $("#dvloader").hide();
                        toastr.error(errorThrown, textStatus);
                    }
                });
            } else {
                showError();
            }
        }

        togglePayoutFields();
    </script>
@endsection