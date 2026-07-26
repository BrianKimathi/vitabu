@extends('admin.layout.page-app')
@section('page_title', __('label.reviews'))
@section('tab_title', __('label.reviews'))

@section('content')
@include('admin.layout.sidebar')

<div class="right-content">
    @include('admin.layout.header')

    <!-- Select2 -->
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/select2/4.0.13/css/select2.min.css" />

    <div class="body-content">
        <!-- mobile title -->
        <h1 class="page-title-sm">{{ __('label.reviews') }}</h1>

        <div class="border-bottom row mb-3">
            <div class="col-sm-12">
                <ol class="breadcrumb">
                    <li class="breadcrumb-item"><a href="{{ route('admin.dashboard') }}">{{ __('label.dashboard') }}</a></li>
                    <li class="breadcrumb-item active" aria-current="page">{{ __('label.reviews') }}</li>
                </ol>
            </div>
        </div>

        <div class="page-search">
            <div class="input-group">
                <div class="input-group-prepend">
                    <span class="input-group-text" id="basic-addon1">
                        <i class="fa-solid fa-magnifying-glass fa-xl light-gray"></i>
                    </span>
                </div>
                <input type="text" id="input_search" class="form-control" placeholder="{{ __('label.search') }}" aria-label="Search" aria-describedby="basic-addon1">
            </div>
            <div class="sorting mr-2 w-50">
                <label>{{ __('label.sort_by') }}</label>
                <select class="form-control" name="input_user" id="input_user">
                    <option value="0" selected>{{ __('label.all_user') }}</option>
                    @for ($i = 0; $i < count($user); $i++)
                        <option value="{{ $user[$i]['id'] }}">
                        {{ $user[$i]['first_name'] }} {{ $user[$i]['last_name'] }}
                        </option>
                        @endfor
                </select>
            </div>
        </div>
        <div class="page-search mb-3">
            <div class="sorting mr-2 w-50">
                <label>{{ __('label.sort_by') }}</label>
                <select class="form-control" name="input_audio_book" id="input_audio_book">
                    <option value="0" selected>{{ __('label.all_audio_books') }}</option>
                    @for ($i = 0; $i < count($audio_book); $i++)
                        <option value="{{ $audio_book[$i]['id'] }}">
                        {{ $audio_book[$i]['title'] }}
                        </option>
                        @endfor
                </select>
            </div>
            <div class="sorting mr-2 w-50">
                <select class="form-control" name="input_novel" id="input_novel">
                    <option value="0" selected>{{ __('label.all_novels') }}</option>
                    @for ($i = 0; $i < count($novel); $i++)
                        <option value="{{ $novel[$i]['id'] }}">
                        {{ $novel[$i]['title'] }}
                        </option>
                        @endfor
                </select>
            </div>
            <div class="sorting mr-2 w-50">
                <select class="form-control" name="input_magazine" id="input_magazine">
                    <option value="0" selected>{{ __('label.all_magazines') }}</option>
                    @for ($i = 0; $i < count($magazine); $i++)
                        <option value="{{ $magazine[$i]['id'] }}">
                        {{ $magazine[$i]['title'] }}
                        </option>
                        @endfor
                </select>
            </div>
        </div>

        <div class="table-responsive table">
            <table class="table table-striped text-center table-bordered" id="datatable">
                <thead>
                    <tr class="table-bg">
                        <th>{{__('label.#')}}</th>
                        <th>{{__('label.user')}}</th>
                        <th>{{__('label.content')}}</th>
                        <th>{{__('label.review')}}</th>
                        <th>{{__('label.rating')}}</th>
                        <th>{{__('label.date')}}</th>
                        <th>{{__('label.status')}}</th>
                        <th>{{__('label.action')}}</th>
                    </tr>
                </thead>
                <tbody></tbody>
            </table>
        </div>
    </div>
</div>
@endsection

@section('pagescript')
<!-- Select2 -->
<script src="https://cdnjs.cloudflare.com/ajax/libs/select2/4.0.13/js/select2.min.js"></script>

<script>
    // Sidebar Scroll Down
    sidebar_down('700');

    $("#input_user").select2();
    $("#input_audio_book").select2();
    $("#input_novel").select2();
    $("#input_magazine").select2();

    $(document).ready(function() {
        $(function() {
            var table = $('#datatable').DataTable({
                ...dataTableDefaults,
                ajax: {
                    url: "{{ route('admin.reviews.index') }}",
                    data: function(d) {
                        d.input_search = $('#input_search').val();
                        d.input_user = $('#input_user').val();
                        d.input_audio_book = $('#input_audio_book').val();
                        d.input_novel = $('#input_novel').val();
                        d.input_magazine = $('#input_magazine').val();
                    },
                },
                columns: [{
                        data: 'DT_RowIndex',
                        name: 'DT_RowIndex',
                        orderable: false,
                        searchable: false
                    },
                    {
                        data: 'user',
                        name: 'user',
                        render: function(data) {
                            if (data) {
                                return '<div class="text-left">' + data.first_name + ' ' + data.last_name + '<br><span class="f-14 font-weight-bold">' + data.user_name + '</span></div>';
                            } else {
                                return "-";
                            }
                        }
                    },
                    {
                        data: 'content',
                        name: 'content',
                        render: function(data, type, row) {
                            var content_type = "-";
                            var content = "-";
                            if (row.content_type == 1) {
                                content_type = "{{__('label.audiobooks')}}";
                                content = row.audio_book?.title ?? "-";
                            } else if (row.content_type == 2) {
                                content_type = "{{__('label.novels')}}";
                                content = row.novel?.title ?? "-";
                            } else if (row.content_type == 3) {
                                content_type = "{{__('label.magazines')}}";
                                content = row.magazine?.title ?? "-";
                            }


                            return `<div class="text-left"><span class="primary-color font-weight-bold">${content_type || ''}</span><br><span class="f-14 font-weight-bold">${content}</span>`;
                        }
                    },
                    {
                        data: 'review',
                        name: 'review',
                        render: function(data) {
                            return data ? '<div class="text-left f-14">' + data + '</div>' : "-";
                        }
                    },
                    {
                        data: 'rating',
                        name: 'rating',
                        render: function(data) {
                            return data ? '<b class="primary-color h5">' + data + '</b>' : "-";
                        }
                    },
                    {
                        data: 'date',
                        name: 'date'
                    },
                    {
                        data: 'status',
                        name: 'status',
                        orderable: false,
                        searchable: false
                    },
                    {
                        data: 'action',
                        name: 'action',
                        orderable: false,
                        searchable: false
                    },
                ],
            });

            $('#input_user, #input_audio_book, #input_novel, #input_magazine').change(function() {
                table.draw();
            });
            $('#input_search').keyup(function() {
                table.draw();
            });
        });
    });

    function change_status(id) {

        var Demo_Mode = '<?php echo Demo_Mode(); ?>';
        if (Demo_Mode == 1) {

            $("#dvloader").show();
            var url = `{{ route('admin.reviews.show', '') }}/${id}`;

            $.ajax({
                type: "GET",
                url: url,
                headers: {
                    'X-CSRF-TOKEN': $('meta[name="csrf-token"]').attr('content')
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
</script>
@endsection