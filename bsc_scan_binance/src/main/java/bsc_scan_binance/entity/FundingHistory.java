package bsc_scan_binance.entity;

import java.math.BigDecimal;

import javax.persistence.Column;
import javax.persistence.ColumnResult;
import javax.persistence.ConstructorResult;
import javax.persistence.EmbeddedId;
import javax.persistence.Entity;
import javax.persistence.SqlResultSetMapping;
import javax.persistence.Table;

import bsc_scan_binance.response.ForexHistoryResponse;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@Entity
@AllArgsConstructor
@NoArgsConstructor
@Table(name = "funding_history")

@SqlResultSetMapping(name = "ForexHistoryResponse", classes = {
        @ConstructorResult(targetClass = ForexHistoryResponse.class, columns = {
                @ColumnResult(name = "epic", type = String.class),
                @ColumnResult(name = "d", type = String.class),
                @ColumnResult(name = "h", type = String.class),
                @ColumnResult(name = "m15", type = String.class),
                @ColumnResult(name = "m5", type = String.class),
                @ColumnResult(name = "note", type = String.class),
        })
})

public class FundingHistory {

    @EmbeddedId
    private FundingHistoryKey id;

    @Column(name = "symbol")
    private String symbol;

    @Column(name = "low")
    private BigDecimal low = BigDecimal.ZERO;

    @Column(name = "high")
    private BigDecimal high = BigDecimal.ZERO;

    @Column(name = "avg_low")
    private BigDecimal avgLow = BigDecimal.ZERO;

    @Column(name = "avg_high")
    private BigDecimal avgHigh = BigDecimal.ZERO;

    @Column(name = "count_low")
    private int countLow = 1;

    @Column(name = "count_high")
    private int countHigh = 1;

    @Column(name = "note")
    private String note;

    @Column(name = "pumpdump")
    private boolean pumpdump;

}
