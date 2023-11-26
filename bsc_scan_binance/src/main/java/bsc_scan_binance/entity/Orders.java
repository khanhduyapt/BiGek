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

//--  DROP TABLE IF EXISTS public.orders;
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
//    trend_by_ma_10 character varying(255) COLLATE pg_catalog."default",
//    tradable_zone character varying(255) COLLATE pg_catalog."default",
//    trend_by_ma_06 character varying(255) COLLATE pg_catalog."default",
//    trend_by_ma_20 character varying(255) COLLATE pg_catalog."default",
//    trend_by_ma_50 character varying(255) COLLATE pg_catalog."default",
//    trend_by_seq_ma character varying(255) COLLATE pg_catalog."default",
//    trend_by_bread_area character varying(255) COLLATE pg_catalog."default",
//    short_zone numeric(30,5) DEFAULT 0,
//    long_zone numeric(30,5) DEFAULT 0,
//    amplitude_1_part_15 numeric(30,5) DEFAULT 0,
//    amplitude_avg_of_candles numeric(30,5) DEFAULT 0,
//    ma050 numeric(30,5) DEFAULT 0,
//    ma020 numeric(30,5) DEFAULT 0,
//    ma010 numeric(30,5) DEFAULT 0,
//    low_50candle numeric(30,5) DEFAULT 0,
//    hig_50candle numeric(30,5) DEFAULT 0,
//    lowest_price_of_curr_candle numeric(30,5) DEFAULT 0,
//    highest_price_of_curr_candle numeric(30,5) DEFAULT 0,
//    trend_of_heiken3_1 character varying(255) COLLATE pg_catalog."default",
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
    private String trend_by_heiken;

    @Column(name = "current_price")
    private BigDecimal current_price = BigDecimal.ZERO;

    @Column(name = "str_body_price")
    private BigDecimal sl_long = BigDecimal.ZERO;

    @Column(name = "end_body_price")
    private BigDecimal sl_shot = BigDecimal.ZERO;

    @Column(name = "low_price")
    private BigDecimal close_candle_1 = BigDecimal.ZERO;

    @Column(name = "high_price")
    private BigDecimal close_candle_2 = BigDecimal.ZERO;

    @Column(name = "note")
    private String switch_trend;

    @Column(name = "trend_by_ma_10")
    private String trend_by_ma_9;

    @Column(name = "tradable_zone")
    private String trend_candle1_vs_ma20;

    @Column(name = "trend_by_ma_06")
    private String trend_by_ma_6;

    @Column(name = "trend_by_ma_20")
    private String trend_by_ma_20;

    @Column(name = "trend_by_ma_50")
    private String trend_by_seq_10_20_50;

    @Column(name = "trend_by_seq_ma")
    private String trend_by_seq_ma_369;

    @Column(name = "trend_by_bread_area")
    private String todo;

    @Column(name = "short_zone")
    private BigDecimal body_hig_50_candle = BigDecimal.ZERO;

    @Column(name = "long_zone")
    private BigDecimal body_low_50_candle = BigDecimal.ZERO;

    @Column(name = "amplitude_1_part_15")
    private BigDecimal todo1 = BigDecimal.ZERO;

    @Column(name = "amplitude_avg_of_candles")
    private BigDecimal amplitude_avg_of_candles = BigDecimal.ZERO;

    @Column(name = "ma050")
    private BigDecimal tp_long = BigDecimal.ZERO;

    @Column(name = "ma020")
    private BigDecimal tp_shot = BigDecimal.ZERO;

    @Column(name = "ma010")
    private BigDecimal ma20 = BigDecimal.ZERO;

    @Column(name = "low_50candle")
    private BigDecimal low_50candle = BigDecimal.ZERO;

    @Column(name = "hig_50candle")
    private BigDecimal hig_50candle = BigDecimal.ZERO;

    @Column(name = "lowest_price_of_curr_candle")
    private Double count_position_of_candle1_vs_ma20 = Double.valueOf(0);

    @Column(name = "highest_price_of_curr_candle")
    private Double count_position_of_heiken_candle1 = Double.valueOf(0);

    @Column(name = "trend_of_heiken3_1")
    private String trend_heiken_candle1;

}
