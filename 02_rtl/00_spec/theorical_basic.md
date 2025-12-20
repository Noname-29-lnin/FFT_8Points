# Thực hiện liên quan đến các hoạt động của FFT

- Thuật toán phân rã (Algorithm Decomposition)
    - 1. Khái niệm của Radix-2 và Butterfly là gần như nhau:
      - Radix-2 là việc một bộ FFT chiến lược của việc tính FFT theo Cooley-Tukey để một lần tính được bao giá trị một lần.
      - Butterfly là việc hiện thực hóa các tính theo các Radix bằng các phép tính như cộng, trừ nhân chia.

- Cooley-Tukey Algorithm là một giải thuật có thể giúp giảm thời gian tính toán của khi chuyển đổi từ miền thời gian sang miền tần số. Giảm độ phức tạp của các tính DFT nguyên bản xuống từ O(N^2) thành O(NlogN).
  - 1. Phân tách (Spliting): Phân mảng N phần tử ban đầu thành 2 mảng N/2 phần tử với với 1 mảng chứa các vị trí chẵn (even) và 1 mảng chứa các giá trị lẻ (odd).
  - 2. Đệ quy (Recursion): Tiếp tục chia mảng N/2 phần tử đó thành các đơn vị 2-diểm (Radix-2).
  - 3. Kết hợp (Butterfly Unit): Sau khi tính toán các đơn vị nhỏ, kết hợp chúng lại bằng các phép tính cộng, trừ và nhân với một hệ số là Twiddle Factor (W^k_N).

- FFT có hai loại là thực hiện theo DIT hoặc DFT


# Thực hiện các xây dụng các Radix-2 và Radix-4