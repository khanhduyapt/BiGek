package bsc_scan_binance.entity;

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
@Table(name = "prepare_orders")

public class PrepareOrders {
    @Id
    @Column(name = "gecko_id")
    private String id;

    @Column(name = "symbol")
    private String orders_id;

    @Column(name = "name")
    private String note;

    @Column(name = "data_type")
    private String dataType;
}
