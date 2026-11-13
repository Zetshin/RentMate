# RentMate API

เริ่มต้นด้วย Go standard library ไม่ต้องติดตั้งแพ็กเกจเพิ่ม

```powershell
cd backend
go run ./cmd/api
```

เปิด http://127.0.0.1:8080/health จะได้รับ:

```json
{"status":"ok"}
```

หยุดด้วย Ctrl+C ใน Terminal ที่รันเซิร์ฟเวอร์

```powershell
go test ./...
go vet ./...
```

## โครงสร้าง

- `cmd/api/main.go`: เริ่มเซิร์ฟเวอร์และตั้งค่า HTTP timeout
- `cmd/api/routes.go`: จับคู่ URL กับ handler
- `cmd/api/handlers_health.go`: ตอบสถานะของ API process
- `cmd/api/routes_test.go`: ทดสอบ endpoint ผ่าน router

ไฟล์ใน `cmd/api` ใช้ `package main` ร่วมกัน และใช้ method ของ `application`
เมื่อมีฟีเจอร์ใหม่จะแยกเป็น `handlers_auth.go`, `handlers_rooms.go` เป็นต้น
ส่วน `internal/models` และ `internal/validator` จะเพิ่มเมื่อเริ่มใช้ฐานข้อมูลและ validation
ยังไม่มีฐานข้อมูลหรือระบบยืนยันตัวตน health จึงไม่ได้ตรวจการเชื่อมฐานข้อมูล
เซิร์ฟเวอร์รับคำขอเฉพาะเครื่องนี้ที่ 127.0.0.1:8080
