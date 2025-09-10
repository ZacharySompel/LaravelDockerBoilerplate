<?php

use Illuminate\Support\Facades\Route;
use Spatie\Sitemap\Sitemap;
use Spatie\Sitemap\Tags\Url;

Route::get('/', function () {
    return view('welcome');
});

Route::get('/sitemap.xml', function () {
    return Sitemap::create()
        ->add(Url::create('/')->setChangeFrequency(Url::CHANGE_FREQUENCY_DAILY))
        ->add('/about')
        ->toResponse(request());
});
