# BC Bootcamp

Repository นี้รวมเนื้อหา Bootcamp ทั้งหมดไว้ในที่เดียว โดยแยกแต่ละหัวข้อไว้คนละ branch ทั้งเอกสาร (docs), โปรเจกต์ตัวอย่าง (demo) และ workshop สำหรับลงมือทำ

## Bootcamps

| Bootcamp   | เอกสาร (Docs)                                   | โปรเจกต์ตัวอย่าง (Demo)                     | Workshop                                                                                |
| ---------- | ----------------------------------------------- | ------------------------------------------- | --------------------------------------------------------------------------------------- |
| TypeScript | [`typescript/docs`](../../tree/typescript/docs) | -                                           | -                                                                                       |
| Angular    | [`angular/docs`](../../tree/angular/docs)       | [`angular/demo`](../../tree/angular/demo)   | -                                                                                       |
| Rails API  | -                                               | -                                           | [`rails/api`](../../tree/rails/api), [`rails/api-authen`](../../tree/rails/api-authen) |
| Hotwire    | [`hotwire/docs`](../../tree/hotwire/docs)       | [`hotwire/demo`](../../tree/hotwire/demo)   | [`hotwire/workshop`](../../tree/hotwire/workshop)                                       |

## วิธีใช้งาน

เลือก branch ของ Bootcamp ที่ต้องการ แล้ว checkout:

```bash
git clone <repo-url>
cd BC-Bootcamp
git checkout angular/docs   # เปลี่ยนเป็น branch ที่ต้องการ
```

แต่ละ branch มี `README.md` ของตัวเองที่อธิบายเนื้อหาและวิธีติดตั้ง
