package bsc_scan_binance.entity;

import java.math.BigDecimal;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@AllArgsConstructor
@NoArgsConstructor
public class Mt5DataTrade {
    private String Symbol;

    private String Ticket;

    private String Type;

    private BigDecimal PriceOpen = BigDecimal.ZERO;

    private BigDecimal StopLoss = BigDecimal.ZERO;

    private BigDecimal TakeProfit = BigDecimal.ZERO;

    private BigDecimal Profit = BigDecimal.ZERO;

    private String comment;

    private BigDecimal stop_loss_m30 = BigDecimal.ZERO;

    private BigDecimal volume = BigDecimal.ZERO;

    private BigDecimal currprice = BigDecimal.ZERO;
}