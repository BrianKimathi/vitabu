<div class="sidebar">
    <div class="side-head">
        <a href="{{ route('author.dashboard') }}" class="side-logo">
            <img src="{{ asset('assets/imgs/logo.png') }}" alt="Logo">
            <h3>{{ App_Name() }}</h3>
        </a>
        <button class="side-toggle" type="button">
            <span></span>
            <span></span>
            <span></span>
        </button>
    </div>

    <ul class="side-menu">
        <li class="side_line {{ request()->routeIs('author.dashboard*') ? 'active' : '' }}{{ request()->routeIs('author.profile*') ? 'active' : '' }}">
            <a href="{{ route('author.dashboard') }}">
                <i class="fa-solid fa-house menu-icon"></i>
                <span>{{__('label.dashboard')}}</span>
            </a>
        </li>

        <li class="partition"><span>{{__('label.basic_element')}}</span></li>
        <li class="dropdown {{ request()->routeIs('author.category*') ? 'active' : '' }}{{ request()->routeIs('author.language*') ? 'active' : '' }}">
            <a class="dropdown-toggle" data-toggle="dropdown" aria-haspopup="true" aria-expanded="{{ request()->routeIs('author.category*') || request()->routeIs('author.language*') ? 'true' : 'false' }}">
                <i class="fa-solid fa-gear menu-icon"></i>
                <span>{{__('label.basic_items')}}</span>
            </a>
            <ul class="dropdown-menu side-submenu">
                <li class="side_line {{ request()->routeIs('author.category*') ? 'active' : '' }}">
                    <a href="{{ route('author.category.index') }}" class="dropdown-item">
                        <i class="fa-solid fa-list submenu-icon"></i>
                        <span>{{__('label.category')}}</span>
                    </a>
                </li>
                <li class="side_line {{ request()->routeIs('author.language*') ? 'active' : '' }}">
                    <a href="{{ route('author.language.index') }}" class="dropdown-item">
                        <i class="fa-solid fa-globe submenu-icon"></i>
                        <span>{{__('label.language')}}</span>
                    </a>
                </li>
            </ul>
        </li>

        <li class="partition"><span>{{__('label.contents')}}</span></li>
        <li class="side_line {{ request()->routeIs('author.novels.*') ? 'active' : '' }}">
            <a href="{{ route('author.novels.index') }}">
                <i class="fa-solid fa-book menu-icon"></i>
                <span>{{__('label.novels')}}</span>
            </a>
        </li>
        <li class="side_line {{ request()->routeIs('author.magazines.*') ? 'active' : '' }}">
            <a href="{{ route('author.magazines.index') }}">
                <i class="fa-solid fa-newspaper menu-icon"></i>
                <span>{{__('label.magazines')}}</span>
            </a>
        </li>
        <li class="side_line {{ request()->routeIs('author.audiobooks.*') ? 'active' : '' }}">
            <a href="{{ route('author.audiobooks.index') }}">
                <i class="fa-solid fa-headphones menu-icon"></i>
                <span>{{__('label.audiobooks')}}</span>
            </a>
        </li>

        <li class="partition"><span>{{__('label.interaction')}}</span></li>
        <li class="side_line {{ request()->routeIs('author.reviews*') ? 'active' : '' }}">
            <a href="{{ route('author.reviews.index') }}">
                <i class="fa-solid fa-comment-dots menu-icon"></i>
                <span>{{__('label.reviews')}}</span>
            </a>
        </li>

        <li class="partition"><span>{{__('label.finance')}}</span></li>
        <li class="dropdown {{ request()->routeIs('author.salesnovels*') ? 'active' : '' }}{{ request()->routeIs('author.salesmagazines*') ? 'active' : '' }}{{ request()->routeIs('author.salesaudiobooks*') ? 'active' : '' }}">
            <a class="dropdown-toggle" data-toggle="dropdown" aria-haspopup="true" aria-expanded="{{ request()->routeIs('author.salesnovels*') || request()->routeIs('author.salesmagazines*') || request()->routeIs('author.salesaudiobooks*') ? 'true' : 'false' }}">
                <i class="fa-solid fa-chart-line menu-icon"></i>
                <span>{{__('label.content_reports')}}</span>
            </a>
            <ul class="dropdown-menu side-submenu">
                <li class="side_line {{ request()->routeIs('author.salesnovels*') ? 'active' : '' }}">
                    <a href="{{ route('author.salesnovels.index') }}" class="dropdown-item">
                        <i class="fa-solid fa-book submenu-icon"></i>
                        <span>{{__('label.novel_sales')}}</span>
                    </a>
                </li>
                <li class="side_line {{ request()->routeIs('author.salesmagazines*') ? 'active' : '' }}">
                    <a href="{{ route('author.salesmagazines.index') }}" class="dropdown-item">
                        <i class="fa-solid fa-newspaper submenu-icon"></i>
                        <span>{{__('label.magazine_sales')}}</span>
                    </a>
                </li>
                <li class="side_line {{ request()->routeIs('author.salesaudiobooks*') ? 'active' : '' }}">
                    <a href="{{ route('author.salesaudiobooks.index') }}" class="dropdown-item">
                        <i class="fa-solid fa-headphones submenu-icon"></i>
                        <span>{{__('label.audiobook_sales')}}</span>
                    </a>
                </li>
            </ul>
        </li>
        <li class="side_line {{ request()->routeIs('author.withdrawal*') ? 'active' : '' }}">
            <a href="{{ route('author.withdrawal.index') }}">
                <i class="fa-solid fa-money-bill-transfer menu-icon"></i>
                <span>{{__('label.withdrawal_requests')}}</span>
            </a>
        </li>
        <li class="side_line {{ request()->routeIs('author.subscription_payout*') ? 'active' : '' }}">
            <a href="{{ route('author.subscription_payout.index') }}">
                <i class="fa-solid fa-hand-holding-dollar menu-icon"></i>
                <span>{{__('label.subscription_payout')}}</span>
            </a>
        </li>

        <li class="partition"><span>{{__('label.account')}}</span></li>
        <li>
            <a href="{{ route('author.logout') }}" onclick="event.preventDefault(); document.getElementById('logout-form').submit();">
                <i class="fa-solid fa-arrow-right-from-bracket menu-icon" style="color:#EF4444;"></i>
                <span style="color:#EF4444;">{{__('label.logout')}}</span>
            </a>
            <form id="logout-form" action="{{ route('author.logout') }}" method="GET" class="d-none">
                @csrf
            </form>
        </li>
    </ul>
</div>