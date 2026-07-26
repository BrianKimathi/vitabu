@extends('admin.layout.page-app')
@section('page_title', __('label.magazines_section'))
@section('tab_title', __('label.magazines_section'))

@section('content')
@include('admin.layout.sidebar')

<div class="right-content">
    @include('admin.layout.header')

    <!-- Select2 -->
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/select2/4.0.13/css/select2.min.css" />

    <div class="body-content">
        <!-- mobile title -->
        <h1 class="page-title-sm">{{ __('label.magazines_section') }}</h1>

        <div class="border-bottom row mb-3">
            <div class="col-sm-11">
                <ol class="breadcrumb">
                    <li class="breadcrumb-item"><a href="{{ route('admin.dashboard') }}">{{ __('label.dashboard') }}</a></li>
                    <li class="breadcrumb-item active" aria-current="page">{{ __('label.magazines_section') }}</li>
                </ol>
            </div>
            <div class="col-sm-1 d-flex justify-content-start mb-3">
                <button type="button" data-toggle="modal" data-target="#sortOrderModal" class="btn btn-default br-10">
                    <i class="fa-solid fa-sort fa-1x"></i>
                </button>
            </div>
        </div>

        <!-- Add Magazines Section -->
        <div class="card custom-border-card">
            <h5 class="card-header">{{ __('label.add_magazines_section') }}</h5>
            <div class="card-body">
                <form id="save_magazines_section" enctype="multipart/form-data">
                    <input type="hidden" name="id" value="">
                    <div class="form-row">
                        <div class="col-md-3">
                            <div class="form-group">
                                <label>{{ __('label.title') }}<span class="text-danger">*</span></label>
                                <input type="text" name="title" class="form-control" placeholder="{{ __('label.title_here') }}" autofocus>
                            </div>
                        </div>
                        <div class="col-md-3">
                            <div class="form-group">
                                <label>{{ __('label.short_title') }}</label>
                                <input type="text" name="short_title" class="form-control" placeholder="{{ __('label.short_title_here') }}">
                            </div>
                        </div>
                        <div class="col-md-3 content_type_drop">
                            <div class="form-group">
                                <label>{{ __('label.content_type') }}<span class="text-danger">*</span></label>
                                <select name="content_type" class="form-control" id="content_type">
                                    <option value="">{{ __('label.select_content_type') }}</option>
                                    <option value="3">{{ __('label.magazines') }}</option>
                                    <option value="4">{{ __('label.category') }}</option>
                                    <option value="5">{{ __('label.language') }}</option>
                                    <option value="6">{{ __('label.authors') }}</option>
                                </select>
                            </div>
                        </div>
                        <div class="col-md-3 screen_layout_drop">
                            <div class="form-group">
                                <label>{{ __('label.screen_layout') }}<span class="text-danger">*</span></label>
                                <select name="screen_layout" class="form-control" id="screen_layout">
                                    <option value="">{{ __('label.select_screen_layout') }}</option>
                                    <option value="banner">{{ __('label.banner') }}</option>
                                    <option value="portrait">{{ __('label.portrait') }}</option>
                                    <option value="square">{{ __('label.square') }}</option>
                                    <option value="horizontal_view">{{ __('label.horizontal_view') }}</option>
                                    <option value="category">{{ __('label.category') }}</option>
                                    <option value="language">{{ __('label.language') }}</option>
                                    <option value="author">{{ __('label.author') }}</option>
                                </select>
                            </div>
                        </div>
                        <div class="col-md-3 author_drop">
                            <div class="form-group">
                                <label>{{ __('label.authors') }}<span class="text-danger">*</span></label>
                                <select name="author_id" class="form-control" id="author_id">
                                    <option value="0">{{ __('label.all_authors') }}</option>
                                    @for ($i = 0; $i < count($author); $i++)
                                        <option value="{{ $author[$i]['id'] }}">
                                        {{ $author[$i]['first_name'] }} {{ $author[$i]['last_name'] }}
                                        </option>
                                        @endfor
                                </select>
                            </div>
                        </div>
                        <div class="col-md-3 category_drop">
                            <div class="form-group">
                                <label>{{ __('label.category') }}<span class="text-danger">*</span></label>
                                <select name="category_id" class="form-control" id="category_id">
                                    <option value="0">{{ __('label.all_category') }}</option>
                                    @for ($i = 0; $i < count($category); $i++)
                                        <option value="{{ $category[$i]['id'] }}">
                                        {{ $category[$i]['name'] }}
                                        </option>
                                        @endfor
                                </select>
                            </div>
                        </div>
                        <div class="col-md-3 language_drop">
                            <div class="form-group">
                                <label>{{ __('label.language') }}<span class="text-danger">*</span></label>
                                <select name="language_id" class="form-control" id="language_id">
                                    <option value="0">{{ __('label.all_language') }}</option>
                                    @for ($i = 0; $i < count($language); $i++)
                                        <option value="{{ $language[$i]['id'] }}">
                                        {{ $language[$i]['name'] }}
                                        </option>
                                        @endfor
                                </select>
                            </div>
                        </div>
                        <div class="col-md-3 access_type_drop">
                            <div class="form-group">
                                <label>{{ __('label.access_type') }}<span class="text-danger">*</span></label>
                                <select name="access_type" class="form-control" id="access_type">
                                    <option value="">{{__('label.select_access_type')}}</option>
                                    <option value="0">
                                        {{__('label.free')}}
                                    </option>
                                    <option value="1">
                                        {{__('label.paid')}}
                                    </option>
                                    <option value="2">
                                        {{__('label.subscription_included')}}
                                    </option>
                                </select>
                            </div>
                        </div>
                        <div class="col-md-3 no_of_content">
                            <div class="form-group">
                                <label>{{ __('label.no_of_content') }}<span class="text-danger">*</span></label>
                                <input type="number" name="no_of_content" min="1" class="form-control" placeholder="{{ __('label.no_of_content_here') }}">
                            </div>
                        </div>
                        <div class="col-md-3 order_by_view">
                            <div class="form-group">
                                <label>{{ __('label.order_by_view') }}<span class="text-danger">*</span></label>
                                <div class="radio-group">
                                    <div class="custom-control custom-radio">
                                        <input type="radio" name="order_by_view" id="order_by_view_asc" class="custom-control-input" value="1">
                                        <label class="custom-control-label" for="order_by_view_asc">{{ __('label.asc') }}</label>
                                    </div>
                                    <div class="custom-control custom-radio">
                                        <input type="radio" name="order_by_view" id="order_by_view_desc" class="custom-control-input" value="2" checked>
                                        <label class="custom-control-label" for="order_by_view_desc">{{ __('label.desc') }}</label>
                                    </div>
                                </div>
                            </div>
                        </div>
                        <div class="col-md-3 order_by_upload">
                            <div class="form-group">
                                <label>{{ __('label.order_by_upload') }}<span class="text-danger">*</span></label>
                                <div class="radio-group">
                                    <div class="custom-control custom-radio">
                                        <input type="radio" name="order_by_upload" id="order_by_upload_asc" class="custom-control-input" value="1" checked>
                                        <label class="custom-control-label" for="order_by_upload_asc">{{ __('label.asc') }}</label>
                                    </div>
                                    <div class="custom-control custom-radio">
                                        <input type="radio" name="order_by_upload" id="order_by_upload_desc" class="custom-control-input" value="2">
                                        <label class="custom-control-label" for="order_by_upload_desc">{{ __('label.desc') }}</label>
                                    </div>
                                </div>
                            </div>
                        </div>
                        <div class="col-md-3 view_all">
                            <div class="form-group">
                                <label>{{ __('label.view_all_content') }}<span class="text-danger">*</span></label>
                                <div class="radio-group">
                                    <div class="custom-control custom-radio">
                                        <input type="radio" name="view_all" id="view_all_no" class="custom-control-input" value="0">
                                        <label class="custom-control-label" for="view_all_no">{{ __('label.no') }}</label>
                                    </div>
                                    <div class="custom-control custom-radio">
                                        <input type="radio" name="view_all" id="view_all_yes" class="custom-control-input" value="1" checked>
                                        <label class="custom-control-label" for="view_all_yes">{{ __('label.yes') }}</label>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>
                    <div class="border-top pt-3 text-right">
                        <button type="button" class="btn btn-default mw-120" onclick="save_magazines_section()">{{ __('label.save') }}</button>
                        <input type="hidden" name="_token" value="{{ csrf_token() }}">
                    </div>
                </form>
            </div>
        </div>

        <!-- Section List -->
        @foreach($data as $section)
        <?php
        $content_type = "-";
        if ($section['content_type'] == 3) {
            $content_type = __('label.magazines');
        } else if ($section['content_type'] == 4) {
            $content_type = __('label.category');
        } else if ($section['content_type'] == 5) {
            $content_type = __('label.language');
        } else if ($section['content_type'] == 6) {
            $content_type = __('label.author');
        }

        $screen_layout = "-";
        if ($section['screen_layout'] == 'banner') {
            $screen_layout = __('label.banner');
        } else if ($section['screen_layout'] == 'portrait') {
            $screen_layout = __('label.portrait');
        } else if ($section['screen_layout'] == 'square') {
            $screen_layout = __('label.square');
        } else if ($section['screen_layout'] == 'horizontal_view') {
            $screen_layout = __('label.horizontal_view');
        } else if ($section['screen_layout'] == 'category') {
            $screen_layout = __('label.category');
        } else if ($section['screen_layout'] == 'language') {
            $screen_layout = __('label.language');
        } else if ($section['screen_layout'] == 'author') {
            $screen_layout = __('label.author');
        }
        ?>

        <div class="card custom-border-card mt-3">
            <div class="card-header d-flex justify-content-between">
                <h5>{{ __('label.edit_magazines_section') }}</h5>
                <div class="switch">
                    <input class="status-checkbox" id="checkbox{{$section['id']}}" data-id="{{$section['id']}}" type="checkbox" {{$section['status']==1 ? "checked" : ""}}>
                    <label for="checkbox{{$section['id']}}" class="my-auto"></label>
                    <span class="toggle-text"
                        data-on="{{ __('label.show')}}"
                        data-off="{{ __('label.hide')}}"></span>
                </div>
            </div>
            <div class="card-body">
                <div class="form-row">
                    <div class="col-md-3">
                        <div class="form-group">
                            <label>{{ __('label.title') }}</label>
                            <input type="text" name="title" value="{{ $section['title'] }}" class="form-control" readonly>
                        </div>
                    </div>
                    <div class="col-md-3">
                        <div class="form-group">
                            <label>{{ __('label.short_title') }}</label>
                            <input type="text" name="short_title" value="{{ $section['short_title'] }}" class="form-control" readonly>
                        </div>
                    </div>
                    <div class="col-md-3">
                        <div class="form-group">
                            <label>{{ __('label.content_type') }}</label>
                            <input type="text" name="content_type" value="{{ $content_type }}" class="form-control" readonly>
                        </div>
                    </div>
                    <div class="col-md-3">
                        <div class="form-group">
                            <label>{{ __('label.screen_layout') }}</label>
                            <input type="text" name="screen_layout" value="{{ $screen_layout }}" class="form-control" readonly>
                        </div>
                    </div>
                </div>
                <div class="border-top pt-3 text-right">
                    <button type="button" data-toggle="modal" data-target="#editSectionModal" onclick="edit_magazines_section('{{ $section['id'] }}')" class="btn btn-default mw-120">{{ __('label.update') }}</button>
                    <button type="button" onclick="delete_magazines_section('{{ $section['id'] }}')" class="btn btn-cancel mw-120 ml-2">{{ __('label.delete') }}</button>
                </div>
            </div>
        </div>
        @endforeach

        <!-- Edit Section Modal -->
        <div class="modal fade" id="editSectionModal" tabindex="-1" data-backdrop="static" role="dialog" aria-labelledby="editSectionModalLabel" aria-hidden="true">
            <div class="modal-dialog modal-lg" role="document">
                <div class="modal-content">
                    <div class="modal-header">
                        <h5 class="modal-title" id="editSectionModalLabel">{{ __('label.edit_magazines_section') }}</h5>
                        <button type="button" class="close text-dark" data-dismiss="modal" aria-label="Close">
                            <span aria-hidden="true">&times;</span>
                        </button>
                    </div>
                    <form id="edit_magazines_section" enctype="multipart/form-data">
                        <div class="modal-body">
                            <input type="hidden" name="id" id="edit_id" value="">
                            <div class="form-row">
                                <div class="col-md-6">
                                    <div class="form-group">
                                        <label>{{ __('label.title') }}<span class="text-danger">*</span></label>
                                        <input type="text" name="title" id="edit_title" class="form-control" placeholder="{{ __('label.title_here') }}">
                                    </div>
                                </div>
                                <div class="col-md-6">
                                    <div class="form-group">
                                        <label>{{ __('label.short_title') }}<span class="text-danger">*</span></label>
                                        <input type="text" name="short_title" id="edit_short_title" class="form-control" placeholder="{{ __('label.short_title_here') }}">
                                    </div>
                                </div>
                                <div class="col-md-6 edit_content_type_drop">
                                    <div class="form-group">
                                        <label>{{ __('label.content_type') }}<span class="text-danger">*</span></label>
                                        <select name="content_type" class="form-control" id="edit_content_type">
                                            <option value="">{{ __('label.select_content_type') }}</option>
                                            <option value="3">{{ __('label.magazines') }}</option>
                                            <option value="4">{{ __('label.category') }}</option>
                                            <option value="5">{{ __('label.language') }}</option>
                                            <option value="6">{{ __('label.authors') }}</option>
                                        </select>
                                    </div>
                                </div>
                                <div class="col-md-6 edit_screen_layout_drop">
                                    <div class="form-group">
                                        <label>{{ __('label.screen_layout') }}<span class="text-danger">*</span></label>
                                        <select name="screen_layout" class="form-control" id="edit_screen_layout">
                                            <option value="">{{ __('label.select_screen_layout') }}</option>
                                            <option value="banner">{{ __('label.banner') }}</option>
                                            <option value="portrait">{{ __('label.portrait') }}</option>
                                            <option value="square">{{ __('label.square') }}</option>
                                            <option value="horizontal_view">{{ __('label.horizontal_view') }}</option>
                                            <option value="category">{{ __('label.category') }}</option>
                                            <option value="language">{{ __('label.language') }}</option>
                                            <option value="author">{{ __('label.author') }}</option>
                                        </select>
                                    </div>
                                </div>
                                <div class="col-md-6 edit_author_drop">
                                    <div class="form-group">
                                        <label>{{ __('label.authors') }}<span class="text-danger">*</span></label>
                                        <select name="author_id" class="form-control" id="edit_author_id" style="width:100%!important;">
                                            <option value="0">{{ __('label.all_authors') }}</option>
                                            @for ($i = 0; $i < count($author); $i++)
                                                <option value="{{ $author[$i]['id'] }}">
                                                {{ $author[$i]['first_name'] }} {{ $author[$i]['last_name'] }}
                                                </option>
                                                @endfor
                                        </select>
                                    </div>
                                </div>
                                <div class="col-md-6 edit_category_drop">
                                    <div class="form-group">
                                        <label>{{ __('label.category') }}<span class="text-danger">*</span></label>
                                        <select name="category_id" class="form-control" id="edit_category_id" style="width:100%!important;">
                                            <option value="0">{{ __('label.all_category') }}</option>
                                            @for ($i = 0; $i < count($category); $i++)
                                                <option value="{{ $category[$i]['id'] }}">
                                                {{ $category[$i]['name'] }}
                                                </option>
                                                @endfor
                                        </select>
                                    </div>
                                </div>
                                <div class="col-md-6 edit_language_drop">
                                    <div class="form-group">
                                        <label>{{ __('label.language') }}<span class="text-danger">*</span></label>
                                        <select name="language_id" class="form-control" id="edit_language_id" style="width:100%!important;">
                                            <option value="0">{{ __('label.all_language') }}</option>
                                            @for ($i = 0; $i < count($language); $i++)
                                                <option value="{{ $language[$i]['id'] }}">
                                                {{ $language[$i]['name'] }}
                                                </option>
                                                @endfor
                                        </select>
                                    </div>
                                </div>
                                <div class="col-md-6 edit_access_type_drop">
                                    <div class="form-group">
                                        <label>{{ __('label.access_type') }}<span class="text-danger">*</span></label>
                                        <select name="access_type" class="form-control" id="edit_access_type" style="width:100%!important;">
                                            <option value="">{{__('label.select_access_type')}}</option>
                                            <option value="0">{{__('label.free')}}</option>
                                            <option value="1">{{__('label.paid')}}</option>
                                            <option value="2">{{__('label.subscription_included')}}</option>
                                        </select>
                                    </div>
                                </div>
                                <div class="col-md-6 edit_no_of_content">
                                    <div class="form-group">
                                        <label>{{ __('label.no_of_content') }}<span class="text-danger">*</span></label>
                                        <input type="number" name="no_of_content" id="edit_no_of_content" min="1" class="form-control" placeholder="{{ __('label.no_of_content_here') }}">
                                    </div>
                                </div>
                                <div class="col-md-6 edit_order_by_view">
                                    <div class="form-group">
                                        <label>{{ __('label.order_by_view') }}<span class="text-danger">*</span></label>
                                        <div class="radio-group">
                                            <div class="custom-control custom-radio">
                                                <input type="radio" name="order_by_view" id="edit_order_by_view_asc" class="custom-control-input" value="1">
                                                <label class="custom-control-label" for="edit_order_by_view_asc">{{ __('label.asc') }}</label>
                                            </div>
                                            <div class="custom-control custom-radio">
                                                <input type="radio" name="order_by_view" id="edit_order_by_view_desc" class="custom-control-input" value="2">
                                                <label class="custom-control-label" for="edit_order_by_view_desc">{{ __('label.desc') }}</label>
                                            </div>
                                        </div>
                                    </div>
                                </div>
                                <div class="col-md-6 edit_order_by_upload">
                                    <div class="form-group">
                                        <label>{{ __('label.order_by_upload') }}<span class="text-danger">*</span></label>
                                        <div class="radio-group">
                                            <div class="custom-control custom-radio">
                                                <input type="radio" name="order_by_upload" id="edit_order_by_upload_asc" class="custom-control-input" value="1">
                                                <label class="custom-control-label" for="edit_order_by_upload_asc">{{ __('label.asc') }}</label>
                                            </div>
                                            <div class="custom-control custom-radio">
                                                <input type="radio" name="order_by_upload" id="edit_order_by_upload_desc" class="custom-control-input" value="2">
                                                <label class="custom-control-label" for="edit_order_by_upload_desc">{{ __('label.desc') }}</label>
                                            </div>
                                        </div>
                                    </div>
                                </div>
                                <div class="col-md-6 edit_view_all">
                                    <div class="form-group">
                                        <label>{{ __('label.view_all_content') }}<span class="text-danger">*</span></label>
                                        <div class="radio-group">
                                            <div class="custom-control custom-radio">
                                                <input type="radio" name="view_all" id="edit_view_all_no" class="custom-control-input" value="0">
                                                <label class="custom-control-label" for="edit_view_all_no">{{ __('label.no') }}</label>
                                            </div>
                                            <div class="custom-control custom-radio">
                                                <input type="radio" name="view_all" id="edit_view_all_yes" class="custom-control-input" value="1">
                                                <label class="custom-control-label" for="edit_view_all_yes">{{ __('label.yes') }}</label>
                                            </div>
                                        </div>
                                    </div>
                                </div>
                            </div>
                        </div>
                        <div class="modal-footer">
                            <button type="button" class="btn btn-default mw-120" onclick="update_magazines_section()">{{ __('label.update') }}</button>
                            <input type="hidden" name="_method" value="PATCH">
                        </div>
                    </form>
                </div>
            </div>
        </div>

        <!-- Sort Order Modal -->
        <div class="modal fade" id="sortOrderModal" tabindex="-1" data-backdrop="static" role="dialog" aria-labelledby="sortOrderModalLabel" aria-hidden="true">
            <div class="modal-dialog" role="document">
                <div class="modal-content">
                    <div class="modal-header">
                        <h5 class="modal-title w-100 text-center" id="sortOrderModalLabel">{{ __('label.magazines_section_sort_order_list') }}</h5>
                        <button type="button" class="close" data-dismiss="modal" aria-label="Close">
                            <span aria-hidden="true" class="text-dark">&times;</span>
                        </button>
                    </div>
                    <div class="modal-body">
                        <div id="contentListId">
                            @foreach($data as $section)
                            <div id="{{ $section['id'] }}" class="listitemClass mb-2 cursor">
                                <p class="m-2">{{ $section['title'] }}</p>
                            </div>
                            @endforeach
                        </div>
                    </div>
                    <div class="modal-footer justify-content-center">
                        <form id="save_magazines_section_sortorder" enctype="multipart/form-data">
                            <input id="outputvalues" type="hidden" name="ids" value="" />
                            <div class="w-100 text-center">
                                <button type="button" class="btn btn-default mw-120" onclick="save_magazines_section_sortorder()">{{ __('label.save') }}</button>
                                <input type="hidden" name="_token" value="{{ csrf_token() }}">
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
<!-- Select2 -->
<script src="https://cdnjs.cloudflare.com/ajax/libs/select2/4.0.13/js/select2.min.js"></script>
<!-- Sortable -->
<script src="https://code.jquery.com/ui/1.10.4/jquery-ui.js"></script>

