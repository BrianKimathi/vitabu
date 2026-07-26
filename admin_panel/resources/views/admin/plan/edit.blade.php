@extends('admin.layout.page-app')
@section('page_title', __('label.edit_plan'))

@section('content')
@include('admin.layout.sidebar')

<!-- Select2 -->
<link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/select2/4.0.13/css/select2.min.css" />

<div class="right-content">
	@include('admin.layout.header')

	<div class="body-content">
		<!-- mobile title -->
		<h1 class="page-title-sm">{{__('label.edit_plan')}}</h1>

		<div class="border-bottom row mb-3">
			<div class="col-sm-10">
				<ol class="breadcrumb">
					<li class="breadcrumb-item">
						<a href="{{ route('admin.dashboard') }}">{{__('label.dashboard')}}</a>
					</li>
					<li class="breadcrumb-item">
						<a href="{{ route('admin.plan.index') }}">{{__('label.plan')}}</a>
					</li>
					<li class="breadcrumb-item active" aria-current="page">
						{{__('label.edit_plan')}}
					</li>
				</ol>
			</div>
			<div class="col-sm-2 d-flex align-items-center justify-content-end">
				<a href="{{ route('admin.plan.index') }}" class="btn btn-default mw-120 mt-14">{{__('label.plan_list')}}</a>
			</div>
		</div>

		<div class="card custom-border-card">
			<div class="card-body">
				<form name="plan" id="plan_update" enctype="multipart/form-data" autocomplete="off">
					<input type="hidden" name="id" value="@if($data){{$data->id}}@endif">
					<div class="form-row">
						<div class="col-md-9">
							<div class="form-row">
								<div class="col-md-4">
									<div class="form-group">
										<label>{{__('label.name')}}<span class="text-danger">*</span></label>
										<input type="text" value="@if($data){{$data->name}}@endif" name="name" class="form-control" placeholder="{{__('label.name_here')}}">
									</div>
								</div>
								<div class="col-md-3">
									<div class="form-group">
										<label for="type">{{__('label.plan_time')}}<span class="text-danger">*</span></label>
										<select class="form-control" id="plan_time" name="type">
											<option value="">Select Type</option>
											<option value="Day" {{$data->type == 'Day' ? 'selected' : ''}}>{{__('label.day')}}</option>
											<option value="Week" {{$data->type == 'Week' ? 'selected' : ''}}>{{__('label.week')}}</option>
											<option value="Month" {{$data->type == 'Month' ? 'selected' : ''}}>{{__('label.month')}}</option>
											<option value="Year" {{$data->type == 'Year' ? 'selected' : ''}}>{{__('label.year')}}</option>
										</select>
									</div>
								</div>
								<div class="col-md-2 mb-6 mt-4">
									<div class="form-group mt-2">
										<select class="form-control time" id="time" name="time">
											<option value="">{{__('label.select_number')}}</option>
											@for($i=1; $i<=31; $i++)
												<option value="{{$i}}" {{$data->time == $i ? 'selected' : ''}}>{{$i}}</option>
												@endfor
										</select>
									</div>
								</div>
								<div class="col-md-2">
									<div class="form-group">
										<label>{{__('label.price')}}<span class="text-danger">*</span></label>
										<input type="text" value="@if($data){{$data->price}}@endif" name="price" class="form-control" placeholder="{{__('label.price_here')}}">
									</div>
								</div>
							</div>
							<div class="form-row">
								<div class="col-md-4">
									<div class="form-group">
										<?php $x = explode(',', $data->access_type); ?>
										<label for="type">{{__('label.access_type')}}<span class="text-danger">*</span></label>
										<select class="form-control" id="access_type" name="access_type[]" multiple>
											<option value="1" {{in_array(1,$x) ? "selected" : ""}}>{{__('label.unlimited_reading')}}</option>
											<option value="2" {{in_array(2,$x) ? "selected" : ""}}>{{__('label.access_mobile_web')}}</option>
											<option value="3" {{in_array(3,$x) ? "selected" : ""}}>{{__('label.dark_mode_reading')}}</option>
										</select>
									</div>
								</div>
								<div class="col-md-3">
									<div class="form-group">
										<label>{{__('label.cancel_anytime')}}<span class="text-danger">*</span></label>
										<div class="radio-group">
											<div class="custom-control custom-radio">
												<input type="radio" id="cancel_anytime1" name="cancel_anytime" class="custom-control-input" value="1" {{$data->cancel_anytime ==1 ? "checked" : ""}}>
												<label class="custom-control-label" for="cancel_anytime1">{{__('label.yes')}}</label>
											</div>
											<div class="custom-control custom-radio">
												<input type="radio" id="cancel_anytime0" name="cancel_anytime" class="custom-control-input" value="0" {{$data->cancel_anytime ==0 ? "checked" : ""}}>
												<label class="custom-control-label" for="cancel_anytime0">{{__('label.no')}}</label>
											</div>
										</div>
									</div>
								</div>
								<div class="col-md-3">
									<div class="form-group">
										<label>{{__('label.auto_renew')}}<span class="text-danger">*</span></label>
										<div class="radio-group">
											<div class="custom-control custom-radio">
												<input type="radio" id="auto_renew1" name="auto_renew" class="custom-control-input" value="1" {{$data->auto_renew==1 ? "checked" : ""}}>
												<label class="custom-control-label" for="auto_renew1">{{__('label.yes')}}</label>
											</div>
											<div class="custom-control custom-radio">
												<input type="radio" id="auto_renew0" name="auto_renew" class="custom-control-input" value="0" {{$data->auto_renew==0 ? "checked" : ""}}>
												<label class="custom-control-label" for="auto_renew0">{{__('label.no')}}</label>
											</div>
										</div>
									</div>
								</div>
							</div>
						</div>
						<div class="col-md-3">
							<div class="form-group ml-5">
								<label class="ml-5">{{__('label.image')}}</label>
								<div class="avatar-upload ml-5">
									<div class="avatar-edit">
										<input type='file' name="image" id="imageUpload" accept=".png, .jpg, .jpeg, .webp" />
										<label for="imageUpload" title="Select File"></label>
									</div>
									<div class="avatar-preview">
										<img src="{{$data['image']}}" alt="no_img.png" id="imagePreview">
									</div>
								</div>
								<input type="hidden" name="old_image" value="@if($data){{$data->image}}@endif">
								<label class="mt-3 ml-5 text-gray">{{__('label.max_size_5mb')}}</label>
							</div>
						</div>
					</div>
					<div class="border-top pt-3 text-right">
						<button type="button" class="btn btn-default mw-120" onclick="update_plan()">{{__('label.update')}}</button>
						<a href="{{route('admin.plan.index')}}" class="btn btn-cancel mw-120 ml-2">{{__('label.cancel')}}</a>
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
	$('#access_type').select2({
		placeholder: "{{__('label.select_access_type')}}"
	});
	sidebar_down($(document).height());

	function update_plan() {

		var Check_Admin = '<?php echo Demo_Mode(); ?>';
		if (Check_Admin == 1) {

			$("#dvloader").show();
			var formData = new FormData($("#plan_update")[0]);

			$.ajax({
				headers: {
					'X-CSRF-TOKEN': $('meta[name="csrf-token"]').attr('content')
				},
				type: 'POST',
				url: '{{route("admin.plan.update", [$data->id])}}',
				data: formData,
				cache: false,
				contentType: false,
				processData: false,
				success: function(resp) {
					$("#dvloader").hide();
					get_responce_message(resp, 'plan_update', '{{ route("admin.plan.index") }}');
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

	$(document).ready(function() {

		var plan_time = "<?php echo $data->type; ?>";
		if (plan_time == "Day") {
			for (let i = 8; i <= 31; i++) {
				$(".time option[value=" + i + "]").hide();
			}
		} else if (plan_time == "Week") {
			for (let i = 5; i <= 31; i++) {
				$(".time option[value=" + i + "]").hide();
			}
		} else if (plan_time == "Month") {
			for (let i = 13; i <= 31; i++) {
				$(".time option[value=" + i + "]").hide();
			}
		} else if (plan_time == "Year") {
			for (let i = 2; i <= 31; i++) {
				$(".time option[value=" + i + "]").hide();
			}
		} else {
			$('.time').hide();
		}
	});

	$('#plan_time').on('change', function() {

		$('.time').show();
		var type = $("#plan_time").val()

		for (let i = 1; i <= 31; i++) {
			$(".time option[value=" + i + "]").show();
			$(".time option[value=" + i + "]").attr("selected", false);
		}

		if (type == "Day") {
			for (let i = 8; i <= 31; i++) {
				$(".time option[value=" + i + "]").hide();
			}
		} else if (type == "Week") {
			for (let i = 5; i <= 31; i++) {
				$(".time option[value=" + i + "]").hide();
			}
		} else if (type == "Month") {
			for (let i = 13; i <= 31; i++) {
				$(".time option[value=" + i + "]").hide();
			}
		} else if (type == "Year") {
			for (let i = 2; i <= 31; i++) {
				$(".time option[value=" + i + "]").hide();
			}
		} else {
			$('.time').hide();
		}
	})
</script>
@endsection