package bsc_scan_binance.entity;

import java.math.BigDecimal;

import javax.persistence.Column;
import javax.persistence.Entity;
import javax.persistence.Id;
import javax.persistence.Table;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@Entity
@AllArgsConstructor
@NoArgsConstructor
@Table(name = "orders")

public class Orders {
    @Id
    @Column(name = "gecko_id")
    private String id;

    @Column(name = "symbol")
    private String insertTime;

    @Column(name = "name")
    private String trend;

    @Column(name = "order_price")
    private BigDecimal current_price = BigDecimal.ZERO;

    @Column(name = "qty")
    private BigDecimal open_price = BigDecimal.ZERO;

    @Column(name = "amount")
    private BigDecimal close_price = BigDecimal.ZERO;

    @Column(name = "low_price")
    private BigDecimal low_price = BigDecimal.ZERO;

    @Column(name = "height_price")
    private BigDecimal height_price = BigDecimal.ZERO;

    @Column(name = "note")
    private String note;
}
