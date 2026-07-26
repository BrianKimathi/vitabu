@extends('admin.layout.page-app')
@section('page_title', __('label.audiobooks'))
@section('tab_title', __('label.audiobooks'))

@section('content')
@include('admin.layout.sidebar')

<div class="right-content">
    @include('admin.layout.header')

    <!-- Select2 -->
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/select2/4.0.13/css/select2.min.css" />

    <div class="body-content">
        <!-- mobile title -->
        <h1 class="page-title-sm">{{__('label.audiobooks')}}</h1>

        <div class="border-bottom row mb-3">
            <div class="col-sm-10">
                <ol class="breadcrumb">
                    <li class="breadcrumb-item"><a href="{{ route('admin.dashboard') }}">{{__('label.dashboard')}}</a></li>
                    <li class="breadcrumb-item active" aria-current="page">{{__('label.audiobooks')}}</li>
                </ol>
            </div>
            <div class="col-sm-2 d-flex align-items-center justify-content-end">
                <a href="{{ route('admin.audiobooks.create') }}" class="btn btn-default mw-120 mb-3">{{__('label.add_audiobook')}}</a>
            </div>
        </div>

        <!-- Search -->
        <div class="page-search">
            <div class="input-group">
                <div class="input-group-prepend">
                    <span class="input-group-text" id="basic-addon1"><i class="fa-solid fa-magnifying-glass fa-xl light-gray"></i></span>
                </div>
                <input type="text" id="input_search" class="form-control" placeholder="{{__('label.search')}}" aria-label="Search" aria-describedby="basic-addon1">
            </div>
        </div>
        <div class="page-search mb-3">
            <div class="sorting mr-2 w-50">
                <label>{{__('label.sort_by')}}</label>
                <select class="form-control" name="input_author" id="input_author">
                    <option value="0">{{__('label.all_authors')}}</option>
                    @for ($i = 0; $i < count($author); $i++)
                        <option value="{{ $author[$i]['id'] }}">
                        {{ $author[$i]['first_name'] }} {{ $author[$i]['last_name'] }}
                        </option>
                        @endfor
                </select>
            </div>
            <div class="sorting mr-2 w-50">
                <select class="form-control" name="input_category" id="input_category">
                    <option value="0">{{__('label.all_category')}}</option>
                    @for ($i = 0; $i < count($category); $i++)
                        <option value="{{ $category[$i]['id'] }}">
                        {{ $category[$i]['name'] }}
                        </option>
                        @endfor
                </select>
            </div>
            <div class="sorting mr-2 w-50">
                <select class="form-control" name="input_language" id="input_language">
                    <option value="0">{{__('label.all_language')}}</option>
                    @for ($i = 0; $i < count($language); $i++)
                        <option value="{{ $language[$i]['id'] }}">
                        {{ $language[$i]['name'] }}
                        </option>
                        @endfor
                </select>
            </div>
            <div class="sorting mr-2 w-50">
                <select class="form-control" name="input_status" id="input_status">
                    <option value="0" selected>{{__('label.all_status')}}</option>
                    <option value="1">
                        {{ __('label.show') }}
                    </option>
                    <option value="2">
                        {{ __('label.hide') }}
                    </option>

                </select>
            </div>
            <div class="sorting w-50">
                <select class="form-control" name="input_access_type" id="input_access_type">
                    <option value="all" selected>{{__('label.all_access_types')}}</option>
                    <option value="0">
                        {{ __('label.free') }}
                    </option>
                    <option value="1">
                        {{ __('label.paid') }}
                    </option>
                    <option value="2">
                        {{ __('label.subscription_included') }}
                    </option>
                </select>
            </div>
        </div>

        <div class="table-responsive table">
            <table class="table table-striped text-center table-bordered" id="datatable">
                <thead>
                    <tr class="table-bg">
                        <th>{{__('label.#')}}</th>
                        <th>{{__('label.image')}}</th>
                        <th>{{__('label.title')}}</th>
                        <th>{{__('label.author')}}</th>
                        <th>{{__('label.info')}}</th>
                        <th>{{__('label.access_type')}}</th>
                        <th>{{__('label.episodes')}}</th>
                        <th>{{__('label.status')}}</th>
                        <th> {{__('label.action')}} </th>
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
    sidebar_down(350);

    $(document).ready(function() {
        $("#input_author").select2();
        $("#input_category").select2();
        $("#input_language").select2();
        $('#input_status').select2();
        $('#input_access_type').select2();

        $(function() {
            var table = $('#datatable').DataTable({
                ...dataTableDefaults,
                ajax: {
                    url: "{{ route('admin.audiobooks.index') }}",
                    data: function(d) {
                        d.input_search = $('#input_search').val();
                        d.input_author = $('#input_author').val();
                        d.input_category = $('#input_category').val();
                        d.input_language = $('#input_language').val();
                        d.input_status = $('#input_status').val();
                        d.input_access_type = $('#input_access_type').val();
                    },
                },
                columns: [{
                        data: 'DT_RowIndex',
                        name: 'DT_RowIndex',
                        orderable: false,
                        searchable: false
                    },
                    {
                        data: 'portrait_img',
                        name: 'portrait_img',
                        orderable: false,
                        searchable: false,
                        render: function(data, type, full, meta) {
                            return `<a href='${data}' target='_blank'>
                                            <img src='${data}' class='img-thumbnail size-55' >
                                        </a>`;
                        },
                    },
                    {
                        data: 'title',
                        name: 'title',
                        render: function(data) {
                            return data ? '<div class="text-left f-14">' + data + '</div>' : "-";
                        }
                    },
                    {
                        data: 'author',
                        name: 'author',
                        render: function(data) {
                            if (data) {
                                return '<div class="text-left">' + data.first_name + ' ' + data.last_name + '<br><span class="f-14 font-weight-bold">' + data.user_name + '</span></div>';
                            } else {
                                return "-";
                            }
                        }
                    },
                    {
                        data: 'info',
                        name: 'info',
                        render: function(data, type, row) {
                            return `<div class="text-left">${row.category?.name || ''}<br><span class="f-14 font-weight-bold">${row.language?.name || ''}</span>`;
                        }
                    },
                    {
                        data: 'access_type',
                        name: 'access_type',
                        render: function(data, type, row) {
                            if (data == 0) {
                                access_type = "{{ __('label.free') }}"
                            } else if (data == 1) {
                                access_type = "{{ __('label.paid') }}"
                            } else if (data == 2) {
                                access_type = "{{ __('label.subscription_included') }}"
                            } else {
                                access_type = "-";
                            }
                            const price = row.price ? `{{ Currency_Code() }} ${row.price}` : "0";
                            const btnClass = data === 1 ? "mb-1 px-3 hide-btn" : "show-btn";

                            return `
                                    <div class="text-center" >
                                        <button type='button' class='${btnClass}'>${access_type}</button>
                                        ${data === 1 ? `<br><span  class="primary-color f-14 font-weight-bold">${price}</span>` : ""}
                                    </div>
                                `;
                        }
                    },
                    {
                        data: 'episode',
                        name: 'episode',
                        orderable: false,
                        searchable: false
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

            $('#input_author, #input_category, #input_language,#input_status,#input_access_type').change(function() {
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
            var url = `{{ route('admin.audiobooks.show', '') }}/${id}`;

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