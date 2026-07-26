@extends('admin.layout.page-app')
@section('page_title', __('label.add_audiobook'))
@section('tab_title', __('label.add_audiobook'))

@section('content')
@include('admin.layout.sidebar')

<div class="right-content">
    @include('admin.layout.header')

    <!-- Select2 -->
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/select2/4.0.13/css/select2.min.css" />

    <div class="body-content">
        <!-- mobile title -->
        <h1 class="page-title-sm">{{__('label.add_audiobook')}}</h1>

        <div class="border-bottom row mb-3">
            <div class="col-sm-10">
                <ol class="breadcrumb">
                    <li class="breadcrumb-item"><a href="{{ route('admin.dashboard') }}">{{__('label.dashboard')}}</a></li>
                    <li class="breadcrumb-item"><a href="{{ route('admin.audiobooks.index') }}">{{__('label.audiobooks')}}</a></li>
                    <li class="breadcrumb-item active" aria-current="page">{{__('label.add_audiobook')}}</li>
                </ol>
            </div>
            <div class="col-sm-2 d-flex align-items-center justify-content-end">
                <a href="{{ route('admin.audiobooks.index') }}" class="btn btn-default mw-120 mb-3">{{__('label.audiobooks_list')}}</a>
            </div>
        </div>

        <div class="card custom-border-card">
            <div class="card-body py-0">
                <form id="save_audiobook" enctype="multipart/form-data">
                    <input type="hidden" name="id">
                    <div class="form-row">
                        <div class="col-md-9">
                            <div class="form-row">
                                <div class="col-md-4">
                                    <div class="form-group">
                                        <label>{{__('label.authors')}}<span class="text-danger">*</span></label>
                                        <select class="form-control" name="author_id" id="author_id" style="width:100%!important;">
                                            <option value="">{{__('label.select_author')}}</option>
                                            @foreach ($author as $item)
                                            <option value="{{ $item['id'] }}">{{ $item['first_name'] }} {{ $item['last_name'] }}</option>
                                            @endforeach
                                        </select>
                                    </div>
                                </div>
                                <div class="col-md-4">
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
                                <div class="col-md-4">
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
                                            <label>{{__('label.upload_full_audio')}}</label>
                                            <div id="filelist3"></div>
                                            <div id="container3" class="position-relative">
                                                <div class="form-group">
                                                    <input type="file" id="uploadFile3" name="uploadFile3" class="form-control import-file p-2" accept=".mp3">
                                                </div>
                                                <input type="hidden" name="full_audio" id="full_audio_file_name" class="form-control">
                                            </div>
                                        </div>
                                    </div>
                                </div>
                                <div class="col-md-2 mt-4">
                                    <div class="form-group mt-3">
                                        <a id="upload3" class="btn text-white bg-primary-color">{{__('label.upload_audiobook')}}</a>
                                    </div>
                                </div>
                                <div class="col-md-4 price">
                                    <div class="form-group">
                                        <label>{{__('label.price')}}<span class="text-danger">*</span></label>
                                        <input type="number" name="price" class="form-control" min="0" placeholder="{{__('label.price_here')}}">
                                    </div>
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
                            <!-- BSNB / ISBN and Publisher Author -->
                            <div class="form-row mt-2">
                                <div class="col-md-6">
                                    <div class="form-group">
                                        <label>BSNB / ISBN <small class="text-muted">(Optional)</small></label>
                                        <input type="text" name="isbn" class="form-control" placeholder="Enter BSNB or ISBN number">
                                    </div>
                                </div>
                                <div class="col-md-6">
                                    <div class="form-group">
                                        <label>Publisher's Author Name <small class="text-muted">(If author has no account)</small></label>
                                        <input type="text" name="publisher_author_name" class="form-control" placeholder="Enter author name manually">
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
                        <button type="button" class="btn btn-default mw-120" onclick="save_audiobook()">{{__('label.save')}}</button>
                        <a href="{{route('admin.audiobooks.index')}}" class="btn btn-cancel mw-120 ml-2">{{__('label.cancel')}}</a>
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
    // Sidebar Scroll Down
    sidebar_down(350);

    $(document).ready(function() {
        $("#author_id").select2();
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

    // Save AudioBook
    function save_audiobook() {

        var Demo_Mode = '<?php echo Demo_Mode(); ?>';
        if (Demo_Mode == 1) {

            $("#dvloader").show();
            var formData = new FormData($("#save_audiobook")[0]);
            $.ajax({
                type: 'POST',
                url: '{{ route("admin.audiobooks.store") }}',
                data: formData,
                cache: false,
                contentType: false,
                processData: false,
                success: function(resp) {
                    $("#dvloader").hide();
                    get_responce_message(resp, 'save_audiobook', '{{ route("admin.audiobooks.index") }}');
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