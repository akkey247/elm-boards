<?php

namespace App;

use Illuminate\Database\Eloquent\Model;

class Boards extends Model
{
    protected $fillable = [
        'title',
        'content',
    ];
}
