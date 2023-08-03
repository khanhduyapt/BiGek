package bsc_scan_binance.service.impl;

import java.io.BufferedReader;
import java.io.File;
import java.io.FileInputStream;
import java.io.FileWriter;
import java.io.IOException;
import java.io.InputStreamReader;
import java.io.Reader;
import java.math.BigDecimal;
import java.math.BigInteger;
import java.math.RoundingMode;
import java.nio.file.Files;
import java.nio.file.attribute.BasicFileAttributes;
import java.time.Duration;
import java.time.LocalDateTime;
import java.time.LocalTime;
import java.time.ZoneId;
import java.util.ArrayList;
import java.util.Arrays;
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
import bsc_scan_binance.entity.BtcFutures;
import bsc_scan_binance.entity.BtcVolumeDay;
import bsc_scan_binance.entity.CandidateCoin;
import bsc_scan_binance.entity.DepthAsks;
import bsc_scan_binance.entity.DepthBids;
import bsc_scan_binance.entity.FundingHistory;
import bsc_scan_binance.entity.FundingHistoryKey;
import bsc_scan_binance.entity.GeckoVolumeMonth;
import bsc_scan_binance.entity.GeckoVolumeMonthKey;
import bsc_scan_binance.entity.Mt5DataCandle;
import bsc_scan_binance.entity.Mt5DataCandleKey;
import bsc_scan_binance.entity.Mt5DataTrade;
import bsc_scan_binance.entity.Mt5OpenTrade;
import bsc_scan_binance.entity.Mt5OpenTradeEntity;
import bsc_scan_binance.entity.Orders;
import bsc_scan_binance.repository.BinanceFuturesRepository;
import bsc_scan_binance.repository.BinanceVolumeDateTimeRepository;
import bsc_scan_binance.repository.BinanceVolumnDayRepository;
import bsc_scan_binance.repository.BinanceVolumnWeekRepository;
import bsc_scan_binance.repository.BtcVolumeDayRepository;
import bsc_scan_binance.repository.CandidateCoinRepository;
import bsc_scan_binance.repository.DepthAsksRepository;
import bsc_scan_binance.repository.DepthBidsRepository;
import bsc_scan_binance.repository.FundingHistoryRepository;
import bsc_scan_binance.repository.GeckoVolumeMonthRepository;
import bsc_scan_binance.repository.Mt5DataCandleRepository;
import bsc_scan_binance.repository.Mt5OpenTradeRepository;
import bsc_scan_binance.repository.OrdersRepository;
import bsc_scan_binance.repository.PrepareOrdersRepository;
import bsc_scan_binance.response.BtcFuturesResponse;
import bsc_scan_binance.response.CandidateTokenCssResponse;
import bsc_scan_binance.response.CandidateTokenResponse;
import bsc_scan_binance.response.DepthResponse;
import bsc_scan_binance.response.EntryCssResponse;
import bsc_scan_binance.response.ForexHistoryResponse;
import bsc_scan_binance.service.BinanceService;
import bsc_scan_binance.utils.Utils;
import lombok.RequiredArgsConstructor;

@Service
@RequiredArgsConstructor
public class BinanceServiceImpl implements BinanceService {
    // ********************************************************************************
    private static Hashtable<String, LocalTime> keys_dict = new Hashtable<String, LocalTime>();
    private static List<String> CRYPTO_LIST_BUYING = new ArrayList<String>();
    private static List<String> CRYPTO_LIST_SELING = new ArrayList<String>();

    private static List<String> GLOBAL_LONG_LIST = new ArrayList<String>();
    private static List<String> GLOBAL_SHOT_LIST = new ArrayList<String>();

    private String str_long_suggest = "";
    private String str_shot_suggest = "";

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
    private Mt5OpenTradeRepository mt5OpenTradeRepository;

    @Autowired
    private OrdersRepository ordersRepository;

    @Autowired
    private BinanceFuturesRepository binanceFuturesRepository;

    @Autowired
    private DepthBidsRepository depthBidsRepository;

    @Autowired
    private DepthAsksRepository depthAsksRepository;

    @Autowired
    private CandidateCoinRepository candidateCoinRepository;

    @Autowired
    private FundingHistoryRepository fundingHistoryRepository;

    @Autowired
    private Mt5DataCandleRepository mt5DataCandleRepository;

    @Autowired
    private PrepareOrdersRepository prepareOrdersRepository;

    private String BTC_ETH_BNB = "_BTC_ETH_BNB_";
    private static final String EVENT_BTC_RANGE = "BTC_RANGE";

    private static final String EVENT_PUMP = "Pump_";
    private static final String SEPARATE_D1_AND_H1 = "1DH1";

    private static final String CSS_PRICE_WARNING = "bg-warning border border-warning rounded px-1";
    private static final String CSS_PRICE_SUCCESS = "border border-success rounded px-1";
    private static final String CSS_PRICE_DANGER = "border-bottom border-danger";
    private static final String CSS_PRICE_WHITE = "text-white bg-info rounded-lg px-1";
    private static final String CSS_MIN28_DAYS = "text-white rounded-lg bg-info px-1";

    private boolean required_update_bars_csv = false;
    @SuppressWarnings("unused")
    private String pre_monitorBtcPrice_mm = "";
    List<String> monitorBtcPrice_results = new ArrayList<String>();

    private String pre_Bitfinex_status = "";
    private String preSaveDepthData;

    List<DepthResponse> list_bids_ok = new ArrayList<DepthResponse>();
    List<DepthResponse> list_asks_ok = new ArrayList<DepthResponse>();

    private int pre_HH = 0;
    private String sp500 = "";

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
                    + "          left join funding_history his on  his.event_time like '%1W1D"
                    + "%' and his.pumpdump and his.gecko_id = can.gecko_id  \n"
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
                    // -----------------------------------------------------------------------------
                    // + " , (case when can.symbol = ( \n"
                    // + " SELECT DISTINCT ON (symbol) symbol FROM funding_history main \n"
                    // + " WHERE \n"
                    // + " note = 'Long' \n"
                    // + " and symbol = can.symbol \n"
                    // + " and symbol= (SELECT symbol FROM funding_history WHERE event_time =
                    // 'DH4H1_D_TREND_CRYPTO' and symbol = main.symbol) \n"
                    // + " and symbol= (SELECT symbol FROM funding_history WHERE event_time =
                    // 'DH4H1_STR_H4_CRYPTO' and symbol = main.symbol) \n"
                    // + " and symbol= (SELECT symbol FROM funding_history WHERE event_time =
                    // 'DH4H1_STR_15M_CRYPTO' and symbol = main.symbol) \n"
                    // + " and symbol= (SELECT symbol FROM funding_history WHERE event_time =
                    // 'DH4H1_STR_05M_CRYPTO' and symbol = main.symbol) \n"
                    // + ") then 1 else 0 end) DESC \n"
                    // -----------------------------------------------------------------------------
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

                if (futu.contains(Utils.TEXT_STOP_LONG) || futu.contains(Utils.TEXT_DANGER)) {
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

                String dot_symbol = "";
                char[] dot_arr = dto.getSymbol().toCharArray();
                for (char dot : dot_arr) {
                    if (Utils.isNotBlank(dot_symbol))
                        dot_symbol += ".";

                    dot_symbol += Utils.getStringValue(dot);
                }
                css.setDot_symbol(dot_symbol);

                BigDecimal price_now = Utils.getBigDecimal(dto.getPrice_now());
                BigDecimal mid_price = Utils.getMidPrice(dto.getPrice_can_buy(), dto.getPrice_can_sell());
                BigDecimal market_cap = Utils.getBigDecimal(dto.getMarket_cap());
                BigDecimal gecko_total_volume = Utils.getBigDecimal(dto.getGecko_total_volume());

                if (css.getName().toUpperCase().contains("FUTURES")) {
                    css.setTrading_view(Utils.getCryptoLink_Future(dto.getSymbol()));
                } else {
                    css.setTrading_view(Utils.getCryptoLink_Spot(dto.getSymbol()));
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

                    css.setToken_btc_link("https://tradingview.com/chart/?symbol=BINANCE%3A" + dto.getSymbol() + "BTC");
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
                            } else if (scap.contains(Utils.TREND_SHOT)) {
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

                            if (ma7.contains(Utils.TEXT_DANGER)) {
                                // css.setDt_range_css("text-danger");
                            }
                            if (ma7.contains(Utils.TEXT_STOP_LONG)) {
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

                                if (sl_e_tp[3].contains(Utils.TEXT_DANGER)) {
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
                            css.setRange_position_css(CSS_PRICE_WHITE);
                        }
                        if (futu.contains("_PositionD1")) {
                            futu = futu.replace("_PositionD1", "");

                            css.setRange_position("Long(D1)");
                            css.setRange_position_css(CSS_PRICE_WHITE);
                        }

                        if (futu.contains("_Position_DHM5")) {
                            css.setRange_position("Long(M5)");
                            css.setRange_position_css(CSS_PRICE_WHITE);
                        }

                        futu = futu.replace("_PositionBTC15m", "").replace("_PositionBTC4h", "")
                                .replace("_Position_DHM5", "");

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

                            if ((price_now.multiply(BigDecimal.valueOf(1.005)).compareTo(highest_price_today) > 0)) {

                                css.setBtc_warning_css("bg-danger rounded-lg");

                            }
                        }

                        css.setRange_wdh_css("");
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

            List<ForexHistoryResponse> list_fx = getForexSamePhaseList();
            for (ForexHistoryResponse dto : list_fx) {
                CandidateTokenCssResponse css = new CandidateTokenCssResponse();

                String name = dto.getSymbol_or_epic();
                if (BscScanBinanceApplication.forex_naming_dict.containsKey(dto.getSymbol_or_epic())) {
                    name = BscScanBinanceApplication.forex_naming_dict.get(dto.getSymbol_or_epic());
                }

                String trading_view = "https://tradingview.com/chart/?symbol=CAPITALCOM%3A" + dto.getSymbol_or_epic();
                css.setSymbol(dto.getSymbol_or_epic());
                css.setBinance_trade(trading_view);
                css.setTrading_view(trading_view);
                css.setToken_btc_link(trading_view);

                css.setName(name);

                // css.setPumping_history(name);
                String position = "(D):" + dto.getD() + ", (H4):" + dto.getH();
                position += (Utils.isNotBlank(dto.getM15()) ? ", (15m):" + dto.getM15() : "");
                position += (Utils.isNotBlank(dto.getM5()) ? ", (5m):" + dto.getM5() : "");
                css.setRange_position(position);

                boolean isSideway = true;
                if (Objects.equals(dto.getH(), dto.getH())
                        && (Objects.equals(dto.getH(), dto.getM15()) || Objects.equals(dto.getH(), dto.getM5()))) {
                    isSideway = false;
                }
                css.setOco_opportunity(dto.getSymbol_or_epic() + " : " + name);

                String note = Utils.getStringValue(dto.getNote());
                if (note.contains(Utils.new_line_from_service)) {
                    css.setRange_backer(note.substring(0, note.indexOf(Utils.new_line_from_service)));

                    css.setRange_total_w(note.substring(note.indexOf(Utils.new_line_from_service))
                            .replace(Utils.new_line_from_service, ""));
                } else {
                    css.setRange_backer(note);
                }

                if (isSideway) {
                    // css.setRange_position_css("text-danger");
                    css.setPumping_history_css("text-danger");
                } else {
                    css.setRange_position_css(CSS_PRICE_WHITE);
                }

                list.add(css);
                index += 1;
            }

            return list;

        } catch (Exception e) {
            e.printStackTrace();
            return new ArrayList<CandidateTokenCssResponse>();
        }
    }

    @Override
    public List<ForexHistoryResponse> getCryptoSamePhaseList() {
        try {
            Query query = entityManager.createNativeQuery(Utils.sql_CryptoHistoryResponse, "ForexHistoryResponse");

            @SuppressWarnings("unchecked")
            List<ForexHistoryResponse> results = query.getResultList();

            return results;
        } catch (Exception e) {
            e.printStackTrace();
        }

        return new ArrayList<ForexHistoryResponse>();
    }

