package bsc_scan_binance.service.impl;

import java.math.BigDecimal;
import java.math.BigInteger;
import java.math.RoundingMode;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.Calendar;
import java.util.Collection;
import java.util.Hashtable;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Objects;

import javax.persistence.EntityManager;
import javax.persistence.PersistenceContext;
import javax.persistence.Query;
import javax.transaction.Transactional;

import org.jsoup.Jsoup;
import org.jsoup.nodes.Document;
import org.jsoup.select.Elements;
import org.modelmapper.ModelMapper;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.util.CollectionUtils;
import org.springframework.web.client.RestTemplate;

import bsc_scan_binance.BscScanBinanceApplication;
import bsc_scan_binance.entity.BinanceVolumeDateTime;
import bsc_scan_binance.entity.BinanceVolumeDateTimeKey;
import bsc_scan_binance.entity.BinanceVolumnDay;
import bsc_scan_binance.entity.BinanceVolumnDayKey;
import bsc_scan_binance.entity.BinanceVolumnWeek;
import bsc_scan_binance.entity.BinanceVolumnWeekKey;
import bsc_scan_binance.entity.BollArea;
import bsc_scan_binance.entity.BtcFutures;
import bsc_scan_binance.entity.BtcVolumeDay;
import bsc_scan_binance.entity.CandidateCoin;
import bsc_scan_binance.entity.DepthAsks;
import bsc_scan_binance.entity.DepthBids;
import bsc_scan_binance.entity.FundingHistory;
import bsc_scan_binance.entity.FundingHistoryKey;
import bsc_scan_binance.entity.GeckoVolumeMonth;
import bsc_scan_binance.entity.GeckoVolumeMonthKey;
import bsc_scan_binance.entity.GeckoVolumeUpPre4h;
import bsc_scan_binance.entity.Orders;
import bsc_scan_binance.entity.PriorityCoinHistory;
import bsc_scan_binance.repository.BinanceFuturesRepository;
import bsc_scan_binance.repository.BinanceVolumeDateTimeRepository;
import bsc_scan_binance.repository.BinanceVolumnDayRepository;
import bsc_scan_binance.repository.BinanceVolumnWeekRepository;
import bsc_scan_binance.repository.BitcoinBalancesOnExchangesRepository;
import bsc_scan_binance.repository.BollAreaRepository;
import bsc_scan_binance.repository.BtcFuturesRepository;
import bsc_scan_binance.repository.BtcVolumeDayRepository;
import bsc_scan_binance.repository.CandidateCoinRepository;
import bsc_scan_binance.repository.DepthAsksRepository;
import bsc_scan_binance.repository.DepthBidsRepository;
import bsc_scan_binance.repository.FundingHistoryRepository;
import bsc_scan_binance.repository.GeckoVolumeMonthRepository;
import bsc_scan_binance.repository.GeckoVolumeUpPre4hRepository;
import bsc_scan_binance.repository.OrdersRepository;
import bsc_scan_binance.repository.PriorityCoinHistoryRepository;
import bsc_scan_binance.response.BollAreaResponse;
import bsc_scan_binance.response.BtcFuturesResponse;
import bsc_scan_binance.response.CandidateTokenCssResponse;
import bsc_scan_binance.response.CandidateTokenResponse;
import bsc_scan_binance.response.DepthResponse;
import bsc_scan_binance.response.EntryCssResponse;
import bsc_scan_binance.response.FundingResponse;
import bsc_scan_binance.response.GeckoVolumeUpPre4hResponse;
import bsc_scan_binance.response.OrdersProfitResponse;
import bsc_scan_binance.service.BinanceService;
import bsc_scan_binance.utils.Utils;
import lombok.RequiredArgsConstructor;

@Service
@RequiredArgsConstructor
public class BinanceServiceImpl implements BinanceService {
    @PersistenceContext
    private final EntityManager entityManager;

    @Autowired
    private BinanceVolumnDayRepository binanceVolumnDayRepository;

    @Autowired
    private GeckoVolumeMonthRepository geckoVolumeMonthRepository;

    @Autowired
    private BinanceVolumeDateTimeRepository binanceVolumeDateTimeRepository;

    @Autowired
    private BinanceVolumnWeekRepository binanceVolumnWeekRepository;

    @Autowired
    private BtcVolumeDayRepository btcVolumeDayRepository;

    @Autowired
    private GeckoVolumeUpPre4hRepository geckoVolumeUpPre4hRepository;

    @Autowired
    private BollAreaRepository bollAreaRepository;

    @Autowired
    private OrdersRepository ordersRepository;

    @Autowired
    private BinanceFuturesRepository binanceFuturesRepository;

    @Autowired
    private DepthBidsRepository depthBidsRepository;

    @Autowired
    private DepthAsksRepository depthAsksRepository;

    @Autowired
    private BtcFuturesRepository btcFuturesRepository;

    @Autowired
    private PriorityCoinHistoryRepository priorityCoinHistoryRepository;

    @Autowired
    private CandidateCoinRepository candidateCoinRepository;

    @Autowired
    private FundingHistoryRepository fundingHistoryRepository;

    @Autowired
    private BitcoinBalancesOnExchangesRepository bitcoinBalancesOnExchangesRepository;

    private static final String SYMBOL_BTC = "BTC";

    private static final String TIME_15m = "15m";
    private static final String TIME_5m = "5m";
    private static final String TIME_1m = "1m";

    private static final String TIME_1h = "1h";
    private static final String TIME_2h = "2h";
    private static final String TIME_4h = "4h";
    private static final String TIME_1d = "1d";
    private static final String TIME_1w = "1w";

    @SuppressWarnings("unused")
    private static final int LIMIT_DATA_15m = 48;
    private static final int LIMIT_DATA_1h = 50;
    private static final int LIMIT_DATA_4h = 60;

    private static final String EVENT_FUNDING_RATE = "FUNDING_RATE";
    private static final String EVENT_DANGER_CZ_KILL_LONG = "CZ_KILL_LONG";
    private static final String EVENT_BTC_RANGE = "BTC_RANGE";
    private static final String EVENT_BTC_ON_EXCHANGES = "BTC_EXCHANGES";
    private static final String EVENT_FIBO_LONG_SHORT = "FIBO_";
    private static final String EVENT_TREND_1W1D = "1W1D";
    // "l:Long, s:Short, n:normal"
    // DH4H1_BTC_LLL -> Search long m15.
    // DH4H1_BTC_SSS -> Search short m15.
    private static final String EVENT_D_H4_H1 = "DH4H1_"; // + SYMBOL + LLL
    private static final String EVENT_COMPRESSED_CHART = "Ma3_10_20_";
    private static final String EVENT_PUMP = "Pump_";
    private static final String EVENT_MSG_PER_HOUR = "MSG_PER_HOUR";
    private static final String SEPARATE_D1_AND_H1 = "1DH1";

    private static final String CSS_PRICE_WARNING = "bg-warning border border-warning rounded px-1";
    private static final String CSS_PRICE_SUCCESS = "border border-success rounded px-1";
    private static final String CSS_PRICE_FOCUS = "border-bottom border-dark";
    private static final String CSS_PRICE_DANGER = "border-bottom border-danger";
    private static final String CSS_PRICE_WHITE = "text-white bg-info rounded-lg px-1";
    private static final String CSS_MIN28_DAYS = "text-white rounded-lg bg-info px-1";

    // private Boolean IS_Ma10_of_BTC_h1_ALLOW_LONG = true;
    private String BTC_H1_TRENDING = "";

    private int pre_HH_CheckUSD = 0;
    private String TREND_CURRENCY_TODAY = Utils.TREND_LONG;
    private Boolean RANGE_BTC_IS_DANGER = true;
    private Boolean usd_is_uptrend_today = true;

    private String monitorBitcoinBalancesOnExchanges_temp = "";

    @SuppressWarnings("unused")
    private String pre_monitorBtcPrice_mm = "";
    List<String> monitorBtcPrice_results = new ArrayList<String>();

    private String pre_time_of_saved_data_4h = "";
    private String pre_time_of_btc_kill_long_short = "";
    private String pre_Bitfinex_status = "";
    private String preSaveDepthData;
    private String pre_btc6days = "";
    private String CHART_BTC_4H = "";
    List<BtcFutures> btc6days = new ArrayList<BtcFutures>();

    List<DepthResponse> list_bids_ok = new ArrayList<DepthResponse>();
    List<DepthResponse> list_asks_ok = new ArrayList<DepthResponse>();

    private int pre_HH = 0;
    private String pre_HH_h4 = "";
    private String sp500 = "";
    private Hashtable<String, String> msg_vol_up_dict = new Hashtable<String, String>();

