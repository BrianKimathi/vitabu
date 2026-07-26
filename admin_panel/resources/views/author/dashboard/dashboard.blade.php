@extends('author.layout.page-app')
@section('page_title', __('label.dashboard'))
@section('tab_title', __('label.dashboard'))

@section('content')
@include('author.layout.sidebar')

<div class="right-content">
    @include('author.layout.header')

    <div class="body-content">
        <h1 class="page-title-sm">{{__('label.dashboard')}}</h1>

        <!-- Welcome Card -->
        <div class="card border-0 shadow-sm mb-4" style="border-radius:12px;background:linear-gradient(135deg,#4E45B8,#6C63FF);">
            <div class="card-body px-4 py-3">
                <div class="d-flex align-items-center">
                    <div style="width:42px;height:42px;border-radius:50%;overflow:hidden;border:2px solid rgba(255,255,255,0.3);background:rgba(255,255,255,0.15);display:flex;align-items:center;justify-content:center;flex-shrink:0;">
                        <i class="fa-solid fa-user text-white" style="font-size:16px;"></i>
                    </div>
                    <div class="ml-3 text-white" style="line-height:1.3;">
                        <div style="font-size:15px;font-weight:600;color:#fff;">
                            Welcome, {{ String_Cut($AuthorData['first_name'] . ' ' . $AuthorData['last_name'] ?? 'Guest', 25) }}
                        </div>
                        <div style="color:rgba(255,255,255,0.75);font-size:12.5px;margin-top:2px;">
                            <i class="fa-solid fa-envelope mr-1"></i> {{ $AuthorData['email'] ?? '' }}
                        </div>
                        <div style="color:rgba(255,255,255,0.6);font-size:12px;">
                            <i class="fa-solid fa-at mr-1"></i> {{ $AuthorData['user_name'] ?? '' }}
                        </div>
                    </div>
                </div>
            </div>
        </div>

        <!-- Content Stats -->
        <div class="row mb-3">
            <div class="col-12 mb-2">
                <div style="font-size:11px;font-weight:600;letter-spacing:0.5px;text-transform:uppercase;color:#9CA3AF;">
                    <i class="fa-solid fa-layer-group mr-1" style="color:#4E45B8;"></i> Your Content
                </div>
            </div>
            <div class="col-xl-4 col-sm-6 col-12 mb-3">
                <div class="card border-0 shadow-sm" style="border-radius:12px;">
                    <div class="card-body d-flex align-items-center px-3 py-3">
                        <div class="d-flex align-items-center justify-content-center rounded mr-3" style="width:40px;height:40px;background:#EEF0FF;flex-shrink:0;">
                            <i class="fa-solid fa-book" style="color:#4E45B8;font-size:16px;"></i>
                        </div>
                        <div>
                            <div style="font-size:18px;font-weight:700;color:#1F2937;line-height:1.2;">{{$NovelsCount ?? 0}}</div>
                            <div style="font-size:12px;color:#9CA3AF;">{{__('label.novels')}}</div>
                        </div>
                    </div>
                </div>
            </div>
            <div class="col-xl-4 col-sm-6 col-12 mb-3">
                <div class="card border-0 shadow-sm" style="border-radius:12px;">
                    <div class="card-body d-flex align-items-center px-3 py-3">
                        <div class="d-flex align-items-center justify-content-center rounded mr-3" style="width:40px;height:40px;background:#FFF0EE;flex-shrink:0;">
                            <i class="fa-solid fa-newspaper" style="color:#E54B4B;font-size:16px;"></i>
                        </div>
                        <div>
                            <div style="font-size:18px;font-weight:700;color:#1F2937;line-height:1.2;">{{$MagazinesCount ?? 0}}</div>
                            <div style="font-size:12px;color:#9CA3AF;">{{__('label.magazines')}}</div>
                        </div>
                    </div>
                </div>
            </div>
            <div class="col-xl-4 col-sm-6 col-12 mb-3">
                <div class="card border-0 shadow-sm" style="border-radius:12px;">
                    <div class="card-body d-flex align-items-center px-3 py-3">
                        <div class="d-flex align-items-center justify-content-center rounded mr-3" style="width:40px;height:40px;background:#FFF8E5;flex-shrink:0;">
                            <i class="fa-solid fa-headphones" style="color:#F5A623;font-size:16px;"></i>
                        </div>
                        <div>
                            <div style="font-size:18px;font-weight:700;color:#1F2937;line-height:1.2;">{{$AudioBooksCount ?? 0}}</div>
                            <div style="font-size:12px;color:#9CA3AF;">{{__('label.audiobooks')}}</div>
                        </div>
                    </div>
                </div>
            </div>
        </div>

        <!-- Earnings -->
        <div class="row mb-3">
            <div class="col-12 mb-2">
                <div style="font-size:11px;font-weight:600;letter-spacing:0.5px;text-transform:uppercase;color:#9CA3AF;">
                    <i class="fa-solid fa-chart-line mr-1" style="color:#4E45B8;"></i> Earnings &amp; Finances
                </div>
            </div>
            <div class="col-xl-3 col-sm-6 col-12 mb-3">
                <div class="card border-0 shadow-sm" style="border-radius:12px;">
                    <div class="card-body px-3 py-3">
                        <div style="font-size:11px;color:#9CA3AF;text-transform:uppercase;letter-spacing:0.3px;font-weight:600;">{{__('label.wallet_balance')}}</div>
                        <div style="font-size:18px;font-weight:700;color:#1F2937;margin-top:2px;">
                            {{ Currency_Code() . ' ' . No_Format($WalletBalance ?? 0) }}
                        </div>
                    </div>
                </div>
            </div>
            <div class="col-xl-3 col-sm-6 col-12 mb-3">
                <div class="card border-0 shadow-sm" style="border-radius:12px;">
                    <div class="card-body px-3 py-3">
                        <div style="font-size:11px;color:#9CA3AF;text-transform:uppercase;letter-spacing:0.3px;font-weight:600;">{{__('label.total_sales')}}</div>
                        <div style="font-size:18px;font-weight:700;color:#1F2937;margin-top:2px;">
                            {{ Currency_Code() . ' ' . No_Format($TotalGrossSales ?? 0) }}
                        </div>
                        <div style="font-size:10.5px;color:#D1D5DB;margin-top:1px;">Gross revenue</div>
                    </div>
                </div>
            </div>
            <div class="col-xl-3 col-sm-6 col-12 mb-3">
                <div class="card border-0 shadow-sm" style="border-radius:12px;">
                    <div class="card-body px-3 py-3">
                        <div style="font-size:11px;color:#9CA3AF;text-transform:uppercase;letter-spacing:0.3px;font-weight:600;">{{__('label.admin_commission')}}</div>
                        <div style="font-size:18px;font-weight:700;color:#E54B4B;margin-top:2px;">
                            {{ Currency_Code() . ' ' . No_Format($TotalCommissionDeducted ?? 0) }}
                        </div>
                        <div style="font-size:10.5px;color:#D1D5DB;margin-top:1px;">{{ No_Format($ActiveCommissionRate ?? 0) }}% platform fee</div>
                    </div>
                </div>
            </div>
            <div class="col-xl-3 col-sm-6 col-12 mb-3">
                <div class="card border-0 shadow-sm" style="border-radius:12px;border-left:3px solid #4E45B8;">
                    <div class="card-body px-3 py-3">
                        <div style="font-size:11px;color:#9CA3AF;text-transform:uppercase;letter-spacing:0.3px;font-weight:600;">{{__('label.total_earnings')}}</div>
                        <div style="font-size:18px;font-weight:700;color:#4E45B8;margin-top:2px;">
                            {{ Currency_Code() . ' ' . No_Format($TotalEarnings ?? 0) }}
                        </div>
                        <div style="font-size:10.5px;color:#D1D5DB;margin-top:1px;">{{__('label.after_commission')}}</div>
                    </div>
                </div>
            </div>
            <div class="col-xl-4 col-sm-6 col-12 mb-3">
                <div class="card border-0 shadow-sm" style="border-radius:12px;">
                    <div class="card-body px-3 py-3">
                        <div class="d-flex align-items-center">
                            <div class="mr-3" style="width:36px;height:36px;background:#EEF0FF;border-radius:8px;display:flex;align-items:center;justify-content:center;flex-shrink:0;">
                                <i class="fa-solid fa-book" style="color:#4E45B8;font-size:14px;"></i>
                            </div>
                            <div>
                                <div style="font-size:11px;color:#9CA3AF;">{{__('label.novel_earning')}}</div>
                                <div style="font-size:15px;font-weight:700;color:#1F2937;">
                                    {{ Currency_Code() . ' ' . No_Format($NovelEarnings ?? 0) }}
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
            <div class="col-xl-4 col-sm-6 col-12 mb-3">
                <div class="card border-0 shadow-sm" style="border-radius:12px;">
                    <div class="card-body px-3 py-3">
                        <div class="d-flex align-items-center">
                            <div class="mr-3" style="width:36px;height:36px;background:#FFF0EE;border-radius:8px;display:flex;align-items:center;justify-content:center;flex-shrink:0;">
                                <i class="fa-solid fa-newspaper" style="color:#E54B4B;font-size:14px;"></i>
                            </div>
                            <div>
                                <div style="font-size:11px;color:#9CA3AF;">{{__('label.magazine_earning')}}</div>
                                <div style="font-size:15px;font-weight:700;color:#1F2937;">
                                    {{ Currency_Code() . ' ' . No_Format($MagazineEarnings ?? 0) }}
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
            <div class="col-xl-4 col-sm-6 col-12 mb-3">
                <div class="card border-0 shadow-sm" style="border-radius:12px;">
                    <div class="card-body px-3 py-3">
                        <div class="d-flex align-items-center">
                            <div class="mr-3" style="width:36px;height:36px;background:#FFF8E5;border-radius:8px;display:flex;align-items:center;justify-content:center;flex-shrink:0;">
                                <i class="fa-solid fa-headphones" style="color:#F5A623;font-size:14px;"></i>
                            </div>
                            <div>
                                <div style="font-size:11px;color:#9CA3AF;">{{__('label.audio_book_earning')}}</div>
                                <div style="font-size:15px;font-weight:700;color:#1F2937;">
                                    {{ Currency_Code() . ' ' . No_Format($AudioBookEarnings ?? 0) }}
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>

        <!-- Most Read Content & Quick Links -->
        <div class="row">
            <div class="col-12 mb-2">
                <div style="font-size:11px;font-weight:600;letter-spacing:0.5px;text-transform:uppercase;color:#9CA3AF;">
                    <i class="fa-solid fa-fire mr-1" style="color:#4E45B8;"></i> Most Read Content
                </div>
            </div>
            <div class="col-12 col-xl-8 mb-3">
                <div class="card border-0 shadow-sm" style="border-radius:12px;">
                    <div class="card-body p-3">
                        <ul class="nav nav-pills mb-2" id="pills-tab" role="tablist" style="gap:3px;">
                            <li class="nav-item">
                                <a class="nav-link active" id="pills-novels-tab" data-toggle="pill" href="#pills-novels" role="tab" style="border-radius:6px;font-size:12px;font-weight:600;padding:4px 14px;background:#EEF0FF;color:#4E45B8;">{{__('label.novels')}}</a>
                            </li>
                            <li class="nav-item">
                                <a class="nav-link" id="pills-magazines-tab" data-toggle="pill" href="#pills-magazines" role="tab" style="border-radius:6px;font-size:12px;font-weight:600;padding:4px 14px;background:#F3F4F6;color:#6B7280;">{{__('label.magazines')}}</a>
                            </li>
                            <li class="nav-item">
                                <a class="nav-link" id="pills-audiobooks-tab" data-toggle="pill" href="#pills-audiobooks" role="tab" style="border-radius:6px;font-size:12px;font-weight:600;padding:4px 14px;background:#F3F4F6;color:#6B7280;">{{__('label.audiobooks')}}</a>
                            </li>
                        </ul>
                        <div class="tab-content" id="pills-tabContent">
                            <div class="tab-pane fade show active" id="pills-novels">
                                @forelse($most_read_novels ?? [] as $i => $item)
                                <div class="d-flex align-items-center py-1 border-bottom" style="border-color:#F9FAFB !important;">
                                    <span style="color:#D1D5DB;font-weight:600;font-size:12px;min-width:20px;">{{$i+1}}</span>
                                    <img src="{{$item['portrait_img'] ?? ''}}" class="rounded" style="width:28px;height:28px;object-fit:cover;margin:0 10px;">
                                    <div class="flex-grow-1" style="overflow:hidden;">
                                        <div style="font-size:12.5px;font-weight:500;color:#374151;white-space:nowrap;overflow:hidden;text-overflow:ellipsis;">{{$item['title']}}</div>
                                    </div>
                                    <div class="d-flex align-items-center ml-2">
                                        <i class="fa-solid fa-book-open-reader mr-1" style="color:#D1D5DB;font-size:11px;"></i>
                                        <span style="font-weight:600;font-size:12px;color:#4E45B8;">{{ No_Format($item['total_read'] ?? 0) }}</span>
                                    </div>
                                </div>
                                @empty
                                <div class="text-center py-3" style="color:#D1D5DB;font-size:13px;">No reads yet</div>
                                @endforelse
                            </div>
                            <div class="tab-pane fade" id="pills-magazines">
                                @forelse($most_read_magazines ?? [] as $i => $item)
                                <div class="d-flex align-items-center py-1 border-bottom" style="border-color:#F9FAFB !important;">
                                    <span style="color:#D1D5DB;font-weight:600;font-size:12px;min-width:20px;">{{$i+1}}</span>
                                    <img src="{{$item['portrait_img'] ?? ''}}" class="rounded" style="width:28px;height:28px;object-fit:cover;margin:0 10px;">
                                    <div class="flex-grow-1" style="overflow:hidden;">
                                        <div style="font-size:12.5px;font-weight:500;color:#374151;white-space:nowrap;overflow:hidden;text-overflow:ellipsis;">{{$item['title']}}</div>
                                    </div>
                                    <div class="d-flex align-items-center ml-2">
                                        <i class="fa-solid fa-book-open-reader mr-1" style="color:#D1D5DB;font-size:11px;"></i>
                                        <span style="font-weight:600;font-size:12px;color:#E54B4B;">{{ No_Format($item['total_read'] ?? 0) }}</span>
                                    </div>
                                </div>
                                @empty
                                <div class="text-center py-3" style="color:#D1D5DB;font-size:13px;">No reads yet</div>
                                @endforelse
                            </div>
                            <div class="tab-pane fade" id="pills-audiobooks">
                                @forelse($most_read_audio_books ?? [] as $i => $item)
                                <div class="d-flex align-items-center py-1 border-bottom" style="border-color:#F9FAFB !important;">
                                    <span style="color:#D1D5DB;font-weight:600;font-size:12px;min-width:20px;">{{$i+1}}</span>
                                    <img src="{{$item['portrait_img'] ?? ''}}" class="rounded" style="width:28px;height:28px;object-fit:cover;margin:0 10px;">
                                    <div class="flex-grow-1" style="overflow:hidden;">
                                        <div style="font-size:12.5px;font-weight:500;color:#374151;white-space:nowrap;overflow:hidden;text-overflow:ellipsis;">{{$item['title']}}</div>
                                    </div>
                                    <div class="d-flex align-items-center ml-2">
                                        <i class="fa-solid fa-headphones mr-1" style="color:#D1D5DB;font-size:11px;"></i>
                                        <span style="font-weight:600;font-size:12px;color:#F5A623;">{{ No_Format($item['total_played'] ?? 0) }}</span>
                                    </div>
                                </div>
                                @empty
                                <div class="text-center py-3" style="color:#D1D5DB;font-size:13px;">No plays yet</div>
                                @endforelse
                            </div>
                        </div>
                    </div>
                </div>
            </div>

            <!-- Quick Links -->
            <div class="col-12 col-xl-4 mb-3">
                <div class="card border-0 shadow-sm h-100" style="border-radius:12px;">
                    <div class="card-body p-3">
                        <div style="font-size:12px;font-weight:600;color:#374151;margin-bottom:12px;">
                            <i class="fa-solid fa-link mr-1" style="color:#4E45B8;"></i> Quick Links
                        </div>
                        <div class="d-flex flex-column" style="gap:6px;">
                            <a href="{{ route('author.salesnovels.index') }}" class="btn d-flex align-items-center" style="background:#EEF0FF;color:#4E45B8;font-weight:500;border-radius:8px;padding:8px 14px;font-size:12.5px;text-align:left;border:none;">
                                <i class="fa-solid fa-book mr-3"></i>
                                <span>{{__('label.novel_sales_report')}}</span>
                                <i class="fa-solid fa-chevron-right ml-auto" style="font-size:10px;"></i>
                            </a>
                            <a href="{{ route('author.salesmagazines.index') }}" class="btn d-flex align-items-center" style="background:#FFF0EE;color:#E54B4B;font-weight:500;border-radius:8px;padding:8px 14px;font-size:12.5px;text-align:left;border:none;">
                                <i class="fa-solid fa-newspaper mr-3"></i>
                                <span>{{__('label.magazine_sales_report')}}</span>
                                <i class="fa-solid fa-chevron-right ml-auto" style="font-size:10px;"></i>
                            </a>
                            <a href="{{ route('author.salesaudiobooks.index') }}" class="btn d-flex align-items-center" style="background:#FFF8E5;color:#F5A623;font-weight:500;border-radius:8px;padding:8px 14px;font-size:12.5px;text-align:left;border:none;">
                                <i class="fa-solid fa-headphones mr-3"></i>
                                <span>{{__('label.audio_book_sales_report')}}</span>
                                <i class="fa-solid fa-chevron-right ml-auto" style="font-size:10px;"></i>
                            </a>
                            <a href="{{ route('author.withdrawal.index') }}" class="btn d-flex align-items-center" style="background:#E8F5E9;color:#2E7D32;font-weight:500;border-radius:8px;padding:8px 14px;font-size:12.5px;text-align:left;border:none;">
                                <i class="fa-solid fa-money-bill-transfer mr-3"></i>
                                <span>{{__('label.withdrawal_request')}}</span>
                                <i class="fa-solid fa-chevron-right ml-auto" style="font-size:10px;"></i>
                            </a>
                        </div>
                    </div>
                </div>
            </div>
        </div>

    </div>
</div>
@endsection

@section('pagescript')
<script>
</script>
@endsection