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
public class Mt5DataCandleKey implements Serializable {
    private static final long serialVersionUID = 2487553551545049610L;

    @Column(name = "epic")
    private String epic;

    @Column(name = "candle")
    private String candle;

    @Column(name = "date_time")
    private String candleTime;

}
