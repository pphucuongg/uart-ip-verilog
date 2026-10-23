# Nhật ký lỗi

## Lỗi gặp khi làm byte_swap
- Tạo file bằng đường dẫn đầy đủ khi đang chọn sẵn thư mục nên bị lồng thư mục. Cách tránh: chuột phải đúng thư mục, chọn New File, chỉ gõ tên file.
- Chạy `cd` hai lần bằng đường dẫn tương đối nên đi sâu thêm một tầng. Cách tránh: nhìn dòng prompt trước khi gõ lệnh.
   ## Lỗi gặp ở phần Modules
   - Nộp cả module mod_a dù HDLBits đã cho sẵn, bị trùng tên module. Chỉ nộp top_module.
   - Dùng tên dây khác tên đã khai báo (q1 thay vì w1), bị tạo ngầm dây 1 bit.
   - Quên `end` đóng khối always, quên `reg` cho cổng ra được gán trong always.
   - Quên đuôi `.v` khi lưu file (adder1, vector5).
   ## Lỗi gặp ở ngày 7 (priority_encoder4)
- Tính expected sai điều kiện: `if (in[k]==0)` thay vì `==1`, làm testbench báo lỗi cho mạch đúng. Cách tránh: tự chạy tay một ví dụ (1010 thì pos = 1) trước khi tin testbench.
- Đặt tên module là `top_module` (chép từ HDLBits) trong khi testbench gọi `priority_encoder4`.
- Dán khối $display ra ngoài vòng for và xóa mất phần báo PASS/FAIL cuối. Cách nhớ: so sánh và in lỗi nằm trong vòng lặp, tổng kết nằm sau vòng lặp.
- Dán nhiều lệnh một lúc làm terminal dính chữ. Cách tránh: dán từng lệnh, hoặc `cls` trước.
## Hiểu lệch ở ngày 10 (Sequential Logic)
- Tưởng `always @*` kích hoạt khi clk đổi. Thực tế `@*` nhạy với mọi tín hiệu được đọc trong khối, là mạch tổ hợp, không dính clk.
- Tưởng `*` là "or" còn edge là "and". Thực tế danh sách nhạy `@(posedge clk, posedge areset)` là "hoặc": cạnh nào tới trước cũng kích hoạt khối.
- Khi nêu cách tránh latch chỉ nhớ một cách. Có hai: gán mặc định đầu khối always, hoặc phủ đủ nhánh bằng else/default.
## Lỗi gặp ở ngày 12 (detect_an_edge)
- Dùng in_d trong always mà chưa khai báo, và quên reg cho cổng ra pedge được gán trong always.
- Khai báo reg in_d; thiếu độ rộng nên chỉ nhớ 1 bit trong khi in có 8 bit (khai báo có tên nhưng thiếu độ rộng).