package bsc_scan_binance.entity;

import java.io.Serializable;

import javax.persistence.Column;
import javax.persistence.Embeddable;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@NoArgsConstructor
@AllArgsConstructor
@Data
@Embeddable
public class BitcoinBalancesOnExchangesKey implements Serializable {
    private static final long serialVersionUID = 2487553551545049610L;

    @Column(name = "yyyymmdd")
    private String yyyymmdd;

    @Column(name = "exchange_name")
    private String exchangeName;

    @Column(name = "symbol")
    private String symbol;
}
