# Hotwire Bootcamp

## Table of Contents

1. [Prerequisites](#1-prerequisites)
2. [What is Hotwire?](#2-what-is-hotwire)
3. [SPA vs HTML over the wire](#3-spa-vs-html-over-the-wire)
4. [Environment Setup](#4-environment-setup)
5. [Project Structure](#5-project-structure)
6. [Turbo Drive](#6-turbo-drive)
7. [Turbo Frames](#7-turbo-frames)
8. [Turbo Streams](#8-turbo-streams)
9. [Broadcasting (Real-time)](#9-broadcasting-real-time)
10. [Page Refresh & Morphing](#10-page-refresh--morphing)
11. [Stimulus](#11-stimulus)
12. [Workshop: Task App](#12-workshop-task-app)
13. [Best Practices & Common Pitfalls](#13-best-practices--common-pitfalls)
14. [Resources](#14-resources)

## 1. Prerequisites

**ความรู้พื้นฐานที่จำเป็น:**

- พื้นฐาน Ruby และ Ruby on Rails (MVC, Routing, ActiveRecord)
- ความรู้ HTML/CSS
- พื้นฐาน JavaScript (ES modules, class, event)
- ติดตั้ง Docker Desktop (หรือ Docker Engine + Docker Compose)
- ติดตั้ง VS Code พร้อม Ruby LSP Extension

## 2. What is Hotwire?

**Hotwire (HTML Over The Wire)** คือแนวทางการสร้างเว็บแอปที่รู้สึกเร็วเหมือน SPA

- Server ส่ง **HTML** แทน **JSON**
- เขียน JavaScript น้อยลงมาก
- logic ส่วนใหญ่ยังอยู่ที่ฝั่ง Server

Hotwire ประกอบด้วย 3 ส่วนที่ทำงานร่วมกัน:

| ส่วนประกอบ          | ตอบคำถาม                          | ตัวอย่างงาน                                        |
| ------------------ | -------------------------------- | ------------------------------------------------ |
| **Turbo**          | HTML ใหม่จะมาแทนที่ตรงไหนของหน้า     | เปลี่ยนหน้า, submit form, อัปเดตบางส่วน, real-time    |
| **Stimulus**       | ต้องการ JS เล็ก ๆ ฝั่ง client ตรงไหน | toggle, dropdown, copy to clipboard, auto-submit |
| **Hotwire Native** | จะนำเว็บเดิมไปเป็นแอปมือถือยังไง        | แอป iOS / Android ที่ใช้หน้าเว็บจาก Server            |

**หลักการเลือกใช้:**

1. **Turbo:** เริ่มจากตัวนี้ก่อน (ไม่ต้องเขียน JS)
2. **Stimulus:** ใช้เมื่อต้องการ behavior ที่ไม่ต้องคุยกับ Server
3. **Hotwire Native:** ใช้เมื่อต้องการแอปมือถือจากเว็บเดิม

### Turbo

Turbo คือหัวใจของ Hotwire

- **หน้าที่:** ส่ง request แทน Browser แล้วนำ HTML ที่ Server ตอบกลับมาไปแทนที่ในหน้าเว็บ โดยไม่ reload ทั้งหน้า
- **แบ่งเป็น 3 เทคนิค** ตามขอบเขตของการอัปเดต:

| เทคนิค             | อัปเดตอะไร                          | ใช้เมื่อ                                 | รายละเอียด                         |
| ----------------- | ---------------------------------- | ------------------------------------- | --------------------------------- |
| **Turbo Drive**   | ทั้ง `<body>`                        | เปลี่ยนหน้าทั่วไป (เปิดใช้อัตโนมัติ)            | [Turbo Drive](#6-turbo-drive)     |
| **Turbo Frames**  | เฉพาะใน `<turbo-frame>` ที่ id ตรงกัน | แก้ไขแบบ inline, แท็บ, lazy load บางส่วน | [Turbo Frames](#7-turbo-frames)   |
| **Turbo Streams** | หลาย element ตาม action ที่สั่ง        | เพิ่ม/แก้/ลบหลายจุดพร้อมกัน, real-time      | [Turbo Streams](#8-turbo-streams) |

```erb
<%# Turbo Drive: ลิงก์ปกติ ไม่ต้องทำอะไรเพิ่ม %>
<%= link_to "Edit", edit_project_path(project) %>

<%# Turbo Frames: คลิก New task แล้วโหลดฟอร์มมาแสดงเฉพาะใน frame "modal" %>
<%= link_to "New task", new_project_task_path(@project), data: { turbo_frame: "modal" } %>
<%= turbo_frame_tag "modal" %>

<%# Turbo Streams: สั่งแทนที่การ์ดของ task ที่เปลี่ยนสถานะ %>
<%= turbo_stream.replace dom_id(@task), partial: "tasks/task", locals: { task: @task } %>

```

- **Page Refresh & Morphing:** Turbo ยัง refresh หน้าเดิมได้โดยคง scroll position และ state ของ element ไว้
  - ดูรายละเอียดที่ [Page Refresh & Morphing](#10-page-refresh--morphing)

### Stimulus

Stimulus คือ JavaScript framework ขนาดเล็กที่ **เพิ่ม behavior ให้ HTML ที่ Server render มาแล้ว**

- ไม่ render HTML เอง ต่างจาก React/Angular ที่สร้าง UI ทั้งหมดด้วย JS
- HTML เป็นตัวบอกว่าจะใช้ controller อะไร ผ่าน `data-*` attributes
- state เก็บอยู่ใน HTML (data attributes) ไม่ใช่ใน JavaScript object
- controller เชื่อมต่อ/ตัดการเชื่อมต่อเองอัตโนมัติเมื่อ element ถูกเพิ่ม/ลบออกจากหน้า
  - จึงทำงานได้ทันทีกับ HTML ที่ Turbo นำมาแทนที่

```html
<div data-controller="clipboard">
  <input data-clipboard-target="source" value="ABC-123" readonly>
  <button data-action="click->clipboard#copy">Copy</button>
</div>

```

```javascript
// app/javascript/controllers/clipboard_controller.js
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["source"]

  copy() {
    navigator.clipboard.writeText(this.sourceTarget.value)
  }
}

```

- รายละเอียดเพิ่มเติมดูที่ [Stimulus](#11-stimulus)

### Hotwire Native

Hotwire Native ใช้สร้างแอป iOS / Android จากเว็บ Hotwire ที่มีอยู่แล้ว

- **แนวคิด:** "Content is all web, navigation is all native"
- **Native shell:**
  - แอปเขียนด้วย Swift (iOS) หรือ Kotlin (Android) แล้วเปิดหน้าเว็บจาก Server ใน web view
  - การเปลี่ยนหน้า, ปุ่ม back, modal เป็นแบบ native
- **Deploy เว็บ = อัปเดตแอป:** แก้หน้าเว็บแล้ว deploy ผู้ใช้เห็นทันที ไม่ต้องรอ App Store review
- **Basic navigation:**
  - ลิงก์ใน domain เดียวกัน: push หน้าจอ native ใหม่
  - `data-turbo-action="replace"`: แทนที่หน้าจอเดิม
  - ลิงก์ต่าง domain: เปิดใน in-app browser
- **Path configuration:**
  - ไฟล์ JSON ที่มี `settings` และ `rules`
  - กำหนดพฤติกรรมตาม URL (regex) เช่น `/new$` ให้เปิดเป็น modal
- **Bridge Components:** Stimulus controller ฝั่งเว็บคู่กับ component ฝั่ง native (Swift/Kotlin) เพื่อใช้ปุ่ม, เมนู หรือ API ของเครื่องแบบ native
- **Native screens:** ค่อย ๆ เปลี่ยนบางหน้าเป็น native เต็มรูปแบบได้เมื่อจำเป็น

> **Note:** บทความเก่าอาจเรียก Hotwire Native ว่า **Turbo Native** และเรียก Bridge Components ว่า **Strada** ปัจจุบันรวมเป็น Hotwire Native แล้ว

### ทำไมต้อง Hotwire?

- **Less JavaScript:** ไม่ต้องสร้าง API + Frontend app แยก ลดโค้ดและความซับซ้อน
- **Server is the source of truth:** Business logic, validation, authorization อยู่ที่ Rails ที่เดียว
- **Fast by default:** ได้ความเร็วแบบ SPA จาก Turbo Drive โดยไม่ต้องตั้งค่า
- **Built into Rails:**
  - Rails 7+ ติดตั้ง Hotwire มาให้แล้วตั้งแต่ `rails new`
  - Turbo และ Stimulus ใช้กับ backend อื่นได้ ไม่จำเป็นต้องเป็น Rails
- **Progressive enhancement:**
  - ลิงก์และฟอร์มปกติยังทำงานแบบ HTML ธรรมดาได้แม้ JS ไม่ทำงาน
  - ยกเว้น `data-turbo-method`, lazy frame และ Stimulus ที่ต้องใช้ JS

> **Tip:** Hotwire ไม่ได้มาแทน React/Angular ในทุกกรณี ถ้า UI มี state ซับซ้อนมาก (เช่น editor, dashboard แบบ interactive สูง) SPA อาจเหมาะกว่า

## 3. SPA vs HTML over the wire

- **SPA (เช่น Angular, React):**
  - Server ส่ง **JSON**
  - Browser รัน JavaScript เพื่อสร้าง HTML เอง
  - ต้องมี state, routing, validation ซ้ำทั้งสองฝั่ง
- **Hotwire:**
  - Server render **HTML** ให้เลย
  - Turbo นำ HTML ที่ได้ไปแทนที่ในหน้าเว็บ
  - logic อยู่ที่ Server ที่เดียว

```
SPA
Browser ──(fetch /api/tasks)──▶ Server
Browser ◀──── JSON ─────────── Server
Browser: JSON → render HTML ด้วย JS framework

Hotwire
Browser ──(GET /tasks)───────▶ Server
Browser ◀──── HTML ─────────── Server (render ERB)
Turbo: เอา HTML ไปแทนที่ <body> / <turbo-frame> / target ที่กำหนด

```

| หัวข้อ             | SPA                                  | Hotwire                                                   |
| ---------------- | ------------------------------------ | --------------------------------------------------------- |
| Data format      | JSON                                 | HTML                                                      |
| Rendering        | Client                               | Server                                                    |
| Routing          | Client + Server                      | Server                                                    |
| Validation       | ทั้งสองฝั่ง                              | Server                                                    |
| JavaScript ที่เขียน | มาก                                  | น้อย (เฉพาะ Stimulus)                                      |
| เหมาะกับ          | UI ที่มี client state ซับซ้อนมาก, offline | CRUD app, admin, SaaS ทั่วไป, mobile app ผ่าน Hotwire Native |

## 4. Environment Setup

ใช้ **Docker** รันโปรเจกต์ ไม่ต้องติดตั้ง Ruby, Node.js หรือ Yarn ในเครื่อง

**1. ตรวจสอบว่าติดตั้ง Docker แล้ว:**

```bash
docker -v
docker compose version

```

**2. Clone โปรเจกต์เริ่มต้นแล้วรัน:**

- ใช้ branch [`hotwire/workshop`](https://github.com/paradon-sg/BC-Bootcamp/tree/hotwire/workshop) ซึ่งเป็น Rails 8.1 ที่สร้างด้วย esbuild
- ตั้งค่า Turbo, Stimulus, Tailwind CSS และ Docker ไว้แล้ว

```bash
git clone -b hotwire/workshop --single-branch https://github.com/paradon-sg/BC-Bootcamp.git hotwire-bootcamp
cd hotwire-bootcamp
docker compose up --build

```

- ครั้งแรกจะ build image (Ruby 4.0.7 + Node 26.8.1) และติดตั้ง gem กับ npm package ให้
- เปิด http://localhost:3000 จะเห็นหน้าแรกของแอป
- ครั้งต่อไปรันแค่ `docker compose up`

**3. Service ใน `compose.yml`:** มี 3 service ทำงานพร้อมกัน (แทน `bin/dev`)

| Service | หน้าที่                                                   |
| ------- | ------------------------------------------------------ |
| `web`   | `bin/rails db:prepare` แล้วรัน Rails server ที่ port 3000  |
| `js`    | `yarn build --watch` build JS ใหม่ทุกครั้งที่แก้ไฟล์           |
| `css`   | `bin/rails tailwindcss:watch` build CSS ใหม่ทุกครั้งที่แก้ไฟล์ |

- โค้ดในเครื่องถูก mount เข้า container แก้ไฟล์ใน VS Code แล้วเห็นผลทันที
- ไฟล์ที่ build ออกมาอยู่ที่ `app/assets/builds/`

**4. รันคำสั่งใน container:**

- คำสั่ง `bin/rails` และ `yarn` ทุกคำสั่งในเอกสารนี้ให้รันผ่าน `docker compose exec web`
- รันระหว่างที่ `docker compose up` ทำงานอยู่ (เปิดอีก terminal)

```bash
docker compose exec web bin/rails routes
docker compose exec web bin/rails db:migrate
docker compose exec web bin/rails console
docker compose exec web yarn add <package>

```

- หลังแก้ `Gemfile` ให้ติดตั้ง gem แล้ว restart server:

```bash
docker compose exec web bundle install
docker compose restart web

```

> **Note:** บน Linux ไฟล์ที่ generator สร้างจาก container จะเป็นของ `root` ถ้าแก้ไฟล์ไม่ได้ให้รัน `sudo chown -R $USER:$USER .` (macOS และ Windows ไม่มีปัญหานี้)

**5. ตรวจสอบว่า Hotwire ถูกติดตั้งแล้ว:**

```ruby

# Gemfile
gem "jsbundling-rails"
gem "turbo-rails"
gem "stimulus-rails"

```

```json
// package.json
{
  "scripts": {
    "build": "esbuild app/javascript/*.* --bundle --sourcemap --format=esm --outdir=app/assets/builds --public-path=/assets"
  },
  "dependencies": {
    "@hotwired/stimulus": "...",
    "@hotwired/turbo-rails": "..."
  },
  "devDependencies": {
    "esbuild": "..."
  }
}

```

```js
// app/javascript/application.js
import "@hotwired/turbo-rails"
import "./controllers"

```

```erb
<%# app/views/layouts/application.html.erb %>
<%= javascript_include_tag "application", "data-turbo-track": "reload", type: "module" %>

```

## 5. Project Structure

**ไฟล์ที่เกี่ยวข้องกับ Hotwire ในโปรเจกต์เริ่มต้น ([branch `hotwire/workshop`](https://github.com/paradon-sg/BC-Bootcamp/tree/hotwire/workshop)):**

```
hotwire-bootcamp/
├── app/
│   ├── assets/
│   │   ├── builds/                       # ไฟล์ที่ esbuild และ Tailwind build ออกมา (อยู่ใน .gitignore)
│   │   └── tailwind/
│   │       └── application.css           # Tailwind CSS
│   ├── javascript/
│   │   ├── application.js                # Entry point: import Turbo + Stimulus controllers
│   │   └── controllers/                  # Stimulus controllers
│   │       ├── application.js            # Stimulus application instance
│   │       ├── index.js                  # Register controllers (generate อัตโนมัติ)
│   │       └── hello_controller.js       # ตัวอย่าง controller ที่มากับ stimulus-rails
│   └── views/
│       └── layouts/
│           └── application.html.erb      # javascript_include_tag + yield :head
├── config/
│   └── cable.yml                         # Action Cable adapter (ใช้ใน Broadcasting)
├── compose.yml                           # Docker: service web + js + css
├── Dockerfile.dev                        # Image สำหรับ development
├── Gemfile                               # jsbundling-rails, turbo-rails, stimulus-rails, tailwindcss-rails
├── package.json                          # JS dependencies + build script ของ esbuild
└── Procfile.dev                          # bin/dev สำหรับรันนอก Docker

```

- ไฟล์ที่จะสร้างเพิ่มระหว่าง workshop ดูที่ [โครงสร้างหลังทำ workshop เสร็จ](#โครงสร้างหลังทำ-workshop-เสร็จ)

**คำอธิบายไฟล์สำคัญ:**

- **`app/javascript/application.js`**: Entry point ของ JavaScript
  - esbuild bundle ไฟล์นี้พร้อมทุกไฟล์ที่ import ไปเป็น `app/assets/builds/application.js`

- **`app/javascript/controllers/index.js`**: Register Stimulus controllers
  - esbuild ไม่รองรับการโหลดไฟล์แบบ auto-load จึงต้อง import และ register controller ทีละตัว
  - `bin/rails generate stimulus` จะอัปเดตไฟล์นี้ให้อัตโนมัติ ถ้าสร้างไฟล์ controller เอง ให้รัน `bin/rails stimulus:manifest:update`

```js
// app/javascript/controllers/index.js
// This file is auto-generated by ./bin/rails stimulus:manifest:update
import { application } from "./application"

import HelloController from "./hello_controller"
application.register("hello", HelloController)

```

- **`package.json`**: จัดการ JavaScript dependencies
  - ติดตั้ง package ด้วย `docker compose exec web yarn add <package>` แล้ว import ใน JS ได้เลย

## 6. Turbo Drive

Turbo Drive จะ **ดักการคลิกลิงก์และการ submit form ที่ไป origin เดียวกัน** แล้วทำงานดังนี้:

1. ส่ง request ด้วย `fetch`
2. นำ `<body>` ใหม่มาแทนที่ของเดิม และ merge `<head>` ให้ **โดยไม่ reload ทั้งหน้า**

- **ผลลัพธ์:** CSS/JS ไม่ต้องโหลดใหม่ทุกครั้ง หน้าเว็บจึงรู้สึกเร็วเหมือน SPA
- **ไม่ต้องเขียนโค้ดเพิ่ม:** แค่ import `@hotwired/turbo-rails` ก็ทำงานทันที

### Visit actions: advance vs replace

- **Application visit:** คลิกลิงก์ → Turbo เพิ่มประวัติใน browser history (`advance` เป็นค่า default)
- **Restoration visit:** กด Back/Forward → Turbo แสดงหน้าจาก cache ทันที
- **`replace`:** แทนที่ history entry ปัจจุบัน ไม่เพิ่มรายการใหม่

```erb
<%= link_to "Next step", step_path(2), data: { turbo_action: "replace" } %>

```

สั่ง visit จาก JavaScript:

```js
import { Turbo } from "@hotwired/turbo-rails"

Turbo.visit("/tasks", { action: "replace" })

```

### ปิด Turbo Drive เฉพาะจุด

```erb
<%# หน้าที่ใช้ JS library เก่าซึ่งต้อง reload ทั้งหน้า %>
<%= link_to "Legacy report", legacy_report_path, data: { turbo: false } %>

<%# ฟอร์มที่ redirect ไป origin อื่น เช่น payment gateway ภายนอก %>
<%= form_with url: checkout_path, data: { turbo: false } do |f| %>
  ...
<% end %>

```

> **Note:** Turbo ข้ามลิงก์เหล่านี้ให้อัตโนมัติ ไม่ต้องใส่ `data-turbo="false"`
>
> - URL ที่มีนามสกุลไฟล์ที่ไม่ใช่ HTML ที่พบบ่อย เช่น `/report.pdf`, `/data.json`, `.zip`, `.csv`
> - ลิงก์ที่มี `download`
> - ลิงก์ไป origin อื่น

### Link ที่ใช้ HTTP method อื่น

```erb
<%= link_to "Destroy", project_task_path(task.project, task),
      data: { turbo_method: :delete, turbo_confirm: "Are you sure?" } %>

<%# แนะนำใช้ button_to สำหรับ action ที่เปลี่ยนข้อมูล %>
<%= button_to "Destroy", [ task.project, task ], method: :delete, data: { turbo_confirm: "Are you sure?" } %>

```

### Form submission rules

Turbo Drive ต้องการ response ที่ถูกต้องหลัง submit form:

- **สำเร็จ:** หลัง submit ที่ไม่ใช่ GET (POST, PATCH, DELETE) ให้ตอบ **redirect 303 See Other**
- **ไม่ผ่าน validation:**
  - render ฟอร์มพร้อม status **4xx** (นิยมใช้ 422)
  - Turbo จะ render ทุก response ที่เป็น 4xx/5xx
- **ห้ามตอบ 200 กับ POST โดยไม่ redirect:**
  - Turbo จะไม่ render หน้านั้น
  - เพราะ browser จะทำ Back/Refresh ไม่ถูกต้อง

```ruby
# PATCH/PUT /projects/1
def update
  if @project.update(project_params)
    redirect_to edit_project_path(@project), notice: "Project was successfully updated.", status: :see_other
  else
    # ต้องส่ง 422 ไม่อย่างนั้น Turbo จะไม่ render error
    # (:unprocessable_content คือ 422 ชื่อใหม่ตั้งแต่ Rack 3.1, :unprocessable_entity ถูก deprecate แล้ว)
    render :edit, status: :unprocessable_content
  end
end

# DELETE /projects/1
def destroy
  @project.destroy!

  redirect_to projects_path, notice: "Project was successfully destroyed.", status: :see_other
end

```

- ระหว่าง submit Turbo จะ disable ปุ่ม submit ให้อัตโนมัติ
- เปลี่ยนข้อความปุ่มระหว่าง submit ได้ด้วย `data-turbo-submits-with`:

```erb
<%= f.submit "Save", data: { turbo_submits_with: "Saving..." } %>

```

### Prefetch และ Asset tracking

- **Prefetch:**
  - Turbo 8 จะ prefetch ลิงก์เมื่อ hover ค้างไว้ประมาณ 100ms
  - คลิกแล้วแสดงผลแทบทันที
- **`data-turbo-track="reload"`:**
  - ถ้า URL ของไฟล์ CSS/JS เปลี่ยน (Rails ใส่ digest ให้แล้ว เช่นหลัง deploy)
  - Turbo จะ reload ทั้งหน้าในการเปลี่ยนหน้าครั้งถัดไป

```erb
<%= stylesheet_link_tag :app, "data-turbo-track": "reload" %>

<%# ปิด prefetch เฉพาะลิงก์ %>
<%= link_to "Heavy page", heavy_path, data: { turbo_prefetch: false } %>

<%# ปิด prefetch ทั้งเว็บ (ใส่ใน <head>) %>
<meta name="turbo-prefetch" content="false">

```

> **Security:** prefetch ยิง GET แค่ตอน hover
>
> - ทุก GET route ต้อง **ไม่มี side effect** (ไม่สร้าง/แก้/ลบข้อมูล)
> - action ที่เปลี่ยนข้อมูลให้ใช้ `button_to` หรือฟอร์ม POST/PATCH/DELETE

### Cache และ Restoration visits

Turbo เก็บ snapshot ของหน้าไว้ใน cache เพื่อ:

- แสดงทันทีตอนกด Back/Forward
- แสดงเป็น preview ระหว่างโหลดหน้าที่เคยเปิด

จึงต้องระวัง element ที่ไม่ควรกลับมาอีก:

```erb
<%# flash message ไม่ควรโผล่อีกตอนกด Back %>
<div id="flash" data-turbo-temporary>
  <%= notice %>
</div>

```

```erb
<%# หน้าที่ข้อมูลเปลี่ยนบ่อย: ไม่ใช้ cache เลย (ใส่ meta turbo-cache-control ลงใน <head>) %>
<% turbo_exempts_page_from_cache %>

<%# หรือไม่แสดง preview แต่ยังใช้ cache ตอน Back %>
<% turbo_exempts_page_from_preview %>

```

- ถ้าต้อง reset state ของ JS ก่อนเก็บ snapshot ให้ฟัง `turbo:before-cache`
  - Stimulus ส่วนใหญ่จัดการผ่าน `disconnect()` ได้

### Persist element ข้ามหน้า

- `data-turbo-permanent` ทำให้ element ที่มี **id เดียวกัน** ไม่ถูกแทนที่เมื่อเปลี่ยนหน้า
- เหมาะกับตัวนับตะกร้าสินค้า หรือ audio player:

```erb
<div id="cart-counter" data-turbo-permanent>1 item</div>

```

## 7. Turbo Frames

Turbo Frames คือการแบ่งหน้าเว็บเป็น **ส่วนย่อยที่อัปเดตแยกกันได้**

- ลิงก์และฟอร์มภายใน frame จะอัปเดตเฉพาะ frame นั้น ไม่ใช่ทั้งหน้า

**หลักการ:**

1. Server ส่ง HTML กลับมา (ทั้งหน้าหรือแค่บางส่วนก็ได้)
2. Turbo หา `<turbo-frame>` ที่มี **id เดียวกัน**
3. นำ**เนื้อหาข้างใน**ไปแทนที่เนื้อหาของ frame เดิม
4. ส่วนอื่นของ response ถูกทิ้ง

### อัปเดตเฉพาะรายการ task

ตัวอย่างจาก [Workshop](#step-7-view-ของ-task): กด "Destroy" แล้วอัปเดตเฉพาะรายการ task ไม่ใช่ทั้งหน้า

```erb
<%# app/views/tasks/_index.html.erb (ย่อ) %>
<%= turbo_frame_tag dom_id(@project, "tasks") do %>
  <div id="task-list">
    <% @tasks.each do |task| %>
      <%= render "tasks/task", task: task %>
    <% end %>
  </div>
<% end %>

```

```erb
<%# app/views/tasks/_task.html.erb (ย่อ) %>
<div id="<%= dom_id(task) %>">
  <%= task.title %>
  <%= button_to "Destroy", [ task.project, task ], method: :delete, data: { turbo_confirm: "Are you sure?" } %>
</div>

```

- `turbo_frame_tag dom_id(@project, "tasks")` จะสร้าง `<turbo-frame id="tasks_project_1">`
- เมื่อกด "Destroy":
  1. Turbo ส่ง `DELETE /projects/1/tasks/1` แล้วตาม redirect ไปที่ `/projects/1/edit`
  2. ดึงเฉพาะ `<turbo-frame id="tasks_project_1">` จาก response มาแทนที่
  3. ฟอร์มของ project และส่วนอื่นในหน้าไม่เปลี่ยน โดยไม่ต้องเขียน JS เลย

### Eager และ Lazy loading

- **Eager:** frame ที่มี `src` จะโหลดเนื้อหาจาก URL นั้นทันทีหลังหน้าโหลด
- **Lazy:** ใส่ `loading: :lazy` จะโหลดเมื่อ frame เลื่อนเข้ามาในจอ เหมาะกับส่วนที่ query ช้า:

```erb
<%= turbo_frame_tag "stats", src: stats_path, loading: :lazy do %>
  <p>Loading...</p>
<% end %>

```

- response ของ `stats_path` ต้องมี `turbo_frame_tag "stats"` (ไม่ต้องใส่ `src`) อยู่ข้างใน
- ระหว่างโหลด frame จะมี attribute `busy` และ `aria-busy="true"` ใช้ทำ loading state ด้วย CSS ได้:

```css
turbo-frame[aria-busy="true"] { opacity: 0.5; }

```

### ควบคุม frame จากภายนอก

- ลิงก์หรือฟอร์มที่อยู่นอก frame สั่งให้อัปเดต frame ได้ด้วย `data-turbo-frame`
- ตัวอย่างจาก [Workshop](#step-6-modal-dialog-ด้วย-stimulus): ลิงก์ "New task" โหลดฟอร์มมาแสดงใน frame `modal`

```erb
<%# app/views/tasks/_index.html.erb (ย่อ) %>
<%= link_to "New task", new_project_task_path(@project), data: { turbo_frame: "modal" } %>

```

```erb
<%# app/views/projects/edit.html.erb (ย่อ) %>
<%= render "tasks/index" %>

<%= turbo_frame_tag "modal" %>

```

```erb
<%# app/views/tasks/new.html.erb (ย่อ) %>
<%= turbo_frame_tag "modal" do %>
  <%= render "form", project: @project, task: @task %>
<% end %>

```

- frame `modal` ว่างไว้ก่อน รอรับเนื้อหาเมื่อคลิกลิงก์
- response ต้องมี `turbo_frame_tag "modal"` id เดียวกัน (ใน Workshop อยู่ใน partial `application/_dialog.html.erb`)

### Navigate ออกนอก frame

```erb
<%# ลิงก์นี้อยู่ใน frame แต่ต้องการเปลี่ยนทั้งหน้า %>
<%= link_to "Back to projects", projects_path, data: { turbo_frame: "_top" } %>

<%# ให้ทุกลิงก์ใน frame เปลี่ยนทั้งหน้า %>
<%= turbo_frame_tag "nav", target: "_top" do %>
  ...
<% end %>

<%# อัปเดต URL ใน address bar ด้วย %>
<%= turbo_frame_tag "results", data: { turbo_action: "advance" } do %>
  ...
<% end %>

```

> **Note:** ถ้า response ไม่มี frame id ที่ตรงกัน
>
> - จะเห็นข้อความ **"Content missing"** และเกิด event `turbo:frame-missing`
> - ให้ตรวจว่า id ของ frame ทั้งสองหน้าตรงกัน

### Breaking out ออกจาก frame

- **กรณีที่พบบ่อย:** session หมดอายุ ระหว่างกดลิงก์ใน frame แล้วถูก redirect ไปหน้า login ซึ่งไม่มี frame
- **อาการ:** เห็น "Content missing"
- **วิธีแก้:** ให้หน้า login สั่ง reload ทั้งหน้า:

```erb
<%# app/views/sessions/new.html.erb (ใส่ meta turbo-visit-control ลงใน <head>) %>
<% turbo_page_requires_reload %>

```

## 8. Turbo Streams

Turbo Streams ใช้เมื่อต้องการ **อัปเดตหลายจุดในหน้าพร้อมกัน**

- target เป็น element ไหนก็ได้ที่มี id ไม่จำเป็นต้องเป็น `<turbo-frame>`
- Turbo Stream คือ HTML element ที่บอกว่า "ทำ action อะไร กับ element id ไหน":

```html
<turbo-stream action="append" target="task-list">
  <template>
    <div id="task_5">Buy milk</div>
  </template>
</turbo-stream>

```

### Actions

| Action    | ผลลัพธ์                                                                    |
| --------- | ------------------------------------------------------------------------ |
| `append`  | เพิ่มต่อท้ายใน target                                                        |
| `prepend` | เพิ่มไว้ด้านบนใน target                                                      |
| `replace` | แทนที่ target ทั้ง element                                                   |
| `update`  | แทนที่เฉพาะเนื้อหาข้างใน target                                               |
| `remove`  | ลบ target                                                                |
| `before`  | เพิ่มก่อน target                                                            |
| `after`   | เพิ่มหลัง target                                                            |
| `refresh` | สั่ง page refresh (จะ morph ถ้าหน้าตั้ง `turbo_refreshes_with method: :morph`) |

### ตอบกลับ Turbo Stream จาก Controller

ตัวอย่างจาก [Workshop](#step-8-taskscontroller): กดปุ่ม "Mark complete" แล้วอัปเดตการ์ดของ task และจำนวน task ที่เสร็จพร้อมกัน

```ruby
# PATCH /projects/:project_id/tasks/1/make_completed
def make_completed
  @task.completed!

  respond_to do |format|
    format.turbo_stream { render :update_status }  # render update_status.turbo_stream.erb
    format.html { redirect_to edit_project_path(@project), status: :see_other }
  end
end

```

```erb
<%# app/views/tasks/update_status.turbo_stream.erb %>
<%= turbo_stream.replace dom_id(@task), partial: "tasks/task", locals: { task: @task } %>

<%= turbo_stream.update dom_id(@project, "tasks-completed-count"), partial: "tasks/completed_count", locals: { project: @project } %>

```

หน้าที่มี target ของแต่ละ stream action:

```erb
<%# app/views/tasks/_index.html.erb (ย่อ) %>
<h2>
  Tasks
  <span id="<%= dom_id(@project, "tasks-completed-count") %>">
    <%= render "tasks/completed_count", project: @project %>
  </span>
</h2>

<div id="task-list">
  <% @tasks.each do |task| %>
    <%= render "tasks/task", task: task %>
  <% end %>
</div>

```

```erb
<%# app/views/tasks/_task.html.erb (ย่อ) %>
<div id="<%= dom_id(task) %>">
  <%= task.title %>
  <%= task_status_badge(task) %>
  ...
</div>

```

- **target ของแต่ละ action:**
  - `replace dom_id(@task)` → `<div id="task_1">` แทนที่การ์ดทั้งใบด้วย partial `tasks/_task.html.erb`
  - `update dom_id(@project, "tasks-completed-count")` → `<span id="tasks-completed-count_project_1">` แทนที่ข้อความ `(1/3 completed)`
- target id ต้องมีอยู่ในหน้าแล้ว ถ้าไม่มี Turbo จะข้าม action นั้นไปเฉย ๆ โดยไม่มี error
- ใช้ `dom_id` สร้าง id ทั้งใน view และ stream เพื่อให้ตรงกันเสมอ
- **Turbo ขอ Turbo Stream เมื่อไหร่?**
  - ตอน submit ฟอร์มที่ไม่ใช่ GET Turbo จะเพิ่ม `text/vnd.turbo-stream.html` ใน `Accept` header ให้ `format.turbo_stream` จึงทำงานได้
  - ลิงก์หรือฟอร์ม GET ต้องขอเองด้วย `data: { turbo_stream: true }`

### Inline ใน controller (กรณีสั้น ๆ)

```ruby
def destroy
  @task.destroy!

  respond_to do |format|
    format.turbo_stream { render turbo_stream: turbo_stream.remove(@task) }
    format.html { redirect_to edit_project_path(@project), status: :see_other }
  end
end

```

> **Best Practice:** ใส่ `format.html` ไว้เสมอเพื่อ fallback กรณีที่ไม่ได้ request ผ่าน Turbo

### Target หลาย element และ morph

```erb
<%# targets = CSS selector อัปเดตทุก element ที่ตรง %>
<%= turbo_stream.update_all ".completed-count", partial: "tasks/completed_count", locals: { project: @project } %>
<%= turbo_stream.remove_all "#task-list .completed" %>

<%# morph แทนการแทนที่ทั้งก้อน (รักษา focus/state ของ element ข้างใน) %>
<%= turbo_stream.replace @task, method: :morph %>

```

### Frames vs Streams ใช้อันไหน?

| สถานการณ์                                       | ใช้                       |
| ---------------------------------------------- | ------------------------ |
| อัปเดตส่วนเดียว เช่น inline edit, tabs, pagination | Turbo Frame              |
| อัปเดตหลายจุดพร้อมกัน                              | Turbo Stream             |
| อัปเดต real-time ให้ผู้ใช้คนอื่น                      | Turbo Stream + Broadcast |

## 9. Broadcasting (Real-time)

Turbo Streams สามารถส่งผ่าน **WebSocket (Action Cable)** ได้

- ผู้ใช้ทุกคนที่เปิดหน้าเดียวกันเห็นการเปลี่ยนแปลงทันที
- **Adapter ของ Action Cable** (ดูได้ที่ `config/cable.yml`):
  - production: Rails 8 ใช้ **Solid Cable** โดย default จึงไม่ต้องมี Redis
  - development: ใช้ adapter `async`

### 1) Model: broadcast เมื่อข้อมูลเปลี่ยน

```ruby
class Task < ApplicationRecord
  belongs_to :project

  # create → append ใน #task-list, update → replace, destroy → remove
  broadcasts_to ->(task) { [ task.project, "tasks-container" ] }, target: "task-list"
end

```

หรือเขียนแบบ explicit:

```ruby
class Task < ApplicationRecord
  belongs_to :project

  after_create_commit  -> { broadcast_append_later_to [ project, "tasks-container" ], target: "task-list" }
  after_update_commit  -> { broadcast_replace_later_to [ project, "tasks-container" ] }
  after_destroy_commit -> { broadcast_remove_to [ project, "tasks-container" ] }
end

```

- stream name เป็น array ได้ Rails จะต่อกันเป็นชื่อเดียว เช่น `[ project, "tasks-container" ]`
- broadcast ส่วนอื่นนอกจาก record ได้ด้วย `broadcast_update_later_to` เช่น จำนวน task ที่เสร็จ (ดู [Workshop Step 9](#step-9-real-time))

### 2) View: subscribe stream

```erb
<%# app/views/projects/edit.html.erb %>
<%= turbo_stream_from @project, "tasks-container" %>

<div id="task-list">
  <% @tasks.each do |task| %>
    <%= render "tasks/task", task: task %>
  <% end %>
</div>

```

- argument ของ `turbo_stream_from` ต้องตรงกับ stream name ใน model ทุกตัว

> **Security:** Stream name ถูก sign โดย Rails ผู้ใช้จึงปลอมชื่อ stream เองไม่ได้ แต่ใครก็ตามที่เปิดหน้านั้นได้จะได้รับ broadcast ด้วย
>
> - ให้ **scope stream ตามสิทธิ์** (เช่น ต่อ project หรือต่อ user)
> - อย่า broadcast ข้อมูล sensitive ไปยัง stream ที่ใช้ร่วมกัน

> **Tip:** ใช้ method ที่ลงท้ายด้วย `_later` เพื่อ render และส่งผ่าน background job ไม่ block request

## 10. Page Refresh & Morphing

Turbo 8 เพิ่ม **page refresh** คือการโหลด**หน้าเดิมซ้ำ**

- **เกิดเมื่อ:**
  - ฟอร์ม redirect กลับมาที่ URL เดิม
  - ได้รับ stream action `refresh`
- **ไม่นับ:** การเปลี่ยนไปหน้าอื่นตามปกติ
- **ค่า default:** แทนที่ `<body>` ทั้งหมด (`replace`) และ scroll กลับไปบนสุด (`reset`)
- **เมื่อเปิด morph:**
  - Turbo จะเปรียบเทียบ DOM เก่ากับใหม่ แล้วเปลี่ยนเฉพาะส่วนที่ต่างกัน
  - ถ้าตั้ง `scroll: :preserve` จะรักษาตำแหน่ง scroll ไว้

**เปิด morph ทั้งเว็บ:**

```erb
<%# app/views/layouts/application.html.erb (ใน <head>) %>
<%= turbo_refresh_method_tag :morph %>
<%= turbo_refresh_scroll_tag :preserve %>

```

**เปิด morph เฉพาะบางหน้า:**

- เรียก `<% turbo_refreshes_with method: :morph, scroll: :preserve %>` ใน view ของหน้านั้น
- helper นี้ใส่ meta ผ่าน `yield :head` จึงใช้ใน view ไม่ใช่ใน layout

**ใช้ร่วมกับ broadcast:**

- ตัวอย่าง: แทน `broadcasts_to` + `broadcast_completed_count` ใน [Workshop Step 9](#step-9-real-time) ด้วยบรรทัดเดียว

```ruby
class Task < ApplicationRecord
  belongs_to :project

  broadcasts_refreshes_to ->(task) { [ task.project, "tasks-container" ] }
end

```

```erb
<%# app/views/projects/edit.html.erb %>
<% turbo_refreshes_with method: :morph, scroll: :preserve %>

<%= turbo_stream_from @project, "tasks-container" %>

```

เมื่อ task ถูกสร้าง/แก้/ลบ:

1. ทุกคนที่เปิดหน้า edit ของ project นั้นได้รับคำสั่ง `refresh`
2. หน้าโหลด HTML ใหม่
3. morph เฉพาะส่วนที่ต่างกัน

**ป้องกันไม่ให้ element ถูก morph** (เช่น form ที่ผู้ใช้กำลังพิมพ์):

- ใช้ `data-turbo-permanent`
- มีผลกับการเปลี่ยนหน้าปกติด้วย ดู [Persist element ข้ามหน้า](#persist-element-ข้ามหน้า)

```erb
<div id="draft" data-turbo-permanent>...</div>

```

**Frame ที่โหลดเนื้อหาจาก `src`:**

- ใส่ `refresh: "morph"` เพื่อให้ frame โหลดเนื้อหาใหม่แบบ morph ด้วยเมื่อเกิด page refresh

```erb
<%= turbo_frame_tag "stats", src: stats_path, refresh: "morph" %>

```

> **Best Practice:**
>
> - เริ่มจาก **morphing + `broadcasts_refreshes`** ก่อน เพราะเขียนน้อยที่สุด
> - ค่อยเปลี่ยนไปใช้ Turbo Stream action เฉพาะจุดเมื่อมีปัญหาเรื่อง performance

## 11. Stimulus

Stimulus คือ JavaScript framework ขนาดเล็กที่ **เพิ่ม behavior ให้ HTML ที่ Server render มาแล้ว**

- ไม่ได้ render HTML เอง
- HTML เป็นตัวบอกว่าจะใช้ controller อะไร ผ่าน `data-*` attributes
- **state เก็บอยู่ใน HTML** (data attributes) ไม่ใช่ใน JavaScript object

### Identifier และชื่อไฟล์

ชื่อไฟล์ controller ถูกแปลงเป็น **identifier** (kebab-case) ที่ใช้ใน HTML:

| ไฟล์                             | Identifier         |
| ------------------------------- | ------------------ |
| `hello_controller.js`           | `hello`            |
| `auto_submit_controller.js`     | `auto-submit`      |
| `users/list_item_controller.js` | `users--list-item` |

- **การตั้งชื่อ:** ใน JavaScript ใช้ camelCase ส่วนใน HTML ใช้ kebab-case
  - เช่น value `contentType` → `data-loader-content-type-value`
- **หลาย controller บน element เดียว:** คั่นด้วยเว้นวรรค เช่น `data-controller="clipboard tooltip"`
  - แต่ละ element จะได้ controller instance ของตัวเอง

### Core concepts

| Concept        | Attribute                                | หน้าที่                                  |
| -------------- | ---------------------------------------- | ------------------------------------- |
| **Controller** | `data-controller="counter"`              | ผูก JS class กับ element                |
| **Action**     | `data-action="click->counter#increment"` | ผูก event กับ method                    |
| **Target**     | `data-counter-target="output"`           | อ้างอิง element ภายใน controller        |
| **Value**      | `data-counter-count-value="0"`           | state ที่อ่าน/เขียนได้ (sync กับ attribute) |
| **Class**      | `data-counter-active-class="is-active"`  | ส่งชื่อ CSS class เข้า controller         |
| **Outlet**     | `data-counter-modal-outlet="#modal"`     | อ้างอิง controller อื่น                   |

- `this.element` คือ element ที่มี `data-controller`
- controller จะมองเห็นเฉพาะ element นั้นและลูก ๆ ของมัน

### Actions

รูปแบบ `event->controller#method:option`:

```erb
<button data-action="click->counter#increment">+</button>

<%# ไม่ระบุ event ได้ ถ้าเป็น default event ของ element นั้น %>
<button data-action="counter#increment">+</button>

<%# หลาย action คั่นด้วยเว้นวรรค %>
<input data-action="focus->search#open input->search#query">

```

**Default events:**

| Element             | Default event                               |
| ------------------- | ------------------------------------------- |
| `a`, `button`       | `click`                                     |
| `form`              | `submit`                                    |
| `input`, `textarea` | `input` (`input type="submit"` เป็น `click`) |
| `select`            | `change`                                    |
| `details`           | `toggle`                                    |

**Action options, keyboard filter และ global events:**

```erb
<%# :prevent = event.preventDefault(), :stop = event.stopPropagation() %>
<a href="#" data-action="click->menu#toggle:prevent">Menu</a>

<%# :once = ทำครั้งเดียว, :self = เฉพาะเมื่อ event เกิดที่ element นี้เอง %>
<div data-action="click->modal#close:self">...</div>

<%# keyboard filter %>
<input data-action="keydown.enter->search#submit keydown.esc->search#clear">

<%# ฟัง event ของ window / document %>
<div data-controller="layout" data-action="resize@window->layout#recalculate"></div>

```

**Action parameters:**

- ส่งค่าให้ method ผ่าน `data-[identifier]-[name]-param`
- ต้องอยู่บน element เดียวกับ `data-action`
- Stimulus แปลง type ให้อัตโนมัติ:

```erb
<button data-action="cart#add" data-cart-id-param="42">Add</button>

```

```js
add({ params: { id } }) {
  console.log(id) // 42 (Number)
}

```

### Targets

```js
static targets = ["item"]

this.itemTarget     // element แรก (throw error ถ้าไม่มี)
this.itemTargets    // array ของทุก element
this.hasItemTarget  // true / false

```

### Values

```js
static values = {
  url: String,                              // default ""
  count: Number,                            // default 0
  open: Boolean,                            // default false ("false" หรือ "0" = false)
  ids: Array,                               // default [] (เขียนใน HTML เป็น JSON)
  options: Object,                          // default {} (เขียนใน HTML เป็น JSON)
  delay: { type: Number, default: 300 },    // กำหนด default เอง
}

```

- **อ่าน:** `this.urlValue`
  - เช็คว่ามี attribute ไหม: `this.hasUrlValue`
- **เขียน:** `this.countValue = 5` จะเขียนกลับไปที่ `data-*-count-value` ด้วย
- **`[name]ValueChanged(value, previousValue)`:**
  - ถูกเรียก**ครั้งแรกตอน controller เริ่มทำงาน**
  - และทุกครั้งที่ค่าเปลี่ยน

### ตัวอย่าง: Counter

สร้าง controller:

```bash
docker compose exec web bin/rails generate stimulus counter

```

- คำสั่งนี้จะสร้าง `counter_controller.js` และ register ใน `controllers/index.js` ให้อัตโนมัติ

```js
// app/javascript/controllers/counter_controller.js
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["output"]
  static values = { count: Number }

  increment() {
    this.countValue++
  }

  // ถูกเรียกครั้งแรกตอนเริ่มทำงาน (span จึงแสดง 5 ทันที) และทุกครั้งที่ countValue เปลี่ยน
  countValueChanged() {
    this.outputTarget.textContent = this.countValue
  }
}

```

```erb
<div data-controller="counter" data-counter-count-value="5">
  <p>Count: <span data-counter-target="output"></span></p>
  <button data-action="click->counter#increment">Increment</button>
</div>

```

### Lifecycle

| Callback       | เรียกเมื่อ                                                                          |
| -------------- | -------------------------------------------------------------------------------- |
| `initialize()` | สร้าง controller instance (ครั้งเดียว)                                               |
| `connect()`    | controller เชื่อมกับ document (เกิดได้หลายครั้ง เช่น หลัง Turbo เปลี่ยนหน้าหรือแสดงจาก cache) |
| `disconnect()` | controller หลุดจาก document (element ถูกลบ, parent ถูกแทนที่ หรือลบ `data-controller`) |

**ตัวอย่าง:** ต้อง cleanup resource ที่สร้างใน `connect()` เสมอ

```js
// app/javascript/controllers/refresh_controller.js
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = { interval: { type: Number, default: 5000 } }

  connect() {
    this.timer = setInterval(() => this.element.reload(), this.intervalValue)
  }

  disconnect() {
    clearInterval(this.timer)
  }
}

```

```erb
<%# reload() เป็น method ของ <turbo-frame> ที่มี src %>
<%= turbo_frame_tag "stats", src: stats_path,
      data: { controller: "refresh", refresh_interval_value: 10000 } %>

```

- มี callback สำหรับ target ด้วย:
  - `[name]TargetConnected(element)`
  - `[name]TargetDisconnected(element)`

### CSS Classes

- ส่งชื่อ CSS class จาก HTML แทนการ hardcode ใน JS
- attribute ต้องอยู่บน element เดียวกับ `data-controller`

```js
static classes = ["active"]

toggle() {
  this.element.classList.toggle(this.activeClass)
}

```

```erb
<div data-controller="toggle" data-toggle-active-class="bg-blue-500">...</div>

```

### สื่อสารระหว่าง controller

**`this.dispatch()`**

- ส่ง custom event (ชื่อขึ้นต้นด้วย identifier อัตโนมัติ)
- controller อื่นฟังผ่าน `data-action`:

```js
// clipboard_controller.js
copy() {
  navigator.clipboard.writeText(this.sourceTarget.value)
  this.dispatch("copied", { detail: { content: this.sourceTarget.value } })
}

```

```erb
<%# element ต้องอยู่ใน scope ของ controller ที่รับ event (toast) ด้วย %>
<div data-controller="clipboard toast" data-action="clipboard:copied->toast#show">...</div>

```

**Outlets**

- อ้างอิง controller อื่นด้วย CSS selector
- element ปลายทางต้องมี `data-controller` ตรงกัน:

```js
static outlets = ["modal"]

open() {
  this.modalOutlet.show() // this.modalOutlets, this.hasModalOutlet ก็มี
}

```

```erb
<button data-controller="trigger" data-trigger-modal-outlet="#signup" data-action="trigger#open">Sign up</button>
<div id="signup" data-controller="modal">...</div>

```

### ตัวอย่าง: Reset form หลัง submit สำเร็จ

ฟัง Turbo event ได้โดยตรงจาก `data-action`:

```js
// app/javascript/controllers/reset_form_controller.js
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  reset(event) {
    if (event.detail.success) this.element.reset()
  }
}

```

```erb
<%= form_with model: [ @project, Task.new ],
      data: { controller: "reset-form", action: "turbo:submit-end->reset-form#reset" } do |f| %>
  ...
<% end %>

```

> **Best Practice:** เขียน controller ให้เล็กและ reusable (เช่น `auto-submit`, `clipboard`, `toggle`) แทนการเขียน controller ผูกกับหน้าใดหน้าหนึ่ง

## 12. Workshop: Task App

สร้าง Task app ที่แบ่ง task ตาม project โดยมี:

- เพิ่ม/แก้ไข task ผ่าน modal (`<dialog>` + Turbo Frame + Stimulus)
- เปลี่ยนสถานะ task ด้วยปุ่มเดียวโดยไม่ reload (Turbo Stream)
- real-time เฉพาะคนที่เปิด project เดียวกัน พร้อมจำนวน task ที่เสร็จแล้ว
- หน้ารายการ project อัปเดต real-time เมื่อมีคนเพิ่ม/แก้/ลบ project

> **โค้ดเฉลย:** [branch `hotwire/demo`](https://github.com/paradon-sg/BC-Bootcamp/tree/hotwire/demo)

### ER Diagram

```mermaid
erDiagram
  PROJECT ||--o{ TASK : has

  PROJECT {
    integer id PK
    string name
  }
  TASK {
    integer id PK
    integer project_id FK "not null"
    string title "not null"
    integer status "0 pending | 1 in_progress | 2 completed (default: 0)"
  }

```

| Relationship    | Rails association                                      | ใช้ใน workshop                                                                      |
| --------------- | ------------------------------------------------------ | ---------------------------------------------------------------------------------- |
| Project → Tasks | `Project has_many :tasks` / `Task belongs_to :project` | `broadcasts_to [project, "tasks-container"]` + `turbo_stream_from @project, "tasks-container"` |

### Step 1: Project และ Task

```bash
docker compose exec web bin/rails generate scaffold Project name:string --no-jbuilder --skip-test-framework
docker compose exec web bin/rails generate scaffold Task project:references title:string status:integer --no-jbuilder --skip-test-framework

```

แก้ migration ของ task ก่อน migrate:

- `references` สร้าง foreign key และ index ที่ `project_id` ให้อัตโนมัติแล้ว
- เพิ่ม `null: false` ที่ `title` และ `default: 0` ที่ `status`:

```ruby

# db/migrate/xxxxxxxxxxxxxx_create_tasks.rb
class CreateTasks < ActiveRecord::Migration[8.1]
  def change
    create_table :tasks do |t|
      t.references :project, null: false, foreign_key: true
      t.string  :title, null: false
      t.integer :status, default: 0

      t.timestamps
    end
  end
end

```

```bash
docker compose exec web bin/rails db:migrate

```

ผลลัพธ์ใน `db/schema.rb`:

```ruby
create_table "projects", force: :cascade do |t|
  t.string "name"
  t.datetime "created_at", null: false
  t.datetime "updated_at", null: false
end

create_table "tasks", force: :cascade do |t|
  t.integer "project_id", null: false
  t.string "title", null: false
  t.integer "status", default: 0
  t.datetime "created_at", null: false
  t.datetime "updated_at", null: false
  t.index ["project_id"], name: "index_tasks_on_project_id"
end

```

เพิ่ม association และ validation ตาม ER Diagram (ส่วน broadcast จะเพิ่มใน Step 9):

```ruby

# app/models/project.rb
class Project < ApplicationRecord
  has_many :tasks, dependent: :destroy

  validates :name, presence: true
end

```

```ruby

# app/models/task.rb
class Task < ApplicationRecord
  enum :status, { pending: 0, in_progress: 1, completed: 2 }, validate: true

  belongs_to :project

  validates :title, presence: true
end

```

**`enum`:**

- map ชื่อสถานะกับตัวเลขที่เก็บใน database (`default: 0` จึงเป็น `pending`)
- ได้ method มาให้ เช่น
  - `task.pending?`, `task.in_progress?` ใช้เลือกปุ่มที่จะแสดง
  - `task.in_progress!`, `task.completed!` ใช้ใน member action ของ controller
  - `Task.completed` / `project.tasks.completed` ใช้นับ task ที่เสร็จแล้ว
- `validate: true` ทำให้ค่าที่ไม่อยู่ใน enum เป็น validation error แทนการ raise `ArgumentError`
  - status มาจากฟอร์มจึงต้องตรวจ

> **Note:**
>
> - ระบุตัวเลขให้แต่ละสถานะเองเสมอ
> - ห้ามเปลี่ยนตัวเลขของสถานะที่มีอยู่แล้ว เพราะข้อมูลเดิมใน database จะเปลี่ยนความหมายทันที

### Step 2: Routes

แทนที่ `resources :projects` และ `resources :tasks` ที่ scaffold เพิ่มไว้:

```ruby

# config/routes.rb
Rails.application.routes.draw do
  resources :projects, except: :show do
    resources :tasks, only: [ :edit, :update, :new, :create, :destroy ] do
      member do
        patch :make_in_progress
        patch :make_completed
      end
    end
  end

  get "up" => "rails/health#show", as: :rails_health_check

  root "projects#index"
end

```

- **ไม่มีหน้า show ของ project:** task แสดงและจัดการในหน้า edit ของ project
- **member action:** เปลี่ยนสถานะ task ด้วย `PATCH` แยกจาก `update` ปกติ
- ทุก route ของ task อยู่ใต้ project จึงต้องส่ง project ไปด้วยเสมอ:

| Route                                                  | Path helper                                         |
| ------------------------------------------------------ | --------------------------------------------------- |
| `GET /projects/:project_id/tasks/new`                  | `new_project_task_path(project)`                    |
| `POST /projects/:project_id/tasks`                     | `project_tasks_path(project)`                       |
| `GET /projects/:project_id/tasks/:id/edit`             | `edit_project_task_path(project, task)`             |
| `PATCH`, `DELETE /projects/:project_id/tasks/:id`      | `project_task_path(project, task)`                  |
| `PATCH /projects/:project_id/tasks/:id/make_in_progress` | `make_in_progress_project_task_path(project, task)` |
| `PATCH /projects/:project_id/tasks/:id/make_completed` | `make_completed_project_task_path(project, task)`   |

- ใน `form_with` และ `button_to` ส่งเป็น array `[project, task]` แทน path helper ได้
- ลบไฟล์ที่ scaffold สร้างแต่ไม่ได้ใช้: `app/views/projects/show.html.erb`, `app/views/tasks/index.html.erb`, `app/views/tasks/show.html.erb`

### Step 3: Style และ Layout

เพิ่ม component class ที่ทุก view ใช้ร่วมกัน:

```css
/* app/assets/tailwind/application.css */
@import "tailwindcss";

@layer components {
  .btn {
    @apply inline-block rounded-md px-3.5 py-2.5 text-center font-medium cursor-pointer;
  }

  .btn-primary {
    @apply bg-blue-600 text-white hover:bg-blue-500;
  }

  .btn-secondary {
    @apply bg-gray-100 hover:bg-gray-50;
  }

  .btn-danger {
    @apply bg-red-600 text-white hover:bg-red-500;
  }

  .input {
    @apply block w-full mt-2 px-3 py-2 rounded-md border border-gray-400 shadow-sm focus:outline-blue-600;
  }

  /* Must stay after .input so it wins in the same layer */
  .input-error {
    @apply border-red-400 focus:outline-red-600;
  }

  .form-errors {
    @apply mt-3 px-3 py-2 rounded-md bg-red-50 text-red-500 font-medium;

    & ul {
      @apply list-disc ml-6;
    }
  }

  .page-title {
    @apply font-bold text-4xl;
  }

  .detail-label {
    @apply block font-medium mb-1;
  }

  .badge {
    @apply inline-block px-2 py-1 rounded-full text-xs font-medium;
  }

  .empty-state {
    @apply text-center my-10;
  }
}

```

แสดง flash message ที่มุมขวาบนของทุกหน้า:

```erb
<%# app/views/layouts/application.html.erb (ใน <body>) %>
<main class="container mx-auto mt-28 px-5 flex">

  <div class="fixed top-5 right-5 z-50 flex flex-col gap-3">
    <% if notice.present? %>
      <p class="py-3 px-4 bg-green-50 text-green-700 font-medium rounded-lg border border-green-200" id="notice">
        <%= notice %>
      </p>
    <% end %>

    <% if alert.present? %>
      <p class="py-3 px-4 bg-red-50 text-red-700 font-medium rounded-lg border border-red-200" id="alert">
        <%= alert %>
      </p>
    <% end %>
  </div>

  <%= yield %>
</main>

```

### Step 4: ProjectsController

```ruby

# app/controllers/projects_controller.rb
class ProjectsController < ApplicationController
  before_action :set_project, only: %i[ edit update destroy ]
  before_action :set_tasks, only: %i[ edit update ]

  def index
    @projects = Project.all
  end

  def new
    @project = Project.new
  end

  def edit
  end

  def create
    @project = Project.new(project_params)

    if @project.save
      redirect_to edit_project_path(@project), notice: "Project was successfully created."
    else
      render :new, status: :unprocessable_content
    end
  end

  def update
    if @project.update(project_params)
      redirect_to edit_project_path(@project), notice: "Project was successfully updated.", status: :see_other
    else
      render :edit, status: :unprocessable_content
    end
  end

  def destroy
    @project.destroy!

    redirect_to projects_path, notice: "Project was successfully destroyed.", status: :see_other
  end

  private
    def set_project
      @project = Project.find(params.expect(:id))
    end

    def set_tasks
      @tasks = @project.tasks
    end

    def project_params
      params.expect(project: [ :name ])
    end
end

```

- `set_tasks` ใช้กับ `update` ด้วย เพราะถ้า validation ไม่ผ่านจะ render หน้า edit ซึ่งแสดงรายการ task

### Step 5: View ของ Project

**หน้ารายการ project:**

```erb
<%# app/views/projects/index.html.erb %>
<% content_for :title, "Projects" %>

<div class="w-full">
  <div class="flex justify-between items-center">
    <h1 class="page-title">Projects</h1>
    <%= link_to "New project", new_project_path, class: "btn btn-primary block" %>
  </div>

  <%= turbo_stream_from "project-container" %>

  <div id="project-list" class="min-w-full divide-y divide-gray-200 space-y-5">
    <% @projects.each do |project| %>
      <%= render "projects/project", project: project %>
    <% end %>

    <p class="empty-state hidden only:block col-span-full">No projects found.</p>
  </div>
</div>

```

- `turbo_stream_from "project-container"` รับ broadcast เมื่อ project ถูกเพิ่ม/แก้/ลบ (ตั้งค่าใน Step 9)
- `#project-list` เป็น target ของ broadcast จึงต้องมีอยู่ในหน้าเสมอ
- **empty state:** `<p>` อยู่ใน `#project-list` เสมอ และแสดงเฉพาะเมื่อเป็นลูกตัวเดียว (`hidden only:block`)

```erb
<%# app/views/projects/_project.html.erb %>
<div id="<%= dom_id project %>" class="flex flex-col sm:flex-row justify-between items-center pb-5 sm:pb-0">
  <div class="w-full sm:w-auto my-5 space-y-5">
    <div>
      <strong class="detail-label">Name:</strong>
      <%= project.name %>
    </div>
  </div>
  <div class="w-full sm:w-auto flex flex-col sm:flex-row space-x-2 space-y-2">
    <%= link_to "Edit", edit_project_path(project), class: "btn btn-secondary w-full sm:w-auto" %>
    <%= button_to "Destroy", project, method: :delete, class: "btn btn-danger w-full sm:w-auto", data: { turbo_confirm: "Are you sure?" } %>
  </div>
</div>

```

**ฟอร์มของ project:**

```erb
<%# app/views/projects/_form.html.erb %>
<%= form_with model: project, class: "contents" do |form| %>
  <% if project.errors.any? %>
    <div id="error_explanation" class="form-errors">
      <h2><%= pluralize(project.errors.count, "error") %> prohibited this project from being saved:</h2>

      <ul>
        <% project.errors.each do |error| %>
          <li><%= error.full_message %></li>
        <% end %>
      </ul>
    </div>
  <% end %>

  <div class="my-5">
    <%= form.label :name %>
    <%= form.text_field :name, class: ["input", { "input-error": project.errors[:name].any? }] %>
  </div>

  <div class="inline">
    <%= form.submit class: "btn btn-primary w-full sm:w-auto" %>
  </div>
<% end %>

```

```erb
<%# app/views/projects/new.html.erb %>
<% content_for :title, "New project" %>

<div class="w-full">
  <h1 class="page-title">New project</h1>

  <%= render "form", project: @project %>

  <%= link_to "Back to projects", projects_path, class: "btn btn-secondary w-full sm:w-auto mt-2 sm:mt-0 sm:ml-2" %>
</div>

```

**หน้า edit ของ project (แสดงและจัดการ task ด้วย):**

```erb
<%# app/views/projects/edit.html.erb %>
<% content_for :title, "Editing project" %>

<div class="w-full">
  <h1 class="page-title">Editing project</h1>

  <%= render "form", project: @project %>

  <%= link_to "Back to projects", projects_path, class: "btn btn-secondary w-full sm:w-auto mt-2 sm:mt-0 sm:ml-2" %>

  <%= turbo_stream_from @project, "tasks-container" %>

  <div class="mt-10">
    <%= render "tasks/index" %>
  </div>

  <%= turbo_frame_tag "modal" %>
</div>

```

- `turbo_stream_from @project, "tasks-container"` subscribe เฉพาะ stream ของ project นี้
- `turbo_frame_tag "modal"` คือ frame ว่างที่รอรับฟอร์ม new/edit ของ task (Step 6)

### Step 6: Modal dialog ด้วย Stimulus

สร้าง controller:

```bash
docker compose exec web bin/rails generate stimulus dialog

```

```js
// app/javascript/controllers/dialog_controller.js
import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  connect() {
    this.frame = this.element.closest("turbo-frame");
    this.element.showModal();
  }

  disconnect() {
    this.frame?.removeAttribute("src");
  }

  close() {
    this.element.close();
  }

  closeOnBackdrop(event) {
    if (event.target === this.element) {
      this.close();
    }
  }

  clear() {
    this.element.remove();
  }
}

```

สร้าง layout partial ของ modal ที่ใช้ร่วมกันทุกหน้า:

```erb
<%# app/views/application/_dialog.html.erb %>
<%= turbo_frame_tag "modal" do %>
  <dialog data-controller="dialog" data-action="close->dialog#clear click->dialog#closeOnBackdrop" class="m-auto w-full max-w-lg rounded-lg p-0 shadow-xl backdrop:bg-black/50">
    <div class="p-6">
      <div class="flex justify-between items-center">
        <h1 class="font-bold text-2xl"><%= title %></h1>
        <button type="button" data-action="dialog#close" aria-label="Close" class="text-2xl leading-none text-gray-500 hover:text-gray-700 cursor-pointer">&times;</button>
      </div>

      <%= yield %>
    </div>
  </dialog>
<% end %>

```

**ลำดับการทำงาน:**

1. ลิงก์ที่มี `data: { turbo_frame: "modal" }` โหลดหน้า new/edit ของ task มาใส่ `<turbo-frame id="modal">`
2. `<dialog>` เข้ามาในหน้า → `connect()` เรียก `showModal()` เปิด modal
3. ปิด modal ได้ 3 ทาง: กดปุ่ม ×, คลิก backdrop (`closeOnBackdrop`) หรือกด Esc
4. `<dialog>` ปิดแล้วเกิด event `close` → `clear()` ลบ element ออก
5. `disconnect()` ลบ `src` ของ frame เพื่อให้กดลิงก์เดิมซ้ำแล้วโหลดใหม่ได้

- **submit สำเร็จ:** controller redirect ไปหน้า edit ของ project ซึ่งมี `turbo_frame_tag "modal"` ว่าง → frame ถูกแทนที่ด้วยเนื้อหาว่าง → modal ปิดเอง
- **submit ไม่ผ่าน:** render `new`/`edit` พร้อม status 422 → frame `modal` ได้ dialog ใหม่ที่มี error

### Step 7: View ของ Task

**รายการ task (อยู่ในหน้า edit ของ project):**

```erb
<%# app/views/tasks/_index.html.erb %>
<%= turbo_frame_tag dom_id(@project, "tasks") do %>
  <div class="w-full space-y-5">
    <div class="flex justify-between items-center">
      <h2 class="font-bold text-2xl">
        Tasks
        <span id="<%= dom_id(@project, "tasks-completed-count") %>" class="text-base font-normal text-gray-500">
          <%= render "tasks/completed_count", project: @project %>
        </span>
      </h2>
      <%= link_to "New task", new_project_task_path(@project), data: { turbo_frame: "modal" }, class: "btn btn-primary block" %>
    </div>

    <div id="task-list" class="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-5">

      <% if @tasks.present? %>

        <% @tasks.each do |task| %>
          <%= render "tasks/task", task: task %>
        <% end %>

      <% end %>

      <p class="empty-state hidden only:block col-span-full">No tasks found.</p>

    </div>
  </div>
<% end %>

```

```erb
<%# app/views/tasks/_completed_count.html.erb %>
(<%= project.tasks.completed.count %>/<%= project.tasks.count %> completed)

```

- **`dom_id(@project, "tasks")`** สร้าง id เช่น `tasks_project_1`
  - ปุ่ม Destroy ใน frame นี้จะอัปเดตเฉพาะ frame หลัง redirect
- **`#task-list`** เป็น target ของ broadcast (Step 9) จึงต้องมีอยู่ในหน้าเสมอ
- **empty state:** `hidden only:block` แสดงข้อความเมื่อ `<p>` เป็นลูกตัวเดียวของ `#task-list`
  - เมื่อมี task ถูก append เข้ามา ข้อความจะซ่อนเองโดยไม่ต้องเขียน JS

**การ์ดของ task:**

```erb
<%# app/views/tasks/_task.html.erb %>
<div id="<%= dom_id(task) %>" class="flex flex-col justify-between h-full rounded-lg border border-gray-200 shadow-sm p-5 space-y-4">
  <div class="space-y-3">

    <div>
      <strong class="detail-label">Title:</strong>
      <%= task.title %>
    </div>

    <div>
      <strong class="detail-label">Status:</strong>
      <%= task_status_badge(task) %>
    </div>
  </div>

  <div class="grid grid-cols-2 gap-2">

    <% if task.pending? %>
      <%= button_to "Mark in progress", make_in_progress_project_task_path(task.project, task), method: :patch, class: "btn btn-secondary w-full" %>
    <% elsif task.in_progress? %>
      <%= button_to "Mark complete", make_completed_project_task_path(task.project, task), method: :patch, class: "btn btn-secondary w-full" %>
    <% end %>

    <%= link_to "Edit", edit_project_task_path(task.project, task), data: { turbo_frame: "modal" }, class: "btn btn-secondary" %>

    <%= button_to "Destroy", [ task.project, task ], method: :delete, form_class: "col-span-2", class: "btn btn-danger w-full", data: { turbo_confirm: "Are you sure?" } %>

  </div>
</div>

```

```ruby

# app/helpers/tasks_helper.rb
module TasksHelper
  TASK_STATUS_BADGE_CLASSES = {
    "pending" => "bg-gray-100 text-gray-800",
    "in_progress" => "bg-yellow-100 text-yellow-800",
    "completed" => "bg-green-100 text-green-800"
  }.freeze

  def task_status_badge(task)
    tag.span task.status.humanize, class: [ "badge", TASK_STATUS_BADGE_CLASSES.fetch(task.status) ]
  end
end

```

**ฟอร์มของ task:**

- ลบช่อง `project_id` ที่ scaffold สร้าง
- เปลี่ยนช่อง `status` จากตัวเลขเป็น select
- ส่งไปถูก route ด้วย `form_with model: [ project, task ]`

```erb
<%# app/views/tasks/_form.html.erb %>
<%= form_with model: [ project, task ], class: "contents" do |form| %>
  <% if task.errors.any? %>
    <div id="error_explanation" class="form-errors">
      <h2><%= pluralize(task.errors.count, "error") %> prohibited this task from being saved:</h2>

      <ul>
        <% task.errors.each do |error| %>
          <li><%= error.full_message %></li>
        <% end %>
      </ul>
    </div>
  <% end %>

  <div class="my-5">
    <%= form.label :title %>
    <%= form.text_field :title, class: ["input", { "input-error": task.errors[:title].any? }] %>
  </div>

  <div class="my-5 flex items-center gap-2">
    <%= form.label :status %>
    <%= form.select :status, Task.statuses.keys.map { |key| [key.humanize, key] }, { prompt: "Select Status" }, { class: ["input", { "input-error": task.errors[:status].any? }] } %>
  </div>

  <div class="inline">
    <%= form.submit class: "btn btn-primary w-full sm:w-auto" %>
  </div>
<% end %>

```

หน้า new และ edit ใช้ layout partial `dialog` จาก Step 6:

```erb
<%# app/views/tasks/new.html.erb %>
<% content_for :title, "New task" %>

<%= render layout: "dialog", locals: { title: "New task" } do %>
  <%= render "form", project: @project, task: @task %>
<% end %>

```

```erb
<%# app/views/tasks/edit.html.erb %>
<% content_for :title, "Editing task" %>

<%= render layout: "dialog", locals: { title: "Editing task" } do %>
  <%= render "form", project: @project, task: @task %>
<% end %>

```

### Step 8: TasksController

```ruby

# app/controllers/tasks_controller.rb
class TasksController < ApplicationController
  before_action :set_project
  before_action :set_task, only: %i[ edit update destroy make_in_progress make_completed ]

  def new
    @task = @project.tasks.new
  end

  def edit
  end

  def create
    @task = @project.tasks.new(task_params)

    if @task.save
      redirect_to edit_project_path(@project), notice: "Task was successfully created."
    else
      render :new, status: :unprocessable_content
    end
  end

  def update
    if @task.update(task_params)
      redirect_to edit_project_path(@project), notice: "Task was successfully updated.", status: :see_other
    else
      render :edit, status: :unprocessable_content
    end
  end

  def destroy
    @task.destroy!

    redirect_to edit_project_path(@project), notice: "Task was successfully destroyed.", status: :see_other
  end

  def make_in_progress
    @task.in_progress!

    respond_to do |format|
      format.turbo_stream { render :update_status }
      format.html { redirect_to edit_project_path(@project), status: :see_other }
    end
  end

  def make_completed
    @task.completed!

    respond_to do |format|
      format.turbo_stream { render :update_status }
      format.html { redirect_to edit_project_path(@project), status: :see_other }
    end
  end

  private
    def set_project
      @project = Project.find(params.expect(:project_id))
    end

    def set_task
      @task = @project.tasks.find(params.expect(:id))
    end

    def task_params
      params.expect(task: [ :title, :status ])
    end
end

```

`make_in_progress` และ `make_completed` ใช้ Turbo Stream template เดียวกัน อัปเดต 2 จุดพร้อมกัน:

```erb
<%# app/views/tasks/update_status.turbo_stream.erb %>
<%= turbo_stream.replace dom_id(@task), partial: "tasks/task", locals: { task: @task } %>

<%= turbo_stream.update dom_id(@project, "tasks-completed-count"), partial: "tasks/completed_count", locals: { project: @project } %>

```

- `replace dom_id(@task)` → แทนที่การ์ดของ task (ปุ่มเปลี่ยนตามสถานะใหม่)
- `update dom_id(@project, "tasks-completed-count")` → อัปเดตตัวเลข `(1/3 completed)`

### Step 9: Real-time

**Task: broadcast การ์ดและจำนวน task ที่เสร็จ**

```ruby

# app/models/task.rb
class Task < ApplicationRecord
  enum :status, { pending: 0, in_progress: 1, completed: 2 }, validate: true

  belongs_to :project

  validates :title, presence: true

  broadcasts_to ->(task) { [ task.project, "tasks-container" ] }, target: "task-list"

  after_commit :broadcast_completed_count, unless: :destroyed_by_association

  private
    def broadcast_completed_count
      broadcast_update_later_to [ project, "tasks-container" ],
        target: ActionView::RecordIdentifier.dom_id(project, "tasks-completed-count"),
        partial: "tasks/completed_count",
        locals: { project: project }
    end
end

```

- **`broadcasts_to`:** create → append ใน `#task-list`, update → replace, destroy → remove
- **stream name** `[ task.project, "tasks-container" ]` ต้องตรงกับ `turbo_stream_from @project, "tasks-container"` ในหน้า edit ของ project
- **`after_commit`:** ทุกครั้งที่ task ถูกสร้าง/แก้/ลบ จะส่งจำนวน task ที่เสร็จใหม่ไปที่ `#tasks-completed-count_project_1`
- **`unless: :destroyed_by_association`:** ข้ามเมื่อ task ถูกลบเพราะลบ project (`dependent: :destroy`)
  - ไม่อย่างนั้น background job จะหา project ที่ถูกลบไปแล้วไม่เจอ

**Project: broadcast ไปหน้ารายการ project**

```ruby

# app/models/project.rb
class Project < ApplicationRecord
  has_many :tasks, dependent: :destroy

  validates :name, presence: true

  broadcasts_to ->(_) { "project-container" }, target: "project-list"
end

```

- ทุกคนที่เปิดหน้ารายการ project (`turbo_stream_from "project-container"`) ได้รับ broadcast
- create → append ใน `#project-list`, update → replace, destroy → remove (render partial `projects/_project`)

**ทดสอบ:**

1. เปิดหน้า edit ของ project เดียวกันใน 2 browser
2. ลองเพิ่ม/แก้/ลบ/เปลี่ยนสถานะ task จะเห็นการ์ดและจำนวน task ที่เสร็จเปลี่ยนทั้งสองหน้าทันที
3. project อื่นจะไม่ได้รับอะไรเลย
4. เปิดหน้ารายการ project ใน browser หนึ่ง แล้วสร้าง/แก้ชื่อ project ในอีก browser จะเห็นรายการอัปเดตเอง

> **Note:** task ไม่ซ้ำในหน้าของคนที่สร้าง เพราะ
>
> - ผู้สร้างได้รับ task ใหม่ผ่าน broadcast เพียงทางเดียว (response ของฟอร์มอัปเดตแค่ frame `modal`)
> - ถ้ามี element ที่ id เดียวกันเป็น**ลูกโดยตรง**ของ target อยู่แล้ว `append` / `prepend` จะแทนที่ของเดิม

> **Security:** workshop นี้ไม่มี authentication ใครก็เปิดและแก้ได้ทุก project ในงานจริงให้:
>
> 1. เพิ่ม authentication (เช่น `bin/rails generate authentication` ของ Rails 8)
> 2. ผูก project กับผู้ใช้
> 3. หา project ผ่าน `Current.user.projects.find` เพื่อให้ทั้งหน้าและ stream เห็นได้เฉพาะผู้ที่มีสิทธิ์
> 4. stream `"project-container"` ใช้ร่วมกันทุกคน ต้องเปลี่ยนเป็น stream ต่อผู้ใช้

### โครงสร้างหลังทำ workshop เสร็จ

- ไฟล์ที่สร้างหรือแก้ใน Step 1-9
- ใช้ตรวจงานของตัวเองหลังทำเสร็จ หรือเทียบกับ [branch `hotwire/demo`](https://github.com/paradon-sg/BC-Bootcamp/tree/hotwire/demo)

```
hotwire-bootcamp/
├── app/
│   ├── assets/
│   │   └── tailwind/
│   │       └── application.css                 # component class: btn, input, badge, ...
│   ├── controllers/
│   │   ├── projects_controller.rb              # CRUD project (ไม่มี show), edit แสดง tasks
│   │   └── tasks_controller.rb                 # CRUD task + make_in_progress / make_completed
│   ├── helpers/
│   │   └── tasks_helper.rb                     # task_status_badge
│   ├── javascript/
│   │   └── controllers/
│   │       ├── dialog_controller.js            # เปิด/ปิด <dialog> ใน frame modal
│   │       └── index.js                        # register dialog controller
│   ├── models/
│   │   ├── project.rb                          # has_many :tasks + broadcasts_to project-list
│   │   └── task.rb                             # enum status + broadcasts_to + completed count
│   └── views/
│       ├── application/
│       │   └── _dialog.html.erb                # layout ของ modal (turbo_frame_tag "modal")
│       ├── layouts/
│       │   └── application.html.erb            # flash message
│       ├── projects/
│       │   ├── _form.html.erb
│       │   ├── _project.html.erb
│       │   ├── index.html.erb                  # turbo_stream_from "project-container" + #project-list
│       │   ├── new.html.erb
│       │   └── edit.html.erb                   # turbo_stream_from + tasks/index + frame modal
│       └── tasks/
│           ├── _index.html.erb                 # frame ของรายการ task + #task-list
│           ├── _task.html.erb                  # การ์ด task (ใช้ซ้ำทั้งใน view, stream และ broadcast)
│           ├── _completed_count.html.erb       # (x/y completed)
│           ├── _form.html.erb                  # form_with model: [ project, task ]
│           ├── new.html.erb                    # render layout: "dialog"
│           ├── edit.html.erb                   # render layout: "dialog"
│           └── update_status.turbo_stream.erb  # replace การ์ด + update completed count
├── config/
│   └── routes.rb                               # projects (except: :show) + tasks (nested + member)
└── db/
    ├── migrate/
    │   ├── xxxxxxxxxxxxxx_create_projects.rb
    │   └── xxxxxxxxxxxxxx_create_tasks.rb      # project_id FK, title (not null), status (default 0)
    └── schema.rb

```

## 13. Best Practices & Common Pitfalls

**Best Practices:**

- เริ่มจาก **HTML ปกติ + Turbo Drive** ก่อน แล้วค่อยเพิ่ม Frames → Streams → Stimulus เมื่อจำเป็น
- ใช้ **partial เดียว** (`_task.html.erb`) ทั้งใน index, frame, stream และ broadcast
- ใช้ `dom_id` / `turbo_frame_tag record` แทนการพิมพ์ id เอง
- ใส่ `format.html` fallback ทุกครั้งที่ใช้ `format.turbo_stream`
- Stimulus controller ควรเล็ก, generic และรับค่าผ่าน Values
- ใช้ `_later` broadcasts และระวัง N+1 ใน partial ที่ถูก broadcast

**Common Pitfalls:**

| ปัญหา                            | สาเหตุ / วิธีแก้                                                                                         |
| ------------------------------- | ---------------------------------------------------------------------------------------------------- |
| Form error ไม่แสดง               | ลืม `status: :unprocessable_content` ตอน render form                                                  |
| submit แล้ว redirect ผิด / ลบซ้ำ    | ใช้ `redirect_to ..., status: :see_other` หลังทุก POST/PATCH/DELETE                                     |
| submit แล้วหน้าไม่เปลี่ยน            | ตอบ 200 กับ POST โดยไม่ redirect ให้ redirect 303 หรือ render 4xx                                        |
| เห็น "Content missing" ใน frame  | response ไม่มี `<turbo-frame>` ที่ id ตรงกัน (เช่นถูก redirect ไปหน้า login ใช้ `turbo_page_requires_reload`) |
| กด Back แล้ว flash message โผล่อีก | ใส่ `data-turbo-temporary` ที่ element ของ flash                                                        |
| hover ลิงก์แล้วข้อมูลเปลี่ยน           | GET route มี side effect + prefetch ให้ใช้ `button_to` / POST แทน                                       |
| JS ทำงานแค่หน้าแรก                 | ใช้ `DOMContentLoaded` ให้เปลี่ยนเป็น Stimulus `connect()`                                                |
| Broadcast ไม่มา                  | ลืม `turbo_stream_from` หรือชื่อ stream ไม่ตรงกัน                                                          |
| ข้อมูลหลุดไปให้ผู้ใช้อื่น                | stream ไม่ได้ scope ตาม user/permission                                                                |
| ลิงก์ใน frame ไม่เปลี่ยนทั้งหน้า        | ใส่ `data: { turbo_frame: "_top" }`                                                                   |

## 14. Resources

- Hotwire: https://hotwired.dev
- Turbo Handbook: https://turbo.hotwired.dev/handbook/introduction
- Turbo Reference (Drive, Frames, Streams, Events, Attributes): https://turbo.hotwired.dev/reference/drive
- Stimulus Handbook: https://stimulus.hotwired.dev/handbook/introduction
- Stimulus Reference: https://stimulus.hotwired.dev/reference/controllers
- turbo-rails: https://github.com/hotwired/turbo-rails
- stimulus-rails: https://github.com/hotwired/stimulus-rails
- Hotwire Native: https://native.hotwired.dev
- Hotwire Native, How it works: https://native.hotwired.dev/overview/how-it-works
- Rails Guides: https://guides.rubyonrails.org
