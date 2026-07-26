<header class="header">
    <div class="title-control">
        <button class="side-toggle" type="button">
            <span></span>
            <span></span>
            <span></span>
        </button>

        <a href="{{ route('author.dashboard') }}" class="side-logo" style="color:#4E45B8;">
            <h3 style="font-size:18px;font-weight:700;margin:0;">{{ App_Name() }}</h3>
        </a>

        <h1 class="page-title" style="font-size:24px;font-weight:600;color:#1F2937;">@yield('page_title')</h1>
    </div>

    <div class="head-control">
        @if( env('DEMO_MODE') == 'ON')
            <div class="demo-mode-box">
                <span>{{__('label.demo_mode')}}</span>
            </div>
        @endif

        <div class="dropdown dropright">
            <a href="#" class="btn head-btn" style="background:#EEF0FF;border:none;border-radius:10px;width:42px;height:42px;display:flex;align-items:center;justify-content:center;" data-toggle="dropdown" aria-haspopup="true" aria-expanded="false">
                <i class="fa-solid fa-user" style="color:#4E45B8;font-size:16px;"></i>
            </a>
            <div class="dropdown-menu p-2 mt-2" aria-labelledby="dropdownMenuLink">
                <a class="dropdown-item" href="{{ route('author.profile.index') }}" style="color:#4E45B8;border-radius:8px;">
                    <span><i class="fa-solid fa-user fa-sm mr-2"></i></span>
                    {{__('label.profile')}}
                </a>
                <a class="dropdown-item" href="{{ route('author.logout') }}" style="color:#EF4444;border-radius:8px;">
                    <span><i class="fa-solid fa-arrow-right-from-bracket fa-sm mr-2"></i></span>
                    {{__('label.logout')}}
                </a>
            </div>
        </div>
    </div>
</header>