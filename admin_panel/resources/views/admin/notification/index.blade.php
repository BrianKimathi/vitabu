@extends('admin.layout.page-app')
@section('page_title', __('label.notification'))
@section('tab_title', __('label.notification'))

@section('content')
    @include('admin.layout.sidebar')

    <div class="right-content">
        @include('admin.layout.header')

        <div class="body-content">
            <!-- mobile title -->
            <h1 class="page-title-sm">{{__('label.notification')}}</h1>

            <div class="border-bottom row mb-3">
                <div class="col-sm-9">
                    <ol class="breadcrumb">
                        <li class="breadcrumb-item"><a href="{{ route('admin.dashboard') }}">{{__('label.dashboard')}}</a></li>
                        <li class="breadcrumb-item active" aria-current="page">{{__('label.notification')}}</li>
                    </ol>
                </div>
                <div class="col-sm-3">
                    <div class="d-flex justify-content-between">
                        <a href="{{ route('admin.notification.create') }}" class="btn btn-default mw-120">{{__('label.add')}}</a>
                        <a href="{{ route('admin.notification.setting') }}" class="btn btn-default mw-120">{{__('label.notification_setting')}}</a>
                    </div>
                </div>
            </div>

            <!-- Search -->
            <div class="page-search mb-3 mt-3">
                <div class="input-group">
                    <div class="input-group-prepend">
                        <span class="input-group-text" id="basic-addon1"><i class="fa-solid fa-magnifying-glass fa-xl light-gray"></i></span>
                    </div>
                    <input type="text" id="input_search" class="form-control" placeholder="{{__('label.search')}}" aria-label="Search" aria-describedby="basic-addon1">
                </div>
            </div>

            <div class="table-responsive table">
                <table class="table table-striped text-center table-bordered" id="datatable">
                    <thead>
                        <tr class="table-bg">
                            <th>{{__('label.#')}}</th>
                            <th>{{__('label.image')}}</th>
                            <th>{{__('label.title')}}</th>
                            <th>{{__('label.message')}}</th>
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
    <script>
        // Sidebar Scroll Down
        sidebar_down('700');

        $(document).ready(function() {
            var table = $('#datatable').DataTable({
                ...dataTableDefaults,
                ajax: {
                    url: "{{ route('admin.notification.index') }}",
                    data: function(d) {
                        d.input_search = $('#input_search').val();
                    },
                },
                columns: [
                    { data: 'DT_RowIndex', name: 'DT_RowIndex', orderable: false, searchable: false},
                    {
						data: 'image',
						name: 'image',
						orderable: false,
						searchable: false,
						render: function(data, type, full, meta) {
                            return `<a href='${data}' target='_blank'>
                                        <img src='${data}' class='img-thumbnail size-55'>
                                    </a>`;
						},
					},
                    {
                        data: 'title',
                        name: 'title',
                        render: function(data) {
                            return data ? data : "-";
                        }
                    },
                    {
                        data: 'message',
                        name: 'message',
                        render: function(data) {
                            return data ? '<div class="text-left f-14">' + data + '</div>' : "-";
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

            $('#input_search').keyup(function() {
                table.draw();
            });
        });
    </script>
@endsection
