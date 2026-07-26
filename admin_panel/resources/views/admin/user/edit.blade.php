@extends('admin.layout.page-app')
@section('page_title', __('label.edit_user'))
@section('tab_title', __('label.edit_user'))

@section('content')
    @include('admin.layout.sidebar')

    <div class="right-content">
        @include('admin.layout.header')

        <!-- Select2 -->
        <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/select2/4.0.13/css/select2.min.css" />

        <div class="body-content">
            <!-- mobile title -->
            <h1 class="page-title-sm">{{__('label.edit_user')}}</h1>

            <div class="border-bottom row mb-3">
                <div class="col-sm-10">
                    <ol class="breadcrumb">
                        <li class="breadcrumb-item"><a href="{{ route('admin.dashboard') }}">{{__('label.dashboard')}}</a></li>
                        <li class="breadcrumb-item"><a href="{{ route('admin.user.index') }}">{{__('label.users')}}</a></li>
                        <li class="breadcrumb-item active" aria-current="page">{{__('label.edit_user')}}</li>
                    </ol>
                </div>
                <div class="col-sm-2 d-flex align-items-center justify-content-end">
                    <a href="{{ route('admin.user.index') }}" class="btn btn-default mw-120 mb-3">{{__('label.user_list')}}</a>
                </div>
            </div>

            <div class="card custom-border-card">
                <div class="card-body">
                    <form id="update_user" enctype="multipart/form-data">
                        <input type="hidden" name="id" value="{{ $data->id }}">
                        <div class="form-row">
                            <div class="col-md-9">
                                <div class="form-row">
                                    <div class="col-md-4">
                                        <div class="form-group">
                                            <label>{{__('label.first_name')}}<span class="text-danger">*</span></label>
                                            <input type="text" name="first_name" value="{{ $data->first_name }}" class="form-control" placeholder="{{__('label.first_name_here')}}" autofocus>
                                        </div>
                                    </div>
                                    <div class="col-md-4">
                                        <div class="form-group">
                                            <label>{{__('label.last_name')}}<span class="text-danger">*</span></label>
                                            <input type="text" name="last_name" value="{{ $data->last_name }}" class="form-control" placeholder="{{__('label.last_name_here')}}">
                                        </div>
                                    </div>
                                    <div class="col-md-4">
                                        <div class="form-group">
                                            <label>{{__('label.mobile_number')}}<span class="text-danger">*</span></label>
                                            <input type="text" name="mobile_number" value="{{ $data->mobile_number }}" class="form-control" placeholder="{{__('label.mobile_number_here')}}">
                                        </div>
                                    </div>
                                </div>
                                <div class="form-row">
                                    <div class="col-md-4">
                                        <div class="form-group">
                                            <label>{{__('label.email')}}<span class="text-danger">*</span></label>
                                            <input type="email" name="email" value="{{ $data->email }}" class="form-control" placeholder="{{__('label.email_here')}}">
                                        </div>
                                    </div>
                                    <div class="col-md-4">
                                        <div class="form-group">
                                            <label>{{__('label.new_password')}}</label>
                                            <input type="password" name="password" class="form-control" placeholder="{{__('label.password_here')}}">
                                        </div>
                                    </div>
                                    <div class="col-md-4">
										<?php $ids = explode(",", $data->category_ids); ?>
                                        <div class="form-group">
                                            <label>{{__('label.category')}}</label>
                                            <select name="category_ids[]" class="form-control" id="category_ids" multiple style="width:100%!important;">
                                                @foreach ($category as $key => $value)
                                                <option value="{{ $value->id }}" {{(in_array($value->id, $ids)) ? 'selected' : ''}}>
                                                    {{ $value->name }}
                                                </option>
                                                @endforeach
                                            </select>
                                        </div>
                                    </div>
                                </div>
                                <div class="form-row">
                                    <div class="col-md-12">
                                        <div class="form-group">
                                            <label>{{__('label.description')}}</label>
                                            <textarea name="description" class="form-control" rows="1" placeholder="{{__('label.description_here')}}">{{ $data->description }}</textarea>
                                        </div>
                                    </div>
                                </div>
                                <div class="form-row">
                                    <div class="col-md-12">
                                        <div class="form-group">
                                            <label>{{__('label.address')}}</label>
                                            <textarea name="address" class="form-control" rows="1" placeholder="{{__('label.address_here')}}">{{ $data->address }}</textarea>
                                        </div>
                                    </div>
                                </div>
                            </div>
                            <div class="col-md-3">
                                <div class="form-group ml-5">
                                    <label>{{__('label.image')}}<span class="text-danger">*</span></label>
                                    <div class="avatar-upload">
                                        <div class="avatar-edit">
                                            <input type='file' name="image" id="imageUpload" accept=".png, .jpg, .jpeg, .webp"/>
                                            <label for="imageUpload" title="{{__('label.upload_file')}}"></label>
                                        </div>
                                        <div class="avatar-preview">
                                            <img src="{{ $data['image'] }}" id="imagePreview">
                                        </div>
                                    </div>
									<input type="hidden" name="old_image" value="{{ $data['image'] }}">
                                    <label class="mt-3 text-gray">{{__('label.max_size_5mb')}}</label>
                                </div>
                            </div>
                        </div>
                        <div class="border-top pt-3 text-right">
                            <button type="button" class="btn btn-default mw-120" onclick="update_user()">{{__('label.update')}}</button>
                            <a href="{{route('admin.user.index')}}" class="btn btn-cancel mw-120 ml-2">{{__('label.cancel')}}</a>
							<input type="hidden" name="_method" value="PATCH">
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
        $("#category_ids").select2({placeholder: "{{__('label.select_category')}}"});

        function update_user() {

            var Demo_Mode = '<?php echo Demo_Mode(); ?>';
            if (Demo_Mode == 1) {

                $("#dvloader").show();
                var formData = new FormData($("#update_user")[0]);
                $.ajax({
                    type: 'POST',
					url:'{{ route("admin.user.update", [ $data->id ]) }}',
                    data: formData,
                    cache: false,
                    contentType: false,
                    processData: false,
                    success: function(resp) {
                        $("#dvloader").hide();
                        get_responce_message(resp, 'update_user', '{{ route("admin.user.index") }}');
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