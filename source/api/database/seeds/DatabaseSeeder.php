<?php

use Illuminate\Database\Seeder;

class DatabaseSeeder extends Seeder
{
    /**
     * Seed the application's database.
     *
     * @return void
     */
    public function run()
    {
        DB::table('boards')->insert([
          [
            'title' => 'Title 1',
            'content' => 'Content 1',
            'created_at' => new DateTime(),
            'updated_at' => new DateTime(),
          ],
          [
            'title' => 'Title 2',
            'content' => 'Content 2',
            'created_at' => new DateTime(),
            'updated_at' => new DateTime(),
          ],
          [
            'title' => 'Title 3',
            'content' => 'Content 3',
            'created_at' => new DateTime(),
            'updated_at' => new DateTime(),
          ],
        ]);
    }
}
