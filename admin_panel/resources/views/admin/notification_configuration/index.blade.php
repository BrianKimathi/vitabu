@extends('admin.layout.page-app')
@section('page_title', __('label.notification_configurations'))
@section('tab_title', __('label.notification_configurations'))

@section('content')
@include('admin.layout.sidebar')

<div class="right-content">
    @include('admin.layout.header')

    <div class="body-content">

        <!-- mobile title -->
        <h1 class="page-title-sm">{{__('label.notification_configurations')}}</h1>

        <div class="border-bottom row mb-3">
            <div class="col-sm-12">
                <ol class="breadcrumb">
                    <li class="breadcrumb-item"><a href="{{ route('admin.dashboard') }}">{{__('label.dashboard')}}</a></li>
                    <li class="breadcrumb-item active" aria-current="page">{{__('label.notification_configurations')}}</li>
                </ol>
            </div>
        </div>

        <div class="col-8 mb-2">
            <div class="custom-control custom-checkbox mr-sm-2">
                <input type="checkbox" class="custom-control-input" id="notificationToggle" {{ $main_status == 1 ? 'checked' : ''}} autofocus>
                <label class="custom-control-label h5 font-weight-bold" for="notificationToggle">{{__('label.do_you_want_to_disable_all_configurations')}}</label>
            </div>
        </div>

        <div class="table-responsive table" id="dataTable-container">
            <table class="table table-striped text-center table-bordered" id="datatable">
                <thead>
                    <tr class="table-bg">
                        <th>{{__('label.types')}}</th>
                        <th>{{__('label.mail')}}</th>
                        <th>{{__('label.notification')}}</th>
                    </tr>
                </thead>
                <tbody></tbody>
            </table>
        </div>
        @if($main_status == 1)
        <div>
            <button id="saveButton" class="btn btn-default mw-120">{{__('label.save')}}</button>
        </div>
        @endif
    </div>
</div>
@endsection

@section('pagescript')
<script>
    // Sidebar Scroll Down
    sidebar_down($(document).height());

    $(document).ready(function() {
        var table = $('#datatable').DataTable({
            ...dataTableDefaults,
            lengthMenu: [
                [50, 100, 500, -1],
                [50, 100, 500, "All"]
            ],
            ajax: {
                url: "{{ route('admin.notificationconfigurations.index') }}",
            },
            columns: [{
                    data: 'type',
                    name: 'type',
                    orderable: false,
                    searchable: false,
                    render: function(data, type, full, meta) {
                        return data ? '<div class="primary-color h5 text-left">' + data + '</div>' : "-";
                    }
                },
                {
                    data: 'send_mail',
                    render: function(data, type, row) {
                        var disabled = (row.type == 'upload-new-content' || row.type == 'add-withdrawal-request' || row.type == 'withdrawal-request-status-chagne' || row.type == 'plan-status-change') ? 'disabled' : '';
                        return `<input type="checkbox" name="email[]" class="email-checkbox custom-checkbox" data-id="${row.id}" ${data == 1 ? 'checked' : ''} ${disabled}>`;
                    },
                    orderable: false,
                    searchable: false,
                },
                {
                    data: 'send_notification',
                    render: function(data, type, row) {
                        var disabled = (row.type == 'register' || row.type == 'login' || row.type == 'buy-content' || row.type == 'buy-plan' | row.type == 'add-withdrawal-request' || row.type == 'withdrawal-request-status-chagne') ? 'disabled' : '';
                        return `<input type="checkbox" name="notification[]" class="notification-checkbox custom-checkbox" data-id="${row.id}" ${data == 1 ? 'checked' : ''} ${disabled}>`;
                    },
                    orderable: false,
                    searchable: false,
                },
            ],
        });
    });

    var mainstatus = "<?php echo $main_status; ?>";
    if (mainstatus == 1) {
        $('#dataTable-container').show();
    } else {
        $('#dataTable-container').hide();
    }

    function SaveNotification(type, status) {

        var Demo_Mode = '<?php echo Demo_Mode(); ?>';
        if (Demo_Mode == 1) {

            let entries = [];
            $('#datatable tbody tr').each(function() {
                let entryId = $(this).find('.notification-checkbox').data('id');
                let notification = $(this).find('.notification-checkbox').is(':checked') ? 1 : 0;
                let email = $(this).find('.email-checkbox').is(':checked') ? 1 : 0;

                entries.push({
                    id: entryId,
                    notification: notification,
                    email: email,
                });
            });

            $.ajax({
                url: "{{ route('admin.notificationconfigurations.store') }}",
                type: 'POST',
                data: {
                    entries: entries,
                    type: type,
                    status: status,
                    _token: '{{ csrf_token() }}'
                },
                beforeSend: function() {
                    $("#dvloader").show();
                },
                success: function(resp) {
                    $("#dvloader").hide();
                    get_responce_message(resp, '', '{{ route("admin.notificationconfigurations.index") }}');
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

    $('#saveButton').on('click', function() {
        SaveNotification("", 2); // Call the function when Save button is clicked
    });

    $('#notificationToggle').change(function() {

        var Demo_Mode = '<?php echo Demo_Mode(); ?>';
        if (Demo_Mode == 1) {

            if (this.checked) {
                $('#dataTable-container').show();
                SaveNotification("all", 1);
            } else {
                $('#dataTable-container').hide();
                SaveNotification("all", 0);
            }
        } else {
            showError();
        }
    });
</script>
@endsection