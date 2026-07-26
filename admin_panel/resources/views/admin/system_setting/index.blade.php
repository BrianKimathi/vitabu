@extends('admin.layout.page-app')
@section('page_title', __('label.system_settings'))
@section('tab_title', __('label.system_settings'))

@section('content')
@include('admin.layout.sidebar')

<div class="right-content">
    @include('admin.layout.header')

    <div class="body-content">

        <!-- mobile title -->
        <h1 class="page-title-sm">{{__('label.system_settings')}}</h1>

        <div class="border-bottom row mb-3">
            <div class="col-sm-12">
                <ol class="breadcrumb">
                    <li class="breadcrumb-item"><a href="{{ route('admin.dashboard') }}">{{__('label.dashboard')}}</a></li>
                    <li class="breadcrumb-item active" aria-current="page">{{__('label.system_settings')}}</li>
                </ol>
            </div>
        </div>

        <div class="row">
            <div class="col-6">
                <div class="card custom-border-card">
                    <a data-bs-toggle="collapse" data-bs-target="#clear_data">
                        <h5 class="card-header"><i class="fa-solid fa-chevron-down float-right"></i>{{__('label.clear_cache')}}</h5>
                    </a>

                    <div id="clear_data" class="collapse">
                        <div class="card-body">
                            <p>This means that the extra uploaded files, images and videos in your system will be deleted.</p>
                            <div class="d-flex justify-content-end">
                                <button type="button" class="btn btn-default mw-120" onclick="clear_data()">{{__('label.clear_cache')}}</button>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
            <div class="col-6">
                <div class="card custom-border-card">
                    <a data-bs-toggle="collapse" data-bs-target="#download_database">
                        <h5 class="card-header"><i class="fa-solid fa-chevron-down float-right"></i>{{__('label.backup_database')}}</h5>
                    </a>

                    <div id="download_database" class="collapse">
                        <div class="card-body">
                            <p>Download the SQL file of the current database.</p>
                            <div class="d-flex justify-content-end">
                                <a href="{{ route('admin.system.setting.downloaddb') }}" onclick="return confirm('You want to download this SQL file ?')" class="btn btn-default mw-120">{{__('label.download')}}</a>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
        <div class="row">
            <div class="col-6">
                <div class="card custom-border-card">
                    <a data-bs-toggle="collapse" data-bs-target="#clean_database">
                        <h5 class="card-header"><i class="fa-solid fa-chevron-down float-right"></i>{{__('label.clean_database')}}</h5>
                    </a>

                    <div id="clean_database" class="collapse">
                        <div class="card-body">
                            <p>This Action will permanently delete all data from the Database.</p>
                            <div class="d-flex justify-content-end">
                                <button type="button" class="btn btn-default mw-120" onclick="clean_database()">{{__('label.clean_database')}}</button>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>
</div>
@endsection

@section('pagescript')
<script>
    // Sidebar Scroll Down
    sidebar_down($(document).height());

    function clear_data() {
        if (confirm('Do you confirm Clear the Data !!!')) {

            $("#dvloader").show();
            $.ajax({
                headers: {
                    'X-CSRF-TOKEN': $('meta[name="csrf-token"]').attr('content')
                },
                enctype: 'multipart/form-data',
                type: 'POST',
                url: '{{ route("admin.system.setting.cleardata") }}',
                cache: false,
                contentType: false,
                processData: false,
                success: function(resp) {
                    $("#dvloader").hide();
                    get_responce_message(resp, '', '{{ route("admin.system.setting.index") }}');
                },
                error: function(XMLHttpRequest, textStatus, errorThrown) {
                    $("#dvloader").hide();
                    toastr.error(errorThrown, textStatus);
                }
            });
        }
    }

    function clean_database() {

        var Demo_Mode = '<?php echo Demo_Mode(); ?>';
        if (Demo_Mode == 1) {

            if (confirm('Do you confirm Clean the Database !!!')) {

                $("#dvloader").show();
                $.ajax({
                    headers: {
                        'X-CSRF-TOKEN': $('meta[name="csrf-token"]').attr('content')
                    },
                    enctype: 'multipart/form-data',
                    type: 'POST',
                    url: '{{ route("admin.system.setting.cleandatabase") }}',
                    cache: false,
                    contentType: false,
                    processData: false,
                    success: function(resp) {
                        $("#dvloader").hide();
                        get_responce_message(resp, '', '{{ route("admin.system.setting.index") }}');
                    },
                    error: function(XMLHttpRequest, textStatus, errorThrown) {
                        $("#dvloader").hide();
                        toastr.error(errorThrown, textStatus);
                    }
                });
            }
        } else {
            showError();
        }
    }
</script>
@endsection