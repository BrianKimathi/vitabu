@extends('author.layout.page-app')
@section('page_title', __('label.add_novel'))
@section('tab_title', __('label.add_novel'))

@section('content')
@include('author.layout.sidebar')

<div class="right-content">
    @include('author.layout.header')

    <!-- Select2 -->
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/select2/4.0.13/css/select2.min.css" />

    <div class="body-content">
        <!-- mobile title -->
        <h1 class="page-title-sm">{{__('label.add_novel')}}</h1>

        <div class="border-bottom row mb-3">
            <div class="col-sm-10">
                <ol class="breadcrumb">
                    <li class="breadcrumb-item"><a href="{{ route('author.dashboard') }}">{{__('label.dashboard')}}</a></li>
                    <li class="breadcrumb-item"><a href="{{ route('author.novels.index') }}">{{__('label.novels')}}</a></li>
                    <li class="breadcrumb-item active" aria-current="page">{{__('label.add_novel')}}</li>
                </ol>
            </div>
            <div class="col-sm-2 d-flex align-items-center justify-content-end">
                <a href="{{ route('author.novels.index') }}" class="btn btn-default mw-120 mb-3">{{__('label.novels_list')}}</a>
            </div>
        </div>

        <div class="card custom-border-card">
            <div class="card-body py-0">
                <form id="save_novel" enctype="multipart/form-data">
                    <input type="hidden" name="id">
                    <div class="form-row">
                        <div class="col-md-9">
                            <div class="form-row">
                                <div class="col-md-6">
                                    <div class="form-group">
                                        <label>{{__('label.category')}}<span class="text-danger">*</span></label>
                                        <select class="form-control" name="category_id" id="category_id" style="width:100%!important;">
                                            <option value="">{{__('label.select_category')}}</option>
                                            @foreach ($category as $item)
                                            <option value="{{ $item['id'] }}">{{ $item['name'] }}</option>
                                            @endforeach
                                        </select>
                                    </div>
                                </div>
                                <div class="col-md-6">
                                    <div class="form-group">
                                        <label>{{__('label.language')}}<span class="text-danger">*</span></label>
                                        <select class="form-control" name="language_id" id="language_id" style="width:100%!important;">
                                            <option value="">{{__('label.select_language')}}</option>
                                            @foreach ($language as $item)
                                            <option value="{{ $item['id'] }}">{{ $item['name'] }}</option>
                                            @endforeach
                                        </select>
                                    </div>
                                </div>
                            </div>
                            <div class="form-row">
                                <div class="col-md-8">
                                    <div class="form-group">
                                        <label>{{__('label.title')}}<span class="text-danger">*</span></label>
                                        <input type="text" name="title" class="form-control" placeholder="{{__('label.title_here')}}">
                                    </div>
                                </div>
                                <div class="col-md-4">
                                    <div class="form-group">
                                        <label>{{__('label.access_type')}}<span class="text-danger">*</span></label>
                                        <select class="form-control" name="access_type" id="access_type">
                                            <option value="">{{__('label.select_access_type')}}</option>
                                            <option value="0">{{__('label.free')}}</option>
                                            <option value="1">{{__('label.paid')}}</option>
                                            <option value="2">{{__('label.subscription_included')}}</option>
                                        </select>
                                    </div>
                                </div>
                            </div>
                            <div class="form-row">
                                <div class="col-md-6">
                                    <div class="form-group">
                                        <div class="d-block">
                                            <label>{{__('label.upload_full_novel')}}</label>
                                            <div id="filelist"></div>
                                            <div id="container" class="position-relative">
                                                <div class="form-group">
                                                    <input type="file" id="uploadFile" name="uploadFile" class="form-control import-file p-2" accept=".pdf, .epub">
                                                </div>
                                                <input type="hidden" name="full_novel" id="novel_file_name" class="form-control">
                                            </div>
                                        </div>
                                    </div>
                                </div>
                                <div class="col-md-2 mt-4">
                                    <div class="form-group mt-3">
                                        <a id="upload" class="btn text-white bg-primary-color">{{__('label.upload_novel')}}</a>
                                    </div>
                                </div>
                                <div class="col-md-4 price">
                                    <div class="form-group">
                                        <label>{{__('label.price')}}<span class="text-danger">*</span></label>
                                        <input type="number" name="price" class="form-control" min="0" value="0" placeholder="{{__('label.price_here')}}">
                                    </div>
                                </div>
                            </div>
                            <div class="form-row mt-2">
                                <div class="col-md-6">
                                    <div class="form-group">
                                        <label>Author Split Amount <small class="text-muted">(fixed per sale)</small></label>
                                        <input type="number" step="0.01" min="0" name="author_split_amount" class="form-control" placeholder="e.g. 2.50">
                                    </div>
                                </div>
                                <div class="col-md-6">
                                    <div class="form-group">
                                        <label>Author Split % <small class="text-muted">(percentage per sale)</small></label>
                                        <input type="number" step="0.01" min="0" max="100" name="author_split_percentage" class="form-control" placeholder="e.g. 70">
                                    </div>
                                </div>
                                <div class="col-12">
                                    <small class="text-muted">Leave empty to use default commission rate. If both set, % takes priority.</small>
                                </div>
                            </div>
                        </div>
                        <div class="col-md-3">
                            <div class="form-group ml-5">
                                <label class="ml-5">{{__('label.portrait_image')}}<span class="text-danger">*</span></label>
                                <div class="avatar-upload ml-5">
                                    <div class="avatar-edit">
                                        <input type='file' name="portrait_img" id="imageUpload" accept=".png, .jpg, .jpeg, .webp" />
                                        <label for="imageUpload" title="{{__('label.upload_file')}}"></label>
                                    </div>
                                    <div class="avatar-preview">
                                        <img src="{{asset('assets/imgs/upload_img.png')}}" id="imagePreview">
                                    </div>
                                </div>
                                <label class="mt-3 ml-5 text-gray">{{__('label.max_size_5mb')}}</label>
                            </div>
                        </div>
                    </div>
                    <div class="form-row">
                        <div class="col-md-9">
                            <div class="form-row">
                                <div class="col-md-12">
                                    <div class="form-group">
                                        <label>{{__('label.description')}}</label>
                                        <textarea class="form-control" name="description" rows="5" placeholder="{{__('label.description_here')}}"></textarea>
                                    </div>
                                </div>
                            </div>
                        </div>
                        <div class="col-md-3">
                            <div class="form-group ml-5">
                                <label class="ml-5">{{__('label.landscape_image')}}<span class="text-danger">*</span></label>
                                <div class="avatar-upload-landscape ml-5">
                                    <div class="avatar-edit-landscape">
                                        <input type='file' name="landscape_img" id="imageUploadLandscape" accept=".png, .jpg, .jpeg, .webp" />
                                        <label for="imageUploadLandscape" title="{{__('label.upload_file')}}"></label>
                                    </div>
                                    <div class="avatar-preview-landscape">
                                        <img src="{{asset('assets/imgs/upload_img.png')}}" id="imagePreviewLandscape">
                                    </div>
                                </div>
                                <label class="mt-3 ml-5 text-gray">{{__('label.max_size_5mb')}}</label>
                            </div>
                        </div>
                    </div>
                    <div class="border-top pt-3 text-right">
                        <button type="button" class="btn btn-default mw-120" onclick="save_novel()">{{__('label.save')}}</button>
                        <a href="{{route('author.novels.index')}}" class="btn btn-cancel mw-120 ml-2">{{__('label.cancel')}}</a>
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
<!-- Chunk JS -->
<script src="{{ asset('/assets/js/plupload.full.min.js')}}"></script>
<script src="{{ asset('/assets/js/common.js')}}"></script>

<script>
    $(document).ready(function() {
        $("#category_id").select2();
        $("#language_id").select2();
        $('#access_type').select2();

        $(".price").hide();
        $('#access_type').change(function() {
            if ($(this).val() == 1) {
                $(".price").show();
            } else {
                $(".price").hide();

            }
        });
    });

    // Save Novel
    function save_novel() {

        var Demo_Mode = '<?php echo Demo_Mode(); ?>';
        if (Demo_Mode == 1) {

            $("#dvloader").show();
            var formData = new FormData($("#save_novel")[0]);
            $.ajax({
                type: 'POST',
                url: '{{ route("author.novels.store") }}',
                data: formData,
                cache: false,
                contentType: false,
                processData: false,
                success: function(resp) {
                    $("#dvloader").hide();
                    get_responce_message(resp, 'save_novel', '{{ route("author.novels.index") }}');
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