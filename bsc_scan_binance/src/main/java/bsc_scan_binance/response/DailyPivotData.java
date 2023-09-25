package bsc_scan_binance.response;

import java.math.BigDecimal;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@AllArgsConstructor
@NoArgsConstructor
public class DailyPivotData {
    private String TimeCurrent = "";
    private String symbol;

    private BigDecimal mid;
    private BigDecimal amp;

    private BigDecimal open;
    private BigDecimal close;

    private BigDecimal support1;
    private BigDecimal support2;
    private BigDecimal support3;

    private BigDecimal resistance1;
    private BigDecimal resistance2;
    private BigDecimal resistance3;
}