    @Override
    @Transactional
    public List<CandidateTokenCssResponse> getList(Boolean isBynaceUrl) {
        try {
            String sql = " select                                                                                 \n"
                    + "   can.gecko_id,                                                                           \n"
                    + "   can.symbol,                                                                             \n"
                    + "   concat (can.name, (case when (select gecko_id from binance_futures where gecko_id=can.gecko_id) is not null then ' (Futures)' else '' end) ) as name,  \n"

                    + "    boll.low_price   as low_price_24h,                                                     \n"
                    + "    boll.hight_price as hight_price_24h,                                                   \n"
                    + "    boll.price_can_buy,                                                                    \n"
                    + "    boll.price_can_sell,                                                                   \n"
                    + "    boll.is_bottom_area,                                                                   \n"
                    + "    boll.is_top_area,                                                                      \n"
                    + "    0 as profit,                                                                           \n"
                    + "                                                                                           \n"
                    + "    0 as count_up, "

                    + "   vol.pumping_history,                                                                    \n "

                    + "   ROUND(can.volumn_div_marketcap * 100, 0) volumn_div_marketcap,                          \n"
                    + "                                                                                           \n"
                    + "   ROUND((cur.total_volume / COALESCE ((SELECT (case when pre.total_volume = 0.0 then 1000000000 else pre.total_volume end) FROM public.binance_volumn_day pre WHERE cur.gecko_id = pre.gecko_id AND cur.symbol = pre.symbol AND hh=TO_CHAR((NOW() - interval '4 hours'), 'HH24')), 1000000000) * 100 - 100), 0) pre_4h_total_volume_up, \n"
                    + "   coalesce((SELECT ROUND(pre.total_volume/1000000, 1) FROM public.binance_volumn_day pre WHERE cur.gecko_id = pre.gecko_id AND cur.symbol = pre.symbol AND hh=TO_CHAR((NOW()), 'HH24')), 0)                  as vol_now,      \n"
                    + "                                                                                           \n"
                    + "   ROUND(coalesce((SELECT pre.price_at_binance FROM public.binance_volumn_day pre WHERE cur.gecko_id = pre.gecko_id AND cur.symbol = pre.symbol AND hh=TO_CHAR((NOW()), 'HH24')), 0)                     , 5) as price_now,    \n"
                    + "   ROUND(coalesce((SELECT pre.price_at_binance FROM public.binance_volumn_day pre WHERE cur.gecko_id = pre.gecko_id AND cur.symbol = pre.symbol AND hh=TO_CHAR((NOW() - interval '1 hours'), 'HH24')), 0), 5) as price_pre_1h, \n"
                    + "   ROUND(coalesce((SELECT pre.price_at_binance FROM public.binance_volumn_day pre WHERE cur.gecko_id = pre.gecko_id AND cur.symbol = pre.symbol AND hh=TO_CHAR((NOW() - interval '2 hours'), 'HH24')), 0), 5) as price_pre_2h, \n"
                    + "   ROUND(coalesce((SELECT pre.price_at_binance FROM public.binance_volumn_day pre WHERE cur.gecko_id = pre.gecko_id AND cur.symbol = pre.symbol AND hh=TO_CHAR((NOW() - interval '3 hours'), 'HH24')), 0), 5) as price_pre_3h, \n"
                    + "   ROUND(coalesce((SELECT pre.price_at_binance FROM public.binance_volumn_day pre WHERE cur.gecko_id = pre.gecko_id AND cur.symbol = pre.symbol AND hh=TO_CHAR((NOW() - interval '4 hours'), 'HH24')), 0), 5) as price_pre_4h, \n"
                    + "                                                                                           \n"
                    + "   can.market_cap ,                                                                        \n"
                    + "   can.current_price               as current_price,                                       \n"
                    + "   can.total_volume                as gecko_total_volume,                                  \n"
                    + "   false as top10_vol_up,                                                                  \n"
                    + "   0 as vol_up_rate,                                                                       \n"
                    + "                                                                                           \n"
                    + "   coalesce((SELECT ROUND(pre.total_volume/1000000, 1) FROM public.gecko_volumn_day pre WHERE cur.gecko_id = pre.gecko_id AND cur.symbol = pre.symbol AND hh=TO_CHAR((NOW() - interval '1 hours'), 'HH24')), 0) as gec_vol_pre_1h, \n"
                    + "   coalesce((SELECT ROUND(pre.total_volume/1000000, 1) FROM public.gecko_volumn_day pre WHERE cur.gecko_id = pre.gecko_id AND cur.symbol = pre.symbol AND hh=TO_CHAR((NOW() - interval '2 hours'), 'HH24')), 0) as gec_vol_pre_2h, \n"
                    + "   coalesce((SELECT ROUND(pre.total_volume/1000000, 1) FROM public.gecko_volumn_day pre WHERE cur.gecko_id = pre.gecko_id AND cur.symbol = pre.symbol AND hh=TO_CHAR((NOW() - interval '3 hours'), 'HH24')), 0) as gec_vol_pre_3h, \n"
                    + "   coalesce((SELECT ROUND(pre.total_volume/1000000, 1) FROM public.gecko_volumn_day pre WHERE cur.gecko_id = pre.gecko_id AND cur.symbol = pre.symbol AND hh=TO_CHAR((NOW() - interval '4 hours'), 'HH24')), 0) as gec_vol_pre_4h, \n"
                    + "                                                                                           \n"
                    + "   can.price_change_percentage_24h,                                                        \n"
                    + "   can.price_change_percentage_7d,                                                         \n"
                    + "   can.price_change_percentage_14d,                                                        \n"
                    + "   can.price_change_percentage_30d,                                                        \n"
                    + "                                                                                           \n"
                    + "   can.category,                                                                           \n"
                    + "   can.trend,                                                                              \n"
                    + "   can.total_supply,                                                                       \n"
                    + "   can.max_supply,                                                                         \n"
                    + "   can.circulating_supply,                                                                 \n"
                    + "   can.binance_trade,                                                                      \n"
                    + "   can.coin_gecko_link,                                                                    \n"
                    + "   (select concat (w.symbol,' ', w.name) from priority_coin_history w where w.gecko_id = can.gecko_id) as backer,                                                                             \n"
                    + "   can.note,                                                                               \n"
                    + "                                                                                           \n"
                    + "   (select concat(w.total_volume, '~', ROUND(w.avg_price, 4), '~', ROUND(w.min_price, 4), '~', ROUND(w.max_price, 4), '~', ROUND(w.ema, 5), '~', coalesce(price_change_24h, 0), '~', ROUND(gecko_volume, 1) ) from binance_volumn_week w where w.gecko_id = can.gecko_id and w.symbol = can.symbol and yyyymmdd = TO_CHAR(NOW(), 'yyyyMMdd'))                     as today,  \n"
                    + "   (select concat(w.total_volume, '~', ROUND(w.avg_price, 4), '~', ROUND(w.min_price, 4), '~', ROUND(w.max_price, 4), '~', ROUND(w.ema, 5), '~', coalesce(price_change_24h, 0), '~', ROUND(gecko_volume, 1) ) from binance_volumn_week w where w.gecko_id = can.gecko_id and w.symbol = can.symbol and yyyymmdd = TO_CHAR(NOW() - interval '1 days', 'yyyyMMdd')) as day_0,  \n"
                    + "   (select concat(w.total_volume, '~', ROUND(w.avg_price, 4), '~', ROUND(w.min_price, 4), '~', ROUND(w.max_price, 4), '~', ROUND(w.ema, 5), '~', coalesce(price_change_24h, 0), '~', ROUND(gecko_volume, 1) ) from binance_volumn_week w where w.gecko_id = can.gecko_id and w.symbol = can.symbol and yyyymmdd = TO_CHAR(NOW() - interval '2 days', 'yyyyMMdd')) as day_1,  \n"
                    + "   (select concat(w.total_volume, '~', ROUND(w.avg_price, 4), '~', ROUND(w.min_price, 4), '~', ROUND(w.max_price, 4), '~', ROUND(w.ema, 5), '~', coalesce(price_change_24h, 0), '~', ROUND(gecko_volume, 1) ) from binance_volumn_week w where w.gecko_id = can.gecko_id and w.symbol = can.symbol and yyyymmdd = TO_CHAR(NOW() - interval '3 days', 'yyyyMMdd')) as day_2,  \n"
                    + "   (select concat(w.total_volume, '~', ROUND(w.avg_price, 4), '~', ROUND(w.min_price, 4), '~', ROUND(w.max_price, 4), '~', ROUND(w.ema, 5), '~', coalesce(price_change_24h, 0), '~', ROUND(gecko_volume, 1) ) from binance_volumn_week w where w.gecko_id = can.gecko_id and w.symbol = can.symbol and yyyymmdd = TO_CHAR(NOW() - interval '4 days', 'yyyyMMdd')) as day_3,  \n"
                    + "   (select concat(w.total_volume, '~', ROUND(w.avg_price, 4), '~', ROUND(w.min_price, 4), '~', ROUND(w.max_price, 4), '~', ROUND(w.ema, 5), '~', coalesce(price_change_24h, 0), '~', ROUND(gecko_volume, 1) ) from binance_volumn_week w where w.gecko_id = can.gecko_id and w.symbol = can.symbol and yyyymmdd = TO_CHAR(NOW() - interval '5 days', 'yyyyMMdd')) as day_4,  \n"
                    + "   (select concat(w.total_volume, '~', ROUND(w.avg_price, 4), '~', ROUND(w.min_price, 4), '~', ROUND(w.max_price, 4), '~', ROUND(w.ema, 5), '~', coalesce(price_change_24h, 0), '~', ROUND(gecko_volume, 1) ) from binance_volumn_week w where w.gecko_id = can.gecko_id and w.symbol = can.symbol and yyyymmdd = TO_CHAR(NOW() - interval '6 days', 'yyyyMMdd')) as day_5,  \n"
                    + "   (select concat(w.total_volume, '~', ROUND(w.avg_price, 4), '~', ROUND(w.min_price, 4), '~', ROUND(w.max_price, 4), '~', ROUND(w.ema, 5), '~', coalesce(price_change_24h, 0), '~', ROUND(gecko_volume, 1) ) from binance_volumn_week w where w.gecko_id = can.gecko_id and w.symbol = can.symbol and yyyymmdd = TO_CHAR(NOW() - interval '7 days', 'yyyyMMdd')) as day_6,  \n"
                    + "   (select concat(w.total_volume, '~', ROUND(w.avg_price, 4), '~', ROUND(w.min_price, 4), '~', ROUND(w.max_price, 4), '~', ROUND(w.ema, 5), '~', coalesce(price_change_24h, 0), '~', ROUND(gecko_volume, 1) ) from binance_volumn_week w where w.gecko_id = can.gecko_id and w.symbol = can.symbol and yyyymmdd = TO_CHAR(NOW() - interval '8 days', 'yyyyMMdd')) as day_7,  \n"
                    + "   (select concat(w.total_volume, '~', ROUND(w.avg_price, 4), '~', ROUND(w.min_price, 4), '~', ROUND(w.max_price, 4), '~', ROUND(w.ema, 5), '~', coalesce(price_change_24h, 0), '~', ROUND(gecko_volume, 1) ) from binance_volumn_week w where w.gecko_id = can.gecko_id and w.symbol = can.symbol and yyyymmdd = TO_CHAR(NOW() - interval '9 days', 'yyyyMMdd')) as day_8,  \n"
                    + "   (select concat(w.total_volume, '~', ROUND(w.avg_price, 4), '~', ROUND(w.min_price, 4), '~', ROUND(w.max_price, 4), '~', ROUND(w.ema, 5), '~', coalesce(price_change_24h, 0), '~', ROUND(gecko_volume, 1) ) from binance_volumn_week w where w.gecko_id = can.gecko_id and w.symbol = can.symbol and yyyymmdd = TO_CHAR(NOW() - interval '10 days', 'yyyyMMdd')) as day_9, \n"
                    + "   (select concat(w.total_volume, '~', ROUND(w.avg_price, 4), '~', ROUND(w.min_price, 4), '~', ROUND(w.max_price, 4), '~', ROUND(w.ema, 5), '~', coalesce(price_change_24h, 0), '~', ROUND(gecko_volume, 1) ) from binance_volumn_week w where w.gecko_id = can.gecko_id and w.symbol = can.symbol and yyyymmdd = TO_CHAR(NOW() - interval '11 days', 'yyyyMMdd')) as day_10, \n"
                    + "   (select concat(w.total_volume, '~', ROUND(w.avg_price, 4), '~', ROUND(w.min_price, 4), '~', ROUND(w.max_price, 4), '~', ROUND(w.ema, 5), '~', coalesce(price_change_24h, 0), '~', ROUND(gecko_volume, 1) ) from binance_volumn_week w where w.gecko_id = can.gecko_id and w.symbol = can.symbol and yyyymmdd = TO_CHAR(NOW() - interval '12 days', 'yyyyMMdd')) as day_11, \n"
                    + "   (select concat(w.total_volume, '~', ROUND(w.avg_price, 4), '~', ROUND(w.min_price, 4), '~', ROUND(w.max_price, 4), '~', ROUND(w.ema, 5), '~', coalesce(price_change_24h, 0), '~', ROUND(gecko_volume, 1) ) from binance_volumn_week w where w.gecko_id = can.gecko_id and w.symbol = can.symbol and yyyymmdd = TO_CHAR(NOW() - interval '13 days', 'yyyyMMdd')) as day_12, \n"
                    + "   can.priority,                                                                           \n"

                    + "   macd.ema07d,                                                                            \n"
                    + "   macd.ema14d,                                                                            \n"
                    + "   macd.ema21d,                                                                            \n"
                    + "   macd.ema28d,                                                                            \n"
                    + "   macd.min60d,                                                                            \n"
                    + "   macd.max28d,                                                                            \n"
                    + "   macd.min14d,                                                                            \n"
                    + "   macd.min28d,                                                                            \n" // min
                    + "   false AS uptrend,                                                                       \n"
                    + "   vol.vol0d,                                                                              \n"
                    + "   vol.vol1d,                                                                              \n"
                    + "   vol.vol7d                                                                               \n"
                    + "   , 0 vol_gecko_increate                                                                  \n"
                    + "   , cur.point AS opportunity                                                              \n"
                    + "                                                                                           \n"
                    + "   , concat('1h: ', rate1h, '%, 2h: ', rate2h, '%, 4h: ', rate4h, '%, 1d0h: ', rate1d0h, '%, 1d4h: ', rate1d4h, '%') as binance_vol_rate \n"
                    + "   , rate1h                                                                                \n"
                    + "   , rate2h                                                                                \n"
                    + "   , rate4h                                                                                \n"
                    + "   , rate1d0h                                                                              \n"
                    + "   , rate1d4h                                                                              \n"
                    + "   , cur.rsi                                                                               \n"
                    + "   , macd.futures as futures                                                               \n"
                    + "   , '' as futures_css       \n"
                    + "                                                                                           \n"
                    + " from                                                                                      \n"
                    + "   candidate_coin can,                                                                     \n"
                    + "   binance_volumn_day cur,                                                                 \n"
                    + "   view_binance_volume_rate vbvr,                                                          \n"
                    + " (                                                                                         \n"
                    + "    select                                                                                 \n"
                    + "       xyz.gecko_id,                                                                       \n"
                    + "       concat(xyz.note, ' ', xyz.symbol) as futures,                                       \n"
                    + "       COALESCE(price_today   - price_pre_07d*1.05, -99) as ema07d,                        \n"
                    + "       COALESCE(price_pre_07d - price_pre_14d, -99) as ema14d,                             \n"
                    + "       COALESCE(price_pre_14d - price_pre_21d, -99) as ema21d,                             \n"
                    + "       COALESCE(price_pre_21d - price_pre_28d, -99) as ema28d,                             \n"
                    + "       COALESCE(min60d, -99) min60d,                                                       \n"
                    + "       COALESCE(max28d, -99) max28d,                                                       \n"
                    + "       COALESCE(min14d, -99) min14d,                                                       \n"
                    + "       COALESCE(min28d, -99) min28d                                                        \n"
                    + "    from                                                                                   \n"
                    + "      (                                                                                    \n"
                    + "          select                                                                           \n"
                    + "             can.gecko_id,                                                                 \n"
                    + "             can.symbol,                                                                   \n"
                    + "             his.note,                                                                     \n"
                    + "             0 as price_today,                                                             \n"
                    + "             0 as price_pre_07d,                                                           \n"
                    + "             0 as price_pre_14d,                                                           \n"
                    + "             0 as price_pre_21d,                                                           \n"
                    + "             0 as price_pre_28d,                                                           \n"
                    + "             ROUND((select MIN(COALESCE(w.min_price, 1000000)) from binance_volumn_week w where w.gecko_id = can.gecko_id and w.symbol = can.symbol and yyyymmdd between TO_CHAR(NOW() - interval '60 days', 'yyyyMMdd') and TO_CHAR(NOW(), 'yyyyMMdd')), 5) as min60d, \n" // min60d
                    + "             ROUND((select MAX(COALESCE(w.max_price, 1000000)) from binance_volumn_week w where w.gecko_id = can.gecko_id and w.symbol = can.symbol and yyyymmdd between TO_CHAR(NOW() - interval '30 days', 'yyyyMMdd') and TO_CHAR(NOW(), 'yyyyMMdd')), 5) as max28d, \n" // max28d
                    + "             ROUND((select MIN(COALESCE(w.min_price, 1000000)) from binance_volumn_week w where w.gecko_id = can.gecko_id and w.symbol = can.symbol and yyyymmdd between TO_CHAR(NOW() - interval '14 days', 'yyyyMMdd') and TO_CHAR(NOW(), 'yyyyMMdd')), 5) as min14d, \n" // min14d
                    + "             ROUND((select MIN(COALESCE(w.min_price, 1000000)) from binance_volumn_week w where w.gecko_id = can.gecko_id and w.symbol = can.symbol and yyyymmdd between TO_CHAR(NOW() - interval '30 days', 'yyyyMMdd') and TO_CHAR(NOW(), 'yyyyMMdd')), 5) as min28d  \n" // min28d
                    + "                                                                                           \n"
                    + "          from                                                                             \n"
                    + "              candidate_coin can                                                           \n"
                    + "          left join funding_history his on  his.event_time like '%1W1D%' and his.pumpdump and his.gecko_id = can.gecko_id  \n"
                    + "    ) xyz                                                                                  \n"
                    + " ) macd                                                                                    \n"
                    + " , ("
                    + "     select                                                                                \n"
                    + "        gecko_id,                                                                          \n"
                    + "        symbol,                                                                            \n"
                    + "        pumping_history,                                                                   \n"
                    + "        ROUND((COALESCE(volume_today  , 0))/1000000, 1) as vol0d, \n"
                    + "        ROUND((COALESCE(volume_pre_01d, 0))/1000000, 1) as vol1d, \n"
                    + "        ROUND((COALESCE(volume_pre_07d, 0))/1000000, 1) as vol7d  \n"
                    + "     from                                                                                  \n"
                    + "       (                                                                                   \n"
                    + "           select                                                                          \n"
                    + "               can.gecko_id,                                                               \n"
                    + "               can.symbol,                                                                 \n"
                    + "               concat('day: '                                                              \n"
                    + "                 , coalesce((select string_agg(dd, ', ') from (SELECT distinct dd FROM (   \n"
                    + "                     select dd from gecko_volume_month where gecko_id = can.gecko_id and symbol = 'GECKO'   and total_volume > (SELECT avg(total_volume)*1.5 FROM public.gecko_volume_month where gecko_id = can.gecko_id and symbol = 'GECKO')      \n"
                    + "                     union                                                                 \n"
                    + "                     select dd from gecko_volume_month where gecko_id = can.gecko_id and symbol = 'BINANCE' and total_volume > (SELECT avg(total_volume)*1.5 FROM public.gecko_volume_month where gecko_id = can.gecko_id and symbol = 'BINANCE')    \n"
                    + "                 ) uni_dd order by dd) pump), '')                                          \n"
                    + "               ) as pumping_history,                                                       \n"

                    + "              (select COALESCE(w.total_volume, 0) from gecko_volume_month w where w.gecko_id = can.gecko_id and w.symbol = 'GECKO' and dd = TO_CHAR(NOW(), 'dd'))                      as volume_today,  \n"
                    + "              (select COALESCE(w.total_volume, 0) from gecko_volume_month w where w.gecko_id = can.gecko_id and w.symbol = 'GECKO' and dd = TO_CHAR(NOW() - interval  '1 days', 'dd')) as volume_pre_01d, \n"
                    + "              (select COALESCE(w.total_volume, 0) from gecko_volume_month w where w.gecko_id = can.gecko_id and w.symbol = 'GECKO' and dd = TO_CHAR(NOW() - interval  '6 days', 'dd')) as volume_pre_07d  \n"
                    + "           from                                                                            \n"
                    + "               candidate_coin can                                                          \n"
                    + "     ) tmp                                                                                 \n"
                    + ") vol                                                                                      \n"
                    + ", " + Utils.sql_boll_2_body
                    + "                                                                                           \n"
                    + " WHERE                                                                                     \n"
                    + "       cur.hh = (case when EXTRACT(MINUTE FROM NOW()) < 15 then TO_CHAR(NOW() - interval '1 hours', 'HH24') else TO_CHAR(NOW(), 'HH24') end) \n"
                    + "   AND can.gecko_id = cur.gecko_id                                                         \n"
                    + "   AND can.gecko_id = vbvr.gecko_id                                                        \n"
                    + "   AND can.symbol = cur.symbol                                                             \n"
                    + "   AND can.gecko_id = macd.gecko_id                                                        \n"
                    + "   AND can.gecko_id = boll.gecko_id                                                        \n"
                    + "   AND can.gecko_id = vol.gecko_id                                                         \n"
                    + (isBynaceUrl ? // " AND (case when can.symbol <> 'BTC' and can.volumn_div_marketcap < 0.25 then
                            " AND macd.futures LIKE '%move↑%'     \n" // AND macd.futures NOT LIKE '%(Spot)%'
                            : "")
                    + (!(((BscScanBinanceApplication.app_flag == Utils.const_app_flag_all_coin)
                            || (BscScanBinanceApplication.app_flag == Utils.const_app_flag_all_and_msg)))
                                    ? "   AND can.gecko_id IN (SELECT gecko_id FROM binance_futures) \n"
                                    : "")
                    + " order by                                                                                    \n"
                    + "     coalesce(can.priority, 3) ASC                                                           \n"
                    + "   , (case when (macd.futures LIKE '%Futures%' AND macd.futures LIKE '%_Position%') then 10 when (macd.futures LIKE '%Futures%' AND macd.futures LIKE '%Long_4h%') then 11 when (macd.futures LIKE '%Futures%' AND macd.futures LIKE '%move↑%') then 15 when macd.futures LIKE '%Futures%' then 19 \n"
                    + "           when (macd.futures LIKE '%Spot%'    AND macd.futures LIKE '%_Position%') then 30 when (macd.futures LIKE '%Spot%'    AND macd.futures LIKE '%Long_4h%') then 31 when (macd.futures LIKE '%Spot%'    AND macd.futures LIKE '%move↑%') then 35 when macd.futures LIKE '%Spot%'    then 39 \n"
                    + "       else 100 end) ASC \n"
                    + "   , (case when can.volumn_div_marketcap >= 0.2 then 1 else 0 end) DESC                      \n"
                    + "   , vbvr.rate1d0h DESC, vbvr.rate4h DESC                                                    \n";

            Query query = entityManager.createNativeQuery(sql, "CandidateTokenResponse");
            @SuppressWarnings("unchecked")
            List<CandidateTokenResponse> results = query.getResultList();

            int weekUp = 0;
            int cutUp = 0;
            int count_stop_long = 0;
            for (CandidateTokenResponse dto : results) {
                String futu = Utils.getStringValue(dto.getFutures());

                if (futu.contains("W↑")) {
                    weekUp += 1;
                }

                if (futu.contains("move↑")) {
                    cutUp += 1;
                }

                if (futu.contains(Utils.TREND_STOP_LONG) || futu.contains(Utils.TREND_DANGER)) {
                    count_stop_long += 1;
                }
            }
            String totalMarket = "W↑=" + weekUp + "(" + Utils
                    .getPercentStr(BigDecimal.valueOf(results.size() - weekUp), BigDecimal.valueOf(results.size()))
                    .replace("-", "") + ")";
            totalMarket += ", W↓=" + (results.size() - weekUp) + "(" + Utils
                    .getPercentStr(BigDecimal.valueOf(weekUp), BigDecimal.valueOf(results.size())).replace("-", "")
                    + ")";

            totalMarket += ", ↑D(ma8)=" + cutUp + "(" + Utils
                    .getPercentStr(BigDecimal.valueOf(results.size() - cutUp), BigDecimal.valueOf(results.size()))
                    .replace("-", "") + ")";

            totalMarket += " AUD_EUR_GBP:" + (Objects.equals(TREND_CURRENCY_TODAY, Utils.TREND_LONG) ? "↑" : "↓")
                    + " USDT:" + (Objects.equals(TREND_CURRENCY_TODAY, Utils.TREND_LONG) ? "↓" : "↑");
            totalMarket += " Stop(" + count_stop_long + "/" + results.size() + ")";

            List<CandidateTokenCssResponse> list = new ArrayList<CandidateTokenCssResponse>();
            ModelMapper mapper = new ModelMapper();
            Integer index = 1;
            String dd = Utils.getToday_dd();
            String ddAdd1 = Utils.getDdFromToday(1);
            String ddAdd2 = Utils.getDdFromToday(2);

            // monitorTokenSales(results);
            for (CandidateTokenResponse dto : results) {
                CandidateTokenCssResponse css = new CandidateTokenCssResponse();
                mapper.map(dto, css);

                BigDecimal price_now = Utils.getBigDecimal(dto.getPrice_now());
                BigDecimal mid_price = Utils.getMidPrice(dto.getPrice_can_buy(), dto.getPrice_can_sell());
                BigDecimal market_cap = Utils.getBigDecimal(dto.getMarket_cap());
                BigDecimal gecko_total_volume = Utils.getBigDecimal(dto.getGecko_total_volume());

                if (css.getName().toUpperCase().contains("FUTURES")) {
                    css.setTrading_view("https://vn.tradingview.com/chart/?symbol=BINANCE%3A"
                            + dto.getSymbol().toUpperCase() + "USDTPERP");
                } else {
                    css.setTrading_view("https://vn.tradingview.com/chart/?symbol=BINANCE%3A"
                            + dto.getSymbol().toUpperCase() + "USDT");
                }

                if ((market_cap.compareTo(BigDecimal.valueOf(36000001)) < 0)
                        && (market_cap.compareTo(BigDecimal.valueOf(1000000)) > 0)) {
                    css.setMarket_cap_css("highlight rounded-lg px-1");
                } else if (market_cap.compareTo(BigDecimal.valueOf(1000000000)) > 0) {
                    css.setMarket_cap_css("bg-warning rounded-lg px-1");
                }

                BigDecimal volumn_binance_div_marketcap = BigDecimal.ZERO;
                String volumn_binance_div_marketcap_str = "";
                if (market_cap.compareTo(BigDecimal.ZERO) > 0) {
                    volumn_binance_div_marketcap = Utils.getBigDecimal(dto.getVol_now()).divide(
                            market_cap.divide(BigDecimal.valueOf(100000000), 6, RoundingMode.CEILING), 1,
                            RoundingMode.CEILING);
                } else if (gecko_total_volume.compareTo(BigDecimal.ZERO) > 0) {
                    volumn_binance_div_marketcap = Utils.getBigDecimal(dto.getVol_now()).divide(
                            gecko_total_volume.divide(BigDecimal.valueOf(100000000), 6, RoundingMode.CEILING), 1,
                            RoundingMode.CEILING);
                }

                if (getValue(css.getVolumn_div_marketcap()) > Long.valueOf(100)) {
                    css.setVolumn_div_marketcap_css("text-primary highlight rounded-lg");
                } else if (getValue(css.getVolumn_div_marketcap()) >= Long.valueOf(20)) {
                    css.setVolumn_div_marketcap_css("highlight rounded-lg");
                } else {
                    // css.setVolumn_div_marketcap_css("text-danger bg-light");
                }

                if (volumn_binance_div_marketcap.compareTo(BigDecimal.valueOf(30)) > 0) {
                    volumn_binance_div_marketcap_str = "B:" + volumn_binance_div_marketcap.toString();
                    // css.setVolumn_div_marketcap_css("highlight rounded-lg");
                } else if (volumn_binance_div_marketcap.compareTo(BigDecimal.valueOf(20)) > 0) {
                    volumn_binance_div_marketcap_str = "B:" + volumn_binance_div_marketcap.toString();
                    // css.setVolumn_binance_div_marketcap_css("text-primary");

                } else if (volumn_binance_div_marketcap.compareTo(BigDecimal.valueOf(10)) > 0) {
                    volumn_binance_div_marketcap_str = "B:" + volumn_binance_div_marketcap.toString();

                } else {
                    volumn_binance_div_marketcap_str = volumn_binance_div_marketcap.toString();
                }

                css.setVolumn_binance_div_marketcap(volumn_binance_div_marketcap_str);
                if (css.getPumping_history().contains(dd)) {
                    css.setPumping_history_css("text-white bg-success rounded-lg");
                } else if (css.getPumping_history().contains(ddAdd1) || css.getPumping_history().contains(ddAdd2)) {
                    css.setPumping_history_css("bg-warning rounded-lg");
                }
                if (css.getPumping_history().length() > 31) {
                    css.setPumping_history(css.getPumping_history().substring(0, 31) + "...");
                }

                if (css.getName().contains("Futures")) {
                    css.setBinance_trade(
                            "https://www.binance.com/en/futures/" + dto.getSymbol().toUpperCase() + "USDT");
                } else {
                    css.setBinance_trade("https://www.binance.com/en/trade/" + dto.getSymbol().toUpperCase() + "USDT");
                }

                // Price
                if (!Objects.equals("BTC", dto.getSymbol())) {

                    // _PositionBTC15m
                    // _PositionBTC4h

                    css.setToken_btc_link(
                            "https://vn.tradingview.com/chart/?symbol=BINANCE%3A" + dto.getSymbol() + "BTC");
                    if (dto.getFutures().contains("_PositionBTC")) {
                        css.setBtc_warning_css(CSS_PRICE_WARNING);
                    }
                }

                css.setCurrent_price(Utils.removeLastZero(dto.getCurrent_price()));
                css.setPrice_change_24h_css(Utils.getTextCss(css.getPrice_change_percentage_24h()));
                css.setPrice_change_07d_css(Utils.getTextCss(css.getPrice_change_percentage_7d()));
                css.setPrice_change_14d_css(Utils.getTextCss(css.getPrice_change_percentage_14d()));
                css.setPrice_change_30d_css(Utils.getTextCss(css.getPrice_change_percentage_30d()));

                List<String> volList = new ArrayList<String>();
                List<String> avgPriceList = new ArrayList<String>();
                List<String> lowPriceList = new ArrayList<String>();
                List<String> hightPriceList = new ArrayList<String>();

                List<String> temp = splitVolAndPrice(css.getToday());
                css.setToday_vol(temp.get(0));
                String mid_price_percent = Utils.toPercent(mid_price, price_now);
                css.setToday_price(Utils.removeLastZero(mid_price.toString()) + "$ (" + mid_price_percent + "%)");

                if (mid_price_percent.contains("-")) {
                    css.setToday_price_css("text-danger");
                } else {
                    css.setToday_price_css("text-primary");
                }

                css.setToday_gecko_vol(
                        temp.get(6) + " (Vol4h: " + Utils.getBigDecimal(dto.getVol_up_rate()).toString() + ")");

                css.setToday_ema(Utils.getPercentVol2Mc(temp.get(6), dto.getMarket_cap()));

                volList.add("");
                avgPriceList.add(temp.get(1));
                lowPriceList.add(temp.get(2));
                hightPriceList.add(temp.get(3));
                BigDecimal highest_price_today = Utils.getBigDecimalValue(temp.get(3));

                temp = splitVolAndPrice(css.getDay_0());
                css.setDay_0_vol(temp.get(0));
                css.setDay_0_price(temp.get(1));
                css.setDay_0_ema(Utils.getPercentVol2Mc(temp.get(6), dto.getMarket_cap()));
                css.setDay_0_gecko_vol(temp.get(6));

                volList.add(temp.get(0));
                avgPriceList.add(temp.get(1));
                lowPriceList.add(temp.get(2));
                hightPriceList.add(temp.get(3));

                temp = splitVolAndPrice(css.getDay_1());
                css.setDay_1_vol(temp.get(0));
                css.setDay_1_price(temp.get(1));
                // css.setDay_1_ema(temp.get(4) + " (" + temp.get(5).replace("-", "↓") + "%)");
                css.setDay_1_ema(Utils.getPercentVol2Mc(temp.get(6), dto.getMarket_cap()));
                css.setDay_1_gecko_vol(temp.get(6));

                volList.add(temp.get(0));
                avgPriceList.add(temp.get(1));
                lowPriceList.add(temp.get(2));
                hightPriceList.add(temp.get(3));

                temp = splitVolAndPrice(css.getDay_2());
                css.setDay_2_vol(temp.get(0));
                css.setDay_2_price(temp.get(1));
                // css.setDay_2_ema(temp.get(4) + " (" + temp.get(5).replace("-", "↓") + "%)");
                css.setDay_2_ema(Utils.getPercentVol2Mc(temp.get(6), dto.getMarket_cap()));
                css.setDay_2_gecko_vol(temp.get(6));

                volList.add(temp.get(0));
                avgPriceList.add(temp.get(1));
                lowPriceList.add(temp.get(2));
                hightPriceList.add(temp.get(3));

                temp = splitVolAndPrice(css.getDay_3());
                css.setDay_3_vol(temp.get(0));
                css.setDay_3_price(temp.get(1));
                // css.setDay_3_ema(temp.get(4) + " (" + temp.get(5).replace("-", "↓") + "%)");
                css.setDay_3_ema(Utils.getPercentVol2Mc(temp.get(6), dto.getMarket_cap()));
                css.setDay_3_gecko_vol(temp.get(6));

                volList.add(temp.get(0));
                avgPriceList.add(temp.get(1));
                lowPriceList.add(temp.get(2));
                hightPriceList.add(temp.get(3));

                temp = splitVolAndPrice(css.getDay_4());
                css.setDay_4_vol(temp.get(0));
                css.setDay_4_price(temp.get(1));
                // css.setDay_4_ema(temp.get(4) + " (" + temp.get(5).replace("-", "↓") + "%)");
                css.setDay_4_ema(Utils.getPercentVol2Mc(temp.get(6), dto.getMarket_cap()));
                css.setDay_4_gecko_vol(temp.get(6));

                volList.add(temp.get(0));
                avgPriceList.add(temp.get(1));
                lowPriceList.add(temp.get(2));
                hightPriceList.add(temp.get(3));

                temp = splitVolAndPrice(css.getDay_5());
                css.setDay_5_vol(temp.get(0));
                css.setDay_5_price(temp.get(1));
                // css.setDay_5_ema(temp.get(4) + " (" + temp.get(5).replace("-", "↓") + "%)");
                css.setDay_5_ema(Utils.getPercentVol2Mc(temp.get(6), dto.getMarket_cap()));
                css.setDay_5_gecko_vol(temp.get(6));

                volList.add(temp.get(0));
                avgPriceList.add(temp.get(1));
                lowPriceList.add(temp.get(2));
                hightPriceList.add(temp.get(3));

                temp = splitVolAndPrice(css.getDay_6());
                css.setDay_6_vol(temp.get(0));
                css.setDay_6_price(temp.get(1));
                // css.setDay_6_ema(temp.get(4) + " (" + temp.get(5).replace("-", "↓") + "%)");
                css.setDay_6_ema(Utils.getPercentVol2Mc(temp.get(6), dto.getMarket_cap()));
                css.setDay_6_gecko_vol(temp.get(6));

                volList.add(temp.get(0));
                avgPriceList.add(temp.get(1));
                lowPriceList.add(temp.get(2));
                hightPriceList.add(temp.get(3));

                temp = splitVolAndPrice(css.getDay_7());
                css.setDay_7_vol(temp.get(0));
                css.setDay_7_price(temp.get(1));
                // css.setDay_7_ema(temp.get(4) + " (" + temp.get(5).replace("-", "↓") + "%)");
                css.setDay_7_ema(Utils.getPercentVol2Mc(temp.get(6), dto.getMarket_cap()));
                css.setDay_7_gecko_vol(temp.get(6));

                volList.add(temp.get(0));
                avgPriceList.add(temp.get(1));
                lowPriceList.add(temp.get(2));
                hightPriceList.add(temp.get(3));

                temp = splitVolAndPrice(css.getDay_8());
                css.setDay_8_vol(temp.get(0));
                css.setDay_8_price(temp.get(1));
                // css.setDay_8_ema(temp.get(4) + " (" + temp.get(5).replace("-", "↓") + "%)");
                css.setDay_8_ema(Utils.getPercentVol2Mc(temp.get(6), dto.getMarket_cap()));
                css.setDay_8_gecko_vol(temp.get(6));

                volList.add(temp.get(0));
                avgPriceList.add(temp.get(1));
                lowPriceList.add(temp.get(2));
                hightPriceList.add(temp.get(3));

                temp = splitVolAndPrice(css.getDay_9());
                css.setDay_9_vol(temp.get(0));
                css.setDay_9_price(temp.get(1));
                // css.setDay_9_ema(temp.get(4) + " (" + temp.get(5).replace("-", "↓") + "%)");
                css.setDay_9_ema(Utils.getPercentVol2Mc(temp.get(6), dto.getMarket_cap()));
                css.setDay_9_gecko_vol(temp.get(6));

                volList.add(temp.get(0));
                avgPriceList.add(temp.get(1));
                lowPriceList.add(temp.get(2));
                hightPriceList.add(temp.get(3));

                temp = splitVolAndPrice(css.getDay_10());
                css.setDay_10_vol(temp.get(0));
                css.setDay_10_price(temp.get(1));
                // css.setDay_10_ema(temp.get(4) + " (" + temp.get(5).replace("-", "↓") + "%)");
                css.setDay_10_ema(Utils.getPercentVol2Mc(temp.get(6), dto.getMarket_cap()));
                css.setDay_10_gecko_vol(temp.get(6));

                volList.add(temp.get(0));
                avgPriceList.add(temp.get(1));
                lowPriceList.add(temp.get(2));
                hightPriceList.add(temp.get(3));

                temp = splitVolAndPrice(css.getDay_11());
                css.setDay_11_vol(temp.get(0));
                css.setDay_11_price(temp.get(1));
                // css.setDay_11_ema(temp.get(4) + " (" + temp.get(5).replace("-", "↓") + "%)");
                css.setDay_11_ema(Utils.getPercentVol2Mc(temp.get(6), dto.getMarket_cap()));
                css.setDay_11_gecko_vol(temp.get(6));

                volList.add(temp.get(0));
                avgPriceList.add(temp.get(1));
                lowPriceList.add(temp.get(2));
                hightPriceList.add(temp.get(3));

                temp = splitVolAndPrice(css.getDay_12());
                css.setDay_12_vol(temp.get(0));
                css.setDay_12_price(temp.get(1));
                // css.setDay_12_ema(temp.get(4) + " (" + temp.get(5).replace("-", "↓") + "%)");
                css.setDay_12_ema(Utils.getPercentVol2Mc(temp.get(6), dto.getMarket_cap()));
                css.setDay_12_gecko_vol(temp.get(6));

                volList.add(temp.get(0));
                avgPriceList.add(temp.get(1));
                lowPriceList.add(temp.get(2));
                hightPriceList.add(temp.get(3));

                int idx_vol_max = getIndexMax(volList);
                int idx_price_max = getIndexMax(avgPriceList);
                int idx_vol_min = getIndexMin(volList);
                int idx_price_min = getIndexMin(avgPriceList);

                String str_down = "";
                if (Utils.getBigDecimal(avgPriceList.get(idx_price_min)).compareTo(BigDecimal.ZERO) > 0) {
                    BigDecimal down = Utils.getBigDecimal(avgPriceList.get(idx_price_max))
                            .divide(Utils.getBigDecimal(avgPriceList.get(idx_price_min)), 2, RoundingMode.CEILING)
                            .multiply(BigDecimal.valueOf(100));
                    str_down = "(" + down.subtract(BigDecimal.valueOf(100)).toString().replace(".00", "") + "%)";
                }
                setVolumnDayCss(css, idx_vol_max, "text-primary"); // Max Volumn
                setPriceDayCss(css, idx_price_max, "text-primary", ""); // Max Price
                setVolumnDayCss(css, idx_vol_min, "text-danger"); // Min Volumn
                setPriceDayCss(css, idx_price_min, "text-danger", str_down); // Min Price

                BigDecimal min_add_5_percent = Utils.getBigDecimal(avgPriceList.get(idx_price_min));
                min_add_5_percent = min_add_5_percent.multiply(BigDecimal.valueOf(Double.valueOf(1.05)));

                BigDecimal max_subtract_5_percent = Utils.getBigDecimal(avgPriceList.get(idx_price_max));
                max_subtract_5_percent.multiply(BigDecimal.valueOf(Double.valueOf(0.95)));

                // --------------AVG PRICE---------------
                BigDecimal avg_price = BigDecimal.ZERO;
                BigDecimal total_price = BigDecimal.ZERO;
                for (String price : avgPriceList) {
                    if (!Objects.equals("", price)) {
                        total_price = total_price.add(Utils.getBigDecimalValue(price));
                    }
                }

                avg_price = total_price.divide(BigDecimal.valueOf(avgPriceList.size()), 10, RoundingMode.CEILING);

                price_now = Utils.getBigDecimalValue(css.getCurrent_price());

                if ((price_now.compareTo(BigDecimal.ZERO) > 0) && (avg_price.compareTo(BigDecimal.ZERO) > 0)) {

                    BigDecimal percent = Utils.getBigDecimalValue(Utils.toPercent(avg_price, price_now, 1));
                    css.setAvg_price(Utils.removeLastZero(Utils.roundDefault(avg_price)));
                    css.setAvg_percent(percent.toString() + "%");
                } else {
                    css.setAvg_price("0.0");
                }

                {
                    if ((Utils.getBigDecimal(dto.getRate1d0h()).compareTo(BigDecimal.valueOf(1000)) > 0)
                            || (Utils.getBigDecimal(dto.getRate1d4h()).compareTo(BigDecimal.valueOf(1000)) > 0)) {

                        css.setRate1d0h_css("text-primary font-weight-bold");
                        css.setStar(css.getStar() + " Volx10");

                    } else if ((Utils.getBigDecimal(dto.getRate1d0h()).compareTo(BigDecimal.valueOf(500)) > 0)
                            || (Utils.getBigDecimal(dto.getRate1d4h()).compareTo(BigDecimal.valueOf(500)) > 0)) {

                        css.setRate1d0h_css("text-primary font-weight-bold");
                        css.setStar(css.getStar() + " Volx5");

                    } else if (Utils.getBigDecimal(dto.getRate1d0h()).compareTo(BigDecimal.valueOf(200)) > 0) {
                        css.setRate1d0h_css("text-primary font-weight-bold");
                    } else if (Utils.getBigDecimal(dto.getRate1d0h()).compareTo(BigDecimal.valueOf(100)) > 0) {
                        css.setRate1d0h_css("text-primary");
                    } else if (Utils.getBigDecimal(dto.getRate1d0h()).compareTo(BigDecimal.valueOf(-30)) < 0) {
                        css.setRate1d0h_css("text-danger font-weight-bold");
                    } else if (Utils.getBigDecimal(dto.getRate1d0h()).compareTo(BigDecimal.valueOf(0)) < 0) {
                        css.setRate1d0h_css("text-danger");
                    }

                    if (Utils.getBigDecimal(dto.getRate1h()).compareTo(BigDecimal.valueOf(40)) > 0) {
                        css.setRate1h_css("text-primary");
                    } else if (Utils.getBigDecimal(dto.getRate1h()).compareTo(BigDecimal.valueOf(0)) < 0) {
                        css.setRate1h_css("text-danger");
                    }

                    if (Utils.getBigDecimal(dto.getRate2h()).compareTo(BigDecimal.valueOf(30)) > 0) {
                        css.setRate2h_css("text-primary");
                    } else if (Utils.getBigDecimal(dto.getRate2h()).compareTo(BigDecimal.valueOf(0)) < 0) {
                        css.setRate2h_css("text-danger");
                    }

                    if (Utils.getBigDecimal(dto.getRate4h()).compareTo(BigDecimal.valueOf(40)) > 0) {
                        css.setRate4h_css("text-primary");
                    } else if (Utils.getBigDecimal(dto.getRate4h()).compareTo(BigDecimal.valueOf(0)) < 0) {
                        css.setRate4h_css("text-danger");
                    }

                    BigDecimal price_max = Utils.getBigDecimal(avgPriceList.get(idx_price_max));
                    BigDecimal min_14d_per = Utils.getBigDecimalValue(Utils.toPercent(dto.getMin14d(), price_now));
                    String min_14d = "Min14d: " + Utils.removeLastZero(dto.getMin14d().toString()) + "(" + min_14d_per
                            + "%) Max14d: ";

                    if (min_14d_per.compareTo(BigDecimal.valueOf(-0.8)) > 0) {
                        css.setStar("m14d" + css.getStar());
                        // css.setStar_css("text-white rounded-lg bg-info");

                        css.setMin_14d_css("text-primary");

                    } else if (min_14d_per.compareTo(BigDecimal.valueOf(-3)) > 0) {
                        css.setMin_14d_css("text-primary");
                    }

                    String max_14d_percent = Utils.toPercent(price_max, price_now);
                    css.setOco_tp_price(min_14d);
                    css.setOco_tp_price_hight(price_max.toString() + "(" + max_14d_percent + "%)");

                    if (Utils.getBigDecimalValue(max_14d_percent).compareTo(BigDecimal.valueOf(20)) > 0) {
                        css.setOco_tp_price_hight_css("text-primary");
                    } else {
                        css.setOco_tp_price_hight_css("text-danger");
                    }

                    BigDecimal min28d_percent = Utils.getBigDecimalValue(Utils.toPercent(dto.getMin28d(), price_now));
                    BigDecimal max28d_percent = Utils.getBigDecimalValue(Utils.toPercent(dto.getMax28d(), price_now));

                    String avg_history = "Min60d: " + Utils.removeLastZero(dto.getMin60d().toString()) + "("
                            + Utils.toPercent(dto.getMin60d(), price_now) + "%)";

                    avg_history += ", Max28d: " + Utils.removeLastZero(dto.getMax28d().toString()) + "("
                            + max28d_percent + "%)";
                    avg_history += ", Min28d: ";
                    String min28day = Utils.removeLastZero(dto.getMin28d().toString()) + "(" + min28d_percent + "%)";

                    if (min28d_percent.compareTo(BigDecimal.valueOf(-10)) > 0) {
                        css.setMin28day_css(CSS_MIN28_DAYS);
                    }

                    css.setAvg_history(avg_history);
                    css.setMin28day(min28day);
                }

                if (!Objects.equals(null, dto.getPrice_can_buy()) && !Objects.equals(null, dto.getPrice_can_sell())
                        && BigDecimal.ZERO.compareTo(dto.getPrice_can_buy()) != 0
                        && BigDecimal.ZERO.compareTo(dto.getPrice_can_sell()) != 0) {

                    BigDecimal price_can_buy_24h = dto.getPrice_can_buy();
                    BigDecimal price_can_sell_24h = dto.getPrice_can_sell();

                    BigDecimal temp_prire_24h = Utils
                            .formatPrice(dto.getLow_price_24h().multiply(BigDecimal.valueOf(1.008)), 5);
                    if (dto.getPrice_can_buy().compareTo(temp_prire_24h) < 0) {
                        temp_prire_24h = dto.getPrice_can_buy();
                    }
                    temp_prire_24h = Utils.formatPriceLike(temp_prire_24h, price_now);
                    css.setEntry_price(temp_prire_24h);

                    String futu = dto.getFutures().replace("(Futures) ", "") + " ";

                    // volma(h1x2.5) AAVE
                    if (futu.contains("volma{") && futu.contains("}volma")) {
                        try {
                            String volma = futu.substring(futu.indexOf("volma{"), futu.indexOf("}volma"));
                            futu = futu.replace(volma + "}volma", "").replaceAll("  ", "");
                            volma = volma.replace("volma{", "");
                            css.setVolma(volma);

                            if (volma.contains("pump")) {
                                // css.setVolma_css("text-primary font-weight-bold");
                            } else if (volma.contains("dump")) {
                                // css.setVolma_css("text-danger font-weight-bold");
                            }

                        } catch (Exception e) {
                            css.setRange_move("volma exception");
                        }
                    }

                    if (futu.contains("scap{") && futu.contains("}scap")) {
                        try {
                            String scap = futu.substring(futu.indexOf("scap{"), futu.indexOf("}scap"));
                            futu = futu.replace(scap + "}scap", "").replaceAll("  ", "");
                            scap = scap.replace("scap{", "");
                            css.setRange_scap(scap);

                            if (scap.contains(Utils.TREND_LONG)) {
                                css.setRange_scap_css(CSS_PRICE_SUCCESS);
                            } else if (scap.contains(Utils.TREND_SHORT)) {
                                css.setRange_scap_css(CSS_PRICE_WARNING);
                            }
                        } catch (Exception e) {
                            css.setRange_move("scap exception");
                        }
                    }

                    if (futu.contains("_ma7(") && futu.contains(")~")) {
                        try {
                            String ma7 = futu.substring(futu.indexOf("_ma7("), futu.indexOf(")~") + 2);
                            futu = futu.replace(ma7, "");
                            ma7 = ma7.replace("_ma7(", "").replace(")~", "");

                            String[] arr_ma7 = ma7.split(SEPARATE_D1_AND_H1);
                            if (arr_ma7.length == 2) {
                                String range_entry_d1 = arr_ma7[0];
                                String range_entry_h1 = arr_ma7[1];

                                css.setOco_opportunity(range_entry_d1);
                                css.setRange_entry_h1(range_entry_h1);
                            } else {
                                css.setOco_opportunity(ma7.replace(SEPARATE_D1_AND_H1, ""));
                            }

                            if (ma7.contains(Utils.TREND_DANGER)) {
                                // css.setDt_range_css("text-danger");
                            }
                            if (ma7.contains(Utils.TREND_STOP_LONG)) {
                                // css.setDt_range_css("text-danger");
                            }
                        } catch (Exception e) {
                            css.setRange_move("ma7 exception");
                        }
                    }

                    String history = Utils.getStringValue(dto.getBacker()).replace("_", " ").replace(",,", ",")
                            .replace("...", " ").replace(",", ", ").replace(" ", " ").replace("Chart:", "")
                            .replaceAll(" +", " ").replace(" :", ":");
                    history = Utils.isNotBlank(history) ? "History:" + history : "";
                    css.setRange_backer(history);

                    String m2ma = "";
                    if (futu.contains("m2ma{") && futu.contains("}m2ma")) {
                        try {
                            m2ma = futu.substring(futu.indexOf("m2ma{"), futu.indexOf("}m2ma"));
                            futu = futu.replace(m2ma + "}m2ma", "").replaceAll("  ", "");

                            m2ma = m2ma.replace("m2ma{", "").replace("move", "");

                            if (m2ma.contains("↑")) {
                                css.setRange_move_css(CSS_PRICE_WHITE);
                            } else if (m2ma.contains("↓")) {
                                css.setRange_move_css(CSS_PRICE_WARNING);
                            }
                            css.setRange_move(m2ma.replace("↑", "").replace("↓", ""));

                        } catch (Exception e) {
                            css.setRange_move("m2ma exception");
                        }
                    }

                    if (futu.contains("sl2ma{") && futu.contains("}sl2ma")) {
                        try {
                            String sl2ma = futu.substring(futu.indexOf("sl2ma{"), futu.indexOf("}sl2ma"));
                            futu = futu.replace(sl2ma + "}sl2ma", "").replaceAll("  ", "");
                            sl2ma = sl2ma.replace("sl2ma{", "");

                            css.setStr_entry_price(sl2ma);

                            String[] sl_e_tp = sl2ma.split(",");
                            if (sl_e_tp.length >= 4) {
                                css.setRange_stoploss(sl_e_tp[0]);
                                css.setRange_entry(sl_e_tp[1]);
                                css.setRange_take_profit(sl_e_tp[2]);
                                css.setRange_volume(sl_e_tp[3]);

                                if (sl_e_tp[3].contains(Utils.TREND_DANGER)) {
                                    // css.setRange_volume_css("text-danger");
                                }

                                if (sl_e_tp[0].contains("SL(Short_")) {
                                    css.setRange_stoploss_css("text-danger");
                                    css.setRange_entry_css("text-danger");
                                    css.setRange_take_profit_css("text-danger");
                                    css.setRange_volume_css("text-danger");
                                } else if (sl_e_tp[0].contains("SL(Long_")) {
                                    css.setRange_stoploss_css("text-primary");
                                    css.setRange_entry_css("text-primary");
                                    css.setRange_take_profit_css("text-primary");
                                    css.setRange_volume_css("text-primary");
                                }
                            } else {
                                css.setRange_stoploss(sl2ma);
                                // css.setRange_stoploss_css("text-danger");
                            }
                        } catch (Exception e) {
                            css.setRange_move("sl2ma exception");
                        }
                    }

                    String taker = "";
                    if (futu.contains("taker{") && futu.contains("}taker")) {
                        try {
                            taker = futu.substring(futu.indexOf("taker{"), futu.indexOf("}taker"));
                            futu = futu.replace(taker + "}taker", "").replaceAll("  ", "");

                            taker = taker.replace("taker{", "");

                            css.setRange_taker_css(CSS_PRICE_WHITE);
                            css.setRange_taker(taker);
                        } catch (Exception e) {
                            css.setRange_taker("taker exception");
                        }
                    }

                    if (futu.contains("_GoodPrice")) {
                        futu = futu.replace("_GoodPrice", "");

                        css.setRange_position("Price");
                        css.setRange_position_css(CSS_PRICE_WARNING);
                    }

                    if (futu.contains("_Position")) {
                        if (futu.contains("_PositionH4")) {
                            futu = futu.replace("_PositionH4", "");

                            css.setRange_position("Long(H4)");
                            css.setRange_position_css(CSS_PRICE_SUCCESS + " bg-success");
                        }
                        if (futu.contains("_PositionD1")) {

                            futu = futu.replace("_PositionD1", "");

                            css.setRange_position("Long(D1)");
                            css.setRange_position_css(CSS_PRICE_SUCCESS + " bg-success");
                        }

                        futu = futu.replace("_PositionBTC15m", "").replace("_PositionBTC4h", "");

                        css.setRange_wdh_css("text-primary");
                        css.setStop_loss_css("text-white bg-success rounded-lg px-1");
                    }

                    if (futu.contains("W↑D↑")) {

                        css.setRange_wdh_css("text-primary font-weight-bold");

                    } else if (futu.contains("W↑ font-weight-bold")) {

                        css.setRange_wdh_css("text-primary");

                    } else if (futu.contains("W↓D↓")) {

                        css.setRange_wdh_css("text-danger font-weight-bold");

                    } else if (futu.contains("W↓")) {

                        css.setRange_wdh_css("text-danger");

                    } else {
                        css.setRange_wdh_css("");
                    }

                    String[] wdh = futu.split(",");
                    if (wdh.length >= 5) {

                        css.setRange_wdh(wdh[0]);
                        css.setRange_L10d(wdh[1]);
                        css.setRange_H10d(wdh[2]);
                        css.setRange_L6w(wdh[3]);
                        css.setRange_type(wdh[4]);

                        BigDecimal range_L10d = Utils.getPercentFromStringPercent(wdh[1]);
                        BigDecimal range_L10w = Utils.getPercentFromStringPercent(wdh[3]);

                        if ((range_L10d.compareTo(BigDecimal.valueOf(10)) < 0)
                                && (range_L10w.compareTo(BigDecimal.valueOf(10)) < 0)) {

                            css.setRange_L10d_css(CSS_PRICE_SUCCESS); // "border border-primary rounded"
                            css.setRange_L6w_css(CSS_PRICE_SUCCESS);
                        }

                        if (range_L10d.compareTo(BigDecimal.valueOf(15)) > 0) {
                            css.setRange_L10d_css(CSS_PRICE_DANGER);
                        }

                        if (range_L10w.compareTo(BigDecimal.valueOf(20)) > 0) {
                            css.setRange_L6w_css(CSS_PRICE_DANGER);
                        }

                    } else {
                        css.setRange_wdh(futu);
                    }

                    // btc_warning_css
                    if (Objects.equals("BTC", dto.getSymbol().toUpperCase())) {

                        String textDepth = getTextDepthData();
                        css.setOco_depth(textDepth);

                        BigDecimal btc_range_b_s = ((price_can_sell_24h.subtract(price_can_buy_24h))
                                .divide(price_can_buy_24h, 3, RoundingMode.CEILING));

                        // take_profit_percent > 3% ?
                        if ((btc_range_b_s.compareTo(BigDecimal.valueOf(0.015)) >= 0)) {

                            if (Utils.isGoodPriceLong(price_now, price_can_buy_24h, price_can_sell_24h)) {

                                css.setBtc_warning_css("bg-success rounded-lg");
                            }

                            if ((price_now.multiply(BigDecimal.valueOf(1.005)).compareTo(highest_price_today) > 0)) {

                                css.setBtc_warning_css("bg-danger rounded-lg");

                            }
                        }

                        css.setRange_wdh_css("");
                        if (Objects.equals(Utils.TREND_LONG, BTC_H1_TRENDING)) {
                            css.setFutures_css("text-white bg-success rounded-lg px-2");
                        } else {
                            css.setFutures_css("text-white bg-danger rounded-lg px-2");
                        }
                    }

                }

                if ((Utils.getBigDecimalValue(dto.getVolumn_div_marketcap()).compareTo(BigDecimal.valueOf(20)) < 0)
                        && (volumn_binance_div_marketcap.compareTo(BigDecimal.valueOf(10)) < 0)) {
                    // css.setVolumn_binance_div_marketcap_css("text-danger");
                }

                if (Objects.equals("BTC", dto.getSymbol().toUpperCase())) {
                    // monitorToken(css); // debug

                    if (pre_HH != Utils.getCurrentHH()) {

                        sp500 = loadPremarketSp500().replace(" ", "").replace("Futures", "(Futures)")
                                .replace(Utils.new_line_from_bot, " ");

                        pre_HH = Utils.getCurrentHH();

                        getBitfinexLongShortBtc();
                    }

                    wallToday();
                    css.setNote("");

                    css.setRange_total_w(totalMarket);
                    if (weekUp < (results.size() / 3)) {
                        css.setRange_total_w_css("text-white bg-danger rounded-lg px-2");
                    } else if (weekUp > (2 * results.size() / 3)) {
                        css.setRange_total_w_css("text-white bg-success rounded-lg px-2");
                    }

                    css.setStar(sp500);
                    css.setStar_css("display-tity text-left");
                    if (sp500.contains("-")) {
                        css.setStar_css("bg-danger rounded-lg display-tity text-left text-white");
                    }
                }

                list.add(css);
                index += 1;
            }

            // if ((count_stop_long > 0) || Utils.isNotBlank(msg_position)) {
            // String EVENT_ID = EVENT_COMPRESSED_CHART + "_POSITION_" +
            // Utils.getCurrentYyyyMmDd_Blog4h();
            // msg_position = msg_position.replace(" ", "");
            // if (msg_position.length() > 100) {
            // msg_position = msg_position.substring(0, 100) + "...";
            // }
            //
            // sendMsgPerHour(EVENT_ID, Utils.new_line_from_service + Utils.TREND_STOP_LONG
            // + "(" + count_stop_long
            // + "):Total(" + list.size() + ")" + Utils.new_line_from_service + "Position:"
            // + msg_position);
            // }

            return list;

        } catch (

        Exception e) {
            e.printStackTrace();
            return new ArrayList<CandidateTokenCssResponse>();
        }
    }

