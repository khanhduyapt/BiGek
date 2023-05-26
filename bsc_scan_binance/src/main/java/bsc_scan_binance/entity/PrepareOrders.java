package bsc_scan_binance.entity;

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
@Table(name = "prepare_orders")

//DROP TABLE IF EXISTS public.prepare_orders;
//
//CREATE TABLE IF NOT EXISTS public.prepare_orders
//(
//   epic_and_capital_timeframe character varying(255) COLLATE pg_catalog."default" NOT NULL,
//   trend character varying(225) COLLATE pg_catalog."default" NOT NULL,
//   trend_reversal_time character varying(255) COLLATE pg_catalog."default" NOT NULL,
//   waiting_time_in_minutes integer,
//   CONSTRAINT prepare_orders_pkey PRIMARY KEY (epic_and_capital_timeframe)
//)

public class PrepareOrders {
    @Id
    @Column(name = "epic_and_capital_timeframe")
    private String epic_and_capital_timeframe;

    @Column(name = "trend")
    private String trend;

    @Column(name = "trend_reversal_time")
    private String trend_reversal_time;

    @Column(name = "waiting_time_in_minutes")
    private int waiting_time_in_minutes;
}
