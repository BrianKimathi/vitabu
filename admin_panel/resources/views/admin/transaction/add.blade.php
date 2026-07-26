@extends('admin.layout.page-app')
@section('page_title', __('label.add_transaction'))

@section('content')
@include('admin.layout.sidebar')

<!-- Select2 -->
<link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/select2/4.0.13/css/select2.min.css" />

<div class="right-content">
    @include('admin.layout.header')

    <div class="body-content">
        <!-- mobile title -->
        <h1 class="page-title-sm">{{__('label.add_transaction')}}</h1>
        <div class="border-bottom row mb-3">
            <div class="col-sm-10">
                <ol class="breadcrumb">
                    <li class="breadcrumb-item">
                        <a href="{{ route('admin.dashboard') }}">{{__('label.dashboard')}}</a>
                    </li>
                    <li class="breadcrumb-item">
                        <a href="{{ route('admin.transaction.index') }}">{{__('label.transaction')}}</a>
                    </li>
                    <li class="breadcrumb-item active" aria-current="page">
                        {{__('label.add_transaction')}}
                    </li>
                </ol>
            </div>
            <div class="col-sm-2 d-flex align-items-center justify-content-end">
                <a href="{{ route('admin.transaction.index') }}" class="btn btn-default mw-120 mt-14">{{__('label.transaction_list')}}</a>
            </div>
        </div>

        <div class="custom-border-card">
            <form id="transaction" autocomplete="off" enctype="multipart/form-data">
                <input type="hidden" name="id" value="">
                <div class="form-row">
                    <div class="col-md-4">
                        <div class="form-group">
                            <label>{{__('label.user')}}<span class="text-danger">*</span></label>
                            <select class="form-control" id="user_id" name="user_id">
                                <option value="">{{__('label.select_user')}}</option>
                                @foreach($users as $user)
                                <option value="{{$user->id}}">{{$user->first_name}}</option>
                                @endforeach
                            </select>
                        </div>
                    </div>
                    <div class="col-md-4">
                        <div class="form-group">
                            <label>{{__('label.plan')}}<span class="text-danger">*</span></label>
                            <select class="form-control" id="plan_id" name="plan_id">
                                <option value="">{{__('label.select_plan')}}</option>
                                @foreach($plans as $plan)
                                <option value="{{ $plan->id }}">{{ $plan->name }}</option>
                                @endforeach
                            </select>
                        </div>
                    </div>
                    <div class="col-md-4">
                        <div class="form-group">
                            <label>{{__('label.coupon_code')}}</label>
                            <input type="text" class="form-control" name="coupon_code" placeholder="{{__('label.coupon_code_here')}}">
                        </div>
                    </div>
                </div>
                <div class="border-top pt-3 text-right">
                    <button type="button" class="btn btn-default mw-120" onclick="save_transaction()">{{__('label.save')}}</button>
                    <a href="{{route('admin.transaction.index')}}" class="btn btn-cancel mw-120 ml-2">{{__('label.cancel')}}</a>
                    <input type="hidden" name="_token" value="{{ csrf_token() }}">
                </div>
            </form>
        </div>
    </div>
</div>
@endsection

@section('pagescript')
<!-- Select2 -->
<script src="https://cdnjs.cloudflare.com/ajax/libs/select2/4.0.13/js/select2.min.js"></script>
<script>
    sidebar_down($(document).height());

    $('#user_id').select2();
    $('#plan_id').select2();

    function save_transaction() {

        var Check_Admin = '<?php echo Demo_Mode(); ?>';
        if (Check_Admin == 1) {

            $("#dvloader").show();
            var formData = new FormData($("#transaction")[0]);

            $.ajax({
                type: 'POST',
                url: '{{ route("admin.transaction.store") }}',
                data: formData,
                cache: false,
                contentType: false,
                processData: false,
                success: function(resp) {
                    $("#dvloader").hide();
                    get_responce_message(resp, 'transaction', '{{ route("admin.transaction.index") }}');
                },
                error: function(XMLHttpRequest, textStatus, errorThrown) {
                    $("#dvloader").hide();
                    toastr.error(errorThrown, textStatus);
                }
            });
        } else {
            toastr.error('{{__("label.you_have_no_right_to_add_edit_and_delete")}}');
        }
    }
</script>
@endsection