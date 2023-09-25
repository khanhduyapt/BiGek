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
//    mid numeric(30,5) DEFAULT 0,
//    amp numeric(30,5) DEFAULT 0,
//    open_price numeric(30,5) DEFAULT 0,
//    close_price numeric(30,5) DEFAULT 0,
//    support1 numeric(30,5) DEFAULT 0,
//    support2 numeric(30,5) DEFAULT 0,
//    support3 numeric(30,5) DEFAULT 0,
//    resistance1 numeric(30,5) DEFAULT 0,
//    resistance2 numeric(30,5) DEFAULT 0,
//    resistance3 numeric(30,5) DEFAULT 0,
//    CONSTRAINT daily_range_pkey PRIMARY KEY (yyyy_mm_dd, symbol)
//)

public class DailyRange {

    @EmbeddedId
    private DailyRangeKey id;

    @Column(name = "mid")
    private BigDecimal mid = BigDecimal.ZERO;

    @Column(name = "amp")
    private BigDecimal amp = BigDecimal.ZERO;

    @Column(name = "open_price")
    private BigDecimal open_price = BigDecimal.ZERO;

    @Column(name = "close_price")
    private BigDecimal close_price = BigDecimal.ZERO;

    @Column(name = "support1")
    private BigDecimal support1 = BigDecimal.ZERO;

    @Column(name = "support2")
    private BigDecimal support2 = BigDecimal.ZERO;

    @Column(name = "support3")
    private BigDecimal support3 = BigDecimal.ZERO;

    @Column(name = "resistance1")
    private BigDecimal resistance1 = BigDecimal.ZERO;

    @Column(name = "resistance2")
    private BigDecimal resistance2 = BigDecimal.ZERO;

    @Column(name = "resistance3")
    private BigDecimal resistance3 = BigDecimal.ZERO;

}