    @Override
    public List<ForexHistoryResponse> getForexSamePhaseList() {
        try {
            Query query = entityManager.createNativeQuery(Utils.sql_ForexHistoryResponse, "ForexHistoryResponse");

            @SuppressWarnings("unchecked")
            List<ForexHistoryResponse> results = query.getResultList();

            return results;
        } catch (

        Exception e) {
            e.printStackTrace();
        }

        return new ArrayList<ForexHistoryResponse>();
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

    @Override
    public String loadPremarket() {
        String sp_500 = getPreMarket("https://markets.businessinsider.com/index/s&p_500");
        String sp500_future = getPreMarket("https://markets.businessinsider.com/futures/s&p-500-futures");

        String value = "";
        value = appendStringForBot(value, sp_500);
        value = appendStringForBot(value, sp500_future);

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
    public String initWebBinance(String gecko_id, String symbol, List<BtcFutures> list_days, List<BtcFutures> list_h1,
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
                            cur_Bitfinex_status = Utils.TREND_SHOT;
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
        return "";
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

    @SuppressWarnings("unused")
    private String getVolMc(String gecko_id) {
        CandidateCoin coinmarketcap = candidateCoinRepository.findById(gecko_id).orElse(null);
        if (Objects.equals(null, coinmarketcap)) {
            return Utils.appendSpace("", 15);
        }
        BigDecimal vol = Utils.getBigDecimal(coinmarketcap.getVolumnDivMarketcap()).multiply(BigDecimal.valueOf(100));

        return Utils.appendSpace(" Vol.Mc:" + Utils.removeLastZero(vol) + "%", 15);
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
                        dto.setTradingview("https://tradingview.com/chart/?symbol=BINANCE%3ABTCUSDTPERP");
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

    public void sendMsgPerHour_ToAll(String EVENT_ID, String msg_content) {
        String msg = BscScanBinanceApplication.hostname + Utils.getTimeHHmm();
        msg += msg_content;
        msg = msg.replace(" ", "").replace(",", ", ");

        if (!fundingHistoryRepository.existsPumDump(Utils.EVENT_ID_NO_DUPLICATES,
                Utils.EVENT_ID_NO_DUPLICATES + EVENT_ID)) {
            fundingHistoryRepository.save(createPumpDumpEntity(Utils.EVENT_ID_NO_DUPLICATES + EVENT_ID,
                    Utils.EVENT_ID_NO_DUPLICATES, Utils.EVENT_ID_NO_DUPLICATES, Utils.EVENT_ID_NO_DUPLICATES, true));

            Utils.sendToTelegram(msg);
        }
    }

    @Override
    public void sendMsgPerHour_OnlyMe(String EVENT_ID, String msg_content) {
        String msg = BscScanBinanceApplication.hostname + Utils.getTimeHHmm();
        msg += msg_content;
        msg = msg.replace(" ", "").replace(",", ", ");

        if (!fundingHistoryRepository.existsPumDump(Utils.EVENT_ID_NO_DUPLICATES,
                Utils.EVENT_ID_NO_DUPLICATES + EVENT_ID)) {
            fundingHistoryRepository.save(createPumpDumpEntity(Utils.EVENT_ID_NO_DUPLICATES + EVENT_ID,
                    Utils.EVENT_ID_NO_DUPLICATES, Utils.EVENT_ID_NO_DUPLICATES, Utils.EVENT_ID_NO_DUPLICATES, true));

            Utils.sendToMyTelegram(msg);
        }
    }

    public boolean isReloadAfter(long minutes, String epic) {
        LocalTime cur_time = LocalTime.now();
        String key = Utils.getStringValue(epic);

        boolean reload = false;
        if (keys_dict.containsKey(key)) {
            LocalTime pre_time = keys_dict.get(key);

            long elapsedMinutes = Duration.between(pre_time, cur_time).toMinutes();

            if (minutes <= elapsedMinutes) {
                keys_dict.put(key, cur_time);

                reload = true;
            }
        } else {
            keys_dict.put(key, cur_time);
            reload = true;
        }

        return reload;
    }

    @Override
    public void logMsgPerHour(String epic_id, String log, Integer MINUTES_OF_Xx) {
        if (isReloadAfter(MINUTES_OF_Xx, epic_id)) {
            Utils.logWritelnDraft(log);
        }
    }

    @SuppressWarnings("unused")
    private boolean isReloadPrepareOrderTrend(String EPIC, String CAPITAL_TIME_XXX) {
        long elapsedMinutes = Utils.MINUTES_OF_1D + 1;
        LocalDateTime date_time = LocalDateTime.now();

        String id = EPIC + "_" + CAPITAL_TIME_XXX;
        Orders entity = ordersRepository.findById(id).orElse(null);
        if (!Objects.equals(null, entity)) {
            String insert_time = Utils.getStringValue(entity.getInsertTime());
            if (Utils.isNotBlank(insert_time)) {
                LocalDateTime pre_time = LocalDateTime.parse(insert_time);
                elapsedMinutes = Duration.between(pre_time, date_time).toMinutes();
            }
        }

        long time = Utils.MINUTES_OF_1H;
        if (Objects.equals(CAPITAL_TIME_XXX, Utils.CAPITAL_TIME_D1)
                || Objects.equals(CAPITAL_TIME_XXX, Utils.CRYPTO_TIME_D1)) {
            time = Utils.MINUTES_OF_1D;
        } else if (Objects.equals(CAPITAL_TIME_XXX, Utils.CAPITAL_TIME_H12)
                || Objects.equals(CAPITAL_TIME_XXX, Utils.CRYPTO_TIME_H4)) {
            time = Utils.MINUTES_OF_4H;
        } else if (Objects.equals(CAPITAL_TIME_XXX, Utils.CRYPTO_TIME_15)) {
            time = 15;
        }

        if (time <= elapsedMinutes) {
            return true;
        }

        return false;
    }

    // --------------------------------------------------------------------------------------
    // --------------------------------------------------------------------------------------
    // --------------------------------------------------------------------------------------
    // --------------------------------------------------------------------------------------
    // --------------------------------------------------------------------------------------

    @Override
    @Transactional
    public void clearTrash() {
        List<FundingHistory> list = fundingHistoryRepository.clearTrash();
        if (!CollectionUtils.isEmpty(list)) {
            fundingHistoryRepository.deleteAll(list);
        }

        ordersRepository.deleteAll();

        mt5DataCandleRepository.deleteAll();

        prepareOrdersRepository.deleteAll();
    }

    @Override
    public boolean isFutureCoin(String gecko_id) {
        if (binanceFuturesRepository.existsById(gecko_id)) {
            return true;
        }
        return false;
    }

    @Override
    @Transactional
    public String initCrypto(String gecko_id, String symbol) {
        String init_trend_result = "";

        List<BtcFutures> list_weeks = Utils.loadData(symbol, Utils.CRYPTO_TIME_W1, 10);
        BscScanBinanceApplication.wait(BscScanBinanceApplication.SLEEP_MINISECONDS);
        if (CollectionUtils.isEmpty(list_weeks)) {
            return "";
        }

        List<BtcFutures> list_days = Utils.loadData(symbol, Utils.CRYPTO_TIME_D1, 30);
        BscScanBinanceApplication.wait(BscScanBinanceApplication.SLEEP_MINISECONDS);
        if (CollectionUtils.isEmpty(list_days)) {
            return "";
        }

        List<BtcFutures> list_h4 = Utils.loadData(symbol, Utils.CRYPTO_TIME_H4, 60);
        BscScanBinanceApplication.wait(BscScanBinanceApplication.SLEEP_MINISECONDS);
        if (CollectionUtils.isEmpty(list_h4)) {
            return "";
        }

        List<BtcFutures> list_h1 = Utils.loadData(symbol, Utils.CRYPTO_TIME_H1, 60);
        BscScanBinanceApplication.wait(BscScanBinanceApplication.SLEEP_MINISECONDS);
        if (CollectionUtils.isEmpty(list_h1)) {
            return "";
        }

        BigDecimal current_price = list_days.get(0).getCurrPrice();

        String type = "";
        if (binanceFuturesRepository.existsById(gecko_id)) {
            type = " (Futures) ";
        } else {
            type = " (Spot) ";
        }
        String taker = Utils.analysisTakerVolume(list_days, list_h4);

        // -------------------------- INIT WEBSITE --------------------------

        Boolean allow_long_d1 = Utils.checkClosePriceAndMa_StartFindLong(list_days);
        String scapLongH4 = Utils.getScapLong(list_h4, list_days, 10, allow_long_d1);
        String scapLongD1 = Utils.getScapLong(list_days, list_days, 10, allow_long_d1);

        CandidateCoin entity = candidateCoinRepository.findById(gecko_id).orElse(null);
        if (!Objects.equals(null, entity)) {
            entity.setCurrentPrice(current_price);
            candidateCoinRepository.save(entity);
        }

        List<BigDecimal> min_max_week = Utils.getLowHighCandle(list_weeks);
        BigDecimal min_week = Utils.formatPrice(min_max_week.get(0).multiply(BigDecimal.valueOf(0.99)), 5);

        List<BigDecimal> min_max_day = Utils
                .getLowHighCandle(list_days.subList(0, list_days.size() > 10 ? 10 : list_days.size()));
        BigDecimal min_days = min_max_day.get(0);
        BigDecimal max_days = min_max_day.get(1);

        String W1 = list_weeks.get(0).isUptrend() ? "W↑" : "W↓";
        String D1 = list_days.get(0).isUptrend() ? "D↑" : "D↓";

        String note = W1 + D1;
        note += ",L10d:" + Utils.getPercentToEntry(current_price, min_days, true);
        note += ",H10d:" + Utils.getPercentToEntry(current_price, max_days, false);
        note += ",L10w:" + Utils.getPercentToEntry(current_price, min_week, true) + ",";
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
        String web_result = note + type + Utils.analysisVolume(list_days) + m2ma + ma7 + sl2ma + taker;
        if (web_result.length() > 500) {
            web_result = web_result.substring(0, 450);
        }
        String EVENT_ID = "EVENT_1W1D_CRYPTO_" + symbol;
        fundingHistoryRepository.save(createPumpDumpEntity(EVENT_ID, gecko_id, symbol, web_result, true));

        initWebBinance(gecko_id, symbol, list_days, list_h1, web_result);

        return init_trend_result;
    }

    @Override
    public boolean hasConnectTimeOutException() {
        return ordersRepository.existsById(Utils.CONNECTION_TIMED_OUT_ID);
    }

    @Override
    @Transactional
    public void deleteConnectTimeOutException() {
        deleteOrders(Utils.CONNECTION_TIMED_OUT_ID);
    }

    @Transactional
    public void deleteOrders(String orderId_d1) {
        Orders entity_d1 = ordersRepository.findById(orderId_d1).orElse(null);
        if (Objects.nonNull(entity_d1)) {
            ordersRepository.deleteById(orderId_d1);
        }
    }

    @Transactional
    private void createOrders(String SYMBOL, String orderId, String switch_trend_type, String trend,
            List<BtcFutures> list, String trend_candle_1) {
        String date_time = LocalDateTime.now().toString();

        List<BigDecimal> body = Utils.getBodyCandle(list);
        List<BigDecimal> low_high = Utils.getLowHighCandle(list);

        String note = "";
        if (CRYPTO_LIST_BUYING.contains(SYMBOL)) {
            note = switch_trend_type + "   **BUYING** ";

        } else if (Utils.COINS_NEW_LISTING.contains(SYMBOL)) {
            note = switch_trend_type + "   NEW_LISTING";

        } else if (Utils.LIST_WAITING.contains(SYMBOL)) {
            note = switch_trend_type + "   WATCH_LIST";

        } else {
            note = switch_trend_type;
        }

        String nocation = "";
        if (list.size() >= 50) {
            if (Utils.isNotBlank(Utils.switchTrendByMa13_XX(list, 50))) {
                nocation = Utils.NOCATION_CUTTING_MA50;
            } else if (Utils.isBelowMALine(list, 50)) {
                nocation = Utils.NOCATION_BELOW_MA50;
            } else if (Utils.isAboveMALine(list, 50)) {
                nocation = Utils.NOCATION_ABOVE_MA50;
            }
        }

        boolean allow_trade_by_ma50 = false;
        if (Objects.equals(trend, Utils.TREND_LONG) && Objects.equals(nocation, Utils.NOCATION_BELOW_MA50)) {
            allow_trade_by_ma50 = true;
        }
        if (Objects.equals(trend, Utils.TREND_SHOT) && Objects.equals(nocation, Utils.NOCATION_ABOVE_MA50)) {
            allow_trade_by_ma50 = true;
        }

        String zone = Utils.getZone(list);
        String trend_d1 = get_trend_by_line_chart(SYMBOL, Utils.CAPITAL_TIME_D1);
        boolean tradable_zone = false;
        if (zone.contains(trend_d1)) {
            tradable_zone = true;
        }

        Orders entity = new Orders(orderId, date_time, trend, list.get(0).getCurrPrice(), body.get(0), body.get(1),
                low_high.get(0), low_high.get(1), Utils.appendSpace(note, 50), allow_trade_by_ma50, trend_candle_1,
                tradable_zone);

        ordersRepository.save(entity);
    }

    private String get_time_frames(String EPIC) {
        // "(W1:Buy ,D1:Buy ,H12:Buy ,H8:Buy ,H4:Buy ,H2:Sell,30:Buy )";
        List<String> times = Arrays.asList(Utils.CAPITAL_TIME_MO, Utils.CAPITAL_TIME_W1, Utils.CAPITAL_TIME_D1,
                Utils.CAPITAL_TIME_H12, Utils.CAPITAL_TIME_H4, Utils.CAPITAL_TIME_H1);

        String TRADE_TREND = "NOT_FOUND";
        List<Mt5OpenTradeEntity> tradeList = mt5OpenTradeRepository.findAllBySymbolOrderByCompanyAsc(EPIC);
        if (!CollectionUtils.isEmpty(tradeList)) {
            Mt5OpenTradeEntity trade = tradeList.get(0);
            TRADE_TREND = trade.getType().toUpperCase().contains(Utils.TREND_LONG) ? Utils.TREND_LONG
                    : Utils.TREND_SHOT;
        }

        String summary = "";
        String trend_w = "";
        String trend_d1 = "";
        String trend_h12 = "";
        String trend_h4 = "";
        String trend_h1 = "";
        for (String CAPITAL_TIME_XX : times) {
            String chart_name = Utils.getChartNameCapital(CAPITAL_TIME_XX).replace("(", "").replace(")", "").trim();

            String trend_xx = get_trend_by_line_chart(EPIC, CAPITAL_TIME_XX);
            if (trend_xx.contains(Utils.TREND_NULL)) {
                if (Utils.isNotBlank(summary))
                    summary += "  ";
                summary += Utils.appendSpace("", chart_name.length()) + "  ";
                continue;
            }

            if (Utils.isNotBlank(summary))
                summary += ", ";

            summary += chart_name + ":";
            summary += Objects.equals(trend_xx, Utils.TREND_LONG) ? "B"
                    : Objects.equals(trend_xx, Utils.TREND_SHOT) ? "S" : " ";

            if (Objects.equals(Utils.CAPITAL_TIME_W1, CAPITAL_TIME_XX)) {
                trend_w = trend_xx;
            }
            if (Objects.equals(Utils.CAPITAL_TIME_D1, CAPITAL_TIME_XX)) {
                trend_d1 = trend_xx;
            }
            if (Objects.equals(Utils.CAPITAL_TIME_H12, CAPITAL_TIME_XX)) {
                trend_h12 = trend_xx;
            }
            if (Objects.equals(Utils.CAPITAL_TIME_H4, CAPITAL_TIME_XX)) {
                trend_h4 = trend_xx;
            }
            if (Objects.equals(Utils.CAPITAL_TIME_H1, CAPITAL_TIME_XX)) {
                trend_h1 = trend_xx;
            }
        }
        summary = "(" + summary + ")";
        if (Objects.equals(trend_w, trend_d1)) {
            summary = "       " + summary;
        } else {
            summary = "  W#D  " + summary;
        }
        summary = Utils.appendSpace(summary, 50);
        // ----------------------------------------
        boolean isTrendInverse = false;
        if (!Objects.equals(trend_h12, TRADE_TREND) && !Objects.equals(trend_h4, TRADE_TREND)
                && !Objects.equals(trend_h1, TRADE_TREND)) {
            isTrendInverse = true;
        }

        if (isTrendInverse) {
            summary = "Stop -> " + Utils.appendSpace(TRADE_TREND, 4) + summary;
        } else {
            summary = "            " + summary;
        }

        return summary;
    }

    private String analysis_profit(String prifix, String EPIC, String append2, String find_trend) {
        // if (Objects.equals(EPIC, "BAC")) {
        // boolean debug = true;
        // }

        int length = 60;
        String type = "";
        BigDecimal t_profit = BigDecimal.ZERO;
        List<Mt5OpenTradeEntity> tradeList = mt5OpenTradeRepository.findAllBySymbolOrderByCompanyAsc(EPIC);
        for (Mt5OpenTradeEntity trade : tradeList) {
            type = Objects.equals(trade.getType(), Utils.TREND_LONG) ? "B"
                    : Objects.equals(trade.getType(), Utils.TREND_SHOT) ? "S" : " ";
            t_profit = t_profit.add(Utils.getBigDecimal(trade.getProfit()));
        }

        String append = prifix.trim() + "   " + append2
                + Utils.appendSpace(tradeList.size() > 0
                        ? " (" + type + ")_Profit:" + Utils.appendLeft(String.valueOf(t_profit.intValue()), 6) + "$"
                        : "", 15);

        outputLog(EPIC, append, find_trend);

        for (Mt5OpenTradeEntity trade : tradeList) {
            String ea = "   Opening: ";
            ea += Utils.appendLeft(trade.getCompany(), 9) + ": ";
            ea += Utils.appendSpace(trade.getType(), 8);
            ea += " SL:" + Utils.appendSpace(Utils.removeLastZero(trade.getStopLoss()), 11);
            ea += " TP:" + Utils.appendSpace(Utils.removeLastZero(trade.getTakeProfit()), 10);
            ea += "     Profit:"
                    + Utils.appendLeft(Utils.getStringValue(Utils.getBigDecimal(trade.getProfit()).intValue()), 6);
            ea += "$    " + Utils.appendLeft(Utils.getStringValue(Utils.formatPrice(trade.getVolume(), 2)), 18)
                    + "(lot)";
            ea = Utils.appendLeft("", 138) + Utils.appendSpace(ea, length);

            Utils.logWritelnDraft(ea);
        }
        if (tradeList.size() > 0) {
            // Utils.logWritelnDraft("");
        }

        if (!isReloadAfter(Utils.MINUTES_OF_1H, EPIC + find_trend)) {
            return "";
        }

        return EPIC;
    }

    @Override
    public void CloseTickets() {
        String mt5_data_file = Utils.getMt5DataFolder(Utils.MT5_COMPANY_FTMO) + "CloseSymbols.csv";
        try {
            FileWriter writer = new FileWriter(mt5_data_file, true);

            for (String TICKET : BscScanBinanceApplication.mt5_close_ticket_dict.keySet()) {
                if (!mt5OpenTradeRepository.existsById(TICKET)) {
                    continue;
                }

                String EPIC = "NOT_FOUND";
                Mt5OpenTradeEntity mt5Entity = mt5OpenTradeRepository.findById(TICKET).orElse(null);
                if (Objects.nonNull(mt5Entity)) {
                    EPIC = mt5Entity.getSymbol();
                }

                if (Utils.EPICS_STOCKS_EUR.contains(EPIC) && !Utils.is_london_session()) {
                    continue;
                }
                if (Utils.EPICS_STOCKS_USA.contains(EPIC) && !Utils.is_newyork_session()) {
                    continue;
                }

                StringBuilder sb = new StringBuilder();
                String hold = "__";
                if (!hold.contains(EPIC)) {
                    sb.append(TICKET);
                    sb.append('\n');
                    writer.write(sb.toString());
                }

                System.out.println("CloseTicket: " + TICKET + "    Resion: "
                        + BscScanBinanceApplication.mt5_close_ticket_dict.get(TICKET));
            }

            writer.close();
        } catch (

        Exception e) {
            System.out.println(e.getMessage());
        }
    }

    private void openTrade() {
        if (CollectionUtils.isEmpty(BscScanBinanceApplication.mt5_open_trade_List)) {
            return;
        }
        if (Utils.isSleepTime_23h_to_8h()) {
            return;
        }

        String mt5_open_trade_file = Utils.getMt5DataFolder(Utils.MT5_COMPANY_FTMO) + "OpenTrade.csv";
        int MAX_TRADE = 100;
        int trade_count = 0;

        try {
            FileWriter writer = new FileWriter(mt5_open_trade_file, true);
            Hashtable<String, String> msg_dict = new Hashtable<String, String>();

            // TODO: 4. openTrade
            for (Mt5OpenTrade dto : BscScanBinanceApplication.mt5_open_trade_List) {
                if (Objects.isNull(dto)) {
                    continue;
                }
                String EPIC = dto.getEpic().toUpperCase();

                if ("_DX.f_NATGAS_ERBN__".toUpperCase().contains(EPIC)) {
                    continue;
                }

                if (!is_opening_trade(EPIC, dto.getOrder_type()) && !dto.getComment().contains("EOZ:H12H4")) {
                    String find_reverse_trend = dto.getOrder_type().contains(Utils.TREND_LONG) ? Utils.TREND_LONG
                            : dto.getOrder_type().contains(Utils.TREND_SHOT) ? Utils.TREND_SHOT : "_";

                    List<Mt5OpenTradeEntity> opening_list = mt5OpenTradeRepository
                            .findAllBySymbolAndTypeOrderBySymbolAsc(EPIC, find_reverse_trend);

                    for (Mt5OpenTradeEntity trade : opening_list) {
                        String log = Utils.createCloseTradeMsg(trade, "MUST_CLOSE_TRADE: ", "reverse_trade_opening");
                        Utils.logWritelnDraft(log);

                        String EVENT_ID = "MUST_CLOSE_TRADE" + dto.getEpic() + dto.getOrder_type()
                                + Utils.getCurrentYyyyMmDd_Blog4h()
                                + Utils.getDeEncryptedChartNameCapital(dto.getComment());

                        msg_dict.put(EVENT_ID, log);

                        BscScanBinanceApplication.mt5_close_ticket_dict.put(trade.getTicket(), "reverse_trade_opening");
                    }

                    // ----------------------------------------------------------------------------------
                    String prefix = "Open_Trade: ";
                    if (dto.getComment().contains("1vs6810")) {
                        // prefix = "Check:      ";
                    }
                    String msg = Utils.createOpenTradeMsg(dto, prefix);
                    Utils.logWritelnDraft(msg + " " + Utils.appendSpace(Utils.getCapitalLink(EPIC), 62));

                    if (!Utils.isSleepTime_23h_to_8h()) {
                        String EVENT_ID = "OPEN_TRADE" + dto.getEpic() + dto.getOrder_type()
                                + Utils.getCurrentYyyyMmDd_Blog4h()
                                + Utils.getDeEncryptedChartNameCapital(dto.getComment());

                        msg_dict.put(EVENT_ID, msg);

                        if (Utils.EPICS_CRYPTO_CFD.contains(EPIC)) {
                            continue;
                        }

                        if ((trade_count < MAX_TRADE) && dto.getComment().contains(Utils.TEXT_PASS)) {
                            trade_count += 1;
                            if (Utils.isPcCongTy()) {
                                StringBuilder sb = new StringBuilder();
                                sb.append(dto.getEpic());
                                sb.append('\t');
                                sb.append(dto.getOrder_type());
                                sb.append('\t');
                                if (EPIC.contains("ERBN")) {
                                    sb.append(1);
                                } else {
                                    sb.append(dto.getLots());
                                }
                                sb.append('\t');
                                sb.append(dto.getEntry());
                                sb.append('\t');
                                sb.append(dto.getStop_loss());
                                sb.append('\t');
                                sb.append(dto.getTake_profit());
                                sb.append('\t');
                                sb.append(dto.getComment());
                                sb.append('\n');

                                writer.write(sb.toString());
                            }
                        }
                    }
                }
            }
            writer.close();

            String msg = "";
            for (String EVENT_ID : msg_dict.keySet()) {
                if (isReloadAfter(Utils.MINUTES_OF_1H, EVENT_ID)) {
                    msg += msg_dict.get(EVENT_ID) + Utils.new_line_from_service + Utils.new_line_from_service;
                }
            }

            for (String stock : BscScanBinanceApplication.msg_open_trade_stocks) {
                msg += stock + Utils.new_line_from_service + Utils.new_line_from_service;
            }

            if (Utils.isNotBlank(msg)) {
                String EVENT_ID = "OPEN_TRADE" + Utils.getCurrentYyyyMmDd_HH();
                sendMsgPerHour_OnlyMe(EVENT_ID, "(FTMO)" + Utils.new_line_from_service + msg);
            }
        } catch (Exception e) {
            System.out.println(e.getMessage());
        }

        Utils.logWritelnDraft("");
        Utils.logWritelnDraft("");
        Utils.logWritelnDraft("");
    }

    private void outputLog(String EPIC, String append, String trend_fi) {
        Orders dto_w1 = ordersRepository.findById(EPIC + "_" + Utils.CAPITAL_TIME_W1).orElse(null);
        Orders dto_d1 = ordersRepository.findById(EPIC + "_" + Utils.CAPITAL_TIME_D1).orElse(null);
        Orders dto_h4 = ordersRepository.findById(EPIC + "_" + Utils.CAPITAL_TIME_H4).orElse(null);
        Orders dto_h1 = ordersRepository.findById(EPIC + "_" + Utils.CAPITAL_TIME_H1).orElse(null);

        List<BtcFutures> list_h12 = getCapitalData(EPIC, Utils.CAPITAL_TIME_H12);
        if (CollectionUtils.isEmpty(list_h12)) {
            list_h12 = getCapitalData(EPIC, Utils.CAPITAL_TIME_D1);
        }
        if (CollectionUtils.isEmpty(list_h12) || Objects.isNull(dto_d1) || Objects.isNull(dto_h4)
                || Objects.isNull(dto_h1)) {
            return;
        }

        String trend_w1 = dto_w1.getTrend_line();
        String trend_d1 = dto_d1.getTrend_line();
        String trend_h4 = dto_h4.getTrend_line();

        String text_risk = "0.1% ";
        BigDecimal risk = Utils.RISK_0_10_PERCENT;

        String log_week = "     0.1% " + Utils.appendSpace(Utils.calc_BUF_LO_HI_BUF_Forex(Utils.RISK_0_10_PERCENT,
                false, dto_w1.getTrend_line(), EPIC, dto_h1, dto_w1), 45) + dto_w1.getSwitch_trend();

        if (Objects.equals(EPIC, "NATGAS")) {
            boolean debug = true;
        }

        // TODO: outputLog
        String log = Utils.getTypeOfEpic(EPIC) + Utils.appendSpace(EPIC, 8);
        log += Utils.appendSpace(Utils.removeLastZero(Utils.formatPrice(dto_h1.getCurrent_price(), 5)), 11);
        log += Utils.appendSpace(append.trim(), 115) + " ";
        log += Utils.appendSpace(Utils.getCapitalLink(EPIC), 62) + " ";
        log += text_risk + Utils.appendSpace(
                Utils.calc_BUF_LO_HI_BUF_Forex(risk, false, dto_d1.getTrend_line(), EPIC, dto_h1, dto_d1), 45);

        if (!dto_d1.isTradable_zone() || !dto_h4.isTradable_zone()
                || (Utils.isNotBlank(dto_h4.getSwitch_trend()) && !dto_h4.getSwitch_trend().contains(trend_d1))) {
            String reverse_trend = (Objects.equals(dto_d1.getTrend_line(), Utils.TREND_LONG)) ? Utils.TREND_SHOT
                    : Utils.TREND_LONG;

            log += text_risk + Utils
                    .appendSpace(Utils.calc_BUF_LO_HI_BUF_Forex(risk, false, reverse_trend, EPIC, dto_h1, dto_d1), 45);
        }

        if (dto_w1.getSwitch_trend().contains(dto_w1.getTrend_line()) && dto_w1.isTradable_zone()
                && Objects.equals(trend_w1, trend_d1) && Objects.equals(trend_w1, trend_h4)) {
            log += log_week;
        } else {
            log += Utils.appendSpace("", log_week.length());
        }

        Utils.logWritelnDraft(log.trim());

        if (Objects.equals(trend_d1, trend_h4)) {
            if (log.contains("Heiken") || log.contains("Ma")) {
                Utils.logWritelnReport(log.trim());
            }
        }
    }

    private String get_trend_by_line_chart(String EPIC, String CAPITAL_TIME_XX) {
        Orders dto = ordersRepository.findById(EPIC + "_" + CAPITAL_TIME_XX).orElse(null);

        if (Objects.isNull(dto)) {
            return Utils.TREND_NULL + Utils.getChartPrefix(CAPITAL_TIME_XX);
        }

        String trend = dto.getTrend_line();

        return trend;
    }

    @Override
    @Transactional
    public String sendMsgKillLongShort(String SYMBOL) {
        if (!BTC_ETH_BNB.contains(SYMBOL)) {
            return Utils.CRYPTO_TIME_H1;
        }
        if (Utils.isSleepTime_23h_to_8h()) {
            return Utils.CRYPTO_TIME_H1;
        }

        List<BtcFutures> list = Utils.loadData(SYMBOL, Utils.CRYPTO_TIME_D1, 15);
        if (CollectionUtils.isEmpty(list)) {
            return Utils.CRYPTO_TIME_H1;
        }

        List<BtcFutures> heken_list = Utils.getHeikenList(list);
        String trend = Utils.getTrendByHekenAshiList(heken_list);
        String switch_trend = Utils.switchTrendByHeken_12(heken_list);

        if (Utils.isNotBlank(switch_trend)) {
            // TODO: sendMsgKillLongShort
            String msg = "";

            if (Objects.equals(Utils.TREND_LONG, trend)) {
                msg = " 💹 (D1)" + SYMBOL + "_kill_Short 💔 ";
            } else if (Objects.equals(Utils.TREND_SHOT, trend)) {
                msg = " 🔻 (D1)" + SYMBOL + "_kill_Long 💔 ";
            } else {
                return Utils.CRYPTO_TIME_H1;
            }
            msg += "(" + Utils.appendSpace(Utils.removeLastZero(list.get(0).getCurrPrice()), 5) + ")";

            String EVENT_ID = "MSG_PER_HOUR" + SYMBOL + Utils.getCurrentYyyyMmDd_Blog4h();
            sendMsgPerHour_ToAll(EVENT_ID, msg);
        }

        return Utils.CRYPTO_TIME_H1;
    }

    private boolean allow_padding_trade_after_1day(String EPIC) {
        List<Mt5OpenTradeEntity> list = mt5OpenTradeRepository.findAllBySymbolOrderByCompanyAsc(EPIC);
        if (CollectionUtils.isEmpty(list)) {
            return false;
        }

        int count = 0;
        for (Mt5OpenTradeEntity mt5Entity : list) {
            String insert_time = Utils.getStringValue(mt5Entity.getOpenTime());
            if (Utils.isNotBlank(insert_time)) {
                LocalDateTime pre_time = LocalDateTime.parse(insert_time);
                Duration duration = Duration.between(pre_time, LocalDateTime.now());
                long elapsedMinutes = duration.toMinutes();

                if (elapsedMinutes > Utils.MINUTES_OF_1D) {
                    count += 1;
                }
            }
        }

        if (count == list.size()) {
            return true;
        }
        return false;
    }

    private boolean allow_close_trade_after(String TICKET, Integer MINUTES_OF_XX) {
        Mt5OpenTradeEntity mt5Entity = mt5OpenTradeRepository.findById(TICKET).orElse(null);
        if (Objects.nonNull(mt5Entity)) {

            String insert_time = Utils.getStringValue(mt5Entity.getOpenTime());
            if (Utils.isNotBlank(insert_time)) {
                LocalDateTime pre_time = LocalDateTime.parse(insert_time);
                Duration duration = Duration.between(pre_time, LocalDateTime.now());
                long elapsedMinutes = duration.toMinutes();

                if (elapsedMinutes > MINUTES_OF_XX) {
                    return true;
                }
            }

        }

        return false;
    }

    private boolean is_opening_trade(String EPIC, String trend) {
        // cho nhồi lệnh = chưa mở lệnh
        if (allow_padding_trade_after_1day(EPIC)) {
            return false;
        }

        List<Mt5OpenTradeEntity> tradeList = mt5OpenTradeRepository.findAllBySymbolOrderByCompanyAsc(EPIC);
        allow_padding_trade_after_1day(EPIC);
        for (Mt5OpenTradeEntity trade : tradeList) {
            if (Objects.equals(trade.getSymbol().toUpperCase(), EPIC.toUpperCase())) {
                if (Utils.isBlank(trend)) {
                    return true;
                }
                if (trade.getType().toUpperCase().contains(trend.toUpperCase())) {
                    return true;
                }
            }
        }

        return false;
    }

    @Override
    @Transactional
    public void monitorProfit() {
        // -------------------------------------------------------------------------------------
        // "BTCUSD", GER40", "US30", "US100", "UK100", "USOIL", "XAGUSD", "XAUUSD"
        // "AUDJPY", "AUDUSD", "CADJPY", "CHFJPY",
        // "EURAUD", "EURCAD", "EURCHF", "EURGBP", "EURJPY", "EURNZD", "EURUSD",
        // "GBPAUD", "GBPCAD", "GBPCHF", "GBPJPY", "GBPNZD", "GBPUSD",
        // "NZDCAD", "NZDCHF", "NZDJPY", "NZDUSD",
        // "USDCAD", "USDCHF", "USDJPY"
        // ---------------------------------------CRYPTO----------------------------------------
        CRYPTO_LIST_BUYING = Arrays.asList("");
        if (isReloadAfter(Utils.MINUTES_OF_1H, "MONITOR_CRYPTO_BUY")) {
            for (String SYMBOL : CRYPTO_LIST_BUYING) {
                if (Utils.isBlank(SYMBOL)) {
                    continue;
                }

                initCryptoTrend(SYMBOL);
                BscScanBinanceApplication.wait(BscScanBinanceApplication.SLEEP_MINISECONDS);
            }
        }

        CRYPTO_LIST_SELING = Arrays.asList("");
        if (isReloadAfter(Utils.MINUTES_OF_1H, "MONITOR_CRYPTO_SEL")) {
            for (String SYMBOL : CRYPTO_LIST_SELING) {
                if (Utils.isBlank(SYMBOL)) {
                    continue;
                }

                initCryptoTrend(SYMBOL);
                BscScanBinanceApplication.wait(BscScanBinanceApplication.SLEEP_MINISECONDS);
            }
        }

        // -----------------------------------
        // TODO: 6. monitorProfit
        Utils.logWritelnDraft("");
        for (String company : Utils.COMPANIES) {
            try {
                String mt5_close_trade_file = Utils.getMt5DataFolder(Utils.MT5_COMPANY_FTMO) + "CloseSymbols.csv";
                File myScap = new File(mt5_close_trade_file);
                myScap.delete();
            } catch (Exception e) {
            }

            int count = 0;
            String msg = "";
            BigDecimal total = BigDecimal.ZERO;
            String risk_0_15 = "     Risk: 0.1% : " + Utils.RISK_0_10_PERCENT.intValue() + "$ per trade";
            List<Mt5OpenTradeEntity> mt5Openlist = mt5OpenTradeRepository.findAllByCompanyOrderBySymbolAsc(company);
            for (Mt5OpenTradeEntity trade : mt5Openlist) {
                count += 1;
                String EPIC = trade.getSymbol();
                String multi_timeframes = get_time_frames(EPIC);
                BigDecimal PROFIT = Utils.getBigDecimal(trade.getProfit());
                String TRADE_TREND = trade.getType().toUpperCase();

                String result = "";
                result += Utils.appendLeft("Trade:" + Utils.appendLeft(String.valueOf(count), 3), 15) + ". ";
                result += Utils.appendSpace(trade.getCompany(), 10);
                result += Utils.appendSpace(TRADE_TREND, 10) + "   ";
                result += Utils.getTypeOfEpic(EPIC) + "   ";
                result += Utils.appendSpace(EPIC, 10);
                result += Utils.appendSpace(trade.getTicket(), 10);
                result += "   Vol:" + Utils.appendLeft(Utils.removeLastZero(trade.getVolume()), 6);
                result += "   (Profit):" + Utils.appendLeft(Utils.getStringValue(PROFIT.intValue()), 6) + "$";
                result += "    " + Utils.appendSpace(multi_timeframes, 55);
                result += Utils.appendSpace(Utils.getCapitalLink(EPIC), 62);
                result += "---" + Utils.appendSpace(trade.getComment(), 35, "-");

                total = total.add(PROFIT);
                msg += result + Utils.new_line_from_service;
            }

            if (Utils.isNotBlank(msg)) {
                msg = Utils.appendSpace(company, 15) + Utils.appendLeft(String.valueOf(total.intValue()), 10)
                        + risk_0_15 + Utils.new_line_from_service + msg;
                Utils.logWritelnDraft(msg.replace(Utils.new_line_from_service, "\n"));
            }
        }

        Utils.logWritelnDraft("");
        openTrade();

        for (String msg : BscScanBinanceApplication.msg_open_trade_stocks) {
            Utils.logWritelnDraft(msg);
        }
    }

    private String check_mt5_data_file(String mt5_data_file_path, Integer MINUTES_OF_XX) {
        try {
            File file = new File(mt5_data_file_path);
            if (!file.exists()) {
                Utils.logWritelnDraft(Utils.getCompanyByFoder(mt5_data_file_path) + " [mt5_data_file FileNotFound]: "
                        + mt5_data_file_path);
                return "";
            }

            if (mt5_data_file_path.contains("Trade.csv")) {
                return mt5_data_file_path;
            }

            BasicFileAttributes attr = Files.readAttributes(file.toPath(), BasicFileAttributes.class);
            LocalDateTime created_time = attr.lastModifiedTime().toInstant().atZone(ZoneId.systemDefault())
                    .toLocalDateTime();
            long elapsedMinutes = Duration.between(created_time, LocalDateTime.now()).toMinutes();
            required_update_bars_csv = false;
            if (elapsedMinutes > (MINUTES_OF_XX * 3)) {
                String filename = file.getName();
                required_update_bars_csv = true;

                Utils.logWritelnDraft(filename + " khong duoc update! " + filename + " khong duoc update! " + filename
                        + " khong duoc update! " + filename + " khong duoc update! \n");
                String EVENT_ID = EVENT_PUMP + "_UPDATE_BARS_CSV_" + Utils.getCurrentYyyyMmDd_HH();
                sendMsgPerHour_OnlyMe(EVENT_ID, "(FTMO) Update:" + filename);

                return "";
            }
        } catch (Exception e) {
        }

        return mt5_data_file_path;
    }

    @Override
    @Transactional
    public void saveMt5Data(String filename, Integer MINUTES_OF_XX) {
        try {
            String mt5_data_file_path = Utils.getMt5DataFolder(Utils.MT5_COMPANY_FTMO) + filename;
            String mt5_data_file = check_mt5_data_file(mt5_data_file_path, MINUTES_OF_XX);
            if (Utils.isBlank(mt5_data_file)) {
                return;
            }
            // ------------------------------------------------------------------------
            String line;
            int total_line = 0;
            int total_data = 0;
            int not_found = 0;
            String epic_not_found = "";
            List<String> epics_time = new ArrayList<String>();
            List<Mt5DataCandle> list = new ArrayList<Mt5DataCandle>();
            List<Mt5DataCandle> list_delete = new ArrayList<Mt5DataCandle>();
            Reader reader = new InputStreamReader(new FileInputStream(mt5_data_file), "UTF-8");
            BufferedReader fin = new BufferedReader(reader);
            while ((line = fin.readLine()) != null) {
                total_line += 1;

                String[] tempArr = line.replace(".f", "").replace(".cash", "").replace(".pro", "").split("\\t");

                if (line.contains("NATGAS")) {
                    boolean debug = true;
                }

                if (tempArr.length == 8) {
                    Mt5DataCandle dto = new Mt5DataCandle(new Mt5DataCandleKey(tempArr[0], tempArr[1], tempArr[2]),
                            Utils.getBigDecimal(tempArr[3]), Utils.getBigDecimal(tempArr[4]),
                            Utils.getBigDecimal(tempArr[5]), Utils.getBigDecimal(tempArr[6]), Utils.getYYYYMMDD(0),
                            Utils.getBigDecimal(tempArr[7]));
                    list.add(dto);

                    total_data += 1;

                    if (!epics_time.contains(dto.getId().getEpic() + "_" + dto.getId().getCandleTime())) {
                        epics_time.add(dto.getId().getEpic() + "_" + dto.getId().getCandleTime());
                        list_delete.add(dto);
                    }
                }

                if (line.contains("NOT_FOUND")) {
                    not_found += 1;

                    if (tempArr.length > 2 && !epic_not_found.contains(tempArr[1])) {
                        epic_not_found += tempArr[1] + ", ";
                    }
                }
            }

            // Remember to call close.
            // calling close on a BufferedReader/BufferedWriter
            // will automatically call close on its underlying stream
            fin.close();
            reader.close();

            // ------------------------------------------------------------------------

            List<Mt5DataCandle> nottodaylist = mt5DataCandleRepository.findAllByCreateddateNot(Utils.getYYYYMMDD(0));
            if (!CollectionUtils.isEmpty(nottodaylist)) {
                mt5DataCandleRepository.deleteAll(nottodaylist);
            }

            for (Mt5DataCandle dto : list_delete) {
                List<Mt5DataCandle> temp = mt5DataCandleRepository.findAllByIdEpicAndIdCandle(dto.getId().getEpic(),
                        dto.getId().getCandle());

                if (!CollectionUtils.isEmpty(temp)) {
                    mt5DataCandleRepository.deleteAll(temp);
                }
            }
            mt5DataCandleRepository.saveAll(list);

            // ------------------------------------------------------------------------
            String log = "(MT5_DATA): " + Utils.appendLeft(String.valueOf(total_data), 4) + "/"
                    + Utils.appendLeft(String.valueOf(total_line), 4);
            if (not_found > 0) {
                log += "/NOT_FOUND:" + epic_not_found;
            }

            if (log.contains("NOT_FOUND")) {
                Utils.logWritelnDraft("\n\n\n");
                Utils.logWritelnDraft(log);
                Utils.logWritelnDraft("file:" + mt5_data_file.replace("\\", "/"));
                Utils.logWritelnDraft("\n\n\n");
            }

            if (Objects.equals("Forex.csv", filename)) {
                initTradeList();
            }
        } catch (Exception e) {
        }
    }

    private List<BtcFutures> getCapitalData(String EPIC, String CAPITAL_TIME_XXX) {
        List<BtcFutures> list = new ArrayList<BtcFutures>();

        List<Mt5DataCandle> list_mt5 = mt5DataCandleRepository.findAllByIdEpicAndIdCandleOrderByIdCandleTimeDesc(EPIC,
                CAPITAL_TIME_XXX);
        int id = 0;
        for (Mt5DataCandle dto : list_mt5) {
            BigDecimal clo_price = Utils.getBigDecimal(dto.getClo_price());
            BigDecimal currPrice = Utils.getBigDecimal(dto.getCurrent_price());
            if (id == 0) {
                clo_price = currPrice;
            }

            boolean uptrend = (dto.getOpe_price().compareTo(clo_price) < 0) ? true : false;

            String strid = Utils.getStringValue(id);
            if (strid.length() < 2) {
                strid = "0" + strid;
            }
            strid = dto.getId().getEpic() + Utils.getChartPrefix(dto.getId().getCandle()) + strid;

            BtcFutures entity = new BtcFutures(strid, currPrice, dto.getLow_price(), dto.getHig_price(),
                    dto.getOpe_price(), clo_price, BigDecimal.ZERO, BigDecimal.ZERO, BigDecimal.ZERO, BigDecimal.ZERO,
                    uptrend);
            list.add(entity);

            id += 1;
        }

        return list;
    }

    @SuppressWarnings("unused")
    @Override
    public void createReport() {
        if (required_update_bars_csv || true) {
            return;
        }

        // --------------------------------------------------------------------------
        File myObj = new File(Utils.getForexLogFile());
        myObj.delete();

        str_long_suggest = "";
        str_shot_suggest = "";

        List<String> compare_list = Arrays.asList("USD", "CHF", "NZD", "EUR", "GBP", "AUD");
        if (!CollectionUtils.isEmpty(GLOBAL_LONG_LIST)) {
            for (String s : GLOBAL_LONG_LIST) {
                str_long_suggest += s + "    ";
            }
        }
        if (!CollectionUtils.isEmpty(GLOBAL_SHOT_LIST)) {
            for (String s : GLOBAL_SHOT_LIST) {
                str_shot_suggest += s + "    ";
            }
        }
        Utils.logWritelnReport("(BUY ) " + str_long_suggest.trim());
        Utils.logWritelnReport("(SELL) " + str_shot_suggest.trim());

        String msg_forx = "";
        String msg_futu = "";

        List<String> list_d1_log = new ArrayList<String>();
        List<Orders> list_all = ordersRepository.getTrend_DayList();
        if (!CollectionUtils.isEmpty(list_all)) {
            Utils.logWritelnReport("");

            int index = 1;
            for (Orders dto_d1 : list_all) {
                String EPIC = Utils.getEpicFromId(dto_d1.getId());

                String trend_w1 = get_trend_by_line_chart(EPIC, Utils.CAPITAL_TIME_W1);
                String trend_d1 = dto_d1.getTrend_line();

                if (Objects.equals(trend_w1, trend_d1)) {
                    String append = Utils.appendSpace(dto_d1.getSwitch_trend(), 35);
                    String log = Utils.createLineForex_Header(dto_d1, dto_d1, append);
                    log += Utils.appendSpace(Utils.removeLastZero(dto_d1.getCurrent_price()), 15);
                    log += Utils.createLineForex_Body(Utils.RISK_0_10_PERCENT, dto_d1, dto_d1, trend_w1, true).trim();
                    list_d1_log.add(log);
                    index += 1;
                }
            }
        }

        if (list_d1_log.size() > 0) {
            Utils.logWritelnReport("");
            Utils.logWritelnReport(Utils.appendLeftAndRight("   D1   ", 50, "+"));
            for (String log : list_d1_log) {
                Utils.logWritelnReport(log);
            }
            Utils.logWritelnReport("");
            Utils.logWritelnReport("");
        }

        // TODO: createReport
        // ==================================================================================
        // ==================================================================================
        // ==================================================================================
        List<Orders> crypto_list = new ArrayList<Orders>();
        crypto_list.addAll(ordersRepository.getCrypto_D1());

        String w1d1h4 = "";
        String d1h4 = "";
        String d1 = "";
        List<String> list_crypto_log = new ArrayList<String>();

        if (crypto_list.size() > 2) {
            String pre_trend = "";
            for (Orders dto : crypto_list) {
                if (Objects.isNull(dto)) {
                    continue;
                }
                String symbol = dto.getId().replace("CRYPTO_", "").replace("_1w", "").replace("_1d", "")
                        .replace("_12h", "").replace("_4h", "").replace("_1h", "");

                String type = "";
                if (Utils.COINS_FUTURES.contains(symbol)) {
                    type = "  (Futures)   ";
                } else {
                    type = "  (Spot   )   ";
                }

                if (pre_trend.contains(Utils.TREND_LONG) && dto.getTrend_line().contains(Utils.TREND_SHOT)) {
                    list_crypto_log.add("");
                }

                if (Objects.nonNull(dto) && Utils.isNotBlank(dto.getSwitch_trend())) {
                    String log = Utils.createLineCrypto(dto, symbol, type);
                    list_crypto_log.add(log);
                }

                pre_trend = dto.getTrend_line();
            }

            if (list_crypto_log.size() > 0) {
                Utils.logWritelnReport("");
                Utils.logWritelnReport(Utils.appendLeftAndRight("          D1         ", 50, "+"));
                for (String log : list_crypto_log) {
                    Utils.logWritelnReport(log);
                }
                Utils.logWritelnReport("");
                Utils.logWritelnReport("");
            }
        }

        if (isReloadAfter(Utils.MINUTES_OF_1H * 2, "_REPORT_CRYPTO_") && Utils.isNotBlank(msg_futu)) {
            String EVENT_ID = EVENT_PUMP + "_REPORT_CRYPTO_" + Utils.getCurrentYyyyMmDd_Blog2h();

            if (!fundingHistoryRepository.existsPumDump(Utils.EVENT_ID_NO_DUPLICATES, EVENT_ID)) {
                String msg_crypto = "";
                msg_crypto += "(Futu)" + msg_futu + Utils.new_line_from_service;

                Utils.logWritelnDraft(msg_crypto.replace(Utils.new_line_from_service, "\n"));
                // sendMsgPerHour(EVENT_ID, msg_crypto, true);
            }
        }

        Utils.writelnLogFooter_Forex();
    }

    // Tokyo: 05:45~06:15 Đóng lệnh: 11:25~11:45
    // London: 13:45~14:15 Đóng lệnh: 21:25~23:25
    // NewYork: 18:45~19:15 Đóng lệnh: 02:25~03:25
    @Override
    @Transactional
    public String initCryptoTrend(String SYMBOL) {
        List<String> WATCHLIST = new ArrayList<String>();
        WATCHLIST.addAll(CRYPTO_LIST_BUYING);
        WATCHLIST.addAll(Utils.LIST_WAITING);
        WATCHLIST.addAll(Utils.COINS_FUTURES);

        String orderId_M1 = "CRYPTO_" + SYMBOL + "_1M";
        String orderId_d1 = "CRYPTO_" + SYMBOL + "_1d";
        if (!WATCHLIST.contains(SYMBOL)) {
            deleteOrders(orderId_d1);
            deleteOrders("CRYPTO_" + SYMBOL + "_1w");
            deleteOrders("CRYPTO_" + SYMBOL + "_12h");
            deleteOrders("CRYPTO_" + SYMBOL + "_4h");

            return Utils.CRYPTO_TIME_H4;
        }
        // TODO: initCryptoTrend
        // ------------------------------------------------------------------
        List<BtcFutures> heiken_list_month = Utils.getHeikenList(Utils.loadData(SYMBOL, "1M", 15));
        if (CollectionUtils.isEmpty(heiken_list_month)) {
            return Utils.CRYPTO_TIME_H4;
        }
        String trend_month = Utils.getTrendByHekenAshiList(heiken_list_month);
        String switch_trend_month = Utils.switchTrendByHeken_12(heiken_list_month);
        if (!Objects.equals(Utils.TREND_LONG, trend_month)) {
            return Utils.CRYPTO_TIME_H4;
        } else {
            String trend_candle_1 = Utils.getTrendByHekenAshiList(heiken_list_month, 1);
            createOrders(SYMBOL, orderId_M1, switch_trend_month, switch_trend_month, heiken_list_month, trend_candle_1);
        }

        // ------------------------------------------------------------------
        List<BtcFutures> heiken_list_w = Utils.getHeikenList(Utils.loadData(SYMBOL, Utils.CRYPTO_TIME_W1, 15));
        if (CollectionUtils.isEmpty(heiken_list_w)) {
            return Utils.CRYPTO_TIME_H4;
        }
        String trend_w = Utils.getTrendByHekenAshiList(heiken_list_w);
        if (!Objects.equals(Utils.TREND_LONG, trend_w)) {
            return Utils.CRYPTO_TIME_H4;
        }
        // ------------------------------------------------------------------
        List<BtcFutures> heiken_list_d = Utils.getHeikenList(Utils.loadData(SYMBOL, Utils.CRYPTO_TIME_D1, 15));
        if (CollectionUtils.isEmpty(heiken_list_d)) {
            return Utils.CRYPTO_TIME_H4;
        }
        String trend_d = Utils.getTrendByHekenAshiList(heiken_list_d);
        // ------------------------------------------------------------------
        String trading_trend = "";
        if (CRYPTO_LIST_BUYING.contains(SYMBOL)) {
            trading_trend = Utils.TREND_LONG;
        }
        if (CRYPTO_LIST_SELING.contains(SYMBOL)) {
            trading_trend = Utils.TREND_SHOT;
        }
        if (Utils.isNotBlank(trading_trend) && !Objects.equals(trading_trend, trend_d)) {
            String msg_d1 = " 🔻 (STOP_BUY)";
            String str_price = "(" + Utils.appendSpace(Utils.removeLastZero(heiken_list_d.get(0).getCurrPrice()), 5)
                    + ")";
            String log = Utils.appendSpace(Utils.getCryptoLink_Spot(SYMBOL), 70) + Utils.appendSpace(str_price, 15);

            msg_d1 += Utils.appendSpace(SYMBOL, 10) + Utils.appendSpace(str_price, 10);
            msg_d1 += ".D1:" + Utils.appendSpace(trend_d, 5);

            String EVENT_ID = "MSG_PER_HOUR" + SYMBOL + Utils.getCurrentYyyyMmDd_HH();
            sendMsgPerHour_OnlyMe(EVENT_ID, msg_d1);
            logMsgPerHour(EVENT_ID, msg_d1 + log, Utils.MINUTES_OF_1H);
        }
        if (!Objects.equals(Utils.TREND_LONG, trend_d)) {
            return Utils.CRYPTO_TIME_H4;
        }
        String zone_d = Utils.getZone(heiken_list_d);
        if (!zone_d.contains(Utils.TREND_LONG)) {
            return Utils.CRYPTO_TIME_H4;
        }
        // ------------------------------------------------------------------
        List<BtcFutures> heiken_list_h4 = Utils.getHeikenList(Utils.loadData(SYMBOL, Utils.CRYPTO_TIME_H4, 15));
        if (CollectionUtils.isEmpty(heiken_list_h4)) {
            return Utils.CRYPTO_TIME_H4;
        }
        String zone_h4 = Utils.getZone(heiken_list_h4);
        if (!zone_h4.contains(Utils.TREND_LONG)) {
            return Utils.CRYPTO_TIME_H4;
        }
        String trend_h4 = Utils.getTrendByHekenAshiList(heiken_list_h4);
        if (!Objects.equals(Utils.TREND_LONG, trend_h4)) {
            return Utils.CRYPTO_TIME_H4;
        }
        // ------------------------------------------------------------------
        String switch_trend = Utils.switchTrendByMa1_6810(heiken_list_h4);
        switch_trend += Utils.switchTrendByHeken_12(heiken_list_d);
        switch_trend += Utils.switchTrendByHeken_12(heiken_list_w);
        switch_trend += switch_trend_month;

        if (switch_trend.contains(trend_d)) {
            String trend_candle_1 = Utils.getTrendByHekenAshiList(heiken_list_d, 1);
            createOrders(SYMBOL, orderId_d1, switch_trend, switch_trend, heiken_list_d, trend_candle_1);

            String temp = Utils.getTimeHHmm() + "(D1)" + Utils.appendSpace(SYMBOL, 10);
            temp += Utils.appendSpace(Utils.removeLastZero(heiken_list_d.get(0).getCurrPrice()), 15);
            temp += switch_trend + "   " + Utils.getCryptoLink_Spot(SYMBOL).trim();
            System.out.println(temp);
            Utils.logWritelnDraft(temp);
        }

        return Utils.CRYPTO_TIME_H1;
    }

    @Override
    @Transactional
    public void scapStocks() {
        if (required_update_bars_csv) {
            return;
        }
        int index = 1;
        for (String EPIC : Utils.EPICS_STOCKS) {
            Orders dto_mo = ordersRepository.findById(EPIC + "_" + Utils.CAPITAL_TIME_MO).orElse(null);
            Orders dto_w1 = ordersRepository.findById(EPIC + "_" + Utils.CAPITAL_TIME_W1).orElse(null);
            Orders dto_d1 = ordersRepository.findById(EPIC + "_" + Utils.CAPITAL_TIME_D1).orElse(null);
            Orders dto_h4 = ordersRepository.findById(EPIC + "_" + Utils.CAPITAL_TIME_H4).orElse(null);
            Orders dto_h1 = ordersRepository.findById(EPIC + "_" + Utils.CAPITAL_TIME_H1).orElse(null);

            if (Objects.isNull(dto_mo) || Objects.isNull(dto_w1) || Objects.isNull(dto_d1) || Objects.isNull(dto_h4)
                    || Objects.isNull(dto_h1)) {
                String mo = "MO:" + (Objects.isNull(dto_mo) ? "null" : "    ");
                String w1 = "W1:" + (Objects.isNull(dto_w1) ? "null" : "    ");
                String d1 = "D1:" + (Objects.isNull(dto_d1) ? "null" : "    ");
                String h4 = "H4:" + (Objects.isNull(dto_h4) ? "null" : "    ");
                String h1 = "H1:" + (Objects.isNull(dto_h1) ? "null" : "    ");

                Utils.logWritelnDraft(String.format("[scapStocks] dto (%s) :  %s, %s, %s, %s, %s.",
                        Utils.appendSpace(EPIC, 10), mo, w1, d1, h4, h1));
                continue;
            }

            String trend_mo = dto_mo.getTrend_line();
            String trend_w1 = dto_w1.getTrend_line();

            String trend_d1 = dto_d1.getTrend_line();
            String trend_h4 = dto_h4.getTrend_line();
            String trend_h1 = dto_h1.getTrend_line();

            String prefix = Utils.getPrefix_FollowTrackingTrend(EPIC, index, trend_mo, trend_w1, trend_d1, "", trend_h4,
                    trend_h1, dto_mo.getSwitch_trend(), dto_w1.getSwitch_trend(), dto_d1.getSwitch_trend(), "",
                    dto_h4.getSwitch_trend(), trend_w1) + Utils.appendSpace("", 15);

            String type = Objects.equals(Utils.TREND_LONG, trend_d1) ? "B"
                    : Objects.equals(Utils.TREND_SHOT, trend_d1) ? "S" : "?";

            String eoz = " (" + type + ")EOZ:";
            eoz += (!dto_mo.isTradable_zone() && Objects.equals(trend_d1, trend_mo)) ? "MN" : "--";
            eoz += (!dto_w1.isTradable_zone() && Objects.equals(trend_d1, trend_w1)) ? "W1" : "--";
            eoz += "  ";

            boolean is_trade_zone = false;
            if (dto_w1.isTradable_zone()) {
                is_trade_zone = true;
            }

            boolean is_eq_w_d_h4_h1 = false;
            if (Objects.equals(trend_w1, trend_d1)
                    && Objects.equals(trend_d1, trend_h4)
                    && Objects.equals(dto_h4.getTrend_line(), dto_h4.getTrend_by_ma10())
                    && Objects.equals(trend_h4, trend_h1)
                    && Objects.equals(trend_h1, dto_h1.getTrend_by_ma10())) {
                is_eq_w_d_h4_h1 = true;
            }

            // TODO: scapStocks
            if (is_opening_trade(EPIC, "")) {

                index += 1;
                analysis_profit(prefix, EPIC, eoz, trend_w1);

            } else if (Objects.equals(trend_w1, trend_d1) && Objects.equals(trend_d1, trend_h4)) {
                index += 1;
                analysis_profit(prefix, EPIC, eoz, trend_w1);

                // -------------------------------------------------------

                if (((Utils.EPICS_STOCKS_EUR.contains(EPIC) && Utils.is_london_session())
                        || (Utils.EPICS_STOCKS_USA.contains(EPIC) && Utils.is_newyork_session()))

                        && is_eq_w_d_h4_h1 && is_trade_zone
                        && dto_h4.getSwitch_trend().contains(Utils.TEXT_SWITCH_TREND_Ma_1vs6810)) {
                    String key = EPIC + Utils.CAPITAL_TIME_H4;
                    String append = "96.4." + Utils.TEXT_PASS;

                    Mt5OpenTrade trade_h4 = Utils.calc_Lot_En_SL_TP(Utils.RISK_0_10_PERCENT, EPIC, trend_d1, dto_h1,
                            dto_h4, append, true, Utils.CAPITAL_TIME_H4);

                    BscScanBinanceApplication.mt5_open_trade_List.add(trade_h4);
                    BscScanBinanceApplication.dic_comment.put(key, trade_h4.getComment());
                }

                // -------------------------------------------------------
                BscScanBinanceApplication.dic_comment.put(EPIC.toUpperCase(),
                        "wdh4" + Utils.getEncryptedChartNameCapital(Utils.CAPITAL_TIME_D1));
            }
        }

    }

    /*
     * Symbol Ticket Type PriceOpen StopLoss TakeProfit Profit GER40.cash 81258050 0
     * 15895.35 16111.0 0.0 -185.77 EURCAD 81249169 0 1.46448 1.45172 0.0 -22.2
     * EURGBP 81246958 0 0.87056 0.86395 0.0 108.2
     */
    @Override
    @Transactional
    public void initTradeList() {
        List<Mt5DataTrade> tradeList = new ArrayList<Mt5DataTrade>();

        for (String company : Utils.COMPANIES) {
            String company_id = Utils.MT5_COMPANY_FTMO;
            // if (Objects.equals(company, "8CAP")) {
            // company_id = Utils.MT5_COMPANY_NEXT;
            // } else if (Objects.equals(company, "ALPHA")) {
            // company_id = Utils.MT5_COMPANY_ALPHA;
            // } else if (Objects.equals(company, "THE5ERS")) {
            // company_id = Utils.MT5_COMPANY_5ERS;
            // } else if (Objects.equals(company, "MFF")) {
            // company_id = Utils.MT5_COMPANY_MFF;
            // }

            String mt5_ftmo_trading_file_path = Utils.getMt5DataFolder(company_id) + "Trade.csv";
            String mt5_data_file = check_mt5_data_file(mt5_ftmo_trading_file_path, 3);
            if (Utils.isBlank(mt5_data_file)) {
                continue;
            }

            int row_count = 0;
            boolean has_open_trade = false;
            try {
                String line;

                Reader reader = new InputStreamReader(new FileInputStream(mt5_data_file), "UTF-8");
                BufferedReader fin = new BufferedReader(reader);
                while ((line = fin.readLine()) != null) {
                    row_count += 1;
                    if (row_count == 1) {
                        continue;
                    }
                    String[] tempArr = line.replace(".f", "").replace(".cash", "").replace(".pro", "").split("\\t");
                    if (tempArr.length == 10) {
                        Mt5DataTrade dto = new Mt5DataTrade();

                        dto.setSymbol(tempArr[0]);
                        dto.setTicket(tempArr[1].toUpperCase());
                        dto.setType(tempArr[2].toUpperCase());

                        dto.setPriceOpen(Utils.getBigDecimal(tempArr[3]));
                        dto.setStopLoss(Utils.getBigDecimal(tempArr[4]));
                        dto.setTakeProfit(Utils.getBigDecimal(tempArr[5]));

                        dto.setProfit(Utils.roundDefault(Utils.getBigDecimal(tempArr[6])));
                        dto.setComment(Utils.getStringValue(tempArr[7]).trim().toUpperCase());
                        dto.setVolume(Utils.roundDefault(Utils.getBigDecimal(tempArr[8])));
                        dto.setCurrPrice(Utils.roundDefault(Utils.getBigDecimal(tempArr[9])));
                        dto.setCompany(company);
                        tradeList.add(dto);
                        has_open_trade = true;
                    }
                }

                fin.close();
                reader.close();
            } catch (IOException e) {
                e.printStackTrace();
            }

            // Đóng các lệnh đã close
            if (has_open_trade || (row_count == 1)) {
                List<Mt5OpenTradeEntity> mt5Openlist = mt5OpenTradeRepository.findAllByCompanyOrderBySymbolAsc(company);
                for (Mt5OpenTradeEntity entity : mt5Openlist) {
                    boolean not_found = true;
                    for (Mt5DataTrade trade : tradeList) {
                        if (Objects.equals(entity.getTicket(), trade.getTicket())) {
                            not_found = false;
                            break;
                        }
                    }
                    if (not_found) {
                        mt5OpenTradeRepository.deleteById(entity.getTicket());
                    }
                }
            }
        }

        // TODO: 2. initTradeList
        for (Mt5DataTrade trade : tradeList) {
            String EPIC = trade.getSymbol();
            if (EPIC.contains("DX")) {
                // boolean debug = true;
            }
            for (String key : BscScanBinanceApplication.linked_2_ftmo.keySet()) {
                if (key.contains("_" + EPIC + "_")) {
                    EPIC = BscScanBinanceApplication.linked_2_ftmo.get(key);
                    break;
                }
            }

            String date_time = LocalDateTime.now().toString();
            String comment = Utils.getStringValue(BscScanBinanceApplication.dic_comment.get(EPIC));
            // ----------------------------------------------------------------------------------
            Orders dto_d1 = ordersRepository.findById(EPIC + "_" + Utils.CAPITAL_TIME_D1).orElse(null);
            if (Objects.isNull(dto_d1)) {
                continue;
            }
            // ----------------------------------------------------------------------------------

            Mt5OpenTradeEntity entity = mt5OpenTradeRepository.findById(trade.getTicket()).orElse(null);
            if (Objects.isNull(entity)) {
                String find_trend = (trade.getType().toUpperCase().contains(Utils.TREND_LONG)) ? Utils.TREND_LONG
                        : (trade.getType().toUpperCase().contains(Utils.TREND_SHOT)) ? Utils.TREND_SHOT : "_";

                String timeframe = Utils.getDeEncryptedChartNameCapital(comment);
                boolean same_trend_w_d = true;
                if (comment.contains("00")) {
                    same_trend_w_d = false;
                }

                List<BigDecimal> sl1_tp2 = Utils.calc_SL1_TP2(dto_d1, find_trend, same_trend_w_d);
                BigDecimal sl_d1 = sl1_tp2.get(0);
                BigDecimal tp_d1 = sl1_tp2.get(1);

                entity = new Mt5OpenTradeEntity();
                entity.setTicket(trade.getTicket());
                entity.setSymbol(EPIC);
                entity.setPriceOpen(trade.getPriceOpen());
                entity.setStopLoss(sl_d1);
                entity.setTakeProfit(tp_d1);
                entity.setComment(comment);
                entity.setTimeframe(timeframe);
            } else {
                if (Utils.getBigDecimal(trade.getStopLoss()).compareTo(BigDecimal.ZERO) > 0) {
                    entity.setStopLoss(trade.getStopLoss());
                }

                if (Utils.getBigDecimal(trade.getTakeProfit()).compareTo(BigDecimal.ZERO) > 0) {
                    entity.setTakeProfit(trade.getTakeProfit());
                }
            }
            entity.setSymbol(EPIC);
            if (Utils.isBlank(entity.getComment()) && Utils.isNotBlank(comment)) {
                entity.setComment(comment.replace(" ", ""));
            }
            entity.setProfit(trade.getProfit());
            entity.setType(trade.getType());
            entity.setVolume(trade.getVolume());
            entity.setCurrprice(trade.getCurrPrice());
            entity.setCompany(trade.getCompany());
            if (Utils.isBlank(entity.getOpenTime())) {
                entity.setOpenTime(date_time);
            }

            mt5OpenTradeRepository.save(entity);
        }
    }

    @Override
    @Transactional
    public String initForexTrend(String EPIC, String CAPITAL_TIME_XX) {
        if (required_update_bars_csv) {
            return "";
        }
        // EPIC = "GBPNZD";
        // CAPITAL_TIME_XX = Utils.CAPITAL_TIME_H4;
        // ----------------------------TREND------------------------
        // TODO: 1. initForexTrend

        if (Objects.equals(EPIC, "AUS200")) {
            boolean debug = true;
        }

        List<BtcFutures> list = getCapitalData(EPIC, CAPITAL_TIME_XX);
        List<BtcFutures> heiken_list = Utils.getHeikenList(list);
        if (CollectionUtils.isEmpty(heiken_list)) {
            return "";
        }

        // TODO: 1. initForexTrend
        String trend_line = "";
        Utils.getTrendByLineChart(list);
        String trend_by_ma10 = "";
        if (CAPITAL_TIME_XX.contains("MINUTE") || Objects.equals(CAPITAL_TIME_XX, Utils.CAPITAL_TIME_H1)) {
            trend_line = Utils.getTrendByHekenAshiList(heiken_list);
            trend_by_ma10 = Utils.isAboveMALine(heiken_list, 10) ? Utils.TREND_LONG : Utils.TREND_SHOT;
        } else {
            trend_line = Utils.getTrendByLineChart(list);
            trend_by_ma10 = Utils.isAboveMALine(list, 10) ? Utils.TREND_LONG : Utils.TREND_SHOT;
        }

        String nocation = "";
        if (heiken_list.size() >= 50) {
            if (Utils.isBelowMALine(heiken_list, 50)) {
                nocation = Utils.NOCATION_BELOW_MA50;
            } else if (Utils.isAboveMALine(heiken_list, 50)) {
                nocation = Utils.NOCATION_ABOVE_MA50;
            }

            if (Utils.isBlank(nocation)
                    && CAPITAL_TIME_XX.contains(Utils.CAPITAL_TIME_05)
                    && Utils.switchTrendByMa13_XX(heiken_list, 50).contains(trend_line)) {
                nocation = Utils.NOCATION_CUTTING_MA50;
            }
        }

        String switch_trend = "";
        if (Objects.equals(CAPITAL_TIME_XX, Utils.CAPITAL_TIME_MO)
                || Objects.equals(CAPITAL_TIME_XX, Utils.CAPITAL_TIME_W1)
                || Objects.equals(CAPITAL_TIME_XX, Utils.CAPITAL_TIME_D1)
                || Objects.equals(CAPITAL_TIME_XX, Utils.CAPITAL_TIME_H12)) {
            switch_trend += Utils.switchTrendByHeken_12(heiken_list);
            switch_trend += Utils.switchTrendByMa3_2_1(heiken_list);
            switch_trend += Utils.switchTrendByMa1_6810(list);
        }
        switch_trend += Utils.switchTrendByMa1_6810(heiken_list);

        boolean allow_trade_by_ma50 = false;
        String trend_d1 = get_trend_by_line_chart(EPIC, Utils.CAPITAL_TIME_D1);
        if (list.size() > 30) {
            if (Objects.equals(trend_d1, Utils.TREND_LONG) && Objects.equals(nocation, Utils.NOCATION_BELOW_MA50)) {
                allow_trade_by_ma50 = true;
            }
            if (Objects.equals(trend_d1, Utils.TREND_SHOT) && Objects.equals(nocation, Utils.NOCATION_ABOVE_MA50)) {
                allow_trade_by_ma50 = true;
            }
        }
        // -----------------------------DATABASE---------------------------
        String orderId = EPIC + "_" + CAPITAL_TIME_XX;
        String date_time = LocalDateTime.now().toString();
        List<BigDecimal> body = Utils.getBodyCandle(heiken_list);
        BigDecimal str_body = body.get(0);
        BigDecimal end_body = body.get(1);

        BigDecimal bread = Utils.calcAvgBread(heiken_list);
        List<BigDecimal> lohi = Utils.getLowHighCandle(heiken_list);
        BigDecimal sl_long = lohi.get(0).subtract(bread);
        BigDecimal sl_shot = lohi.get(1).add(bread);

        BigDecimal sl_at_switch_trend = Utils.getSL(EPIC, heiken_list, trend_line);
        if (Objects.equals(trend_line, Utils.TREND_LONG)) {
            sl_long = sl_at_switch_trend;
        } else if (Objects.equals(trend_line, Utils.TREND_SHOT)) {
            sl_shot = sl_at_switch_trend;
        }

        String zone = Utils.getZone(heiken_list);
        boolean tradable_zone = false;
        if (zone.contains(trend_d1)) {
            tradable_zone = true;
        }

        Orders entity = new Orders(orderId, date_time, trend_line, heiken_list.get(0).getCurrPrice(), str_body,
                end_body, sl_long, sl_shot, switch_trend, allow_trade_by_ma50, trend_by_ma10, tradable_zone);

        ordersRepository.save(entity);

        return "";
    }

    @Override
    @Transactional
    public int controlMt5(List<String> CAPITAL_LIST) {
        if (Utils.isNewsAt_19_20_21h()) {
            return 0;
        }

        if (required_update_bars_csv) {
            return 0;
        }

        int count = 0;
        for (String EPIC : CAPITAL_LIST) {
            if (BscScanBinanceApplication.EPICS_OUTPUTED_LOG.contains(EPIC)) {
                continue;
            }

            // EPIC = "BTCUSD";
            // Orders dto_mo = ordersRepository.findById(EPIC + "_" +
            // Utils.CAPITAL_TIME_MO).orElse(null);
            Orders dto_w1 = ordersRepository.findById(EPIC + "_" + Utils.CAPITAL_TIME_W1).orElse(null);
            Orders dto_d1 = ordersRepository.findById(EPIC + "_" + Utils.CAPITAL_TIME_D1).orElse(null);
            Orders dto_12 = ordersRepository.findById(EPIC + "_" + Utils.CAPITAL_TIME_H12).orElse(null);
            Orders dto_h4 = ordersRepository.findById(EPIC + "_" + Utils.CAPITAL_TIME_H4).orElse(null);
            Orders dto_h1 = ordersRepository.findById(EPIC + "_" + Utils.CAPITAL_TIME_H1).orElse(null);
            Orders dto_15 = ordersRepository.findById(EPIC + "_" + Utils.CAPITAL_TIME_15).orElse(null);
            Orders dto_05 = ordersRepository.findById(EPIC + "_" + Utils.CAPITAL_TIME_05).orElse(null);

            if (Objects.isNull(dto_w1) || Objects.isNull(dto_d1) || Objects.isNull(dto_12) || Objects.isNull(dto_h4)
                    || Objects.isNull(dto_h1) || Objects.isNull(dto_15) || Objects.isNull(dto_05)) {

                String w1 = "W1:" + (Objects.isNull(dto_w1) ? "null" : "    ");
                String d1 = "D1:" + (Objects.isNull(dto_d1) ? "null" : "    ");
                String h12 = "H12:" + (Objects.isNull(dto_12) ? "null" : "    ");
                String h4 = "H4:" + (Objects.isNull(dto_h4) ? "null" : "    ");
                String h1 = "H1:" + (Objects.isNull(dto_h1) ? "null" : "    ");

                Utils.logWritelnDraft(String.format("[controlMt5] dto (%s) :  %s, %s, %s, %s, %s.",
                        Utils.appendSpace(EPIC, 10), w1, d1, h12, h4, h1));

                continue;
            }
            if (Objects.equals(EPIC, "GBPCAD")) {
                boolean debug = true;
            }

            String trend_w1 = dto_w1.getTrend_line();
            String trend_d1 = dto_d1.getTrend_line();
            String trend_12 = dto_12.getTrend_line();

            String trend_h4 = dto_h4.getTrend_line();
            String trend_h1 = dto_h1.getTrend_line();
            String trend_15 = dto_15.getTrend_line();
            String trend_05 = dto_05.getTrend_line();
            // ---------------------------------------------------------------------------------------------
            String trend_btc = "";
            if (Utils.EPICS_CRYPTO_CFD.contains(EPIC)) {
                trend_btc = get_trend_by_line_chart("BTCUSD", Utils.CAPITAL_TIME_D1);
            }
            String log_trend = trend_d1;
            String tracking_trend = trend_w1;

            String switch_w1 = dto_w1.getSwitch_trend().trim();
            String switch_d1 = dto_d1.getSwitch_trend().trim();
            String switch_12 = dto_12.getSwitch_trend().trim();
            String switch_h4 = dto_h4.getSwitch_trend().trim();

            String type = Objects.equals(Utils.TREND_LONG, trend_w1) ? "B"
                    : Objects.equals(Utils.TREND_SHOT, trend_w1) ? "S" : "?";

            Boolean allow_trade = true;
            if (!dto_12.isTradable_zone() || !dto_h4.isTradable_zone()) {
                allow_trade = false;
            }

            String eoz = " (" + type + ")EOZ:";
            eoz += (!dto_12.isTradable_zone() && Objects.equals(trend_h4, trend_12)) ? "H12" : "---";
            eoz += !dto_h4.isTradable_zone() ? "H4" : "--";
            eoz += "  ";

            boolean is_trade_zone = true;
            if (eoz.contains("EOZ:H12H4") || eoz.contains("EOZ:---H4")) {
                is_trade_zone = false;
            }

            boolean is_eq_w_d_h12 = false;
            if (Objects.equals(trend_w1, trend_d1) && Objects.equals(trend_d1, trend_12)) {
                is_eq_w_d_h12 = true;
            }

            boolean is_eq_d_h4_h1 = false;
            if (Objects.equals(trend_d1, trend_12)
                    && Objects.equals(trend_d1, trend_h4)
                    && Objects.equals(trend_h4, trend_h1)
                    && Objects.equals(dto_h1.getTrend_line(), dto_h1.getTrend_by_ma10())) {
                is_eq_d_h4_h1 = true;
            }

            boolean is_eq_h1_15_05 = false;
            if (Objects.equals(trend_h1, trend_15) && Objects.equals(trend_h1, trend_05)) {
                is_eq_h1_15_05 = true;
            }

            boolean is_h1_allow_trade = false;
            if ((dto_h1.getSwitch_trend().contains(Utils.TEXT_SWITCH_TREND_Ma_1vs6810)
                    && dto_h1.isTradable_zone())) {
                is_h1_allow_trade = true;
            }

            boolean is_opening = false;
            if (is_opening_trade(EPIC, "")) {
                is_opening = true;
            }

            // TODO: 3. controlMt5 : Không đánh ngược trend_d1
            // Từ triệu phú thành tay trắng do đánh W & D nghịch pha nhau.
            if (allow_trade && (Utils.EPICS_FOREXS_ALL.contains(EPIC) || Utils.EPICS_CASH_CFD.contains(EPIC)
                    || Utils.EPICS_METALS.contains(EPIC)
                    || (Utils.EPICS_CRYPTO_CFD.contains(EPIC) && Objects.equals(trend_w1, trend_d1)
                            && Objects.equals(trend_d1, Utils.TREND_LONG)
                            && Objects.equals(trend_btc, Utils.TREND_LONG)))) {

                if (is_eq_w_d_h12 && is_eq_d_h4_h1 && is_eq_h1_15_05 && is_trade_zone
                        && (dto_05.isAllow_trade_by_ma50() || dto_15.isAllow_trade_by_ma50() || is_h1_allow_trade)) {

                    String key = EPIC + Utils.CAPITAL_TIME_H4;
                    String append = "96_1." + Utils.TEXT_PASS;

                    Mt5OpenTrade trade_h4 = Utils.calc_Lot_En_SL_TP(Utils.RISK_0_15_PERCENT, EPIC, trend_d1, dto_15,
                            dto_d1, append, true, Utils.CAPITAL_TIME_H4);

                    BscScanBinanceApplication.mt5_open_trade_List.add(trade_h4);
                    BscScanBinanceApplication.dic_comment.put(key, trade_h4.getComment());
                }
            }

            // ---------------------------------------------------------------------------------------------
            if (!Objects.equals(EPIC, "BTCUSD")) {
                BscScanBinanceApplication.EPICS_OUTPUTED_LOG += "_" + EPIC + "_";
            }
            // ---------------------------------------------------------------------------------------------
            if ((is_eq_w_d_h12 && is_eq_d_h4_h1) || is_opening) {
                count += 1;

                String prefix = Utils.getPrefix_FollowTrackingTrend(EPIC, count, "", trend_w1, trend_d1, trend_12,
                        trend_h4, "", "", switch_w1, switch_d1, switch_12, switch_h4, tracking_trend);

                analysis_profit(prefix, EPIC, eoz, log_trend);
            }
        }

        return count;

    }

    @Override
    public void closeTrade_by_SL_TP() {
        if (Utils.isNewsAt_19_20_21h()) {
            return;
        }
        if (BscScanBinanceApplication.mt5_open_trade_List.size() > 0) {
            Utils.logWritelnDraft("");
        }

        // ----------------------------------------PROFIT--------------------------------------
        List<Mt5OpenTradeEntity> mt5Openlist = mt5OpenTradeRepository.findAll();
        BigDecimal TOTAL_PROFIT = BigDecimal.ZERO;
        for (Mt5OpenTradeEntity trade : mt5Openlist) {
            BigDecimal PROFIT = Utils.getBigDecimal(trade.getProfit());
            TOTAL_PROFIT = TOTAL_PROFIT.add(PROFIT);
        }

        for (Mt5OpenTradeEntity trade : mt5Openlist) {
            String EPIC = trade.getSymbol();
            if (Objects.equals(EPIC, "DX.F")) {
                EPIC = "DX";
            }

            String TICKET = trade.getTicket();
            String REVERSE_TRADE_TREND = trade.getType().toUpperCase().contains(Utils.TREND_LONG) ? Utils.TREND_SHOT
                    : Utils.TREND_LONG;
            BigDecimal PROFIT = Utils.getBigDecimal(trade.getProfit());

            if (Utils.EPICS_STOCKS.contains(EPIC) && !Utils.is_newyork_session()) {
                continue;
            }

            String CAPITAL_TIME_05 = Utils.CAPITAL_TIME_05;
            String CAPITAL_TIME_15 = Utils.CAPITAL_TIME_15;
            String CAPITAL_TIME_H12 = Utils.CAPITAL_TIME_H12;
            if (Utils.EPICS_STOCKS.contains(EPIC)) {
                CAPITAL_TIME_05 = Utils.CAPITAL_TIME_H1;
                CAPITAL_TIME_15 = Utils.CAPITAL_TIME_H1;
                CAPITAL_TIME_H12 = Utils.CAPITAL_TIME_D1;
            }

            Orders dto_w1 = ordersRepository.findById(EPIC + "_" + Utils.CAPITAL_TIME_W1).orElse(null);
            Orders dto_d1 = ordersRepository.findById(EPIC + "_" + Utils.CAPITAL_TIME_D1).orElse(null);
            Orders dto_12 = ordersRepository.findById(EPIC + "_" + CAPITAL_TIME_H12).orElse(null);
            Orders dto_h4 = ordersRepository.findById(EPIC + "_" + Utils.CAPITAL_TIME_H4).orElse(null);
            Orders dto_h1 = ordersRepository.findById(EPIC + "_" + Utils.CAPITAL_TIME_H1).orElse(null);
            Orders dto_15 = ordersRepository.findById(EPIC + "_" + CAPITAL_TIME_15).orElse(null);
            Orders dto_05 = ordersRepository.findById(EPIC + "_" + CAPITAL_TIME_05).orElse(null);

            if (Objects.isNull(dto_w1) || Objects.isNull(dto_d1) || Objects.isNull(dto_12) || Objects.isNull(dto_h4)
                    || Objects.isNull(dto_h1) || Objects.isNull(dto_15) || Objects.isNull(dto_05)) {

                String w1 = "W1:" + (Objects.isNull(dto_w1) ? "null" : "    ");
                String d1 = "D1:" + (Objects.isNull(dto_d1) ? "null" : "    ");
                String h12 = "H12:" + (Objects.isNull(dto_12) ? "null" : "    ");
                String h4 = "H4:" + (Objects.isNull(dto_h4) ? "null" : "    ");
                String h1 = "H1:" + (Objects.isNull(dto_h1) ? "null" : "    ");
                String m15 = "15:" + (Objects.isNull(dto_15) ? "null" : "    ");
                String m05 = "05:" + (Objects.isNull(dto_05) ? "null" : "    ");

                Utils.logWritelnDraft(String.format("[controlMt5] dto (%s) :  %s, %s, %s, %s, %s, %s, %s.",
                        Utils.appendSpace(EPIC, 10), w1, d1, h12, h4, h1, m15, m05));

                continue;
            }

            if (Objects.equals(EPIC, "GBPNZD")) {
            }

            // ---------------------------------------------------------------------------------
            boolean has_profit = false;
            if ((PROFIT.compareTo(Utils.RISK_0_02_PERCENT) > 0) // 50$
                    && Objects.equals(dto_h1.getTrend_by_ma10(), REVERSE_TRADE_TREND)
                    && Objects.equals(dto_h1.getTrend_line(), REVERSE_TRADE_TREND)
                    && Objects.equals(dto_15.getTrend_line(), REVERSE_TRADE_TREND)
                    && Objects.equals(dto_05.getTrend_line(), REVERSE_TRADE_TREND)) {
                has_profit = true;
            }
            // ---------------------------------------------------------------------------------
            boolean is_hit_sl = false;
            if (PROFIT.add(Utils.RISK_0_10_PERCENT).compareTo(BigDecimal.ZERO) < 0) {
                is_hit_sl = true;
            }
            // ---------------------------------------------------------------------------------
            boolean is_reverse = false; // Đóng khi H4 đảo chiều theo Ma10 & giữ lệnh 12h
            if (Objects.equals(dto_h4.getTrend_by_ma10(), REVERSE_TRADE_TREND)
                    && Objects.equals(dto_h4.getTrend_line(), REVERSE_TRADE_TREND)
                    && (allow_close_trade_after(TICKET, Utils.MINUTES_OF_12H)
                            || (PROFIT.compareTo(Utils.RISK_0_02_PERCENT) > 0))) {
                is_reverse = true;
            }
            // ---------------------------------------------------------------------------------
            // TODO: 5. closeTrade_by_SL_TP
            if (allow_close_trade_after(TICKET, Utils.MINUTES_OF_4H)) {
                if (has_profit || is_hit_sl || is_reverse) {
                    String reason = "";
                    if (has_profit) {
                        reason = "4hprofit";
                    } else if (is_hit_sl) {
                        reason = "sl1r";
                    } else if (is_reverse) {
                        reason = "reverse";
                    }

                    BscScanBinanceApplication.mt5_close_ticket_dict.put(TICKET, reason);

                    // --------------------------------------------------------------------------
                    String log = Utils.createCloseTradeMsg(trade, "CloseTrade: ", reason);
                    Utils.logWritelnDraft(log);

                    String key = trade.getSymbol() + "_" + trade.getType() + trade.getTimeframe();
                    if (isReloadAfter(Utils.MINUTES_OF_1H, key)) {
                        String EVENT_ID = "CLOSE_TRADE" + Utils.getCurrentYyyyMmDd_HH() + key;
                        String msg = "(" + trade.getCompany() + ") Close:" + trade.getSymbol() + ":";
                        msg += Utils.getStringValue(trade.getProfit().intValue()) + "$:" + reason;
                        sendMsgPerHour_OnlyMe(EVENT_ID, msg);
                    }
                }
            }
        }

    }

}
// 8-10-13-17-21-26-34
// râu quét 2 đầu -> đánh khá khó chịu -> tốt nhất là biến
// Lỗi chung:
//1) Không nhìn biều đồ lớn đánh mất tổng quan.
//2) Không cắt lỗ, không quản trị vốn, cố vào biểu đồ bé cố tìm lệnh.
//3) Quan trọng nhất là khối lượng tiền lớn chứ không phải % tăng giá.
