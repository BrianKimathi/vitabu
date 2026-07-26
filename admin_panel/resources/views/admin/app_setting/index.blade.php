@extends('admin.layout.page-app')
@section('page_title', __('label.app_settings'))
@section('tab_title', __('label.app_settings'))

@section('content')
@include('admin.layout.sidebar')

<style>
    .custom-border-card {
        border: none !important;
        border-radius: 14px !important;
        box-shadow: 0 1px 3px rgba(0,0,0,0.08) !important;
        margin-bottom: 20px;
    }
    .custom-border-card .card-header {
        background: transparent !important;
        border-bottom: 1px solid #F3F4F6 !important;
        font-size: 16px !important;
        font-weight: 700 !important;
        color: #1F2937 !important;
        padding: 18px 24px !important;
    }
    .custom-border-card .card-header i {
        color: #4E45B8;
        margin-right: 8px;
    }
    .custom-border-card .card-body {
        padding: 20px 24px !important;
    }
    .btn-default {
        background: #4E45B8 !important;
        border-radius: 10px !important;
        font-size: 14px !important;
        font-weight: 600 !important;
        color: #fff !important;
        border: none !important;
        padding: 8px 24px !important;
        transition: all 0.2s;
    }
    .btn-default:hover {
        background: #3D35A0 !important;
        color: #fff !important;
    }
    .breadcrumb a { color: #4E45B8 !important; }
    .nav-pills .nav-link.active {
        background: #EEF0FF !important;
        color: #4E45B8 !important;
    }
    .nav-pills .nav-link:not(.active) {
        background: #F3F4F6 !important;
        color: #6B7280 !important;
    }
    .radio-group .custom-control-input:checked ~ .custom-control-label {
        background: #4E45B8 !important;
        color: #fff !important;
    }
    .radio-group .custom-control-label::before {
        border-color: #4E45B8 !important;
    }
</style>

<div class="right-content">
    @include('admin.layout.header')

    <div class="body-content">
        <!-- mobile title -->
        <h1 class="page-title-sm">{{__('label.app_settings')}}</h1>

        <div class="border-bottom row mb-3">
            <div class="col-sm-10">
                <ol class="breadcrumb" style="background:transparent;padding:0;">
                    <li class="breadcrumb-item"><a href="{{ route('admin.dashboard') }}">{{__('label.dashboard')}}</a></li>
                    <li class="breadcrumb-item active" aria-current="page" style="color:#6B7280;">{{__('label.app_settings')}}</li>
                </ol>
            </div>
        </div>

        <ul class="nav nav-pills mb-3" id="pills-tab" role="tablist" style="gap:4px;">
            <li class="nav-item">
                <a class="nav-link active" id="app-tab" data-toggle="tab" href="#app" role="tab" aria-selected="true" style="border-radius:8px;font-size:13px;font-weight:600;padding:7px 18px;background:#EEF0FF;color:#4E45B8;">{{__('label.app_settings')}}</a>
            </li>
            @if( env('DEMO_MODE') == 'OFF')
            <li class="nav-item">
                <a class="nav-link" id="smtp-tab" data-toggle="tab" href="#smtp" role="tab" aria-selected="false" style="border-radius:8px;font-size:13px;font-weight:600;padding:7px 18px;background:#F3F4F6;color:#6B7280;">{{__('label.smtp')}}</a>
            </li>
            @endif
            <li class="nav-item">
                <a class="nav-link" id="commission-tab" data-toggle="tab" href="#commission" role="tab" aria-selected="false" style="border-radius:8px;font-size:13px;font-weight:600;padding:7px 18px;background:#F3F4F6;color:#6B7280;">{{__('label.commission')}}</a>
            </li>
            <li class="nav-item">
                <a class="nav-link" id="social-tab" data-toggle="tab" href="#social" role="tab" aria-selected="false" style="border-radius:8px;font-size:13px;font-weight:600;padding:7px 18px;background:#F3F4F6;color:#6B7280;">{{__('label.social_setting')}}</a>
            </li>
            <li class="nav-item">
                <a class="nav-link" id="onboarding-tab" data-toggle="tab" href="#onboarding" role="tab" aria-selected="false" style="border-radius:8px;font-size:13px;font-weight:600;padding:7px 18px;background:#F3F4F6;color:#6B7280;">{{__('label.onboarding_screen')}}</a>
            </li>
        </ul>

        <div class="tab-content" id="pills-tabContent">
            <div class="tab-pane fade show active" id="app" role="tabpanel" aria-labelledby="app-tab">
                <div class="card custom-border-card">
                    <h5 class="card-header">{{__('label.app_settings')}}</h5>
                    <div class="card-body">
                        <form id="app_setting" enctype="multipart/form-data">
                            <div class="form-row">
                                <div class="col-md-9">
                                    <div class="form-row">
                                        <div class="form-group col-md-4">
                                            <label>{{__('label.app_name')}}<span class="text-danger">*</span></label>
                                            <input type="text" name="app_name" value="{{ $result['app_name'] }}" class="form-control" placeholder="{{__('label.app_name_here')}}">
                                        </div>
                                        <div class="form-group col-md-4">
                                            <label>{{__('label.app_version')}}<span class="text-danger">*</span></label>
                                            <input type="text" name="app_version" value="{{ $result['app_version'] }}" class="form-control" placeholder="{{__('label.app_version_here')}}">
                                        </div>
                                        <div class="form-group col-md-4">
                                            <label>{{__('label.email')}} <span class="text-danger">*</span></label>
                                            <input type="email" name="email" value="{{ $result['email'] }}" class="form-control" placeholder="{{__('label.email_here')}}">
                                        </div>
                                    </div>
                                    <div class="form-row">
                                        <div class="form-group col-md-4">
                                            <label>{{__('label.author')}}<span class="text-danger">*</span></label>
                                            <input type="text" name="author" value="{{ $result['author'] }}" class="form-control" placeholder="{{__('label.author_here')}}">
                                        </div>
                                        <div class="form-group col-md-4">
                                            <label> {{__('label.contact')}} <span class="text-danger">*</span></label>
                                            <input type="text" name="contact" value="{{ $result['contact'] }}" class="form-control" placeholder="{{__('label.contact_here')}}">
                                        </div>
                                        <div class="form-group col-md-4">
                                            <label>{{__('label.website')}}<span class="text-danger">*</span></label>
                                            <input type="text" name="website" value="{{ $result['website'] }}" class="form-control" placeholder="{{__('label.website_here')}}">
                                        </div>
                                    </div>
                                    <div class="form-row">
                                        <div class="form-group col-md-8">
                                            <label>{{__('label.app_description')}}<span class="text-danger">*</span></label>
                                            <textarea name="app_description" rows="1" class="form-control" placeholder="{{__('label.app_description_here')}}">{{ $result['app_description'] }}</textarea>
                                        </div>
                                        <div class="form-group col-md-4">
                                            <label>{{__('label.company_name')}}<span class="text-danger">*</span></label>
                                            <input type="text" name="company_name" value="{{ $result['company_name'] }}" class="form-control" placeholder="{{__('label.company_name_here')}}">
                                        </div>
                                    </div>
                                    <div class="form-row">
                                        <div class="form-group col-md-12">
                                            <label>{{__('label.address')}}<span class="text-danger">*</span></label>
                                            <textarea name="address" rows="1" class="form-control" placeholder="{{__('label.address_here')}}">{{ $result['address'] }}</textarea>
                                        </div>
                                    </div>
                                    <div class="form-row">
                                        <div class="form-group col-md-12">
                                            <label><strong>SMS Gateway (Celcom Africa)</strong></label>
                                        </div>
                                        <div class="form-group col-md-3">
                                            <label>SMS API URL</label>
                                            <input type="text" name="sms_api_url" value="{{ $result['sms_api_url'] ?? 'https://isms.celcomafrica.com/api/services/sendsms' }}" class="form-control" placeholder="https://isms.celcomafrica.com/api/services/sendsms">
                                        </div>
                                        <div class="form-group col-md-3">
                                            <label>SMS API Key</label>
                                            <input type="text" name="sms_api_key" value="{{ $result['sms_api_key'] ?? '' }}" class="form-control" placeholder="API Key">
                                        </div>
                                        <div class="form-group col-md-3">
                                            <label>SMS PartnerID</label>
                                            <input type="text" name="sms_partner_id" value="{{ $result['sms_partner_id'] ?? '' }}" class="form-control" placeholder="PartnerID">
                                        </div>
                                        <div class="form-group col-md-3">
                                            <label>SMS Shortcode</label>
                                            <input type="text" name="sms_shortcode" value="{{ $result['sms_shortcode'] ?? '' }}" class="form-control" placeholder="TEXTME">
                                        </div>
                                    </div>
                                </div>
                                <div class="col-md-3">
                                    <div class="form-row">
                                        <div class="col-12">
                                            <div class="form-group ml-5">
                                                <label class="ml-5">{{__('label.app_logo')}}<span class="text-danger">*</span></label>
                                                <div class="avatar-upload ml-5">
                                                    <div class="avatar-edit">
                                                        <input type='file' name="app_logo" id="imageUpload" accept=".png, .jpg, .jpeg, .webp" />
                                                        <label for="imageUpload" title="{{__('label.upload_file')}}"></label>
                                                    </div>
                                                    <div class="avatar-preview">
                                                        <img src="{{ $result['app_logo'] }}" id="imagePreview">
                                                    </div>
                                                </div>
                                                <input type="hidden" name="old_app_logo" value="{{ $result['app_logo'] }}">
                                            </div>
                                        </div>
                                    </div>
                                    <div class="form-row">
                                        <div class="col-12">
                                            <div class="form-group ml-5">
                                                <label class="ml-5">{{__('label.company_logo')}}<span class="text-danger">*</span></label>
                                                <div class="avatar-upload ml-5">
                                                    <div class="avatar-edit">
                                                        <input type='file' name="company_logo" id="imageUpload2" accept=".png, .jpg, .jpeg, .webp, .webp" />
                                                        <label for="imageUpload2" title="{{__('label.upload_file')}}"></label>
                                                    </div>
                                                    <div class="avatar-preview">
                                                        <img src="{{ $result['company_logo'] }}" id="imagePreview2">
                                                    </div>
                                                </div>
                                                <input type="hidden" name="old_company_logo" value="{{ $result['company_logo'] }}">
                                            </div>
                                        </div>
                                    </div>
                                </div>
                            </div>
                            <div class="border-top pt-3 text-right">
                                <button type="button" class="btn btn-default mw-120" onclick="app_setting()">{{__('label.save')}}</button>
                                <input type="hidden" name="_token" value="{{ csrf_token() }}">
                            </div>
                        </form>
                    </div>
                </div>
                <!-- API Configrations -->
                <div class="card custom-border-card">
                    <h5 class="card-header">{{__('label.api_configrations')}}</h5>
                    <div class="card-body">
                        <div class="input-group">
                            <div class="col-2">
                                <label class="pt-3" style="font-size:16px; font-weight:500; color:#1b1b1b">{{__('label.api_path')}}</label>
                            </div>
                            <input type="text" readonly value="{{url('/')}}/api/" name="api_path" class="form-control" id="api_path">
                            <div class="input-group-text ml-2" onclick="Function_Api_path('api_path')">
                                <i class="fa-solid fa-copy fa-2xl"></i>
                            </div>
                        </div>
                    </div>
                </div>
                <div class="form-row">
                    <div class="col-6">
                        <!-- Purchase Code -->
                        <div class="card custom-border-card">
                            <h5 class="card-header">{{__('label.purchase_code')}}</h5>
                            <div class="card-body">
                                <div class="form-row">
                                    <div class="form-group col-md-6">
                                        <label>{{__('label.purchase_code')}}</label>
                                        <input type="text" class="form-control" value="{{env('PURCHASE_CODE')}}" readonly>
                                    </div>
                                    <div class="form-group col-md-6">
                                        <label> {{__('label.envato_name')}}</label>
                                        <input type="text" class="form-control" value="{{env('BUYER_USERNAME')}}" readonly>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>
                    <div class="col-6">
                        <!-- Currency Settings -->
                        <div class="card custom-border-card">
                            <h5 class="card-header">{{__('label.currency_settings')}}</h5>
                            <div class="card-body">
                                <form id="save_currency">
                                    <div class="form-row">
                                        <div class="form-group col-md-6">
                                            <label>{{__('label.currency_name')}}<span class="text-danger">*</span></label>
                                            <input type="text" name="currency" class="form-control" value="{{ $result['currency'] }}" placeholder="{{__('label.currency_name_here')}}">
                                        </div>
                                        <div class="form-group col-md-6">
                                            <label> {{__('label.currency_code')}}<span class="text-danger">*</span></label>
                                            <input type="text" name="currency_code" class="form-control" value="{{ $result['currency_code'] }}" placeholder="{{__('label.currency_code_here')}}">
                                        </div>
                                    </div>
                                    <div class="border-top pt-3 text-right">
                                        <button type="button" class="btn btn-default mw-120" onclick="save_currency()">{{__('label.save')}}</button>
                                        <input type="hidden" name="_token" value="{{ csrf_token() }}">
                                    </div>
                                </form>
                            </div>
                        </div>
                    </div>
                    <div class="col-6">
                        <!-- Screenshot Settings -->
                        <div class="card custom-border-card">
                            <h5 class="card-header">{{__('label.screenshot_settings')}}</h5>
                            <div class="card-body">
                                <form id="save_screenshot">
                                    <div class="form-row">
                                        <div class="com-md-6">
                                            <div class="form-group">
                                                <label>{{__('label.screenshot_settings')}}</label>
                                                <div class="radio-group mt-2">
                                                    <div class="custom-control custom-radio">
                                                        <input type="radio" id="enable_ss" value="1" name="screenshot" class="custom-control-input" {{$result['screenshot']==1 ? "checked" : ""}}>
                                                        <label class="custom-control-label" for="enable_ss">{{__('label.enable')}}</label>
                                                    </div>
                                                    <div class="custom-control custom-radio">
                                                        <input type="radio" id="disable_ss" value="0" name="screenshot" class="custom-control-input" {{$result['screenshot']==0 ? "checked" : ""}}>
                                                        <label class="custom-control-label" for="disable_ss">{{__('label.disable')}}</label>
                                                    </div>
                                                </div>
                                            </div>
                                        </div>
                                    </div>
                                    <div class="border-top pt-3 text-right">
                                        <button type="button" class="btn btn-default mw-120" onclick="save_screenshot_setting()">{{__('label.save')}}</button>
                                        <input type="hidden" name="_token" value="{{ csrf_token() }}">
                                    </div>
                                </form>
                            </div>
                        </div>
                    </div>
                    <div class="col-6">
                        <!-- Vap Id Key -->
                        <div class="card custom-border-card">
                            <h5 class="card-header">{{__('label.vap_id_key')}}</h5>
                            <div class="card-body">
                                <form id="save_vap_id_key">
                                    <div class="form-row">
                                        <div class="col-md-6">
                                            <div class="form-group">
                                                <label>{{__('label.key')}}<span class="text-danger">*</span></label>
                                                <input type="text" name="vap_id_key" class="form-control" value="{{ $result['vap_id_key'] }}" placeholder="{{__('label.vap_id_key_here')}}">
                                            </div>
                                        </div>
                                    </div>
                                    <div class="border-top pt-3 text-right">
                                        <button type="button" class="btn btn-default mw-120" onclick="save_vap_id_key()">{{__('label.save')}}</button>
                                        <input type="hidden" name="_token" value="{{ csrf_token() }}">
                                    </div>
                                </form>
                            </div>
                        </div>
                    </div>
                    <div class="col-6">
                        <!-- Reading Time Settings -->
                        <div class="card custom-border-card">
                            <h5 class="card-header">{{__('label.reading_time_settings')}}</h5>
                            <div class="card-body">
                                <form id="save_reading_time">
                                    <div class="form-row">
                                        <div class="form-group col-md-6">
                                            <label>{{__('label.min_time')}}<span class="text-danger">*</span></label>
                                            <input type="number" name="min_time" class="form-control" value="{{ $result['min_time'] }}" placeholder="{{__('label.currency_name_here')}}">
                                        </div>
                                        <div class="form-group col-md-6">
                                            <label> {{__('label.max_time')}}<span class="text-danger">*</span></label>
                                            <input type="number" name="max_time" class="form-control" value="{{ $result['max_time'] }}" placeholder="{{__('label.currency_code_here')}}">
                                        </div>
                                    </div>
                                    <div class="border-top pt-3 text-right">
                                        <button type="button" class="btn btn-default mw-120" onclick="save_reading_time()">{{__('label.save')}}</button>
                                        <input type="hidden" name="_token" value="{{ csrf_token() }}">
                                    </div>
                                </form>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
            <div class="tab-pane fade" id="smtp" role="tabpanel" aria-labelledby="smtp-tab">
                <div class="card custom-border-card">
                    <h5 class="card-header">{{__('label.email_setting_smtp')}}</h5>
                    <div class="card-body">
                        <form id="smtp_setting">
                            <input type="hidden" name="id" value="{{ $smtp->id }}">
                            <div class="form-row">
                                <div class="form-group col-md-3">
                                    <label>{{__('label.is_smtp_active')}}<span class="text-danger">*</span></label>
                                    <select name="status" class="form-control">
                                        <option value="">{{__('label.select_status')}}</option>
                                        <option value="0" {{ $smtp->status == 0  ? 'selected' : ''}}>{{__('label.no')}}</option>
                                        <option value="1" {{ $smtp->status == 1  ? 'selected' : ''}}>{{__('label.yes')}}</option>
                                    </select>
                                </div>
                                <div class="form-group col-md-3">
                                    <label>{{__('label.host')}}<span class="text-danger">*</span></label>
                                    <input type="text" name="host" class="form-control" value="{{ $smtp->host }}" placeholder="{{__('label.host_here')}}">
                                </div>
                                <div class="form-group col-md-3">
                                    <label>{{__('label.port')}}<span class="text-danger">*</span></label>
                                    <input type="text" name="port" class="form-control" value="{{ $smtp->port }}" placeholder="{{__('label.port_here')}}">
                                </div>
                                <div class="form-group col-md-3">
                                    <label>{{__('label.protocol')}}<span class="text-danger">*</span></label>
                                    <input type="text" name="protocol" class="form-control" value="{{ $smtp->protocol }}" placeholder="{{__('label.protocol_here')}}">
                                </div>
                            </div>
                            <div class="form-row">
                                <div class="form-group col-md-3">
                                    <label>{{__('label.user_name')}}<span class="text-danger">*</span></label>
                                    <input type="text" name="user" class="form-control" value="{{ $smtp->user }}" placeholder="{{__('label.user_name_here')}}">
                                </div>
                                <div class="form-group col-md-3">
                                    <label>{{__('label.password')}}<span class="text-danger">*</span></label>
                                    <input type="password" name="pass" class="form-control" value="{{ $smtp->pass }}" placeholder="{{__('label.password_here')}}">
                                    <label class="mt-1 text-gray">{{__('label.search_for_better_result')}} <a href="https://support.google.com/mail/answer/185833?hl=en" target="_blank" class="btn-link">{{__('label.click_here')}}</a></label>
                                </div>
                                <div class="form-group col-md-3">
                                    <label>{{__('label.from_name')}}<span class="text-danger">*</span></label>
                                    <input type="text" name="from_name" class="form-control" value="{{ $smtp->from_name }}" placeholder="{{__('label.from_name_here')}}">
                                </div>
                                <div class="form-group col-md-3">
                                    <label>{{__('label.from_email')}}<span class="text-danger">*</span></label>
                                    <input type="text" name="from_email" class="form-control" value="{{ $smtp->from_email }}" placeholder="{{__('label.from_email_here')}}">
                                </div>
                            </div>
                            <div class="border-top pt-3 text-right">
                                <button type="button" class="btn btn-default mw-120" onclick="smtp_setting()">{{__('label.save')}}</button>
                                <input type="hidden" name="_token" value="{{ csrf_token() }}">
                            </div>
                        </form>
                    </div>
                </div>
                @if($smtp->status==1)
                <div class="card custom-border-card col-md-6">
                    <h5 class="card-header">{{__('label.test_smtp')}}</h5>
                    <div class="card-body">
                        <form id="test_smtp" method="POST">
                            <div class="form-row">
                                <div class="form-group col-md-8">
                                    <label>{{__('label.email')}}</label>
                                    <input type="text" name="email" class="form-control" placeholder="{{__('label.email_here')}}">
                                </div>
                            </div>
                            <div class="border-top pt-3 text-right">
                                <button type="button" class="btn btn-default mw-120" onclick="test_smtp()">{{__('label.send')}}</button>
                                <input type="hidden" name="_token" value="{{ csrf_token() }}">
                            </div>
                        </form>
                    </div>
                </div>
                @endif
            </div>
            <div class="tab-pane fade" id="commission" role="tabpanel" aria-labelledby="commission-tab">
                <div class="card custom-border-card">
                    <h5 class="card-header">{{__('label.commission')}}</h5>
                    <div class="card-body">
                        <form id="commission_setting">
                            <div class="form-row">
                                <div class="form-group col-md-2">
                                    <label>{{__('label.active_commission')}}</label>
                                    <input type="text" class="form-control" value="{{$result['active_commission']}}" readonly>
                                </div>
                                <div class="form-group col-md-2">
                                    <label>{{__('label.commission_type')}}<span class="text-danger">*</span></label>
                                    <input class="form-control" value="{{__('percentage')}}" readonly>
                                </div>
                                <div class="form-group col-md-4">
                                    <label>{{__('label.commission')}}<span class="text-danger">*</span> {{__('label.commission_note')}}</label>
                                    <input type="number" name="commission" min="1" class="form-control" value="{{ $result['commission'] }}" placeholder="{{__('label.commission_here')}}">
                                </div>
                            </div>
                            <div class="border-top pt-3 text-right">
                                <button type="button" class="btn btn-default mw-120" onclick="commission_setting()">{{__('label.save')}}</button>
                                <input type="hidden" name="_token" value="{{ csrf_token() }}">
                            </div>
                        </form>
                    </div>
                </div>
            </div>
            <div class="tab-pane fade" id="social" role="tabpanel" aria-labelledby="social-tab">
                <div class="card custom-border-card">
                    <h5 class="card-header">{{__('label.social_links')}}</h5>
                    <div class="card-body">
                        <form id="social_link" enctype="multipart/form-data">
                            <div class="row">
                                <div class="form-group col-md-3">
                                    <label>{{__('label.name')}}<span class="text-danger">*</span></label>
                                    <input type="text" name="name[]" class="form-control" placeholder="{{__('label.name_here')}}">
                                </div>
                                <div class="form-group col-md-3">
                                    <label>{{__('label.url')}}<span class="text-danger">*</span></label>
                                    <input type="url" name="url[]" class="form-control" placeholder="{{__('label.url_here')}}">
                                </div>
                                <div class="form-group col-md-3">
                                    <label>{{__('label.icon')}}<span class="text-danger">*</span></label>
                                    <input type="file" name="image[]" class="form-control import-file social_img" id="social_img" accept=".png, .jpg, .jpeg, .webp">
                                    <input type="hidden" name="old_image[]" value="">
                                </div>
                                <div class="form-group col-md-1">
                                    <div class="custom-file">
                                        <img src="{{asset('assets/imgs/upload_img.png')}}" class="img-thumbnail size-90" id="link_img_social_img">
                                    </div>
                                </div>
                                <div class="col-md-1 mt-2">
                                    <div class="flex-grow-1 px-5 d-inline-flex">
                                        <div class="change mr-3 mt-4" id="add_btn">
                                            <a class="btn btn-success add-more text-white" onclick="add_more_link()">+</a>
                                        </div>
                                    </div>
                                </div>
                            </div>

                            @for ($i=0; $i < count($social_link); $i++)
                                <div class="social_part">
                                <div class="row">
                                    <div class="form-group col-md-3">
                                        <label>{{__('label.name')}}<span class="text-danger">*</span></label>
                                        <input type="text" name="name[]" value="{{ $social_link[$i]['name'] }}" class="form-control" placeholder="{{__('label.name_here')}}">
                                    </div>
                                    <div class="form-group col-md-3">
                                        <label>{{__('label.url')}}<span class="text-danger">*</span></label>
                                        <input type="url" name="url[]" value="{{ $social_link[$i]['url'] }}" class="form-control" placeholder="{{__('label.url_here')}}">
                                    </div>
                                    <div class="form-group col-md-3">
                                        <label>{{__('label.icon')}}<span class="text-danger">*</span></label>
                                        <input type="file" name="image[]" class="form-control import-file social_img" id="social_img_{{$i}}" accept=".png, .jpg, .jpeg, .webp">
                                        <input type="hidden" name="old_image[]" value="{{ basename($social_link[$i]['image']) }}">
                                    </div>
                                    <div class="form-group col-md-1">
                                        <div class="custom-file">
                                            <img src="{{$social_link[$i]['image']}}" class="img-thumbnail size-90" id="link_img_social_img_{{$i}}">
                                        </div>
                                    </div>
                                    <div class="col-md-1 mt-2">
                                        <div class="flex-grow-1 px-5 d-inline-flex">
                                            <div class="change mr-3 mt-4" id="add_btn">
                                                <a class="btn btn-danger text-white remove_link">-</a>
                                            </div>
                                        </div>
                                    </div>
                                </div>
                    </div>
                    @endfor

                    <div class="add-more-social-link"></div>

                    <div class="border-top pt-3 text-right">
                        <button type="button" class="btn btn-default mw-120" onclick="social_link()">{{__('label.save')}}</button>
                        <input type="hidden" name="_token" value="{{ csrf_token() }}">
                    </div>
                    </form>
                </div>
            </div>
        </div>
        <div class="tab-pane fade" id="onboarding" role="tabpanel" aria-labelledby="onboarding-tab">
            <div class="card custom-border-card">
                <h5 class="card-header">{{__('label.onboarding_screen')}}</h5>
                <div class="card-body">
                    <form id="onboarding_screen" enctype="multipart/form-data">
                        <div class="row">
                            <div class="form-group col-md-3">
                                <label>{{__('label.title')}}<span class="text-danger">*</span></label>
                                <input type="text" name="title[]" class="form-control" placeholder="{{__('label.title_here')}}">
                            </div>
                            <div class="form-group col-md-3">
                                <label>{{__('label.description')}}<span class="text-danger">*</span></label>
                                <textarea name="description[]" rows="1" class="form-control" placeholder="{{__('label.description_here')}}"></textarea>
                            </div>
                            <div class="form-group col-md-3">
                                <label>{{__('label.image')}}<span class="text-danger">*</span></label>
                                <input type="file" name="image[]" class="form-control import-file on_boarding_img" id="on_boarding_img" accept=".png, .jpg, .jpeg, .webp">
                                <input type="hidden" name="old_image[]" value="">
                            </div>
                            <div class="form-group col-md-1">
                                <div class="custom-file">
                                    <img src="{{asset('assets/imgs/upload_img.png')}}" class="img-thumbnail size-90" id="link_img_on_boarding_img">
                                </div>
                            </div>
                            <div class="col-md-1 mt-2">
                                <div class="flex-grow-1 px-5 d-inline-flex">
                                    <div class="change mr-3 mt-4" id="add_btn">
                                        <a class="btn btn-success add-more text-white" onclick="add_more_screen()">+</a>
                                    </div>
                                </div>
                            </div>
                        </div>

                        @for ($i=0; $i < count($onboarding_screen); $i++)
                            <div class="onboarding_part">
                            <div class="row">
                                <div class="form-group col-md-3">
                                    <label>{{__('label.title')}}<span class="text-danger">*</span></label>
                                    <input type="text" name="title[]" value="{{ $onboarding_screen[$i]['title'] }}" class="form-control" placeholder="{{__('label.title_here')}}">
                                </div>
                                <div class="form-group col-md-3">
                                    <label>{{__('label.description')}}<span class="text-danger">*</span></label>
                                    <textarea name="description[]" rows="1" class="form-control" placeholder="{{__('label.description_here')}}">{{ $onboarding_screen[$i]['description'] }}</textarea>
                                </div>
                                <div class="form-group col-md-3">
                                    <label>{{__('label.image')}}<span class="text-danger">*</span></label>
                                    <input type="file" name="image[]" class="form-control import-file on_boarding_img" id="on_boarding_img{{$i}}" accept=".png, .jpg, .jpeg, .webp">
                                    <input type="hidden" name="old_image[]" value="{{ basename($onboarding_screen[$i]['image']) }}">
                                </div>
                                <div class="form-group col-md-1">
                                    <div class="custom-file">
                                        <img src="{{ $onboarding_screen[$i]['image'] }}" class="img-thumbnail size-90" id="link_img_on_boarding_img{{$i}}">
                                    </div>
                                </div>
                                <div class="col-md-1 mt-2">
                                    <div class="flex-grow-1 px-5 d-inline-flex">
                                        <div class="change mr-3 mt-4" id="add_btn">
                                            <a class="btn btn-danger text-white remove_on_boarding">-</a>
                                        </div>
                                    </div>
                                </div>
                            </div>
                </div>
                @endfor

                <div class="add-more-onboarding"></div>

                <div class="border-top pt-3 text-right">
                    <button type="button" class="btn btn-default mw-120" onclick="onboarding_screen()">{{__('label.save')}}</button>
                    <input type="hidden" name="_token" value="{{ csrf_token() }}">
                </div>
                </form>
            </div>
        </div>
    </div>
</div>
</div>
</div>
@endsection

@section('pagescript')
<script>
    // Sidebar Scroll Down
    let sidebarHeight = $('.sidebar')[0].scrollHeight;
    sidebar_down(sidebarHeight);

    // App Setting
    function app_setting() {

        var Demo_Mode = '<?php echo Demo_Mode(); ?>';
        if (Demo_Mode == 1) {

            $("#dvloader").show();
            var formData = new FormData($("#app_setting")[0]);

            $.ajax({
                type: 'POST',
                url: '{{ route("admin.appsetting.app") }}',
                data: formData,
                cache: false,
                contentType: false,
                processData: false,
                success: function(resp) {
                    $("#dvloader").hide();
                    get_responce_message(resp, 'app_setting', '{{ route("admin.appsetting.index") }}');
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
    // API Key
    function Function_Api_path(id) {
        /* Get the text field */
        var copyText = document.getElementById(id);

        /* Select the text field */
        copyText.select();
        copyText.setSelectionRange(0, 99999); /* For mobile devices */

        document.execCommand('copy');

        /* Alert the copied text */
        alert("Copied the API Path: " + copyText.value);
    }
    // Currency Setting
    function save_currency() {

        var Demo_Mode = '<?php echo Demo_Mode(); ?>';
        if (Demo_Mode == 1) {

            $("#dvloader").show();
            var formData = new FormData($("#save_currency")[0]);

            $.ajax({
                type: 'POST',
                url: '{{ route("admin.appsetting.currency") }}',
                data: formData,
                cache: false,
                contentType: false,
                processData: false,
                success: function(resp) {
                    $("#dvloader").hide();
                    $("html, body").animate({
                        scrollTop: 0
                    }, "swing");
                    get_responce_message(resp);
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

    function save_screenshot_setting() {

        var Demo_Mode = '<?php echo Demo_Mode(); ?>';
        if (Demo_Mode == 1) {

            $("#dvloader").show();
            var formData = new FormData($("#save_screenshot")[0]);

            $.ajax({
                type: 'POST',
                url: '{{ route("admin.appsetting.screenshot") }}',
                data: formData,
                cache: false,
                contentType: false,
                processData: false,
                success: function(resp) {
                    $("#dvloader").hide();
                    $("html, body").animate({
                        scrollTop: 0
                    }, "swing");
                    get_responce_message(resp);
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

    function save_vap_id_key() {

        var Demo_Mode = '<?php echo Demo_Mode(); ?>';
        if (Demo_Mode == 1) {

            $("#dvloader").show();
            var formData = new FormData($("#save_vap_id_key")[0]);

            $.ajax({
                type: 'POST',
                url: '{{ route("admin.appsetting.vap_id_key") }}',
                data: formData,
                cache: false,
                contentType: false,
                processData: false,
                success: function(resp) {
                    $("#dvloader").hide();
                    $("html, body").animate({
                        scrollTop: 0
                    }, "swing");
                    get_responce_message(resp);
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

    function save_reading_time() {

        var Demo_Mode = '<?php echo Demo_Mode(); ?>';
        if (Demo_Mode == 1) {

            $("#dvloader").show();
            var formData = new FormData($("#save_reading_time")[0]);

            $.ajax({
                type: 'POST',
                url: '{{ route("admin.appsetting.reading_time") }}',
                data: formData,
                cache: false,
                contentType: false,
                processData: false,
                success: function(resp) {
                    $("#dvloader").hide();
                    $("html, body").animate({
                        scrollTop: 0
                    }, "swing");
                    get_responce_message(resp);
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

    // SMTP
    function smtp_setting() {

        var Demo_Mode = '<?php echo Demo_Mode(); ?>';
        if (Demo_Mode == 1) {

            $("#dvloader").show();
            var formData = new FormData($("#smtp_setting")[0]);

            $.ajax({
                type: 'POST',
                url: '{{ route("admin.appsetting.smtp") }}',
                data: formData,
                cache: false,
                contentType: false,
                processData: false,
                success: function(resp) {
                    $("#dvloader").hide();
                    $("html, body").animate({
                        scrollTop: 0
                    }, "swing");
                    get_responce_message(resp);
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

    // test smtp 
    function test_smtp() {
        var isAdmin = <?php echo Demo_Mode(); ?>;
        if (isAdmin == 1) {
            var formData = new FormData($("#test_smtp")[0]);
            $("#dvloader").show();
            $.ajax({
                type: 'POST',
                url: '{{ route("admin.appsetting.testsmtp") }}',
                data: formData,
                cache: false,
                contentType: false,
                processData: false,
                success: function(resp) {
                    $("#dvloader").hide();
                    $("html, body").animate({
                        scrollTop: 0
                    }, "swing");
                    get_responce_message(resp, 'test_smtp');
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
    // Commission
    function commission_setting() {

        var Demo_Mode = '<?php echo Demo_Mode(); ?>';
        if (Demo_Mode == 1) {

            $("#dvloader").show();
            var formData = new FormData($("#commission_setting")[0]);

            $.ajax({
                type: 'POST',
                url: '{{ route("admin.appsetting.commission") }}',
                data: formData,
                cache: false,
                contentType: false,
                processData: false,
                success: function(resp) {
                    $("#dvloader").hide();
                    $("html, body").animate({
                        scrollTop: 0
                    }, "swing");
                    get_responce_message(resp);
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

    // Multipal Img Show 
    $(document).on('change', '.social_img', function() {
        readURL(this, this.id);
    });
    $(document).on('change', '.on_boarding_img', function() {
        readURL(this, this.id);
    });

    function readURL(input, id) {
        if (input.files && input.files[0]) {
            var reader = new FileReader();

            reader.onload = function(e) {
                $('#link_img_' + id).attr('src', e.target.result);
            }
            reader.readAsDataURL(input.files[0]);
        }
    }

    // Social Link Add-Remove Link Part
    var i = -1;

    function add_more_link() {

        var data = '<div class="social_part">';
        data += '<div class="row">';
        data += '<div class="form-group col-md-3">';
        data += '<label>{{__("label.name")}}<span class="text-danger">*</span></label>';
        data += '<input type="text" name="name[]" class="form-control" placeholder="{{__("label.name_here")}}">';
        data += '</div>';
        data += '<div class="form-group col-md-3">';
        data += '<label>{{__("label.url")}}<span class="text-danger">*</span></label>';
        data += '<input type="url" name="url[]" class="form-control" placeholder="{{__("label.url_here")}}">';
        data += '</div>';
        data += '<div class="form-group col-lg-3">';
        data += '<label>{{__("label.icon")}}<span class="text-danger">*</span></label>';
        data += '<input type="file" name="image[]" class="form-control import-file social_img" id="social_img_' + i + '" accept=".png, .jpg, .jpeg, .webp">';
        data += '<input type="hidden" name="old_image[]" value="">';
        data += '</div>';
        data += '<div class="form-group col-md-1">';
        data += '<div class="custom-file">';
        data += '<img src="{{asset("assets/imgs/upload_img.png")}}" class="img-thumbnail size-90" id="link_img_social_img_' + i + '">';
        data += '</div>';
        data += '</div>';
        data += '<div class="col-md-1 mt-2">';
        data += '<div class="flex-grow-1 px-5 d-inline-flex">';
        data += '<div class="change mr-3 mt-4" id="add_btn">';
        data += '<a class="btn btn-danger add-more text-white remove_link">-</a>';
        data += '</div>';
        data += '</div>';
        data += '</div>';
        data += '</div>';
        data += '</div>';

        $('.add-more-social-link').append(data);
        i--;
        $("html, body").animate({
            scrollTop: $(document).height()
        }, "slow");
    }
    $("body").on("click", ".remove_link", function(e) {
        $(this).parents('.social_part').remove();
    });
    // Social Link Save
    function social_link() {

        var Demo_Mode = '<?php echo Demo_Mode(); ?>';
        if (Demo_Mode == 1) {

            $("#dvloader").show();
            var formData = new FormData($("#social_link")[0]);
            $.ajax({
                type: 'POST',
                url: '{{ route("admin.appsetting.sociallink") }}',
                data: formData,
                cache: false,
                contentType: false,
                processData: false,
                success: function(resp) {
                    $("#dvloader").hide();
                    get_responce_message(resp, 'social_link', '{{ route("admin.appsetting.index") }}');
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

    // OnBoarding Screen Add-Remove Link Part
    var i = -1;

    function add_more_screen() {

        var data = '<div class="onboarding_part">';
        data += '<div class="row">';
        data += '<div class="form-group col-md-3">';
        data += '<label>{{__("label.title")}}<span class="text-danger">*</span></label>';
        data += '<input type="text" name="title[]" class="form-control" placeholder="{{__("label.title_here")}}">';
        data += '</div>';
        data += '<div class="form-group col-md-3">';
        data += '<label>{{__("label.description")}}<span class="text-danger">*</span></label>';
        data += '<textarea name="description[]" rows="1" class="form-control" placeholder="{{__("label.description_here")}}"></textarea>';
        data += '</div>';
        data += '<div class="form-group col-lg-3">';
        data += '<label>{{__("label.image")}}<span class="text-danger">*</span></label>';
        data += '<input type="file" name="image[]" class="form-control import-file on_boarding_img" id="on_boarding_img_' + i + '" accept=".png, .jpg, .jpeg, .webp">';
        data += '<input type="hidden" name="old_image[]" value="">';
        data += '</div>';
        data += '<div class="form-group col-md-1">';
        data += '<div class="custom-file">';
        data += '<img src="{{asset("assets/imgs/upload_img.png")}}" class="img-thumbnail size-90" id="link_img_on_boarding_img_' + i + '">';
        data += '</div>';
        data += '</div>';
        data += '<div class="col-md-1 mt-2">';
        data += '<div class="flex-grow-1 px-5 d-inline-flex">';
        data += '<div class="change mr-3 mt-4" id="add_btn">';
        data += '<a class="btn btn-danger add-more text-white remove_on_boarding">-</a>';
        data += '</div>';
        data += '</div>';
        data += '</div>';
        data += '</div>';
        data += '</div>';

        $('.add-more-onboarding').append(data);
        i--;
        $("html, body").animate({
            scrollTop: $(document).height()
        }, "slow");
    }
    $("body").on("click", ".remove_on_boarding", function(e) {
        $(this).parents('.onboarding_part').remove();
    });
    // OnBoarding Screen Save
    function onboarding_screen() {

        var Demo_Mode = '<?php echo Demo_Mode(); ?>';
        if (Demo_Mode == 1) {

            $("#dvloader").show();
            var formData = new FormData($("#onboarding_screen")[0]);
            $.ajax({
                type: 'POST',
                url: '{{ route("admin.appsetting.onboardingscreen") }}',
                data: formData,
                cache: false,
                contentType: false,
                processData: false,
                success: function(resp) {
                    $("#dvloader").hide();
                    get_responce_message(resp, 'onboarding_screen', '{{ route("admin.appsetting.index") }}');
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
</script>
@endsection