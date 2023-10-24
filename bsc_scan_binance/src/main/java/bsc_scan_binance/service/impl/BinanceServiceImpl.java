package bsc_scan_binance.service.impl;

import java.io.BufferedReader;
import java.io.File;
import java.io.FileInputStream;
import java.io.FileWriter;
import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;
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
import java.util.Collections;
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
import bsc_scan_binance.entity.DailyRange;
import bsc_scan_binance.entity.DailyRangeKey;
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
import bsc_scan_binance.entity.TakeProfit;
import bsc_scan_binance.repository.BinanceFuturesRepository;
import bsc_scan_binance.repository.BinanceVolumeDateTimeRepository;
import bsc_scan_binance.repository.BinanceVolumnDayRepository;
import bsc_scan_binance.repository.BinanceVolumnWeekRepository;
import bsc_scan_binance.repository.BtcVolumeDayRepository;
import bsc_scan_binance.repository.CandidateCoinRepository;
import bsc_scan_binance.repository.DailyRangeRepository;
import bsc_scan_binance.repository.DepthAsksRepository;
import bsc_scan_binance.repository.DepthBidsRepository;
import bsc_scan_binance.repository.FundingHistoryRepository;
import bsc_scan_binance.repository.GeckoVolumeMonthRepository;
import bsc_scan_binance.repository.Mt5DataCandleRepository;
import bsc_scan_binance.repository.Mt5OpenTradeRepository;
import bsc_scan_binance.repository.OrdersRepository;
import bsc_scan_binance.repository.PrepareOrdersRepository;
import bsc_scan_binance.repository.TakeProfitRepository;
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

    private BigDecimal OPEN_POSITIONS = BigDecimal.ZERO;
    private BigDecimal TOTAL_LOSS_TODAY = BigDecimal.ZERO;

    private String CLOSED_TRADE_TODAY = "";

    private static Hashtable<String, BigDecimal> BREAD_DICT = new Hashtable<String, BigDecimal>();

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

    @Autowired
    private DailyRangeRepository dailyRangeRepository;

    @Autowired
    private TakeProfitRepository takeProfitRepository;

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
        } else if (Objects.equals(CAPITAL_TIME_XXX, Utils.CRYPTO_TIME_H4)) {
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

        List<Orders> orders = ordersRepository.findAll();
        // List<Orders> orders = ordersRepository.getForexList();
        if (!CollectionUtils.isEmpty(orders)) {
            ordersRepository.deleteAll(orders);
        }

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
    private void createOrders(String SYMBOL, String orderId, String switch_trend, String trend,
            List<BtcFutures> heiken_list) {
        String date_time = LocalDateTime.now().toString();

        List<BigDecimal> body = Utils.getBodyCandle(heiken_list);
        List<BigDecimal> low_high = Utils.getLowHighCandle(heiken_list);

        String ma50 = Utils.isAboveMALine(heiken_list, 50) ? "(Ma50)  " : "        ";
        String trend_by_ma10 = Utils.isAboveMALine(heiken_list, 10) ? Utils.TREND_LONG : Utils.TREND_SHOT;
        String trend_heiken_1 = Utils.getTrendByHekenAshiList(heiken_list);

        String note = "                ";
        if (CRYPTO_LIST_BUYING.contains(SYMBOL)) {
            note = "   **BUYING**    ";

        } else if (Utils.COINS_NEW_LISTING.contains(SYMBOL)) {
            note = "   NEW_LISTING   ";

        } else if (Utils.LIST_WAITING.contains(SYMBOL)) {
            note = "   WATCH_LIST   ";
        }
        note += ma50 + "   " + switch_trend;

        String tradable_zone = Utils.getZone(heiken_list);

        Orders entity = new Orders(orderId, date_time, trend, heiken_list.get(0).getCurrPrice(), body.get(0),
                body.get(1), low_high.get(0), low_high.get(1), note, trend_by_ma10, tradable_zone, trend_heiken_1, "",
                "", "", "", BigDecimal.ZERO, BigDecimal.ZERO, BigDecimal.ZERO, BigDecimal.ZERO, BigDecimal.ZERO,
                BigDecimal.ZERO, BigDecimal.ZERO, BigDecimal.ZERO, BigDecimal.ZERO, BigDecimal.ZERO, BigDecimal.ZERO,
                "");

        ordersRepository.save(entity);
    }

    private String analysis_profit(String prefix, String EPIC, String append_eoz, DailyRange dailyRange,
            String trend_folow, BigDecimal curr_price, String trend_by_ma89_h4, String trade_zone) {

        String type = "";
        BigDecimal t_profit = BigDecimal.ZERO;
        BigDecimal t_volume = BigDecimal.ZERO;

        List<Mt5OpenTradeEntity> tradeList = mt5OpenTradeRepository.findAllBySymbolOrderByCompanyAsc(EPIC);
        for (Mt5OpenTradeEntity trade : tradeList) {
            if (trade.getType().toUpperCase().contains("LIMIT")) {
                continue;
            }

            type = "(" + Utils.getType(trade.getType()).toUpperCase() + ")";
            t_profit = t_profit.add(Utils.getBigDecimal(trade.getProfit()));
            t_volume = t_volume.add(Utils.getBigDecimal(trade.getVolume()));
        }

        String profit = "";
        if (tradeList.size() > 0) {
            profit = type + Utils.appendLeft(String.valueOf(t_profit.intValue()), 5) + "$";
            profit += "/" + Utils.appendSpace(String.valueOf(tradeList.size()), 2);
        }

        // TODO: outputLog
        String log = Utils.getTypeOfEpic(EPIC) + Utils.appendSpace(EPIC, 8);
        log += Utils.appendSpace(Utils.removeLastZero(Utils.formatPrice(curr_price, 5)), 11);
        log += Utils.appendSpace((prefix + " " + append_eoz).trim(), 138) + Utils.appendSpace(profit, 15);
        log += Utils.appendSpace(Utils.getCapitalLink(EPIC), 62) + " ";

        log += "Unit:" + Utils.appendLeft(String.valueOf(Utils.get_standard_vol_per_100usd(EPIC)), 5) + "(lot)     ";

        log += Utils.appendSpace(trend_by_ma89_h4, 20);
        log += trade_zone + "    ";

        if (Utils.isNotBlank(trend_folow)) {
            Orders dto_h1 = ordersRepository.findById(EPIC + "_" + Utils.CAPITAL_TIME_H1).orElse(null);

            if (Objects.nonNull(dto_h1)) {
                log += Utils.calc_BUF_LO_HI_BUF_Forex(Utils.RISK_0_15_PERCENT, true, trend_folow, EPIC, dto_h1, dto_h1);
            }
        }

        Utils.logWritelnDraft(log);

        return EPIC;
    }

    @Override
    public void CloseTickets() {
        String mt5_data_file = Utils.getMt5DataFolder() + "CloseSymbols.csv";
        try {
            FileWriter writer = new FileWriter(mt5_data_file, true);

            for (String TICKET : BscScanBinanceApplication.mt5_close_ticket_dict.keySet()) {
                if (!mt5OpenTradeRepository.existsById(TICKET)) {
                    continue;
                }

                String type = "";
                String EPIC = "NOT_FOUND";
                String str_profit = "";
                BigDecimal profit = BigDecimal.ZERO;
                Mt5OpenTradeEntity mt5Entity = mt5OpenTradeRepository.findById(TICKET).orElse(null);
                if (Objects.nonNull(mt5Entity)) {
                    type = mt5Entity.getType();
                    EPIC = mt5Entity.getSymbol();
                    str_profit = Utils.appendSpace(mt5Entity.getProfit(), 10) + "$";
                    profit = Utils.getBigDecimal(mt5Entity.getProfit());
                }

                if (Utils.EPICS_STOCKS_EUR.contains(EPIC) && !Utils.is_london_session()) {
                    continue;
                }
                if (Utils.EPICS_STOCKS_USA.contains(EPIC) && !Utils.is_newyork_session()) {
                    continue;
                }

                // TODO: CloseTickets HOLDING _USDJPY_CHFJPY_ || (profit.compareTo(BigDecimal.ZERO) > 0)
                if (!"_USDJPY_CHFJPY_EURJPY_".contains("_" + EPIC.toUpperCase() + "_")
                        || (profit.compareTo(BigDecimal.ZERO) > 0)) {

                    StringBuilder sb = new StringBuilder();
                    sb.append(TICKET);
                    sb.append('\n');
                    writer.write(sb.toString());
                }

                System.out.println(Utils.getTimeHHmm() + "CloseTicket: " + Utils.appendSpace(TICKET, 15)
                        + Utils.appendSpace(type, 15) + Utils.appendSpace(EPIC, 10) + "     Profit:" + str_profit
                        + "    Resion: " + BscScanBinanceApplication.mt5_close_ticket_dict.get(TICKET));
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

        String mt5_open_trade_file = Utils.getMt5DataFolder() + "OpenTrade.csv";
        int MAX_TRADE = 100;
        int trade_count = 0;

        try {
            FileWriter writer = new FileWriter(mt5_open_trade_file, true);
            Hashtable<String, String> msg_dict = new Hashtable<String, String>();

            for (Mt5OpenTrade dto : BscScanBinanceApplication.mt5_open_trade_List) {
                if (Objects.isNull(dto)) {
                    continue;
                }
                String EPIC = dto.getEpic();
                if ("_DX.f_".contains(EPIC)) {
                    continue;
                }

                boolean is_notice_only = "_DX.f_NATGAS_ERBN_BTCUSD_".toUpperCase().contains(EPIC)
                        || (Utils.EPICS_CRYPTO_CFD.contains(EPIC) && !Objects.equals("BTCUSD", EPIC))
                        || dto.getComment().contains(Utils.TEXT_NOTICE_ONLY);

                if (Utils.EPICS_STOCKS.contains(EPIC) && dto.getOrder_type().toUpperCase().contains(Utils.TREND_SHOT)) {
                    continue;
                }
                if (Utils.EPICS_STOCKS_EUR.contains(EPIC) && !Utils.is_london_session()) {
                    continue;
                }
                if (Utils.EPICS_STOCKS_USA.contains(EPIC) && !Utils.is_newyork_session()) {
                    continue;
                }

                // TODO: 4. openTrade
                String prefix = "OpenTrade";
                if (dto.getComment().contains(Utils.TEXT_NOTICE_ONLY) || is_notice_only) {
                    prefix = "Notice";
                }

                String chart_name = Utils
                        .getChartPrefix(Utils.getDeEncryptedChartNameCapital(dto.getComment().toLowerCase()));

                prefix = Utils.appendSpace(prefix, 10) + Utils.appendSpace(chart_name, 10) + ": ";
                String log = Utils.createOpenTradeMsg(dto, prefix);
                log += Utils.appendSpace(Utils.getCapitalLink(EPIC), 62) + " ";
                Utils.logWritelnDraft(log);

                if (Utils.isNewsAt_19_20_21h()) {
                    // continue;
                }
                if (!Utils.isOpenTradeTime_6h_to_1h() || Utils.isWeekend()) {
                    continue;
                }

                // ----------------------------------------------------------------------------------
                if ((trade_count < MAX_TRADE)) {
                    String EVENT_ID = "OPEN_TRADE" + dto.getEpic() + dto.getOrder_type()
                            + Utils.getCurrentYyyyMmDd_Blog4h()
                            + Utils.getDeEncryptedChartNameCapital(dto.getComment());

                    msg_dict.put(EVENT_ID, Utils.createOpenTradeMsg(dto, prefix));

                    if (is_notice_only) {
                        continue;
                    }

                    trade_count += 1;
                    // if (Utils.isPcCongTy())
                    {
                        StringBuilder sb = new StringBuilder();
                        sb.append(dto.getEpic()); // 0
                        sb.append('\t');
                        sb.append(dto.getOrder_type()); // 1
                        sb.append('\t');
                        sb.append(dto.getLots()); // 2
                        sb.append('\t');
                        sb.append(dto.getEntry1()); // 3
                        sb.append('\t');
                        sb.append(dto.getStop_loss()); // 4
                        sb.append('\t');
                        sb.append(dto.getTake_profit1()); // 5
                        sb.append('\t');
                        sb.append(dto.getComment().trim()); // 6
                        sb.append('\t');
                        sb.append(dto.getEntry2()); // 7
                        sb.append('\t');
                        sb.append(dto.getTake_profit2()); // 8
                        sb.append('\t');
                        sb.append(dto.getEntry3()); // 9
                        sb.append('\t');
                        sb.append(dto.getTake_profit3()); // 10
                        sb.append('\t');
                        sb.append(dto.getTotal_trade()); // 11
                        sb.append('\n');

                        writer.write(sb.toString());
                    }
                }
            }
            writer.close();

            String msg = "";
            for (String EVENT_ID : msg_dict.keySet()) {
                if (isReloadAfter(Utils.MINUTES_OF_4H, EVENT_ID)) {
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

    private DailyRange get_DailyRange(String EPIC) {
        List<DailyRange> ranges = dailyRangeRepository.findSymbolToday(EPIC);
        if (CollectionUtils.isEmpty(ranges)) {
            return null;
        }
        DailyRange dailyRange = ranges.get(0);
        return dailyRange;
    }

    @Override
    @Transactional
    public String sendMsgKillLongShort(String SYMBOL) {
        if (!BTC_ETH_BNB.contains(SYMBOL)) {
            return Utils.CRYPTO_TIME_H1;
        }
        if (!Utils.isWeekday()) {
            return Utils.CRYPTO_TIME_H1;
        }
        if (!Utils.isOpenTradeTime_6h_to_1h()) {
            return Utils.CRYPTO_TIME_H1;
        }
        List<BtcFutures> list_d1 = Utils.loadData(SYMBOL, Utils.CRYPTO_TIME_D1, 15);

        if (CollectionUtils.isEmpty(list_d1)) {
            return Utils.CRYPTO_TIME_H1;
        }
        List<BtcFutures> heken_list_d1 = Utils.getHeikenList(list_d1);
        String switch_trend_d1 = Utils.switchTrendByMa1vs10(heken_list_d1);
        if (Utils.isBlank(switch_trend_d1)) {
            return Utils.CRYPTO_TIME_H1;
        }

        List<BtcFutures> list_h4 = Utils.loadData(SYMBOL, Utils.CRYPTO_TIME_H4, 15);
        if (CollectionUtils.isEmpty(list_h4)) {
            return Utils.CRYPTO_TIME_H1;
        }
        List<BtcFutures> heken_list_h4 = Utils.getHeikenList(list_h4);
        String trend_h4_ma10 = Utils.getTrendByMaXx(heken_list_h4, 10);
        String switch_trend_h4 = Utils.switchTrendByMa1vs2025(heken_list_h4);

        String trend_h4 = Utils.getTrendByHekenAshiList(heken_list_h4);
        String trend_d1 = Utils.getTrendByHekenAshiList(heken_list_d1);

        String chart_name = "";
        if (Utils.isNotBlank(switch_trend_d1)
                || (Objects.equals(trend_h4, trend_h4_ma10) && Utils.isNotBlank(switch_trend_h4))) {
            chart_name = "(D1)";
        }

        if (Objects.equals(trend_d1, trend_h4) && Utils.isNotBlank(chart_name)) {
            // TODO: sendMsgKillLongShort
            String msg = "";

            if (Objects.equals(Utils.TREND_LONG, trend_d1)) {
                msg = " 💹 " + chart_name + SYMBOL + "_kill_Short 💔 ";
            } else if (Objects.equals(Utils.TREND_SHOT, trend_d1)) {
                msg = " 🔻 " + chart_name + SYMBOL + "_kill_Long 💔 ";
            } else {
                return Utils.CRYPTO_TIME_H1;
            }
            msg += "(" + Utils.appendSpace(Utils.removeLastZero(list_d1.get(0).getCurrPrice()), 5) + ")";

            String EVENT_ID = "MSG_PER_HOUR" + SYMBOL + Utils.getCurrentYyyyMmDd_Blog4h();
            sendMsgPerHour_ToAll(EVENT_ID, msg);
        }

        return Utils.CRYPTO_TIME_H1;
    }

    @SuppressWarnings("unused")
    private boolean allow_append_trade_after_1day(String EPIC, String ACTION) {
        List<Mt5OpenTradeEntity> list = mt5OpenTradeRepository.findAllBySymbolOrderByCompanyAsc(EPIC);
        if (CollectionUtils.isEmpty(list)) {
            return false;
        }

        int count = 0;
        for (Mt5OpenTradeEntity mt5Entity : list) {
            if (mt5Entity.getType().toUpperCase().contains(ACTION.toUpperCase())) {
                String insert_time = Utils.getStringValue(mt5Entity.getOpenTime());
                if (Utils.isNotBlank(insert_time)) {
                    LocalDateTime pre_time = LocalDateTime.parse(insert_time);
                    Duration duration = Duration.between(pre_time, LocalDateTime.now());
                    long elapsedMinutes = duration.toMinutes();

                    if (elapsedMinutes > Utils.MINUTES_OF_8H) {
                        count += 1;
                    }
                }
            }
        }

        if (count == list.size()) {
            return true;
        }
        return false;
    }

    private boolean allow_open_or_close_trade_after(String TICKET, Integer MINUTES_OF_XX) {
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

    private int append_trade_number(String EPIC, String find_trend, DailyRange dailyRange, BigDecimal curr_price) {
        if (Utils.isBlank(find_trend)) {
            return 0;
        }

        List<Mt5OpenTradeEntity> opening_list = mt5OpenTradeRepository.findAllBySymbolOrderByCompanyAsc(EPIC);

        if (CollectionUtils.isEmpty(opening_list)) {
            return 1;
        }
        int size = opening_list.size();
        if (size > 3) {
            return size; // stop auto trade here.
        }

        BigDecimal last_open_price = opening_list.get(0).getPriceOpen();

        for (Mt5OpenTradeEntity trade : opening_list) {
            BigDecimal PROFIT = Utils.getBigDecimal(trade.getProfit());

            if (!trade.getType().toUpperCase().contains(find_trend.toUpperCase())) {
                boolean has_profit = PROFIT.compareTo(BigDecimal.valueOf(1)) > 0;
                if (has_profit) {
                    BscScanBinanceApplication.mt5_close_ticket_dict.put(trade.getTicket(), "reverse_trade_opening");
                }
            } else {
                // BUY: thì tìm giá vào lệnh nhỏ nhất
                if (Objects.equals(find_trend, Utils.TREND_LONG)) {
                    if (last_open_price.compareTo(trade.getPriceOpen()) > 0) {
                        last_open_price = trade.getPriceOpen();
                    }
                }

                // SELL: thì tìm giá vào lệnh lớn nhất
                if (Objects.equals(find_trend, Utils.TREND_SHOT)) {
                    if (last_open_price.compareTo(trade.getPriceOpen()) < 0) {
                        last_open_price = trade.getPriceOpen();
                    }
                }
            }
        }

        boolean satisfy_loss_range_when_enter = false;

        // BUY: giá nhỏ nhất - AMP > curr_price >>> có thể nhồi lệnh.
        if (Objects.equals(find_trend, Utils.TREND_LONG)) {
            last_open_price = last_open_price.subtract(dailyRange.getAvg_amp_week());

            satisfy_loss_range_when_enter = curr_price.compareTo(last_open_price) < 0;
        }

        // SELL: giá lớn nhất + AMP < curr_price >>> có thể nhồi lệnh.
        if (Objects.equals(find_trend, Utils.TREND_SHOT)) {
            last_open_price = last_open_price.add(dailyRange.getAvg_amp_week());

            satisfy_loss_range_when_enter = curr_price.compareTo(last_open_price) > 0;
        }

        if (satisfy_loss_range_when_enter) {
            return 3;
        }

        return 0;
    }

    private boolean close_reverse_trade(String EPIC, String TRADING_TREND) {
        TRADING_TREND = TRADING_TREND.toUpperCase();
        if (TRADING_TREND.contains("LIMIT")) {
            return false;
        }

        String REVERSE_TRADE_TREND = TRADING_TREND.contains(Utils.TREND_LONG) ? Utils.TREND_SHOT
                : TRADING_TREND.contains(Utils.TREND_SHOT) ? Utils.TREND_LONG : Utils.TREND_UNSURE;

        List<Mt5OpenTradeEntity> opening_list = mt5OpenTradeRepository.findAllBySymbolAndTypeOrderBySymbolAsc(EPIC,
                REVERSE_TRADE_TREND);

        if (CollectionUtils.isEmpty(opening_list)) {
            return true;
        }

        boolean result = true;
        BigDecimal total_profit = BigDecimal.ZERO;
        for (Mt5OpenTradeEntity trade : opening_list) {
            BigDecimal PROFIT = Utils.getBigDecimal(trade.getProfit());
            total_profit = total_profit.add(PROFIT);
        }
        BigDecimal avg_profit = total_profit.divide(BigDecimal.valueOf(opening_list.size()), 1, RoundingMode.CEILING);

        boolean close_all = total_profit.compareTo(avg_profit) > 0;

        for (Mt5OpenTradeEntity trade : opening_list) {
            String log = Utils.createCloseTradeMsg(trade, "MUST_CLOSE_TRADE: ", "reverse_trade_opening");
            Utils.logWritelnDraft(log);

            BigDecimal PROFIT = Utils.getBigDecimal(trade.getProfit());
            total_profit = total_profit.add(PROFIT);

            boolean has_profit = PROFIT.compareTo(BigDecimal.valueOf(10)) > 0;
            if (has_profit) {
                BscScanBinanceApplication.mt5_close_ticket_dict.put(trade.getTicket(), "reverse_trade_opening");
            } else if (close_all) {
                BscScanBinanceApplication.mt5_close_ticket_dict.put(trade.getTicket(), "reverse_trade_opening");
            } else {
                BscScanBinanceApplication.mt5_close_ticket_dict.put(trade.getTicket(), "reverse_trade_opening");
            }
        }

        return result;
    }

    @Override
    @Transactional
    public void monitorProfit() {
        // -------------------------------------------------------------------------------------
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

        Utils.logWritelnDraft("");
        for (String company : Utils.COMPANIES) {
            try {
                String mt5_close_trade_file = Utils.getMt5DataFolder() + "CloseSymbols.csv";
                File myScap = new File(mt5_close_trade_file);
                myScap.delete();
            } catch (Exception e) {
            }

            int count = 0;
            String msg = "";
            BigDecimal total = BigDecimal.ZERO;
            String risk_0_15 = "     Risk: 0.15% : " + Utils.RISK_0_15_PERCENT.intValue() + "$ per trade";

            List<Mt5OpenTradeEntity> mt5Openlist = mt5OpenTradeRepository
                    .findAllByCompanyOrderBySymbolAscTicketAsc(company);

            for (Mt5OpenTradeEntity trade : mt5Openlist) {
                count += 1;
                String EPIC = trade.getSymbol();
                // String multi_timeframes = get_time_frames(EPIC);
                BigDecimal PROFIT = Utils.getBigDecimal(trade.getProfit());
                String TRADE_TREND = trade.getType().toUpperCase();
                if (TRADE_TREND.contains("LIMIT")) {
                    continue;
                }
                // --------------------------------------------------------------------------
                String trend_reverse = "                 ";
                String REVERSE_TRADE_TREND = TRADE_TREND.contains(Utils.TREND_LONG) ? Utils.TREND_SHOT
                        : Utils.TREND_LONG;

                Orders dto_h4 = ordersRepository.findById(EPIC + "_" + Utils.CAPITAL_TIME_H4).orElse(null);
                // Orders dto_w1 = ordersRepository.findById(EPIC + "_" +
                // Utils.CAPITAL_TIME_W1).orElse(dto_h4);
                // Orders dto_d1 = ordersRepository.findById(EPIC + "_" +
                // Utils.CAPITAL_TIME_D1).orElse(dto_h4);

                Orders dto_h1 = ordersRepository.findById(EPIC + "_" + Utils.CAPITAL_TIME_H1).orElse(null);
                Orders dto_15 = ordersRepository.findById(EPIC + "_" + Utils.CAPITAL_TIME_15).orElse(null);
                if (Objects.isNull(dto_h4) || Objects.isNull(dto_h1) || Objects.isNull(dto_15)) {
                    continue;
                }
                if (Objects.nonNull(dto_h4) && Objects.nonNull(dto_h1) && Objects.nonNull(dto_15)
                        && Objects.equals(dto_15.getTrend_by_heiken1(), REVERSE_TRADE_TREND)
                        && Objects.equals(dto_h1.getTrend_by_heiken1(), REVERSE_TRADE_TREND)
                        && Objects.equals(dto_h4.getTrend_by_heiken1(), REVERSE_TRADE_TREND)) {
                    trend_reverse = "    h4_h1_15_reverse";
                }

                // --------------------------------------------------------------------------
                String result = "";
                result += Utils.appendLeft("TradeNo." + Utils.appendLeft(String.valueOf(count), 3, "0"), 15) + "   ";
                result += Utils.appendSpace(trade.getCompany(), 10);
                result += Utils.appendSpace(TRADE_TREND, 10) + "   ";
                result += Utils.getTypeOfEpic(EPIC) + "   ";
                result += Utils.appendSpace(EPIC, 10);
                result += Utils.appendSpace(trade.getTicket(), 10);
                result += ", Vol:" + Utils.appendLeft(Utils.removeLastZero(trade.getVolume()), 6) + "(lot)";
                result += ", Standard:"
                        + Utils.appendLeft(Utils.removeLastZero(Utils.get_standard_vol_per_100usd(EPIC)), 6) + "(lot)";
                result += "   Open: " + Utils.appendLeft(Utils.removeLastZero(trade.getPriceOpen()), 10);
                result += ", Profit: " + Utils.appendLeft(Utils.getStringValue(PROFIT.intValue()), 6) + "$";
                result += Utils.appendSpace(trend_reverse, 20);
                result += Utils.appendSpace(Utils.get_duration_trade_time(trade) + "   " + trade.getComment(), 60);
                result += Utils.appendSpace(Utils.getCapitalLink(EPIC), 62);

                total = total.add(PROFIT);
                msg += result + Utils.new_line_from_service;
            }

            if (Utils.isNotBlank(msg)) {
                msg = Utils.appendSpace(company, 15) + Utils.appendLeft(String.valueOf(total.intValue()), 10)
                        + risk_0_15 + Utils.new_line_from_service + msg;
                Utils.logWritelnDraft(msg.replace(Utils.new_line_from_service, "\n"));
            }
        }

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

    @SuppressWarnings("unused")
    private boolean is_opening_trade(String EPIC, String trend) {
        List<Mt5OpenTradeEntity> tradeList = mt5OpenTradeRepository.findAllBySymbolOrderByCompanyAsc(EPIC);

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
    public void get_total_loss_today() {
        String mt5_data_file_path = Utils.getMt5DataFolder() + "HistoryToday.csv";
        String mt5_data_file = check_mt5_data_file(mt5_data_file_path, Utils.MINUTES_RELOAD_CSV_DATA);
        if (Utils.isBlank(mt5_data_file)) {
            return;
        }
        // ------------------------------------------------------------------------
        String line;
        int total_line = 0;

        CLOSED_TRADE_TODAY = "";

        InputStream inputStream;
        try {
            inputStream = new FileInputStream(mt5_data_file);

            InputStreamReader reader = new InputStreamReader(inputStream, "UTF-8");
            List<TakeProfit> list = new ArrayList<TakeProfit>();

            BufferedReader fin = new BufferedReader(reader);
            while ((line = fin.readLine()) != null) {
                total_line += 1;

                if (total_line < 2) {
                    continue;
                }
                String[] tempArr = line.replace(".f", "").replace(".cash", "").replace(".pro", "").split("\\t");
                if (tempArr.length == 9) {

                    String open_date = tempArr[0].trim();
                    String symbol = tempArr[1].trim();
                    BigDecimal profit = Utils.getBigDecimal(tempArr[2].trim());
                    String trade_type = tempArr[3].trim();
                    String ticket = tempArr[4].trim();
                    BigDecimal open_price = Utils.getBigDecimal(tempArr[6].trim());
                    String status = tempArr[7].trim();

                    TakeProfit take_profit = new TakeProfit(ticket, symbol, trade_type, open_date, profit, open_price,
                            status);

                    list.add(take_profit);

                    String key = "(" + symbol + "_" + trade_type + ")";
                    if (!CLOSED_TRADE_TODAY.contains(key) && (profit.compareTo(BigDecimal.ZERO) > 0)) {
                        CLOSED_TRADE_TODAY += key.toUpperCase() + ":" + profit.intValue() + "$; ";
                    }
                }

                if (line.contains("OPEN_POSITIONS")) {
                    String str_loss = line.replace("OPEN_POSITIONS:", "");
                    OPEN_POSITIONS = Utils.getBigDecimal(str_loss);
                }
                if (line.contains("TOTAL_LOSS_TODAY")) {
                    String str_loss = line.replace("TOTAL_LOSS_TODAY:", "");
                    TOTAL_LOSS_TODAY = Utils.getBigDecimal(str_loss);
                }
            }

            // Remember to call close.
            // calling close on a BufferedReader/BufferedWriter
            // will automatically call close on its underlying stream
            fin.close();
            reader.close();
            inputStream.close();

            takeProfitRepository.saveAll(list);

        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    @Override
    @Transactional
    public void saveDailyPivotData() {
        String mt5_data_file_path = Utils.getMt5DataFolder() + "DailyPivot.csv";
        String mt5_data_file = check_mt5_data_file(mt5_data_file_path, Utils.MINUTES_RELOAD_CSV_DATA);
        if (Utils.isBlank(mt5_data_file)) {
            return;
        }
        // ------------------------------------------------------------------------
        String line;
        int total_line = 0;
        List<DailyRange> list = new ArrayList<DailyRange>();

        InputStream inputStream;
        try {
            inputStream = new FileInputStream(mt5_data_file);

            InputStreamReader reader = new InputStreamReader(inputStream, "UTF-8");

            BufferedReader fin = new BufferedReader(reader);
            while ((line = fin.readLine()) != null) {
                total_line += 1;

                if (total_line < 2) {
                    continue;
                }

                String[] tempArr = line.replace(".f", "").replace(".cash", "").replace(".pro", "").split("\\t");

                if (tempArr.length > 10) {
                    String yyyy_mm_dd = tempArr[0];
                    String symbol = tempArr[1];
                    String trend_w1 = tempArr[2];
                    BigDecimal w_close = Utils.getBigDecimal(tempArr[3]);
                    BigDecimal avg_amp_week = Utils.getBigDecimal(tempArr[4]);

                    BigDecimal upper_03 = Utils.getBigDecimal(tempArr[5]);
                    BigDecimal lower_03 = Utils.getBigDecimal(tempArr[6]);

                    BigDecimal upper_15 = Utils.getBigDecimal(tempArr[7]);
                    BigDecimal lower_15 = Utils.getBigDecimal(tempArr[8]);

                    BigDecimal upper_h1 = Utils.getBigDecimal(tempArr[9]);
                    BigDecimal lower_h1 = Utils.getBigDecimal(tempArr[10]);

                    BigDecimal upper_h4 = Utils.getBigDecimal(tempArr[11]);
                    BigDecimal lower_h4 = Utils.getBigDecimal(tempArr[12]);

                    BigDecimal upper_d1 = Utils.getBigDecimal(tempArr[13]);
                    BigDecimal lower_d1 = Utils.getBigDecimal(tempArr[14]);

                    BigDecimal d_close = Utils.getBigDecimal(tempArr[15]);
                    BigDecimal d_today_low = Utils.getBigDecimal(tempArr[16]);
                    BigDecimal d_today_hig = Utils.getBigDecimal(tempArr[17]);

                    BigDecimal amp_min_d1 = Utils.getBigDecimal(tempArr[18]);
                    BigDecimal amp_avg_h4 = Utils.getBigDecimal(tempArr[19]);

                    DailyRangeKey id = new DailyRangeKey(yyyy_mm_dd, symbol);
                    DailyRange daily = new DailyRange(id, trend_w1, w_close, avg_amp_week, upper_03, lower_03, upper_15,
                            lower_15, upper_h1, lower_h1, upper_h4, lower_h4, upper_d1, lower_d1, d_close, d_today_low,
                            d_today_hig, amp_min_d1, amp_avg_h4);

                    list.add(daily);
                }
            }

            // Remember to call close.
            // calling close on a BufferedReader/BufferedWriter
            // will automatically call close on its underlying stream
            fin.close();
            reader.close();
            inputStream.close();

        } catch (Exception e) {
            e.printStackTrace();
        }

        // ------------------------------------------------------------------------
        if (list.size() > 1) {
            dailyRangeRepository.saveAll(list);
        }
    }

    @Override
    @Transactional
    public void saveMt5Data(String filename, Integer MINUTES_OF_XX) {
        try {
            String mt5_data_file_path = Utils.getMt5DataFolder() + filename;
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

            InputStream inputStream = new FileInputStream(mt5_data_file);
            InputStreamReader reader = new InputStreamReader(inputStream, "UTF-8");

            BufferedReader fin = new BufferedReader(reader);
            while ((line = fin.readLine()) != null) {
                total_line += 1;

                String[] tempArr = line.replace(".f", "").replace(".cash", "").replace(".pro", "").split("\\t");

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
            inputStream.close();
            // ------------------------------------------------------------------------
            if (list.size() > 10) {
                List<Mt5DataCandle> nottodaylist = mt5DataCandleRepository
                        .findAllByCreateddateNot(Utils.getYYYYMMDD(0));
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
            }
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

    @Override
    public void createReport() {
        boolean exit = true;
        if (exit) {
            return;
        }

        // TODO: createReport
        File myObj = new File(Utils.getReportFilePath());
        myObj.delete();

        // ==================================================================================
        List<Orders> crypto_list = new ArrayList<Orders>();
        crypto_list.addAll(ordersRepository.getCrypto_D1());
        String msg_futu = "";
        String msg_switch_trend_d1 = "";
        List<String> list_crypto_log = new ArrayList<String>();

        int count = 1;
        for (Orders dto : crypto_list) {
            if (Objects.isNull(dto)) {
                continue;
            }
            String symbol = Utils.getEpicFromId(dto.getId());

            String type = "";
            if (Utils.COINS_FUTURES.contains(symbol)) {
                type = "  (Futures)   ";
            } else {
                type = "  (Spot   )   ";
            }

            if (Utils.isNotBlank(dto.getSwitch_trend()) && dto.getTrend_by_heiken1().contains(Utils.TREND_LONG)) {
                if (count > 20) {
                    msg_switch_trend_d1 += ".";
                } else {
                    msg_switch_trend_d1 += symbol + "; ";
                }
            }

            String log = "   " + Utils.appendLeft(String.valueOf(count), 3, "0") + "   "
                    + Utils.createLineCrypto(dto, symbol, type);
            list_crypto_log.add(log);
            count += 1;
        }

        if (isReloadAfter(Utils.MINUTES_OF_1H, "Switch_Trend_D1") && Utils.isNotBlank(msg_switch_trend_d1)
                && count > 0) {
            Utils.logWritelnDraft("");
            Utils.logWritelnDraft("");
            Utils.logWritelnDraft("");
            Utils.logWritelnDraft("Switch_Trend_D1 (" + count + "):" + msg_switch_trend_d1);
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
        List<BtcFutures> heiken_list_d = Utils.getHeikenList(Utils.loadData(SYMBOL, Utils.CRYPTO_TIME_D1, 55));
        if (CollectionUtils.isEmpty(heiken_list_d)) {
            Utils.logWritelnDraft("[initCryptoTrend] Not found: " + SYMBOL);
            return Utils.CRYPTO_TIME_H4;
        }

        String orderId_d1 = "CRYPTO_" + SYMBOL + Utils.PREFIX_D01;
        String trend_d = Utils.getTrendByHekenAshiList(heiken_list_d);
        String switch_d1 = Utils.switchTrendByMa1vs10(heiken_list_d);

        if (switch_d1.contains(Utils.TREND_LONG)) {
            createOrders(SYMBOL, orderId_d1, switch_d1, trend_d, heiken_list_d);

        } else if (Objects.equals(Utils.TREND_LONG, trend_d) && Utils.isAboveMALine(heiken_list_d, 10)
                && Utils.isAboveMALine(heiken_list_d, 50)) {
            createOrders(SYMBOL, orderId_d1, "", trend_d, heiken_list_d);

        } else {

            deleteOrders(orderId_d1);
        }

        // TODO: initCryptoTrend
        if (CRYPTO_LIST_BUYING.contains(SYMBOL)) {
            List<BtcFutures> heiken_list_h4 = Utils.getHeikenList(Utils.loadData(SYMBOL, Utils.CRYPTO_TIME_H4, 20));
            if (CollectionUtils.isEmpty(heiken_list_h4)) {
                return Utils.CRYPTO_TIME_H1;
            }
            if (!Utils.isAboveMALine(heiken_list_h4, 10)) {
                String msg_alert = " 🔻 (STOP_BUY)";
                String str_price = "("
                        + Utils.appendSpace(Utils.removeLastZero(heiken_list_h4.get(0).getCurrPrice()), 5) + ")";

                String log = Utils.appendSpace(Utils.getCryptoLink_Spot(SYMBOL), 70) + Utils.appendSpace(str_price, 15);

                msg_alert += Utils.appendSpace(SYMBOL, 10) + Utils.appendSpace(str_price, 10);
                msg_alert += ".D1:" + Utils.appendSpace(trend_d, 5);

                String EVENT_ID = "MSG_PER_HOUR" + SYMBOL + Utils.getCurrentYyyyMmDd_HH();
                sendMsgPerHour_OnlyMe(EVENT_ID, msg_alert);
                logMsgPerHour(EVENT_ID, msg_alert + log, Utils.MINUTES_OF_1H);
            }
        }

        return Utils.CRYPTO_TIME_H1;
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
            // String company_id = Utils.MT5_COMPANY_FTMO;
            // if (Objects.equals(company, "8CAP")) {
            // company_id = Utils.MT5_COMPANY_NEXT;
            // } else if (Objects.equals(company, "ALPHA")) {
            // company_id = Utils.MT5_COMPANY_ALPHA;
            // } else if (Objects.equals(company, "THE5ERS")) {
            // company_id = Utils.MT5_COMPANY_5ERS;
            // } else if (Objects.equals(company, "MFF")) {
            // company_id = Utils.MT5_COMPANY_MFF;
            // }

            String mt5_ftmo_trading_file_path = Utils.getMt5DataFolder() + "Trade.csv";
            String mt5_data_file = check_mt5_data_file(mt5_ftmo_trading_file_path, 3);
            if (Utils.isBlank(mt5_data_file)) {
                continue;
            }

            int row_count = 0;
            boolean has_open_trade = false;
            try {
                String line;
                InputStream inputStream = new FileInputStream(mt5_data_file);
                InputStreamReader reader = new InputStreamReader(inputStream, "UTF-8");

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
                        dto.setComment(Utils.getStringValue(tempArr[7]).trim());
                        dto.setVolume(Utils.roundDefault(Utils.getBigDecimal(tempArr[8])));
                        dto.setCurrPrice(Utils.roundDefault(Utils.getBigDecimal(tempArr[9])));
                        dto.setCompany(company);
                        tradeList.add(dto);
                        has_open_trade = true;
                    }
                }

                fin.close();
                reader.close();
                inputStream.close();
            } catch (IOException e) {
                e.printStackTrace();
            }

            // Đóng các lệnh đã close
            if (has_open_trade || (row_count == 1)) {
                List<Mt5OpenTradeEntity> mt5Openlist = mt5OpenTradeRepository
                        .findAllByCompanyOrderByCommentAscSymbolAsc(company);
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

        // ----------------------------------------------------------------------------------------------
        // ----------------------------------------Trailing----------------------------------------------
        // ----------------------------------------------------------------------------------------------
        try {
            String mt5_trailing_sl_file = Utils.getMt5DataFolder() + "TrailingStoploss.csv";
            try {
                // File myScap = new File(mt5_trailing_sl_file);
                // myScap.delete();
            } catch (Exception e) {
            }

            FileWriter writer = new FileWriter(mt5_trailing_sl_file, false);
            for (Mt5DataTrade trade : tradeList) {
                BigDecimal PROFIT = Utils.getBigDecimal(trade.getProfit());

                String TRADE_TREND = Objects.equals(trade.getType().toUpperCase(), Utils.TREND_LONG) ? Utils.TREND_LONG
                        : Objects.equals(trade.getType().toUpperCase(), Utils.TREND_SHOT) ? Utils.TREND_SHOT
                                : Utils.TREND_UNSURE;

                boolean allow_traning_stop = false;

                if ((PROFIT.compareTo(Utils.RISK_0_15_PERCENT) > 0)) {
                    if ((Objects.equals(TRADE_TREND, Utils.TREND_LONG)
                            && trade.getPriceOpen().compareTo(trade.getStopLoss()) > 0)) {
                        allow_traning_stop = true;
                    }
                    if ((Objects.equals(TRADE_TREND, Utils.TREND_SHOT)
                            && trade.getPriceOpen().compareTo(trade.getStopLoss()) < 0)) {
                        allow_traning_stop = true;
                    }
                }

                if ((PROFIT.compareTo(BigDecimal.valueOf(100)) > 0)) {
                    DailyRange dailyRange = get_DailyRange(trade.getSymbol());

                    if (Objects.nonNull(dailyRange) && !Objects.equals(TRADE_TREND, Utils.TREND_UNSURE)) {

                        BigDecimal amplitude = dailyRange.getAvg_amp_week();

                        if (Objects.equals(TRADE_TREND, Utils.TREND_LONG)) {
                            BigDecimal next_price = trade.getPriceOpen().add(amplitude);

                            if (trade.getCurrPrice().compareTo(next_price) > 0) {
                                allow_traning_stop = true;
                            }
                        }

                        if (Objects.equals(TRADE_TREND, Utils.TREND_SHOT)) {
                            BigDecimal next_price = trade.getPriceOpen().subtract(amplitude);

                            if (trade.getCurrPrice().compareTo(next_price) < 0) {
                                allow_traning_stop = true;
                            }
                        }

                    }
                }

                if (allow_traning_stop) {
                    StringBuilder sb = new StringBuilder();
                    sb.append(trade.getTicket()); // TICKET
                    sb.append('\t');
                    sb.append(trade.getPriceOpen()); // SL
                    sb.append('\t');
                    sb.append(trade.getTakeProfit()); // TP
                    sb.append('\n');
                    writer.write(sb.toString());

                    System.out.println("traning_stop:   " + trade.toString());
                } else {
                    if ("_CHFJPY_".contains(trade.getSymbol())) {
                        boolean debug = true;
                    }

                    if ((Utils.getBigDecimal(trade.getTakeProfit()).compareTo(BigDecimal.ZERO) < 1)
                            || (Utils.getBigDecimal(trade.getStopLoss()).compareTo(BigDecimal.ZERO) < 1)) {

                        List<DailyRange> ranges = dailyRangeRepository.findSymbolToday(trade.getSymbol());
                        if (CollectionUtils.isEmpty(ranges)) {
                            continue;
                        }

                        DailyRange dailyRange = ranges.get(0);
                        boolean init_tp = false;

                        BigDecimal stop_loss = trade.getStopLoss();
                        BigDecimal take_profit = trade.getTakeProfit();

                        // Ko cài SL
                        if (Utils.getBigDecimal(trade.getStopLoss()).compareTo(BigDecimal.ZERO) < 1) {
                            List<BigDecimal> sl_tp = Utils.get_SL_TP_by_amp(dailyRange, trade.getPriceOpen(),
                                    TRADE_TREND);
                            init_tp = true;
                            stop_loss = sl_tp.get(0);
                        }

                        // Ko cài TP
                        if (Utils.getBigDecimal(trade.getTakeProfit()).compareTo(BigDecimal.ZERO) < 1) {
                            List<BigDecimal> sl_tp = Utils.get_SL_TP_by_amp(dailyRange, trade.getCurrPrice(),
                                    TRADE_TREND);
                            init_tp = true;
                            take_profit = sl_tp.get(1);
                        }

                        if (init_tp) {
                            StringBuilder sb = new StringBuilder();
                            sb.append(trade.getTicket()); // TICKET
                            sb.append('\t');
                            sb.append(stop_loss); // SL
                            sb.append('\t');
                            sb.append(take_profit); // TP
                            sb.append('\n');
                            writer.write(sb.toString());
                        }
                    }

                }
            }
            writer.close();
        } catch (Exception e) {
            System.out.println(e.getMessage());
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
            String comment = trade.getComment();
            String timeframe = Utils.getDeEncryptedChartNameCapital(comment);

            // ----------------------------------------------------------------------------------
            Mt5OpenTradeEntity entity = mt5OpenTradeRepository.findById(trade.getTicket()).orElse(null);
            if (Objects.isNull(entity)) {

                entity = new Mt5OpenTradeEntity();
                entity.setTicket(trade.getTicket());
                entity.setSymbol(EPIC);
                entity.setPriceOpen(trade.getPriceOpen());

            } else {
                if (Utils.getBigDecimal(trade.getStopLoss()).compareTo(BigDecimal.ZERO) > 0) {
                    entity.setStopLoss(trade.getStopLoss());
                }

                if (Utils.getBigDecimal(trade.getTakeProfit()).compareTo(BigDecimal.ZERO) > 0) {
                    entity.setTakeProfit(trade.getTakeProfit());
                }
            }
            entity.setSymbol(EPIC);
            entity.setComment(comment);
            entity.setProfit(trade.getProfit());
            entity.setType(trade.getType());
            entity.setVolume(trade.getVolume());
            entity.setStopLoss(trade.getStopLoss());
            entity.setTakeProfit(trade.getTakeProfit());
            entity.setCurrprice(trade.getCurrPrice());
            entity.setCompany(trade.getCompany());
            entity.setComment(Utils.getStringValue(trade.getComment()));

            if (Utils.isBlank(entity.getOpenTime())) {
                entity.setOpenTime(date_time);
            }
            entity.setTimeframe(timeframe);

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

        List<BtcFutures> list = getCapitalData(EPIC, CAPITAL_TIME_XX);
        List<BtcFutures> heiken_list = Utils.getHeikenList(list);
        if (CollectionUtils.isEmpty(heiken_list)) {
            return "";
        }
        List<BigDecimal> amplitutes = Utils.calc_amplitude_average_of_candles(list);
        BigDecimal amp_avg_h4 = amplitutes.get(1);
        BigDecimal curr_price = list.get(0).getCurrPrice();

        BigDecimal ma3 = Utils.calcMA(heiken_list, 3, 0);
        BigDecimal ma6 = Utils.calcMA(heiken_list, 6, 0);
        BigDecimal ma9 = Utils.calcMA(heiken_list, 9, 0);

        String trend_by_heiken1 = Utils.getTrendByHekenAshiList(heiken_list);
        String trend_by_ma_6 = Utils.isUptrendByMa(heiken_list, 6) ? Utils.TREND_LONG : Utils.TREND_SHOT;
        String trend_by_ma_9 = Utils.isUptrendByMa(heiken_list, 9) ? Utils.TREND_LONG : Utils.TREND_SHOT;
        String trend_by_ma_20 = Utils.getTrendByMaXx(heiken_list, 20);

        String trend_by_ma_89 = "Allow :" + Utils.TREND_LONG + "_" + Utils.TREND_SHOT;
        if (heiken_list.size() > 50) {
            DailyRange dailyRange = get_DailyRange(EPIC);
            if (Objects.nonNull(dailyRange)) {

                BigDecimal ma34 = Utils.calcMA(heiken_list, 34, 1);
                BigDecimal ma89 = Utils.calcMA(heiken_list, heiken_list.size(), 1);

                BigDecimal amp_w_x2 = dailyRange.getAvg_amp_week().multiply(BigDecimal.valueOf(2));
                BigDecimal hig_w = ma89.add(amp_w_x2);
                BigDecimal low_w = ma89.subtract(amp_w_x2);

                if (Utils.EPICS_FOREXS_ALL.contains(EPIC) && (low_w.compareTo(curr_price) < 0)
                        && curr_price.compareTo(hig_w) < 0) {
                    if ((curr_price.compareTo(ma34) > 0) && (curr_price.compareTo(ma89) > 0)) {
                        trend_by_ma_89 = "maOnly:" + Utils.TREND_LONG;

                    } else if ((curr_price.compareTo(ma34) < 0) && (curr_price.compareTo(ma89) < 0)) {
                        trend_by_ma_89 = "maOnly:" + Utils.TREND_SHOT;
                    }
                }
                if (!Utils.EPICS_FOREXS_ALL.contains(EPIC)) {
                    if ((curr_price.compareTo(ma34) > 0) && (curr_price.compareTo(ma89) > 0)) {
                        trend_by_ma_89 = "maOnly:" + Utils.TREND_LONG;

                    } else if ((curr_price.compareTo(ma34) < 0) && (curr_price.compareTo(ma89) < 0)) {
                        trend_by_ma_89 = "maOnly:" + Utils.TREND_SHOT;
                    }
                }
            }
        }

        String trend_compared_to_center_previous_candle = "";
        if (Objects.equals(CAPITAL_TIME_XX, Utils.CAPITAL_TIME_H4)) {
            BigDecimal c1_open = list.get(1).getPrice_open_candle();
            BigDecimal c1_close = list.get(1).getPrice_close_candle();
            BigDecimal c1_mid = (c1_open.subtract(c1_close).abs()).multiply(BigDecimal.valueOf(0.5));
            if (c1_open.compareTo(c1_close) > 0) {
                c1_mid = c1_close.add(c1_mid);
            } else {
                c1_mid = c1_open.add(c1_mid);
            }
            if (curr_price.compareTo(c1_mid) > 0) {
                trend_compared_to_center_previous_candle = Utils.TREND_SHOT;
            }
            if (curr_price.compareTo(c1_mid) < 0) {
                trend_compared_to_center_previous_candle = Utils.TREND_LONG;
            }
            if ("_CHFJPY_".contains(EPIC)) {
                boolean debug = true;
            }
        }
        // ----------------------------TREND------------------------

        // TODO: 1. initForexTrend
        String switch_trend = "";
        String trend_by_seq_ma = "";

        if (CAPITAL_TIME_XX.contains("HOUR_")) {
            switch_trend += Utils.switchTrendByMa1vs10(heiken_list);
            switch_trend += Utils.switchTrendByMa1vs2025(heiken_list);

            if (!switch_trend.contains(Utils.TEXT_SEQ)) {
                switch_trend += Utils.switch_trend_seq_1_6_10_20(heiken_list);
            }
        } else if (CAPITAL_TIME_XX.contains("MINUTE_")) {
            switch_trend += Utils.switchTrendByMa1vs50(heiken_list);
            switch_trend += Utils.switch_trend_seq_1_10_20_50(heiken_list, amp_avg_h4);
        } else {
            switch_trend += Utils.switchTrendByMa1vs10(heiken_list);
        }

        if (Objects.equals(CAPITAL_TIME_XX, Utils.CAPITAL_TIME_03)) {
            switch_trend += Utils.switchTrendByMa1vs10(heiken_list);
            switch_trend += Utils.switchTrendByMa1vs2025(heiken_list);
        }

        switch_trend += Utils.switchTrendByMa6vs9(heiken_list);
        if (Objects.equals(CAPITAL_TIME_XX, Utils.CAPITAL_TIME_D1)) {
            switch_trend += Utils.switchTrendByMa3_2_1(heiken_list);
        }

        // ---------------------------------------------------------------------------
        if (CAPITAL_TIME_XX.contains("MINUTE_")) {
            trend_by_seq_ma += Utils.trend_by_seq_ma_1_10_20_50(heiken_list, amp_avg_h4);
        } else {
            trend_by_seq_ma += Utils.trend_by_seq_ma_6_10_20(heiken_list);
        }

        // -----------------------------DATABASE---------------------------
        String id = EPIC + "_" + CAPITAL_TIME_XX;
        String insertTime = LocalDateTime.now().toString();

        List<BigDecimal> lohi = Utils.getLowHighCandle(heiken_list);
        BigDecimal low_50candle = lohi.get(0);
        BigDecimal hig_50candle = lohi.get(1);

        BigDecimal amplitude_1_part_15 = (hig_50candle.subtract(low_50candle)).multiply(BigDecimal.valueOf(0.0666666));

        BigDecimal tp_long = hig_50candle.subtract(amplitude_1_part_15);
        BigDecimal tp_shot = low_50candle.add(amplitude_1_part_15);

        int size = heiken_list.size();
        if (size > 33) {
            size = 33;
        }
        List<BigDecimal> body = Utils.getBodyCandle(heiken_list.subList(3, size));
        BigDecimal body_low_30_candle = body.get(0);
        BigDecimal body_hig_30_candle = body.get(1);

        String trend_by_bread_area = "";
        if (curr_price.compareTo(body_low_30_candle) <= 0) {
            trend_by_bread_area = "(bread_area)" + Utils.TREND_LONG;
        }
        if (curr_price.compareTo(body_hig_30_candle) >= 0) {
            trend_by_bread_area = "(bread_area)" + Utils.TREND_SHOT;
        }

        BigDecimal bread = Utils.calcMaxBread(heiken_list);
        if (bread.compareTo(amplitude_1_part_15) < 0) {
            bread = amplitude_1_part_15;
        }

        String heiken_zone = Utils.countCandlesMatchingCondition(heiken_list);

        BigDecimal close_candle_1 = list.get(1).getPrice_close_candle();
        BigDecimal close_candle_2 = list.get(2).getPrice_close_candle();

        BigDecimal lowest_price_of_curr_candle = heiken_list.get(0).getLow_price();
        BigDecimal highest_price_of_curr_candle = heiken_list.get(0).getHight_price();

        if (Utils.isPinBar(heiken_list.get(0))) {
            trend_by_heiken1 = Utils.TREND_UNSURE + "_" + CAPITAL_TIME_XX;
        }

        Orders entity = new Orders(id, insertTime, trend_by_heiken1, curr_price, tp_long, tp_shot, close_candle_1,
                close_candle_2, switch_trend, trend_by_ma_9, heiken_zone, trend_by_ma_6, trend_by_ma_20, trend_by_ma_89,
                trend_by_seq_ma, trend_by_bread_area, body_hig_30_candle, body_low_30_candle, amplitude_1_part_15,
                amp_avg_h4, ma6, ma3, ma9, low_50candle, hig_50candle, lowest_price_of_curr_candle,
                highest_price_of_curr_candle, trend_compared_to_center_previous_candle);

        ordersRepository.save(entity);

        return "";
    }

    @Override
    @Transactional
    public int controlMt5(List<String> CAPITAL_LIST) {
        if (required_update_bars_csv) {
            // return 0;
        }

        int count = 0;
        Collections.sort(CAPITAL_LIST);
        for (String EPIC : CAPITAL_LIST) {
            if (BscScanBinanceApplication.EPICS_OUTPUTED_LOG.contains(EPIC)) {
                continue;
            }

            Orders dto_w1 = ordersRepository.findById(EPIC + "_" + Utils.CAPITAL_TIME_W1).orElse(null);
            Orders dto_d1 = ordersRepository.findById(EPIC + "_" + Utils.CAPITAL_TIME_D1).orElse(null);
            Orders dto_h4 = ordersRepository.findById(EPIC + "_" + Utils.CAPITAL_TIME_H4).orElse(null);
            Orders dto_h1 = ordersRepository.findById(EPIC + "_" + Utils.CAPITAL_TIME_H1).orElse(null);

            Orders dto_15 = ordersRepository.findById(EPIC + "_" + Utils.CAPITAL_TIME_15).orElse(null);
            Orders dto_05 = ordersRepository.findById(EPIC + "_" + Utils.CAPITAL_TIME_03).orElse(dto_15);

            DailyRange dailyRange = get_DailyRange(EPIC);

            if (Objects.isNull(dailyRange) || Objects.isNull(dto_w1) || Objects.isNull(dto_d1) || Objects.isNull(dto_h4)
                    || Objects.isNull(dto_h1) || Objects.isNull(dto_15) || Objects.isNull(dto_05)) {
                String str_null = "";
                str_null += "DailyRange:" + (Objects.isNull(dailyRange) ? "isEmpty" : "       ");
                str_null += " W1:" + (Objects.isNull(dto_w1) ? "null" : "    ");
                str_null += " D1:" + (Objects.isNull(dto_d1) ? "null" : "    ");
                str_null += " H4:" + (Objects.isNull(dto_h4) ? "null" : "    ");
                str_null += " H1:" + (Objects.isNull(dto_h1) ? "null" : "    ");
                str_null += " 15:" + (Objects.isNull(dto_15) ? "null" : "    ");
                str_null += " 03:" + (Objects.isNull(dto_05) ? "null" : "    ");

                Utils.logWritelnDraft(
                        String.format("[controlMt5] dto (%s): %s.", Utils.appendSpace(EPIC, 10), str_null));

                continue;
            }

            count += 1;
            String No = Utils.appendLeft(String.valueOf(count), 2, "0") + ". ";

            BigDecimal curr_price = dto_h1.getCurrent_price();

            String trend_d1_ma6 = dto_d1.getTrend_by_ma_6();

            // ---------------------------------------------------------------------------------------------

            // --------------------------------------------
            String amp = " ";
            BigDecimal amp_avg_h4 = dailyRange.getAmp_avg_h4();
            amp += "(amp):" + Utils.appendSpace(Utils.calculatePoints(EPIC, amp_avg_h4), 6);
            amp += "(avg_w):" + Utils.appendSpace(Utils.calculatePoints(EPIC, dailyRange.getAvg_amp_week()), 6);
            amp += "   ";

            String st_d1 = dto_d1.getSwitch_trend().contains(trend_d1_ma6)
                    ? "D1" + Utils.getType(trend_d1_ma6)
                    : "   ";
            String st_h4 = (dto_h4.getSwitch_trend().contains(Utils.TEXT_SWITCH_TREND_Ma69)
                    || dto_h4.getSwitch_trend().contains(Utils.TEXT_SWITCH_TREND_Ma_1vs20))
                            ? "H4" + Utils.getType(dto_h4.getTrend_by_ma_6())
                            : "   ";
            amp += Utils.appendSpace("~" + st_d1 + " " + st_h4 + "~", 10);

            String trend_d1_ma369 = Utils.find_trend_by_ma3_6_9(dto_d1);
            String trend_h4_ma369 = Utils.find_trend_by_ma3_6_9(dto_h4);
            String trend_h1_ma369 = Utils.find_trend_by_ma3_6_9(dto_h1);
            String trend_15_ma369 = Utils.find_trend_by_ma3_6_9(dto_15);
            String trend_05_ma369 = Utils.find_trend_by_ma3_6_9(dto_05);

            String pin_bar = "        ";
            boolean allow_trend_following = false;
            String find_trend = dto_d1.getTrend_by_heiken1();
            if (find_trend.contains(Utils.TREND_UNSURE)) {
                find_trend = trend_h4_ma369;
                pin_bar = " PinBar ";
            } else if (Objects.equals(trend_h4_ma369, dto_d1.getTrend_by_bread_area())) {
                find_trend = trend_h4_ma369;
                pin_bar = " BreadD ";
            }

            String str_369 = pin_bar + Utils.getType(" D1:", find_trend, find_trend).toUpperCase() + " ";
            str_369 += "(Seq)";
            str_369 += Utils.getType(" H4:", trend_h4_ma369, find_trend);
            str_369 += Utils.getType(" H1:", trend_h1_ma369, find_trend);
            str_369 += Utils.getType(" 15:", trend_15_ma369, find_trend);
            str_369 += Utils.getType(" 05:", trend_05_ma369, find_trend);

            String prefix = "  " + No + amp + str_369;

            String trend_folow = "";
            String append_eoz = "";

            // TODO: 3 controlMt5
            // vào lệnh từ 06h~10h: lãi thì chốt hết từ 11h trở đi.
            // vào lệnh từ 13h~15h: lãi thì chốt từ 16h trở đi.
            // vào lệnh từ 18h~20h: lãi thì chốt từ 22h trở đi.
            if ("_USDCAD_".contains(EPIC)) {
                boolean debug = true;
            }

            boolean h4_d1_allow = Objects.equals(trend_h1_ma369, trend_h4_ma369)
                    && Objects.equals(trend_h1_ma369, find_trend);

            boolean d1_h4_allow = Objects.equals(trend_h1_ma369, dto_h4.getTrend_by_ma_6())
                    && Objects.equals(trend_h1_ma369, find_trend);

            if (dto_h1.getTrend_by_ma_89().contains(find_trend) && (h4_d1_allow || d1_h4_allow)) {
                allow_trend_following = true;
                trend_folow = find_trend;
            }
            if (!trend_d1_ma369.contains(Utils.TREND_UNSURE)
                    && !Objects.equals(find_trend, trend_d1_ma369)) {
                allow_trend_following = false;
            }
            if (Utils.EPICS_INDEXS_CFD.contains(EPIC)
                    && !Objects.equals(dto_w1.getTrend_by_heiken1(), find_trend)) {
                allow_trend_following = false;
            }

            boolean is_able_tp_h4 = Utils.is_able_to_trade_by_h4(dto_h4, dailyRange, find_trend);
            if (!is_able_tp_h4) {
                append_eoz += "  EOZ:" + Utils.getType(find_trend).toUpperCase();
            }

            // TREND_FLOWING
            Mt5OpenTrade dto_notifiy = null;
            if (Objects.isNull(dto_notifiy) && allow_trend_following && is_able_tp_h4) {

                boolean allow_trade_now = Objects.equals(find_trend, trend_15_ma369)
                        && Objects.equals(find_trend, trend_05_ma369);

                boolean is_best_price = Utils.is_best_prirce(dto_05, find_trend, curr_price)
                        || Utils.is_best_prirce(dto_15, find_trend, curr_price);

                if (allow_trade_now || is_best_price) {
                    close_reverse_trade(EPIC, find_trend);

                    List<TakeProfit> his_list_folow_d369 = takeProfitRepository
                            .findAllBySymbolAndTradeTypeAndOpenDate(EPIC, find_trend,
                                    Utils.getYyyyMMdd());

                    if (CollectionUtils.isEmpty(his_list_folow_d369)
                            || (is_best_price && (his_list_folow_d369.size() < 3))) {

                        int trade_count = 1;

                        dto_notifiy = Utils.calc_Lot_En_SL_TP(EPIC, find_trend, dto_h1,
                                Utils.TEXT_TREND_FLOWING + Utils.TEXT_PASS, true, Utils.CAPITAL_TIME_H1, dailyRange,
                                trade_count);

                        String key = EPIC + Utils.CAPITAL_TIME_H1;
                        BscScanBinanceApplication.mt5_open_trade_List.add(dto_notifiy);
                        BscScanBinanceApplication.dic_comment.put(key, dto_notifiy.getComment());
                    }
                }
            }

            // -----------------------------------------------------------------------------------------------
            boolean is_tradable_zone = dto_h1.getHeiken_zone().contains(trend_h1_ma369)
                    && dto_h4.getHeiken_zone().contains(trend_h1_ma369);
            if (!is_tradable_zone) {
                String ashi = "  ashi41:NG";
                if (dto_h4.getHeiken_zone().contains(trend_h1_ma369)) {
                    ashi = ashi.replace("4", "0");
                }
                if (dto_h1.getHeiken_zone().contains(trend_h1_ma369)) {
                    ashi = ashi.replace("1", "0");
                }
                append_eoz += ashi;
            }
            if (!allow_trend_following) {
                append_eoz = Utils.appendSpace("", append_eoz.length());
            }

            List<TakeProfit> total_trade_list = takeProfitRepository.findAllBySymbolAndOpenDateAndStatus(EPIC,
                    Utils.getYyyyMMdd(), "CLOSED");

            String str_profit = "";
            {
                BigDecimal t_profit = BigDecimal.ZERO;
                if (total_trade_list.size() > 0) {
                    str_profit += "T:" + Utils.appendLeft(Utils.getStringValue(total_trade_list.size()), 2);

                    for (TakeProfit dto : total_trade_list) {
                        t_profit = t_profit.add(dto.getProfit());
                    }
                    str_profit += "/P:" + Utils.appendLeft(Utils.getStringValue(t_profit.intValue()), 3) + "$";
                } else {
                    str_profit = ".";
                }
                str_profit = Utils.appendSpace(str_profit, 15);
            }

            analysis_profit(str_profit + prefix, EPIC, append_eoz, dailyRange, trend_folow, curr_price,
                    dto_h4.getTrend_by_ma_89(), dto_h1.getHeiken_zone() + "    " + dto_h4.getHeiken_zone() + pin_bar);

            BscScanBinanceApplication.EPICS_OUTPUTED_LOG += "_" + EPIC + "_";
        }

        return count;

    }

    @Override
    public void closeTrade_by_SL_TP() {
        get_total_loss_today();
        Utils.logWritelnDraft(CLOSED_TRADE_TODAY);

        if (BscScanBinanceApplication.mt5_open_trade_List.size() > 0) {
            Utils.logWritelnDraft("");
        }
        // -----------------------------------------------------------------------------------
        // -----------------------------------------------------------------------------------
        List<String> CAPITAL_LIST = new ArrayList<String>();
        CAPITAL_LIST.addAll(Utils.EPICS_INDEXS_CFD);
        CAPITAL_LIST.addAll(Utils.EPICS_FOREXS_ALL);
        Collections.sort(CAPITAL_LIST);

        String msg = "";
        String keys = "";
        List<Mt5OpenTradeEntity> mt5Openlist = mt5OpenTradeRepository.findAllByOrderByCompanyAscSymbolAsc();
        for (Mt5OpenTradeEntity trade : mt5Openlist) {
            String EPIC = trade.getSymbol();
            String TICKET = trade.getTicket();
            BigDecimal PROFIT = Utils.getBigDecimal(trade.getProfit());

            if (Objects.equals(EPIC, "DX.F")) {
                EPIC = "DX";
            }
            if (Utils.EPICS_STOCKS_EUR.contains(EPIC) && !Utils.is_london_session()) {
                continue;
            }
            if (Utils.EPICS_STOCKS_USA.contains(EPIC) && !Utils.is_newyork_session()) {
                continue;
            }

            Orders dto_d1 = ordersRepository.findById(EPIC + "_" + Utils.CAPITAL_TIME_D1).orElse(null);
            Orders dto_h4 = ordersRepository.findById(EPIC + "_" + Utils.CAPITAL_TIME_H4).orElse(null);
            Orders dto_h1 = ordersRepository.findById(EPIC + "_" + Utils.CAPITAL_TIME_H1).orElse(null);
            Orders dto_15 = ordersRepository.findById(EPIC + "_" + Utils.CAPITAL_TIME_15).orElse(null);
            Orders dto_03 = ordersRepository.findById(EPIC + "_" + Utils.CAPITAL_TIME_03).orElse(null);

            if (Objects.isNull(dto_d1) || Objects.isNull(dto_h4) || Objects.isNull(dto_h1) || Objects.isNull(dto_15)
                    || Objects.isNull(dto_03)) {
                String str_null = "";
                str_null += " d1:" + (Objects.isNull(dto_d1) ? "null" : "    ");
                str_null += " h4:" + (Objects.isNull(dto_h4) ? "null" : "    ");
                str_null += " h1:" + (Objects.isNull(dto_h1) ? "null" : "    ");
                str_null += " 15:" + (Objects.isNull(dto_15) ? "null" : "    ");
                str_null += " 03:" + (Objects.isNull(dto_03) ? "null" : "    ");

                Utils.logWritelnDraft(String.format("[closetrade_by_sl_tp_take_profit] dto (%s): %s.",
                        Utils.appendSpace(EPIC, 10), str_null));

                continue;
            }

            String TRADING_TREND = Objects.equals(trade.getType().toUpperCase(), Utils.TREND_LONG) ? Utils.TREND_LONG
                    : Objects.equals(trade.getType().toUpperCase(), Utils.TREND_SHOT) ? Utils.TREND_SHOT
                            : Utils.TREND_UNSURE;

            String REVERSE_TRADE_TREND = TRADING_TREND.contains(Utils.TREND_LONG) ? Utils.TREND_SHOT : Utils.TREND_LONG;

            if ("_GBPCHF_".contains(EPIC)) {
                boolean debug = true;
            }

            boolean has_profit_10 = PROFIT.compareTo(BigDecimal.valueOf(10)) > 0;
            boolean has_profit_30 = PROFIT.compareTo(BigDecimal.valueOf(30)) > 0;

            String trend_h4_369 = Utils.find_trend_by_ma3_6_9(dto_h4);
            String trend_h1_369 = Utils.find_trend_by_ma3_6_9(dto_h1);
            String trend_15_369 = Utils.find_trend_by_ma3_6_9(dto_15);
            String trend_03_369 = Utils.find_trend_by_ma3_6_9(dto_03);

            boolean reverse_h4_369 = Objects.equals(trend_h4_369, REVERSE_TRADE_TREND);
            boolean reverse_h1_369 = Objects.equals(trend_h1_369, REVERSE_TRADE_TREND);
            boolean reverse_15_369 = Objects.equals(trend_15_369, REVERSE_TRADE_TREND);
            boolean reverse_05_369 = Objects.equals(trend_03_369, REVERSE_TRADE_TREND)
                    && Objects.equals(dto_15.getTrend_by_heiken1(), REVERSE_TRADE_TREND);
            // -------------------------------------------------------------------------------------
            boolean is_hit_sl = false;

            String reason_id = "";
            // -------------------------------------------------------------------------------------
            // Bảo vệ tài khoản tránh thua sạch tiền tích góp trong 53 ngày: -$6,133.97
            if ((OPEN_POSITIONS.add(BigDecimal.valueOf(1000)).compareTo(BigDecimal.ZERO) < 0)
                    || (TOTAL_LOSS_TODAY.add(BigDecimal.valueOf(1000)).compareTo(BigDecimal.ZERO) < 0)) {
                if (reverse_h1_369 && reverse_15_369 && reverse_05_369) {
                    if (allow_open_or_close_trade_after(TICKET, Utils.MINUTES_OF_2H)) {
                        is_hit_sl = true;
                        reason_id += "(H1_STOPLOSS:ACCOUNT_PROTECTION)";
                        String reason = "stoploss:" + Utils.appendLeft(String.valueOf(PROFIT.intValue()), 5)
                                + "$(OPEN_POSITIONS)" + OPEN_POSITIONS + "$";

                        BscScanBinanceApplication.mt5_close_ticket_dict.put(TICKET, reason);
                    }
                }
            }
            if (reverse_h4_369 && reverse_h1_369 && reverse_15_369 && reverse_05_369) {
                if (allow_open_or_close_trade_after(TICKET, Utils.MINUTES_OF_2H)) {
                    is_hit_sl = true;
                    reason_id += "(H4_STOPLOSS:ACCOUNT_PROTECTION)";
                    BscScanBinanceApplication.mt5_close_ticket_dict.put(TICKET, reason_id);
                }
            }
            if (Objects.equals(dto_d1.getTrend_by_ma_6(), REVERSE_TRADE_TREND)
                    && Objects.equals(dto_d1.getTrend_by_heiken1(), REVERSE_TRADE_TREND)
                    && Objects.equals(dto_h4.getTrend_by_ma_6(), REVERSE_TRADE_TREND)
                    && Objects.equals(dto_h1.getTrend_by_ma_6(), REVERSE_TRADE_TREND)
                    && Objects.equals(dto_15.getTrend_by_ma_6(), REVERSE_TRADE_TREND)) {
                if (allow_open_or_close_trade_after(TICKET, Utils.MINUTES_OF_2H)) {
                    is_hit_sl = true;
                    reason_id += "(D1_STOPLOSS:ACCOUNT_PROTECTION)";
                    BscScanBinanceApplication.mt5_close_ticket_dict.put(TICKET, reason_id);
                }
            }
            // -------------------------------------------------------------------------------------
            if (has_profit_10) {
                if ((has_profit_30 && reverse_05_369)
                        || (reverse_15_369 && reverse_05_369)
                        || (Utils.is_close_trade_time() && reverse_05_369)
                        || Utils.is_close_jpy_trade_at_3am(EPIC)) {
                    is_hit_sl = true;
                    reason_id += "(has_profit)";
                }
            }
            // -------------------------------------------------------------------------------------
            if ((PROFIT.add(BigDecimal.valueOf(100)).compareTo(BigDecimal.ZERO) < 0)) {
                int total_trade = 0;
                if (Objects.equals(trend_15_369, TRADING_TREND)
                        && Objects.equals(dto_h1.getTrend_by_heiken1(), TRADING_TREND)
                        && Objects.equals(dto_15.getTrend_by_heiken1(), TRADING_TREND)
                        && Objects.equals(dto_03.getTrend_by_heiken1(), TRADING_TREND)) {
                    total_trade = 2;
                }
                if (PROFIT.add(BigDecimal.valueOf(280)).compareTo(BigDecimal.ZERO) < 0) {
                    total_trade = 3;
                }
                total_trade = 0;
                if (total_trade > 0) {
                    List<TakeProfit> his_list_folow_d369 = takeProfitRepository
                            .findAllBySymbolAndTradeTypeAndOpenDate(EPIC, TRADING_TREND, Utils.getYyyyMMdd());

                    if (his_list_folow_d369.size() < 3) {
                        DailyRange dailyRange = get_DailyRange(EPIC);
                        if (Objects.nonNull(dailyRange)) {
                            Mt5OpenTrade dto_notifiy = Utils.calc_Lot_En_SL_TP(EPIC, TRADING_TREND, dto_h1,
                                    "_nhoi" + total_trade + Utils.TEXT_PASS, true, Utils.CAPITAL_TIME_H1, dailyRange,
                                    total_trade);
                            dto_notifiy.setLots(trade.getVolume());

                            String key = EPIC + Utils.CAPITAL_TIME_H1;
                            BscScanBinanceApplication.mt5_open_trade_List.add(dto_notifiy);
                            BscScanBinanceApplication.dic_comment.put(key, dto_notifiy.getComment());
                        }
                    }
                }
            }
            // -------------------------------------------------------------------------------------
            // TODO: 5 closeTrade_by_SL_TP
            // -------------------------------------------------------------------------------------
            if (is_hit_sl) {
                List<Mt5OpenTradeEntity> tradeList = mt5OpenTradeRepository.findAllBySymbolOrderByCompanyAsc(EPIC);
                for (Mt5OpenTradeEntity entity : tradeList) {
                    if (!Objects.equals(entity.getTicket(), TICKET)) {
                        if (entity.getProfit().compareTo(BigDecimal.valueOf(5)) > 0) {
                            String reason = "close_group:" + Utils.appendLeft(PROFIT.intValue(), 5) + "$";
                            BscScanBinanceApplication.mt5_close_ticket_dict.put(entity.getTicket(), reason);
                        }
                    }
                }
            }

            boolean pass_time_hoding = allow_open_or_close_trade_after(TICKET, Utils.MINUTES_OF_4H)
                    || (has_profit_10 && allow_open_or_close_trade_after(TICKET, Utils.MINUTES_OF_2H));

            if (is_hit_sl && pass_time_hoding) {
                String reason = "Profit:" + Utils.appendLeft(String.valueOf(PROFIT.intValue()), 5) + "$   "
                        + Utils.appendSpace(trade.getComment(), 30) + reason_id;

                String log = Utils.createCloseTradeMsg(trade, "CloseTrade: ", reason);
                Utils.logWritelnDraft(log);

                // --------------------------------------------------------------------------

                BscScanBinanceApplication.mt5_close_ticket_dict.put(TICKET, reason_id);
            }
        }

        if (Utils.isNotBlank(msg)) {
            String EVENT_ID = "CLOSE_TRADE" + Utils.getCurrentYyyyMmDd_HH() + keys;
            sendMsgPerHour_OnlyMe(EVENT_ID, Utils.new_line_from_service + msg);
        }

        // ----------------------------------------------------------------------------------------------
        // ---------------------------------------Open_trade--------------------------------------------
        // ----------------------------------------------------------------------------------------------
        Utils.logWritelnDraft("");

        openTrade();
    }

}

// 8-10-13-17-21-26-34
// Lỗi chung:
//1) Không nhìn biều đồ lớn đánh mất tổng quan.
//2) Không cắt lỗ, không quản trị vốn, cố vào biểu đồ bé cố tìm lệnh.
//3) Quan trọng nhất là khối lượng tiền lớn chứ không phải % tăng giá.
