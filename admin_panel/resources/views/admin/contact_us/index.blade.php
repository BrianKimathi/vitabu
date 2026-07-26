@extends('admin.layout.page-app')
@section('page_title', __('label.contact_us'))
@section('tab_title', __('label.contact_us'))

@section('content')
@include('admin.layout.sidebar')

<div class="right-content">
    @include('admin.layout.header')

    <div class="body-content">
        <!-- mobile title -->
        <h1 class="page-title-sm">{{__('label.contact_us')}}</h1>

        <div class="border-bottom row mb-3">
            <div class="col-sm-12">
                <ol class="breadcrumb">
                    <li class="breadcrumb-item"><a href="{{ route('admin.dashboard') }}">{{__('label.dashboard')}}</a></li>
                    <li class="breadcrumb-item active" aria-current="page">{{__('label.contact_us')}}</li>
                </ol>
            </div>
        </div>

        <!-- Search -->
        <div class="page-search mb-3">
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
                        <th> {{__('label.#')}} </th>
                        <th> {{__('label.user_name')}} </th>
                        <th> {{__('label.name')}} </th>
                        <th> {{__('label.email')}} </th>
                        <th> {{__('label.subject')}} </th>
                        <th> {{__('label.details')}} </th>
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
<script>
      // Sidebar Scroll Down
        sidebar_down('700');

    $(document).ready(function() {
        var table = $('#datatable').DataTable({
            ...dataTableDefaults,
            ajax: {
                url: "{{ route('admin.contact_us.index') }}",
                data: function(d) {
                    d.input_search = $('#input_search').val();
                },
            },
            columns: [{
                    data: 'DT_RowIndex',
                    name: 'DT_RowIndex',
                    orderable: false,
                    searchable: false,
                },
                {
                    data: 'user_name',
                    name: 'user_name',
                },
                {
                    data: 'name',
                    name: 'name',
                    render: function(data) {
                        return data ? data : "-";
                    }
                },

                {
                    data: 'email',
                    name: 'email',
                    render: function(data) {
                        return data ? data : "-";
                    }
                },

                {
                    data: 'subject',
                    name: 'subject',
                    render: function(data) {
                        return data ? data : "-";
                    }
                },

                {
                    data: 'details',
                    name: 'details',
                    render: function(data) {
                        return data ? data : "-";
                    }
                },


                {
                    data: 'action',
                    name: 'action',
                    orderable: false,
                    searchable: false
                }
            ],
        });
        $('#input_search').keyup(function() {
            table.draw();
        });
    });
</script>
@endsection