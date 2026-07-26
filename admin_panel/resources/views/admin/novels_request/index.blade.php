@extends('admin.layout.page-app')
@section('page_title', __('label.novels_request'))
@section('tab_title', __('label.novels_request'))

@section('content')
@include('admin.layout.sidebar')

<div class="right-content">
    @include('admin.layout.header')

    <!-- Select2 -->
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/select2/4.0.13/css/select2.min.css" />

    <div class="body-content">
        <!-- mobile title -->
        <h1 class="page-title-sm">{{__('label.novels_request')}}</h1>

        <div class="border-bottom row mb-3">
            <div class="col-sm-12">
                <ol class="breadcrumb">
                    <li class="breadcrumb-item"><a href="{{ route('admin.dashboard') }}">{{__('label.dashboard')}}</a></li>
                    <li class="breadcrumb-item active" aria-current="page">{{__('label.novels_request')}}</li>
                </ol>
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

        $(function() {
            var table = $('#datatable').DataTable({
                ...dataTableDefaults,
                ajax: {
                    url: "{{ route('admin.novels_request.index') }}",
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
                        data: 'action',
                        name: 'action',
                        orderable: false,
                        searchable: false
                    },
                ],
            });
        });
    });

    function change_status(id, status) {

        var Demo_Mode = '<?php echo Demo_Mode(); ?>';
        if (Demo_Mode == 1) {

            $("#dvloader").show();
            var url = "{{route('admin.novels_request.show', '')}}" + "/" + id;

            $.ajax({
                type: "GET",
                url: url,
                headers: {
                    'X-CSRF-TOKEN': $('meta[name="csrf-token"]').attr('content')
                },
                data: {
                    id: id,
                    status: status
                },
                success: function(resp) {
                    $("#dvloader").hide();
                    get_responce_message(resp, '', '{{route("admin.novels_request.index")}}');
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
</script>
@endsection