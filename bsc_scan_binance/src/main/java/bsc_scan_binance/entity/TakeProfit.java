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
@Table(name = "take_profit")

//CREATE TABLE IF NOT EXISTS public.take_profit
//(
//    ticket character varying(255) NOT NULL,
//    symbol character varying(255) COLLATE pg_catalog."default",
//    trade_type character varying(255) COLLATE pg_catalog."default",
//    open_date character varying(255) COLLATE pg_catalog."default",
//    profit numeric(30,5) DEFAULT 0,
//    open_price numeric(30,5) DEFAULT 0,
//    CONSTRAINT take_profit_pkey PRIMARY KEY (ticket)
//)

public class TakeProfit {

    @Id
    @Column(name = "ticket")
    private String ticket;

    @Column(name = "symbol")
    private String symbol;

    @Column(name = "trade_type")
    private String tradeType;

    @Column(name = "open_date")
    private String closedDate;

    @Column(name = "profit")
    private BigDecimal profit = BigDecimal.ZERO;

    @Column(name = "open_price")
    private BigDecimal openPrice = BigDecimal.ZERO;

}
