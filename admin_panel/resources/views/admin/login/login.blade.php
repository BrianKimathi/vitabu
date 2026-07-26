@extends('admin.layout.page-app')
@section('tab_title', __('label.login'))

@section('content')
<style>
    .login-container-bg {
        background-color: #F8FAFC;
        min-height: 100vh;
    }
    .login-card-modern {
        background: #ffffff;
        border-radius: 24px;
        box-shadow: 0 20px 40px -15px rgba(15, 23, 42, 0.08);
        border: 1px solid #E2E8F0;
        padding: 40px;
    }
    .role-switcher-container {
        background: #F1F5F9;
        padding: 5px;
        border-radius: 16px;
        display: flex;
        gap: 6px;
        margin-bottom: 28px;
    }
    .role-tab-btn {
        flex: 1;
        text-align: center;
        padding: 10px 16px;
        border-radius: 12px;
        font-weight: 600;
        font-size: 0.9rem;
        transition: all 0.2s ease;
        text-decoration: none !important;
        display: inline-flex;
        align-items: center;
        justify-content: center;
        gap: 8px;
    }
    .role-tab-btn.active {
        background: linear-gradient(135deg, #4E45B8 0%, #3B3398 100%);
        color: #ffffff !important;
        box-shadow: 0 4px 12px rgba(78, 69, 184, 0.3);
    }
    .role-tab-btn.inactive {
        background: transparent;
        color: #64748B !important;
    }
    .role-tab-btn.inactive:hover {
        background: rgba(255, 255, 255, 0.6);
        color: #0F172A !important;
    }
    .form-control-login {
        border-radius: 12px;
        border: 1px solid #CBD5E1;
        padding: 12px 16px 12px 42px;
        font-size: 0.95rem;
        transition: all 0.2s ease;
        height: auto;
    }
    .form-control-login:focus {
        border-color: #4E45B8;
        box-shadow: 0 0 0 4px rgba(78, 69, 184, 0.15);
    }
    .input-icon-wrapper {
        position: relative;
    }
    .input-icon-wrapper i {
        position: absolute;
        left: 15px;
        top: 50%;
        transform: translateY(-50%);
        color: #94A3B8;
        font-size: 1.1rem;
        z-index: 5;
    }
    .btn-login-submit {
        background: linear-gradient(135deg, #4E45B8 0%, #312E81 100%);
        color: #ffffff !important;
        border: none;
        border-radius: 12px;
        padding: 14px;
        font-weight: 700;
        font-size: 1rem;
        width: 100%;
        transition: all 0.2s ease;
        box-shadow: 0 6px 18px rgba(78, 69, 184, 0.3);
    }
    .btn-login-submit:hover {
        transform: translateY(-1px);
        box-shadow: 0 8px 22px rgba(78, 69, 184, 0.4);
    }
</style>

<div class="h-100 login-container-bg">
    <div class="h-100 no-gutters row align-items-center">
        <div class="d-none d-lg-block h-100 col-lg-7 col-xl-7">
            <div class="left-caption h-100">
                <img src="{{ Login_Image() }}" class="bg-img" style="object-fit: cover; width: 100%; height: 100%;" />
                <div class="caption">
                    <div>
                        <h1 style="font-size: 52px; font-weight: 800; letter-spacing: -1px; text-shadow: 0 4px 12px rgba(0,0,0,0.3);">{{ App_Name() }}</h1>
                        <?php $setting = Setting_Data(); ?>
                        <p class="text" style="font-size: 1.1rem; opacity: 0.9;">
                            {{$setting['app_description']}}
                        </p>
                    </div>
                </div>
            </div>
        </div>
        <div class="h-100 d-flex justify-content-center align-items-center col-md-12 col-lg-5 col-xl-5">
            <div class="mx-auto col-sm-11 col-md-9 col-xl-8 py-5">
                <div class="login-card-modern">
                    <div class="text-center mb-4">
                        <h2 class="font-weight-bold text-dark mb-1" style="font-size: 1.75rem;">Welcome Back</h2>
                        <p class="text-muted" style="font-size: 0.9rem;">Sign in to your administration dashboard</p>
                    </div>

                    <!-- Role Switcher Tabs (Admin vs Author) -->
                    <div class="role-switcher-container">
                        <a href="{{ route('admin.login') }}" class="role-tab-btn active">
                            <i class="fa-solid fa-user-gear"></i> Admin Login
                        </a>
                        <a href="{{ route('author.login') }}" class="role-tab-btn inactive">
                            <i class="fa-solid fa-pen-nib"></i> Author Login
                        </a>
                    </div>

                    @php
                    $emailValue = env('DEMO_MODE') == 'ON' ? 'admin@admin.com' : '';
                    $passwordValue = env('DEMO_MODE') == 'ON' ? 'admin' : '';
                    @endphp

                    <form id="login_form">
                        <div class="form-group mb-3">
                            <label class="font-weight-600 text-dark mb-2" style="font-size: 0.9rem;">{{__('label.email')}}</label>
                            <div class="input-icon-wrapper">
                                <i class="fa-regular fa-envelope"></i>
                                <input name="email" type="email" value="{{ $emailValue }}" placeholder="{{__('label.email_here')}}" class="form-control form-control-login" autofocus>
                            </div>
                        </div>

                        <div class="form-group mb-4">
                            <label class="font-weight-600 text-dark mb-2" style="font-size: 0.9rem;">{{__('label.password')}}</label>
                            <div class="input-icon-wrapper">
                                <i class="fa-solid fa-lock"></i>
                                <input name="password" type="password" value="{{ $passwordValue }}" placeholder="{{__('label.password_here')}}" class="form-control form-control-login">
                            </div>
                        </div>

                        <button class="btn btn-login-submit" onclick="save_login()" type="button">
                            {{__('label.login')}} <i class="fa-solid fa-arrow-right-to-bracket ml-2"></i>
                        </button>
                    </form>

                    @if( env('DEMO_MODE') == 'ON')
                    <hr class="my-4">
                    <p class="text-center text-muted mb-0" style="font-size: 0.85rem;">
                        {{__('label.if_you_cannot_login_then')}} <a href="{{ env('APP_URL'). '/public/admin/login' }}" target="_blank" class="font-weight-bold text-primary">{{__('label.click_here')}}</a>
                    </p>
                    @endif
                </div>
            </div>
        </div>
    </div>
</div>
@endsection

@section('pagescript')
<script>
    function save_login() {
        $("#dvloader").show();
        var formData = new FormData($("#login_form")[0]);
        $.ajax({
            headers: {
                'X-CSRF-TOKEN': $('meta[name="csrf-token"]').attr('content')
            },
            type: 'POST',
            url: '{{ route("admin.save.login") }}',
            data: formData,
            cache: false,
            contentType: false,
            processData: false,
            success: function(resp) {
                $("#dvloader").hide();
                get_responce_message(resp, 'login_form', '{{ route("admin.dashboard") }}');
            },
            error: function(XMLHttpRequest, textStatus, errorThrown) {
                $("#dvloader").hide();
                toastr.error(errorThrown, textStatus);
            }
        });
    }

    $('#login_form').keypress((e) => {
        if (e.which === 13) {
            save_login();
        }
    });
</script>
@endsection