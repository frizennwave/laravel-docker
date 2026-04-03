# ===========================
# Makefile - Laravel Docker
# Shortcut commands untuk development
# ===========================

.PHONY: help install up down destroy restart logs bash artisan migrate seed fresh test

# Default target
help:
	@echo ""
	@echo "╔══════════════════════════════════════════╗"
	@echo "║       Laravel Docker - Perintah          ║"
	@echo "╚══════════════════════════════════════════╝"
	@echo ""
	@echo "  Setup:"
	@echo "    make install     - Install Laravel baru (jalankan pertama kali)"
	@echo ""
	@echo "  Docker:"
	@echo "    make up          - Jalankan semua container"
	@echo "    make down        - Hentikan semua container"
	@echo "    make destroy     - Hapus container, volume, dan image (reset total)"
	@echo "    make restart     - Restart semua container"
	@echo "    make logs        - Lihat logs semua container"
	@echo "    make logs-app    - Lihat logs app saja"
	@echo ""
	@echo "  Laravel:"
	@echo "    make bash        - Masuk ke container app (shell)"
	@echo "    make artisan     - Jalankan artisan (contoh: make artisan cmd='route:list')"
	@echo "    make migrate     - Jalankan migrasi database"
	@echo "    make seed        - Jalankan database seeder"
	@echo "    make fresh       - Drop semua tabel dan migrate ulang + seed"
	@echo "    make test        - Jalankan unit test"
	@echo "    make composer    - Jalankan composer (contoh: make composer cmd='require spatie/laravel-permission')"
	@echo ""

# ===========================
# SETUP
# ===========================
install:
	@echo "🚀 Memulai instalasi Laravel..."
	docker compose up -d --build
	@echo "⏳ Menunggu container siap..."
	@sleep 5
	docker compose exec -u root app chown -R www:www /var/www/html
	@rm -f src/.gitkeep
	docker compose exec app composer create-project laravel/laravel . --prefer-dist
	cp .env.example src/.env
	docker compose exec app php artisan key:generate
	docker compose exec app php artisan migrate
	@echo ""
	@echo "✅ Instalasi selesai!"
	@echo "🌐 Buka: http://localhost:8080"
	@echo "🗄️  pgAdmin: http://localhost:5050"

# ===========================
# DOCKER
# ===========================
up:
	docker compose up -d
	@echo "✅ Container berjalan di http://localhost:8080"

down:
	docker compose down
	@echo "🛑 Semua container dihentikan"

destroy:
	@echo "⚠️  Menghapus semua container, volume, dan image..."
	docker compose down -v --rmi all
	@echo "🗑️  Semua container, volume, dan image berhasil dihapus"

restart:
	docker compose restart
	@echo "🔄 Container di-restart"

logs:
	docker compose logs -f

logs-app:
	docker compose logs -f app

logs-nginx:
	docker compose logs -f nginx

logs-db:
	docker compose logs -f db

# ===========================
# LARAVEL
# ===========================
bash:
	docker compose exec app bash

artisan:
	docker compose exec app php artisan $(cmd)

migrate:
	docker compose exec app php artisan migrate

migrate-status:
	docker compose exec app php artisan migrate:status

seed:
	docker compose exec app php artisan db:seed

fresh:
	docker compose exec app php artisan migrate:fresh --seed

test:
	docker compose exec app php artisan test

composer:
	docker compose exec app composer $(cmd)

tinker:
	docker compose exec app php artisan tinker

cache-clear:
	docker compose exec app php artisan cache:clear
	docker compose exec app php artisan config:clear
	docker compose exec app php artisan route:clear
	docker compose exec app php artisan view:clear
	@echo "✅ Cache dibersihkan!"

# ===========================
# DATABASE
# ===========================
db-bash:
	docker compose exec db psql -U laravel_user -d laravel_db

db-dump:
	docker compose exec db pg_dump -U laravel_user laravel_db > backup_$$(date +%Y%m%d_%H%M%S).sql
	@echo "✅ Database backup selesai!"
