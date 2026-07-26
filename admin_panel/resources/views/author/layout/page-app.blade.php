<!DOCTYPE html>
<html>

<head>
    <!-- Meta Tag -->
    <meta charset="utf-8">
    <meta name="csrf-token" content="{{ csrf_token() }}">

    <!-- Tab Icon -->
    <link rel="shortcut icon" type="image/jpeg" href="{{ asset('assets/imgs/favicon.jpg') }}">

    <!-- Title Tag  -->
    <title>@yield('tab_title') | {{ App_Name() }}</title>

    <link href="{{asset('assets/bootstrap/css/bootstrap.min.css') }}" rel="stylesheet">
    <link href="{{asset('assets/css/dataTables.bootstrap4.min.css') }}" rel="stylesheet">
    <link href="{{asset('assets/css/toastr.min.css')}}" rel="stylesheet" type="text/css">
    <link href="{{asset('assets/css/style.css') }}" rel="stylesheet">
    <!-- Font Awesome -->
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.6.0/css/all.min.css" />

    <!-- base_url -->
    <input type="hidden" value="{{ URL('') }}" id="base_url">

    <!-- Custom CSS -->
    <style>
        /* ================================================================
           MODERN INDIGO THEME — Global Overrides for Author Panel
           ================================================================ */

        /* Cards */
        .custom-border-card {
            border: none !important;
            border-radius: 12px !important;
            box-shadow: 0 1px 3px rgba(0,0,0,0.08) !important;
            margin-bottom: 20px;
        }
        .custom-border-card .card-header {
            background: transparent !important;
            border-bottom: 1px solid #F3F4F6 !important;
            font-size: 15px !important;
            font-weight: 700 !important;
            color: #1F2937 !important;
            padding: 16px 20px !important;
        }
        .custom-border-card .card-header i { color: #4E45B8; margin-right: 6px; }
        .custom-border-card .card-body { padding: 16px 20px !important; }

        /* Buttons */
        .btn-default {
            background: #4E45B8 !important;
            border-radius: 8px !important;
            font-size: 13px !important;
            font-weight: 600 !important;
            color: #fff !important;
            border: none !important;
            padding: 7px 20px !important;
            transition: all 0.2s;
        }
        .btn-default:hover { background: #3D35A0 !important; color: #fff !important; }

        .btn { font-size: 13px; border-radius: 8px; }

        /* Breadcrumb */
        .breadcrumb { background: transparent; padding: 0; }
        .breadcrumb a { color: #4E45B8 !important; font-weight: 500; }
        .breadcrumb-item.active { color: #6B7280; }

        /* Tables */
        .table { color: #374151; min-width: 650px; }
        .table thead th {
            font-size: 12px; font-weight: 600; color: #6B7280;
            border-top: none; border-bottom: 1px solid #F3F4F6;
            text-transform: uppercase; letter-spacing: 0.3px; padding: 10px 12px;
        }
        .table td {
            font-size: 13px; padding: 10px 12px;
            border-bottom: 1px solid #F3F4F6; vertical-align: middle;
        }
        .table-striped tbody tr:nth-of-type(even) { background: #F9FAFB; }

        /* Form Controls */
        .form-control {
            border: 1px solid #E5E7EB; background: #F9FAFB;
            border-radius: 8px; padding: 10px 14px;
            font-size: 13px; height: auto !important;
        }
        .form-control:focus {
            border-color: #4E45B8; box-shadow: 0 0 0 2px rgba(78,69,184,0.1); background: #fff;
        }
        .form-group label { font-size: 13px; font-weight: 600; color: #374151; margin-bottom: 6px; }

        /* Select2 */
        .select2-container .select2-selection--single {
            border: 1px solid #E5E7EB !important; background: #F9FAFB !important;
            border-radius: 8px !important; padding: 6px 12px !important; height: auto !important;
        }

        /* Page title */
        .page-title-sm { font-size: 20px; font-weight: 700; color: #1F2937; margin-bottom: 16px; }

        /* Pills */
        .nav-pills .nav-link.active { background: #EEF0FF !important; color: #4E45B8 !important; }
        .nav-pills .nav-link:not(.active) { background: #F3F4F6 !important; color: #6B7280 !important; }

        /* Approve/Reject buttons */
        .show-btn, .hide-btn {
            font-weight: 600 !important; border: none !important; color: #fff !important;
            padding: 4px 14px !important; border-radius: 6px !important; font-size: 12px !important;
        }
        .show-btn { background: #059669 !important; }
        .hide-btn { background: #DC2626 !important; }

        /* Tabs */
        .custom-tabs { margin: 12px 0; border-radius: 8px; }
        .custom-tabs .nav-link { border-radius: 8px; font-size: 13px; font-weight: 500; padding: 6px 18px; }
        .custom-tabs .nav-link.active { background: #4E45B8; }

        /* Radio groups */
        .radio-group .custom-control-input:checked ~ .custom-control-label { background: #4E45B8 !important; color: #fff !important; }
        .radio-group .custom-control-label::before { border-color: #4E45B8 !important; }

        /* Color overrides */
        .primary-color { color: #4E45B8 !important; }
        .bg-primary-color { background: #4E45B8 !important; }
        .primary-bg { background: #4E45B8 !important; }
        .edit-delete-btn { background-color: #4E45B8 !important; border: none !important; border-radius: 6px !important; }
        .earning-amount { color: #4E45B8; }

        /* DataTable */
        div.dataTables_wrapper div.dataTables_length label,
        div.dataTables_wrapper div.dataTables_filter label {
            background: #F9FAFB; border-radius: 8px; padding: 6px 16px; font-weight: 500; font-size: 13px;
        }

        #dvloader { width: 100%; height: 100%; top: 0; left: 0; position: fixed; display: block; opacity: 0.7; background-color: #fff; z-index: 9999; text-align: center; }
        #dvloader image { position: absolute; top: 100px; left: 240px; z-index: 100; }

        .dot { background: #DC2626; }

        /* Ribbon override — was using red from --primary-color */
        .ribbon span { background: #4E45B8 !important; }
        .video-card .card-body .dropdown .head-btn { color: #4E45B8; }
        .video-card .overlap-control .btn { background: rgba(255,255,255,0.9) !important; }
        .video-card .overlap-control .btn i { color: #4E45B8 !important; }
    </style>

    <!--Custom Script-->
    <script>
        var globalSiteUrl = '<?php echo $path = url('/'); ?>'
        var serverEnvironment = '<?php echo env('APP_ENV'); ?>'
        var currentRouteName = '<?php echo request()->route()->getName(); ?>'
    </script>
</head>

<body>

    @yield('content')

    <div style="display:none" id="dvloader"><img src="{{ asset('assets/imgs/loading.gif')}}" /></div>

    <!-- Jquery -->
    <script src="{{ asset('assets/js/jquery.min.js') }}"></script>
    <script src="{{ asset('assets/js/popper.min.js') }}"></script>
    <script src="{{ asset('assets/bootstrap/js/bootstrap.min.js') }}"></script>
    <script src="https://ajax.googleapis.com/ajax/libs/jquery/2.1.1/jquery.min.js"></script>
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
    <!-- Datatable -->
    <script src="{{ asset('assets/js/jquery.dataTables.min.js') }}"></script>
    <script src="{{ asset('assets/js/dataTables.bootstrap4.min.js') }}"></script>
    <script src="{{ asset('assets/js/js.js')}}"></script>
    <!-- pdfmake -->
    <script src="https://cdnjs.cloudflare.com/ajax/libs/pdfmake/0.1.70/pdfmake.min.js"></script>
    <script src="https://cdnjs.cloudflare.com/ajax/libs/pdfmake/0.1.70/vfs_fonts.js"></script>

    <!-- Toastr -->
    <script src="{{ asset('assets/js/toastr.min.js')}}"></script>

    <script>
        // Counter
        $('.counting').each(function() {
            var $this = $(this),
                countTo = $this.attr('data-count');

            countTo = getVal(countTo);

            $(this).prop('Counter', 0).animate({
                countNum: countTo
            }, {
                duration: 2000,
                easing: 'swing',
                step: function(now) {
                    $(this).text(Math.ceil(now));
                },
                complete: function() {
                    $this.text($this.attr('data-count'));
                }
            });
        });

        function getVal(val) {

            multiplier = val.substr(-1).toLowerCase();

            if (multiplier == "k")
                return parseFloat(val) * 1000;
            else if (multiplier == "m")
                return parseFloat(val) * 1000000;
            else if (multiplier == "b")
                return parseFloat(val) * 1000000000;
            else if (multiplier == "t")
                return parseFloat(val) * 1000000000000;
            else
                return val;
        }

        function get_responce_message(resp, form_name = "", url = "") {
            if (resp.status == '200') {
                toastr.success(resp.success);
                if (form_name != "") {
                    document.getElementById(form_name).reset();
                }
                if (url != "") {
                    setTimeout(function() {
                        window.location.replace(url);
                    }, 500);
                }
            } else {
                var obj = resp.errors;
                if (typeof obj === 'string') {
                    toastr.error(obj);
                } else {
                    $.each(obj, function(i, e) {
                        toastr.error(e);
                    });
                }
            }
        }

        // Toastr MSG Show
        @if(Session::has('error'))
        toastr.error('{{ Session::get("error") }}');
        @elseif(Session::has('success'))
        toastr.success('{{ Session::get("success") }}');
        @endif

        // Image Upload Preview
        $('#imageUpload').change(function() {
            if (this.files && this.files[0]) {
                var reader = new FileReader();
                reader.onload = function(e) {
                    $('#imagePreview').attr("src", e.target.result);
                    $('#imagePreview').hide();
                    $('#imagePreview').fadeIn(650);
                }
                reader.readAsDataURL(this.files[0]);
            }
        });
        $('#imageUploadModel').change(function() {
            if (this.files && this.files[0]) {
                var reader = new FileReader();
                reader.onload = function(e) {
                    $('#imagePreviewModel').attr("src", e.target.result);
                    $('#imagePreviewModel').hide();
                    $('#imagePreviewModel').fadeIn(650);
                }
                reader.readAsDataURL(this.files[0]);
            }
        });
        $('#imageUploadLandscape').change(function() {
            if (this.files && this.files[0]) {
                var reader = new FileReader();
                reader.onload = function(e) {
                    $('#imagePreviewLandscape').attr("src", e.target.result);
                    $('#imagePreviewLandscape').hide();
                    $('#imagePreviewLandscape').fadeIn(650);
                }
                reader.readAsDataURL(this.files[0]);
            }
        });
        $('#imageUploadLandscapeModel').change(function() {
            if (this.files && this.files[0]) {
                var reader = new FileReader();
                reader.onload = function(e) {
                    $('#imagePreviewLandscapeModel').attr("src", e.target.result);
                    $('#imagePreviewLandscapeModel').hide();
                    $('#imagePreviewLandscapeModel').fadeIn(650);
                }
                reader.readAsDataURL(this.files[0]);
            }
        });

        // Sidebar Scroll Down
        function sidebar_down(height) {
            $(".sidebar").animate({
                scrollTop: height
            });
        }

        // DataTable Defaults
        var dataTableDefaults = {
            dom: "<'top'f>rt<'row'<'col-2'i><'col-1'l><'col-9'p>>",
            searching: false,
            responsive: true,
            autoWidth: false,
            processing: true,
            serverSide: true,
            lengthMenu: [
                [10, 50, 100, 500, -1],
                [10, 50, 100, 500, "All"]
            ],
            language: {
                paginate: {
                    previous: "<i class='fa-solid fa-chevron-left'></i>",
                    next: "<i class='fa-solid fa-chevron-right'></i>"
                }
            }
        };

        // Demo Mode Ajex Error
        function showError() {
            toastr.error("{{ __('label.you_have_no_right_to_add_edit_and_delete') }}");
        }
    </script>

    @yield('pagescript')
</body>

</html>