    private Long getValue(String value) {
        if (Objects.equals(null, value) || Objects.equals("", value))
            return Long.valueOf(0);

        return Long.valueOf(value);

    }

    private int getIndexMax(List<String> list) {
        int max_idx = 0;
        String str_temp = "";
        BigDecimal temp = BigDecimal.ZERO;
        BigDecimal max_val = BigDecimal.ZERO;

        for (int idx = 0; idx < list.size(); idx++) {
            str_temp = String.valueOf(list.get(idx)).replace(",", "");

            if (!Objects.equals("", str_temp)) {

                temp = Utils.getBigDecimal(str_temp);
                if (temp.compareTo(max_val) == 1) {
                    max_val = temp;
                    max_idx = idx;
                }
            }
        }

        return max_idx;
    }

    private int getIndexMin(List<String> list) {
        int min_idx = 0;
        String str_temp = "";
        BigDecimal temp = BigDecimal.ZERO;
        BigDecimal min_val = BigDecimal.valueOf(Long.MAX_VALUE);

        for (int idx = 0; idx < list.size(); idx++) {
            str_temp = String.valueOf(list.get(idx)).replace(",", "");

            if (!Objects.equals("", str_temp)) {

                temp = Utils.getBigDecimal(str_temp);
                if (temp.compareTo(min_val) == -1) {
                    min_val = temp;
                    min_idx = idx;
                }
            }
        }

        return min_idx;
    }

