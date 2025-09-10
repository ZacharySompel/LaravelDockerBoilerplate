<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use Spatie\Permission\Models\Role;
use Spatie\Permission\Models\Permission;
use Spatie\Permission\PermissionRegistrar;
use App\Models\User;
use Illuminate\Support\Facades\Hash;

class RolesAndPermissionsSeeder extends Seeder
{
    public function run(): void
    {
        // Reset cached roles and permissions
        app()[PermissionRegistrar::class]->forgetCachedPermissions();

        // Simple CRUD set for "posts"
        $perms = [
            'posts.create',
            'posts.view',
            'posts.update',
            'posts.delete',
        ];
        foreach ($perms as $p) {
            Permission::firstOrCreate(['name' => $p]);
        }

        // Roles
        $admin  = Role::firstOrCreate(['name' => 'admin']);
        $editor = Role::firstOrCreate(['name' => 'editor']);
        $viewer = Role::firstOrCreate(['name' => 'viewer']);

        // Assign permissions
        $admin->syncPermissions(Permission::all()); // everything
        $editor->syncPermissions(['posts.create', 'posts.view', 'posts.update']);
        $viewer->syncPermissions(['posts.view']);

        // Default admin (from .env, with sensible fallbacks)
        $adminEmail = env('ADMIN_SEED_EMAIL', 'admin@example.com');
        $adminName  = env('ADMIN_SEED_NAME', 'Default Admin');
        $adminPass  = env('ADMIN_SEED_PASSWORD', 'password123');

        $user = User::firstOrCreate(
            ['email' => $adminEmail],
            [
                'name' => $adminName,
                'password' => Hash::make($adminPass),
                'email_verified_at' => now(),
            ]
        );

        if (! $user->hasRole('admin')) {
            $user->assignRole($admin);
        }
    }
}
