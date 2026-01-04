### 1. Wallace Tree và Dadda Tree (Kiến trúc phần cứng)

Cả hai đều là phương pháp để thiết kế **Cây nén (Compressor Tree)** - phần giữa của bộ nhân, nơi thực hiện cộng hàng loạt các "tích riêng" (partial products) lại với nhau.

Hãy tưởng tượng khi bạn nhân 2 số nhị phân 4-bit, bạn sẽ tạo ra một hình bình hành gồm các chấm (bit). Nhiệm vụ là cộng các chấm này lại thành 2 hàng cuối cùng nhanh nhất có thể.

#### **Wallace Tree (Cây Wallace)**

* **Nguyên lý:** "Tham lam" (Greedy). Tại mỗi tầng nén, Wallace Tree cố gắng giảm số lượng hàng tích riêng xuống mức thấp nhất có thể ngay lập tức.


* **Cách làm:** Nó sử dụng tối đa các bộ nén 3:2 (Full Adder) ở mọi nơi có thể để nén 3 hàng thành 2 hàng.
* **Ưu điểm:** Có độ trễ (Delay) lý thuyết ngắn nhất vì số tầng (stage) là ít nhất ().
* **Nhược điểm:** Cấu trúc rất lộn xộn, không đều. Điều này làm cho việc đi dây (routing) trên chip cực khó, tốn diện tích dây dẫn và có thể gây nhiễu.



#### **Dadda Tree (Cây Dadda)**

* **Nguyên lý:** "Tiết kiệm" (Minimalist). Mục tiêu là dùng **ít cổng logic nhất** (ít bộ cộng nhất) mà vẫn đạt được độ trễ tương đương Wallace.


* **Cách làm:** Thay vì nén tối đa ngay lập tức, Dadda làm việc ngược từ đích lên. Nó xác định chiều cao tối đa cho phép của mỗi tầng dựa trên một dãy số cố định (2, 3, 4, 6, 9, 13... - mỗi số bằng 1.5 lần số trước). Nó chỉ nén những hàng "dư thừa" vượt quá chiều cao này.
* **Ưu điểm:** Dùng ít phần cứng (Adders) hơn Wallace, tiết kiệm diện tích (Area) và công suất (Power).
* **Nhược điểm:** Đôi khi độ trễ thực tế có thể nhỉnh hơn Wallace một chút do cấu trúc dây dẫn, nhưng thường là tối ưu hơn về diện tích.

> **Tóm lại sự khác biệt:**
> * **Wallace:** Nén càng nhiều càng tốt  Nhanh, nhưng tốn diện tích và đi dây rối.
> * **Dadda:** Chỉ nén vừa đủ  Tiết kiệm diện tích, đi dây gọn hơn.
> 
---

### 2. Integer Linear Programming (ILP) - Quy hoạch tuyến tính nguyên

Đây **không phải là một cấu trúc mạch**, mà là một **phương pháp toán học** để tự động hóa việc thiết kế mạch (Design Automation).

* **Định nghĩa:** ILP là bài toán tối ưu hóa trong đó hàm mục tiêu và các ràng buộc đều là tuyến tính, và các biến số phải là số nguyên (Integer).

* Trong thiết kế Bộ nhân (Ví dụ GOMIL ):

* Người ta mô hình hóa việc "đặt bộ cộng nào vào chỗ nào" thành một phương trình toán học.
* **Biến số (Variables):** Số lượng bộ nén 3:2, 2:2 tại vị trí .
* **Hàm mục tiêu (Objective Function):** Min(Tổng Diện tích) hoặc Min(Tổng Độ trễ).
* **Ràng buộc (Constraints):** Phải đảm bảo tính đúng đắn của phép cộng (Carry phải nối đúng vị trí).


* **Tại sao dùng ILP?** Nó tìm ra kết quả **tối ưu toàn cục (Global Optimum)** về mặt toán học. Tức là về lý thuyết, không có cấu trúc nào tốt hơn kết quả mà ILP tìm ra cho mô hình đó.
* **Nhược điểm chí mạng:** Độ phức tạp thuật toán quá lớn (NP-hard).
* Với bộ nhân nhỏ (8-bit), ILP chạy mất 1 phút.
* Với bộ nhân lớn hơn (16-bit), ILP có thể mất tới **16 giờ** hoặc không bao giờ chạy xong.

---
        
### Mối liên hệ với bài báo và Bạn

Trong ngữ cảnh bài báo **RL-MUL 2.0**:

1. Họ coi **Wallace** và **GOMIL (ILP)** là các đối thủ (Baseline) để so sánh.


2. Họ chỉ ra rằng **ILP quá chậm** với các thiết kế lớn, còn **Wallace/Dadda** là thiết kế thủ công cứng nhắc ("regular structure") nên không đạt được sự cân bằng tối ưu giữa Diện tích và Tốc độ.


3. **RL-MUL 2.0** dùng AI để làm việc mà ILP muốn làm (tìm cấu trúc tối ưu) nhưng nhanh hơn nhiều và linh hoạt hơn Wallace/Dadda.

**Với dự án PIM của bạn:**
Hiểu về ILP và các cấu trúc cây (Tree) giúp bạn nhận ra rằng: Trong thiết kế phần cứng chuyên dụng (như PIM), việc **tiết kiệm từng micromet vuông diện tích** (như cách Dadda hay RL-MUL làm) quan trọng hơn nhiều so với việc chỉ đơn thuần ghép các bộ cộng lại với nhau một cách ngẫu nhiên.

Bạn có muốn tôi so sánh thử xem một đoạn code Verilog sinh ra bởi Wallace Tree trông sẽ khác thế nào so với một cấu trúc thông thường không?