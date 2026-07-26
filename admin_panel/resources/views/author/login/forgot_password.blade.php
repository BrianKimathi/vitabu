@extends('author.layout.page-app')
@section('tab_title', 'Forgot Password')
@section('page_title', 'Forgot Password')

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
    .back-login-link {
        color: #64748B;
        font-weight: 600;
        font-size: 0.9rem;
        transition: color 0.2s ease;
        text-decoration: none !important;
    }
    .back-login-link:hover {
        color: #4E45B8;
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
                            {{String_Cut($setting['app_description'], 200)}}
                        </p>
                    </div>
                </div>
            </div>
        </div>

        <div class="h-100 d-flex justify-content-center align-items-center col-md-12 col-lg-5 col-xl-5">
            <div class="mx-auto col-sm-11 col-md-9 col-xl-8 py-5">
                <div class="login-card-modern">
                    <div class="text-center mb-4">
                        <div class="mb-3">
                            <span class="d-inline-flex align-items-center justify-content-center" style="width: 56px; height: 56px; background: rgba(78, 69, 184, 0.1); color: #4E45B8; border-radius: 16px;">
                                <i class="fa-solid fa-key fa-xl"></i>
                            </span>
                        </div>
                        <h2 class="font-weight-bold text-dark mb-1" style="font-size: 1.6rem;">Forgot Password?</h2>
                        <p class="text-muted mb-0" style="font-size: 0.88rem; line-height: 1.5;">Enter your registered email below to receive a password reset link.</p>
                    </div>

                    <form id="forgot_password_form" method="POST" action="{{ route('author.send.forgot.password') }}">
                        @csrf

                        <div class="form-group mb-4">
                            <label class="font-weight-600 text-dark mb-2" style="font-size: 0.9rem;">{{__('label.email')}}</label>
                            <div class="input-icon-wrapper">
                                <i class="fa-regular fa-envelope"></i>
                                <input name="email" type="email" value="{{ old('email', '') }}" placeholder="{{__('label.email_here')}}" class="form-control form-control-login" autofocus>
                            </div>
                        </div>

                        <button class="btn btn-login-submit mb-3" type="submit">
                            Reset Password <i class="fa-solid fa-paper-plane ml-2"></i>
                        </button>

                        <div class="text-center">
                            <a href="{{ route('author.login') }}" class="back-login-link">
                                <i class="fa-solid fa-arrow-left mr-1"></i> Back to login
                            </a>
                        </div>
                    </form>
                </div>
            </div>
        </div>
    </div>
</div>
@endsection
