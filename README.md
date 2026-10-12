# UART IP with FIFO and APB interface

Thiết kế UART IP bằng Verilog: TX, RX, FIFO, giao tiếp APB, kiểm chứng bằng mô phỏng (Icarus Verilog).

## Bài toán
CPU truyền dữ liệu song song, tốc độ clock cao. Đường ra thiết bị ngoại vi là nối tiếp, từng bit, tốc độ thấp hơn rất nhiều. UART đứng giữa để chứa dữ liệu (FIFO), chuyển đổi song song/nối tiếp và giữ đúng nhịp (baud rate).

## Tiến độ
- [x] Cài môi trường, chạy mô phỏng đầu tiên (cổng AND)
- [ ] ALU 32-bit
- [ ] Baud generator + UART TX
- [ ] UART RX
- [ ] FIFO
- [ ] APB slave + register map
- [ ] Assertion, coverage, tổng kết