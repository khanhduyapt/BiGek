package bsc_scan_binance.entity;

import java.math.BigDecimal;

import javax.persistence.Column;
import javax.persistence.EmbeddedId;
import javax.persistence.Entity;
import javax.persistence.Table;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@Entity
@AllArgsConstructor
@NoArgsConstructor
@Table(name = "mt5_data_candle")
public class Mt5DataCandle {
    @EmbeddedId
    private Mt5DataCandleKey id;

    @Column(name = "ope_price")
    private BigDecimal ope_price = BigDecimal.ZERO;

    @Column(name = "hig_price")
    private BigDecimal hig_price = BigDecimal.ZERO;

    @Column(name = "low_price")
    private BigDecimal low_price = BigDecimal.ZERO;

    @Column(name = "clo_price")
    private BigDecimal clo_price = BigDecimal.ZERO;

    public Mt5DataCandle(Mt5DataCandleKey id) {
        this.id = id;
    }

}
