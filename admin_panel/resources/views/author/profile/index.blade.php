@extends('author.layout.page-app')
@section('page_title', __('label.profile'))
@section('tab_title', __('label.profile'))

@section('content')
	@include('author.layout.sidebar')

	<div class="right-content">
		@include('author.layout.header')

        <!-- Select2 -->
        <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/select2/4.0.13/css/select2.min.css" />

		<div class="body-content">
			<!-- mobile title -->
			<h1 class="page-title-sm">{{__('label.profile')}}</h1>

            <div class="border-bottom row mb-3">
                <div class="col-sm-12">
                    <ol class="breadcrumb">
                        <li class="breadcrumb-item"><a href="{{ route('author.dashboard') }}">{{__('label.dashboard')}}</a></li>
                        <li class="breadcrumb-item active" aria-current="page">{{__('label.profile')}}</li>
                    </ol>
                </div>
            </div>

            <!-- Profile Info -->
            <div class="card custom-border-card">
                <h5 class="card-header">{{__('label.personal_info')}}</h5>
                <div class="card-body">
                    <form id="profile" enctype="multipart/form-data">
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
                                    <div class="col-md-8">
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
                                    <div class="col-md-6">
                                        <div class="form-group">
                                            <label>{{__('label.description')}}</label>
                                            <textarea name="description" class="form-control" rows="3" placeholder="{{__('label.description_here')}}">{{ $data->description }}</textarea>
                                        </div>
                                    </div>
                                    <div class="col-md-6">
                                        <div class="form-group">
                                            <label>{{__('label.address')}}</label>
                                            <textarea name="address" class="form-control" rows="3" placeholder="{{__('label.address_here')}}">{{ $data->address }}</textarea>
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
                        <div class="form-row">
                            <div class="col-md-9">
                                <div class="form-row">
                                    <div class="col-md-6">
                                        <div class="form-group">
                                            <label>{{__('label.bank_name')}}<span class="text-danger">*</span></label>
                                            <input type="text" name="bank_name" value="{{ $data['bank_name'] ?? '' }}" class="form-control" placeholder="{{__('label.bank_name_here')}}">
                                        </div>
                                    </div>
                                    <div class="col-md-6">
                                        <div class="form-group">
                                            <label>{{__('label.bank_holder_name')}}<span class="text-danger">*</span></label>
                                            <input type="text" name="bank_holder_name" value="{{ $data['bank_holder_name'] ?? '' }}" class="form-control" placeholder="{{__('label.bank_holder_name_here')}}">
                                        </div>
                                    </div>
                                </div>
                                <div class="form-row">
                                    <div class="col-md-6">
                                        <div class="form-group">
                                            <label>{{__('label.account_no')}}<span class="text-danger">*</span></label>
                                            <input type="text" name="account_no" value="{{ $data['account_no'] ?? '' }}" class="form-control" placeholder="{{__('label.account_no_here')}}">
                                        </div>
                                    </div>
                                </div>
                            </div>
                        </div>
                        
                        <!-- KYC Verification Documents -->
                        <div class="border-top mt-4 pt-3">
                            <h6 class="font-weight-bold mb-3 text-danger">KYC & Compliance Verification</h6>
                            
                            @if( ($data->is_publisher ?? 0) == 0 )
                            <!-- Author KYC -->
                            <div class="form-row">
                                <div class="col-md-6">
                                    <div class="form-group">
                                        <label>Legal Name <span class="text-danger">*</span></label>
                                        <input type="text" name="legal_name" value="{{ $data->legal_name ?? '' }}" class="form-control" placeholder="Enter Full Legal Name">
                                    </div>
                                </div>
                                <div class="col-md-6">
                                    <div class="form-group">
                                        <label>National ID/Passport Number <span class="text-danger">*</span></label>
                                        <input type="text" name="national_id_number" value="{{ $data->national_id_number ?? '' }}" class="form-control" placeholder="Enter ID/Passport Number">
                                    </div>
                                </div>
                            </div>
                            <div class="form-row">
                                <div class="col-md-6">
                                    <div class="form-group">
                                        <label>KRA PIN <span class="text-danger">*</span></label>
                                        <input type="text" name="kra_pin" value="{{ $data->kra_pin ?? '' }}" class="form-control" placeholder="Enter KRA PIN">
                                    </div>
                                </div>
                            </div>
                            @else
                            <!-- Publisher KYC -->
                            <div class="form-row">
                                <div class="col-md-6">
                                    <div class="form-group">
                                        <label>Company/Business Name <span class="text-danger">*</span></label>
                                        <input type="text" name="business_name" value="{{ $data->business_name ?? '' }}" class="form-control" placeholder="Enter Registered Business Name">
                                    </div>
                                </div>
                                <div class="col-md-6">
                                    <div class="form-group">
                                        <label>KRA PIN <span class="text-danger">*</span></label>
                                        <input type="text" name="kra_pin" value="{{ $data->kra_pin ?? '' }}" class="form-control" placeholder="Enter Business KRA PIN">
                                    </div>
                                </div>
                            </div>
                            <div class="form-row">
                                <div class="col-md-6">
                                    <div class="form-group">
                                        <label>Representative Contact Name <span class="text-danger">*</span></label>
                                        <input type="text" name="rep_name" value="{{ $data->rep_name ?? '' }}" class="form-control" placeholder="Enter Representative Name">
                                    </div>
                                </div>
                                <div class="col-md-6">
                                    <div class="form-group">
                                        <label>Representative ID (Upload) <span class="text-danger">*</span></label>
                                        <input type="file" name="rep_id_upload" class="form-control-file">
                                        @if($data->rep_id_upload)
                                        <a href="{{ $data->rep_id_upload }}" target="_blank" class="btn-link mt-1 d-block">View Submitted ID</a>
                                        @endif
                                    </div>
                                </div>
                            </div>
                            <div class="form-row">
                                <div class="col-md-6">
                                    <div class="form-group">
                                        <label>Business Registration Certificate (Upload) <span class="text-danger">*</span></label>
                                        <input type="file" name="business_certificate" class="form-control-file">
                                        @if($data->business_certificate)
                                        <a href="{{ $data->business_certificate }}" target="_blank" class="btn-link mt-1 d-block">View Business Certificate</a>
                                        @endif
                                    </div>
                                </div>
                                <div class="col-md-6">
                                    <div class="form-group">
                                        <label>KRA PIN Certificate (Upload) <span class="text-danger">*</span></label>
                                        <input type="file" name="kra_pin_certificate" class="form-control-file">
                                        @if($data->kra_pin_certificate)
                                        <a href="{{ $data->kra_pin_certificate }}" target="_blank" class="btn-link mt-1 d-block">View KRA PIN Certificate</a>
                                        @endif
                                    </div>
                                </div>
                            </div>
                            @endif
                            
                            <div class="form-row mt-3">
                                <div class="col-md-12">
                                    <div class="form-group">
                                        <div class="custom-control custom-checkbox">
                                            <input type="checkbox" class="custom-control-input" id="rights_declaration" name="rights_declaration" value="1" {{ ($data->rights_declaration ?? 0) == 1 ? 'checked' : '' }}>
                                            <label class="custom-control-label" for="rights_declaration">I consent to the platform Terms and Conditions, and declare that all uploaded information and documents are legal and correct.</label>
                                        </div>
                                    </div>
                                </div>
                            </div>
                        </div>
                        <div class="border-top pt-3 text-right">
                            <button type="button" class="btn btn-default mw-120" onclick="update_profile()">{{__('label.update')}}</button>
                            <input type="hidden" name="_token" value="{{ csrf_token() }}">
                        </div>
                    </form>
                </div>
            </div>

            <!-- Change Password -->
            <div class="card custom-border-card">
                <form id="change_password" enctype="multipart/form-data">
                    <input type="hidden" name="id" value="{{ $data->id }}">
                    <h5 class="card-header">{{__('label.change_password')}}</h5>
                    <div class="card-body">
                        <div class="form-row">
                            <div class="col-md-4">
                                <div class="form-group">
                                    <label>{{__('label.current_password')}}<span class="text-danger">*</span></label>
                                    <input type="password" name="current_password" class="form-control" placeholder="{{__('label.current_password_here')}}">
                                </div>
                            </div>
                        </div>
                        <div class="form-row">
                            <div class="col-md-4">
                                <div class="form-group">
                                    <label>{{__('label.new_password')}}<span class="text-danger">*</span></label>
                                    <input type="password" name="new_password" class="form-control" placeholder="{{__('label.new_password_here')}}">
                                </div>
                            </div>
                            <div class="col-md-4">
                                <div class="form-group">
                                    <label>{{__('label.confirm_password')}}<span class="text-danger">*</span></label>
                                    <input type="password" name="confirm_password" class="form-control" placeholder="{{__('label.confirm_password_here')}}">
                                </div>
                            </div>
                        </div>
                    </div>
                    <div class="border-top pt-3 text-right">
                        <button type="button" class="btn btn-default mw-120" onclick="update_password()">{{__('label.update')}}</button>
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
        $("#category_ids").select2({placeholder: "{{__('label.select_category')}}"});

		function update_profile(){

            var Demo_Mode = '<?php echo Demo_Mode(); ?>';
            if(Demo_Mode == 1){

                $("#dvloader").show();
                var formData = new FormData($("#profile")[0]);

                $.ajax({
                    type: 'POST',
                    url: '{{route("author.profile.store")}}',
                    data: formData,
                    cache:false,
                    contentType: false,
                    processData: false,
                    success:function(resp){
                        $("#dvloader").hide();
                        get_responce_message(resp, 'profile', '{{ route("author.profile.index") }}');
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
        function update_password() {

            var Demo_Mode = '<?php echo Demo_Mode(); ?>';
            if(Demo_Mode == 1){

                $("#dvloader").show();
                var formData = new FormData($("#change_password")[0]);

                $.ajax({
                    type: 'POST',
                    url: '{{ route("author.profile.changepassword") }}',
                    data: formData,
                    cache: false,
                    contentType: false,
                    processData: false,
                    success: function(resp) {
                        $("#dvloader").hide();
                        get_responce_message(resp, 'change_password', '{{ route("author.profile.index") }}');
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