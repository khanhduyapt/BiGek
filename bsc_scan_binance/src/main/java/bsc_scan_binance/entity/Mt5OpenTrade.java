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

    private BigDecimal lots = BigDecimal.ZERO;

    private BigDecimal entry = BigDecimal.ZERO;

    private BigDecimal stop_loss = BigDecimal.ZERO;

    private BigDecimal take_profit = BigDecimal.ZERO;
}