<script>
    // Sidebar Scroll Down
    sidebar_down(350);

    $("#author_id").select2();
    $("#category_id").select2();
    $("#language_id").select2();
    $("#access_type").select2();
    $("#edit_author_id").select2();
    $("#edit_category_id").select2();
    $("#edit_language_id").select2();
    $("#edit_access_type").select2();

    $(".category_drop").hide();
    $(".language_drop").hide();
    $(".author_drop").hide();
    $(".no_of_content").hide();
    $(".order_by_view").hide();
    $(".order_by_upload").hide();
    $(".access_type_drop").hide();
    $(".view_all").hide();
    $(".screen_layout_drop").hide();
    $("#content_type").change(function() {

        var content_type = $(this).children("option:selected").val();
        if (content_type == 3) {

            $(".category_drop").show();
            $(".language_drop").show();
            $(".author_drop").show();
            $(".no_of_content").show();
            $(".order_by_view").show();
            $(".order_by_upload").show();
            $(".access_type_drop").show();
            $('#access_type').val("").trigger('change');
            $(".view_all").show();
            $(".screen_layout_drop").show();
            $("#screen_layout").children().prop("selected", false);
            $("#screen_layout option[value='banner']").show();
            $("#screen_layout option[value='portrait']").show();
            $("#screen_layout option[value='square']").show();
            $("#screen_layout option[value='horizontal_view']").show();
            $("#screen_layout option[value='category']").hide();
            $("#screen_layout option[value='language']").hide();
            $("#screen_layout option[value='author']").hide();
        } else if (content_type == 4 || content_type == 5 || content_type == 6) {

            $(".category_drop").hide();
            $(".language_drop").hide();
            $(".author_drop").hide();
            $(".no_of_content").show();
            $(".order_by_view").hide();
            $(".order_by_upload").show();
            $(".access_type_drop").hide();
            $(".view_all").show();
            $(".screen_layout_drop").show();
            $("#screen_layout").children().prop("selected", false);
            $("#screen_layout option[value='banner']").hide();
            $("#screen_layout option[value='portrait']").hide();
            $("#screen_layout option[value='square']").hide();
            $("#screen_layout option[value='horizontal_view']").hide();
            if (content_type == 4) {
                $("#screen_layout option[value='category']").show();
                $("#screen_layout option[value='language']").hide();
                $("#screen_layout option[value='author']").hide();
            } else if (content_type == 5) {
                $("#screen_layout option[value='category']").hide();
                $("#screen_layout option[value='language']").show();
                $("#screen_layout option[value='author']").hide();
            } else if (content_type == 6) {
                $("#screen_layout option[value='category']").hide();
                $("#screen_layout option[value='language']").hide();
                $("#screen_layout option[value='author']").show();
            }
        } else {

            $(".category_drop").hide();
            $(".language_drop").hide();
            $(".author_drop").hide();
            $(".no_of_content").hide();
            $(".order_by_view").hide();
            $(".order_by_upload").hide();
            $(".access_type_drop").hide();
            $(".view_all").hide();
            $(".screen_layout_drop").hide();
        }
    });

    // Save Section
    function save_magazines_section() {

        var Demo_Mode = '<?php echo Demo_Mode(); ?>';
        if (Demo_Mode == 1) {

            $("#dvloader").show();
            var formData = new FormData($("#save_magazines_section")[0]);
            $.ajax({
                type: 'POST',
                url: "{{ route('admin.magazinessection.store') }}",
                data: formData,
                cache: false,
                contentType: false,
                processData: false,
                success: function(resp) {
                    $("#dvloader").hide();
                    get_responce_message(resp, 'save_magazines_section', "{{ route('admin.magazinessection.index') }}");
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

    // Change Section Status
    function change_status(id) {

        var Demo_Mode = '<?php echo Demo_Mode(); ?>';
        if (Demo_Mode == 1) {

            $("#dvloader").show();
            $.ajax({
                headers: {
                    'X-CSRF-TOKEN': $('meta[name="csrf-token"]').attr('content')
                },
                type: "POST",
                url: "{{ route('admin.magazinessection.status') }}",
                data: {
                    id: id
                },
                success: function(resp) {
                    $("#dvloader").hide();

                    if (resp.status == 200) {
                        toastr.success(resp.success);
                    } else {
                        toastr.error(resp.errors);
                    }
                },
                error: function(XMLHttpRequest, textStatus, errorThrown) {
                    $("#dvloader").hide();
                    toastr.error(errorThrown, textStatus);
                }
            });
        } else {
            showError();
        }
    };

    $(document).on('change', '.status-checkbox', function() {
        id = $(this).attr('data-id');
        change_status(id);
    })

    // Delete Section
    function delete_magazines_section(id) {

        var Demo_Mode = '<?php echo Demo_Mode(); ?>';
        if (Demo_Mode == 1) {

            var result = confirm('{{__("label.delete_magazines_section")}}');
            if (result) {

                $("#dvloader").show();

                var url = "{{ route('admin.magazinessection.show', ':id') }}";
                url = url.replace(':id', id);

                $.ajax({
                    headers: {
                        'X-CSRF-TOKEN': $('meta[name="csrf-token"]').attr('content')
                    },
                    type: 'GET',
                    url: url,
                    cache: false,
                    contentType: false,
                    processData: false,
                    success: function(resp) {
                        $("#dvloader").hide();
                        get_responce_message(resp, '', "{{ route('admin.magazinessection.index') }}");
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

    // Update Section
    function edit_magazines_section(id) {

        let editUrl = "{{ route('admin.magazinessection.edit', ':id') }}".replace(':id', id);

        $.ajax({
            headers: {
                'X-CSRF-TOKEN': $('meta[name="csrf-token"]').attr('content')
            },
            type: 'GET',
            url: editUrl,
            success: function(resp) {

                if (resp.data != null) {

                    $("#edit_id").val(resp.data.id);
                    $("#edit_title").val(resp.data.title);
                    $("#edit_short_title").val(resp.data.short_title);
                    $("#edit_content_type").val(resp.data.content_type).attr("selected", "selected");
                    $("#edit_screen_layout").val(resp.data.screen_layout).attr("selected", "selected");
                    $("#edit_author_id").val(resp.data.author_id).trigger('change');
                    $('#edit_category_id').val(resp.data.category_id).trigger('change');
                    $('#edit_language_id').val(resp.data.language_id).trigger('change');
                    $('#edit_access_type').val(resp.data.access_type).trigger('change');
                    $("#edit_no_of_content").val(resp.data.no_of_content);
                    if (resp.data.order_by_view == 1) {
                        $("#edit_order_by_view_asc").prop('checked', true);
                        $("#edit_order_by_view_desc").prop('checked', false);
                    } else {
                        $("#edit_order_by_view_asc").prop('checked', false);
                        $("#edit_order_by_view_desc").prop('checked', true);
                    }
                    if (resp.data.order_by_upload == 1) {
                        $("#edit_order_by_upload_asc").prop('checked', true);
                        $("#edit_order_by_upload_desc").prop('checked', false);
                    } else {
                        $("#edit_order_by_upload_asc").prop('checked', false);
                        $("#edit_order_by_upload_desc").prop('checked', true);
                    }
                    if (resp.data.view_all == 0) {
                        $("#edit_view_all_no").prop('checked', true);
                        $("#edit_view_all_yes").prop('checked', false);
                    } else {
                        $("#edit_view_all_no").prop('checked', false);
                        $("#edit_view_all_yes").prop('checked', true);
                    }

                    if (resp.data.content_type == 3) {

                        $(".edit_author_drop").show();
                        $(".edit_category_drop").show();
                        $(".edit_language_drop").show();
                        $(".edit_no_of_content").show();
                        $(".edit_order_by_view").show();
                        $(".edit_order_by_upload").show();
                        $(".edit_access_type_drop").show();
                        $(".edit_view_all").show();

                        $("#edit_screen_layout option[value='banner']").show();
                        $("#edit_screen_layout option[value='portrait']").show();
                        $("#edit_screen_layout option[value='square']").show();
                        $("#edit_screen_layout option[value='horizontal_view']").show();
                        $("#edit_screen_layout option[value='category']").hide();
                        $("#edit_screen_layout option[value='language']").hide();
                        $("#edit_screen_layout option[value='author']").hide();
                    } else if (resp.data.content_type == 4 || resp.data.content_type == 5 || resp.data.content_type == 6) {

                        $(".edit_author_drop").hide();
                        $(".edit_category_drop").hide();
                        $(".edit_language_drop").hide();
                        $(".edit_no_of_content").show();
                        $(".edit_order_by_view").hide();
                        $(".edit_order_by_upload").show();
                        $(".edit_access_type_drop").hide();
                        $(".edit_view_all").show();

                        $("#edit_screen_layout option[value='banner']").hide();
                        $("#edit_screen_layout option[value='portrait']").hide();
                        $("#edit_screen_layout option[value='square']").hide();
                        $("#edit_screen_layout option[value='horizontal_view']").hide();
                        if (resp.data.content_type == 4) {
                            $("#edit_screen_layout option[value='category']").show();
                            $("#edit_screen_layout option[value='language']").hide();
                            $("#edit_screen_layout option[value='author']").hide();
                        } else if (resp.data.content_type == 5) {
                            $("#edit_screen_layout option[value='category']").hide();
                            $("#edit_screen_layout option[value='language']").show();
                            $("#edit_screen_layout option[value='author']").hide();
                        } else if (resp.data.content_type == 6) {
                            $("#edit_screen_layout option[value='category']").hide();
                            $("#edit_screen_layout option[value='language']").hide();
                            $("#edit_screen_layout option[value='author']").show();
                        }
                    } else {
                        $(".edit_author_drop").hide();
                        $(".edit_category_drop").hide();
                        $(".edit_language_drop").hide();
                        $(".edit_no_of_content").hide();
                        $(".edit_order_by_view").hide();
                        $(".edit_order_by_upload").hide();
                        $(".edit_access_type_drop").hide();
                        $(".edit_view_all").hide();
                    }

                    $("#edit_content_type").change(function() {

                        var content_type = $(this).children("option:selected").val();
                        if (content_type == 3) {

                            $(".edit_author_drop").show();
                            $(".edit_category_drop").show();
                            $(".edit_language_drop").show();
                            $(".edit_no_of_content").show();
                            $(".edit_order_by_view").show();
                            $(".edit_order_by_upload").show();
                            $(".edit_access_type_drop").show();
                            $("#edit_access_type").val('').trigger('change');
                            $(".edit_view_all").show();

                            $(".edit_screen_layout").show();
                            $("#edit_screen_layout").children().prop("selected", false);
                            $("#edit_screen_layout option[value='banner']").show();
                            $("#edit_screen_layout option[value='portrait']").show();
                            $("#edit_screen_layout option[value='square']").show();
                            $("#edit_screen_layout option[value='horizontal_view']").show();
                            $("#edit_screen_layout option[value='category']").hide();
                            $("#edit_screen_layout option[value='language']").hide();
                            $("#edit_screen_layout option[value='author']").hide();
                        } else if (content_type == 4 || content_type == 5 || content_type == 6) {

                            $(".edit_author_drop").hide();
                            $(".edit_category_drop").hide();
                            $(".edit_language_drop").hide();
                            $(".edit_no_of_content").show();
                            $(".edit_order_by_view").hide();
                            $(".edit_order_by_upload").show();
                            $(".edit_access_type_drop").hide();
                            $(".edit_view_all").show();

                            $(".edit_screen_layout").show();
                            $("#edit_screen_layout").children().prop("selected", false);
                            $("#edit_screen_layout option[value='banner']").hide();
                            $("#edit_screen_layout option[value='portrait']").hide();
                            $("#edit_screen_layout option[value='square']").hide();
                            $("#edit_screen_layout option[value='horizontal_view']").hide();
                            if (content_type == 4) {
                                $("#edit_screen_layout option[value='category']").show();
                                $("#edit_screen_layout option[value='language']").hide();
                                $("#edit_screen_layout option[value='author']").hide();
                            } else if (content_type == 5) {
                                $("#edit_screen_layout option[value='category']").hide();
                                $("#edit_screen_layout option[value='language']").show();
                                $("#edit_screen_layout option[value='author']").hide();
                            } else if (content_type == 6) {
                                $("#edit_screen_layout option[value='category']").hide();
                                $("#edit_screen_layout option[value='language']").hide();
                                $("#edit_screen_layout option[value='author']").show();
                            }
                        } else {

                            $(".edit_author_drop").hide();
                            $(".edit_category_drop").hide();
                            $(".edit_language_drop").hide();
                            $(".edit_no_of_content").hide();
                            $(".edit_order_by_view").hide();
                            $(".edit_order_by_upload").hide();
                            $(".edit_access_type_drop").hide();
                            $(".edit_view_all").hide();
                            $(".edit_screen_layout").hide();
                        }
                    });
                }
            },
            error: function(XMLHttpRequest, textStatus, errorThrown) {
                $("#dvloader").hide();
                toastr.error(errorThrown, textStatus);
            }
        });
    }

    function update_magazines_section() {

        var Demo_Mode = '<?php echo Demo_Mode(); ?>';
        if (Demo_Mode == 1) {

            $("#dvloader").show();
            var formData = new FormData($("#edit_magazines_section")[0]);

            var id = $('#edit_id').val();
            var url = "{{ route('admin.magazinessection.update', ':id') }}";
            url = url.replace(':id', id);

            $.ajax({
                headers: {
                    'X-CSRF-TOKEN': $('meta[name="csrf-token"]').attr('content')
                },
                enctype: 'multipart/form-data',
                type: 'POST',
                url: url,
                data: formData,
                cache: false,
                contentType: false,
                processData: false,
                success: function(resp) {

                    $("#dvloader").hide();
                    if (resp.status == 200) {
                        $('#editSectionModal').modal('toggle');
                    }
                    get_responce_message(resp, 'edit_magazines_section', "{{ route('admin.magazinessection.index') }}");
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

    // Sortable Section
    $("#contentListId").sortable({
        update: function(event, ui) {
            getIdsOfImages();
        }
    });

    function getIdsOfImages() {
        var values = [];
        $('.listitemClass').each(function(index) {
            values.push($(this).attr("id")
                .replace("imageNo", ""));
        });
        $('#outputvalues').val(values);
    }

    function save_magazines_section_sortorder() {

        var Demo_Mode = '<?php echo Demo_Mode(); ?>';
        if (Demo_Mode == 1) {

            $("#dvloader").show();
            var formData = new FormData($("#save_magazines_section_sortorder")[0]);
            $.ajax({
                type: 'POST',
                url: "{{ route('admin.magazinessection.sortable') }}",
                data: formData,
                cache: false,
                contentType: false,
                processData: false,
                success: function(resp) {
                    $("#dvloader").hide();
                    get_responce_message(resp, 'save_magazines_section_sortorder', "{{ route('admin.magazinessection.index') }}");
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