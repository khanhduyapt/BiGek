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
//    trend_candle_1 character varying(255) COLLATE pg_catalog."default",
//    trend_zone character varying(255) COLLATE pg_catalog."default",
//    colume_01 character varying(255) COLLATE pg_catalog."default",
//    colume_02 character varying(255) COLLATE pg_catalog."default",
//    colume_03 character varying(255) COLLATE pg_catalog."default",
//    colume_04 character varying(255) COLLATE pg_catalog."default",
//    colume_05 character varying(255) COLLATE pg_catalog."default",
//    price_01 numeric(30,5) DEFAULT 0,
//    price_02 numeric(30,5) DEFAULT 0,
//    price_03 numeric(30,5) DEFAULT 0,
//    price_04 numeric(30,5) DEFAULT 0,
//    price_05 numeric(30,5) DEFAULT 0,
//    price_06 numeric(30,5) DEFAULT 0,
//    price_07 numeric(30,5) DEFAULT 0,
//    price_08 numeric(30,5) DEFAULT 0,
//    price_09 numeric(30,5) DEFAULT 0,
//    price_10 numeric(30,5) DEFAULT 0,
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
    private String trend_of_heiken3;

    @Column(name = "current_price")
    private BigDecimal current_price = BigDecimal.ZERO;

    @Column(name = "str_body_price")
    private BigDecimal tp_long = BigDecimal.ZERO;

    @Column(name = "end_body_price")
    private BigDecimal tp_shot = BigDecimal.ZERO;

    @Column(name = "low_price")
    private BigDecimal sl_long = BigDecimal.ZERO;

    @Column(name = "high_price")
    private BigDecimal sl_shot = BigDecimal.ZERO;

    @Column(name = "note")
    private String switch_trend;

    @Column(name = "trend_candle_1")
    private String trend_by_ma_10;

    @Column(name = "trend_zone")
    private String tradable_zone;

    @Column(name = "colume_01")
    private String trend_by_ma_06;

    @Column(name = "colume_02")
    private String trend_by_ma_20;

    @Column(name = "colume_03")
    private String trend_by_ma_50;

    @Column(name = "colume_04")
    private String trend_by_seq_ma;

    @Column(name = "colume_05")
    private String trend_by_bread_area;

    @Column(name = "price_01")
    private BigDecimal short_zone = BigDecimal.ZERO;

    @Column(name = "price_02")
    private BigDecimal long_zone = BigDecimal.ZERO;

    @Column(name = "price_03")
    private BigDecimal amplitude_1_part_15 = BigDecimal.ZERO;

    @Column(name = "price_04")
    private BigDecimal amplitude_avg_of_candles = BigDecimal.ZERO;

    @Column(name = "price_05")
    private BigDecimal ma050 = BigDecimal.ZERO;

    @Column(name = "price_06")
    private BigDecimal ma020 = BigDecimal.ZERO;

    @Column(name = "price_07")
    private BigDecimal low_50candle = BigDecimal.ZERO;

    @Column(name = "price_08")
    private BigDecimal hig_50candle = BigDecimal.ZERO;

    @Column(name = "price_09")
    private BigDecimal lowest_price_of_curr_candle = BigDecimal.ZERO;

    @Column(name = "price_10")
    private BigDecimal highest_price_of_curr_candle = BigDecimal.ZERO;
}
