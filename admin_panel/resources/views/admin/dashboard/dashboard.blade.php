@extends('admin.layout.page-app')
@section('page_title', __('label.dashboard'))
@section('tab_title', __('label.dashboard'))

@section('content')
@include('admin.layout.sidebar')

<div class="right-content">
    @include('admin.layout.header')

    <div class="body-content">
        <!-- mobile title -->
        <h1 class="page-title-sm">{{__('label.dashboard')}}</h1>

        <!-- ============================================================
             SECTION 1: Users & Authors Overview
        ============================================================ -->
        <div class="row">
            <div class="col-12 mb-3">
                <h5 class="text-muted" style="font-weight:600;font-size:13px;letter-spacing:0.5px;text-transform:uppercase;">
                    <i class="fa-solid fa-users mr-2" style="color:#4E45B8;"></i>Users &amp; Authors
                </h5>
            </div>
            <div class="col-xl-3 col-sm-6 col-12 mb-3">
                <div class="card border-0 shadow-sm" style="border-radius:14px;">
                    <div class="card-body d-flex align-items-center py-3 px-4">
                        <div class="d-flex align-items-center justify-content-center rounded-circle mr-3" style="width:48px;height:48px;background:#EEF0FF;">
                            <i class="fa-solid fa-users" style="color:#4E45B8;font-size:20px;"></i>
                        </div>
                        <div>
                            <h4 class="mb-0 font-weight-bold" style="font-size:22px;color:#1F2937;">{{No_Format($UserCount ?? 0)}}</h4>
                            <span class="text-muted" style="font-size:13px;">{{__('label.users')}}</span>
                        </div>
                    </div>
                </div>
            </div>
            <div class="col-xl-3 col-sm-6 col-12 mb-3">
                <div class="card border-0 shadow-sm" style="border-radius:14px;">
                    <div class="card-body d-flex align-items-center py-3 px-4">
                        <div class="d-flex align-items-center justify-content-center rounded-circle mr-3" style="width:48px;height:48px;background:#FFF0EE;">
                            <i class="fa-solid fa-user-tie" style="color:#E54B4B;font-size:20px;"></i>
                        </div>
                        <div>
                            <h4 class="mb-0 font-weight-bold" style="font-size:22px;color:#1F2937;">{{No_Format($AuthorCount ?? 0)}}</h4>
                            <span class="text-muted" style="font-size:13px;">{{__('label.authors')}}</span>
                        </div>
                    </div>
                </div>
            </div>
            <div class="col-xl-3 col-sm-6 col-12 mb-3">
                <div class="card border-0 shadow-sm" style="border-radius:14px;">
                    <div class="card-body d-flex align-items-center py-3 px-4">
                        <div class="d-flex align-items-center justify-content-center rounded-circle mr-3" style="width:48px;height:48px;background:#FFF8E5;">
                            <i class="fa-solid fa-user-clock" style="color:#F5A623;font-size:20px;"></i>
                        </div>
                        <div>
                            <h4 class="mb-0 font-weight-bold" style="font-size:22px;color:#1F2937;">{{No_Format($AuthorRequestCount ?? 0)}}</h4>
                            <span class="text-muted" style="font-size:13px;">{{__('label.author_request')}}</span>
                        </div>
                    </div>
                </div>
            </div>
            <div class="col-xl-3 col-sm-6 col-12 mb-3">
                <div class="card border-0 shadow-sm" style="border-radius:14px;">
                    <div class="card-body d-flex align-items-center py-3 px-4">
                        <div class="d-flex align-items-center justify-content-center rounded-circle mr-3" style="width:48px;height:48px;background:#E8F5E9;">
                            <i class="fa-solid fa-arrow-trend-up" style="color:#2E7D32;font-size:20px;"></i>
                        </div>
                        <div>
                            <h4 class="mb-0 font-weight-bold" style="font-size:22px;color:#1F2937;">{{No_Format($AuthorRequestCount + $NovelRequestCount + $MagazineRequestCount + $AudioBookRequestCount)}}</h4>
                            <span class="text-muted" style="font-size:13px;">Pending Requests</span>
                        </div>
                    </div>
                </div>
            </div>
        </div>

        <!-- ============================================================
             SECTION 2: Content Overview
        ============================================================ -->
        <div class="row mt-2">
            <div class="col-12 mb-3">
                <h5 class="text-muted" style="font-weight:600;font-size:13px;letter-spacing:0.5px;text-transform:uppercase;">
                    <i class="fa-solid fa-layer-group mr-2" style="color:#4E45B8;"></i>Content Overview
                </h5>
            </div>
            <div class="col-xl-3 col-sm-6 col-12 mb-3">
                <div class="card border-0 shadow-sm" style="border-radius:14px;">
                    <div class="card-body d-flex align-items-center py-3 px-4">
                        <div class="d-flex align-items-center justify-content-center rounded-circle mr-3" style="width:48px;height:48px;background:#EEF0FF;">
                            <i class="fa-solid fa-book" style="color:#4E45B8;font-size:20px;"></i>
                        </div>
                        <div>
                            <h4 class="mb-0 font-weight-bold" style="font-size:22px;color:#1F2937;">{{No_Format($NovelsCount ?? 0)}}</h4>
                            <span class="text-muted" style="font-size:13px;">{{__('label.novels')}}</span>
                            @if(($NovelRequestCount ?? 0) > 0)
                                <span class="badge badge-warning ml-1" style="font-size:10px;">+{{$NovelRequestCount}} requests</span>
                            @endif
                        </div>
                    </div>
                </div>
            </div>
            <div class="col-xl-3 col-sm-6 col-12 mb-3">
                <div class="card border-0 shadow-sm" style="border-radius:14px;">
                    <div class="card-body d-flex align-items-center py-3 px-4">
                        <div class="d-flex align-items-center justify-content-center rounded-circle mr-3" style="width:48px;height:48px;background:#FFF0EE;">
                            <i class="fa-solid fa-newspaper" style="color:#E54B4B;font-size:20px;"></i>
                        </div>
                        <div>
                            <h4 class="mb-0 font-weight-bold" style="font-size:22px;color:#1F2937;">{{No_Format($MagazinesCount ?? 0)}}</h4>
                            <span class="text-muted" style="font-size:13px;">{{__('label.magazines')}}</span>
                            @if(($MagazineRequestCount ?? 0) > 0)
                                <span class="badge badge-warning ml-1" style="font-size:10px;">+{{$MagazineRequestCount}} requests</span>
                            @endif
                        </div>
                    </div>
                </div>
            </div>
            <div class="col-xl-3 col-sm-6 col-12 mb-3">
                <div class="card border-0 shadow-sm" style="border-radius:14px;">
                    <div class="card-body d-flex align-items-center py-3 px-4">
                        <div class="d-flex align-items-center justify-content-center rounded-circle mr-3" style="width:48px;height:48px;background:#FFF8E5;">
                            <i class="fa-solid fa-headphones" style="color:#F5A623;font-size:20px;"></i>
                        </div>
                        <div>
                            <h4 class="mb-0 font-weight-bold" style="font-size:22px;color:#1F2937;">{{No_Format($AudioBooksCount ?? 0)}}</h4>
                            <span class="text-muted" style="font-size:13px;">{{__('label.audiobooks')}}</span>
                            @if(($AudioBookRequestCount ?? 0) > 0)
                                <span class="badge badge-warning ml-1" style="font-size:10px;">+{{$AudioBookRequestCount}} requests</span>
                            @endif
                        </div>
                    </div>
                </div>
            </div>
            <div class="col-xl-3 col-sm-6 col-12 mb-3">
                <div class="card border-0 shadow-sm" style="border-radius:14px;">
                    <div class="card-body d-flex align-items-center py-3 px-4">
                        <div class="d-flex align-items-center justify-content-center rounded-circle mr-3" style="width:48px;height:48px;background:#E8F5E9;">
                            <i class="fa-solid fa-list" style="color:#2E7D32;font-size:20px;"></i>
                        </div>
                        <div>
                            <h4 class="mb-0 font-weight-bold" style="font-size:22px;color:#1F2937;">{{No_Format($CategoryCount ?? 0)}}</h4>
                            <span class="text-muted" style="font-size:13px;">{{__('label.categories')}}</span>
                        </div>
                    </div>
                </div>
            </div>
        </div>

        <!-- ============================================================
             SECTION 3: Sales & Earnings
        ============================================================ -->
        <div class="row mt-2">
            <div class="col-12 mb-3">
                <h5 class="text-muted" style="font-weight:600;font-size:13px;letter-spacing:0.5px;text-transform:uppercase;">
                    <i class="fa-solid fa-chart-line mr-2" style="color:#4E45B8;"></i>Sales &amp; Earnings ({{$setting_data['currency_code']}})
                </h5>
            </div>
            <div class="col-xl-3 col-sm-6 col-12 mb-3">
                <div class="card border-0 shadow-sm" style="border-radius:14px;">
                    <div class="card-body py-3 px-4">
                        <div class="d-flex justify-content-between align-items-center mb-2">
                            <span class="text-muted" style="font-size:13px;">{{__('label.novel_sales')}}</span>
                            <span class="badge badge-primary" style="background:#EEF0FF;color:#4E45B8;font-size:11px;">{{No_Format($NovelSalesCount ?? 0)}} sales</span>
                        </div>
                        <h4 class="mb-0 font-weight-bold" style="font-size:20px;color:#1F2937;">{{No_Format($novel_earning ?? 0)}}</h4>
                    </div>
                </div>
            </div>
            <div class="col-xl-3 col-sm-6 col-12 mb-3">
                <div class="card border-0 shadow-sm" style="border-radius:14px;">
                    <div class="card-body py-3 px-4">
                        <div class="d-flex justify-content-between align-items-center mb-2">
                            <span class="text-muted" style="font-size:13px;">{{__('label.magazine_sales')}}</span>
                            <span class="badge badge-primary" style="background:#FFF0EE;color:#E54B4B;font-size:11px;">{{No_Format($MagazinesSalesCount ?? 0)}} sales</span>
                        </div>
                        <h4 class="mb-0 font-weight-bold" style="font-size:20px;color:#1F2937;">{{No_Format($magazine_earning ?? 0)}}</h4>
                    </div>
                </div>
            </div>
            <div class="col-xl-3 col-sm-6 col-12 mb-3">
                <div class="card border-0 shadow-sm" style="border-radius:14px;">
                    <div class="card-body py-3 px-4">
                        <div class="d-flex justify-content-between align-items-center mb-2">
                            <span class="text-muted" style="font-size:13px;">{{__('label.audio_books_sales')}}</span>
                            <span class="badge badge-primary" style="background:#FFF8E5;color:#F5A623;font-size:11px;">{{No_Format($AudioBooksSalesCount ?? 0)}} sales</span>
                        </div>
                        <h4 class="mb-0 font-weight-bold" style="font-size:20px;color:#1F2937;">{{No_Format($audio_book_earning ?? 0)}}</h4>
                    </div>
                </div>
            </div>
            <div class="col-xl-3 col-sm-6 col-12 mb-3">
                <div class="card border-0 shadow-sm" style="border-radius:14px;">
                    <div class="card-body py-3 px-4">
                        <div class="d-flex justify-content-between align-items-center mb-2">
                            <span class="text-muted" style="font-size:13px;">Total Revenue</span>
                            <span class="badge badge-primary" style="background:#E8F5E9;color:#2E7D32;font-size:11px;">All time</span>
                        </div>
                        <h4 class="mb-0 font-weight-bold" style="font-size:20px;color:#1F2937;">{{No_Format($total_earning ?? 0)}}</h4>
                    </div>
                </div>
            </div>
            <div class="col-xl-3 col-sm-6 col-12 mb-3">
                <div class="card border-0 shadow-sm" style="border-radius:14px;border-left:3px solid #4E45B8;">
                    <div class="card-body py-3 px-4">
                        <span class="text-muted" style="font-size:13px;">{{__('label.admin_earning')}}</span>
                        <h4 class="mb-0 font-weight-bold" style="font-size:20px;color:#1F2937;">{{No_Format($admin_earning ?? 0)}}</h4>
                        <small class="text-muted">Commission: {{ No_Format($ActiveCommissionRate ?? 0) }}%</small>
                    </div>
                </div>
            </div>
            <div class="col-xl-3 col-sm-6 col-12 mb-3">
                <div class="card border-0 shadow-sm" style="border-radius:14px;border-left:3px solid #E54B4B;">
                    <div class="card-body py-3 px-4">
                        <span class="text-muted" style="font-size:13px;">{{__('label.author_earning')}}</span>
                        <h4 class="mb-0 font-weight-bold" style="font-size:20px;color:#1F2937;">{{No_Format($author_earning ?? 0)}}</h4>
                        <small class="text-muted">Authors' share</small>
                    </div>
                </div>
            </div>
        </div>

        <!-- ============================================================
             SECTION 4: Chart + Best Category
        ============================================================ -->
        <div class="row mt-3">
            <div class="col-12 col-xl-8 mb-3">
                <div class="card border-0 shadow-sm" style="border-radius:14px;">
                    <div class="card-body p-4">
                        <div class="d-flex justify-content-between align-items-center mb-3">
                            <h6 class="mb-0 font-weight-bold" style="color:#1F2937;">
                                <i class="fa-solid fa-chart-column mr-2" style="color:#4E45B8;"></i>
                                {{__('label.join_users_&_author_statistice')}}
                            </h6>
                            <div class="btn-group btn-group-sm">
                                <button id="year" class="btn btn-sm" style="background:#EEF0FF;color:#4E45B8;border:none;border-radius:8px 0 0 8px;font-weight:600;">{{__('label.this_year')}}</button>
                                <button id="month" class="btn btn-sm" style="background:#F3F4F6;color:#6B7280;border:none;border-radius:0 8px 8px 0;font-weight:600;">{{__('label.this_month')}}</button>
                            </div>
                        </div>
                        <div id="User_Author_Chart"></div>
                    </div>
                </div>
            </div>
            <div class="col-12 col-xl-4 mb-3">
                <div class="card border-0 shadow-sm" style="border-radius:14px;height:100%;">
                    <div class="card-body p-4">
                        <div class="d-flex justify-content-between align-items-center mb-3">
                            <h6 class="mb-0 font-weight-bold" style="color:#1F2937;">
                                <i class="fa-solid fa-table-cells-large mr-2" style="color:#4E45B8;"></i>
                                {{__('label.best_category')}}
                            </h6>
                            <a href="{{ route('admin.category.index') }}" style="color:#4E45B8;font-size:13px;font-weight:600;">{{__('label.view_all')}}</a>
                        </div>
                        <div class="row">
                            @forelse($best_category ?? [] as $cat)
                            <div class="col-6 mb-2">
                                <div style="position:relative;border-radius:10px;overflow:hidden;height:80px;">
                                    <img src="{{$cat['image'] ?? ''}}" style="width:100%;height:100%;object-fit:cover;filter:brightness(0.6);">
                                    <div style="position:absolute;top:50%;left:50%;transform:translate(-50%,-50%);color:white;font-weight:700;font-size:13px;text-align:center;width:90%;text-shadow:0 1px 4px rgba(0,0,0,0.3);">
                                        {{$cat['name']}}
                                    </div>
                                </div>
                            </div>
                            @empty
                            <div class="col-12 text-center text-muted py-4">No categories yet</div>
                            @endforelse
                        </div>
                    </div>
                </div>
            </div>
        </div>

        <!-- ============================================================
             SECTION 5: Most Read Content
        ============================================================ -->
        <div class="row mt-2">
            <div class="col-12 mb-3">
                <h5 class="text-muted" style="font-weight:600;font-size:13px;letter-spacing:0.5px;text-transform:uppercase;">
                    <i class="fa-solid fa-fire mr-2" style="color:#4E45B8;"></i>{{__('label.most_read_novels_&_magazines_&_audiobooks')}}
                </h5>
            </div>
            <div class="col-12">
                <div class="card border-0 shadow-sm" style="border-radius:14px;">
                    <div class="card-body p-3">
                        <ul class="nav nav-pills mb-3" id="readTabs" role="tablist" style="gap:4px;">
                            <li class="nav-item">
                                <a class="nav-link active" id="read-novels-tab" data-toggle="pill" href="#read-novels" role="tab" style="border-radius:8px;font-size:13px;font-weight:600;padding:6px 16px;background:#EEF0FF;color:#4E45B8;" aria-selected="true">{{__('label.novels')}}</a>
                            </li>
                            <li class="nav-item">
                                <a class="nav-link" id="read-magazines-tab" data-toggle="pill" href="#read-magazines" role="tab" style="border-radius:8px;font-size:13px;font-weight:600;padding:6px 16px;background:#F3F4F6;color:#6B7280;">{{__('label.magazines')}}</a>
                            </li>
                            <li class="nav-item">
                                <a class="nav-link" id="read-audiobooks-tab" data-toggle="pill" href="#read-audiobooks" role="tab" style="border-radius:8px;font-size:13px;font-weight:600;padding:6px 16px;background:#F3F4F6;color:#6B7280;">{{__('label.audiobooks')}}</a>
                            </li>
                        </ul>
                        <div class="tab-content">
                            <div class="tab-pane fade show active" id="read-novels">
                                @forelse($most_read_novels ?? [] as $i => $item)
                                <div class="d-flex align-items-center py-2 border-bottom" style="border-color:#F3F4F6 !important;">
                                    <span class="mr-3 font-weight-bold" style="color:#9CA3AF;min-width:24px;">{{$i+1}}</span>
                                    <img src="{{$item['portrait_img'] ?? ''}}" class="rounded" style="width:36px;height:36px;object-fit:cover;margin-right:12px;">
                                    <div class="flex-grow-1" style="overflow:hidden;">
                                        <div style="font-size:14px;font-weight:600;color:#1F2937;white-space:nowrap;overflow:hidden;text-overflow:ellipsis;">{{$item['title']}}</div>
                                    </div>
                                    <div class="d-flex align-items-center ml-2">
                                        <i class="fa-solid fa-book-open-reader mr-1" style="color:#9CA3AF;font-size:13px;"></i>
                                        <span style="font-weight:600;color:#4E45B8;">{{ No_Format($item['total_read'] ?? 0) }}</span>
                                    </div>
                                </div>
                                @empty
                                <div class="text-center text-muted py-4">No data yet</div>
                                @endforelse
                            </div>
                            <div class="tab-pane fade" id="read-magazines">
                                @forelse($most_read_magazines ?? [] as $i => $item)
                                <div class="d-flex align-items-center py-2 border-bottom" style="border-color:#F3F4F6 !important;">
                                    <span class="mr-3 font-weight-bold" style="color:#9CA3AF;min-width:24px;">{{$i+1}}</span>
                                    <img src="{{$item['portrait_img'] ?? ''}}" class="rounded" style="width:36px;height:36px;object-fit:cover;margin-right:12px;">
                                    <div class="flex-grow-1" style="overflow:hidden;">
                                        <div style="font-size:14px;font-weight:600;color:#1F2937;white-space:nowrap;overflow:hidden;text-overflow:ellipsis;">{{$item['title']}}</div>
                                    </div>
                                    <div class="d-flex align-items-center ml-2">
                                        <i class="fa-solid fa-book-open-reader mr-1" style="color:#9CA3AF;font-size:13px;"></i>
                                        <span style="font-weight:600;color:#E54B4B;">{{ No_Format($item['total_read'] ?? 0) }}</span>
                                    </div>
                                </div>
                                @empty
                                <div class="text-center text-muted py-4">No data yet</div>
                                @endforelse
                            </div>
                            <div class="tab-pane fade" id="read-audiobooks">
                                @forelse($most_read_audio_books ?? [] as $i => $item)
                                <div class="d-flex align-items-center py-2 border-bottom" style="border-color:#F3F4F6 !important;">
                                    <span class="mr-3 font-weight-bold" style="color:#9CA3AF;min-width:24px;">{{$i+1}}</span>
                                    <img src="{{$item['portrait_img'] ?? ''}}" class="rounded" style="width:36px;height:36px;object-fit:cover;margin-right:12px;">
                                    <div class="flex-grow-1" style="overflow:hidden;">
                                        <div style="font-size:14px;font-weight:600;color:#1F2937;white-space:nowrap;overflow:hidden;text-overflow:ellipsis;">{{$item['title']}}</div>
                                    </div>
                                    <div class="d-flex align-items-center ml-2">
                                        <i class="fa-solid fa-headphones mr-1" style="color:#9CA3AF;font-size:13px;"></i>
                                        <span style="font-weight:600;color:#F5A623;">{{ No_Format($item['total_played'] ?? 0) }}</span>
                                    </div>
                                </div>
                                @empty
                                <div class="text-center text-muted py-4">No data yet</div>
                                @endforelse
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>

        <!-- ============================================================
             SECTION 6: Best Selling Content
        ============================================================ -->
        <div class="row mt-3">
            <div class="col-12 mb-3">
                <h5 class="text-muted" style="font-weight:600;font-size:13px;letter-spacing:0.5px;text-transform:uppercase;">
                    <i class="fa-solid fa-trophy mr-2" style="color:#4E45B8;"></i>{{__('label.best_selling_novels_&_magazines_&_audiobooks')}}
                </h5>
            </div>
            <div class="col-12">
                <div class="card border-0 shadow-sm" style="border-radius:14px;">
                    <div class="card-body p-3">
                        <ul class="nav nav-pills mb-3" id="sellTabs" role="tablist" style="gap:4px;">
                            <li class="nav-item">
                                <a class="nav-link active" id="sell-novels-tab" data-toggle="pill" href="#sell-novels" role="tab" style="border-radius:8px;font-size:13px;font-weight:600;padding:6px 16px;background:#EEF0FF;color:#4E45B8;">{{__('label.novels')}}</a>
                            </li>
                            <li class="nav-item">
                                <a class="nav-link" id="sell-magazines-tab" data-toggle="pill" href="#sell-magazines" role="tab" style="border-radius:8px;font-size:13px;font-weight:600;padding:6px 16px;background:#F3F4F6;color:#6B7280;">{{__('label.magazines')}}</a>
                            </li>
                            <li class="nav-item">
                                <a class="nav-link" id="sell-audiobooks-tab" data-toggle="pill" href="#sell-audiobooks" role="tab" style="border-radius:8px;font-size:13px;font-weight:600;padding:6px 16px;background:#F3F4F6;color:#6B7280;">{{__('label.audiobooks')}}</a>
                            </li>
                        </ul>
                        <div class="tab-content">
                            <div class="tab-pane fade show active" id="sell-novels">
                                @forelse($most_purchased_novels ?? [] as $i => $item)
                                <div class="d-flex align-items-center py-2 border-bottom" style="border-color:#F3F4F6 !important;">
                                    <span class="mr-3 font-weight-bold" style="color:#9CA3AF;min-width:24px;">{{$i+1}}</span>
                                    <img src="{{$item['portrait_img'] ?? ''}}" class="rounded" style="width:36px;height:36px;object-fit:cover;margin-right:12px;">
                                    <div class="flex-grow-1" style="overflow:hidden;">
                                        <div style="font-size:14px;font-weight:600;color:#1F2937;white-space:nowrap;overflow:hidden;text-overflow:ellipsis;">{{$item['title']}}</div>
                                    </div>
                                    <div class="d-flex align-items-center ml-2">
                                        <i class="fa-solid fa-cart-shopping mr-1" style="color:#9CA3AF;font-size:13px;"></i>
                                        <span style="font-weight:600;color:#4E45B8;">{{ No_Format($item['content_transaction_count'] ?? 0) }}</span>
                                    </div>
                                </div>
                                @empty
                                <div class="text-center text-muted py-4">No data yet</div>
                                @endforelse
                            </div>
                            <div class="tab-pane fade" id="sell-magazines">
                                @forelse($most_purchased_magazines ?? [] as $i => $item)
                                <div class="d-flex align-items-center py-2 border-bottom" style="border-color:#F3F4F6 !important;">
                                    <span class="mr-3 font-weight-bold" style="color:#9CA3AF;min-width:24px;">{{$i+1}}</span>
                                    <img src="{{$item['portrait_img'] ?? ''}}" class="rounded" style="width:36px;height:36px;object-fit:cover;margin-right:12px;">
                                    <div class="flex-grow-1" style="overflow:hidden;">
                                        <div style="font-size:14px;font-weight:600;color:#1F2937;white-space:nowrap;overflow:hidden;text-overflow:ellipsis;">{{$item['title']}}</div>
                                    </div>
                                    <div class="d-flex align-items-center ml-2">
                                        <i class="fa-solid fa-cart-shopping mr-1" style="color:#9CA3AF;font-size:13px;"></i>
                                        <span style="font-weight:600;color:#E54B4B;">{{ No_Format($item['content_transaction_count'] ?? 0) }}</span>
                                    </div>
                                </div>
                                @empty
                                <div class="text-center text-muted py-4">No data yet</div>
                                @endforelse
                            </div>
                            <div class="tab-pane fade" id="sell-audiobooks">
                                @forelse($most_purchased_audio_books ?? [] as $i => $item)
                                <div class="d-flex align-items-center py-2 border-bottom" style="border-color:#F3F4F6 !important;">
                                    <span class="mr-3 font-weight-bold" style="color:#9CA3AF;min-width:24px;">{{$i+1}}</span>
                                    <img src="{{$item['portrait_img'] ?? ''}}" class="rounded" style="width:36px;height:36px;object-fit:cover;margin-right:12px;">
                                    <div class="flex-grow-1" style="overflow:hidden;">
                                        <div style="font-size:14px;font-weight:600;color:#1F2937;white-space:nowrap;overflow:hidden;text-overflow:ellipsis;">{{$item['title']}}</div>
                                    </div>
                                    <div class="d-flex align-items-center ml-2">
                                        <i class="fa-solid fa-cart-shopping mr-1" style="color:#9CA3AF;font-size:13px;"></i>
                                        <span style="font-weight:600;color:#F5A623;">{{ No_Format($item['content_transaction_count'] ?? 0) }}</span>
                                    </div>
                                </div>
                                @empty
                                <div class="text-center text-muted py-4">No data yet</div>
                                @endforelse
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>

        <!-- ============================================================
             SECTION 7: Language + Active Authors row
        ============================================================ -->
        <div class="row mt-3">
            <div class="col-12 col-xl-4 mb-3">
                <div class="card border-0 shadow-sm" style="border-radius:14px;height:100%;">
                    <div class="card-body p-4">
                        <div class="d-flex justify-content-between align-items-center mb-3">
                            <h6 class="mb-0 font-weight-bold" style="color:#1F2937;">
                                <i class="fa-solid fa-language mr-2" style="color:#4E45B8;"></i>
                                {{__('label.best_language')}}
                            </h6>
                            <a href="{{ route('admin.language.index') }}" style="color:#4E45B8;font-size:13px;font-weight:600;">{{__('label.view_all')}}</a>
                        </div>
                        <div class="row">
                            @forelse($best_language ?? [] as $lang)
                            <div class="col-6 mb-2">
                                <div style="position:relative;border-radius:10px;overflow:hidden;height:80px;">
                                    <img src="{{$lang['image'] ?? ''}}" style="width:100%;height:100%;object-fit:cover;filter:brightness(0.6);">
                                    <div style="position:absolute;top:50%;left:50%;transform:translate(-50%,-50%);color:white;font-weight:700;font-size:13px;text-align:center;width:90%;text-shadow:0 1px 4px rgba(0,0,0,0.3);">
                                        {{$lang['name']}}
                                    </div>
                                </div>
                            </div>
                            @empty
                            <div class="col-12 text-center text-muted py-4">No languages yet</div>
                            @endforelse
                        </div>
                    </div>
                </div>
            </div>
            <div class="col-12 col-xl-8 mb-3">
                <div class="card border-0 shadow-sm" style="border-radius:14px;height:100%;">
                    <div class="card-body p-4">
                        <div class="d-flex justify-content-between align-items-center mb-3">
                            <h6 class="mb-0 font-weight-bold" style="color:#1F2937;">
                                <i class="fa-solid fa-user-tie mr-2" style="color:#4E45B8;"></i>
                                {{__('label.most_active_authors')}}
                            </h6>
                        </div>
                        <div class="row">
                            @forelse($active_authors ?? [] as $author)
                            <div class="col-6 col-md-4 col-xl-2 mb-3">
                                <div class="text-center">
                                    <div style="width:56px;height:56px;border-radius:50%;overflow:hidden;margin:0 auto 8px;border:2px solid #EEF0FF;">
                                        <img src="{{ $author->image ?? '' }}" style="width:100%;height:100%;object-fit:cover;">
                                    </div>
                                    <div style="font-size:13px;font-weight:600;color:#1F2937;white-space:nowrap;overflow:hidden;text-overflow:ellipsis;">{{ $author['first_name'] ?? '' }} {{ $author['last_name'] ?? '' }}</div>
                                    <div style="font-size:11px;color:#9CA3AF;">{{ $author['user_name'] ?? '' }}</div>
                                </div>
                            </div>
                            @empty
                            <div class="col-12 text-center text-muted py-4">No active authors</div>
                            @endforelse
                        </div>
                    </div>
                </div>
            </div>
        </div>

    </div>
