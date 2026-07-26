@extends('admin.layout.page-app')
@section('page_title', __('label.edit_episode'))
@section('tab_title', __('label.edit_episode'))

@section('content')
    @include('admin.layout.sidebar')

    <div class="right-content">
        @include('admin.layout.header')

        <div class="body-content">
            <!-- mobile title -->
            <h1 class="page-title-sm">{{__('label.edit_episode')}}</h1>

            <div class="border-bottom row mb-3">
                <div class="col-sm-10">
                    <ol class="breadcrumb">
                        <li class="breadcrumb-item"><a href="{{ route('admin.dashboard') }}">{{__('label.dashboard')}}</a></li>
                        <li class="breadcrumb-item"><a href="{{ route('admin.audiobooks.index') }}">{{__('label.audiobooks')}}</a></li>
                        <li class="breadcrumb-item"><a href="{{ route('admin.audiobooks.episodes.index', ['id' => $audio_book_id]) }}">{{__('label.episodes')}}</a></li>
                        <li class="breadcrumb-item active" aria-current="page">{{__('label.edit_episode')}}</li>
                    </ol>
                </div>
                <div class="col-sm-2 d-flex align-items-center justify-content-end">
                    <a href="{{ route('admin.audiobooks.episodes.index', ['id' => $audio_book_id]) }}" class="btn btn-default mw-120 mb-3" >{{__('label.episodes')}}</a>
                </div>
            </div>

            <div class="card custom-border-card">
                <form id="episode" enctype="multipart/form-data">
                    <input type="hidden" name="id" value="{{ $data['id'] }}">
                    <input type="hidden" name="audio_book_id" value="{{ $audio_book_id }}">
                    <input type="hidden" name="old_audio" value="{{ $data['audio'] }}">
                    <div class="form-row">
                        <div class="col-md-9">
                            <div class="form-row">
                                <div class="col-md-8">
                                    <div class="form-group">
                                        <label>{{__('label.title')}}<span class="text-danger">*</span></label>
                                        <input type="text" name="title" value="{{ $data['title'] }}" class="form-control" placeholder="{{__('label.title_here')}}" autofocus>
                                    </div>
                                </div>
                                <div class="col-md-4">
                                    <div class="form-group">
                                        <label>{{__('label.is_episode_paid')}}<span class="text-danger">*</span></label>
                                        <div class="radio-group">
                                            <div class="custom-control custom-radio">
                                                <input type="radio" name="is_episode_paid" id="is_episode_paid_no" class="custom-control-input" value="0" {{ $data['is_episode_paid'] == 0 ? 'checked' : ''}}>
                                                <label class="custom-control-label" for="is_episode_paid_no">{{__('label.no')}}</label>
                                            </div>
                                            <div class="custom-control custom-radio">
                                                <input type="radio" name="is_episode_paid" id="is_episode_paid_yes" class="custom-control-input" value="1" {{ $data['is_episode_paid'] == 1 ? 'checked' : ''}}>
                                                <label class="custom-control-label" for="is_episode_paid_yes">{{__('label.yes')}}</label>
                                            </div>
                                        </div>
                                    </div>
                                </div>
                            </div>
                            <div class="form-row">
                                <div class="col-md-2">
                                    <div class="form-group">
                                        <label>{{__('label.audio_type')}}<span class="text-danger">*</span></label>
                                        <select name="audio_type" id="audio_type" class="form-control">
                                            <option value="1" {{ $data['audio_type'] == 1 ? 'selected' : ''}}>{{__('label.server_audio')}}</option>
                                            <option value="2" {{ $data['audio_type'] == 2 ? 'selected' : ''}}>{{__('label.external_url')}}</option>
                                        </select>
                                    </div> 
                                </div>
                                <div class="col-md-4 server_audio">
                                    <div class="form-group">
                                        <div class="d-block">
                                            <label>{{__('label.upload_audio')}}<span class="text-danger">*</span></label>
                                            <div id="filelist4"></div>
                                            <div id="container4" class="position-relative" >
                                                <div class="form-group">
                                                    <input type="file" id="uploadFile4" name="uploadFile4" class="form-control import-file p-2" accept=".mp3">
                                                </div>
                                                <input type="hidden" name="audio" id="audio_file_name" class="form-control">
                                            </div>
                                        </div>
                                        <a href="{{ $data['audio'] }}" target="_blank" class="btn-link">@if($data['audio_type'] == 1){{ basename($data['audio']) }}@endif</a>
                                    </div>
                                </div>
                                <div class="col-md-2 mt-4 server_audio">
                                    <div class="form-group mt-3">
                                        <a id="upload4" class="btn text-white bg-primary-color">{{__('label.upload_audio')}}</a>
                                    </div>
                                </div>
                                <div class="col-md-6 external_url">
                                    <div class="form-group">
                                        <label>{{__('label.url')}}<span class="text-danger">*</span></label>
                                        <input type="url" name="audio_url" value="@if($data['audio_type'] == 2){{ $data['audio'] }}@endif" class="form-control" placeholder="{{__('label.url_here')}}">
                                    </div>
                                </div>
                                <div class="col-md-4 price">
                                    <div class="form-group">
                                        <label>{{__('label.price')}}<span class="text-danger">*</span></label>
                                        <input type="number" name="price" value="{{ $data['price'] }}" class="form-control" min="0" placeholder="{{__('label.price_here')}}">
                                    </div>
                                </div>
                            </div>
                        </div>
                        <div class="col-md-3">
                            <div class="form-group ml-5">
                                <label class="ml-5">{{__('label.image')}}<span class="text-danger">*</span></label>
                                <div class="avatar-upload ml-5">
                                    <div class="avatar-edit">
                                        <input type='file' name="image" id="imageUpload" accept=".png, .jpg, .jpeg, .webp" />
                                        <label for="imageUpload" title="{{__('label.upload_file')}}"></label>
                                    </div>
                                    <div class="avatar-preview">
                                        <img src="{{ $data['image'] }}" id="imagePreview">
                                    </div>
                                </div>
                                <input type="hidden" name="old_image" value="{{ $data['image'] }}">
                                <label class="mt-3 ml-5 text-gray">{{__('label.max_size_5mb')}}</label>
                            </div>
                        </div>
                    </div>
                    <div class="form-row">
                        <div class="col-md-12">
                            <div class="form-group">
                                <label>{{__('label.description')}}</label>
                                <textarea class="form-control" name="description" rows="2" placeholder="{{__('label.description_here')}}">{{ $data['description'] }}</textarea>
                            </div>
                        </div>
                    </div>
                    <div class="border-top pt-3 text-right">
                        <button type="button" class="btn btn-default mw-120" onclick="update_episode()">{{__('label.update')}}</button>
                        <a href="{{ route('admin.audiobooks.episodes.index', ['id' => $audio_book_id]) }}" class="btn btn-cancel mw-120 ml-2">{{__('label.cancel')}}</a>
                        <input type="hidden" name="_token" value="{{ csrf_token() }}">
                    </div>
                </form>
            </div>
        </div>
    </div>
