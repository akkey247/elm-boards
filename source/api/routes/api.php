<?php

use Illuminate\Http\Request;

/*
|--------------------------------------------------------------------------
| API Routes
|--------------------------------------------------------------------------
|
| Here is where you can register API routes for your application. These
| routes are loaded by the RouteServiceProvider within a group which
| is assigned the "api" middleware group. Enjoy building your API!
|
*/

Route::middleware('cache.headers:public')->group(function () {
    Route::apiResource('boards', 'BoardsController');
    Route::options('boards', 'BoardsController@index');
    Route::options('boards/{id}', 'BoardsController@show');
});
