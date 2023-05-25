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

//-- DROP TABLE IF EXISTS public.mt5_open_trade;
//
//CREATE TABLE IF NOT EXISTS public.mt5_open_trade
//(
//ticket_id character varying(255) COLLATE pg_catalog."default" NOT NULL,
//timeframe character varying(255) COLLATE pg_catalog."default",
//symbol character varying(255) COLLATE pg_catalog."default",
//commentss character varying(255) COLLATE pg_catalog."default",
//typedescription character varying(255) COLLATE pg_catalog."default",
//volume numeric(30,5) DEFAULT 0,
//priceopen numeric(30,5) DEFAULT 0,
//stoplosscalc numeric(30,5) DEFAULT 0,
//stoplossm30 numeric(30,5) DEFAULT 0,
//takeprofit numeric(30,5) DEFAULT 0,
//profit numeric(30,5) DEFAULT 0,
//CONSTRAINT mt5_open_trade_id PRIMARY KEY (ticket_id)
//)

public class Mt5OpenTradeEntity {
    @Id
    @Column(name = "ticket_id")
    private String ticket;

    @Column(name = "timeframe")
    private String timeframe;

    @Column(name = "symbol")
    private String symbol;

    @Column(name = "commentss")
    private String comment;

    @Column(name = "typedescription")
    private String typeDescription;

    @Column(name = "volume")
    private BigDecimal volume;

    @Column(name = "priceopen")
    private BigDecimal priceOpen;

    @Column(name = "stoplosscalc")
    private BigDecimal stopLossCalc;

    @Column(name = "stoplossm30")
    private BigDecimal stopLossM30;

    @Column(name = "takeprofit")
    private BigDecimal takeProfit;

    @Column(name = "profit")
    private BigDecimal profit;

}