</div>
@endsection

@section('pagescript')
<!-- Chart -->
<script src="https://cdn.jsdelivr.net/npm/apexcharts"></script>

<script>
    // Get data
    let userYear = JSON.parse(`<?php echo $user_year ?>`);
    let userMonth = JSON.parse(`<?php echo $user_month ?>`);
    let authorYear = JSON.parse(`<?php echo $author_year ?>`);
    let authorMonth = JSON.parse(`<?php echo $author_month ?>`);

    // Indigo theme colors
    const INDIGO = '#4E45B8';
    const INDIGO_LIGHT = '#EEF0FF';
    const ORANGE = '#F5A623';

    let chartOptions = {
        chart: {
            type: 'bar',
            height: 320,
            toolbar: { show: false },
            fontFamily: "'Rubik', sans-serif",
        },
        dataLabels: { enabled: false },
        plotOptions: {
            bar: {
                horizontal: false,
                columnWidth: '60%',
                endingShape: 'rounded',
                borderRadius: 4,
            }
        },
        fill: {
            type: 'gradient',
            gradient: {
                shade: 'light',
                type: 'vertical',
                shadeIntensity: 0.3,
                inverseColors: false,
                opacityFrom: 0.9,
                opacityTo: 0.3,
                stops: [0, 100]
            }
        },
        colors: [INDIGO, ORANGE],
        grid: {
            borderColor: '#F3F4F6',
            strokeDashArray: 4,
        },
        tooltip: {
            theme: 'light',
            style: { fontSize: '13px' }
        },
        series: [],
        xaxis: {
            categories: [],
            labels: { style: { fontSize: '12px', fontWeight: 500 } }
        },
        yaxis: {
            labels: { style: { fontSize: '12px', fontWeight: 500 } }
        },
        legend: {
            position: 'bottom',
            fontSize: '13px',
            fontWeight: 600,
            markers: {
                radius: 4,
                width: 10,
                height: 10,
            }
        },
    };

    let chart = new ApexCharts(document.querySelector("#User_Author_Chart"), chartOptions);
    chart.render();

    function loadChartData(type) {
        if (type === 'year') {
            chart.updateOptions({
                series: [
                    { name: "{{ __('label.users') }}", data: userYear.sum },
                    { name: "{{ __('label.authors') }}", data: authorYear.sum }
                ],
                xaxis: {
                    categories: [
                        '{{__("label.jan")}}','{{__("label.feb")}}','{{__("label.mar")}}','{{__("label.apr")}}',
                        '{{__("label.may")}}','{{__("label.jun")}}','{{__("label.jul")}}','{{__("label.aug")}}',
                        '{{__("label.sep")}}','{{__("label.oct")}}','{{__("label.nov")}}','{{__("label.dec")}}'
                    ],
                },
            });
        } else {
            let daysInMonth = userMonth.sum.length;
            chart.updateOptions({
                series: [
                    { name: "{{ __('label.users') }}", data: userMonth.sum },
                    { name: "{{ __('label.authors') }}", data: authorMonth.sum }
                ],
                xaxis: {
                    categories: Array.from({ length: daysInMonth }, (_, i) => (i + 1).toString())
                },
            });
        }
        // Update button styles
        document.querySelectorAll('#year, #month').forEach(btn => {
            btn.style.background = '#F3F4F6';
            btn.style.color = '#6B7280';
        });
        document.getElementById(type).style.background = '#EEF0FF';
        document.getElementById(type).style.color = '#4E45B8';
    }

    loadChartData('year');
    document.getElementById('year').addEventListener('click', function() { loadChartData('year'); });
    document.getElementById('month').addEventListener('click', function() { loadChartData('month'); });
</script>
@endsection