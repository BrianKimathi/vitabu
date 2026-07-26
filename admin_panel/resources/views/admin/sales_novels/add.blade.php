@extends('admin.layout.page-app')
@section('page_title', __('label.add_sales_report'))
@section('tab_title', __('label.add_sales_report'))

@section('content')
@include('admin.layout.sidebar')

<div class="right-content">
    @include('admin.layout.header')

    <!-- Select2 -->
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/select2/4.0.13/css/select2.min.css" />

    <div class="body-content">
        <!-- mobile title -->
        <h1 class="page-title-sm">{{__('label.add_sales_report')}}</h1>

        <div class="border-bottom row mb-3">
            <div class="col-sm-10">
                <ol class="breadcrumb">
                    <li class="breadcrumb-item"><a href="{{ route('admin.dashboard') }}">{{__('label.dashboard')}}</a></li>
                    <li class="breadcrumb-item"><a href="{{ route('admin.salesnovels.index') }}">{{__('label.novel_sales_report')}}</a></li>
                    <li class="breadcrumb-item active" aria-current="page">{{__('label.add_sales_report')}}</li>
                </ol>
            </div>
            <div class="col-sm-2 d-flex align-items-center justify-content-end">
                <a href="{{ route('admin.salesnovels.index') }}" class="btn btn-default mw-120 mb-3">{{__('label.sales_report_list')}}</a>
            </div>
        </div>

        <div class="card custom-border-card">
            <div class="card-body py-0">
                <form id="save_sales_report" enctype="multipart/form-data">
                    <input type="hidden" name="id">
                    <div class="form-row">
                        <div class="col-md-12">
                            <div class="form-row">
                                <div class="col-md-4">
                                    <div class="form-group">
                                        <label>{{__('label.user')}}<span class="text-danger">*</span></label>
                                        <select class="form-control" name="user_id" id="user_id">
                                            <option value="">{{__('label.select_user')}}</option>
                                            @foreach($users as $user)
                                            <option value="{{$user['id']}}">{{$user['first_name']}}</option>
                                            @endforeach
                                        </select>
                                    </div>
                                </div>
                                <div class="col-md-4">
                                    <div class="form-group">
                                        <label>{{__('label.author')}}<span class="text-danger">*</span></label>
                                        <select class="form-control" name="author_id" id="author_id">
                                            <option value="">{{__('label.select_author')}}</option>
                                            @foreach($authors as $author)
                                            <option value="{{$author['id']}}">{{$author['first_name']}}</option>
                                            @endforeach
                                        </select>
                                    </div>
                                </div>
                                <div class="col-md-4">
                                    <div class="form-group">
                                        <label>{{__('label.novel')}}<span class="text-danger">*</span></label>
                                        <select class="form-control" name="novel_id" id="novel_id">
                                            <option value="">{{__('label.select_novel')}}</option>

                                        </select>
                                    </div>
                                </div>
                            </div>
                            <div class="form-row">
                                <div class="col-md-4">
                                    <div class="form-group">
                                        <label>{{__('label.novel_chapter')}}</label>
                                        <select class="form-control" name="novel_chapter_id" id="novel_chapter_id">
                                            <option value="" selected>{{__('label.select_novel_chapter')}}</option>

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
                        </div>
                    </div>
                    <div class="border-top pt-3 text-right">
                        <button type="button" class="btn btn-default mw-120" onclick="save_sales_report()">{{__('label.save')}}</button>
                        <a href="{{route('admin.salesnovels.index')}}" class="btn btn-cancel mw-120 ml-2">{{__('label.cancel')}}</a>
                        <input type="hidden" name="_token" value="{{ csrf_token() }}">
                    </div>
                </form>
            </div>
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

    $(document).ready(function() {
        $('#user_id').select2();
        $('#author_id').select2();
        $('#novel_id').select2();
        $('#novel_chapter_id').select2();

    });

    // Save novel
    function save_sales_report() {

        var Demo_Mode = '<?php echo Demo_Mode(); ?>';
        if (Demo_Mode == 1) {

            $("#dvloader").show();
            var formData = new FormData($("#save_sales_report")[0]);
            $.ajax({
                type: 'POST',
                url: '{{ route("admin.salesnovels.store") }}',
                data: formData,
                cache: false,
                contentType: false,
                processData: false,
                success: function(resp) {
                    $("#dvloader").hide();
                    get_responce_message(resp, 'save_sales_report', '{{ route("admin.salesnovels.index") }}');
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

    $('#novel_id').change(function() {
        var id = $(this).children("option:selected").val();

        $('#novel_chapter_id').empty('');
        $('#novel_chapter_id').append('<option value="" selected>{{__("label.select_novel_chapter")}}</option>');
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
                    $('#novel_chapter_id').append('<option value="' + resp.result[i]['id'] + '">' + resp.result[i]['title'] + '</option>');
                }
            },
            error: function(XMLHttpRequest, textStatus, errorThrown) {
                toastr.error(errorThrown, textStatus);
            }

        })
    });
    $('#author_id').change(function() {
        var id = $(this).children("option:selected").val();

        $('#novel_id').empty('');
        $('#novel_id').append('<option value="" selected>{{__("label.select_novel")}}</option>');
        $.ajax({
            headers: {
                'X-CSRF-TOKEN': $('meta[name="csrf-token"]').attr('content')
            },
            type: 'POST',
            url: '{{ route("admin.salesnovels.get_novel") }}',
            data: {
                id: id
            },
            success: function(resp) {
                for (i = 0; i < resp.result.length; i++) {
                    $('#novel_id').append('<option value="' + resp.result[i]['id'] + '">' + resp.result[i]['title'] + '</option>');
                }
            },
            error: function(XMLHttpRequest, textStatus, errorThrown) {
                toastr.error(errorThrown, textStatus);
            }

        })
    });
</script>
@endsection