@extends('author.layout.page-app')
@section('page_title', __('label.episodes'))
@section('tab_title', __('label.episodes'))

@section('content')
    @include('author.layout.sidebar')

    <div class="right-content">
        @include('author.layout.header')

        <div class="body-content">
            <!-- mobile title -->
            <h1 class="page-title-sm">{{__('label.episodes')}}</h1>

            <div class="border-bottom row mb-3">
                <div class="col-sm-10">
                    <ol class="breadcrumb">
                        <li class="breadcrumb-item"><a href="{{ route('author.dashboard') }}">{{__('label.dashboard')}}</a></li>
                        <li class="breadcrumb-item"><a href="{{ route('author.audiobooks.index') }}">{{__('label.audiobooks')}}</a></li>
                        <li class="breadcrumb-item active" aria-current="page">{{__('label.episodes')}}</li>
                    </ol>
                </div>
                <div class="col-sm-2 d-flex align-items-center justify-content-end">
                    <a href="{{ route('author.audiobooks.index') }}" class="btn btn-default mw-120 mb-3">{{__('label.audiobooks')}}</a>
                </div>
            </div>

            <!-- Search -->
            <form action="{{ route('author.audiobooks.episodes.index', $audio_book_id)}}" method="GET">
                <div class="page-search mb-2">
                    <div class="input-group">
                        <div class="input-group-prepend">
                            <span class="input-group-text" id="basic-addon1">
                                <i class="fa-solid fa-magnifying-glass fa-xl light-gray"></i>
                            </span>
                        </div>
                        <input type="text" name="input_search" value="@if(isset($_GET['input_search'])){{ $_GET['input_search'] }}@endif" class="form-control" placeholder="{{__('label.search')}}" aria-label="Search" aria-describedby="basic-addon1">
                    </div>
                    <div class="mr-3 ml-5">
                        <button class="btn btn-default" type="submit">{{__('label.search')}}</button>
                    </div>
                    <div class="mr-3 ml-5">
                        <button type="button" data-toggle="modal" data-target="#exampleModal" class="btn btn-default br-10">
                            <i class="fa-solid fa-sort fa-2x"></i>
                        </button>
                    </div>
                </div>
            </form>

            <div class="row">
                <div class="col-12 col-sm-6 col-md-4 col-xl-3">
                    <a href="{{ route('author.audiobooks.episodes.add', $audio_book_id) }}" class="add-video-btn">
                        <i class="fa-regular fa-square-plus fa-3x icon text-gray"></i>
                        {{__('label.add_episode')}}
                    </a>
                </div>

                @foreach ($data as $key => $value)
                    <div class="col-12 col-sm-6 col-md-4 col-xl-3">
                        <div class="card video-card">
                            <div class="position-relative">
                                @if($value['is_episode_paid'] == 1)
                                    <div class="ribbon ribbon-top-left"><span>{{__('label.is_paid')}}</span></div>
                                @endif
                                <img src="{{ $value['image'] }}" class="card-img-top">

                                <ul class="list-inline overlap-control">
                                    <li class="list-inline-item">
                                        <a class="btn" href="{{route('author.audiobooks.episodes.edit', [$audio_book_id, $value->id])}}">
                                            <i class="fa-solid fa-pen-to-square fa-xl primary-color"></i>
                                        </a>
                                    </li>
                                    <li class="list-inline-item">
                                        <a class="btn" href="{{route('author.audiobooks.episodes.delete', [$audio_book_id, $value->id])}}" onclick="return confirm('{{ __('label.delete_episode') }}')">
                                            <i class="fa-solid fa-trash-can fa-xl primary-color"></i>
                                        </a>
                                    </li>
                                </ul>
                            </div>

                            <div class="card-body">
                                <h5 class="card-title">{{$value->title}}</h5>
                                <div class="d-flex justify-content-between">
                                    <div class="d-flex text-align-center">
                                        <span class="d-flex text-align-center mr-3">
                                            <i class="fa-solid fa-play fa-xl mr-3 primary-color mt-12"></i>
                                            <h5 class="counting" data-count="{{ No_Format($value->total_played ?? 0) }}">{{ No_Format($value->total_played) }}</h5>
                                        </span>
                                    </div>
                                    @if($value->is_episode_paid == 1)
                                        <h5 class="primary-color"><b>{{ Currency_Code() }} {{$value->price}}</b></h5>
                                    @endif
                                </div>
                            </div>
                        </div>
                    </div>
                @endforeach
            </div>

            <!-- Sortable -->
            <div class="modal fade" id="exampleModal" tabindex="-1" data-backdrop="static" role="dialog" aria-labelledby="exampleModalLabel" aria-hidden="true">
                <div class="modal-dialog" role="document">
                    <div class="modal-content">
                        <div class="modal-header">
                            <h5 class="modal-title w-100 text-center" id="exampleModalLabel">{{__('label.episodes_sortorder_list')}}</h5>
                            <button type="button" class="close" data-dismiss="modal" aria-label="Close" id="close">
                                <span aria-hidden="true" class="text-dark">&times;</span>
                            </button>
                        </div>
                        <div class="modal-body">
                            <div id="ListId">
                                @foreach ($sort_order as $key => $value)
                                <div id="{{$value->id}}" class="listitemClass mb-2 cursor">
                                    <p class="m-3">{{$value->title}}</p>
                                </div>
                                @endforeach
                            </div>
                        </div>

                        <div class="modal-footer justify-content-center">
                            <form enctype="multipart/form-data" id="save_episode_sortorder">
                                @csrf
                                <input id="outputvalues" type="hidden" name="ids" value="" />
                                <div class="w-100 text-center">
                                    <button type="button" class="btn btn-default mw-120" onclick="save_episode_sortorder()">{{__('label.save')}}</button>
                                </div>
                            </form>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>
@endsection

@section('pagescript')
    <!-- Sortorder -->
    <script src="https://code.jquery.com/ui/1.10.4/jquery-ui.js"></script>

    <script>
        $("#ListId").sortable({
            update: function(event, ui) {
                getIdsOfList();
            }
        });
        function getIdsOfList() {
            var values = [];
            $('.listitemClass').each(function(index) {
                values.push($(this).attr("id")
                    .replace("imageNo", ""));
            });
            $('#outputvalues').val(values);
        }
        function save_episode_sortorder() {

            var Check_Admin = '<?php echo Demo_Mode(); ?>';
            if(Check_Admin == 1){

                $("#dvloader").show();
                var formData = new FormData($("#save_episode_sortorder")[0]);
                $.ajax({
                    type: 'POST',
                    url: '{{ route("author.audiobooks.episodes.sortorder") }}',
                    data: formData,
                    cache: false,
                    contentType: false,
                    processData: false,
                    success: function(resp) {
                        $("#dvloader").hide();
                        get_responce_message(resp, 'save_episode_sortorder', '{{ route("author.audiobooks.episodes.index", $audio_book_id)}}');
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