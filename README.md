# 🚀 Laravel + Docker + PostgreSQL

> ⚠️ **PROJECT INI HANYA UNTUK DEVELOPMENT / PEMBELAJARAN**
> Jangan gunakan konfigurasi ini langsung di production karena credentials bersifat publik.

Project Laravel siap pakai dengan Docker, PostgreSQL, Redis, Nginx, dan pgAdmin.
Dibuat untuk tujuan pembelajaran.

---

## 📦 Stack Teknologi

| Komponen | Teknologi | Versi |
|----------|-----------|-------|
| Backend  | Laravel   | 11.x  |
| PHP      | PHP-FPM   | 8.2   |
| Database | PostgreSQL| 15    |
| Web Server | Nginx   | Alpine|
| Cache/Queue | Redis  | 7     |
| DB GUI   | pgAdmin 4 | Latest|

---

## 📁 Struktur Project

```
laravel-docker/
├── docker/
│   ├── Dockerfile          # Image PHP-FPM untuk Laravel
│   ├── nginx/
│   │   └── default.conf    # Konfigurasi Nginx
│   ├── php/
│   │   └── local.ini       # Konfigurasi PHP
│   └── postgres/
│       └── init.sql        # Inisialisasi PostgreSQL
├── src/                    # 📂 Kode Laravel kamu ada di sini
│   ├── app/
│   ├── database/
│   ├── routes/
│   └── ...
├── docker-compose.yml      # Definisi semua service
├── Makefile               # Shortcut perintah
└── README.md
```

---

## 🚀 Cara Mulai (Pertama Kali)

### Prasyarat
Pastikan sudah terinstall:
- [Docker Desktop](https://www.docker.com/products/docker-desktop/)
- [Git](https://git-scm.com/)

### Langkah Instalasi

```bash
# 1. Clone atau download project ini
git clone <url-project> laravel-docker
cd laravel-docker

# 2. Install Laravel + jalankan semua container
make install

# Atau tanpa Makefile:
docker compose up -d --build
docker compose exec -u root app chown -R www:www /var/www/html
rm -f src/.gitkeep
docker compose exec app composer create-project laravel/laravel . --prefer-dist
cp .env.example src/.env
docker compose exec app php artisan key:generate
docker compose exec app php artisan migrate
```

```bash
# Hapus project tanpa Makefile
docker compose down -v --rmi all
```

### 🌐 Akses Aplikasi

| URL | Deskripsi |
|-----|-----------|
| http://localhost:8080 | Aplikasi Laravel |
| http://localhost:5050 | pgAdmin (GUI Database) |
| localhost:5432 | PostgreSQL (direct) |
| localhost:6379 | Redis |

---

## 🛠️ Perintah Sehari-hari

```bash
# Jalankan container
make up

# Hentikan container (data tetap aman)
make down

# ⚠️ Hapus SEMUA — container, volume, image (reset total)
# Gunakan ini kalau mau mulai dari awal bersih
make destroy

# Masuk ke shell container
make bash

# Lihat logs
make logs

# Jalankan migration
make migrate

# Jalankan seeder
make seed

# Reset database (fresh + seed)
make fresh

# Jalankan artisan command apapun
make artisan cmd="route:list"
make artisan cmd="make:model Product -mf"
make artisan cmd="make:controller ProductController --resource"

# Install package composer
make composer cmd="require spatie/laravel-permission"

# Bersihkan cache
make cache-clear
```

---

## 🗄️ Konfigurasi Database

### Di file `src/.env`:
```env
DB_CONNECTION=pgsql
DB_HOST=db          # Nama service di docker-compose
DB_PORT=5432
DB_DATABASE=laravel_db
DB_USERNAME=laravel_user
DB_PASSWORD=laravel_password
```

### Login pgAdmin (http://localhost:5050):
- **Email:** admin@laravel.com
- **Password:** admin123

### Tambah Server di pgAdmin:
1. Klik kanan "Servers" → Register → Server
2. **Name:** Laravel DB
3. Tab **Connection:**
   - **Host:** db (nama container, bukan localhost!)
   - **Port:** 5432
   - **Database:** laravel_db
   - **Username:** laravel_user
   - **Password:** laravel_password

---

## 📚 Konsep Laravel yang Perlu Dipelajari

### 1. Migration (Struktur Database)
```bash
# Buat migration baru
php artisan make:migration create_products_table

# Jalankan migration
php artisan migrate

# Rollback migration terakhir
php artisan migrate:rollback

# Lihat status migration
php artisan migrate:status
```

### 2. Model (Eloquent ORM)
```bash
# Buat model (+ migration + factory)
php artisan make:model Product -mf

# Gunakan di Tinker (REPL)
php artisan tinker

# Di Tinker:
>>> Product::all()
>>> Product::find(1)
>>> Product::where('price', '>', 100)->get()
```

### 3. Controller
```bash
# Buat resource controller
php artisan make:controller ProductController --resource

# Buat controller biasa
php artisan make:controller HomeController
```

### 4. Route
File: `src/routes/web.php`
```php
// Route sederhana
Route::get('/', function () {
    return view('welcome');
});

// Route ke Controller
Route::get('/products', [ProductController::class, 'index']);

// Resource route (CRUD lengkap)
Route::resource('products', ProductController::class);
```

### 5. Seeder & Factory
```bash
# Buat seeder
php artisan make:seeder ProductSeeder

# Buat factory
php artisan make:factory ProductFactory

# Jalankan seeder
php artisan db:seed

# Isi data dummy menggunakan factory (di Tinker)
>>> Product::factory(10)->create()
```

---

## 🔧 Tips PostgreSQL vs MySQL

| Fitur | PostgreSQL | MySQL |
|-------|-----------|-------|
| Tipe JSON | Native JSONB | JSON biasa |
| Full-text search | Lebih canggih | Terbatas |
| UUID | Built-in | Perlu plugin |
| Array | Didukung | Tidak ada |
| Case sensitive | Ya (default) | Tidak |

### Query khusus PostgreSQL di Laravel:
```php
// JSON query
$users = DB::table('users')
    ->whereJsonContains('preferences->theme', 'dark')
    ->get();

// Array column (khusus PostgreSQL)
$posts = DB::table('posts')
    ->whereRaw("? = ANY(tags)", ['laravel'])
    ->get();

// Full-text search
$posts = Post::whereRaw(
    "to_tsvector('english', title) @@ plainto_tsquery('english', ?)",
    ['laravel tutorial']
)->get();
```

---

## ❓ Troubleshooting

### Container tidak mau jalan:
```bash
# Reset total (hapus container, volume, dan image)
make destroy

# Lalu install ulang dari awal
make install
```

### Mau mulai dari awal (fresh install):
```bash
make destroy   # ⚠️ Semua data database akan terhapus!
make install
```

### Permission error:
```bash
docker compose exec app chmod -R 775 storage bootstrap/cache
docker compose exec app chown -R www:www storage bootstrap/cache
```

### Database tidak terkoneksi:
```bash
# Pastikan host DB adalah nama service, bukan localhost
# Di .env: DB_HOST=db  (bukan localhost atau 127.0.0.1)
```

### Melihat log error:
```bash
make logs-app          # Log container app
make logs-nginx        # Log Nginx
tail -f src/storage/logs/laravel.log  # Log Laravel
```

---

## 📄 License

This project is open source and available under the [MIT License](LICENSE).
