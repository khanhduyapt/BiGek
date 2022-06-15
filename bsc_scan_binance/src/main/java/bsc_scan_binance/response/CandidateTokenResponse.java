package bsc_scan_binance.response;

import java.math.BigDecimal;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@AllArgsConstructor
@NoArgsConstructor
public class CandidateTokenResponse {
    private String gecko_id;
    private String symbol;
    private String name;
    private String volumn_div_marketcap;
    private String pre_4h_total_volume_up;

    private String vol_now;
    private String price_now;
    private String price_pre_1h;
    private String price_pre_2h;
    private String price_pre_3h;
    private String price_pre_4h;

    private String market_cap;
    private String current_price;

    private String gecko_total_volume;
    private String gec_vol_pre_1h;
    private String gec_vol_pre_2h;
    private String gec_vol_pre_3h;
    private String gec_vol_pre_4h;

    private String price_change_percentage_24h;
    private String price_change_percentage_7d;
    private String price_change_percentage_14d;
    private String price_change_percentage_30d;
    private String category;
    private String trend;
    private String total_supply;
    private String max_supply;
    private String circulating_supply;
    private String binance_trade;
    private String coin_gecko_link;
    private String backer;
    private String note;

    private String today;
    private String day_0;
    private String day_1;
    private String day_2;
    private String day_3;
    private String day_4;
    private String day_5;
    private String day_6;
    private String day_7;
    private String day_8;
    private String day_9;
    private String day_10;
    private String day_11;
    private String day_12;
    private String priority;
    private BigDecimal ema;
    private Boolean uptrend;
}
