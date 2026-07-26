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
    <input type="hidden" value="{{URL('')}}" id="base_url">

    <!-- Custom CSS -->
    <style>
        /* Loader */
        #dvloader {
            width: 100%;
            height: 100%;
            top: 0;
            left: 0;
            position: fixed;
            display: block;
            opacity: 0.7;
            background-color: #fff;
            z-index: 9999;
            text-align: center;
        }

        #dvloader image {
            position: absolute;
            top: 100px;
            left: 240px;
            z-index: 100;
        }

        /* btn Cancel */
        .btn-cancel {
            background: #000;
            border-radius: 50px;
            font-size: 16px;
            font-weight: 600;
            color: #fff;
            border: 1px solid transparent;
            -webkit-transition: all 0.3s;
            transition: all 0.3s;
            padding: 8px 20px;
        }

        .btn-cancel:hover {
            color: #000;
            background: transparent;
            border-color: #000;
        }

        /* btn sortorder */
        .btn-sortorder {
            background: var(--primary-color);
            border-radius: 10px;
            font-size: 16px;
            font-weight: 600;
            color: var(--white-color);
            border: 1px solid transparent;
            -webkit-transition: all 0.3s;
            transition: all 0.3s;
            padding: 5px 20px;
        }

        .btn-sortorder:hover {
            color: var(--primary-color);
            background: transparent;
            border-color: var(--primary-color);
        }

        /* Edit-Delete btn */
        .edit-delete-btn {
            border: none;
            cursor: pointer;
            outline: none;
            background-color: #e50914;
            color: #fff !important;
            padding: 5px;
        }

        .light-gray {
            color: #818181;
        }

        /* Import File */
        .import-file {
            background-color: #f5f6f7;
            color: #000;
        }

        .import-file::file-selector-button {
            border-radius: 4px;
            background-color: #969a9e;
            border: 1px solid #969a9e;
            height: 30px;
            cursor: pointer;
        }

        /* Select 2 DropDown */
        .select2-container .select2-selection--single {
            border: 1px solid #f5f5f5;
            background: #fdfdfd;
            border-radius: 8px;
            padding: 8px;
            font-size: 14px;
            height: auto !important;
        }

        .select2-container .select2-selection--multiple {
            border: 1px solid #f5f5f5;
            background: #fdfdfd;
            border-radius: 8px;
            padding: 8px;
            font-size: 14px;
            height: auto !important;
        }

        .select2-container--default.select2-container--focus .select2-selection--multiple {
            border: 1px solid #e50914 !important;
        }
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
        $('#imageUpload2').change(function() {
            if (this.files && this.files[0]) {
                var reader = new FileReader();
                reader.onload = function(e) {
                    $('#imagePreview2').attr("src", e.target.result);
                    $('#imagePreview2').hide();
                    $('#imagePreview2').fadeIn(650);
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