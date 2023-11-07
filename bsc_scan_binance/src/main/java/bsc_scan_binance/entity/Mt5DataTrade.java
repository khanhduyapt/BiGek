package bsc_scan_binance.entity;

import java.math.BigDecimal;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@AllArgsConstructor
@NoArgsConstructor
public class Mt5DataTrade {
    private String company;

    private String symbol;

    private String ticket;

    private String type;

    private BigDecimal priceOpen = BigDecimal.ZERO;

    private BigDecimal stopLoss = BigDecimal.ZERO;

    private BigDecimal takeProfit = BigDecimal.ZERO;

    private BigDecimal profit = BigDecimal.ZERO;

    private String comment;

    private BigDecimal volume = BigDecimal.ZERO;

    private BigDecimal currPrice = BigDecimal.ZERO;

    private String openTime;

    private String currServerTime;
}
