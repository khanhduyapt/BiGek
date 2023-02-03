package bsc_scan_binance.response;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@AllArgsConstructor
@NoArgsConstructor
public class ForexHistoryResponse {
    private String epic = "";
    private String d = "";
    private String h = "";
    private String m15 = "";
    private String m5 = "";
    private String note = "";
}
