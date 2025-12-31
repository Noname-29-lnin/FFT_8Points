module cla_logic_tree_level #(
    parameter WIDTH = 16,
    parameter FANIN = 4
)(
    input  wire              C_in,
    input  wire [WIDTH-1:0]  P_in,
    input  wire [WIDTH-1:0]  G_in,
    output wire [WIDTH:0]    C_out
);

    localparam NUM_GROUPS = (WIDTH + FANIN - 1) / FANIN;

    // =========================================================================
    // BƯỚC 1: Tính P_block và G_block cho mỗi group
    // HOÀN TOÀN PARALLEL và FLATTENED - KHÔNG có nested loop
    // =========================================================================
    wire [NUM_GROUPS-1:0] P_group;
    wire [NUM_GROUPS-1:0] G_group;

    genvar i, j;
    generate
        for (i = 0; i < NUM_GROUPS; i++) begin : COMPUTE_GROUP_PG
            localparam CUR_SIZE = (i == NUM_GROUPS-1) ? 
                                  (WIDTH - i*FANIN) : FANIN;
            localparam START_BIT = i * FANIN;
            
            // =====================================================================
            // P_block: Đơn giản - AND của tất cả P trong group
            // =====================================================================
            assign P_group[i] = &P_in[START_BIT +: CUR_SIZE];
            
            // =====================================================================
            // G_block: FLATTEN hoàn toàn thành parallel OR
            // G_block = G[n-1] | (G[n-2] & P[n-1]) | (G[n-3] & P[n-2] & P[n-1]) | ...
            // =====================================================================
            
            // Tạo các term song song
            wire [CUR_SIZE-1:0] g_terms;
            
            for (j = 0; j < CUR_SIZE; j++) begin : GEN_G_TERMS
                if (j == CUR_SIZE - 1) begin
                    // Term cuối cùng: chỉ có G[n-1]
                    assign g_terms[j] = G_in[START_BIT + j];
                end else begin
                    // Term j: G[j] & P[j+1] & P[j+2] & ... & P[n-1]
                    // = G[j] & (&P[j+1 : n-1])
                    assign g_terms[j] = G_in[START_BIT + j] & 
                                       (&P_in[START_BIT + j + 1 +: (CUR_SIZE - j - 1)]);
                end
            end
            
            // G_block = OR của tất cả các term (parallel OR tree)
            assign G_group[i] = |g_terms;
            
        end
    endgenerate

    // =========================================================================
    // BƯỚC 2: Tính carry giữa các group (từ P_group, G_group)
    // =========================================================================
    wire [NUM_GROUPS:0] C_group;
    
    generate
        if (NUM_GROUPS == 1) begin : SINGLE_GROUP
            // Chỉ có 1 group, không cần tầng cao hơn
            assign C_group[0] = C_in;
            assign C_group[1] = G_group[0] | (P_group[0] & C_in);
        end else begin : MULTI_GROUP
            // Đệ quy tính carry cho các group
            cla_logic_tree_level #(
                .WIDTH(NUM_GROUPS),
                .FANIN(FANIN)
            ) next_level (
                .C_in(C_in),
                .P_in(P_group),
                .G_in(G_group),
                .C_out(C_group)  //  Không tạo vòng lặp
            );
        end
    endgenerate

    // =========================================================================
    // BƯỚC 3: Tính carry chi tiết bên trong mỗi group
    // CHỈ KHỞI TẠO CLA_logic 1 LẦN DUY NHẤT
    // =========================================================================
    assign C_out[0] = C_in;
    
    generate
        for (i = 0; i < NUM_GROUPS; i++) begin : COMPUTE_DETAILED_CARRY
            localparam CUR_SIZE = (i == NUM_GROUPS-1) ? 
                                  (WIDTH - i*FANIN) : FANIN;
            
            wire [CUR_SIZE:0] C_block;
            
            //  CHỈ 1 LẦN khởi tạo CLA_logic cho mỗi group
            CLA_logic #(.WIDTH(CUR_SIZE)) cla_unit (
                .C_in(C_group[i]),
                .G(G_in[i*FANIN +: CUR_SIZE]),
                .P(P_in[i*FANIN +: CUR_SIZE]),
                .C_i(C_block)
            );
            
            // Lấy carry chi tiết (không bao gồm C_in)
            assign C_out[i*FANIN+1 +: CUR_SIZE] = C_block[1 +: CUR_SIZE];
        end
    endgenerate

endmodule
