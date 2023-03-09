package bsc_scan_binance.entity;

import java.math.BigDecimal;

import javax.persistence.Column;
import javax.persistence.ColumnResult;
import javax.persistence.ConstructorResult;
import javax.persistence.Entity;
import javax.persistence.Id;
import javax.persistence.SqlResultSetMapping;
import javax.persistence.Table;

import bsc_scan_binance.response.BtcFuturesResponse;
import bsc_scan_binance.utils.Utils;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@Entity
@AllArgsConstructor
@NoArgsConstructor
@Table(name = "btc_futures")

@SqlResultSetMapping(name = "BtcFuturesResponse", classes = {
        @ConstructorResult(targetClass = BtcFuturesResponse.class, columns = {
                @ColumnResult(name = "low_price_h", type = BigDecimal.class),
                @ColumnResult(name = "open_candle_h", type = BigDecimal.class),
                @ColumnResult(name = "close_candle_h", type = BigDecimal.class),
                @ColumnResult(name = "hight_price_h", type = BigDecimal.class),

                @ColumnResult(name = "id_half1", type = String.class),
                @ColumnResult(name = "open_price_half1", type = BigDecimal.class),
                @ColumnResult(name = "id_half2", type = String.class),
                @ColumnResult(name = "open_price_half2", type = BigDecimal.class), }) })

public class BtcFutures {

    // https://binance-docs.github.io/apidocs/spot/en/#compressed-aggregate-trades-list
    // [
    // [
    // 1499040000000, // Kline open time
    // "0.01634790", // Open price
    // "0.80000000", // High price
    // "0.01575800", // Low price
    // "0.01577100", // Close price
    // "148976.11427815", // Volume
    // 1499644799999, // Kline Close time
    // "2434.19055334", // Quote asset volume
    // 308, // Number of trades
    // "28.46694368", // Taker buy quote asset volume
    // "1756.87402397", // Taker buy base asset volume
    // "0" // Unused field, ignore.
    // ]
    // ]
    // -------------------------------------------------------------//
    // [
    // [
    // 1666843200000,

    // "20755.90000000", Open price
    // "20766.01000000", High price
    // "20747.86000000", Low price
    // "20755.25000000", Close price

    // "1109.22670000", trading qty

    // 1666846799999,

    // "23022631.35991350", trading volume

    // 37665, Number of trades
    // "553.36539000", Qty
    // "11485577.89938500", Taker volume
    // "0" -> avg_price = 20,769
    // ]
    // ]

    @Id
    @Column(name = "id")
    private String id;

    @Column(name = "current_price")
    private BigDecimal currPrice = BigDecimal.ZERO;

    @Column(name = "low_price")
    private BigDecimal low_price = BigDecimal.ZERO;

    @Column(name = "hight_price")
    private BigDecimal hight_price = BigDecimal.ZERO;

    @Column(name = "price_open_candle")
    private BigDecimal price_open_candle = BigDecimal.ZERO;

    @Column(name = "price_close_candle")
    private BigDecimal price_close_candle = BigDecimal.ZERO;

    @Column(name = "trading_qty")
    private BigDecimal trading_qty = BigDecimal.ZERO;

    @Column(name = "trading_volume")
    private BigDecimal trading_volume = BigDecimal.ZERO;

    @Column(name = "taker_qty")
    private BigDecimal taker_qty = BigDecimal.ZERO;

    @Column(name = "taker_volume")
    private BigDecimal taker_volume = BigDecimal.ZERO;

    @Column(name = "uptrend")
    private boolean uptrend = true;

    @Override
    public String toString() {
        String change = Utils.toPercent(price_close_candle, price_open_candle, 2);
        String amplitude = Utils
                .removeLastZero(Utils.getBigDecimalValue(Utils.toPercent(hight_price, low_price, 2)).abs().toString());

        return id + " Up:" + uptrend + "[O:" + Utils.removeLastZero(price_open_candle.toString()) + ", H:"
                + Utils.removeLastZero(hight_price.toString()) + ", L:=" + Utils.removeLastZero(low_price.toString())
                + ", C:" + Utils.removeLastZero(price_close_candle.toString()) + ", Change:"
                + Utils.removeLastZero(change.toString()) + "%, Amplitude: " + amplitude + "]";
    }

    public boolean isZeroPercentCandle() {
        BigDecimal percent = Utils.getBigDecimalValue(Utils.toPercent(price_close_candle, price_open_candle, 2)).abs();

        if ((percent.compareTo(BigDecimal.ZERO) > 0) && (percent.compareTo(BigDecimal.valueOf(0.045)) < 0)) {
            return true;
        }
        return false;
    }

    public boolean isBtcKillLongCandle() {
        BigDecimal percent = Utils.getBigDecimalValue(Utils.toPercent(hight_price, low_price, 2)).abs();

        if (!uptrend && percent.compareTo(BigDecimal.valueOf(0.5)) > 0) {
            return true;
        }

        return false;
    }

    public boolean isBtcKillShortCandle() {
        BigDecimal percent = Utils.getBigDecimalValue(Utils.toPercent(hight_price, low_price, 2)).abs();

        if (uptrend && percent.compareTo(BigDecimal.valueOf(0.5)) > 0) {
            return true;
        }

        return false;
    }

    public boolean is15mPumpingCandle() {
        BigDecimal percent = Utils.getBigDecimalValue(Utils.toPercent(price_open_candle, price_close_candle, 2)).abs();

        if (uptrend && percent.compareTo(BigDecimal.valueOf(2)) > 0) {
            return true;
        }

        return false;
    }

    public BigDecimal getCandleHeight() {
        BigDecimal change = (Utils.getBigDecimal(price_open_candle).subtract(price_close_candle)).abs();

        return change;
    }

    public boolean isDown() {
        return !uptrend;
    }
}
