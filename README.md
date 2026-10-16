# Hotwire Bootcamp

แอปจัดการ Project และ Task สำหรับฝึกใช้ Hotwire (Turbo + Stimulus) บน Rails 8

## ฟีเจอร์

- CRUD Project และ Task (Task อยู่ภายใต้ Project)
- เปลี่ยนสถานะ Task (`pending` → `in_progress` → `completed`) ผ่าน Turbo Stream โดยไม่ reload หน้า
- อัปเดตแบบ real-time ผ่าน Turbo Broadcasts (Action Cable / Solid Cable)
  - `Project` ใช้ `broadcasts_refreshes_to` เพื่อ refresh หน้ารายการ
  - `Task` broadcast การเพิ่ม/แก้/ลบ และจำนวน task ที่เสร็จแล้ว
- ฟอร์มแสดงใน modal (`<dialog>`) ผ่าน Turbo Frame + Stimulus `dialog_controller`

## Tech Stack

| ส่วน | เครื่องมือ |
| --- | --- |
| Backend | Ruby 4.0.7, Rails 8.1 |
| Database | SQLite3 |
| Frontend | Turbo, Stimulus, Tailwind CSS 4 |
| JS bundler | esbuild (ผ่าน `jsbundling-rails`) |
| Cache / Queue / Cable | Solid Cache, Solid Queue, Solid Cable |
| Deploy | Kamal + Thruster |

## เริ่มต้นใช้งาน

### แบบที่ 1: Docker (แนะนำ)

ต้องมี Docker และ Docker Compose

```bash
docker compose up --build
```

เปิด http://localhost:3000

`compose.yml` จะรัน 3 service: `web` (Rails server), `js` (esbuild watch), `css` (Tailwind watch)

คำสั่งที่ใช้บ่อย:

```bash
docker compose run --rm web bin/rails console
docker compose run --rm web bin/rails db:migrate

# หลังแก้ Gemfile หรือ package.json
docker compose run --rm web bundle install
docker compose run --rm web yarn install
```

### แบบที่ 2: รันบนเครื่อง

ต้องมี Ruby 4.0.7 (ดู `.ruby-version`), Node.js 26.8.1 (ดู `.node-version`), Yarn และ SQLite3

```bash
bin/setup   # ติดตั้ง gem/package, เตรียม database แล้วรัน server
```

หรือถ้าตั้งค่าไว้แล้ว:

```bash
bin/dev     # รัน web + js + css ตาม Procfile.dev
```

## โครงสร้างหลัก

```
app/
├── models/
│   ├── project.rb          # has_many :tasks, broadcast refresh
│   └── task.rb             # enum status, broadcast ไปที่ task-list
├── controllers/
│   ├── projects_controller.rb
│   └── tasks_controller.rb # มี make_in_progress / make_completed
├── views/tasks/
│   └── update_status.turbo_stream.erb
└── javascript/controllers/
    └── dialog_controller.js
```

### Routes

| Method | Path | Action |
| --- | --- | --- |
| GET | `/` | `projects#index` |
| — | `/projects` | CRUD (ยกเว้น `show`) |
| — | `/projects/:project_id/tasks` | CRUD (ยกเว้น `index`) |
| PATCH | `/projects/:project_id/tasks/:id/make_in_progress` | เปลี่ยนสถานะเป็น in progress |
| PATCH | `/projects/:project_id/tasks/:id/make_completed` | เปลี่ยนสถานะเป็น completed |

## Testing และ Code Quality

```bash
bin/rails test           # unit / integration tests
bin/rails test:system    # system tests (Capybara + Selenium)
bin/rubocop              # lint
bin/brakeman             # security scan
bin/bundler-audit        # ตรวจช่องโหว่ของ gem
bin/ci                   # รันทุกอย่างข้างบน
```

GitHub Actions (`.github/workflows/ci.yml`) รันขั้นตอนเหล่านี้ทุกครั้งที่ push / เปิด PR

## Deploy

ใช้ Kamal (ตั้งค่าที่ `config/deploy.yml`) และเก็บ secret ไว้ใน `.kamal/secrets` ซึ่งควรดึงค่าจาก environment variable หรือ password manager เท่านั้น ห้าม commit credential ลง repo

```bash
bin/kamal setup    # ครั้งแรก
bin/kamal deploy
```
