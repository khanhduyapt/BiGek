package bsc_scan_binance.response;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@AllArgsConstructor
@NoArgsConstructor
public class CandidateTokenCssResponse {
    private String gecko_id = "";
    private String symbol = "";
    private String name = "";
    private String pumping_history = "";

    private String volumn_div_marketcap = "";
    private String volumn_div_marketcap_css = "";
    private String volumn_binance_div_marketcap = "";
    private String volumn_binance_div_marketcap_css = "";

    private String market_cap = "";
    private String market_cap_css = "";

    private String current_price = "";
    private String price_target = "";
    private String btc_warning_css = "";

    private String avg_percent = "";
    private String avg_price = "";
    private String avg_boll_min = "";
    private String avg_boll_max = "";
    private String max_price = "";
    private String avg_price_css = "";

    private String pre_price_history = "";
    private String gecko_total_volume = "";
    private String gecko_volumn_history = "";

    //tp_price: x2:aaa$ or 50%: bbb$ or 20%:ccc$ 10%:ddd$
    //stop_limit: price_min * 0.95
    //stop_price: price_min * 0.945
    private String oco_css = "";
    private String oco_tp_price = "";
    private String oco_tp_price_hight = "";
    private String oco_tp_price_hight_css = "";
    private String oco_stop_limit = "";
    private String oco_stop_limit_low = "";
    private String oco_stop_limit_low_css = "";
    private String oco_stop_price = "";
    private String oco_low_hight = "";
    private String ema_history;
    private String avg_history;
    private String oco_opportunity;
    private String binance_vol_rate;

    private String price_change_percentage_24h = "";
    private String price_change_percentage_7d = "";
    private String price_change_percentage_14d = "";
    private String price_change_percentage_30d = "";

    private String price_change_24h_css = "";
    private String price_change_07d_css = "";
    private String price_change_14d_css = "";
    private String price_change_30d_css = "";

    private String category = "";
    private String trend = "";
    private String total_supply = "";
    private String vector_vol1d;
    private String vector_vol1d_css;
    private String vector_vol2d;
    private String vector_vol2d_css;
    private String max_supply = "";
    private String circulating_supply = "";
    private String binance_trade = "";
    private String coin_gecko_link = "";
    private String backer = "";
    private String note = "";

    private String star = "";
    private String star_css = "";

    private String low_to_hight_price = "";
    private String today = "";
    private String day_0 = "";
    private String day_1 = "";
    private String day_2 = "";
    private String day_3 = "";
    private String day_4 = "";
    private String day_5 = "";
    private String day_6 = "";
    private String day_7 = "";
    private String day_8 = "";
    private String day_9 = "";
    private String day_10 = "";
    private String day_11 = "";
    private String day_12 = "";

    private String today_gecko_vol = "";
    private String day_0_gecko_vol = "";
    private String day_1_gecko_vol = "";
    private String day_2_gecko_vol = "";
    private String day_3_gecko_vol = "";
    private String day_4_gecko_vol = "";
    private String day_5_gecko_vol = "";
    private String day_6_gecko_vol = "";
    private String day_7_gecko_vol = "";
    private String day_8_gecko_vol = "";
    private String day_9_gecko_vol = "";
    private String day_10_gecko_vol = "";
    private String day_11_gecko_vol = "";
    private String day_12_gecko_vol = "";

    private String today_gecko_vol_css = "";
    private String day_0_gecko_vol_css = "";
    private String day_1_gecko_vol_css = "";
    private String day_2_gecko_vol_css = "";
    private String day_3_gecko_vol_css = "";
    private String day_4_gecko_vol_css = "";
    private String day_5_gecko_vol_css = "";
    private String day_6_gecko_vol_css = "";
    private String day_7_gecko_vol_css = "";
    private String day_8_gecko_vol_css = "";
    private String day_9_gecko_vol_css = "";
    private String day_10_gecko_vol_css = "";
    private String day_11_gecko_vol_css = "";
    private String day_12_gecko_vol_css = "";

    private String today_vol = "";
    private String day_0_vol = "";
    private String day_1_vol = "";
    private String day_2_vol = "";
    private String day_3_vol = "";
    private String day_4_vol = "";
    private String day_5_vol = "";
    private String day_6_vol = "";
    private String day_7_vol = "";
    private String day_8_vol = "";
    private String day_9_vol = "";
    private String day_10_vol = "";
    private String day_11_vol = "";
    private String day_12_vol = "";

    private String today_price = "";
    private String day_0_price = "";
    private String day_1_price = "";
    private String day_2_price = "";
    private String day_3_price = "";
    private String day_4_price = "";
    private String day_5_price = "";
    private String day_6_price = "";
    private String day_7_price = "";
    private String day_8_price = "";
    private String day_9_price = "";
    private String day_10_price = "";
    private String day_11_price = "";
    private String day_12_price = "";

    private String today_ema = "";
    private String day_0_ema = "";
    private String day_1_ema = "";
    private String day_2_ema = "";
    private String day_3_ema = "";
    private String day_4_ema = "";
    private String day_5_ema = "";
    private String day_6_ema = "";
    private String day_7_ema = "";
    private String day_8_ema = "";
    private String day_9_ema = "";
    private String day_10_ema = "";
    private String day_11_ema = "";
    private String day_12_ema = "";

    private String today_ema_css = "";
    private String day_0_ema_css = "";
    private String day_1_ema_css = "";
    private String day_2_ema_css = "";
    private String day_3_ema_css = "";
    private String day_4_ema_css = "";
    private String day_5_ema_css = "";
    private String day_6_ema_css = "";
    private String day_7_ema_css = "";
    private String day_8_ema_css = "";
    private String day_9_ema_css = "";
    private String day_10_ema_css = "";
    private String day_11_ema_css = "";
    private String day_12_ema_css = "";

    private String today_vol_css = "";
    private String day_0_vol_css = "";
    private String day_1_vol_css = "";
    private String day_2_vol_css = "";
    private String day_3_vol_css = "";
    private String day_4_vol_css = "";
    private String day_5_vol_css = "";
    private String day_6_vol_css = "";
    private String day_7_vol_css = "";
    private String day_8_vol_css = "";
    private String day_9_vol_css = "";
    private String day_10_vol_css = "";
    private String day_11_vol_css = "";
    private String day_12_vol_css = "";

    private String today_price_css = "";
    private String day_0_price_css = "";
    private String day_1_price_css = "";
    private String day_2_price_css = "";
    private String day_3_price_css = "";
    private String day_4_price_css = "";
    private String day_5_price_css = "";
    private String day_6_price_css = "";
    private String day_7_price_css = "";
    private String day_8_price_css = "";
    private String day_9_price_css = "";
    private String day_10_price_css = "";
    private String day_11_price_css = "";
    private String day_12_price_css = "";
}
