# Hotwire Bootcamp

## Table of Contents

1. [Prerequisites](#1-prerequisites)
2. [What is Hotwire?](#2-what-is-hotwire)
3. [Environment Setup](#3-environment-setup)
4. [Project Structure](#4-project-structure)
5. [SPA vs HTML over the wire](#5-spa-vs-html-over-the-wire)
6. [Turbo Drive](#6-turbo-drive)
7. [Turbo Frames](#7-turbo-frames)
8. [Turbo Streams](#8-turbo-streams)
9. [Broadcasting (Real-time)](#9-broadcasting-real-time)
10. [Page Refresh & Morphing](#10-page-refresh--morphing)
11. [Stimulus](#11-stimulus)
12. [Workshop: Task App](#12-workshop-task-app)
13. [Testing](#13-testing)
14. [Best Practices & Common Pitfalls](#14-best-practices--common-pitfalls)
15. [Resources](#15-resources)

## 1. Prerequisites

**ความรู้พื้นฐานที่จำเป็น:**

- พื้นฐาน Ruby และ Ruby on Rails (MVC, Routing, ActiveRecord)
- ความรู้ HTML/CSS
- พื้นฐาน JavaScript (ES modules, class, event)
- ติดตั้ง Ruby 3.4+ และ Rails 8+
- ติดตั้ง Node.js LTS และ Yarn (ใช้สำหรับ esbuild)
- ติดตั้ง VS Code พร้อม Ruby LSP Extension

## 2. What is Hotwire?

**Hotwire (HTML Over The Wire)** คือแนวทางการสร้างเว็บแอปที่รู้สึกเร็วเหมือน SPA โดยส่ง **HTML** จาก Server แทน **JSON** ทำให้เขียน JavaScript น้อยลงมาก และ logic ส่วนใหญ่ยังอยู่ที่ฝั่ง Server

Hotwire ประกอบด้วย 3 ส่วนหลัก:

| ส่วนประกอบ        | หน้าที่                                                          |
| ----------------- | ---------------------------------------------------------------- |
| **Turbo**         | ทำให้การเปลี่ยนหน้า, การ submit form และการอัปเดตบางส่วนของหน้าเร็วขึ้น โดยไม่ต้องเขียน JS |
| **Stimulus**      | JavaScript framework ขนาดเล็ก สำหรับเพิ่ม behavior ให้ HTML ที่มีอยู่แล้ว |
| **Hotwire Native** | นำเว็บแอป Hotwire ไปทำเป็นแอป iOS / Android                     |

ส่วน **Turbo** แบ่งย่อยเป็น:

- **Turbo Drive:** เปลี่ยนหน้าโดยไม่ reload ทั้งหน้า
- **Turbo Frames:** อัปเดตเฉพาะบางส่วนของหน้า
- **Turbo Streams:** สั่งเพิ่ม/แก้/ลบ element หลายจุดพร้อมกัน ทั้งจาก HTTP response และ WebSocket

**ทำไมต้อง Hotwire?**

- **Less JavaScript:** ไม่ต้องสร้าง API + Frontend app แยก ลดโค้ดและความซับซ้อน
- **Server is the source of truth:** Business logic, validation, authorization อยู่ที่ Rails ที่เดียว
- **Fast by default:** ได้ความเร็วแบบ SPA จาก Turbo Drive โดยไม่ต้องตั้งค่า
- **Built into Rails:** Rails 7+ ติดตั้ง Hotwire มาให้แล้วตั้งแต่ `rails new`
- **Progressive enhancement:** ถ้า JS ไม่ทำงาน ฟอร์มและลิงก์ยังทำงานแบบ HTML ปกติได้

> **Tip:** Hotwire ไม่ได้มาแทน React/Angular ในทุกกรณี ถ้า UI มี state ซับซ้อนมาก (เช่น editor, dashboard แบบ interactive สูง) SPA อาจเหมาะกว่า

## 3. Environment Setup

**การตั้งค่าสภาพแวดล้อม:**

```bash
ruby -v
rails -v
node -v
yarn -v
gem install rails
```

สร้างโปรเจกต์ใหม่ด้วย **esbuild** (Rails 8 ติดตั้ง Turbo + Stimulus มาให้แล้ว):

```bash
rails new hotwire-bootcamp -j esbuild
cd hotwire-bootcamp
bin/rails db:prepare
bin/dev
```

`bin/dev` จะรัน Rails server และ esbuild แบบ `--watch` พร้อมกัน (ตาม `Procfile.dev`) ทุกครั้งที่แก้ไฟล์ JS, esbuild จะ build ใหม่ไปที่ `app/assets/builds/` ให้อัตโนมัติ

ตรวจสอบว่า Hotwire ถูกติดตั้งแล้ว:

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
    "@hotwired/turbo-rails": "...",
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

**Importmap vs esbuild:**

| หัวข้อ               | Importmap (default)               | esbuild                                 |
| -------------------- | --------------------------------- | --------------------------------------- |
| ต้องมี Node.js        | ไม่ต้อง                            | ต้อง                                     |
| Build step           | ไม่มี                              | มี (`yarn build`)                         |
| npm packages         | pin ผ่าน `bin/importmap pin`       | `yarn add` ได้ทุก package                 |
| TypeScript / JSX     | ไม่รองรับ                          | รองรับ                                   |
| เหมาะกับ             | แอปที่ใช้ JS น้อย                   | ทีมที่ใช้ npm ecosystem หรือ TypeScript    |

> **Note:** ถ้ามีโปรเจกต์ที่ใช้ importmap อยู่แล้ว เปลี่ยนเป็น esbuild ได้ด้วย `bundle add jsbundling-rails` แล้วรัน `bin/rails javascript:install:esbuild` จากนั้นลบ `importmap-rails`, `config/importmap.rb` และ `javascript_importmap_tags` ใน layout

## 4. Project Structure

**ไฟล์ที่เกี่ยวข้องกับ Hotwire ในโปรเจกต์ Rails 8:**

```
hotwire-bootcamp/
├── app/
│   ├── controllers/                  # Rails controllers (respond_to turbo_stream)
│   ├── models/                       # Models (broadcasts)
│   ├── views/
│   │   ├── layouts/
│   │   │   └── application.html.erb  # javascript_include_tag, turbo meta tags
│   │   └── tasks/
│   │       ├── _task.html.erb        # Partial ที่ใช้ซ้ำทั้งใน frame และ stream
│   │       ├── index.html.erb
│   │       └── create.turbo_stream.erb  # Turbo Stream response
│   ├── assets/
│   │   └── builds/                   # ไฟล์ที่ esbuild build ออกมา (ไม่ต้อง commit)
│   └── javascript/
│       ├── application.js            # Entry point: import Turbo + Stimulus
│       └── controllers/              # Stimulus controllers
│           ├── application.js        # Stimulus application instance
│           ├── index.js              # Register controllers (generate อัตโนมัติ)
│           └── hello_controller.js
├── config/
│   └── cable.yml                     # Action Cable (สำหรับ broadcast)
├── Gemfile
├── package.json                      # JS dependencies + build script ของ esbuild
└── Procfile.dev                      # bin/dev: รัน Rails server + esbuild --watch
```

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
  - ติดตั้ง package ด้วย `yarn add <package>` แล้ว import ใน JS ได้เลย

- **`app/views/**/*.turbo_stream.erb`**: Template สำหรับตอบกลับเป็น Turbo Stream
  - ใช้เมื่อต้องการอัปเดตหลายจุดในหน้าหลัง submit form

## 5. SPA vs HTML over the wire

- **SPA (เช่น Angular, React):** Server ส่ง **JSON** → Browser รัน JavaScript เพื่อสร้าง HTML เอง → ต้องมี state, routing, validation ซ้ำทั้งสองฝั่ง

- **Hotwire:** Server render **HTML** ให้เลย → Turbo นำ HTML ที่ได้ไปแทนที่ในหน้าเว็บ → logic อยู่ที่ Server ที่เดียว

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

| หัวข้อ             | SPA                         | Hotwire                       |
| ------------------ | --------------------------- | ----------------------------- |
| Data format        | JSON                        | HTML                          |
| Rendering          | Client                      | Server                        |
| Routing            | Client + Server             | Server                        |
| Validation         | ทั้งสองฝั่ง                  | Server                        |
| JavaScript ที่เขียน | มาก                         | น้อย (เฉพาะ Stimulus)          |
| เหมาะกับ           | UI ซับซ้อน, offline, mobile-first | CRUD app, admin, SaaS ทั่วไป |

## 6. Turbo Drive

Turbo Drive จะ **ดักทุกการคลิกลิงก์และการ submit form** แล้วส่ง request ด้วย `fetch` จากนั้นนำ `<body>` ใหม่มาแทนที่ของเดิม และ merge `<head>` ให้ **โดยไม่ reload ทั้งหน้า**

ผลลัพธ์คือ CSS/JS ไม่ต้องโหลดใหม่ทุกครั้ง หน้าเว็บจึงรู้สึกเร็วเหมือน SPA

**ไม่ต้องเขียนโค้ดเพิ่ม** แค่ import `@hotwired/turbo-rails` ก็ทำงานทันที

### ปิด Turbo Drive เฉพาะจุด

```erb
<%= link_to "Download PDF", report_path(format: :pdf), data: { turbo: false } %>

<%= form_with model: @upload, data: { turbo: false } do |f| %>
  ...
<% end %>
```

### Link ที่ใช้ HTTP method อื่น

```erb
<%= link_to "Delete", task_path(task),
      data: { turbo_method: :delete, turbo_confirm: "ลบใช่ไหม?" } %>

<%# แนะนำใช้ button_to สำหรับ action ที่เปลี่ยนข้อมูล %>
<%= button_to "Delete", task_path(task), method: :delete,
      form: { data: { turbo_confirm: "ลบใช่ไหม?" } } %>
```

### Form submission rules

Turbo Drive ต้องการ response ที่ถูกต้องหลัง submit form:

```ruby
def create
  @task = Task.new(task_params)

  if @task.save
    redirect_to tasks_path, notice: "Task created."
  else
    # ต้องส่ง 422 ไม่อย่างนั้น Turbo จะไม่ render error
    render :new, status: :unprocessable_entity
  end
end

def destroy
  @task.destroy
  # ใช้ 303 See Other หลัง DELETE
  redirect_to tasks_path, status: :see_other
end
```

### Prefetch และ Asset tracking

- **Prefetch:** Turbo 8 จะ prefetch ลิงก์เมื่อ hover ทำให้คลิกแล้วแสดงผลแทบทันที
- **`data-turbo-track="reload"`:** ถ้าไฟล์ CSS/JS เปลี่ยน (deploy ใหม่) Turbo จะ reload ทั้งหน้าอัตโนมัติ

```erb
<%= stylesheet_link_tag :app, "data-turbo-track": "reload" %>
<%= link_to "Heavy page", heavy_path, data: { turbo_prefetch: false } %>
```

### Turbo events

เพราะหน้าไม่ได้ reload จริง `DOMContentLoaded` จะทำงานแค่ครั้งแรก ให้ใช้ `turbo:load` แทน (หรือดีกว่านั้นคือใช้ Stimulus)

```js
document.addEventListener("turbo:load", () => {
  console.log("page loaded")
})
```

> **Best Practice:** หลีกเลี่ยงการเขียน JS ใน `turbo:load` ให้ย้ายไปเป็น Stimulus controller ซึ่งมี `connect()` / `disconnect()` ที่ทำงานถูกต้องเสมอ

## 7. Turbo Frames

Turbo Frames คือการแบ่งหน้าเว็บเป็น **ส่วนย่อยที่อัปเดตแยกกันได้** ลิงก์และฟอร์มภายใน frame จะอัปเดตเฉพาะ frame นั้น ไม่ใช่ทั้งหน้า

**หลักการ:** Server ส่ง HTML ทั้งหน้ากลับมา → Turbo หา `<turbo-frame>` ที่มี **id เดียวกัน** → แทนที่เฉพาะส่วนนั้น

### Inline edit

```erb
<%# app/views/tasks/_task.html.erb %>
<%= turbo_frame_tag task do %>
  <p><%= task.title %></p>
  <%= link_to "Edit", edit_task_path(task) %>
<% end %>
```

```erb
<%# app/views/tasks/edit.html.erb %>
<h1>Edit task</h1>

<%= turbo_frame_tag @task do %>
  <%= render "form", task: @task %>
<% end %>
```

`turbo_frame_tag task` จะสร้าง `<turbo-frame id="task_1">` ให้อัตโนมัติ (ใช้ `dom_id`)

เมื่อคลิก "Edit" → Turbo โหลด `/tasks/1/edit` → ดึงเฉพาะ `<turbo-frame id="task_1">` มาแทนที่ → ได้ inline edit โดยไม่ต้องเขียน JS เลย

### Lazy loading

โหลดเนื้อหาทีหลัง เช่น ส่วนที่ query ช้า:

```erb
<%= turbo_frame_tag "stats", src: stats_path, loading: :lazy do %>
  <p>Loading...</p>
<% end %>
```

### Navigate ออกนอก frame

```erb
<%# ลิงก์นี้อยู่ใน frame แต่ต้องการเปลี่ยนทั้งหน้า %>
<%= link_to "View", task_path(task), data: { turbo_frame: "_top" } %>

<%# ให้ทุกลิงก์ใน frame เปลี่ยนทั้งหน้า %>
<%= turbo_frame_tag "nav", target: "_top" do %>
  ...
<% end %>

<%# อัปเดต URL ใน address bar ด้วย %>
<%= turbo_frame_tag "results", data: { turbo_action: "advance" } do %>
  ...
<% end %>
```

> **Note:** ถ้า response ไม่มี frame id ที่ตรงกัน จะเห็นข้อความ **"Content missing"** ให้ตรวจว่า id ของ frame ทั้งสองหน้าตรงกัน

## 8. Turbo Streams

Turbo Streams ใช้เมื่อต้องการ **อัปเดตหลายจุดในหน้าพร้อมกัน** หรือแก้ element ที่ไม่ได้อยู่ใน frame

Turbo Stream คือ HTML element ที่บอกว่า "ทำ action อะไร กับ element id ไหน":

```html
<turbo-stream action="prepend" target="tasks">
  <template>
    <div id="task_5">Buy milk</div>
  </template>
</turbo-stream>
```

### Actions

| Action    | ผลลัพธ์                                   |
| --------- | ----------------------------------------- |
| `append`  | เพิ่มต่อท้ายใน target                      |
| `prepend` | เพิ่มไว้ด้านบนใน target                    |
| `replace` | แทนที่ target ทั้ง element                 |
| `update`  | แทนที่เฉพาะเนื้อหาข้างใน target              |
| `remove`  | ลบ target                                 |
| `before`  | เพิ่มก่อน target                           |
| `after`   | เพิ่มหลัง target                           |
| `refresh` | สั่งให้หน้า refresh (ใช้กับ morphing)        |

### ตอบกลับ Turbo Stream จาก Controller

```ruby
def create
  @task = Task.new(task_params)

  respond_to do |format|
    if @task.save
      format.turbo_stream  # render create.turbo_stream.erb
      format.html { redirect_to tasks_path }
    else
      format.html { render :new, status: :unprocessable_entity }
    end
  end
end
```

```erb
<%# app/views/tasks/create.turbo_stream.erb %>
<%= turbo_stream.prepend "tasks", @task %>
<%= turbo_stream.update "task_count", Task.count %>
<%= turbo_stream.update "flash", partial: "shared/flash", locals: { notice: "Task created." } %>
```

`turbo_stream.prepend "tasks", @task` จะ render partial `tasks/_task.html.erb` ให้อัตโนมัติ

### Inline ใน controller (กรณีสั้น ๆ)

```ruby
def destroy
  @task.destroy

  respond_to do |format|
    format.turbo_stream { render turbo_stream: turbo_stream.remove(@task) }
    format.html { redirect_to tasks_path, status: :see_other }
  end
end
```

> **Best Practice:** ใส่ `format.html` ไว้เสมอเพื่อ fallback กรณีที่ไม่ได้ request ผ่าน Turbo

### Frames vs Streams ใช้อันไหน?

| สถานการณ์                                 | ใช้          |
| ---------------------------------------- | ------------ |
| อัปเดตส่วนเดียว เช่น inline edit, tabs, pagination | Turbo Frame  |
| อัปเดตหลายจุดพร้อมกัน                       | Turbo Stream |
| อัปเดต real-time ให้ผู้ใช้คนอื่น                | Turbo Stream + Broadcast |

## 9. Broadcasting (Real-time)

Turbo Streams สามารถส่งผ่าน **WebSocket (Action Cable)** ได้ ทำให้ผู้ใช้ทุกคนที่เปิดหน้าเดียวกันเห็นการเปลี่ยนแปลงทันที

Rails 8 ใช้ **Solid Cable** เป็น adapter ของ Action Cable โดย default จึงไม่ต้องมี Redis

### 1) Model: broadcast เมื่อข้อมูลเปลี่ยน

```ruby
class Task < ApplicationRecord
  belongs_to :project

  # create → prepend, update → replace, destroy → remove
  broadcasts_to :project, inserts_by: :prepend
end
```

หรือเขียนแบบ explicit:

```ruby
class Task < ApplicationRecord
  belongs_to :project

  after_create_commit  -> { broadcast_prepend_later_to project, target: "tasks" }
  after_update_commit  -> { broadcast_replace_later_to project }
  after_destroy_commit -> { broadcast_remove_to project }
end
```

### 2) View: subscribe stream

```erb
<%# app/views/projects/show.html.erb %>
<%= turbo_stream_from @project %>

<div id="tasks">
  <%= render @project.tasks %>
</div>
```

> **Security:** Stream name ถูก sign โดย Rails ผู้ใช้จึงปลอมชื่อ stream เองไม่ได้ แต่ใครก็ตามที่เปิดหน้านั้นได้จะได้รับ broadcast ด้วย ให้ **scope stream ตามสิทธิ์** (เช่น ต่อ project หรือต่อ user) และอย่า broadcast ข้อมูล sensitive ไปยัง stream ที่ใช้ร่วมกัน

> **Tip:** ใช้ method ที่ลงท้ายด้วย `_later` เพื่อ render และส่งผ่าน background job ไม่ block request

## 10. Page Refresh & Morphing

Turbo 8 เพิ่มแนวทางที่ง่ายขึ้น: แทนที่จะเขียน stream ทีละ action ให้ **refresh ทั้งหน้าแบบ morph** คือ Turbo จะเปรียบเทียบ DOM เก่ากับใหม่ แล้วเปลี่ยนเฉพาะส่วนที่ต่างกัน พร้อมรักษาตำแหน่ง scroll ไว้

```erb
<%# app/views/layouts/application.html.erb (ใน <head>) %>
<%= turbo_refreshes_with method: :morph, scroll: :preserve %>
```

ใช้ร่วมกับ broadcast:

```ruby
class Task < ApplicationRecord
  belongs_to :project
  broadcasts_refreshes_to :project
end
```

```erb
<%= turbo_stream_from @project %>
```

เมื่อ task เปลี่ยน → ทุกคนที่เปิดหน้า project ได้รับคำสั่ง `refresh` → หน้าโหลด HTML ใหม่แล้ว morph เฉพาะส่วนที่ต่างกัน

ป้องกันไม่ให้ element ถูก morph (เช่น form ที่ผู้ใช้กำลังพิมพ์):

```erb
<div id="draft" data-turbo-permanent>...</div>
```

> **Best Practice:** เริ่มจาก **morphing + `broadcasts_refreshes`** ก่อน เพราะเขียนน้อยที่สุด แล้วค่อยเปลี่ยนไปใช้ Turbo Stream action เฉพาะจุดเมื่อมีปัญหาเรื่อง performance

## 11. Stimulus

Stimulus คือ JavaScript framework ขนาดเล็กที่ **เพิ่ม behavior ให้ HTML ที่ Server render มาแล้ว** ไม่ได้ render HTML เอง

แนวคิด: HTML เป็นตัวบอกว่าจะใช้ controller อะไร ผ่าน `data-*` attributes

### Core concepts

| Concept        | Attribute                              | หน้าที่                            |
| -------------- | -------------------------------------- | -------------------------------- |
| **Controller** | `data-controller="counter"`            | ผูก JS class กับ element          |
| **Action**     | `data-action="click->counter#increment"` | ผูก event กับ method              |
| **Target**     | `data-counter-target="output"`         | อ้างอิง element ภายใน controller  |
| **Value**      | `data-counter-count-value="0"`         | ส่งข้อมูลจาก HTML เข้า controller  |
| **Class**      | `data-counter-active-class="is-active"` | ส่งชื่อ CSS class เข้า controller |
| **Outlet**     | `data-counter-modal-outlet="#modal"`   | อ้างอิง controller อื่น            |

### ตัวอย่าง: Counter

สร้าง controller:

```bash
bin/rails generate stimulus counter
```

คำสั่งนี้จะสร้าง `counter_controller.js` และ register ใน `controllers/index.js` ให้อัตโนมัติ

```js
// app/javascript/controllers/counter_controller.js
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["output"]
  static values = { count: { type: Number, default: 0 } }

  increment() {
    this.countValue++
  }

  // ทำงานอัตโนมัติเมื่อ countValue เปลี่ยน
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

```js
export default class extends Controller {
  connect() {
    // element ถูกเพิ่มเข้า DOM (รวมถึงหลัง Turbo เปลี่ยนหน้า)
  }

  disconnect() {
    // element ถูกลบออกจาก DOM: clear timer, remove listener ที่นี่
  }
}
```

### ตัวอย่าง: Auto-submit form

```js
// app/javascript/controllers/auto_submit_controller.js
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  submit() {
    this.element.requestSubmit()
  }
}
```

```erb
<%= form_with model: task, data: { controller: "auto-submit" } do |f| %>
  <%= f.check_box :completed, data: { action: "change->auto-submit#submit" } %>
<% end %>
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
<%= form_with model: Task.new,
      data: { controller: "reset-form", action: "turbo:submit-end->reset-form#reset" } do |f| %>
  ...
<% end %>
```

> **Best Practice:** เขียน controller ให้เล็กและ reusable (เช่น `auto-submit`, `clipboard`, `toggle`) แทนการเขียน controller ผูกกับหน้าใดหน้าหนึ่ง

## 12. Workshop: Task App

สร้าง Task app ที่มี inline edit, เพิ่มงานโดยไม่ reload, toggle สถานะ และ real-time

### ER Diagram

Workshop นี้ใช้ตารางเดียวคือ `tasks`:

```mermaid
erDiagram
  TASK {
    bigint id PK
    string title "required (validates presence)"
    boolean completed "default: false"
    datetime created_at
    datetime updated_at
  }
```

**ต่อยอด:** ตัวอย่างในหัวข้อ [Broadcasting](#9-broadcasting-real-time) และ [Page Refresh & Morphing](#10-page-refresh--morphing) ใช้ `Project` ที่มีหลาย `Task` และผูกกับ `User` เพื่อ scope stream ตามเจ้าของ:

```mermaid
erDiagram
  USER ||--o{ PROJECT : owns
  PROJECT ||--o{ TASK : has

  USER {
    bigint id PK
    string email_address "unique"
  }
  PROJECT {
    bigint id PK
    bigint user_id FK
    string name
  }
  TASK {
    bigint id PK
    bigint project_id FK
    string title
    boolean completed
  }
```

| Relationship        | Rails association                                             | Turbo stream                              |
| ------------------- | ------------------------------------------------------------- | ----------------------------------------- |
| User → Projects     | `User has_many :projects` / `Project belongs_to :user`        | `turbo_stream_from current_user, :projects` |
| Project → Tasks     | `Project has_many :tasks` / `Task belongs_to :project`        | `turbo_stream_from @project`              |

```bash
bin/rails generate model Project user:references name:string
bin/rails generate model Task project:references title:string completed:boolean
```

> **Note:** `references` สร้าง foreign key และ index ให้อัตโนมัติ ส่วน `completed` ควรตั้ง `default: false, null: false` ใน migration

### Step 1: Scaffold

```bash
bin/rails generate scaffold Task title:string completed:boolean
```

แก้ migration ให้ `completed` มีค่า default ก่อน migrate:

```ruby
# db/migrate/xxxxxxxxxxxxxx_create_tasks.rb
t.boolean :completed, default: false, null: false
```

```bash
bin/rails db:migrate
```

### Step 2: Partial ที่ครอบด้วย Frame

```erb
<%# app/views/tasks/_task.html.erb %>
<%= turbo_frame_tag task do %>
  <div>
    <%= form_with model: task, data: { controller: "auto-submit" } do |f| %>
      <%= f.check_box :completed, data: { action: "change->auto-submit#submit" } %>
    <% end %>

    <span><%= task.title %></span>

    <%= link_to "Edit", edit_task_path(task) %>
    <%= button_to "Delete", task, method: :delete,
          form: { data: { turbo_confirm: "ลบใช่ไหม?" } } %>
  </div>
<% end %>
```

### Step 3: Index พร้อมฟอร์มสร้างงานและ stream

```erb
<%# app/views/tasks/index.html.erb %>
<%= turbo_stream_from "tasks" %>

<h1>Tasks</h1>

<%= turbo_frame_tag "new_task" do %>
  <%= render "form", task: Task.new %>
<% end %>

<div id="tasks">
  <%= render @tasks %>
</div>
```

### Step 4: Controller

```ruby
class TasksController < ApplicationController
  before_action :set_task, only: %i[show edit update destroy]

  def index
    @tasks = Task.order(created_at: :desc)
  end

  def create
    @task = Task.new(task_params)

    respond_to do |format|
      if @task.save
        format.turbo_stream
        format.html { redirect_to tasks_path, notice: "Task created." }
      else
        format.turbo_stream do
          render turbo_stream: turbo_stream.update("new_task", partial: "tasks/form", locals: { task: @task }),
                 status: :unprocessable_entity
        end
        format.html { render :new, status: :unprocessable_entity }
      end
    end
  end

  def update
    if @task.update(task_params)
      redirect_to @task  # show.html.erb render _task ซึ่งมี frame id เดียวกัน
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @task.destroy

    respond_to do |format|
      format.turbo_stream { render turbo_stream: turbo_stream.remove(@task) }
      format.html { redirect_to tasks_path, status: :see_other }
    end
  end

  private

  def set_task
    @task = Task.find(params.expect(:id))
  end

  def task_params
    params.expect(task: %i[title completed])
  end
end
```

```erb
<%# app/views/tasks/create.turbo_stream.erb %>
<%= turbo_stream.prepend "tasks", @task %>
<%= turbo_stream.update "new_task", partial: "tasks/form", locals: { task: Task.new } %>
```

```erb
<%# app/views/tasks/show.html.erb %>
<%= render @task %>
```

### Step 5: Real-time

```ruby
class Task < ApplicationRecord
  validates :title, presence: true

  broadcasts_to ->(_task) { "tasks" }, inserts_by: :prepend
end
```

เปิด 2 browser แล้วลองเพิ่ม/แก้/ลบ task จะเห็นการเปลี่ยนแปลงทั้งสองหน้าทันที

> **Note:** ถ้า element ที่ id เดียวกันมีอยู่แล้ว `append` / `prepend` จะแทนที่ของเดิม จึงไม่เกิด task ซ้ำในหน้าของคนที่สร้าง

> **Security:** stream `"tasks"` ในตัวอย่างนี้ทุกคนเห็นเหมือนกัน ในงานจริงให้ scope ตาม owner เช่น `broadcasts_to ->(task) { [task.user, :tasks] }` และ `turbo_stream_from current_user, :tasks`

## 13. Testing

Rails ใช้ **Minitest** เป็น default และ `turbo-rails` มี assertion สำหรับ Turbo มาให้แล้ว ไม่ต้องติดตั้งอะไรเพิ่ม

```bash
bin/rails test          # รัน unit + integration tests
bin/rails test:system   # รัน system tests (ใช้ browser จริง)
```

### Integration test: Turbo Stream response

ทดสอบว่า controller ตอบ Turbo Stream ถูกต้อง โดยใช้ `as: :turbo_stream` และ `assert_turbo_stream`:

```ruby
# test/controllers/tasks_controller_test.rb
require "test_helper"

class TasksControllerTest < ActionDispatch::IntegrationTest
  test "create prepends the new task via turbo stream" do
    assert_difference("Task.count", 1) do
      post tasks_url, params: { task: { title: "Buy milk" } }, as: :turbo_stream
    end

    assert_turbo_stream action: :prepend, target: "tasks" do
      assert_select "template", text: /Buy milk/
    end
  end

  test "create returns 422 when title is blank" do
    assert_no_difference("Task.count") do
      post tasks_url, params: { task: { title: "" } }, as: :turbo_stream
    end

    assert_response :unprocessable_entity
  end

  test "destroy removes the task via turbo stream" do
    task = tasks(:one)

    delete task_url(task), as: :turbo_stream

    assert_turbo_stream action: :remove, target: task
  end

  test "destroy redirects with 303 for HTML requests" do
    delete task_url(tasks(:one))

    assert_redirected_to tasks_url
    assert_response :see_other
  end
end
```

### Model test: Broadcast

ทดสอบว่า model broadcast ไปยัง stream ที่ถูกต้อง ด้วย `Turbo::Broadcastable::TestHelper`:

```ruby
# test/models/task_test.rb
require "test_helper"

class TaskTest < ActiveSupport::TestCase
  include Turbo::Broadcastable::TestHelper

  test "broadcasts to the tasks stream when created" do
    perform_enqueued_jobs do
      Task.create!(title: "Buy milk")
    end

    assert_turbo_stream_broadcasts "tasks"
  end
end
```

> **Note:** ใช้ `perform_enqueued_jobs` เพราะ `broadcasts_to` ส่ง broadcast ผ่าน background job (`_later`)

### System test

ใช้ทดสอบ flow ที่ต้องรัน JavaScript จริง (Turbo + Stimulus):

```ruby
# test/application_system_test_case.rb
require "test_helper"

class ApplicationSystemTestCase < ActionDispatch::SystemTestCase
  driven_by :selenium, using: :headless_chrome, screen_size: [1400, 1400]
end
```

```ruby
# test/system/tasks_test.rb
require "application_system_test_case"

class TasksTest < ApplicationSystemTestCase
  include ActionView::RecordIdentifier # สำหรับ dom_id

  test "creating a task without reloading the page" do
    visit tasks_url

    fill_in "Title", with: "Write slides"
    click_on "Create Task"

    within("#tasks") { assert_text "Write slides" }
  end

  test "editing a task inline" do
    task = tasks(:one)
    visit tasks_url

    within("##{dom_id(task)}") { click_on "Edit" }
    fill_in "Title", with: "Updated title"
    click_on "Update Task"

    within("##{dom_id(task)}") { assert_text "Updated title" }
    assert_current_path tasks_path
  end
end
```

`assert_current_path tasks_path` ยืนยันว่า inline edit เกิดใน frame โดยไม่เปลี่ยนหน้า

> **Best Practice:** ใช้ integration test เป็นหลักเพราะเร็วและเสถียร ใช้ system test เฉพาะ flow สำคัญที่ต้องพึ่ง JavaScript

## 14. Best Practices & Common Pitfalls

**Best Practices:**

- เริ่มจาก **HTML ปกติ + Turbo Drive** ก่อน แล้วค่อยเพิ่ม Frames → Streams → Stimulus เมื่อจำเป็น
- ใช้ **partial เดียว** (`_task.html.erb`) ทั้งใน index, frame, stream และ broadcast
- ใช้ `dom_id` / `turbo_frame_tag record` แทนการพิมพ์ id เอง
- ใส่ `format.html` fallback ทุกครั้งที่ใช้ `format.turbo_stream`
- Stimulus controller ควรเล็ก, generic และรับค่าผ่าน Values
- ใช้ `_later` broadcasts และระวัง N+1 ใน partial ที่ถูก broadcast

**Common Pitfalls:**

| ปัญหา                                     | สาเหตุ / วิธีแก้                                        |
| ---------------------------------------- | ----------------------------------------------------- |
| Form error ไม่แสดง                        | ลืม `status: :unprocessable_entity` ตอน render form     |
| DELETE แล้ว redirect ผิด / ลบซ้ำ           | ใช้ `redirect_to ..., status: :see_other`              |
| เห็น "Content missing" ใน frame            | response ไม่มี `<turbo-frame>` ที่ id ตรงกัน              |
| JS ทำงานแค่หน้าแรก                         | ใช้ `DOMContentLoaded` ให้เปลี่ยนเป็น Stimulus `connect()` |
| Broadcast ไม่มา                            | ลืม `turbo_stream_from` หรือชื่อ stream ไม่ตรงกัน         |
| ข้อมูลหลุดไปให้ผู้ใช้อื่น                     | stream ไม่ได้ scope ตาม user/permission                  |
| ลิงก์ใน frame ไม่เปลี่ยนทั้งหน้า               | ใส่ `data: { turbo_frame: "_top" }`                     |

## 15. Resources

- Hotwire: https://hotwired.dev
- Turbo Handbook: https://turbo.hotwired.dev/handbook/introduction
- Turbo Reference: https://turbo.hotwired.dev/reference/streams
- Stimulus Handbook: https://stimulus.hotwired.dev/handbook/introduction
- turbo-rails: https://github.com/hotwired/turbo-rails
- stimulus-rails: https://github.com/hotwired/stimulus-rails
- Hotwire Native: https://native.hotwired.dev
- Rails Guides: https://guides.rubyonrails.org
