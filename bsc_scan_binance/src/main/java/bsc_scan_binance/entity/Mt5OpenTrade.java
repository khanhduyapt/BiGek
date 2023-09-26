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

    private BigDecimal entry1 = BigDecimal.ZERO;

    private BigDecimal stop_loss = BigDecimal.ZERO;

    private BigDecimal take_profit1 = BigDecimal.ZERO;

    private String comment;

    private BigDecimal entry2 = BigDecimal.ZERO;
    private BigDecimal entry3 = BigDecimal.ZERO;

    private BigDecimal take_profit2 = BigDecimal.ZERO;
    private BigDecimal take_profit3 = BigDecimal.ZERO;
}