    private void setVolumnDayCss(CandidateTokenCssResponse css, int index, String css_class) {
        switch (index) {
        case 0:
            css.setToday_vol_css(css_class);
            break;
        case 1:
            css.setDay_0_vol_css(css_class);
            break;
        case 2:
            css.setDay_1_vol_css(css_class);
            break;
        case 3:
            css.setDay_2_vol_css(css_class);
            break;
        case 4:
            css.setDay_3_vol_css(css_class);
            break;
        case 5:
            css.setDay_4_vol_css(css_class);
            break;
        case 6:
            css.setDay_5_vol_css(css_class);
            break;
        case 7:
            css.setDay_6_vol_css(css_class);
            break;
        case 8:
            css.setDay_7_vol_css(css_class);
            break;
        case 9:
            css.setDay_8_vol_css(css_class);
            break;
        case 10:
            css.setDay_9_vol_css(css_class);
            break;
        case 11:
            css.setDay_10_vol_css(css_class);
            break;
        case 12:
            css.setDay_11_vol_css(css_class);
            break;
        case 13:
            css.setDay_12_vol_css(css_class);
            break;
        }
    }

    private void setPriceDayCss(CandidateTokenCssResponse css, int index, String css_class, String percent) {
        switch (index) {
        case 0:
            break;
        case 1:
            css.setDay_0_price_css(css_class);
            css.setDay_0_price(css.getDay_0_price() + percent);
            break;
        case 2:
            css.setDay_1_price_css(css_class);
            css.setDay_1_price(css.getDay_1_price() + percent);
            break;
        case 3:
            css.setDay_2_price_css(css_class);
            css.setDay_2_price(css.getDay_2_price() + percent);
            break;
        case 4:
            css.setDay_3_price_css(css_class);
            css.setDay_3_price(css.getDay_3_price() + percent);
            break;
        case 5:
            css.setDay_4_price_css(css_class);
            css.setDay_4_price(css.getDay_4_price() + percent);
            break;
        case 6:
            css.setDay_5_price_css(css_class);
            css.setDay_5_price(css.getDay_5_price() + percent);
            break;
        case 7:
            css.setDay_6_price_css(css_class);
            css.setDay_6_price(css.getDay_6_price() + percent);
            break;
        case 8:
            css.setDay_7_price_css(css_class);
            css.setDay_7_price(css.getDay_7_price() + percent);
            break;
        case 9:
            css.setDay_8_price_css(css_class);
            css.setDay_8_price(css.getDay_8_price() + percent);
            break;
        case 10:
            css.setDay_9_price_css(css_class);
            css.setDay_9_price(css.getDay_9_price() + percent);
            break;
        case 11:
            css.setDay_10_price_css(css_class);
            css.setDay_10_price(css.getDay_10_price() + percent);
            break;
        case 12:
            css.setDay_11_price_css(css_class);
            css.setDay_11_price(css.getDay_11_price() + percent);
            break;
        case 13:
            css.setDay_12_price_css(css_class);
            css.setDay_12_price(css.getDay_12_price() + percent);
            break;
        }
    }

    private List<String> splitVolAndPrice(String value) {
        if (Objects.isNull(value)) {
            return Arrays.asList("", "", "", "", "", "", "");
        }
        String[] arr = value.split("~");

        String volumn = arr[0];
        String avg_price = arr[1];
        String min_price = arr[2];
        String max_price = arr[3];
        volumn = String.format("%,.0f", Utils.getBigDecimal(volumn));

        return Arrays.asList(volumn, Utils.removeLastZero(avg_price), Utils.removeLastZero(min_price),
                Utils.removeLastZero(max_price), arr[4], arr[5], arr[6]);
    }

    @SuppressWarnings("unchecked")
    @Override
    @Transactional
    public void monitorProfit() {
        try {
            Query query = entityManager.createNativeQuery(Utils.sql_OrdersProfitResponse, "OrdersProfitResponse");

            List<OrdersProfitResponse> results = query.getResultList();

            if (!CollectionUtils.isEmpty(results)) {

                for (OrdersProfitResponse dto : results) {
                    String msg = "";

                    BigDecimal tp_percent = Utils.getBigDecimalValue(String.valueOf(dto.getTp_percent()));
                    BigDecimal target_percent = Utils.getBigDecimalValue(String.valueOf(dto.getTarget_percent()))
                            .multiply(BigDecimal.valueOf(0.9));

                    if (target_percent.compareTo(BigDecimal.valueOf(5)) < 0) {
                        target_percent = BigDecimal.valueOf(5);
                    }

                    if (tp_percent.compareTo(target_percent) >= 0) {

                        msg += "TakeProfit (target=" + target_percent + "%): "
                                + Utils.createMsgBalance(dto, Utils.new_line_from_service) + Utils.new_line_from_service
                                + Utils.new_line_from_service;

                    } else if (tp_percent.compareTo(BigDecimal.valueOf(-5)) <= 0) {

                        msg += "STOP LOSS 5%: " + Utils.createMsgBalance(dto, Utils.new_line_from_service)
                                + Utils.new_line_from_service + Utils.new_line_from_service;

                    } else if (tp_percent.compareTo(BigDecimal.valueOf(-1)) <= 0) {

                        msg += "STOP LOSS 1%: " + Utils.createMsgBalance(dto, Utils.new_line_from_service)
                                + Utils.new_line_from_service + Utils.new_line_from_service;
                    }

                    if (Utils.isNotBlank(msg)) {
                        Utils.sendToChatId(dto.getChatId(), msg);
                    }
                }

            }
        } catch (Exception e) {
            e.printStackTrace();
            System.out.println(e.getMessage());
        }
    }

