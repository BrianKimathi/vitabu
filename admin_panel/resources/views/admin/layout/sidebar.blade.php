@php
    $authorRequestCount = \App\Models\Author_Request::where('status', 0)->count();
    $novelRequestCount = \App\Models\Novel::where('status', 0)->count();
    $magazineRequestCount = \App\Models\Magazine::where('status', 0)->count();
    $audioBookRequestCount = \App\Models\AudioBook::where('status', 0)->count();
    $role = Admin_Data()->role ?? 'admin';
@endphp
<div class="sidebar">
    <div class="side-head">
        <a href="{{ route('admin.dashboard') }}" class="side-logo">
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
        <li class="partition"><span>{{__('label.dashboard_and_report')}}</span></li>
        <li class="side_line {{ request()->routeIs('admin.dashboard*') ? 'active' : '' }}{{ request()->routeIs('admin.profile*') ? 'active' : '' }}">
            <a href="{{ route('admin.dashboard') }}">
                <i class="fa-solid fa-house menu-icon"></i>
                <span>{{__('label.dashboard')}}</span>
            </a>
        </li>

        @if(in_array($role, ['admin', 'accounts']))
        <li class="dropdown {{ request()->routeIs('admin.salesreport*') ? 'active' : '' }}">
            <a class="dropdown-toggle" data-toggle="dropdown" aria-haspopup="true" aria-expanded="{{ request()->routeIs('admin.salesreport*') || request()->routeIs('admin.financereport*') || request()->routeIs('admin.customerreport*') ? 'true' : 'false' }}">
                <i class="fa-solid fa-chart-bar menu-icon"></i>
                <span>{{__('label.reports_and_analytics')}}</span>
            </a>
            <ul class="dropdown-menu side-submenu">
                <li class="side_line {{ request()->routeIs('admin.salesreport*') ? 'active' : '' }}">
                    <a href="{{ route('admin.salesreport.index') }}" class="dropdown-item">
                        <i class="fa-solid fa-money-bill-trend-up submenu-icon"></i>
                        <span>{{__('label.sales_report')}}</span>
                    </a>
                </li>
                <li class="side_line {{ request()->routeIs('admin.financereport*') ? 'active' : '' }}">
                    <a href="{{ route('admin.financereport.index') }}" class="dropdown-item">
                        <i class="fa-solid fa-sack-dollar submenu-icon"></i>
                        <span>{{__('label.finance_report')}}</span>
                    </a>
                </li>
                <li class="side_line {{ request()->routeIs('admin.customerreport*') ? 'active' : '' }}">
                    <a href="{{ route('admin.customerreport.index') }}" class="dropdown-item">
                        <i class="fa-solid fa-users-line submenu-icon"></i>
                        <span>{{__('label.customer_report')}}</span>
                    </a>
                </li>
            </ul>
        </li>
        @elseif($role === 'editor')
        <li class="side_line {{ request()->routeIs('admin.customerreport*') ? 'active' : '' }}">
            <a href="{{ route('admin.customerreport.index') }}">
                <i class="fa-solid fa-users-line menu-icon"></i>
                <span>{{__('label.customer_report')}}</span>
            </a>
        </li>
        @endif

        @if(in_array($role, ['admin', 'editor']))
        <li class="partition"><span>{{__('label.basic_data')}}</span></li>
        <li class="side_line {{ request()->routeIs('admin.category*') ? 'active' : '' }}">
            <a href="{{ route('admin.category.index') }}">
                <i class="fa-solid fa-list menu-icon"></i>
                <span>{{__('label.categories')}}</span>
            </a>
        </li>
        <li class="side_line {{ request()->routeIs('admin.language*') ? 'active' : '' }}">
            <a href="{{ route('admin.language.index') }}">
                <i class="fa-solid fa-globe menu-icon"></i>
                <span>{{__('label.languages')}}</span>
            </a>
        </li>
        @endif

        @if(in_array($role, ['admin', 'editor']))
        <li class="partition"><span>{{__('label.users_and_authors')}}</span></li>
        <li class="dropdown {{ request()->routeIs('admin.user*') ? 'active' : '' }}{{ request()->routeIs('admin.subadmin*') ? 'active' : '' }}">
            <a class="dropdown-toggle" data-toggle="dropdown" aria-haspopup="true" aria-expanded="{{ request()->routeIs('admin.user*') || request()->routeIs('admin.subadmin*') ? 'true' : 'false' }}">
                <i class="fa-solid fa-users-gear menu-icon"></i>
                <span>{{__('label.user_management')}}</span>
            </a>
            <ul class="dropdown-menu side-submenu">
                <li class="side_line {{ request()->routeIs('admin.user*') ? 'active' : '' }}">
                    <a href="{{ route('admin.user.index') }}" class="dropdown-item">
                        <i class="fa-solid fa-users submenu-icon"></i>
                        <span>{{__('label.all_users')}}</span>
                    </a>
                </li>
                @if($role === 'admin')
                <li class="side_line {{ request()->routeIs('admin.subadmin*') ? 'active' : '' }}">
                    <a href="{{ route('admin.subadmin.index') }}" class="dropdown-item">
                        <i class="fa-solid fa-user-shield submenu-icon"></i>
                        <span>Sub-Admins</span>
                    </a>
                </li>
                @endif
            </ul>
        </li>

        <li class="dropdown {{ request()->routeIs('admin.author.*') ? 'active' : '' }} {{ request()->routeIs('admin.authorrequest.*') ? 'active' : '' }}">
            <a class="dropdown-toggle" data-toggle="dropdown" aria-haspopup="true" aria-expanded="{{ request()->routeIs('admin.author.*') || request()->routeIs('admin.authorrequest.*') ? 'true' : 'false' }}">
                <i class="fa-solid fa-user-tie menu-icon"></i>
                <span>{{__('label.author_management')}}</span>
            </a>
            <ul class="dropdown-menu side-submenu">
                <li class="side_line {{ request()->routeIs('admin.author.*') ? 'active' : '' }}">
                    <a href="{{ route('admin.author.index') }}" class="dropdown-item">
                        <i class="fa-solid fa-user-check submenu-icon"></i>
                        <span>{{__('label.author_list')}}</span>
                    </a>
                </li>
                <li class="side_line {{ request()->routeIs('admin.authorrequest*') ? 'active' : '' }}">
                    <a href="{{ route('admin.authorrequest.index') }}" class="dropdown-item">
                        <i class="fa-solid fa-user-clock submenu-icon"></i>
                        <span>{{__('label.author_requests')}}</span>
                        @if($authorRequestCount > 0)
                            <span class="badge badge-danger ml-2">{{ $authorRequestCount }}</span>
                        @endif
                    </a>
                </li>
            </ul>
        </li>
        @endif

        @if(in_array($role, ['admin', 'editor']))
        <li class="partition"><span>{{__('label.content_management')}}</span></li>
        <li class="dropdown {{ request()->routeIs('admin.novel*') ? 'active' : '' }}">
            <a class="dropdown-toggle" data-toggle="dropdown" aria-haspopup="true" aria-expanded="{{ request()->routeIs('admin.novels_request*') || request()->routeIs('admin.novels.*') || request()->routeIs('admin.novelsection*') ? 'true' : 'false' }}">
                <i class="fa-solid fa-book menu-icon"></i>
                <span>{{__('label.novels')}}</span>
            </a>
            <ul class="dropdown-menu side-submenu">
                <li class="side_line {{ request()->routeIs('admin.novels_request*') ? 'active' : '' }}">
                    <a href="{{ route('admin.novels_request.index') }}" class="dropdown-item">
                        <i class="fa-solid fa-clock submenu-icon"></i>
                        <span>{{__('label.novel_requests')}}</span>
                        @if($novelRequestCount > 0)
                            <span class="badge badge-danger ml-2">{{ $novelRequestCount }}</span>
                        @endif
                    </a>
                </li>
                <li class="side_line {{ request()->routeIs('admin.novels.*') ? 'active' : '' }}">
                    <a href="{{ route('admin.novels.index') }}" class="dropdown-item">
                        <i class="fa-solid fa-list submenu-icon"></i>
                        <span>{{__('label.novels_list')}}</span>
                    </a>
                </li>
                <li class="side_line {{ request()->routeIs('admin.novelsection*') ? 'active' : '' }}">
                    <a href="{{ route('admin.novelsection.index') }}" class="dropdown-item">
                        <i class="fa-solid fa-layer-group submenu-icon"></i>
                        <span>{{__('label.novel_sections')}}</span>
                    </a>
                </li>
            </ul>
        </li>
        <li class="dropdown {{ request()->routeIs('admin.magazine*') ? 'active' : '' }}">
            <a class="dropdown-toggle" data-toggle="dropdown" aria-haspopup="true" aria-expanded="{{ request()->routeIs('admin.magazines_request*') || request()->routeIs('admin.magazines.*') || request()->routeIs('admin.magazinessection*') ? 'true' : 'false' }}">
                <i class="fa-solid fa-newspaper menu-icon"></i>
                <span>{{__('label.magazines')}}</span>
            </a>
            <ul class="dropdown-menu side-submenu">
                <li class="side_line {{ request()->routeIs('admin.magazines_request*') ? 'active' : '' }}">
                    <a href="{{ route('admin.magazines_request.index') }}" class="dropdown-item">
                        <i class="fa-solid fa-clock submenu-icon"></i>
                        <span>{{__('label.magazine_requests')}}</span>
                        @if($magazineRequestCount > 0)
                            <span class="badge badge-danger ml-2">{{ $magazineRequestCount }}</span>
                        @endif
                    </a>
                </li>
                <li class="side_line {{ request()->routeIs('admin.magazines.*') ? 'active' : '' }}">
                    <a href="{{ route('admin.magazines.index') }}" class="dropdown-item">
                        <i class="fa-solid fa-list submenu-icon"></i>
                        <span>{{__('label.magazines_list')}}</span>
                    </a>
                </li>
                <li class="side_line {{ request()->routeIs('admin.magazinessection*') ? 'active' : '' }}">
                    <a href="{{ route('admin.magazinessection.index') }}" class="dropdown-item">
                        <i class="fa-solid fa-layer-group submenu-icon"></i>
                        <span>{{__('label.magazine_sections')}}</span>
                    </a>
                </li>
            </ul>
        </li>
        <li class="dropdown {{ request()->routeIs('admin.audio_book*') ? 'active' : '' }} {{ request()->routeIs('admin.audiobook*') ? 'active' : '' }}">
            <a class="dropdown-toggle" data-toggle="dropdown" aria-haspopup="true" aria-expanded="{{ request()->routeIs('admin.audio_books_request*') || request()->routeIs('admin.audiobooks.*') || request()->routeIs('admin.audiobooksection*') ? 'true' : 'false' }}">
                <i class="fa-solid fa-headphones menu-icon"></i>
                <span>{{__('label.audio_books')}}</span>
            </a>
            <ul class="dropdown-menu side-submenu">
                <li class="side_line {{ request()->routeIs('admin.audio_books_request*') ? 'active' : '' }}">
                    <a href="{{ route('admin.audio_books_request.index') }}" class="dropdown-item">
                        <i class="fa-solid fa-clock submenu-icon"></i>
                        <span>{{__('label.audiobook_requests')}}</span>
                        @if($audioBookRequestCount > 0)
                            <span class="badge badge-danger ml-2">{{ $audioBookRequestCount }}</span>
                        @endif
                    </a>
                </li>
                <li class="side_line {{ request()->routeIs('admin.audiobooks.*') ? 'active' : '' }}">
                    <a href="{{ route('admin.audiobooks.index') }}" class="dropdown-item">
                        <i class="fa-solid fa-list submenu-icon"></i>
                        <span>{{__('label.audiobooks_list')}}</span>
                    </a>
                </li>
                <li class="side_line {{ request()->routeIs('admin.audiobooksection*') ? 'active' : '' }}">
                    <a href="{{ route('admin.audiobooksection.index') }}" class="dropdown-item">
                        <i class="fa-solid fa-layer-group submenu-icon"></i>
                        <span>{{__('label.audiobook_sections')}}</span>
                    </a>
                </li>
            </ul>
        </li>
        @endif

        @if(in_array($role, ['admin', 'editor']))
        <li class="partition"><span>{{__('label.user_interaction')}}</span></li>
        <li class="side_line {{ request()->routeIs('admin.reviews*') ? 'active' : '' }}">
            <a href="{{ route('admin.reviews.index') }}">
                <i class="fa-solid fa-comment-dots menu-icon"></i>
                <span>{{__('label.reviews_and_ratings')}}</span>
            </a>
        </li>
        <li class="side_line {{ request()->routeIs('admin.notification.*') ? 'active' : '' }}">
            <a href="{{ route('admin.notification.index') }}">
                <i class="fa-solid fa-bell menu-icon"></i>
                <span>{{__('label.notifications')}}</span>
            </a>
        </li>
        <li class="side_line {{ request()->routeIs('admin.contact_us.*') ? 'active' : '' }}">
            <a href="{{ route('admin.contact_us.index') }}">
                <i class="fa-solid fa-phone menu-icon"></i>
                <span>{{__('label.contact_messages')}}</span>
            </a>
        </li>
        @endif

        @if(in_array($role, ['admin', 'accounts']))
        <li class="partition"><span>{{__('label.finance_and_monetization')}}</span></li>
        <li class="side_line {{ request()->routeIs('admin.coupon.*') ? 'active' : '' }}">
            <a href="{{ route('admin.coupon.index') }}">
                <i class="fa-solid fa-ticket menu-icon"></i>
                <span>{{__('label.coupons_and_discounts')}}</span>
            </a>
        </li>
        <li class="side_line {{ request()->routeIs('admin.tax.*') ? 'active' : '' }}">
            <a href="{{ route('admin.tax.index') }}">
                <i class="fa-solid fa-percent menu-icon"></i>
                <span>{{__('label.tax_management')}}</span>
            </a>
        </li>
        <li class="dropdown {{ request()->routeIs('admin.salesnovels*') ? 'active' : '' }}{{ request()->routeIs('admin.salesmagazines*') ? 'active' : '' }}{{ request()->routeIs('admin.salesaudiobooks*') ? 'active' : '' }}">
            <a class="dropdown-toggle" data-toggle="dropdown" aria-haspopup="true" aria-expanded="{{ request()->routeIs('admin.salesnovels*') || request()->routeIs('admin.salesmagazines*') || request()->routeIs('admin.salesaudiobooks*') ? 'true' : 'false' }}">
                <i class="fa-solid fa-chart-line menu-icon"></i>
                <span>{{__('label.content_reports')}}</span>
            </a>
            <ul class="dropdown-menu side-submenu">
                <li class="side_line {{ request()->routeIs('admin.salesnovels*') ? 'active' : '' }}">
                    <a href="{{ route('admin.salesnovels.index') }}" class="dropdown-item">
                        <i class="fa-solid fa-book submenu-icon"></i>
                        <span>{{__('label.novel_sales')}}</span>
                    </a>
                </li>
                <li class="side_line {{ request()->routeIs('admin.salesmagazines*') ? 'active' : '' }}">
                    <a href="{{ route('admin.salesmagazines.index') }}" class="dropdown-item">
                        <i class="fa-solid fa-newspaper submenu-icon"></i>
                        <span>{{__('label.magazine_sales')}}</span>
                    </a>
                </li>
                <li class="side_line {{ request()->routeIs('admin.salesaudiobooks*') ? 'active' : '' }}">
                    <a href="{{ route('admin.salesaudiobooks.index') }}" class="dropdown-item">
                        <i class="fa-solid fa-headphones submenu-icon"></i>
                        <span>{{__('label.audiobook_sale')}}</span>
                    </a>
                </li>
            </ul>
        </li>
        <li class="dropdown {{ request()->routeIs('admin.plan*') ? 'active' : '' }}{{ request()->routeIs('admin.transaction*') ? 'active' : '' }}{{ request()->routeIs('admin.subscription_payout*') ? 'active' : '' }}">
            <a class="dropdown-toggle" data-toggle="dropdown" aria-haspopup="true" aria-expanded="{{ request()->routeIs('admin.plan*') || request()->routeIs('admin.transaction*') || request()->routeIs('admin.subscription_payout*') ? 'true' : 'false' }}">
                <i class="fa-solid fa-file-contract menu-icon"></i>
                <span>{{__('label.subscriptions')}}</span>
            </a>
            <ul class="dropdown-menu side-submenu">
                <li class="side_line {{ request()->routeIs('admin.plan*') ? 'active' : '' }}">
                    <a href="{{ route('admin.plan.index') }}" class="dropdown-item">
                        <i class="fa-solid fa-layer-group submenu-icon"></i>
                        <span>{{__('label.plan')}}</span>
                    </a>
                </li>
                <li class="side_line {{ request()->routeIs('admin.transaction*') ? 'active' : '' }}">
                    <a href="{{ route('admin.transaction.index') }}" class="dropdown-item">
                        <i class="fa-solid fa-wallet submenu-icon"></i>
                        <span>{{__('label.transaction')}}</span>
                    </a>
                </li>
                <li class="side_line {{ request()->routeIs('admin.subscription_payout*') ? 'active' : '' }}">
                    <a href="{{ route('admin.subscription_payout.index') }}" class="dropdown-item">
                        <i class="fa-solid fa-hand-holding-dollar submenu-icon"></i>
                        <span>{{__('label.subscription_payout')}}</span>
                    </a>
                </li>
            </ul>
        </li>
        <li class="side_line {{ request()->routeIs('admin.withdrawal*') ? 'active' : '' }}">
            <a href="{{ route('admin.withdrawal.index') }}">
                <i class="fa-solid fa-money-bill-transfer menu-icon"></i>
                <span>{{__('label.withdrawal_requests')}}</span>
            </a>
        </li>
        @endif

        <li class="partition"><span>{{__('label.configuration_and_settings')}}</span></li>

        @if(in_array($role, ['admin', 'editor']))
        <li class="side_line {{ request()->routeIs('admin.homesection*') ? 'active' : '' }}">
            <a href="{{ route('admin.homesection.index') }}">
                <i class="fa-solid fa-chart-bar menu-icon"></i>
                <span>{{__('label.home_page_section')}}</span>
            </a>
        </li>
        @endif

        @if(in_array($role, ['admin', 'accounts']))
        <li class="side_line {{ request()->routeIs('admin.appsetting*') ? 'active' : '' }}">
            <a href="{{ route('admin.appsetting.index') }}">
                <i class="fa-solid fa-gear menu-icon"></i>
                <span>{{__('label.app_settings')}}</span>
            </a>
        </li>
        @endif

        @if(in_array($role, ['admin', 'editor', 'accounts']))
        <li class="side_line {{ request()->routeIs('admin.pages*') ? 'active' : '' }}">
            <a href="{{ route('admin.pages.index') }}">
                <i class="fa-solid fa-book-open-reader menu-icon"></i>
                <span>{{__('label.pages')}}</span>
            </a>
        </li>
        @endif

        @if(in_array($role, ['admin', 'editor']))
        <li class="side_line {{ request()->routeIs('admin.panelsetting*') ? 'active' : '' }}">
            <a href="{{ route('admin.panelsetting.index') }}">
                <i class="fa-solid fa-palette menu-icon"></i>
                <span>{{__('label.panel_settings')}}</span>
            </a>
        </li>
        @endif

        @if(in_array($role, ['admin', 'accounts']))
        <li class="side_line {{ request()->routeIs('admin.payment*') ? 'active' : '' }}">
            <a href="{{ route('admin.payment.index') }}">
                <i class="fa-solid fa-money-bill-wave menu-icon"></i>
                <span>{{__('label.payment_settings')}}</span>
            </a>
        </li>
        <li class="side_line {{ request()->routeIs('admin.admob*') ? 'active' : '' }}">
            <a href="{{ route('admin.admob.index') }}">
                <i class="fa-brands fa-google menu-icon"></i>
                <span>{{__('label.admob_integration')}}</span>
            </a>
        </li>
        <li class="side_line {{ request()->routeIs('admin.notificationconfigurations*') ? 'active' : '' }}">
            <a href="{{ route('admin.notificationconfigurations.index') }}">
                <i class="fa-solid fa-bell menu-icon"></i>
                <span>{{__('label.notification_configurations')}}</span>
            </a>
        </li>
        @endif

        @if(in_array($role, ['admin']))
        <li class="side_line {{ request()->routeIs('admin.system.setting*') ? 'active' : '' }}">
            <a href="{{ route('admin.system.setting.index') }}">
                <i class="fa-solid fa-screwdriver-wrench menu-icon"></i>
                <span>{{__('label.system_settings')}}</span>
            </a>
        </li>
        @endif

        <li class="partition" style="margin-top:24px;"><span>{{__('label.account')}}</span></li>
        <li>
            <a href="{{ route('admin.logout') }}" onclick="event.preventDefault(); document.getElementById('logout-form').submit();">
                <i class="fa-solid fa-arrow-right-from-bracket menu-icon" style="color:#EF4444;"></i>
                <span style="color:#EF4444;">{{__('label.logout')}}</span>
            </a>
            <form id="logout-form" action="{{ route('admin.logout') }}" method="GET" class="d-none">
                @csrf
            </form>
        </li>
    </ul>
</div>