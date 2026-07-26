@extends('admin.layout.page-app')
@section('page_title', 'Add Sub-Admin')
@section('tab_title', 'Add Sub-Admin')

@section('content')
    @include('admin.layout.sidebar')

    <div class="right-content">
        @include('admin.layout.header')

        <div class="body-content">
            <!-- mobile title -->
            <h1 class="page-title-sm">Add Sub-Admin</h1>

            <div class="border-bottom row mb-3">
                <div class="col-sm-10">
                    <ol class="breadcrumb">
                        <li class="breadcrumb-item"><a href="{{ route('admin.dashboard') }}">{{__('label.dashboard')}}</a></li>
                        <li class="breadcrumb-item"><a href="{{ route('admin.subadmin.index') }}">Sub-Admins</a></li>
                        <li class="breadcrumb-item active" aria-current="page">Add Sub-Admin</li>
                    </ol>
                </div>
                <div class="col-sm-2 d-flex align-items-center justify-content-end">
                    <a href="{{ route('admin.subadmin.index') }}" class="btn btn-default mw-120 mb-3">Sub-Admin List</a>
                </div>
            </div>

            <div class="card custom-border-card">
                <div class="card-body">
                    <form id="subadmin_form" enctype="multipart/form-data">
                        <div class="form-row">
                            <div class="col-md-6">
                                <div class="form-group">
                                    <label>User Name <span class="text-danger">*</span></label>
                                    <input type="text" name="user_name" class="form-control" placeholder="Enter Username" autofocus>
                                </div>
                            </div>
                            <div class="col-md-6">
                                <div class="form-group">
                                    <label>Email <span class="text-danger">*</span></label>
                                    <input type="email" name="email" class="form-control" placeholder="Enter Email">
                                </div>
                            </div>
                        </div>
                        <div class="form-row">
                            <div class="col-md-6">
                                <div class="form-group">
                                    <label>Password <span class="text-danger">*</span></label>
                                    <input type="password" name="password" class="form-control" placeholder="Enter Password">
                                </div>
                            </div>
                            <div class="col-md-6">
                                <div class="form-group">
                                    <label>Role <span class="text-danger">*</span></label>
                                    <select name="role" class="form-control">
                                        <option value="admin">Admin</option>
                                        <option value="editor">Editor</option>
                                        <option value="accounts">Accounts</option>
                                    </select>
                                </div>
                            </div>
                        </div>
                        <div class="border-top pt-3 text-right">
                            <button type="button" class="btn btn-default mw-120" onclick="save_subadmin()">{{__('label.save')}}</button>
                            <a href="{{route('admin.subadmin.index')}}" class="btn btn-cancel mw-120 ml-2">{{__('label.cancel')}}</a>
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
        function save_subadmin() {
            var Demo_Mode = '{{Demo_Mode()}}';
            if (Demo_Mode == 1) {
                $("#dvloader").show();
                var formData = new FormData($("#subadmin_form")[0]);
                $.ajax({
                    type: 'POST',
                    url: '{{ route("admin.subadmin.store") }}',
                    data: formData,
                    cache: false,
                    contentType: false,
                    processData: false,
                    success: function(resp) {
                        $("#dvloader").hide();
                        get_responce_message(resp, 'subadmin_form', '{{ route("admin.subadmin.index") }}');
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
