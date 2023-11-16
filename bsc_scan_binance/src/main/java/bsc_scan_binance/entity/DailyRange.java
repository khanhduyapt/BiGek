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
@Table(name = "daily_range")

//-- DROP TABLE IF EXISTS public.daily_range;
//
//CREATE TABLE IF NOT EXISTS public.daily_range
//(
//    yyyy_mm_dd character varying(255) COLLATE pg_catalog."default" NOT NULL,
//    symbol character varying(255) COLLATE pg_catalog."default" NOT NULL,
//    trend_w1 character varying(255) COLLATE pg_catalog."default",
//    w_close numeric(30,5) DEFAULT 0,
//    avg_amp_week numeric(30,5) DEFAULT 0,
//    upper_03 numeric(30,5) DEFAULT 0,
//    lower_03 numeric(30,5) DEFAULT 0,
//    upper_15 numeric(30,5) DEFAULT 0,
//    lower_15 numeric(30,5) DEFAULT 0,
//    upper_h1 numeric(30,5) DEFAULT 0,
//    lower_h1 numeric(30,5) DEFAULT 0,
//    upper_h4 numeric(30,5) DEFAULT 0,
//    lower_h4 numeric(30,5) DEFAULT 0,
//    upper_d1 numeric(30,5) DEFAULT 0,
//    lower_d1 numeric(30,5) DEFAULT 0,
//    d_close numeric(30,5) DEFAULT 0,
//    d_today_low numeric(30,5) DEFAULT 0,
//    d_today_hig numeric(30,5) DEFAULT 0,
//    amp_min_d1 numeric(30,5) DEFAULT 0,
//    amp_avg_h4 numeric(30,5) DEFAULT 0,
//    CONSTRAINT daily_range_pkey PRIMARY KEY (yyyy_mm_dd, symbol)
//)

public class DailyRange {

    @EmbeddedId
    private DailyRangeKey id;

    @Column(name = "trend_w1")
    private String trend_w1 = "";
    @Column(name = "w_close")
    private BigDecimal w_close = BigDecimal.ZERO;
    @Column(name = "avg_amp_week")
    private BigDecimal avg_amp_week = BigDecimal.ZERO;
    @Column(name = "upper_03")
    private BigDecimal curr_price = BigDecimal.ZERO;

    @Column(name = "lower_03")
    private BigDecimal lot_size_per_500usd = BigDecimal.ZERO;

    @Column(name = "upper_15")
    private BigDecimal amp_fr = BigDecimal.ZERO;
    @Column(name = "lower_15")
    private BigDecimal amp_to = BigDecimal.ZERO;

    @Column(name = "upper_h1")
    private BigDecimal todo_2 = BigDecimal.ZERO;
    @Column(name = "lower_h1")
    private BigDecimal todo_3 = BigDecimal.ZERO;

    @Column(name = "upper_h4")
    private BigDecimal h4_ma10 = BigDecimal.ZERO;
    
    @Column(name = "lower_h4")
    private BigDecimal lower_h4 = BigDecimal.ZERO;
    @Column(name = "upper_d1")
    private BigDecimal upper_d1 = BigDecimal.ZERO;
    @Column(name = "lower_d1")
    private BigDecimal lower_d1 = BigDecimal.ZERO;

    @Column(name = "d_close")
    private BigDecimal d_close = BigDecimal.ZERO;
    @Column(name = "d_today_low")
    private BigDecimal d_today_low = BigDecimal.ZERO;
    @Column(name = "d_today_hig")
    private BigDecimal d_today_hig = BigDecimal.ZERO;

    @Column(name = "amp_min_d1")
    private BigDecimal amp_min_d1 = BigDecimal.ZERO;
    @Column(name = "amp_avg_h4")
    private BigDecimal amp_avg_h4 = BigDecimal.ZERO;
}