@endsection

@section('pagescript')
    <!-- Chunk JS -->
    <script src="{{ asset('/assets/js/plupload.full.min.js')}}"></script>
    <script src="{{ asset('/assets/js/common.js')}}"></script>

    <script>
        // Sidebar Scroll Down
		sidebar_down(350);

        $(document).ready(function() {
            var audio_type = "<?php echo $data->audio_type; ?>";
            if (audio_type == 1) {
                $(".server_audio").show();
                $(".external_url").hide();
            } else {
                $(".server_audio").hide();
                $(".external_url").show();
            }
            $('#audio_type').change(function() {

                var optionValue = $(this).val();
                if (optionValue == 1) {
                    $(".server_audio").show();
                    $(".external_url").hide();
                } else {
                    $(".server_audio").hide();
                    $(".external_url").show();
                }
            });

            var is_episode_paid = "<?php echo $data->is_episode_paid; ?>";
            if (is_episode_paid == 1) {
                $(".price").show();
            } else {
                $(".price").hide();
            }
            $('input[type=radio][name=is_episode_paid]').change(function() {
                if (this.value == 1) {
                    $(".price").show();
                } else {
                    $(".price").hide();
                }
            });
        });

        function update_episode() {

            var Demo_Mode = '<?php echo Demo_Mode(); ?>';
            if (Demo_Mode == 1) {

                $("#dvloader").show();
                var formData = new FormData($("#episode")[0]);
                $.ajax({
                    type: 'POST',
                    url: '{{ route("admin.audiobooks.episodes.update", $data->id) }}',
                    data: formData,
                    cache: false,
                    contentType: false,
                    processData: false,
                    success: function(resp) {
                        $("#dvloader").hide();
                        get_responce_message(resp, 'episode', "{{ route('admin.audiobooks.episodes.index', ['id' => $audio_book_id]) }}");
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