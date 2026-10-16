# Nhật ký lỗi

## Lỗi gặp khi làm byte_swap
- Tạo file bằng đường dẫn đầy đủ khi đang chọn sẵn thư mục nên bị lồng thư mục. Cách tránh: chuột phải đúng thư mục, chọn New File, chỉ gõ tên file.
- Chạy `cd` hai lần bằng đường dẫn tương đối nên đi sâu thêm một tầng. Cách tránh: nhìn dòng prompt trước khi gõ lệnh.
   ## Lỗi gặp ở phần Modules
   - Nộp cả module mod_a dù HDLBits đã cho sẵn, bị trùng tên module. Chỉ nộp top_module.
   - Dùng tên dây khác tên đã khai báo (q1 thay vì w1), bị tạo ngầm dây 1 bit.
   - Quên `end` đóng khối always, quên `reg` cho cổng ra được gán trong always.
   - Quên đuôi `.v` khi lưu file (adder1, vector5).