    @Override
    @Transactional
    public void monitorBollingerBandwidth(Boolean isCallFormBot) {
        try {
            {
                String sql = "" + " select                                                              \n"
                        + "     boll.gecko_id,                                                          \n"
                        + "     boll.symbol,                                                            \n"
                        + "     boll.name,                                                              \n"
                        + "     boll.avg_price,                                                         \n"
                        + "     boll.price_open_candle,                                                 \n"
                        + "     boll.price_close_candle,                                                \n"
                        + "     boll.low_price,                                                         \n"
                        + "     boll.hight_price,                                                       \n"
                        + "     boll.price_can_buy,                                                     \n"
                        + "     boll.price_can_sell,                                                    \n"
                        + "     boll.is_bottom_area,                                                    \n"
                        + "     boll.is_top_area,                                                       \n"
                        + "     ROUND(100*(price_can_sell - price_can_buy)/price_can_buy, 2) as profit,                                             \n"
                        + "     (case when vector.vector_now > 0 then true else false end)   as vector_up,                                          \n"
                        + "     concat('v1h:', cast(vector.vector_now as varchar), ', v4h:' ,cast(vector.vector_pre4h as varchar)) as vector_desc   \n"
                        + " FROM                                                                        \n"
                        + Utils.sql_boll_2_body + " , \n"
                        + " (                                                                                      \n"
                        + "  select                                                                                \n"
                        + "       pre.gecko_id,                                                                    \n"
                        + "       pre.hh,                                                                          \n"
                        + "       ROUND(100 * (price_now   - price_pre4h) /price_pre4h, 2)  as vector_now,         \n"
                        + "       ROUND(100 * (price_pre4h - price_pre8h) /price_pre8h, 2)  as vector_pre4h        \n"
                        + "   from (                                                                               \n"
                        + "       select                                                                           \n"
                        + "       tmp.gecko_id,                                                                    \n"
                        + "       tmp.hh,                                                                          \n"
                        + "       (case when price_now is null then price_pre1h else price_now end) as price_now,  \n"
                        + "          price_pre4h,                                                                  \n"
                        + "          price_pre8h                                                                   \n"
                        + "       from (                                                                           \n"
                        + "           select                                                                       \n"
                        + "               d.gecko_id,                                                              \n"
                        + "               d.hh, \n"
                        + "               (select COALESCE(h.avg_price, 0) from btc_volumn_day h where h.gecko_id = d.gecko_id and h.hh = TO_CHAR(NOW(), 'HH24')) as price_now,                          \n"
                        + "               (select COALESCE(h.avg_price, 0) from btc_volumn_day h where h.gecko_id = d.gecko_id and h.hh = TO_CHAR(NOW() - interval  '1 hours', 'HH24')) as price_pre1h,  \n"
                        + "                                                                                             \n"
                        + "               (select ROUND(AVG(COALESCE(h.avg_price, 0)), 5) from btc_volumn_day h where h.gecko_id = d.gecko_id and h.hh between TO_CHAR(NOW() - interval  '4 hours', 'HH24') and TO_CHAR(NOW() - interval  '1 hours', 'HH24')) as price_pre4h,   \n"
                        + "               (select ROUND(AVG(COALESCE(h.avg_price, 0)), 5) from btc_volumn_day h where h.gecko_id = d.gecko_id and h.hh between TO_CHAR(NOW() - interval  '8 hours', 'HH24') and TO_CHAR(NOW() - interval  '5 hours', 'HH24')) as price_pre8h    \n"
                        + "           from  \n" + "               btc_volumn_day d \n"
                        + "           where d.hh = (case when EXTRACT(MINUTE FROM NOW()) < 15 then TO_CHAR(NOW() - interval '1 hours', 'HH24') else TO_CHAR(NOW(), 'HH24') end) \n"
                        + "           ) as tmp                                                                     \n"
                        + "   ) as pre                                                                             \n"
                        + " ) vector                                                                               \n"
                        + "                                                                                        \n"
                        + " where 1=1                                                                              \n"
                        + " and vector.gecko_id = boll.gecko_id                                                    \n";

                Query query = entityManager.createNativeQuery(sql, "BollAreaResponse");

                @SuppressWarnings("unchecked")
                List<BollAreaResponse> boll_anna_list = query.getResultList();
                if (!CollectionUtils.isEmpty(boll_anna_list)) {

                    List<BollArea> list = new ArrayList<BollArea>();
                    for (BollAreaResponse dto : boll_anna_list) {
                        BollArea entiy = (new ModelMapper()).map(dto, BollArea.class);
                        list.add(entiy);
                    }

                    bollAreaRepository.deleteAll();
                    bollAreaRepository.saveAll(list);
                }
            }

            {
                String sql = " select                                                                       \n"
                        + "     gecko_id,                                                                   \n"
                        + "     symbol,                                                                     \n"
                        + "     hh,                                                                         \n"
                        + "     curr_voulme,                                                                \n"
                        + "     avg_vol_pre4h,                                                              \n"
                        + "     ROUND(vol.curr_voulme / avg_vol_pre4h, 1) as vol_up_rate                    \n"
                        + " from                                                                            \n"
                        + " (                                                                               \n"
                        + "     select                                                                      \n"
                        + "         gecko_id,                                                               \n"
                        + "         symbol,                                                                 \n"
                        + "         hh,                                                                     \n"
                        + "         ROUND(total_volume/1000000, 1) as curr_voulme,                          \n"
                        + "         (select ROUND(AVG(COALESCE(h.total_volume, 0))/1000000, 1) from gecko_volumn_day h where h.gecko_id = d.gecko_id and h.hh between TO_CHAR(NOW() - interval  '4 hours', 'HH24') and TO_CHAR(NOW() - interval  '1 hours', 'HH24')) as avg_vol_pre4h \n"
                        + "     from gecko_volumn_day d                                                     \n"
                        + "     where d.hh = (case when EXTRACT(MINUTE FROM NOW()) < 15 then TO_CHAR(NOW() - interval '1 hours', 'HH24') else TO_CHAR(NOW(), 'HH24') end) \n"
                        + " ) vol                                                                           \n"
                        + " where                                                                           \n"
                        + "     avg_vol_pre4h > 0                                                           \n"
                        + " order by                                                                        \n"
                        + "     vol.curr_voulme / avg_vol_pre4h desc                                        \n";

                Query query = entityManager.createNativeQuery(sql, "GeckoVolumeUpPre4hResponse");

                @SuppressWarnings("unchecked")
                List<GeckoVolumeUpPre4hResponse> vol_list = query.getResultList();
                if (!CollectionUtils.isEmpty(vol_list)) {
                    geckoVolumeUpPre4hRepository.deleteAll();
                    List<GeckoVolumeUpPre4h> saveList = new ArrayList<GeckoVolumeUpPre4h>();

                    for (GeckoVolumeUpPre4hResponse dto : vol_list) {
                        GeckoVolumeUpPre4h entity = (new ModelMapper()).map(dto, GeckoVolumeUpPre4h.class);
                        entity.setGeckoid(dto.getGecko_id());
                        saveList.add(entity);
                    }
                    geckoVolumeUpPre4hRepository.saveAll(saveList);
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    @Override
    public List<Orders> getOrderList() {
        return ordersRepository.findAll();
    }

    @Override
    public String loadPremarket() {
        String sp_500 = getPreMarket("https://markets.businessinsider.com/index/s&p_500");
        String sp500_future = getPreMarket("https://markets.businessinsider.com/futures/s&p-500-futures");

        // String dow_jones =
        // getPreMarket("https://markets.businessinsider.com/index/dow_jones");
        // String dow_jones_future =
        // getPreMarket("https://markets.businessinsider.com/futures/dow-futures");
        //
        // String nasdaq =
        // getPreMarket("https://markets.businessinsider.com/index/nasdaq_100");
        // String nasdaq_future =
        // getPreMarket("https://markets.businessinsider.com/futures/nasdaq-100-futures");

        String value = "";
        value = appendStringForBot(value, sp_500);
        value = appendStringForBot(value, sp500_future);
        // value = appendStringForBot(value, "");
        // value = appendStringForBot(value, dow_jones);
        // value = appendStringForBot(value, dow_jones_future);
        // value = appendStringForBot(value, "");
        // value = appendStringForBot(value, nasdaq);
        // value = appendStringForBot(value, nasdaq_future);

        return value;
    }

    @Override
    public String loadPremarketSp500() {
        String value = "";

        String sp_500 = getPreMarket("https://markets.businessinsider.com/index/s&p_500");
        String sp500_future = getPreMarket("https://markets.businessinsider.com/futures/s&p-500-futures");

        value = appendStringForBot(value, sp_500);
        value = appendStringForBot(value, sp500_future);
        return value;
    }

    private String appendStringForBot(String value, String append) {
        String val = value;
        if (Utils.isNotBlank(append)) {
            if (Utils.isNotBlank(val)) {
                val += Utils.new_line_from_bot;
            }
            val += append.replace("E-mini ", "");
        }

        return val;
    }

    private String getPreMarket(String url) {
        try {
            Document doc = Jsoup.connect(url).get();

            Elements assets1 = doc.getElementsByClass("price-section__label");
            Elements assets2 = doc.getElementsByClass("price-section__absolute-value");
            Elements assets3 = doc.getElementsByClass("price-section__relative-value");

            String sp500 = "";
            if (!Objects.equals(null, assets1) && assets1.size() > 0) {
                sp500 = assets1.get(0).text() + "";
            }
            if (!Objects.equals(null, assets2) && assets2.size() > 0) {
                sp500 += " " + assets2.get(0).text();
            }
            if (!Objects.equals(null, assets3) && assets3.size() > 0) {
                sp500 += " (" + assets3.get(0).text() + ")";
            }
            return sp500;
        } catch (Exception e) {
        }
        return "S&P 500 xxx (xxx%), Futures yyy (yyy%)";
    }

    // ------------------------------------------------------------------------------------

    @Transactional
    public String loadBinanceData(String gecko_id, String symbol, List<BtcFutures> list_days, List<BtcFutures> list_h1,
            String point) {

        try {

            List<GeckoVolumeMonth> list_binance_vol = new ArrayList<GeckoVolumeMonth>();
            List<BinanceVolumnWeek> list_week = new ArrayList<BinanceVolumnWeek>();
            List<BinanceVolumnDay> list_day = new ArrayList<BinanceVolumnDay>();
            List<BtcVolumeDay> btc_vol_day = new ArrayList<BtcVolumeDay>();

            BinanceVolumnDay day = new BinanceVolumnDay();

            String totay = Utils.getYYYYMMDD(0);
            for (int index = 0; index < list_h1.size(); index++) {
                BtcFutures dto = list_h1.get(index);

                if (Objects.equals(totay, Utils.getYYYYMMDD2(-index))) {
                    String hh = Utils.getHH(-index);
                    {
                        BinanceVolumnDayKey id = new BinanceVolumnDayKey(gecko_id, symbol, hh);
                        day.setId(id);
                        day.setTotalVolume(dto.getTaker_volume());
                        day.setTotalTrasaction(BigDecimal.ZERO);
                        day.setPriceAtBinance(Utils.getBinancePrice(symbol));
                        day.setLow_price(dto.getLow_price());
                        day.setHight_price(dto.getHight_price());
                        day.setPrice_open_candle(dto.getPrice_open_candle());
                        day.setPrice_close_candle(dto.getPrice_close_candle());
                        day.setPoint(point);

                        list_day.add(day);
                    }

                    {
                        BtcVolumeDay btc = new BtcVolumeDay();
                        btc.setId(new BinanceVolumnDayKey(gecko_id, symbol, hh));
                        btc.setAvg_price(dto.getPrice_close_candle());
                        btc.setLow_price(dto.getLow_price());
                        btc.setHight_price(dto.getHight_price());
                        btc.setPrice_open_candle(dto.getPrice_open_candle());
                        btc.setPrice_close_candle(dto.getPrice_close_candle());
                        btc_vol_day.add(btc);
                    }

                }

                {
                    String today2 = Utils.getYYYYMMDD2(-index);
                    String dd2 = today2.substring(6, 8);
                    String hh2 = Utils.getHH(-index);
                    BinanceVolumeDateTime ddhh = new BinanceVolumeDateTime();
                    BinanceVolumeDateTimeKey key = new BinanceVolumeDateTimeKey();
                    key.setGeckoid(gecko_id);
                    key.setSymbol(symbol);
                    key.setDd(dd2);
                    key.setHh(hh2);
                    ddhh.setId(key);
                    ddhh.setVolume(dto.getTaker_volume());
                    binanceVolumeDateTimeRepository.save(ddhh);
                }

            }

            // https://www.omnicalculator.com/finance/rsi#:~:text=Calculate%20relative%20strength%20(RS)%20by,1%20%2D%20RS)%20from%20100.

            BigDecimal total_volume_month = BigDecimal.ZERO;
            String yyyymm = Utils.getYYYYMM();
            for (int index = 0; index < list_days.size(); index++) {
                BtcFutures dto = list_days.get(index);
                BinanceVolumnWeek entity = new BinanceVolumnWeek();
                String yyyymmdd = Utils.getYYYYMMDD(-index);
                entity.setId(new BinanceVolumnWeekKey(gecko_id, symbol, yyyymmdd));
                entity.setAvgPrice(dto.getPrice_close_candle());
                entity.setTotalVolume(dto.getTaker_volume());
                entity.setTotalTrasaction(BigDecimal.ZERO);
                entity.setMin_price(dto.getLow_price());
                entity.setMax_price(dto.getHight_price());

                list_week.add(entity);

                if (yyyymmdd.contains(yyyymm)) {
                    total_volume_month = total_volume_month.add(dto.getTrading_volume());
                }
            }

            {
                GeckoVolumeMonth month = new GeckoVolumeMonth();
                month.setId(new GeckoVolumeMonthKey(gecko_id, "BINANCE", Utils.getMM()));
                month.setTotalVolume(total_volume_month);
                list_binance_vol.add(month);
            }

            binanceVolumnDayRepository.saveAll(list_day);
            binanceVolumnWeekRepository.saveAll(list_week);
            geckoVolumeMonthRepository.saveAll(list_binance_vol);
            btcVolumeDayRepository.saveAll(btc_vol_day);

        } catch (

        Exception e) {
            e.printStackTrace();
        }
        return "";
    }

    private FundingHistory createPumpDumpEntity(String event, String gecko_id, String symbol, String note,
            boolean pumpdump) {
        FundingHistory entity = new FundingHistory();
        FundingHistoryKey id = new FundingHistoryKey();
        id.setEventTime(event);
        id.setGeckoid(gecko_id);
        entity.setId(id);
        entity.setSymbol(symbol);
        entity.setPumpdump(pumpdump);
        entity.setNote(note);

        return entity;
    }

    @SuppressWarnings("unchecked")
    @Override
    public String getBitfinexLongShortBtc() {
        String msg = "";
        String time = Utils.getTimeHHmm();

        // timeType=1 -> 4h
        // timeType=2 -> 1h
        // timeType=3 -> 5m
        String url = "https://fapi.coinglass.com/api/futures/longShortRate?symbol=BTC&timeType=2";
        try {
            RestTemplate restTemplate = new RestTemplate();
            Object result = restTemplate.getForObject(url, Object.class);
            LinkedHashMap<String, Object> resultMap = (LinkedHashMap<String, Object>) result;
            Object obj_key = resultMap.get("data");

            if (obj_key instanceof Collection) {
                List<Object> obj_key_list = new ArrayList<>((Collection<Object>) obj_key);
                Object temp = Utils.getLinkedHashMapValue(obj_key_list.get(0), Arrays.asList("list"));
                if (temp instanceof Collection) {
                    List<Object> exchange_list = new ArrayList<>((Collection<Object>) temp);
                    if (exchange_list.size() > 6) {
                        Object Bitfinex = exchange_list.get(6);
                        Object exchangeName = Utils.getLinkedHashMapValue(Bitfinex, Arrays.asList("exchangeName"));

                        BigDecimal longRate = Utils
                                .getBigDecimal(Utils.getLinkedHashMapValue(Bitfinex, Arrays.asList("longRate")));
                        BigDecimal longVolUsd = Utils
                                .getBigDecimal(Utils.getLinkedHashMapValue(Bitfinex, Arrays.asList("longVolUsd")));
                        longVolUsd = longVolUsd.divide(BigDecimal.valueOf(1000), 1, RoundingMode.CEILING);

                        BigDecimal shortRate = Utils
                                .getBigDecimal(Utils.getLinkedHashMapValue(Bitfinex, Arrays.asList("shortRate")));
                        BigDecimal shortVolUsd = Utils
                                .getBigDecimal(Utils.getLinkedHashMapValue(Bitfinex, Arrays.asList("shortVolUsd")));
                        shortVolUsd = shortVolUsd.divide(BigDecimal.valueOf(1000), 1, RoundingMode.CEILING);

                        msg = time + " " + Utils.getStringValue(exchangeName) + " 1h";

                        msg += " Long: " + Utils.formatPrice(longRate, 1) + "%("
                                + Utils.removeLastZero(Utils.getStringValue(longVolUsd)) + "k)";

                        msg += " Short: " + Utils.formatPrice(shortRate, 1) + "%("
                                + Utils.removeLastZero(Utils.getStringValue(shortVolUsd)) + "k)";

                        String cur_Bitfinex_status = "";
                        if (longRate.compareTo(BigDecimal.valueOf(60)) > 0) {
                            cur_Bitfinex_status = Utils.TREND_LONG;

                        }
                        if (shortRate.compareTo(BigDecimal.valueOf(60)) > 0) {
                            cur_Bitfinex_status = Utils.TREND_SHORT;
                        }

                        if (!Objects.equals(cur_Bitfinex_status, pre_Bitfinex_status)
                                && !Objects.equals(cur_Bitfinex_status, "")) {
                            pre_Bitfinex_status = cur_Bitfinex_status;
                        }
                    }

                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }

        return msg;
    }

    @SuppressWarnings({ "unchecked" })
    @Transactional
    private void saveDepthData(String gecko_id, String symbol) {
        try {
            // https://binance-docs.github.io/apidocs/spot/en/#websocket-blvt-info-streams

            String curSaveDepthData = symbol + "_" + Utils.getCurrentMinute();
            if (curSaveDepthData == preSaveDepthData) {
                return;
            }
            preSaveDepthData = curSaveDepthData;

            List<DepthBids> depthBidsList = depthBidsRepository.findAll();
            for (DepthBids entity : depthBidsList) {
                entity.setQty(BigDecimal.ZERO);
            }
            depthBidsRepository.saveAll(depthBidsList);

            List<DepthAsks> depthAsksList = depthAsksRepository.findAll();
            for (DepthAsks entity : depthAsksList) {
                entity.setQty(BigDecimal.ZERO);
            }
            depthAsksRepository.saveAll(depthAsksList);

            BigDecimal MIN_VOL = BigDecimal.valueOf(1000);
            if ("BTC".equals(symbol.toUpperCase())) {
                MIN_VOL = BigDecimal.valueOf(10000);
            }

            String url = "https://api.binance.com/api/v3/depth?limit=5000&symbol=" + symbol.toUpperCase() + "USDT";
            RestTemplate restTemplate = new RestTemplate();
            Object result = restTemplate.getForObject(url, Object.class);

            // BIDS
            {
                Object obj_bids = Utils.getLinkedHashMapValue(result, Arrays.asList("bids"));
                if (obj_bids instanceof Collection) {

                    List<Object> obj_bids2 = new ArrayList<>((Collection<Object>) obj_bids);

                    BigDecimal curr_price = BigDecimal.ZERO;
                    {
                        Object obj = obj_bids2.get(0);
                        List<Double> bids = new ArrayList<>((Collection<Double>) obj);
                        curr_price = Utils.getBigDecimalValue(String.valueOf(bids.get(0)));
                    }
                    BigDecimal MIN_PRICE = curr_price.multiply(BigDecimal.valueOf(0.5));

                    List<DepthBids> saveList = new ArrayList<DepthBids>();
                    BigInteger rowidx = BigInteger.ZERO;
                    for (Object obj : obj_bids2) {
                        List<Double> bids = new ArrayList<>((Collection<Double>) obj);
                        BigDecimal price = Utils.getBigDecimalValue(String.valueOf(bids.get(0)));
                        if (price.compareTo(MIN_PRICE) < 0) {
                            break;
                        }

                        BigDecimal qty = Utils.getBigDecimalValue(String.valueOf(bids.get(1)));

                        BigDecimal volume = price.multiply(qty);
                        if (volume.compareTo(MIN_VOL) < 0) {
                            continue;
                        }

                        DepthBids entity = new DepthBids();
                        rowidx = rowidx.add(BigInteger.valueOf(1));
                        entity.setGeckoId(gecko_id);
                        entity.setSymbol(symbol);
                        entity.setPrice(price);
                        entity.setRowidx(rowidx);
                        entity.setQty(qty);
                        saveList.add(entity);

                    }
                    depthBidsRepository.saveAll(saveList);
                }
            }

            // ASKS
            {
                Object obj_asks = Utils.getLinkedHashMapValue(result, Arrays.asList("asks"));
                if (obj_asks instanceof Collection) {
                    List<Object> obj_asks2 = new ArrayList<>((Collection<Object>) obj_asks);

                    BigDecimal curr_price = BigDecimal.ZERO;
                    {
                        Object obj = obj_asks2.get(0);
                        List<Double> ask = new ArrayList<>((Collection<Double>) obj);
                        curr_price = Utils.getBigDecimalValue(String.valueOf(ask.get(0)));
                    }
                    BigDecimal MAX_PRICE = curr_price.multiply(BigDecimal.valueOf(2));

                    List<DepthAsks> saveList = new ArrayList<DepthAsks>();
                    BigInteger rowidx = BigInteger.ZERO;
                    for (Object obj : obj_asks2) {
                        List<Double> asks = new ArrayList<>((Collection<Double>) obj);
                        BigDecimal price = Utils.getBigDecimalValue(String.valueOf(asks.get(0)));

                        if (price.compareTo(MAX_PRICE) > 0) {
                            break;
                        }

                        BigDecimal qty = Utils.getBigDecimalValue(String.valueOf(asks.get(1)));

                        BigDecimal volume = price.multiply(qty);
                        if (volume.compareTo(MIN_VOL) < 0) {
                            continue;
                        }

                        DepthAsks entity = new DepthAsks();
                        rowidx = rowidx.add(BigInteger.valueOf(1));
                        entity.setGeckoId(gecko_id);
                        entity.setSymbol(symbol);
                        entity.setPrice(price);
                        entity.setRowidx(rowidx);
                        entity.setQty(qty);
                        saveList.add(entity);
                    }
                    depthAsksRepository.saveAll(saveList);
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    // 1: all, 2: bids, 3: asks
    private List<DepthResponse> getDepthDataBtc(int type) {
        try {
            if (depthBidsRepository.count() < 1) {
                return new ArrayList<DepthResponse>();
            }

            String view = "view_btc_depth";
            String orderby = "price ASC ";
            if (type == 2) {
                view = "view_btc_depth_bids";
                orderby = "price DESC ";
            }
            if (type == 3) {
                view = "view_btc_depth_asks";
                orderby = "price ASC ";
            }

            String sql = "SELECT                                                                                  \n"
                    + "    gecko_id,                                                                              \n"
                    + "    symbol,                                                                                \n"
                    + "    price,                                                                                 \n"
                    + "    qty,                                                                                   \n"
                    + "    val_million_dolas,                                                                     \n"
                    + "    0 AS percent                                                                           \n"
                    + "FROM " + view + "                                                                          \n"
                    + "WHERE val_million_dolas > 0                                                                \n"
                    + "ORDER BY " + orderby;

            Query query = entityManager.createNativeQuery(sql, "DepthResponse");

            @SuppressWarnings("unchecked")
            List<DepthResponse> list = query.getResultList();

            return list;

        } catch (Exception e) {
            e.printStackTrace();
        }

        return new ArrayList<DepthResponse>();
    }

    @Override
    @Transactional
    public List<List<DepthResponse>> getListDepthData(String symbol) {
        List<List<DepthResponse>> result = new ArrayList<List<DepthResponse>>();
        BigDecimal current_price = Utils.getBinancePrice(symbol);

        // BTC
        if (symbol.toUpperCase().equals("BTC")) {
            saveDepthData("bitcoin", "BTC");
            List<DepthResponse> list_bids = getDepthDataBtc(2);
            List<DepthResponse> list_asks = getDepthDataBtc(3);

            list_bids_ok = new ArrayList<DepthResponse>();
            list_asks_ok = new ArrayList<DepthResponse>();

            BigDecimal WALL_3 = BigDecimal.valueOf(3);

            BigDecimal total_bids = BigDecimal.ZERO;
            for (DepthResponse dto : list_bids) {
                BigDecimal price = dto.getPrice();
                BigDecimal val = dto.getVal_million_dolas();

                if (val.compareTo(WALL_3) < 0) {
                    total_bids = total_bids.add(val);
                }

                if (val.compareTo(WALL_3) >= 0) {
                    DepthResponse real_wall = new DepthResponse();
                    real_wall.setPrice(price);
                    real_wall.setVal_million_dolas(total_bids);
                    real_wall.setPercent(Utils.getPercentStr(current_price, price));
                    list_bids_ok.add(real_wall);
                }

                dto.setPrice(price);
                dto.setPercent(Utils.getPercentStr(current_price, price));
                list_bids_ok.add(dto);
            }

            BigDecimal total_asks = BigDecimal.ZERO;
            for (DepthResponse dto : list_asks) {
                BigDecimal price = dto.getPrice();
                BigDecimal val = dto.getVal_million_dolas();

                if (val.compareTo(WALL_3) < 0) {
                    total_asks = total_asks.add(val);
                }

                if (val.compareTo(WALL_3) >= 0) {
                    DepthResponse real_wall = new DepthResponse();
                    real_wall.setPrice(price);
                    real_wall.setVal_million_dolas(total_asks);
                    real_wall.setPercent(Utils.getPercentStr(price, current_price));
                    list_asks_ok.add(real_wall);
                }

                dto.setPrice(price);
                dto.setPercent(Utils.getPercentStr(price, current_price));
                list_asks_ok.add(dto);
            }

            result.add(list_bids_ok);
            result.add(list_asks_ok);
            return result;
        }

        // Others
        try {
            List<BinanceVolumnDay> temp = binanceVolumnDayRepository.searchBySymbol(symbol);
            if (CollectionUtils.isEmpty(temp)) {
                return new ArrayList<List<DepthResponse>>();
            }

            String geckoId = temp.get(0).getId().getGeckoid();
            saveDepthData(geckoId, symbol.toUpperCase());

            list_bids_ok = getBids(geckoId, current_price);
            list_asks_ok = getAsks(geckoId, current_price);

            result.add(list_bids_ok);
            result.add(list_asks_ok);

            return result;
        } catch (Exception e) {
            e.printStackTrace();
        }

        return result;
    }

    private List<DepthResponse> getBids(String geckoId, BigDecimal current_price) {

        String sql_bids = "                                                                                     \n"
                + " select * from (                                                                             \n"

                + "SELECT                                                                                       \n"
                + "    gecko_id,                                                                                \n"
                + "    symbol,                                                                                  \n"
                + "    price,                                                                                   \n"
                + "    qty,                                                                                     \n"
                + "    round(price * qty / 1000, 1) as val_million_dolas                                        \n"
                + "    , 0 AS percent                                                                           \n"
                + "FROM                                                                                         \n"
                + "    depth_bids                                                                               \n"
                + "WHERE gecko_id = '" + geckoId + "'                                                           \n"
                + " ) depth where depth.val_million_dolas > 10   ORDER BY price DESC                            \n";

        Query query = entityManager.createNativeQuery(sql_bids, "DepthResponse");
        @SuppressWarnings("unchecked")
        List<DepthResponse> list_bids = query.getResultList();

        List<DepthResponse> list_bids_ok = new ArrayList<DepthResponse>();
        for (DepthResponse dto : list_bids) {
            if (dto.getVal_million_dolas().compareTo(BigDecimal.valueOf(50)) > 0) {
                BigDecimal price = Utils.getBigDecimalValue(Utils.removeLastZero(String.valueOf(dto.getPrice())));
                dto.setPrice(price);
                dto.setPercent(Utils.getPercentStr(current_price, price));
                list_bids_ok.add(dto);
            }
        }

        return list_bids_ok;
    }

    private List<DepthResponse> getAsks(String geckoId, BigDecimal current_price) {
        String sql_asks = "                                                                                     \n"
                + " select * from (                                                                             \n"

                + "SELECT                                                                                       \n"
                + "    gecko_id,                                                                                \n"
                + "    symbol,                                                                                  \n"
                + "    price,                                                                                   \n"
                + "    qty,                                                                                     \n"
                + "    round(price * qty / 1000, 1) as val_million_dolas                                        \n"
                + "    , 0 AS percent                                                                           \n"
                + "FROM                                                                                         \n"
                + "    depth_asks                                                                               \n"
                + "WHERE gecko_id = '" + geckoId + "'                                                           \n"

                + " ) depth where depth.val_million_dolas > 10   ORDER BY price ASC                            \n";

        Query query = entityManager.createNativeQuery(sql_asks, "DepthResponse");
        @SuppressWarnings("unchecked")
        List<DepthResponse> list_asks = query.getResultList();
        List<DepthResponse> list_asks_ok = new ArrayList<DepthResponse>();

        for (DepthResponse dto : list_asks) {
            if (dto.getVal_million_dolas().compareTo(BigDecimal.valueOf(50)) > 0) {
                BigDecimal price = Utils.getBigDecimalValue(Utils.removeLastZero(String.valueOf(dto.getPrice())));
                dto.setPrice(price);
                dto.setPercent(Utils.getPercentStr(price, current_price));
                list_asks_ok.add(dto);
            }
        }

        return list_asks_ok;
    }

    @SuppressWarnings("unused")
    private String getSL(List<DepthResponse> list, BigDecimal entry, boolean isLong) {
        if (CollectionUtils.isEmpty(list)) {
            return "";
        }

        BigDecimal max_vol = BigDecimal.ZERO;
        BigDecimal sl = BigDecimal.ZERO;

        for (int index = 0; index < list.size(); index++) {
            DepthResponse dto = list.get(index);

            if (dto.getVal_million_dolas().compareTo(max_vol) > 0) {
                if (isLong) {
                    if (dto.getPrice().compareTo(entry) < 0) {
                        max_vol = dto.getVal_million_dolas();
                        sl = dto.getPrice();
                    }
                } else {
                    if (dto.getPrice().compareTo(entry) > 0) {
                        max_vol = dto.getVal_million_dolas();
                        sl = dto.getPrice();
                    }
                }

            }
        }

        String mySL = "SL: " + Utils.removeLastZero(sl) + "("
                + (isLong ? Utils.getPercentStr(entry, sl) : Utils.getPercentStr(sl, entry)) + ")";
        return mySL;
    }

    @Override
    @Transactional
    public String getTextDepthData() {
        saveDepthData("bitcoin", "BTC");
        String result = "";
        List<DepthResponse> list = getDepthDataBtc(1);

        if (!CollectionUtils.isEmpty(list)) {
            result = list.get(0).getPrice() + "<NOW>" + list.get(list.size() - 1).getPrice();
        }

        return result.trim();
    }

    public BtcFuturesResponse getBtcFuturesResponse(String symbol, String TIME) {
        String str_id = "'" + symbol + "_" + TIME + "_%'";
        String header = symbol + "_" + TIME + "_";

        String sql = "SELECT                                                                                            \n"
                + "    (SELECT min(low_price) FROM btc_futures WHERE id like " + str_id + ") AS low_price_h, \n"
                + "    (SELECT                                                                                          \n"
                + "        ROUND(AVG(COALESCE(open_price, 0)), 5) open_candle                                           \n"
                + "    FROM(                                                                                            \n"
                + "        SELECT open_price                                                                            \n"
                + "        FROM                                                                                         \n"
                + "        (                                                                                            \n"
                + "            SELECT case when uptrend then price_open_candle else price_close_candle end as open_price \n"
                + "                  FROM btc_futures WHERE id like" + str_id + "  \n"
                + "        ) low_candle1                                                                                \n"
                + "        ORDER BY open_price asc limit 5                                                              \n"
                + "    ) low_candle) open_candle_h                                                                      \n"
                + "    ,                                                                                                \n"
                + "    (SELECT ROUND(AVG(COALESCE(close_price, 0)), 5) open_candle                                      \n"
                + "     FROM(                                                                                           \n"
                + "        SELECT close_price                                                                           \n"
                + "        FROM                                                                                         \n"
                + "        (                                                                                            \n"
                + "            SELECT case when uptrend then price_close_candle else price_open_candle end as close_price \n"
                + "              FROM btc_futures WHERE id like " + str_id + " \n"
                + "        ) close_candle1                                                                              \n"
                + "        ORDER BY close_price desc limit 5                                                            \n"
                + "    ) close_candle) close_candle_h,                                                                  \n"
                + "    (SELECT max(hight_price) FROM btc_futures WHERE id like " + str_id + ")   AS hight_price_h, \n"
                + "                                                                                                     \n"
                + "    (                                                                                                \n"
                + "        SELECT id as id_half1                                                                        \n"
                + "         FROM btc_futures WHERE id like " + str_id + " and id < '" + header + "24' \n"
                + "        ORDER BY (case when uptrend then price_open_candle else price_close_candle end) asc limit 1  \n"
                + "    )  as id_half1,                                                                                  \n"
                + "    (                                                                                                \n"
                + "        SELECT case when uptrend then price_open_candle else price_close_candle end as open_price_half1 \n"
                + "          FROM btc_futures WHERE id like " + str_id + " and id < '" + header + "24' \n"
                + "        ORDER BY open_price_half1 asc limit 1                                                        \n"
                + "    )  as open_price_half1,                                                                          \n"
                + "    (                                                                                                \n"
                + "        SELECT id as id_half2                                                                        \n"
                + "          FROM btc_futures WHERE id like " + str_id + " and id >= '" + header + "24' \n"
                + "        ORDER BY (case when uptrend then price_open_candle else price_close_candle end) asc limit 1  \n"
                + "    )  as id_half2,                                                                                  \n"
                + "    (                                                                                                \n"
                + "        SELECT case when uptrend then price_open_candle else price_close_candle end as open_price_half2 \n"
                + "          FROM btc_futures WHERE id like " + str_id + " and id >= '" + header + "24' \n"
                + "        ORDER BY open_price_half2 asc limit 1                                                        \n"
                + "    )  as open_price_half2                                                                           \n";

        Query query = entityManager.createNativeQuery(sql, "BtcFuturesResponse");

        @SuppressWarnings("unchecked")
        List<BtcFuturesResponse> vol_list = query.getResultList();
        if (CollectionUtils.isEmpty(vol_list)) {
            return null;
        }

        BtcFuturesResponse dto = vol_list.get(0);
        if (Objects.equals(null, dto.getLow_price_h())) {
            return null;
        }
        return dto;
    }

    @Override
    @Transactional
    public String getLongShortIn48h(String symbol) {
        boolean exit = true;
        if (exit) {
            return "";
        }

        List<BtcFutures> btc1hs = Utils.loadData(symbol, TIME_1h, LIMIT_DATA_1h);
        if (CollectionUtils.isEmpty(btc1hs)) {
            return "";
        }
        btcFuturesRepository.saveAll(btc1hs);
        BtcFuturesResponse dto_1h = getBtcFuturesResponse(symbol, TIME_1h);
        if (Objects.equals(null, dto_1h)) {
            return "";
        }
        BigDecimal price_at_binance = btc1hs.get(0).getCurrPrice();
        String low_height = Utils.getMsgLowHeight(price_at_binance, dto_1h);

        return low_height;
    }

    @Transactional
    private String monitorBitcoinBalancesOnExchanges() {
        // try {
        // String event = EVENT_BTC_ON_EXCHANGES + "_" + Utils.getCurrentHH();
        //
        // if (fundingHistoryRepository.existsPumDump("bitcoin", event)) {
        // return "";
        // }
        //
        // FundingHistory his = new FundingHistory();
        // FundingHistoryKey id = new FundingHistoryKey(event, "bitcoin");
        // his.setId(id);
        // his.setPumpdump(true);
        //
        // System.out.println("Start monitorBitcoinBalancesOnExchanges ---->");
        // try {
        // List<BitcoinBalancesOnExchanges> entities =
        // GoinglassUtils.getBtcExchangeBalance();
        // if (entities.size() > 0) {
        // bitcoinBalancesOnExchangesRepository.saveAll(entities);
        // }
        //
        // String sql = " SELECT \n"
        // + " fun_btc_price_now() as price_now \n"
        // + ", sum(balance_change) as change_24h \n"
        // + ", round(sum(balance_change) * fun_btc_price_now() / 1000000, 0) as
        // change_24h_val_million \n"
        // + ", sum(d7_balance_change) as change_7d \n"
        // + ", round(sum(d7_balance_change) * fun_btc_price_now() / 1000000, 0) as
        // change_7d_val_million \n"
        // + " FROM bitcoin_balances_on_exchanges \n"
        // + " WHERE \n"
        // + " yyyymmdd='" + Utils.convertDateToString("yyyyMMdd",
        // Calendar.getInstance().getTime()) + "'";
        //
        // Query query = entityManager.createNativeQuery(sql,
        // "BitcoinBalancesOnExchangesResponse");
        //
        // List<BitcoinBalancesOnExchangesResponse> vol_list = query.getResultList();
        // if (CollectionUtils.isEmpty(vol_list)) {
        // return "";
        // }
        //
        // BitcoinBalancesOnExchangesResponse dto = vol_list.get(0);
        //
        // String msg = "BTC 24h: " + dto.getChange_24h() + "btc(" +
        // dto.getChange_24h_val_million() + "m$)"
        // + Utils.new_line_from_service;
        //
        // msg += " 07d: " + dto.getChange_7d() + "btc(" +
        // dto.getChange_7d_val_million() + "m$)";
        //
        // return msg;
        //
        // } catch (Exception e) {
        // his.setNote(e.getMessage());
        // System.out.println("Error monitorBitcoinBalancesOnExchanges ---->" +
        // e.getMessage());
        // }
        // fundingHistoryRepository.save(his);
        // } catch (Exception e) {
        // }

        return "";
    }

    @Override
    public String getBtcBalancesOnExchanges() {
        return "";
        // int HH = Utils.getCurrentHH();
        // if (HH != pre_monitorBitcoinBalancesOnExchanges_HH) {
        // monitorBitcoinBalancesOnExchanges_temp = monitorBitcoinBalancesOnExchanges();
        // pre_monitorBitcoinBalancesOnExchanges_HH = HH;
        // return monitorBitcoinBalancesOnExchanges_temp;
        // } else {
        // return monitorBitcoinBalancesOnExchanges_temp;
        // }
    }

    @Override
    public List<EntryCssResponse> findAllScalpingToday() {
        List<EntryCssResponse> results = new ArrayList<EntryCssResponse>();
        try {
            // List<FundingHistory> list = fundingHistoryRepository.findAllByPumpdump(true);
            results.add(new EntryCssResponse());

            for (int loop = 0; loop < 2; loop++) {
                List<FundingHistory> list;
                if (loop == 0) {
                    list = fundingHistoryRepository.findAllFiboLong();

                } else {
                    list = fundingHistoryRepository.findAllFiboShort();
                }

                int count = list.size();
                int MAX_LENGTH = 9;
                if (count > MAX_LENGTH) {
                    count = MAX_LENGTH;
                }
                if (!CollectionUtils.isEmpty(list)) {
                    String symbols = "";
                    for (int index = 0; index < count; index++) {
                        FundingHistory entity = list.get(index);

                        if (symbols.contains(entity.getSymbol())) {
                            continue;
                        }
                        EntryCssResponse dto = new EntryCssResponse();
                        dto.setSymbol(entity.getSymbol());
                        dto.setTradingview(
                                "https://www.binance.com/en/futures/" + entity.getSymbol().toUpperCase() + "USDT");
                        symbols += entity.getSymbol() + ",";
                        results.add(dto);
                    }

                    if (list.size() > MAX_LENGTH) {
                        EntryCssResponse dto = new EntryCssResponse();
                        dto.setSymbol(".........");
                        dto.setFutures_msg("http://localhost:8090/BTC");
                        dto.setTradingview("https://vn.tradingview.com/chart/?symbol=BINANCE%3ABTCUSDTPERP");
                        results.add(dto);
                    } else {
                        for (int j = list.size(); j <= MAX_LENGTH; j++) {
                            results.add(new EntryCssResponse());
                        }
                    }
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }

        return results;
    }

    // https://www.binance.com/en-GB/futures/funding-history/3
    @SuppressWarnings("unused")
    private void monitorBtcFundingRate(Boolean isUpCandle) {
        try {
            FundingResponse rate = Utils.loadFundingRate("BTC");
            BigDecimal high = rate.getHigh();
            BigDecimal low = rate.getLow();

            String msg = "";
            if (isUpCandle) {
                if (high.compareTo(BigDecimal.valueOf(0.5)) > 0) {

                    msg = " 💔💔 (DANGER DANGER) CZ kill SHORT!!!";

                } else if (high.compareTo(BigDecimal.valueOf(0.2)) > 0) {

                    msg = " 💔 (DANGER) CZ kill SHORT !!! Wait 10~15 minutes.";

                }
            } else {
                if (low.compareTo(BigDecimal.valueOf(-1)) < 0) {

                    msg = " 💔💔💔 (DANGER DANGER DANGER) CZ kill LONG !!!";

                } else if (low.compareTo(BigDecimal.valueOf(-0.5)) < 0) {

                    msg = " 💔💔 (DANGER DANGER) CZ kill LONG !!!";

                } else if (low.compareTo(BigDecimal.valueOf(-0.2)) < 0) {

                    msg = " 💔 (DANGER) CZ kill LONG !!!";
                }
            }

            // -----------------------------------------------------------------------------------------//

            if (Utils.isNotBlank(msg)) {
                String EVENT_ID = EVENT_DANGER_CZ_KILL_LONG + "_" + Utils.getCurrentYyyyMmDd_Blog2h();

                if (!fundingHistoryRepository.existsPumDump("bitcoin", EVENT_ID)) {

                    fundingHistoryRepository.save(createPumpDumpEntity(EVENT_ID, "bitcoin", "BTC",
                            Utils.getToday_YyyyMMdd() + " Long/Short", true));

                    if (Utils.isNotBlank(msg)) {
                        Utils.sendToTelegram(msg + Utils.new_line_from_service + Utils.new_line_from_service
                                + wallToday() + Utils.new_line_from_service + Utils.new_line_from_service
                                + getBitfinexLongShortBtc());
                    }
                }
            }

        } catch (

        Exception e) {
            e.printStackTrace();
        }
    }

    @Override
    @Transactional
    public String wallToday() {
        String key = Utils.getYyyyMmDdHH_ChangeDailyChart();

        BigDecimal WALL_3 = BigDecimal.valueOf(4);

        BigDecimal max_bid = BigDecimal.ZERO;
        BigDecimal max_ask = BigDecimal.ZERO;

        BigDecimal low = BigDecimal.ZERO;
        BigDecimal high = BigDecimal.ZERO;

        for (DepthResponse dto : list_bids_ok) {
            if (!Objects.equals("BTC", dto.getSymbol())) {
                continue;
            }

            if ((dto.getVal_million_dolas().compareTo(max_bid) > 0)
                    && (dto.getVal_million_dolas().compareTo(WALL_3) >= 0)) {
                max_bid = dto.getVal_million_dolas();
                low = dto.getPrice();
            }
        }

        for (DepthResponse dto : list_asks_ok) {
            if (!Objects.equals("BTC", dto.getSymbol())) {
                continue;
            }

            if ((dto.getVal_million_dolas().compareTo(max_ask) > 0)
                    && (dto.getVal_million_dolas().compareTo(WALL_3) >= 0)) {
                max_ask = dto.getVal_million_dolas();
                high = dto.getPrice();
            }
        }

        String EVENT_ID = EVENT_BTC_RANGE + "_" + key;
        FundingHistoryKey id = new FundingHistoryKey();
        id.setEventTime(EVENT_ID);
        id.setGeckoid("bitcoin");

        String note = low + "~" + high;
        if (!fundingHistoryRepository.existsPumDump("bitcoin", EVENT_ID)) {
            FundingHistory coin = new FundingHistory();
            coin.setId(id);
            coin.setSymbol("BTC");
            coin.setNote(note);
            coin.setPumpdump(true);

            coin.setLow(low);
            coin.setHigh(high);

            coin.setAvgLow(max_bid);
            coin.setAvgHigh(max_ask);

            fundingHistoryRepository.save(coin);
        } else {
            FundingHistory coin = fundingHistoryRepository.findById(id).orElse(null);
            if (!Objects.equals(null, coin)) {

                boolean hasChangeValue = false;

                if (low.compareTo(Utils.getBigDecimal(BigDecimal.ZERO)) > 0) {
                    if (low.compareTo(Utils.getBigDecimal(coin.getLow())) < 0) {
                        coin.setNote(note);
                        coin.setLow(low);
                        coin.setAvgLow(max_bid);
                        hasChangeValue = true;
                    }
                }

                if ((Utils.getBigDecimal(coin.getLow()).compareTo(BigDecimal.ZERO) < 1)
                        || (Utils.getBigDecimal(coin.getAvgLow()).compareTo(BigDecimal.ZERO) < 1)) {
                    coin.setNote(note);
                    coin.setLow(low);
                    coin.setAvgLow(max_bid);
                    hasChangeValue = true;
                }

                // ------------------------------

                if (high.compareTo(Utils.getBigDecimal(BigDecimal.ZERO)) > 0) {
                    if (high.compareTo(Utils.getBigDecimal(coin.getHigh())) > 0) {
                        coin.setNote(note);
                        coin.setHigh(high);
                        coin.setAvgHigh(max_ask);
                        hasChangeValue = true;
                    }
                }

                if ((Utils.getBigDecimal(coin.getHigh()).compareTo(BigDecimal.ZERO) < 1)
                        || (Utils.getBigDecimal(coin.getAvgHigh()).compareTo(BigDecimal.ZERO) < 1)) {
                    coin.setNote(note);
                    coin.setHigh(high);
                    coin.setAvgHigh(max_ask);
                    hasChangeValue = true;
                }

                // ------------------------------

                if (hasChangeValue) {
                    fundingHistoryRepository.save(coin);
                }

                low = coin.getLow();
                high = coin.getHigh();
            }
        }

        String result = Utils.createMsgLowHeight(Utils.getBinancePrice("BTC"), low, high);
        result = result.replace("L:", "Wall: ").replace("-H:", " ~ ").replace("$", "");

        return result;
    }
    // clearTrash

    @Override
    @Transactional
    public String getChartWD(String gecko_id, String symbol) {
        String result = symbol.toUpperCase() + " " + checkWDtrend(gecko_id, symbol.toUpperCase());

        return result;
    }

    @SuppressWarnings("unused")
    private String sendMsgMonitorFibo(String gecko_id, String symbol, List<BtcFutures> list, String only_trend,
            int maIndex, boolean showDetail) {
        String msg = Utils.getMmDD_TimeHHmm() + symbol + ",";

        String result = Utils.checkMa3AndX(list, maIndex, showDetail, only_trend);

        if (result.contains(Utils.TREND_DANGER)) {
            return result;
        }

        if (Utils.isNotBlank(result)) {

            msg = (msg + result).replace(",", Utils.new_line_from_service);
            // msg += Utils.new_line_from_service + "Currency:" + TREND_CURRENCY_TODAY;

            String EVENT_LONG_SHORT = EVENT_FIBO_LONG_SHORT + symbol + "_" + Utils.getCurrentYyyyMmDd_Blog2h();

            if (!fundingHistoryRepository.existsPumDump(gecko_id, EVENT_LONG_SHORT)) {
                fundingHistoryRepository.save(createPumpDumpEntity(EVENT_LONG_SHORT, gecko_id, symbol, "", true));

                Utils.sendToMyTelegram(msg.replace(" ", ""));

            }
        }

        return result;
    }

    private void sendMsgPerHour(String EVENT_ID, String msg_content, boolean isOnlyMe) {
        String msg = Utils.getTimeHHmm();
        msg += msg_content;
        msg = msg.replace(" ", "").replace(",", ", ");

        if (!fundingHistoryRepository.existsPumDump(EVENT_MSG_PER_HOUR, EVENT_ID)) {

            fundingHistoryRepository
                    .save(createPumpDumpEntity(EVENT_ID, EVENT_MSG_PER_HOUR, EVENT_MSG_PER_HOUR, "", false));

            if (isOnlyMe) {
                Utils.sendToMyTelegram(msg);
            } else {
                Utils.sendToTelegram(msg);
            }
        }
    }

    private String sendMsgKillLongShort(String gecko_id, String symbol, List<BtcFutures> list_15m, String append) {
        String msg = "";
        String chartname = Utils.getChartName(list_15m);
        BtcFutures ido = list_15m.get(0);
        boolean isShort = Utils.isAboveMALine(list_15m, 50, 0);

        String atl = Utils.new_line_from_service + Utils.getAtlAth(list_15m);

        if (Utils.isNotBlank(append)) {
            atl += Utils.new_line_from_service + append;
        }

        if (ido.isBtcKillLongCandle()) {
            msg = Utils.getTimeHHmm() + " 🔻  " + symbol + " " + chartname + " kill "
                    + (!isShort ? "LONG 💔 !!! " : "Long 💔 ");
        }

        if (ido.isBtcKillShortCandle()) {
            msg = Utils.getTimeHHmm() + " 💹 " + symbol + " " + chartname + " kill "
                    + (!isShort ? "SHORT 💔  !!!" : "Short 💔 ");
        }

        if (Utils.isNotBlank(msg)) {
            msg += Utils.removeLastZero(ido.getCurrPrice()) + atl;

            String EVENT_ID5 = EVENT_DANGER_CZ_KILL_LONG + "_" + ido.getId() + "_"
                    + list_15m.get(1).getPrice_close_candle();// Utils.getCurrentYyyyMmDd_Blog2h();

            if (!fundingHistoryRepository.existsPumDump(gecko_id, EVENT_ID5)) {
                fundingHistoryRepository.save(createPumpDumpEntity(EVENT_ID5, gecko_id, symbol, msg, true));

                Utils.sendToTelegram(msg);
            }
        }

        return msg;
    }

    private String sendMsgByTrendMaX(String symbol, List<BtcFutures> list, int maIndex, String find_trend,
            String append) {

        if (!Utils.isAllowSendMsgSetting()) {
            return "SettingSendMsg";
        }

        String msg = "";
        String current_trend = "";
        String chartname = Utils.getChartName(list);
        String EVENT_ID = EVENT_PUMP + symbol + "_" + chartname + Utils.getCurrentYyyyMmDdHHByChart(list);

        current_trend = Utils.switchStrategy(list, maIndex);
        if (Utils.isNotBlank(find_trend)) {
            if (!Objects.equals(current_trend, find_trend)) {
                return "";
            }
        }

        BigDecimal price_now = list.get(0).getCurrPrice();

        if (Objects.equals(Utils.TREND_LONG, current_trend)) {

            msg = " 💹. " + symbol + chartname + ":3Up" + maIndex
                    + (list.get(0).getId().contains("_3m_") ? " 🚀" : " 🚀");
            EVENT_ID += "_UP";

        } else if (Objects.equals(Utils.TREND_SHORT, current_trend)) {

            msg = " 📉. " + symbol + chartname + ":3Down" + maIndex
                    + (list.get(0).getId().contains("_3m_") ? " 🥶" : " 🥶");
            EVENT_ID += "_DOWN";

        } else if (Objects.equals("BTC", symbol) && Utils.isStopLong(list)) {
            msg = Utils.TREND_STOP_LONG;
        }

        if (Utils.isNotBlank(msg)) {
            String curr_price = "(" + Utils.removeLastZero(price_now) + ")";

            if (Objects.equals(msg, Utils.TREND_STOP_LONG)) {
                msg = "(" + Utils.TREND_STOP_LONG + ")" + chartname + symbol + curr_price;
            } else {
                msg += curr_price;
                msg += Utils.isNotBlank(append) ? Utils.new_line_from_service + append : "";
            }
            msg += Utils.new_line_from_service + Utils.getAtlAth(list);

            sendMsgPerHour(EVENT_ID, msg, true);
        }

        return msg;
    }

    private void sendScapMsgLongShort(List<BtcFutures> list, String symbol) {
        if (!Objects.equals("BTC", symbol)) {
            return;
        }
        if (Objects.equals(Utils.TREND_OPPOSITE, BTC_H1_TRENDING)) {
            return;
        }

        String trend = "";
        trend += Utils.checkTrendByIndex(list, 3, 10, "");
        trend += Utils.checkTrendByIndex(list, 3, 20, "");
        trend += Utils.checkTrendByIndex(list, 3, 50, "");

        if (Utils.isNotBlank(trend)) {
            String msg = trend + Utils.getChartName(list) + symbol + "("
                    + Utils.removeLastZero(list.get(0).getCurrPrice()) + ")";

            msg += Utils.new_line_from_service
                    + Utils.calcSL_TP_5m(list, trend.contains("Up") ? Utils.TREND_LONG : Utils.TREND_SHORT);

            msg += "(H4.H1):" + BTC_H1_TRENDING;

            String EVENT_ID_BTC = EVENT_PUMP + trend + symbol + Utils.getCurrentYyyyMmDdHHByChart(list);
            sendMsgPerHour(EVENT_ID_BTC, msg, true);
        }
    }

    @Override
    public void sendMsgChart1m(String gecko_id, String symbol) {
        if (Objects.equals("BTC", symbol)) {

            List<BtcFutures> list = Utils.loadData(symbol, TIME_1m, 50);

            sendScapMsgLongShort(list, symbol);
        }
    }

    @Override
    public void sendMsgChart5m(String gecko_id, String symbol) {
        if (Objects.equals("BTC", symbol)) {

            List<BtcFutures> list = Utils.loadData(symbol, TIME_5m, 50);

            sendScapMsgLongShort(list, symbol);
        }
    }

    @Override
    public void sendMsgChart15m(String gecko_id, String symbol, String append) {

        if ("_BTC_ETH_BNB_".contains("_" + symbol + "_")) {
            List<BtcFutures> list_15m = Utils.loadData(symbol, TIME_15m, 50);
            sendMsgKillLongShort(gecko_id, symbol, list_15m, append);
            if (Objects.equals("BTC", symbol)) {
                sendScapMsgLongShort(list_15m, symbol);
            }
        }

        String EVENT_DHH_LONG = EVENT_D_H4_H1 + symbol + "_" + Utils.CHAR_LONG + Utils.CHAR_LONG + Utils.CHAR_LONG;
        FundingHistoryKey id = new FundingHistoryKey();
        id.setGeckoid(gecko_id);
        id.setEventTime(EVENT_DHH_LONG);
        FundingHistory entity = fundingHistoryRepository.findById(id).orElse(null);
        if (!Objects.equals(null, entity)) {
            String supper_trend = Utils.CHAR_MONEY + Utils.CHAR_MONEY + Utils.CHAR_MONEY;
            supper_trend += "SUPPER_LONG" + Utils.CHAR_MONEY + Utils.CHAR_MONEY + Utils.CHAR_MONEY;

            checkTrendByBtc(gecko_id, symbol, TIME_15m, BigDecimal.ZERO, true, supper_trend, false, Utils.TREND_LONG);
        }

        if (Objects.equals("BTC", symbol)) {
            String EVENT_DHH_SHORT = EVENT_D_H4_H1 + symbol + "_" + Utils.CHAR_SHORT + Utils.CHAR_SHORT
                    + Utils.CHAR_SHORT;

            id = new FundingHistoryKey();
            id.setGeckoid(gecko_id);
            id.setEventTime(EVENT_DHH_SHORT);
            entity = fundingHistoryRepository.findById(id).orElse(null);
            if (!Objects.equals(null, entity)) {
                String supper_trend = Utils.CHAR_MONEY + Utils.CHAR_MONEY + Utils.CHAR_MONEY;
                supper_trend += "SUPPER_SHORT" + Utils.CHAR_MONEY + Utils.CHAR_MONEY + Utils.CHAR_MONEY;

                checkTrendByBtc(gecko_id, symbol, TIME_15m, BigDecimal.ZERO, true, supper_trend, false,
                        Utils.TREND_SHORT);
            }
        }
    }

    public String checkTrendByBtc(String gecko_id, String symbol, String TIME, BigDecimal ref_price,
            boolean allowSendMsg, String append, boolean isCompareWithBtc, String find_trend) {
        String trend = "";
        String CURRENCY = isCompareWithBtc ? "BTC" : "USDT";
        List<BtcFutures> list_compare_btc = Utils.loadData(symbol, TIME, 50, CURRENCY);
        BigDecimal current_price = isCompareWithBtc ? ref_price : list_compare_btc.get(0).getCurrPrice();

        if (!CollectionUtils.isEmpty(list_compare_btc)) {
            trend += Utils.checkTrendByIndex(list_compare_btc, 3, 10, Utils.TREND_LONG);
            trend += Utils.checkTrendByIndex(list_compare_btc, 3, 20, Utils.TREND_LONG);
            trend += Utils.checkTrendByIndex(list_compare_btc, 3, 50, Utils.TREND_LONG);

            if (allowSendMsg && Utils.isNotBlank(trend)) {

                if (Utils.isNotBlank(find_trend)) {
                    String find = Objects.equals(Utils.TREND_LONG, find_trend) ? Utils.TREND_LONG_UP
                            : Utils.TREND_SHORT_DN;

                    if (!trend.contains(find)) {
                        return "";
                    }
                }

                String chartname = Utils.getChartName(list_compare_btc);

                saveDepthData(gecko_id, symbol);
                list_bids_ok = getBids(gecko_id, current_price);
                list_asks_ok = getAsks(gecko_id, current_price);
                String bid_ask = "";
                if (!CollectionUtils.isEmpty(list_bids_ok)) {
                    DepthResponse dto_min = list_bids_ok.get(list_bids_ok.size() - 1);
                    bid_ask += "(bid)" + Utils.removeLastZero(dto_min.getPrice()) + "(" + dto_min.getPercent() + ")";
                }
                if (!CollectionUtils.isEmpty(list_asks_ok)) {
                    DepthResponse dto_max = list_asks_ok.get(list_asks_ok.size() - 1);
                    bid_ask += "(ask)" + Utils.removeLastZero(dto_max.getPrice()) + "(" + dto_max.getPercent() + ")";
                }

                String str_current_price = "(" + Utils.removeLastZero(current_price) + ")";
                String msg = chartname + trend + symbol + ".vs.BTC." + str_current_price + append;

                if (Utils.isNotBlank(bid_ask)) {
                    msg += Utils.new_line_from_service + bid_ask;
                }

                String EVENT_ID_COMPARE_BTC = EVENT_PUMP + symbol + Utils.getCurrentYyyyMmDdHHByChart(list_compare_btc);

                sendMsgPerHour(EVENT_ID_COMPARE_BTC, msg, true);

                return msg;
            }
        }

        return trend;
    }

    // AUD_EUR_GBP_USDT
    @Override
    public void checkCurrency() {
        try {
            if (!Utils.isAllowSendMsgSetting()) {
                // return;
            }

            if (!Utils.isBusinessTime()) {
                return;
            }

            int dow = Calendar.getInstance().get(Calendar.DAY_OF_WEEK);
            boolean isWeekend = ((dow < Calendar.MONDAY) || (dow > Calendar.FRIDAY));
            if (isWeekend) {
                return;
            }

            List<BtcFutures> list_AUD = Utils.loadData("AUD", TIME_1h, 50);
            List<BtcFutures> list_EUR = Utils.loadData("EUR", TIME_1h, 50);
            List<BtcFutures> list_GBP = Utils.loadData("GBP", TIME_1h, 50);

            int maFast = 3;
            String chartname = Utils.getChartName(list_AUD);

            String AUD_TREND = "";
            AUD_TREND += Utils.checkTrendByIndex(list_AUD, maFast, 10, "");
            AUD_TREND += Utils.checkTrendByIndex(list_AUD, maFast, 20, "");
            AUD_TREND += Utils.checkTrendByIndex(list_AUD, maFast, 50, "");
            if (Utils.isNotBlank(AUD_TREND)) {
                String msg = chartname + AUD_TREND + " AUD_USDT";

                String EVENT_ID = EVENT_PUMP + "AUD_USDT_" + chartname + Utils.getCurrentYyyyMmDdHHByChart(list_AUD);
                sendMsgPerHour(EVENT_ID, msg, true);
            }

            String EUR_TREND = "";
            EUR_TREND += Utils.checkTrendByIndex(list_EUR, maFast, 10, "");
            EUR_TREND += Utils.checkTrendByIndex(list_EUR, maFast, 20, "");
            EUR_TREND += Utils.checkTrendByIndex(list_EUR, maFast, 50, "");
            if (Utils.isNotBlank(EUR_TREND)) {
                String msg = chartname + EUR_TREND + " EUR_USDT";

                String EVENT_ID = EVENT_PUMP + "EUR_USDT_" + chartname + Utils.getCurrentYyyyMmDdHHByChart(list_EUR);
                sendMsgPerHour(EVENT_ID, msg, true);
            }

            String GBP_TREND = "";
            GBP_TREND += Utils.checkTrendByIndex(list_GBP, maFast, 10, "");
            GBP_TREND += Utils.checkTrendByIndex(list_GBP, maFast, 20, "");
            GBP_TREND += Utils.checkTrendByIndex(list_GBP, maFast, 50, "");
            if (Utils.isNotBlank(GBP_TREND)) {
                String msg = chartname + GBP_TREND + " GBP_USDT";

                String EVENT_ID = EVENT_PUMP + "GBP_USDT_" + chartname + Utils.getCurrentYyyyMmDdHHByChart(list_GBP);
                sendMsgPerHour(EVENT_ID, msg, true);
            }

            boolean IsUpAUD_S = Utils.isUptrendByMaIndex(list_AUD, 50);
            boolean IsUpEUR_S = Utils.isUptrendByMaIndex(list_EUR, 50);
            boolean IsUpGBP_S = Utils.isUptrendByMaIndex(list_GBP, 50);

            int count_usd_uptrend = 3;
            count_usd_uptrend -= IsUpAUD_S ? 1 : 0;
            count_usd_uptrend -= IsUpEUR_S ? 1 : 0;
            count_usd_uptrend -= IsUpGBP_S ? 1 : 0;
            usd_is_uptrend_today = (count_usd_uptrend > 1) ? true : false;
            if (usd_is_uptrend_today) {
                TREND_CURRENCY_TODAY = Utils.TREND_SHORT;
            } else {
                TREND_CURRENCY_TODAY = Utils.TREND_LONG;
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    @Transactional
    public String checkWDtrend(String gecko_id, String symbol) {
        String EVENT_ID = EVENT_TREND_1W1D + "_" + symbol;

        List<BtcFutures> list_weeks = Utils.loadData(symbol, TIME_1w, 10);
        if (CollectionUtils.isEmpty(list_weeks)) {
            return "";
        }
        List<BtcFutures> list_days = Utils.loadData(symbol, TIME_1d, 30);
        if (CollectionUtils.isEmpty(list_days)) {
            return "";
        }
        List<BtcFutures> list_h4 = Utils.loadData(symbol, TIME_4h, 60);
        if (CollectionUtils.isEmpty(list_h4)) {
            return "";
        }
        List<BtcFutures> list_h1 = Utils.loadData(symbol, TIME_1h, 60);
        if (CollectionUtils.isEmpty(list_h1)) {
            return "";
        }

        BigDecimal current_price = list_days.get(0).getCurrPrice();

        if (Objects.equals("BTC", symbol)) {
            boolean trend_h4 = Utils.isUptrendByMaIndex(list_h4, 6);
            boolean trend_h1 = Utils.isUptrendByMaIndex(list_h1, 6);
            if (trend_h4 == trend_h1) {
                BTC_H1_TRENDING = trend_h4 ? Utils.TREND_LONG : Utils.TREND_SHORT;
            } else {
                BTC_H1_TRENDING = Utils.TREND_OPPOSITE;
            }

            RANGE_BTC_IS_DANGER = Utils.isDangerRange(list_days);
        }

        // -------------------------------------------------------------------------
        String taker = "";
        String vol_h1 = Utils.analysisTakerVolume(list_h1, 50);
        String vol_h4 = Utils.analysisTakerVolume(list_h4, 50);
        String vol_d1 = Utils.analysisTakerVolume(list_days, 30);
        if (Utils.isNotBlank(vol_h1 + vol_h4 + vol_d1)) {
            taker += "Taker:";
            taker += Utils.isNotBlank(vol_h1) ? " (H1)" + vol_h1 : "";
            taker += Utils.isNotBlank(vol_h4) ? " (H4)" + vol_h4 : "";
            taker += Utils.isNotBlank(vol_d1) ? " (D)" + vol_d1 : "";
        }
        // -------------------------------------------------------------------------
        Boolean allow_long_d1 = Utils.checkClosePriceAndMa_StartFindLong(list_days);

        String type = "";
        if (binanceFuturesRepository.existsById(gecko_id)) {
            type = " (Futures) ";

            if ("_BTC_ETH_BNB_".contains("_" + symbol + "_")) {

                sendMsgChart15m(gecko_id, symbol, Utils.getAtlAth(list_h1));

                sendMsgByTrendMaX(symbol, list_h1, 50, "", taker); // H4

                sendMsgByTrendMaX(symbol, list_days, 10, "",
                        taker + Utils.new_line_from_service + "DDDDDDDDDDDDDDDDDDDDDDD"); // D

                sendMsgByTrendMaX(symbol, list_days, 50, "",
                        taker + Utils.new_line_from_service + "WWWWWWWWWWWWWWWWWWWWWWW"); // W
            } else {
                if (!RANGE_BTC_IS_DANGER) {
                    if (Utils.isNotBlank(taker)) {
                        sendMsgByTrendMaX(symbol, list_h4, 50, Utils.TREND_LONG,
                                taker + Utils.new_line_from_service + "H4H4H4H4H4H4H4H4H4H4H4"); // D
                    }

                    sendMsgByTrendMaX(symbol, list_days, 10, Utils.TREND_LONG,
                            taker + Utils.new_line_from_service + "DDDDDDDDDDDDDDDDDDDDDDD");// D

                    sendMsgByTrendMaX(symbol, list_days, 50, Utils.TREND_LONG,
                            taker + Utils.new_line_from_service + "WWWWWWWWWWWWWWWWWWWWWWW");// W
                }
            }
        } else {
            type = " (Spot) ";

            if (!RANGE_BTC_IS_DANGER) {
                if (Utils.isNotBlank(taker)) {
                    sendMsgByTrendMaX(symbol, list_h4, 50, Utils.TREND_LONG,
                            taker + Utils.new_line_from_service + "H4H4H4H4(Spot)H4H4H4H4"); // D
                }
            }

            sendMsgByTrendMaX(symbol, list_days, 10, Utils.TREND_LONG,
                    taker + Utils.new_line_from_service + "DDDDDDD(Spot)DDDDDDD"); // D

            sendMsgByTrendMaX(symbol, list_days, 50, Utils.TREND_LONG,
                    taker + Utils.new_line_from_service + "WWWWWWW(Spot)WWWWWWW"); // W

        }
        type = type + Utils.analysisVolume(list_days);

        String scapLongH4 = Utils.getScapLong(list_h4, list_days, 10, allow_long_d1);
        String scapLongD1 = Utils.getScapLong(list_days, list_days, 10, allow_long_d1);

        String checkMa3AndX = "";

        CandidateCoin entity = candidateCoinRepository.findById(gecko_id).orElse(null);
        if (!Objects.equals(null, entity)) {
            entity.setCurrentPrice(current_price);
            candidateCoinRepository.save(entity);
        }

        List<BigDecimal> min_max_week = Utils.getLowHeightCandle(list_weeks);
        BigDecimal min_week = Utils.formatPrice(min_max_week.get(0).multiply(BigDecimal.valueOf(0.99)), 5);
        BigDecimal max_week = min_max_week.get(1);

        List<BigDecimal> min_max_day = Utils
                .getLowHeightCandle(list_days.subList(0, list_days.size() > 10 ? 10 : list_days.size()));
        BigDecimal min_days = min_max_day.get(0);
        BigDecimal max_days = min_max_day.get(1);

        String W1 = list_weeks.get(0).isUptrend() ? "W↑" : "W↓";
        String D1 = list_days.get(0).isUptrend() ? "D↑" : "D↓";

        String note = W1 + D1;
        note += ",L10d:" + Utils.getPercentToEntry(current_price, min_days, true);
        note += ",H10d:" + Utils.getPercentToEntry(current_price, max_days, false);
        note += ",L10w:" + Utils.getPercentToEntry(current_price, min_week, true) + ",";
        // ---------------------------------------------------------
        String position = "";
        if (Objects.equals(Utils.TREND_LONG, Utils.check3CuttingXforH1(list_h4, Utils.MA_INDEX_H4_START_LONG))) {
            position = "_PositionH4";
        }
        if (Objects.equals(Utils.TREND_LONG, Utils.check3CuttingXforH1(list_days, Utils.MA_INDEX_D1_START_LONG))) {
            position = "_PositionD1";

            PriorityCoinHistory his = new PriorityCoinHistory();
            his.setGeckoid(gecko_id);
            his.setSymbol(Utils.getMmDD_TimeHHmm());
            String history = scapLongD1.replace(" ", "");
            if (history.length() > 255) {
                history = history.substring(0, 250) + "...";
            }
            his.setName(history);

            priorityCoinHistoryRepository.save(his);
        }
        if (scapLongD1.contains(Utils.TREND_DANGER) || scapLongH4.contains(Utils.TREND_DANGER)) {
            // position = "";
        }
        // ---------------------------------------------------------
        // EVENT_D_H4_H1
        {
            String chart_d = Utils.initLongShort(list_days);
            String chart_h4 = Utils.initLongShort(list_h4);
            String chart_h1 = Utils.initLongShort(list_h1);
            String DH4H1 = chart_d + chart_h4 + chart_h1;
            String EVENT_DHH = EVENT_D_H4_H1 + symbol;
            FundingHistoryKey id = new FundingHistoryKey(EVENT_DHH, gecko_id);
            if (!fundingHistoryRepository.existsById(id) || !Objects.equals(Utils.CHAR_NORMAL, chart_d)) {
                fundingHistoryRepository.save(createPumpDumpEntity(EVENT_DHH, gecko_id, symbol, DH4H1, true));
            }
            if (!Objects.equals(Utils.CHAR_NORMAL, chart_h4)) {
                FundingHistory entity_dhh = fundingHistoryRepository.findById(id).orElse(null);
                if (!Objects.equals(null, entity_dhh)) {
                    String DHH = entity_dhh.getNote();
                    String d = DHH.substring(0, 1);
                    if (!Objects.equals(Utils.CHAR_NORMAL, d) && Objects.equals(d, chart_h4)) {
                        DHH = DHH.substring(0, 1) + chart_h4 + DHH.substring(2, 3);
                        fundingHistoryRepository.save(createPumpDumpEntity(EVENT_DHH, gecko_id, symbol, DHH, true));
                    }
                }
            }
            if (!Objects.equals(Utils.CHAR_NORMAL, chart_h1)) {
                FundingHistory entity_dhh = fundingHistoryRepository.findById(id).orElse(null);
                if (!Objects.equals(null, entity_dhh)) {
                    String DHH = entity_dhh.getNote();
                    String d = DHH.substring(0, 1);
                    String h4 = DHH.substring(0, 1);
                    if (!Objects.equals(Utils.CHAR_NORMAL, d) && Objects.equals(d, h4) && Objects.equals(d, chart_h1)) {
                        DHH = DHH.substring(0, 2) + chart_h1;
                        fundingHistoryRepository.save(createPumpDumpEntity(EVENT_DHH, gecko_id, symbol, DHH, true));
                    }
                }
            }
        }

        // ---------------------------------------------------------
//        if (!Objects.equals("BTC", symbol) && !Utils.isDangerRange(list_h4)) {
//            if (Utils.isUptrendByMaIndex(list_h4, 6)) {
//                String trend_by_btc = checkTrendByBtc(gecko_id, symbol, TIME_4h, current_price, false, type, true,
//                        Utils.TREND_LONG);
//                if (Utils.isNotBlank(trend_by_btc)) {
//                    note += "_PositionBTC4h";
//                }
//
//                if (Utils.isUptrendByMaIndex(list_h1, 6)) {
//                    trend_by_btc = checkTrendByBtc(gecko_id, symbol, TIME_15m, current_price, true, type, true,
//                            Utils.TREND_LONG);
//                    if (Utils.isNotBlank(trend_by_btc)) {
//                        note += "_PositionBTC15m";
//                    }
//                }
//            }
//        }
        note += position;
        // ---------------------------------------------------------
        String mUpMa = "";
        String today = Utils.getToday_MMdd();
        mUpMa += allow_long_d1 ? "↑" + today + "(Up) " : " ";
        if (Utils.isNotBlank(mUpMa.trim())) {
            mUpMa = " move" + mUpMa.trim();
        }

        String mDownMa = "";
        mDownMa += !allow_long_d1 ? "↓" + today + "(Down) " : "";

        if (Utils.isNotBlank(mDownMa)) {
            if (Utils.isNotBlank(mUpMa)) {
                mDownMa = " " + mDownMa.trim();
            } else {
                mDownMa = "move" + mDownMa.trim();
            }
        }

        String m2ma = " m2ma{" + (mUpMa.trim() + " " + mDownMa.trim()).trim() + "}m2ma";

        // H4 sl2ma
        String sl2ma = "";
        if (Utils.isNotBlank(scapLongH4)) {
            scapLongH4 = scapLongH4.replace("_" + symbol.toUpperCase() + "_", "_");
            sl2ma = " sl2ma{" + scapLongH4 + "}sl2ma";
        }

        String ma7 = "";
        if (Utils.isNotBlank(scapLongD1)) {
            ma7 = "_ma7(" + scapLongD1.replace(",", " ") + ")~";
        }

        if (Utils.isNotBlank(taker)) {
            taker = " taker{" + taker + "}taker";
        }
        // ---------------------------------------------------------

        String result = note + type + m2ma + ma7 + sl2ma + taker;
        if (result.length() > 255) {
            // result = result.substring(0, 250) + "...";
        }
        fundingHistoryRepository.save(createPumpDumpEntity(EVENT_ID, gecko_id, symbol, result, true));
        // -------------------------------------------------------------

        result = Utils.getTimeHHmm() + " " + symbol.toUpperCase() + " " + Utils.removeLastZero(current_price) + m2ma
                + sl2ma;

        result += Utils.new_line_from_bot;
        result += W1 + D1 + Utils.new_line_from_bot;

        result += "L10d:" + Utils.getPercentToEntry(current_price, min_days, true);
        result += ", H10d:" + Utils.getPercentToEntry(current_price, max_days, false);

        result += Utils.new_line_from_bot;

        result += "L10w:" + Utils.getPercentToEntry(current_price, min_week, true);
        result += ", H10w:" + Utils.getPercentToEntry(current_price, max_week, false);
        result += checkMa3AndX.replace(",", Utils.new_line_from_bot);

        result = result.replaceAll("↑", "^").replaceAll("↓", "v");

        loadBinanceData(gecko_id, symbol, list_days, list_h1, result);

        return result;
    }

    @Override
    @Transactional
    public void clearTrash() {
        List<FundingHistory> list = fundingHistoryRepository.clearTrash();
        if (!CollectionUtils.isEmpty(list)) {
            fundingHistoryRepository.deleteAll(list);
        }
    }

}
