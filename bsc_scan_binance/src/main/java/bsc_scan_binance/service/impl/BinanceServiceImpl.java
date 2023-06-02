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
import java.util.stream.Collectors;

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
import bsc_scan_binance.entity.PrepareOrders;
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
import bsc_scan_binance.response.FundingResponse;
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

    List<Mt5DataTrade> tradeList = new ArrayList<Mt5DataTrade>();

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
    private static final String EVENT_DANGER_CZ_KILL_LONG = "CZ_KILL_LONG";
    private static final String EVENT_BTC_RANGE = "BTC_RANGE";

    private static final String EVENT_PUMP = "Pump_";
    private static final String EVENT_MSG_PER_HOUR = "MSG_PER_HOUR";
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

                String trading_view = "https://vn.tradingview.com/chart/?symbol=CAPITALCOM%3A"
                        + dto.getSymbol_or_epic();
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

    @Override
    public void sendMsgPerHour(String EVENT_ID, String msg_content, boolean isOnlyMe) {
        if (!Utils.isBusinessTime_6h_to_22h()) {
            return;
        }

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
        long elapsedMinutes = Utils.MINUTES_OF_D + 1;
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
            time = Utils.MINUTES_OF_D;
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

        List<Orders> orders = ordersRepository.clearTrash();
        if (!CollectionUtils.isEmpty(orders)) {
            ordersRepository.deleteAll(orders);
        }

        List<Mt5DataCandle> candleList = mt5DataCandleRepository.findAll();
        if (!CollectionUtils.isEmpty(candleList)) {
            mt5DataCandleRepository.deleteAll(candleList);
        }

        List<PrepareOrders> prepareOrderList = prepareOrdersRepository.findAll();
        if (!CollectionUtils.isEmpty(prepareOrderList)) {
            prepareOrdersRepository.deleteAll(prepareOrderList);
        }

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
            List<BtcFutures> list) {
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

        Orders entity = new Orders(orderId, date_time, trend, list.get(0).getCurrPrice(), body.get(0), body.get(1),
                low_high.get(0), low_high.get(1), Utils.appendSpace(note, 50));

        ordersRepository.save(entity);
    }

    private void outputLog(String prefix_id, String EPIC, Orders dto_entry, Orders dto_sl, String append,
            String find_trend) {
        if (Objects.isNull(dto_entry) || Objects.isNull(dto_sl)) {
            return;
        }

        String zone = "";
        String text_body = "";

        List<BtcFutures> list_h12 = getCapitalData(EPIC, Utils.CAPITAL_TIME_H12);
        if (CollectionUtils.isEmpty(list_h12)) {
            list_h12 = getCapitalData(EPIC, Utils.CAPITAL_TIME_D1);
        }

        if (!CollectionUtils.isEmpty(list_h12)) {
            List<BtcFutures> heken_list_h12 = Utils.getHekenList(list_h12);
            text_body = Utils.textBodyArea(heken_list_h12);
            zone = "ZoneH12: " + Utils.getZoneTrend(heken_list_h12);
        }

        String text_waiting = "";
        List<PrepareOrders> prepareOrdes = prepareOrdersRepository.findAll();
        if (!CollectionUtils.isEmpty(prepareOrdes)) {
            for (PrepareOrders entity : prepareOrdes) {
                if (entity.getEpic_and_capital_timeframe().contains(EPIC)) {
                    text_waiting = Utils.TEXT_WAITING_ + entity.getTrade_type().toLowerCase();
                }
            }
        }
        text_waiting = Utils.appendSpace(text_waiting, 20);

        String log = Utils.getTypeOfEpic(EPIC) + Utils.appendSpace(EPIC, 8);
        log += Utils.appendSpace(Utils.removeLastZero(Utils.formatPrice(dto_entry.getCurrent_price(), 5)), 11);
        log += append + " " + zone + text_waiting;
        log += Utils.appendSpace(Utils.getCapitalLink(EPIC), 62) + " ";
        log += Utils.calc_BUF_LO_HI_BUF_Forex(false, find_trend, EPIC, dto_entry, dto_sl);
        log += "   " + text_body;

        Utils.logWritelnDraft(log);
    }

    private String getTrendTimeframes(String EPIC) {
        String result = "";// "(W1:Buy ,D1:Buy ,H12:Buy ,H8:Buy ,H4:Buy ,H2:Sell,30:Buy )";
        List<String> times = Arrays.asList(Utils.CAPITAL_TIME_W1, Utils.CAPITAL_TIME_D1, Utils.CAPITAL_TIME_H12,
                Utils.CAPITAL_TIME_H4, Utils.CAPITAL_TIME_H1, Utils.CAPITAL_TIME_05);

        for (String CAPITAL_TIME_XX : times) {
            String chart_name = Utils.getChartNameCapital(CAPITAL_TIME_XX).replace("(", "").replace(")", "").trim();
            Orders dto = ordersRepository.findById(EPIC + "_" + CAPITAL_TIME_XX).orElse(null);
            if (Objects.isNull(dto)) {
                continue;
            }

            if (Utils.isNotBlank(result))
                result += ",";

            result += chart_name + ":";
            result += Objects.equals(dto.getTrend(), Utils.TREND_LONG) ? "Buy " : "Sell";
        }
        result = Utils.appendSpace("(" + result + ")", 30);

        return result;
    }

    private String getSideMa50(String EPIC, boolean isCompact) {
        String result = "";// "H12:b H8:b H4:a H2:a 30:a"
        List<String> times = Arrays.asList(Utils.CAPITAL_TIME_H12, Utils.CAPITAL_TIME_H4, Utils.CAPITAL_TIME_H1,
                Utils.CAPITAL_TIME_05);

        for (String CAPITAL_TIME_XX : times) {
            String chart_name = Utils.getChartNameCapital(CAPITAL_TIME_XX).replace("(", "").replace(")", "").trim();
            List<BtcFutures> list = getCapitalData(EPIC, CAPITAL_TIME_XX);
            List<BtcFutures> heken_list = Utils.getHekenList(list);

            if (Utils.isNotBlank(result))
                result += " ";

            result += chart_name + ":";
            result += Utils.isAboveMALine(heken_list, 50) ? "a" : Utils.isBelowMALine(heken_list, 50) ? "b" : " ";
        }

        result = Utils.appendSpace(result, 30);

        return result;
    }

    private String analysis(String prifix, String EPIC, String CAPITAL_TIME_XX) {
        if (Utils.isBlank(CAPITAL_TIME_XX)) {
            return "";
        }
        Orders dto = ordersRepository.findById(EPIC + "_" + CAPITAL_TIME_XX).orElse(null);
        if (Objects.isNull(dto)) {
            return "";
        }

        Orders dto_en = ordersRepository.findById(EPIC + "_" + Utils.CAPITAL_TIME_H1).orElse(dto);
        Orders dto_sl = ordersRepository.findById(EPIC + "_" + Utils.CAPITAL_TIME_H12).orElse(dto);

        if (Objects.isNull(dto_en) || Objects.isNull(dto_sl)) {
            return "";
        }

        // ----------------------------TREND------------------------
        String trend = dto.getTrend();
        String char_name = Utils.getChartName(dto.getId());
        String type = Objects.equals(Utils.TREND_LONG, trend) ? "(B)"
                : Objects.equals(Utils.TREND_SHOT, trend) ? "(S)" : "(x)";

        String note = dto.getNote();

        int length = 40;
        String ea = Utils.appendSpace(Utils.TEXT_EXPERT_ADVISOR_SPACE, length);

        List<Mt5DataTrade> filteredStream = tradeList.stream().filter(obj -> Objects.equals(EPIC, obj.getSymbol()))
                .collect(Collectors.toList());

        if (!CollectionUtils.isEmpty(filteredStream)) {
            for (Mt5DataTrade trade : filteredStream) {
                Mt5OpenTradeEntity entity = mt5OpenTradeRepository.findById(trade.getTicket()).orElse(null);

                ea = Utils.appendSpace(trade.getType().toLowerCase(), 12);
                if (Objects.nonNull(entity)) {
                    ea += " SL:" + Utils.appendSpace(Utils.removeLastZero(entity.getStopLossTimeFam()), 12);
                    ea += Utils.appendSpace(entity.getComment(), 20);
                }
                ea = Utils.appendSpace(ea, length);

                String append = Utils.appendSpace(prifix + ea, 115) + Utils.appendSpace(note, 45);

                outputLog("Analysis_" + char_name, EPIC, dto_en, dto_sl, append, dto.getTrend());
            }
        } else {
            ea = Utils.appendSpace(Utils.TEXT_EXPERT_ADVISOR_SPACE, length);
            String append = Utils.appendSpace(prifix + ea, 115) + Utils.appendSpace(note, 45);
            outputLog("Analysis_" + char_name, EPIC, dto_en, dto_sl, append, dto.getTrend());
        }

        if (!isReloadAfter(Utils.MINUTES_OF_1H, EPIC + trend)) {
            return "";
        }

        return type + EPIC;
    }

    @Override
    @Transactional
    public String sendMsgKillLongShort(String SYMBOL) {
        List<BtcFutures> list = Utils.loadData(SYMBOL, Utils.CRYPTO_TIME_D1, 15);
        if (CollectionUtils.isEmpty(list)) {
            return Utils.CRYPTO_TIME_H1;
        }

        List<BtcFutures> heken_list = Utils.getHekenList(list);
        String trend = Utils.getTrendByHekenAshiList(heken_list);
        String switch_trend = Utils.switchTrendByHeken_12(heken_list);

        if (Utils.isNotBlank(switch_trend)) {
            // TODO: sendMsgKillLongShort
            String msg = "";
            boolean isOnlyMe = true;
            if (BTC_ETH_BNB.contains(SYMBOL)) {
                isOnlyMe = false;
            }

            if (Objects.equals(Utils.TREND_LONG, trend)) {
                msg = " 💹 (D1)" + SYMBOL + "_kill_Short 💔 ";
            }
            if (Objects.equals(Utils.TREND_SHOT, trend)) {
                msg = " 🔻 (D1)" + SYMBOL + "_kill_Long 💔 ";
            }
            msg += "(" + Utils.appendSpace(Utils.removeLastZero(list.get(0).getCurrPrice()), 5) + ")";

            String EVENT_ID = "MSG_PER_HOUR" + SYMBOL + Utils.getCurrentYyyyMmDd_Blog4h();
            sendMsgPerHour(EVENT_ID, msg, isOnlyMe);
        }

        return Utils.CRYPTO_TIME_H1;
    }

    @Override
    public void openTrade() {
        if (!Utils.isHuntTime_7h_to_22h()) {
            return;
        }

        String mt5_open_trade_file = Utils.getMt5DataFolder() + "OpenTrade.csv";

        List<String> mt5_close_trade_list = new ArrayList<String>();

        try {
            FileWriter writer = new FileWriter(mt5_open_trade_file, true);
            for (Mt5OpenTrade dto : BscScanBinanceApplication.mt5_open_trade_List) {
                String open_type = dto.getOrder_type();

                if (!open_type.contains(Utils.TEXT_LIMIT)) {
                    for (Mt5DataTrade trade : tradeList) {
                        String trade_epic = trade.getSymbol();
                        String trade_type = trade.getType();

                        String open_epic = dto.getEpic();

                        if (Objects.equals(trade_epic, trade_type) && !Objects.equals(open_epic, open_type)) {
                            mt5_close_trade_list.add(trade.getTicket());
                        }
                    }
                }

                StringBuilder sb = new StringBuilder();
                sb.append(dto.getEpic());
                sb.append('\t');
                sb.append(dto.getOrder_type());
                sb.append('\t');
                sb.append(dto.getLots());
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

                String msg = "mt5OpenTrade: " + Utils.appendSpace(dto.getOrder_type(), 15)
                        + Utils.appendSpace(dto.getEpic(), 10) + " comment: " + Utils.appendSpace(dto.getComment(), 25);
                System.out.println(msg);
                Utils.logWritelnDraft(msg);
            }
            writer.close();
        } catch (Exception e) {
            System.out.println(e.getMessage());
        }

        mt5CloseTrade(mt5_close_trade_list);
    }

    private void mt5CloseTrade(List<String> ticketList) {
        String mt5_data_file = Utils.getMt5DataFolder() + "CloseSymbols.csv";

        try {
            FileWriter writer = new FileWriter(mt5_data_file, true);

            for (String TICKET : ticketList) {
                StringBuilder sb = new StringBuilder();
                sb.append(TICKET);
                sb.append('\n');
                writer.write(sb.toString());

                for (Mt5DataTrade trade : tradeList) {
                    if (Objects.equals(TICKET, trade.getTicket())) {

                        String text = "mt5CloseSymbol: " + Utils.appendSpace(TICKET, 15)
                                + Utils.appendSpace(trade.getType(), 15) + Utils.appendSpace(trade.getSymbol(), 10)
                                + Utils.appendLeft(trade.getProfit().toString(), 10);

                        System.out.println(text);
                        Utils.logWritelnDraft(text);
                    }
                }
            }

            writer.close();
        } catch (Exception e) {
            System.out.println(e.getMessage());
        }
    }

    private String mt5_data_file(String filename, Integer MINUTES_OF_XX) {
        String mt5_data_file = "";
        try {
            mt5_data_file = Utils.getMt5DataFolder() + filename;

            File file = new File(mt5_data_file);
            if (!file.exists()) {
                Utils.logWritelnDraft("[mt5_data_file FileNotFound]: " + mt5_data_file);
                return "";
            }

            BasicFileAttributes attr = Files.readAttributes(file.toPath(), BasicFileAttributes.class);
            LocalDateTime created_time = attr.lastModifiedTime().toInstant().atZone(ZoneId.systemDefault())
                    .toLocalDateTime();
            long elapsedMinutes = Duration.between(created_time, LocalDateTime.now()).toMinutes();
            required_update_bars_csv = false;
            if (elapsedMinutes > (MINUTES_OF_XX * 3)) {
                required_update_bars_csv = true;
                Utils.logWritelnDraft(filename + " khong duoc update! " + filename + " khong duoc update! " + filename
                        + " khong duoc update! " + filename + " khong duoc update! \n");

                String EVENT_ID = EVENT_PUMP + "_UPDATE_BARS_CSV_" + Utils.getCurrentYyyyMmDd_HH();
                sendMsgPerHour(EVENT_ID, "Update:" + filename, true);
                return "";
            }
        } catch (Exception e) {
        }

        return mt5_data_file;
    }

    @Override
    @Transactional
    public void saveMt5Data(String filename, Integer MINUTES_OF_XX) {
        try {
            String mt5_data_file = mt5_data_file(filename, MINUTES_OF_XX);
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

                String[] tempArr = line.replace(".cash", "").split("\\t");
                if (tempArr.length == 7) {
                    Mt5DataCandle dto = new Mt5DataCandle(new Mt5DataCandleKey(tempArr[0], tempArr[1], tempArr[2]),
                            Utils.getBigDecimal(tempArr[3]), Utils.getBigDecimal(tempArr[4]),
                            Utils.getBigDecimal(tempArr[5]), Utils.getBigDecimal(tempArr[6]), Utils.getYYYYMMDD(0));
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
                List<Mt5DataCandle> temp = mt5DataCandleRepository.findAllByIdEpicAndIdCandleOrderByIdCandleTimeDesc(
                        dto.getId().getEpic(), dto.getId().getCandle());

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

            if (tradeList.isEmpty() || Objects.equals("Forex.csv", filename)) {
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
            boolean uptrend = (dto.getOpe_price().compareTo(dto.getClo_price()) < 0) ? true : false;

            String strid = Utils.getStringValue(id);
            if (strid.length() < 2) {
                strid = "0" + strid;
            }
            strid = dto.getId().getEpic() + Utils.getChartNameCapital_(dto.getId().getCandle()) + strid;
            BigDecimal currPrice = dto.getOpe_price().add(dto.getClo_price()).add(dto.getLow_price())
                    .add(dto.getHig_price());
            currPrice = currPrice.divide(BigDecimal.valueOf(4), 10, RoundingMode.CEILING);

            BtcFutures entity = new BtcFutures(strid, currPrice, dto.getLow_price(), dto.getHig_price(),
                    dto.getOpe_price(), dto.getClo_price(), BigDecimal.ZERO, BigDecimal.ZERO, BigDecimal.ZERO,
                    BigDecimal.ZERO, uptrend);
            list.add(entity);

            id += 1;
        }

        return list;
    }

    @SuppressWarnings("unused")
    @Override
    public void createReport() {
        if (required_update_bars_csv) {
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

                Orders dto_w1 = ordersRepository.findById(EPIC + "_" + Utils.CAPITAL_TIME_W1).orElse(null);
                Orders dto_h12 = ordersRepository.findById(EPIC + "_" + Utils.CAPITAL_TIME_H12).orElse(null);
                Orders dto_h4 = ordersRepository.findById(EPIC + "_" + Utils.CAPITAL_TIME_H4).orElse(null);
                Orders dto_h1 = ordersRepository.findById(EPIC + "_" + Utils.CAPITAL_TIME_H1).orElse(null);
                Orders dto_05 = ordersRepository.findById(EPIC + "_" + Utils.CAPITAL_TIME_05).orElse(null);

                if (Objects.isNull(dto_w1) || Objects.isNull(dto_d1) || Objects.isNull(dto_h12)
                        || Objects.isNull(dto_h4) || Objects.isNull(dto_h1) || Objects.isNull(dto_05)) {
                    continue;
                }

                String trend_w1 = dto_w1.getTrend();
                String trend_d1 = dto_d1.getTrend();
                String trend_h12 = dto_h12.getTrend();
                String trend_h4 = dto_h4.getTrend();
                String trend_h2 = dto_h1.getTrend();
                String trend_30 = dto_05.getTrend();

                String note_w1 = dto_w1.getNote();
                String note_d1 = dto_d1.getNote();
                String note_h12 = dto_h12.getNote();
                String note_h4 = dto_h4.getNote();
                String note_h1 = dto_h1.getNote();
                String note_05 = dto_05.getNote();

                String tracking_trend = trend_w1;

                String CAPITAL_TIME_XX = Utils.getTimeframe_SwitchTrend(note_d1, note_h12, note_h4);

                String zone_h12 = "";
                String zone_h4 = "";
                String zone_h1 = "";
                {
                    List<BtcFutures> list_h12 = getCapitalData(EPIC, Utils.CAPITAL_TIME_H12);
                    List<BtcFutures> list_h4 = getCapitalData(EPIC, Utils.CAPITAL_TIME_H4);
                    List<BtcFutures> list_h1 = getCapitalData(EPIC, Utils.CAPITAL_TIME_H1);
                    if (CollectionUtils.isEmpty(list_h12) || CollectionUtils.isEmpty(list_h4)
                            || CollectionUtils.isEmpty(list_h1)) {
                        continue;
                    }
                    List<BtcFutures> heken_list_h12 = Utils.getHekenList(list_h12);
                    List<BtcFutures> heken_list_h4 = Utils.getHekenList(list_h4);
                    List<BtcFutures> heken_list_h1 = Utils.getHekenList(list_h1);

                    zone_h12 = Utils.getZoneTrend(heken_list_h12);
                    zone_h4 = Utils.getZoneTrend(heken_list_h4);
                    zone_h1 = Utils.getZoneTrend(heken_list_h1);
                }

                String prefix = Utils.getPrefix_FollowTrackingTrend(index, trend_w1, trend_d1, trend_h12, trend_h4,
                        trend_h2, trend_30, note_w1, note_d1, note_h12, note_h4, note_h1, note_05, tracking_trend,
                        zone_h12, zone_h4, zone_h1);

                Orders dto_xx = ordersRepository.findById(EPIC + "_" + CAPITAL_TIME_XX).orElse(dto_w1);

                String append = Utils
                        .appendSpace(prefix + Utils.appendSpace(dto_xx.getNote(), 45) + getSideMa50(EPIC, true), 150);

                String log = Utils.createLineForex_Header(dto_d1, dto_d1, append);
                log += Utils.appendSpace(Utils.removeLastZero(dto_d1.getCurrent_price()), 15);
                log += Utils.createLineForex_Body(dto_d1, dto_d1, trend_w1, true).trim();

                list_d1_log.add(log);
                index += 1;
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

                if (pre_trend.contains(Utils.TREND_LONG) && dto.getTrend().contains(Utils.TREND_SHOT)) {
                    list_crypto_log.add("");
                }

                if (Objects.nonNull(dto) && Utils.isNotBlank(dto.getNote())) {
                    String log = Utils.createLineCrypto(dto, symbol, type);
                    list_crypto_log.add(log);
                }

                pre_trend = dto.getTrend();
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

            if (!fundingHistoryRepository.existsPumDump(EVENT_MSG_PER_HOUR, EVENT_ID)) {
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

        if (!WATCHLIST.contains(SYMBOL)) {
            deleteOrders("CRYPTO_" + SYMBOL + "_1w");
            deleteOrders("CRYPTO_" + SYMBOL + "_1d");
            deleteOrders("CRYPTO_" + SYMBOL + "_12h");
            deleteOrders("CRYPTO_" + SYMBOL + "_4h");

            return Utils.CRYPTO_TIME_H4;
        }

        String orderId_d1 = "CRYPTO_" + SYMBOL + "_1d";
        // ------------------------------------------------------------------
        String EVENT_ID = "MSG_PER_HOUR" + SYMBOL + Utils.getCurrentYyyyMmDd_Blog2h();

        List<BtcFutures> list = Utils.loadData(SYMBOL, Utils.CRYPTO_TIME_D1, 15);
        if (CollectionUtils.isEmpty(list)) {
            return Utils.CRYPTO_TIME_H1;
        }
        List<BtcFutures> heken_list = Utils.getHekenList(list);

        String trend = Utils.getTrendByHekenAshiList(heken_list);
        String switch_trend = Utils.switchTrendByHeken_12(heken_list);

        if (Utils.isNotBlank(switch_trend)) {
            createOrders(SYMBOL, orderId_d1, switch_trend, switch_trend, heken_list);

            if (Objects.equals(Utils.TREND_LONG, SYMBOL)) {
                String temp = Utils.getTimeHHmm() + "   " + switch_trend + "   " + Utils.appendSpace(SYMBOL, 10);
                temp += "(D1)" + Utils.appendSpace(trend, 10) + Utils.getCryptoLink_Spot(SYMBOL);
                System.out.println(temp);
            }
        } else {
            deleteOrders(orderId_d1);
        }

        // ------------------------------------------------------------------
        // TODO: initCryptoTrend
        // ------------------------------------------------------------------
        String findTrend = "";
        if (CRYPTO_LIST_BUYING.contains(SYMBOL)) {
            findTrend = Utils.TREND_LONG;
        }
        if (CRYPTO_LIST_SELING.contains(SYMBOL)) {
            findTrend = Utils.TREND_SHOT;
        }

        if (Utils.isNotBlank(findTrend) && !Objects.equals(findTrend, trend)) {
            String msg_d1 = " 🔻 (STOP_BUY)";
            String str_price = "(" + Utils.appendSpace(Utils.removeLastZero(list.get(0).getCurrPrice()), 5) + ")";
            String log = Utils.appendSpace(Utils.getCryptoLink_Spot(SYMBOL), 70) + Utils.appendSpace(str_price, 15);

            msg_d1 += Utils.appendSpace(SYMBOL, 10) + Utils.appendSpace(str_price, 10);
            msg_d1 += ".D1:" + Utils.appendSpace(trend, 5);

            sendMsgPerHour(EVENT_ID, msg_d1, true);
            logMsgPerHour(EVENT_ID, msg_d1 + log, Utils.MINUTES_OF_1H);
        }

        return Utils.CRYPTO_TIME_H1;
    }

    @Override
    @Transactional
    public void scapStocks() {
        if (required_update_bars_csv) {
            return;
        }
        if (!Utils.isNewYorkSession()) {
            return;
        }
        int index = 1;
        // TODO: scapStocks

        for (String EPIC : Utils.EPICS_STOCKS) {
            Orders dto_w1 = ordersRepository.findById(EPIC + "_" + Utils.CAPITAL_TIME_W1).orElse(null);
            Orders dto_d1 = ordersRepository.findById(EPIC + "_" + Utils.CAPITAL_TIME_D1).orElse(null);

            if (Objects.isNull(dto_w1) || Objects.isNull(dto_d1)) {
                Utils.logWritelnDraft("[scapStocks] (" + EPIC + ") is empty or null.");
                continue;
            }

            String trend_w1 = dto_w1.getTrend();
            String trend_d1 = dto_d1.getTrend();

            String switch_trend = "." + Utils.appendSpace(trend_w1, 4) + " [W1.D1                 ]     ";

            String prefix = Utils.appendLeft(String.valueOf(index), 2) + switch_trend;
            if (Utils.isNotBlank(dto_w1.getNote())) {
                if (!Objects.equals(trend_w1, trend_w1)) {
                    prefix = prefix.replace("W1", "  ");
                }
                if (!Objects.equals(trend_d1, trend_w1)) {
                    prefix = prefix.replace("D1", "  ");
                }

                analysis(prefix, EPIC, Utils.CAPITAL_TIME_W1);
                index += 1;
            }
        }

        Utils.logWritelnDraft("");

        index = 1;
        for (String EPIC : Utils.EPICS_STOCKS) {
            List<BtcFutures> list_50d = getCapitalData(EPIC, Utils.CAPITAL_TIME_H1);
            Orders dto_w1 = ordersRepository.findById(EPIC + "_" + Utils.CAPITAL_TIME_W1).orElse(null);
            Orders dto_d1 = ordersRepository.findById(EPIC + "_" + Utils.CAPITAL_TIME_D1).orElse(null);

            Orders dto_h4 = ordersRepository.findById(EPIC + "_" + Utils.CAPITAL_TIME_H4).orElse(null);
            Orders dto_h1 = ordersRepository.findById(EPIC + "_" + Utils.CAPITAL_TIME_H1).orElse(null);
            Orders dto_15 = ordersRepository.findById(EPIC + "_" + Utils.CAPITAL_TIME_15).orElse(null);

            if (Objects.isNull(dto_w1) || Objects.isNull(dto_d1) || Objects.isNull(dto_h4) || Objects.isNull(dto_h1)
                    || Objects.isNull(dto_15)
                    || CollectionUtils.isEmpty(list_50d)) {
                Utils.logWritelnDraft("[scapStocks] (" + EPIC + ") is empty or null.");
                continue;
            }

            List<BtcFutures> heken_list = Utils.getHekenList(list_50d);

            String trend_month = Utils.getTrendByMaXx(heken_list, 50);
            String trend_w1 = dto_w1.getTrend();
            String trend_d1 = dto_d1.getTrend();
            String trend_h4 = dto_h4.getTrend();
            String trend_h1 = dto_h1.getTrend();
            String trend_15 = dto_15.getTrend();

            String switch_trend = "." + Utils.appendSpace(trend_w1, 4) + " [M1.W1.D1.H1           ]     ";
            String prefix = Utils.appendLeft(String.valueOf(index), 2) + switch_trend;
            if (!Objects.equals(trend_month, trend_d1)) {
                prefix = prefix.replace("M1", "  ");
            }
            if (!Objects.equals(trend_w1, trend_d1)) {
                prefix = prefix.replace("W1", "  ");
            }
            if (!Objects.equals(trend_h1, trend_d1)) {
                prefix = prefix.replace("H1", "  ");
            }

            if (Objects.equals(trend_w1, trend_d1) && Utils.isNotBlank(dto_d1.getNote())) {
                analysis(prefix, EPIC, Utils.CAPITAL_TIME_D1);
                index += 1;
            } else if (Objects.equals(trend_d1, trend_h1) && Utils.isNotBlank(dto_h1.getNote())) {
                analysis(prefix, EPIC, Utils.CAPITAL_TIME_H1);
                index += 1;
            }

            String w1d1h4h1 = Utils.getTrendPrefix("m", trend_month, " ");
            w1d1h4h1 += Utils.getTrendPrefix("w", trend_w1, " ");
            w1d1h4h1 += Utils.getTrendPrefix("d", trend_d1, " ");
            w1d1h4h1 += Utils.getTrendPrefix("4", trend_h4, " ");
            w1d1h4h1 += Utils.getTrendPrefix("1", trend_h1, " ") + ".";
            w1d1h4h1 = w1d1h4h1.replace(" ", "");

            if (Objects.equals(trend_w1, trend_d1)
                    && Objects.equals(trend_d1, trend_h4) && Objects.equals(trend_h4, trend_h1)
                    && Objects.equals(trend_h1, trend_15)) {

                if (dto_15.getNote().contains(trend_d1)) {
                    Mt5OpenTrade dto = Utils.calc_Lot_En_SL_TP(EPIC, trend_w1, dto_15, dto_d1,
                            Utils.CAPITAL_TIME_D1, w1d1h4h1, true);
                    BscScanBinanceApplication.mt5_open_trade_List.add(dto);
                }
            }

            {
                boolean isBreadLongArea = false;
                boolean isBreadShotArea = false;

                List<BtcFutures> list_h1 = getCapitalData(EPIC, Utils.CAPITAL_TIME_H1);
                List<BtcFutures> list_h4 = getCapitalData(EPIC, Utils.CAPITAL_TIME_H4);
                List<BtcFutures> list_d1 = getCapitalData(EPIC, Utils.CAPITAL_TIME_D1);

                if (CollectionUtils.isEmpty(list_d1) || CollectionUtils.isEmpty(list_h4)
                        || CollectionUtils.isEmpty(list_h1)) {
                    continue;
                }

                List<BtcFutures> heken_list_h1 = Utils.getHekenList(list_h1);
                List<BtcFutures> heken_list_h4 = Utils.getHekenList(list_h4);
                List<BtcFutures> heken_list_d1 = Utils.getHekenList(list_d1);

                BigDecimal cur_price = list_h1.get(0).getCurrPrice();
                List<BigDecimal> lohi_h1 = Utils.getLowHighCandle(heken_list_h1);
                List<BigDecimal> lohi_h4 = Utils.getLowHighCandle(heken_list_h4);
                List<BigDecimal> lohi_d1 = Utils.getLowHighCandle(heken_list_d1);

                if ((cur_price.compareTo(lohi_h1.get(0)) < 0) && (cur_price.compareTo(lohi_h4.get(0)) < 0)
                        && (cur_price.compareTo(lohi_d1.get(0)) < 0)) {
                    isBreadLongArea = true;
                }

                if ((cur_price.compareTo(lohi_h1.get(1)) > 0) && (cur_price.compareTo(lohi_h4.get(1)) > 0)
                        && (cur_price.compareTo(lohi_d1.get(1)) > 0)) {
                    isBreadShotArea = true;
                }

                if (isBreadLongArea || isBreadShotArea) {
                    if (isBreadLongArea && Objects.equals(trend_15, Utils.TREND_LONG)) {
                        Mt5OpenTrade dto = Utils.calc_Lot_En_SL_TP(EPIC, Utils.TREND_LONG, dto_15, dto_d1,
                                Utils.CAPITAL_TIME_15,
                                w1d1h4h1 + "12405b", true);

                        BscScanBinanceApplication.mt5_open_trade_List.add(dto);
                    }

                    if (isBreadShotArea && Objects.equals(trend_15, Utils.TREND_SHOT)) {
                        Mt5OpenTrade dto = Utils.calc_Lot_En_SL_TP(EPIC, Utils.TREND_SHOT, dto_15, dto_d1,
                                Utils.CAPITAL_TIME_15,
                                w1d1h4h1 + "12405s", true);
                        BscScanBinanceApplication.mt5_open_trade_List.add(dto);
                    }
                }
            }

        }

    }

    /*
     * Symbol Ticket Type PriceOpen StopLoss TakeProfit Profit GER40.cash 81258050 0
     * 15895.35 16111.0 0.0 -185.77 EURCAD 81249169 0 1.46448 1.45172 0.0 -22.2
     * EURGBP 81246958 0 0.87056 0.86395 0.0 108.2
     */
    @Transactional
    public void initTradeList() {
        tradeList = new ArrayList<Mt5DataTrade>();
        String mt5_data_file = mt5_data_file("Trade.csv", 3);
        if (Utils.isBlank(mt5_data_file)) {
            return;
        }

        try {
            String line;
            int count = 0;
            Reader reader = new InputStreamReader(new FileInputStream(mt5_data_file), "UTF-8");
            BufferedReader fin = new BufferedReader(reader);
            while ((line = fin.readLine()) != null) {
                count += 1;

                if (count == 1) {
                    continue;
                }
                String[] tempArr = line.replace(".cash", "").split("\\t");
                if (tempArr.length == 10) {
                    Mt5DataTrade dto = new Mt5DataTrade();

                    dto.setSymbol(tempArr[0].toUpperCase());
                    dto.setTicket(tempArr[1].toUpperCase());
                    dto.setType(tempArr[2].toUpperCase());

                    dto.setPriceOpen(Utils.getBigDecimal(tempArr[3]));
                    dto.setStopLoss(Utils.getBigDecimal(tempArr[4]));
                    dto.setTakeProfit(Utils.getBigDecimal(tempArr[5]));

                    dto.setProfit(Utils.roundDefault(Utils.getBigDecimal(tempArr[6])));
                    dto.setComment(Utils.getStringValue(tempArr[7]).trim().toUpperCase());
                    dto.setVolume(Utils.roundDefault(Utils.getBigDecimal(tempArr[8])));
                    dto.setCurrprice(Utils.roundDefault(Utils.getBigDecimal(tempArr[9])));
                    tradeList.add(dto);
                }
            }

            fin.close();
            reader.close();
        } catch (IOException e) {
            e.printStackTrace();
        }

        // TODO: 2. initTradeList
        for (Mt5DataTrade trade : tradeList) {
            String comment = Utils.getStringValue(trade.getComment());
            if (Utils.isBlank(comment)) {
                comment = Utils.getEncryptedChartNameCapital(Utils.CAPITAL_TIME_H1);
            }
            comment = comment.toLowerCase();

            String timeframe = Utils.getDeEncryptedChartNameCapital(comment);

            String EPIC = trade.getSymbol().toUpperCase();
            // ----------------------------------------------------------------------------------
            // upgrade timeframe H12
            if (!Objects.equals(timeframe, Utils.CAPITAL_TIME_H12)) {
                List<BtcFutures> list_h12 = getCapitalData(EPIC, Utils.CAPITAL_TIME_H12);
                Orders dto_d1 = ordersRepository.findById(EPIC + "_" + Utils.CAPITAL_TIME_D1).orElse(null);
                Orders dto_h4 = ordersRepository.findById(EPIC + "_" + Utils.CAPITAL_TIME_H4).orElse(null);
                Orders dto_h12 = ordersRepository.findById(EPIC + "_" + Utils.CAPITAL_TIME_H12).orElse(null);

                if (Objects.isNull(dto_d1) || Objects.isNull(dto_h12) || Objects.isNull(dto_h4)
                        || CollectionUtils.isEmpty(list_h12)) {
                } else {
                    String trend_d1 = dto_d1.getTrend();
                    String trend_h12 = dto_h12.getTrend();

                    // H12 đảo chiều cùng D1
                    if (Objects.equals(trend_d1, trend_h12) && dto_h12.getNote().contains(trend_h12)) {
                        timeframe = Utils.CAPITAL_TIME_H12;
                        comment += "->H12";
                    }
                }
            }

            Mt5OpenTradeEntity entity = mt5OpenTradeRepository.findById(trade.getTicket()).orElse(null);
            if (Objects.isNull(entity)) {

                // Dừng trade khi H1_1 đóng nến tại LoHi + Bread1-5 của H1.
                Orders dto_TimeFam = ordersRepository.findById(EPIC + "_" + Utils.CAPITAL_TIME_H1).orElse(null);
                Orders dto_CalcVol = ordersRepository.findById(EPIC + "_" + Utils.CAPITAL_TIME_D1).orElse(null);

                if (Objects.isNull(dto_TimeFam) || Objects.isNull(dto_CalcVol)) {
                    continue;
                }
                entity = new Mt5OpenTradeEntity();

                String trend = "";
                BigDecimal TP = BigDecimal.ZERO;
                if (trade.getType().contains(Utils.TREND_LONG)) {
                    trend = Utils.TREND_LONG;
                    TP = Utils.calcFiboTP_1R(trend, dto_TimeFam.getLow_price(), trade.getCurrprice());
                }
                if (trade.getType().contains(Utils.TREND_SHOT)) {
                    trend = Utils.TREND_SHOT;
                    TP = Utils.calcFiboTP_1R(trend, dto_TimeFam.getHigh_price(), trade.getCurrprice());
                }

                BigDecimal sl_TimeFam = BigDecimal.ZERO;
                BigDecimal sl_CalcVol = BigDecimal.ZERO;

                if (trade.getType().toUpperCase().contains(Utils.TREND_LONG)) {
                    // Giá đóng cửa Candle1 dưới: Giá thấp nhất của 10 cây nến
                    sl_TimeFam = dto_TimeFam.getLow_price();
                    sl_CalcVol = dto_CalcVol.getLow_price();
                }
                if (trade.getType().toUpperCase().contains(Utils.TREND_SHOT)) {
                    sl_TimeFam = dto_TimeFam.getHigh_price();
                    sl_CalcVol = dto_CalcVol.getHigh_price();
                }

                entity.setTicket(trade.getTicket());
                entity.setSymbol(trade.getSymbol());

                entity.setPriceOpen(trade.getPriceOpen());
                entity.setStopLossTimeFam(sl_TimeFam);
                entity.setStopLossCalcVol(sl_CalcVol);
                entity.setTakeProfit(TP);
            }

            entity.setComment(comment);
            entity.setTimeframe(timeframe);
            entity.setTypeDescription(trade.getType());
            entity.setProfit(trade.getProfit());
            entity.setVolume(trade.getVolume());
            entity.setCurrprice(trade.getCurrprice());

            mt5OpenTradeRepository.save(entity);
        }
    }

    @Override
    @Transactional
    public String initForexTrend(String EPIC, String CAPITAL_TIME_XX) {
        if (required_update_bars_csv) {
            return "";
        }
        // EPIC = "CHFJPY";
        // CAPITAL_TIME_XX = Utils.CAPITAL_TIME_H1;
        // ----------------------------TREND------------------------
        List<BtcFutures> list = getCapitalData(EPIC, CAPITAL_TIME_XX);
        if (CollectionUtils.isEmpty(list)) {
            return "";
        }
        List<BtcFutures> heken_list = Utils.getHekenList(list);
        String trend = Utils.getTrendByHekenAshiList(heken_list);

        String type = "";
        // TODO: 1. initForexTrend

        if ((heken_list.size() > 50) && CAPITAL_TIME_XX.contains("MINUTE")) {
            String switch_trend_05 = Utils.switchTrendByHeken_12(heken_list);
            switch_trend_05 += Utils.switchTrendByMa5_8(heken_list);

            if (switch_trend_05.contains(trend)) {
                if (Objects.equals(trend, Utils.TREND_LONG) && Utils.isBelowMALine(heken_list, 50)) {
                    type = Utils.appendSpace(trend, 4) + Utils.TEXT_SWITCH_TREND_Ma_3_5;
                }
                if (Objects.equals(trend, Utils.TREND_SHOT) && Utils.isAboveMALine(heken_list, 50)) {
                    type = Utils.appendSpace(trend, 4) + Utils.TEXT_SWITCH_TREND_Ma_3_5;
                }
            }

            if (Utils.isBlank(type) && Objects.equals(CAPITAL_TIME_XX, Utils.CAPITAL_TIME_05)) {
                switch_trend_05 = Utils.switchTrendByMaXX(heken_list, 1, 50);
                switch_trend_05 = Utils.switchTrendByMaXX(heken_list, 3, 50);
                if (switch_trend_05.contains(trend)) {
                    type = Utils.appendSpace(trend, 4) + Utils.TEXT_SWITCH_TREND_Ma_1_50;
                }
            }
        } else if (CAPITAL_TIME_XX.contains("HOUR")) {
            if (Objects.equals(trend, Utils.TREND_LONG) && Utils.isBelowMALine(heken_list, 50)) {
                type = Utils.switchTrendByHeken_12(heken_list);
            }
            if (Objects.equals(trend, Utils.TREND_SHOT) && Utils.isAboveMALine(heken_list, 50)) {
                type = Utils.switchTrendByHeken_12(heken_list);
            }
        } else {
            type = Utils.switchTrendByHeken_12(heken_list);
        }

        String note = "";
        if (Utils.isNotBlank(type)) {
            note = Utils.getChartNameCapital(CAPITAL_TIME_XX) + type;
        }

        // -----------------------------DATABASE---------------------------
        List<BigDecimal> lohi;
        BigDecimal bread = BigDecimal.ZERO;

        // Chap nhan thua rui ro, khong niu keo sai lam danh sai xu huong.
        if (Objects.equals(CAPITAL_TIME_XX, Utils.CAPITAL_TIME_05)) {
            int size = heken_list.size() - 1;
            lohi = Utils.getLowHighCandle(heken_list.subList(0, size));
            bread = Utils.calcMaxBread(heken_list.subList(0, size));
        } else {
            int size = heken_list.size() > 10 ? 10 : heken_list.size();
            lohi = Utils.getLowHighCandle(heken_list.subList(0, size));
            bread = Utils.calcMaxBread(heken_list.subList(0, size));
        }
        if (Objects.equals(CAPITAL_TIME_XX, Utils.CAPITAL_TIME_D1)) {
            bread = BigDecimal.ZERO;
        }
        if (Utils.EPICS_STOCKS.contains(EPIC)) {
            bread = Utils.calcMaxCandleHigh(heken_list.subList(1, 5));
        }

        String orderId = EPIC + "_" + CAPITAL_TIME_XX;
        String date_time = LocalDateTime.now().toString();
        List<BigDecimal> body = Utils.getBodyCandle(list);
        BigDecimal str_body = body.get(0);
        BigDecimal end_body = body.get(1);
        BigDecimal sl_long = lohi.get(0).subtract(bread);
        BigDecimal sl_shot = lohi.get(1).add(bread);

        Orders entity = new Orders(orderId, date_time, trend, list.get(0).getCurrPrice(), str_body, end_body, sl_long,
                sl_shot, note);
        ordersRepository.save(entity);

        return "";
    }

    @Override
    @Transactional
    public String controlMt5(List<String> CAPITAL_LIST) {
        if (required_update_bars_csv) {
            return "";
        }

        int index = 0;
        String msg = "";

        for (String EPIC : CAPITAL_LIST) {
            if (BscScanBinanceApplication.EPICS_OUTPUTED_LOG.contains(EPIC)) {
                continue;
            }

            // EPIC = "GBPAUD";

            Orders dto_w1 = ordersRepository.findById(EPIC + "_" + Utils.CAPITAL_TIME_W1).orElse(null);
            Orders dto_d1 = ordersRepository.findById(EPIC + "_" + Utils.CAPITAL_TIME_D1).orElse(null);
            Orders dto_h12 = ordersRepository.findById(EPIC + "_" + Utils.CAPITAL_TIME_H12).orElse(null);
            Orders dto_h4 = ordersRepository.findById(EPIC + "_" + Utils.CAPITAL_TIME_H4).orElse(null);
            Orders dto_h1 = ordersRepository.findById(EPIC + "_" + Utils.CAPITAL_TIME_H1).orElse(null);
            Orders dto_15 = ordersRepository.findById(EPIC + "_" + Utils.CAPITAL_TIME_15).orElse(null);
            Orders dto_05 = ordersRepository.findById(EPIC + "_" + Utils.CAPITAL_TIME_05).orElse(null);

            if (Objects.isNull(dto_w1) || Objects.isNull(dto_d1) || Objects.isNull(dto_h12) || Objects.isNull(dto_h4)
                    || Objects.isNull(dto_h1) || Objects.isNull(dto_15) || Objects.isNull(dto_05)) {
                Utils.logWritelnDraft("[scapForex] (" + EPIC + ") dto is null");
                continue;
            }

            String trend_w1 = dto_w1.getTrend();
            String trend_d1 = dto_d1.getTrend();
            String trend_h12 = dto_h12.getTrend();
            String trend_h4 = dto_h4.getTrend();
            String trend_h1 = dto_h1.getTrend();
            String trend_15 = dto_05.getTrend();
            String trend_05 = dto_05.getTrend();

            String note_w1 = dto_w1.getNote();
            String note_d1 = dto_d1.getNote();
            String note_h12 = dto_h12.getNote();
            String note_h4 = dto_h4.getNote();
            String note_h1 = dto_h1.getNote();
            String note_15 = dto_15.getNote();
            String note_05 = dto_05.getNote();

            // Không đánh ngược xu hướng Khi chỉ số có trend_w1=trend_d1.
            if (Utils.EPICS_INDEXS.contains(EPIC) && Objects.equals(trend_w1, trend_d1)
                    && !Objects.equals(trend_d1, trend_h12)) {
                continue;
            }

            String zone_h12 = "";
            String zone_h4 = "";
            String zone_h1 = "";
            boolean isBreadLongArea = false;
            boolean isBreadShotArea = false;
            {
                List<BtcFutures> list_h1 = getCapitalData(EPIC, Utils.CAPITAL_TIME_H1);
                List<BtcFutures> list_h4 = getCapitalData(EPIC, Utils.CAPITAL_TIME_H4);
                List<BtcFutures> list_h12 = getCapitalData(EPIC, Utils.CAPITAL_TIME_H12);

                if (CollectionUtils.isEmpty(list_h12) || CollectionUtils.isEmpty(list_h4)
                        || CollectionUtils.isEmpty(list_h1)) {
                    continue;
                }

                List<BtcFutures> heken_list_h1 = Utils.getHekenList(list_h1);
                List<BtcFutures> heken_list_h4 = Utils.getHekenList(list_h4);
                List<BtcFutures> heken_list_h12 = Utils.getHekenList(list_h12);

                zone_h12 = Utils.getZoneTrend(heken_list_h12);
                zone_h4 = Utils.getZoneTrend(heken_list_h4);
                zone_h1 = Utils.getZoneTrend(heken_list_h1);

                BigDecimal cur_price = list_h1.get(0).getCurrPrice();
                List<BigDecimal> lohi_h1 = Utils.getLowHighCandle(heken_list_h1);
                List<BigDecimal> lohi_h4 = Utils.getLowHighCandle(heken_list_h4);
                List<BigDecimal> lohi_h12 = Utils.getLowHighCandle(heken_list_h12);

                if ((cur_price.compareTo(lohi_h1.get(0)) < 0) && (cur_price.compareTo(lohi_h4.get(0)) < 0)
                        && (cur_price.compareTo(lohi_h12.get(0)) < 0)) {
                    isBreadLongArea = true;
                }

                if ((cur_price.compareTo(lohi_h1.get(1)) > 0) && (cur_price.compareTo(lohi_h4.get(1)) > 0)
                        && (cur_price.compareTo(lohi_h12.get(1)) > 0)) {
                    isBreadShotArea = true;
                }
            }

            index += 1;
            String tracking_trend = trend_w1;
            String prefix = Utils.getPrefix_FollowTrackingTrend(index, trend_w1, trend_d1, trend_h12, trend_h4,
                    trend_h1, "", note_w1, note_d1, note_h12, note_h4, note_h1, note_05, tracking_trend, zone_h12,
                    zone_h4, zone_h1);

            // Hệ thống đặt lệnh thì có xu hướng của w1d1h4h1 được thêm vào comment.
            String wdh4h1 = Utils.getEncrypted_trend_w1d1h4h1(trend_w1, trend_d1, trend_h12, trend_h4, trend_h1);

            // TODO: 3. controlMt5
            if ((Utils.EPICS_FOREXS_ALL.contains(EPIC) || Utils.EPICS_CASH_CFD.contains(EPIC)
                    || Utils.EPICS_METALS.contains(EPIC))) {

                String action = "";
                Mt5OpenTrade dto = null;

                if (isBreadLongArea || isBreadShotArea) {
                    if (isBreadLongArea && (trend_05 + trend_15).contains(Utils.TREND_LONG)) {
                        String timeframe = (Objects.equals(trend_15, Utils.TREND_LONG)) ? Utils.CAPITAL_TIME_15
                                : Utils.CAPITAL_TIME_05;

                        dto = Utils.calc_Lot_En_SL_TP(EPIC, Utils.TREND_LONG, dto_05, dto_h4, timeframe,
                                wdh4h1 + "12405b", true);

                        BscScanBinanceApplication.mt5_open_trade_List.add(dto);
                    }

                    if (isBreadShotArea && (trend_05 + trend_15).contains(Utils.TREND_SHOT)) {
                        String timeframe = (Objects.equals(trend_15, Utils.TREND_SHOT)) ? Utils.CAPITAL_TIME_15
                                : Utils.CAPITAL_TIME_05;

                        dto = Utils.calc_Lot_En_SL_TP(EPIC, Utils.TREND_SHOT, dto_05, dto_h4, timeframe,
                                wdh4h1 + "12405s", true);
                        BscScanBinanceApplication.mt5_open_trade_List.add(dto);
                    }
                }

                // -----------------------------------------------------------------------------------
                if (Objects.isNull(dto) && note_05.contains(trend_h12)) {
                    if (Objects.equals(trend_h12, trend_h4) && Objects.equals(trend_h4, trend_h1)
                            && Objects.equals(trend_h1, trend_15)) {
                        action = trend_h12;
                        String append = wdh4h1 + "124105";
                        dto = Utils.calc_Lot_En_SL_TP(EPIC, action, dto_05, dto_h4, Utils.CAPITAL_TIME_05, append,
                                true);
                    }
                }

                if (Objects.isNull(dto) && note_15.contains(trend_h12)) {
                    if (Objects.equals(trend_h12, trend_h4) && Objects.equals(trend_h4, trend_h1)) {
                        action = trend_h12;
                        String append = wdh4h1 + "124115";

                        dto = Utils.calc_Lot_En_SL_TP(EPIC, action, dto_05, dto_h4, Utils.CAPITAL_TIME_15, append,
                                true);
                    }
                }

                // -----------------------------------------------------------------------------------

                if (Objects.nonNull(dto)) {
                    if (Objects.equals(trend_w1, trend_h12) && !Objects.equals(trend_h12, action)) {
                        continue;
                    }
                    if (Objects.equals(trend_d1, trend_h12) && !Objects.equals(trend_h12, action)) {
                        continue;
                    }
                    if (Objects.equals(trend_h4, trend_h1) && !Objects.equals(trend_h4, action)) {
                        continue;
                    }
                    if (!zone_h12.contains(action) || !zone_h4.contains(action) || !zone_h1.contains(action)) {
                        continue;
                    }

                    BscScanBinanceApplication.mt5_open_trade_List.add(dto);
                }

            }

            // ---------------------------------------------------------------------------------------------

            String CAPITAL_TIME_XX = Utils.getTimeframe_SwitchTrend(note_d1, note_h12, note_h4);
            analysis(prefix, EPIC, CAPITAL_TIME_XX);

            if (!Objects.equals(EPIC, "BTCUSD")) {
                BscScanBinanceApplication.EPICS_OUTPUTED_LOG += "_" + EPIC + "_";
            }
        }

        return msg;

    }

    // H1 & H4 nguoc huong -> thong bao cat lenh.
    // Xu huong H4 cung xu huong nhung yeu di? Msg thong bao take profit.
    // Xu huong H1 cung xu huong nhung yeu di? Log thong bao.
    @Override
    @Transactional
    public void monitorProfit() {
        initTradeList();

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
        // ------------------ FOREX ------------------
        if (!(Utils.isWeekday() && Utils.isAllowSendMsg())) {
            return;
        }
        if (required_update_bars_csv) {
            return;
        }

        // ------------------ Đóng các trade đã close ------------------
        List<Mt5OpenTradeEntity> mt5Openlist = mt5OpenTradeRepository.findAll();
        if (!CollectionUtils.isEmpty(mt5Openlist)) {
            for (Mt5OpenTradeEntity entity : mt5Openlist) {
                boolean not_found = true;
                for (Mt5DataTrade trade : tradeList) {
                    if (Objects.equals(entity.getTicket(), trade.getTicket())) {
                        not_found = false;
                    }
                }
                if (not_found) {
                    mt5OpenTradeRepository.deleteById(entity.getTicket());
                }
            }
        }

        List<String> mt5_close_trade_list = new ArrayList<String>();

        // Dong lenh LIMIT dat nguoc xu huong
        for (Mt5DataTrade trade : tradeList) {
            String TRADE_EPIC = trade.getSymbol().toUpperCase();
            String TRADE_TREND = trade.getType().toUpperCase();

            // Cấm xóa, nếu không tất cả lệnh sẽ bị delete hết.
            if (!TRADE_TREND.contains("LIMIT")) {
                continue;
            }

            for (Mt5OpenTrade open_dto : BscScanBinanceApplication.mt5_open_trade_List) {
                String EPIC_OPEN = open_dto.getEpic().toUpperCase();
                String OPEN_TREND = open_dto.getOrder_type().toUpperCase();

                if (Objects.equals(TRADE_EPIC, EPIC_OPEN)) {
                    // Đang đặt lệnh LIMIT, Hệ thống check 05m là mua ngay thì xóa lệnh chờ.
                    if (TRADE_TREND.contains("LIMIT") && !OPEN_TREND.contains("LIMIT")) {
                        mt5_close_trade_list.add(trade.getTicket());
                    }
                }
            }
        }

        // ----------------------------------------PROFIT--------------------------------------
        BigDecimal risk = Utils.ACCOUNT.multiply(Utils.RISK_PERCENT).multiply(BigDecimal.valueOf(2.5));
        String max_risk = "     MaxRisk:" + Utils.appendLeft(String.valueOf(risk).replace(".0000", ""), 10) + "$1Trade";
        BigDecimal profit_0_5R = risk.divide(BigDecimal.valueOf(2), 10, RoundingMode.CEILING);
        BigDecimal profit_1R = risk;

        String msg = "";
        String msgStopLoss = "";
        String msgStopScalping = "";
        BigDecimal total = BigDecimal.ZERO;
        List<String> scalpingList = new ArrayList<String>();

        try {
            String mt5_close_trade_file = Utils.getMt5DataFolder() + "CloseSymbols.csv";
            File myScap = new File(mt5_close_trade_file);
            myScap.delete();
        } catch (Exception e) {
        }

        for (Mt5DataTrade trade : tradeList) {
            String EPIC = trade.getSymbol();
            String TICKET = trade.getTicket();
            String TRADE_TREND = trade.getType().toUpperCase();
            if (TRADE_TREND.contains("LIMIT")) {
                continue;
            }
            if (Utils.EPICS_STOCKS.contains(EPIC) && !Utils.isNewYorkSession()) {
                continue;
            }

            // Dừng trade khi H1_1 đóng nến tại LoHi + Bread1-5 của H1.
            Orders dto_h1 = ordersRepository.findById(EPIC + "_" + Utils.CAPITAL_TIME_H1).orElse(null);
            Orders dto_05 = ordersRepository.findById(EPIC + "_" + Utils.CAPITAL_TIME_05).orElse(null);
            if (Utils.EPICS_STOCKS.contains(EPIC)) {
                dto_05 = ordersRepository.findById(EPIC + "_" + Utils.CAPITAL_TIME_15).orElse(null);
            }
            if (Objects.isNull(dto_h1) || Objects.isNull(dto_05)) {
                continue;
            }
            Mt5OpenTradeEntity mt5Entity = mt5OpenTradeRepository.findById(trade.getTicket()).orElse(null);
            if (Objects.isNull(mt5Entity)) {
                Utils.logWritelnDraft("monitorProfit Mt5OpenTradeEntity not found Ticket: " + trade.getTicket() + "   "
                        + trade.getSymbol());
                continue;
            }

            List<BtcFutures> list_h1 = getCapitalData(EPIC, Utils.CAPITAL_TIME_H1);
            if (CollectionUtils.isEmpty(list_h1)) {
                continue;
            }

            BigDecimal SL_of_Timeframe = mt5Entity.getStopLossTimeFam();
            List<BtcFutures> list_tf = getCapitalData(EPIC, mt5Entity.getTimeframe());
            if (CollectionUtils.isEmpty(list_tf)) {
                continue;
            }

            List<BtcFutures> heken_list_tf = Utils.getHekenList(list_tf);
            String trend_tf = Utils.getTrendByHekenAshiList(heken_list_tf);

            // SL khi Cancle_1 đóng cửa dưới LoHi+Bread của H1.
            BigDecimal candle_tf_close = heken_list_tf.get(1).getPrice_close_candle();

            String result = "";
            String trend_h1 = dto_h1.getTrend();
            String trend_05 = dto_05.getTrend();
            // ---------------------------------------------------------------------------------
            boolean isPriceHit_SL = false;

            // Check (H1) & (05) xem còn hy vọng giá hồi hay không, nếu không thì đóng.
            if (!Objects.equals(trend_tf, TRADE_TREND) && !Objects.equals(trend_h1, TRADE_TREND)
                    && !Objects.equals(trend_05, TRADE_TREND)) {

                // SL khi Cancle_1 đóng cửa dưới LoHi+Bread của H1.
                if (Objects.equals(Utils.TREND_LONG, TRADE_TREND) && (candle_tf_close.compareTo(SL_of_Timeframe) < 0)) {
                    result += "(StopLoss)";
                    isPriceHit_SL = true;
                }

                // SL khi Cancle_1 đóng cửa trên LoHi+Bread của H1.
                if (Objects.equals(Utils.TREND_SHOT, TRADE_TREND) && (candle_tf_close.compareTo(SL_of_Timeframe) > 0)) {
                    result += "(StopLoss)";
                    isPriceHit_SL = true;
                }
            }

            if ((trade.getProfit().add(profit_0_5R)).compareTo(BigDecimal.ZERO) < 0) {
                String par_timeframe = Utils.CAPITAL_TIME_H4;

                if (Objects.equals(mt5Entity.getTimeframe(), Utils.CAPITAL_TIME_05)) {
                    par_timeframe = Utils.CAPITAL_TIME_15;
                }
                if (Objects.equals(mt5Entity.getTimeframe(), Utils.CAPITAL_TIME_15)) {
                    par_timeframe = Utils.CAPITAL_TIME_H1;
                }
                if (Objects.equals(mt5Entity.getTimeframe(), Utils.CAPITAL_TIME_H1)) {
                    par_timeframe = Utils.CAPITAL_TIME_H4;
                }

                Orders dto_par_tf = ordersRepository.findById(EPIC + "_" + par_timeframe).orElse(null);
                if (Objects.nonNull(dto_par_tf) && !Objects.equals(dto_par_tf.getTrend(), TRADE_TREND)
                        && (!dto_h1.getNote().contains(TRADE_TREND) || !dto_par_tf.getNote().contains(TRADE_TREND))) {

                    result += "(StopLoss_sw)";
                    isPriceHit_SL = true;
                }
            }
            // ---------------------------------------------------------------------------------
            if (Objects.equals(mt5Entity.getTimeframe(), Utils.CAPITAL_TIME_05)) {
                List<BtcFutures> list = getCapitalData(EPIC, Utils.CAPITAL_TIME_05);
                if (!CollectionUtils.isEmpty(list)) {
                    List<BtcFutures> heken_list = Utils.getHekenList(list);

                    String trend_05_1 = Utils.getTrendByMaXx(heken_list, 5);

                    String switch_trend_05 = Utils.switchTrendByHeken_12(heken_list);
                    switch_trend_05 += Utils.switchTrendByMa5_8(heken_list);
                    switch_trend_05 += Utils.switchTrendByMaXX(heken_list, 1, 20);

                    if (Utils.isNotBlank(switch_trend_05) && Objects.equals(trend_05_1, TRADE_TREND)) {
                        mt5_close_trade_list.add(TICKET);
                    }
                }

                if (isPriceHit_SL) {
                    mt5_close_trade_list.add(TICKET);
                }
            } else {
                // Trailing stops khi profit > 1R
                if (trade.getProfit().compareTo(profit_1R) > 0) {
                    SL_of_Timeframe = candle_tf_close;
                    mt5Entity.setStopLossTimeFam(candle_tf_close);
                    mt5OpenTradeRepository.save(mt5Entity);
                }

                if (isPriceHit_SL) {
                    String prefix = Utils.getChartNameCapital(mt5Entity.getTimeframe()) + "Closed.   ";
                    prefix += "(Ticket):" + Utils.appendSpace(trade.getTicket(), 15);
                    prefix += "(Trade):" + Utils.appendSpace(TRADE_TREND, 10);
                    prefix += Utils.getChartNameCapital(mt5Entity.getTimeframe()) + ":"
                            + Utils.appendSpace(trend_tf, 10);
                    prefix += "(Profit):" + Utils.appendSpace(Utils.appendLeft(trade.getProfit().toString(), 10), 15);
                    prefix += Utils.appendSpace(Utils.getCapitalLink(EPIC), 62) + " ";
                    Utils.logWritelnDraft(prefix);

                    mt5_close_trade_list.add(TICKET);
                }
            }

            // ---------------------------------------------------------------------------------
            String multi_timeframes = getTrendTimeframes(EPIC);
            result = Utils.appendSpace(result, 15);
            result += "(Trade:" + Utils.appendSpace(TRADE_TREND, 10) + ")   ";
            result += Utils.appendSpace(EPIC, 10);
            result += multi_timeframes;
            result += "   (Profit):" + Utils.appendLeft(Utils.removeLastZero(trade.getProfit()), 10);

            total = total.add(trade.getProfit());
            msg += result + Utils.new_line_from_service;

            if (result.contains("StopLoss")) {
                msgStopLoss += result.replace(multi_timeframes, "") + Utils.new_line_from_service;
            }
        }

        if (total.compareTo(BigDecimal.valueOf(2000)) > 0) {
            for (Mt5DataTrade trade : tradeList) {
                if (trade.getComment().contains(Utils.getEncryptedChartNameCapital(Utils.CAPITAL_TIME_H12))) {
                    continue;
                }

                if (!mt5_close_trade_list.contains(trade.getTicket())) {
                    mt5_close_trade_list.add(trade.getTicket());
                }
            }
        }

        if (Utils.isNotBlank(msg)) {
            msg = Utils.appendLeft(String.valueOf(total), 10) + max_risk + Utils.new_line_from_service + msg;
            Utils.logWritelnDraft(msg);
        }
        if (Utils.isNotBlank(msgStopLoss)) {
            msgStopLoss = "[STOP_LOSS]" + max_risk + Utils.new_line_from_service + msgStopLoss;

            String EVENT_ID = "StopLoss" + Utils.getCurrentYyyyMmDd_HH();
            sendMsgPerHour(EVENT_ID, msgStopLoss, true);
        }
        if (Utils.isNotBlank(msgStopScalping)) {
            msgStopScalping = "[STOP_SCALPING]" + Utils.new_line_from_service + msgStopScalping;

            String EVENT_ID = "StopScalping" + Utils.getCurrentYyyyMmDd_HH();
            sendMsgPerHour(EVENT_ID, msgStopScalping, true);
        }

        if (scalpingList.size() > 0) {
            Utils.logWritelnDraft("");
            for (String scalping : scalpingList) {
                Utils.logWritelnDraft(scalping);
            }
            Utils.logWritelnDraft("");
        }

        Utils.logWritelnDraft("");
        Utils.logWritelnDraft("");
        Utils.logWritelnDraft("");

        mt5CloseTrade(mt5_close_trade_list);
    }

}
//8-10-13-17-21-26-34
