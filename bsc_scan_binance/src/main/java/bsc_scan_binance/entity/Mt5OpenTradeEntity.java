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
@Table(name = "mt5_open_trade")

//CREATE TABLE IF NOT EXISTS public.mt5_open_trade
//(
//    comment_id character varying(255) COLLATE pg_catalog."default" NOT NULL,
//    timeframe character varying(255) COLLATE pg_catalog."default",
//    symbol character varying(255) COLLATE pg_catalog."default",
//    ticket character varying(255) COLLATE pg_catalog."default",
//    typedescription character varying(255) COLLATE pg_catalog."default",
//    priceopen numeric(30,5) DEFAULT 0,
//    stoplosscalc numeric(30,5) DEFAULT 0,
//    stoplossm30 numeric(30,5) DEFAULT 0,
//    takeprofit numeric(30,5) DEFAULT 0,
//    profit numeric(30,5) DEFAULT 0,
//    CONSTRAINT mt5_open_trade_pkey PRIMARY KEY (comment_id)
//)

public class Mt5OpenTradeEntity {
    @Id
    @Column(name = "comment_id")
    private String commentId;

    @Column(name = "timeframe")
    private String Timeframe;

    @Column(name = "symbol")
    private String Symbol;

    @Column(name = "ticket")
    private String Ticket;

    @Column(name = "typedescription")
    private String TypeDescription;

    @Column(name = "priceopen")
    private BigDecimal PriceOpen;

    @Column(name = "stoplosscalc")
    private BigDecimal StopLossCalc;

    @Column(name = "stoplossm30")
    private BigDecimal StopLossM30;

    @Column(name = "takeprofit")
    private BigDecimal TakeProfit;

    @Column(name = "profit")
    private BigDecimal Profit;

}
