package bsc_scan_binance.entity;

import java.math.BigDecimal;
import java.time.LocalDateTime;

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
@Table(name = "orders")

//-- DROP TABLE IF EXISTS public.orders;
//
//CREATE TABLE IF NOT EXISTS public.orders
//(
//    gecko_id character varying(255) COLLATE pg_catalog."default" NOT NULL,
//    insert_time character varying(255) COLLATE pg_catalog."default",
//    trend character varying(255) COLLATE pg_catalog."default",
//    current_price numeric(30,5) DEFAULT 0,
//    str_body_price numeric(30,5) DEFAULT 0,
//    end_body_price numeric(30,5) DEFAULT 0,
//    low_price numeric(30,5) DEFAULT 0,
//    high_price numeric(30,5) DEFAULT 0,
//    note character varying(500) COLLATE pg_catalog."default",
//    created_at timestamp without time zone DEFAULT now(),
//    allow_trade_by_ma50 boolean DEFAULT false,
//    trend_candle_1 character varying(255) COLLATE pg_catalog."default",
//    trend_zone character varying(255) COLLATE pg_catalog."default",
//    CONSTRAINT orders_pkey PRIMARY KEY (gecko_id)
//)

public class Orders {
    public Orders(String _id, String _switch_trend) {
        this.id = _id;
        this.switch_trend = _switch_trend;
        this.insertTime = LocalDateTime.now().toString();
    }

    @Id
    @Column(name = "gecko_id")
    private String id;

    @Column(name = "insert_time")
    private String insertTime;

    @Column(name = "trend")
    private String trend;

    @Column(name = "current_price")
    private BigDecimal current_price = BigDecimal.ZERO;

    @Column(name = "str_body_price")
    private BigDecimal body_low = BigDecimal.ZERO;

    @Column(name = "end_body_price")
    private BigDecimal body_hig = BigDecimal.ZERO;

    @Column(name = "low_price")
    private BigDecimal low_price = BigDecimal.ZERO;

    @Column(name = "high_price")
    private BigDecimal high_price = BigDecimal.ZERO;

    @Column(name = "note")
    private String switch_trend;

    @Column(name = "allow_trade_by_ma50")
    private boolean allow_trade_by_ma50;

    @Column(name = "trend_candle_1")
    private String trend_c1;

    @Column(name = "trend_zone")
    private String trend_zone;

}
