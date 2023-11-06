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
@Table(name = "mt5_macd")

//CREATE TABLE IF NOT EXISTS public.mt5_macd
//(
//    symbol character varying(255) COLLATE pg_catalog."default" NOT NULL,
//    time_frame character varying(255) COLLATE pg_catalog."default",
//
//    macd numeric(30,5) DEFAULT 0,
//    signal numeric(30,5) DEFAULT 0,
//
//    pre_macd_trend character varying(255) COLLATE pg_catalog."default",
//    cur_macd_trend character varying(255) COLLATE pg_catalog."default",
//    trend_macd_vs_signal character varying(255) COLLATE pg_catalog."default",
//    trend_macd_vs_zero character varying(255) COLLATE pg_catalog."default",
//
//    CONSTRAINT mt5_macd_id PRIMARY KEY (symbol, time_frame)
//)

public class Mt5Macd {
    @EmbeddedId
    private Mt5MacdKey id;

    @Column(name = "macd")
    private BigDecimal macd = BigDecimal.ZERO;

    @Column(name = "signal")
    private BigDecimal signal = BigDecimal.ZERO;

    @Column(name = "pre_macd_trend")
    private String pre_macd_vs_zero = "";

    @Column(name = "cur_macd_trend")
    private String cur_macd_trend = "";

    @Column(name = "trend_macd_vs_signal")
    private String trend_macd_vs_signal = "";

    @Column(name = "trend_macd_vs_zero")
    private String trend_macd_vs_zero = "";

}
