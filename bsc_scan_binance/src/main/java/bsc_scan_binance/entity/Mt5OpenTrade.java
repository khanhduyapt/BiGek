package bsc_scan_binance.entity;

import java.math.BigDecimal;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@AllArgsConstructor
@NoArgsConstructor
public class Mt5OpenTrade {
    private String epic;

    private String order_type;

    private BigDecimal cur_price = BigDecimal.ZERO;

    private BigDecimal lots = BigDecimal.ZERO;

    private BigDecimal entry_h1 = BigDecimal.ZERO;

    private BigDecimal stop_loss = BigDecimal.ZERO;

    private BigDecimal take_profit_h4 = BigDecimal.ZERO;

    private String comment;

    private BigDecimal entry_h4 = BigDecimal.ZERO;

    private BigDecimal entry_d1 = BigDecimal.ZERO;

    private BigDecimal take_profit_d1 = BigDecimal.ZERO;
    private BigDecimal take_profit_w1 = BigDecimal.ZERO;
}
