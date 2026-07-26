@extends('admin.layout.page-app')
@section('page_title', __('label.panel_settings'))
@section('tab_title', __('label.panel_settings'))

@section('content')
@include('admin.layout.sidebar')

<div class="right-content">
    @include('admin.layout.header')

    <div class="body-content">

        <!-- mobile title -->
        <h1 class="page-title-sm">{{__('label.panel_settings')}}</h1>

        <div class="border-bottom row mb-3">
            <div class="col-sm-12">
                <ol class="breadcrumb">
                    <li class="breadcrumb-item"><a href="{{ route('admin.dashboard') }}">{{__('label.dashboard')}}</a></li>
                    <li class="breadcrumb-item active" aria-current="page">{{__('label.panel_settings')}}</li>
                </ol>
            </div>
        </div>

        <div class="card custom-border-card">
            <h5 class="card-header">{{__('label.panel_login_page')}}</h5>
            <div class="card-body">
                <form id="pannel_setting" enctype="multipart/form-data">
                    <div class="form-row">
                        <div class="col-md-3 text_view">
                            <div class="form-group">
                                <label>{{__('label.background_image')}}<span class="text-danger">*</span></label>
                                <div class="avatar-upload">
                                    <div class="avatar-edit">
                                        <input type='file' name="panel_login_page_bg_image" id="imageUpload" accept=".png, .jpg, .jpeg, .webp" />
                                        <label for="imageUpload" title="{{__('label.upload_file')}}"></label>
                                    </div>
                                    <div class="avatar-preview">
                                        <img src="{{ $result['panel_login_page_bg_image'] }}" id="imagePreview">
                                    </div>
                                </div>
                                <input type="hidden" name="old_panel_login_page_bg_image" value="{{ $result['panel_login_page_bg_image'] }}">
                                <label class="mt-3 text-gray">{{__('label.size_2640_3960_pixels')}}</label>
                            </div>
                        </div>
                    </div>
                    <div class="border-top pt-3 text-right">
                        <button type="button" class="btn btn-default mw-120" onclick="save_panel_setting()">{{__('label.save')}}</button>
                        <input type="hidden" name="_token" value="{{ csrf_token() }}">
                    </div>
                </form>
            </div>
        </div>
    </div>
</div>
@endsection

@section('pagescript')
<script>
    // Sidebar Scroll Down
    sidebar_down($(document).height());

    // Color Picker
    $(document).ready(function() {
        // Event handler for color picker input change
        $('.colorpicker').on('input', function() {
            var target = $(this).attr('id').split('-')[1];
            $('#hexcolor-' + target).val(this.value.toUpperCase());
        });

        // Event handler for hex color input change
        $('.hexcolor').on('input', function() {
            var target = $(this).attr('id').split('-')[1];
            const hexPattern = /^#([a-fA-F0-9]{6}|[a-fA-F0-9]{3})$/;
            if (hexPattern.test(this.value)) {
                $('#colorpicker-' + target).val(this.value);
            }
        });
    });

    function save_panel_setting() {

        var Demo_Mode = '<?php echo Demo_Mode(); ?>';
        if (Demo_Mode == 1) {

            $("#dvloader").show();
            var formData = new FormData($("#pannel_setting")[0]);
            $.ajax({
                type: 'POST',
                url: '{{ route("admin.panelsetting.save") }}',
                data: formData,
                cache: false,
                contentType: false,
                processData: false,
                success: function(resp) {
                    $("#dvloader").hide();
                    get_responce_message(resp, 'pannel_setting', '{{ route("admin.panelsetting.index") }}');
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
</script>
@endsection