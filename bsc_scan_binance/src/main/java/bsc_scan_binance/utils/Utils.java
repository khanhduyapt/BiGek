package bsc_scan_binance.utils;

import java.io.File;
import java.io.FileWriter;
import java.io.IOException;
import java.math.BigDecimal;
import java.math.BigInteger;
import java.math.RoundingMode;
import java.net.InetAddress;
import java.net.URL;
import java.net.URLConnection;
import java.net.UnknownHostException;
import java.sql.Timestamp;
import java.text.DateFormat;
import java.text.SimpleDateFormat;
import java.time.DayOfWeek;
import java.time.Instant;
import java.time.LocalDate;
import java.time.temporal.ChronoField;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.Calendar;
import java.util.Date;
import java.util.Formatter;
import java.util.Iterator;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Locale;
import java.util.Objects;
import java.util.TimeZone;

import javax.servlet.http.HttpServletRequest;

import org.json.JSONArray;
import org.json.JSONObject;
import org.springframework.context.MessageSource;
import org.springframework.http.HttpEntity;
import org.springframework.http.HttpHeaders;
import org.springframework.http.HttpMethod;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.util.CollectionUtils;
import org.springframework.web.client.RestTemplate;
import org.springframework.web.servlet.LocaleResolver;

import bsc_scan_binance.BscScanBinanceApplication;
import bsc_scan_binance.entity.BtcFutures;
import bsc_scan_binance.entity.PrepareOrders;
import bsc_scan_binance.response.BtcFuturesResponse;
import bsc_scan_binance.response.CandidateTokenCssResponse;
import bsc_scan_binance.response.DepthResponse;
import bsc_scan_binance.response.FundingResponse;
import bsc_scan_binance.response.OrdersProfitResponse;

//@Slf4j
public class Utils {
    public static final String chatId_duydk = "5099224587";
    public static final String chatUser_duydk = "tg25251325";

    public static final String chatId_linkdk = "816816414";
    public static final String chatUser_linkdk = "LokaDon";

    public static final String new_line_from_bot = "\n";
    public static final String new_line_from_service = "%0A";

    public static final int const_app_flag_msg_on = 1; // 1: msg_on; 2: msg_off; 3: web only; 4: all coin
    public static final int const_app_flag_Future_msg_off = 2;
    public static final int const_app_flag_webonly = 3;
    public static final int const_app_flag_all_coin = 4;
    public static final int const_app_flag_all_and_msg = 5;

    public static final String PREPARE_ORDERS_DATA_TYPE_BOT = "1";
    public static final String PREPARE_ORDERS_DATA_TYPE_BINANCE_VOL_UP = "2";
    public static final String PREPARE_ORDERS_DATA_TYPE_GECKO_VOL_UP = "3";
    public static final String PREPARE_ORDERS_DATA_TYPE_MIN14D = "4";
    public static final String PREPARE_ORDERS_DATA_TYPE_MAX14D = "5";

    public static final String TREND_LONG = "Long";
    public static final String TREND_SHORT = "Short";

    public static final String TEXT_5STAR = "(*5S*)";
    public static final String TEXT_DANGER = "(Danger)";
    public static final String TEXT_START_LONG = "Start:Long";
    public static final String TEXT_STOP_LONG = "Stop:Long";

    public static final String CHAR_MONEY = "💰";
    public static final String CHAR_LONG_UP = "Up";
    public static final String CHAR_SHORT_DN = "Dn";

    public static final int MA_FAST = 6;
    public static final int MA_INDEX_H1_START_LONG = 50;
    public static final int MA_INDEX_H4_STOP_LONG = 10;
    public static final int MA_INDEX_H4_START_LONG = 50;
    public static final int MA_INDEX_D1_STOP_LONG = 8;
    public static final int MA_INDEX_D1_START_LONG = 8;
    public static final int MA_INDEX_CURRENCY = 10;

    public static String CST = "";
    public static String X_SECURITY_TOKEN = "";
    // MINUTE, MINUTE_5, MINUTE_15, MINUTE_30, HOUR, HOUR_4, DAY, WEEK
    // public static final String CAPITAL_TIME_MINUTE = "MINUTE";
    // public static final String CAPITAL_TIME_MINUTE_5 = "MINUTE_5";
    public static final String CAPITAL_TIME_MINUTE_15 = "MINUTE_15";
    // public static final String CAPITAL_TIME_MINUTE_30 = "MINUTE_30";
    public static final String CAPITAL_TIME_HOUR = "HOUR";
    public static final String CAPITAL_TIME_HOUR_4 = "HOUR_4";
    public static final String CAPITAL_TIME_DAY = "DAY";
    public static final String CAPITAL_TIME_WEEK = "WEEK";

    public static final String CRYPTO_TIME_5m = "5m";
    public static final String CRYPTO_TIME_15m = "15m";
    public static final String CRYPTO_TIME_1h = "1h";
    public static final String CRYPTO_TIME_4h = "4h";
    public static final String CRYPTO_TIME_1d = "1d";
    public static final String CRYPTO_TIME_1w = "1w";

    public static final long MINUTES_OF_W = 10080;
    public static final long MINUTES_OF_D = 1440;
    public static final long MINUTES_OF_4H = 240;
    public static final long MINUTES_OF_1H = 60;
    public static final long MINUTES_OF_15M = 15;

    public static final List<String> EPICS_FOREX = Arrays.asList("DXY", "GOLD", "OIL_CRUDE", "US30", "US500", "UK100",
            "HK50", "FR40", "EURUSD", "GBPUSD", "AUDUSD", "NZDUSD", "USDJPY", "USDCAD", "USDCHF", "EURGBP");

    public static final List<String> EPICS_FOREX_OTHERS = Arrays.asList("GBPAUD",
            "EURAUD", "EURJPY", "EURCAD", "EURCHF", "AUDJPY", "CADJPY", "GBPJPY",
            "AUDCAD", "GBPCAD", "GBPCHF", "GBPNZD", "EURNZD", "AUDCHF",
            "AUDNZD", "CADCHF", "CHFJPY",
            "NZDCAD", "NZDCHF", "NZDJPY");

    // public static final List<String> EPICS_FOREX_OTHERS = Arrays.asList("AUDHKD",
    // "AUDPLN", "AUDZAR", "CADCNH",
    // "CADHKD", "CADMXN", "CADNOK", "CADPLN", "CADTRY", "CADZAR", "CHFCNH",
    // "CHFCZK", "CHFDKK", "CHFMXN",
    // "CHFNOK", "CHFPLN", "CHFSEK", "CHFTRY", "CHFZAR", "DKKJPY", "EURCZK",
    // "EURILS", "EURPLN", "EURRON",
    // "EURSGD", "GBPCNH", "GBPCZK", "GBPDKK", "GBPHUF", "GBPNOK", "GBPPLN",
    // "GBPSEK", "GBPSGD", "GBPZAR",
    // "HKDMXN", "HKDTRY", "NOKSEK", "NOKTRY", "NZDHKD", "NZDMXN", "NZDPLN",
    // "NZDSEK", "PLNSEK", "PLNTRY",
    // "SEKMXN", "SGDHKD", "SGDMXN", "TRYJPY", "USDCZK", "USDDKK", "USDHKD",
    // "USDILS", "USDRON"
    // );

    public static String sql_CryptoHistoryResponse = " "
            + "   SELECT DISTINCT ON (tmp.symbol_or_epic)                                                   \n"
            + "     tmp.geckoid_or_epic,                                                                 \n"
            + "     tmp.symbol_or_epic,                                                                   \n"
            + "     tmp.trend_d      as d,                                                                \n"
            + "     tmp.trend_h      as h,                                                                \n"
            + "     COALESCE(tmp.trend_15m,'') as m15,                                                    \n"
            + "     COALESCE(tmp.trend_5m, '') as m5,                                                     \n"
            + "     (select append.note from funding_history append where append.event_time = concat('1W1D_FX_', append.gecko_id) and append.gecko_id = tmp.geckoid_or_epic) as note         \n"
            + "  FROM                                                                                     \n"
            + " (                                                                                         \n"
            + "     SELECT                                                                                \n"
            + "        str_h.gecko_id  as geckoid_or_epic,                                              \n"
            + "        str_h.symbol    as symbol_or_epic,                                               \n"
            + "        (select str_d.note from funding_history str_d where event_time = 'DH4H1_D_TREND_CRYPTO' and str_d.gecko_id = str_h.gecko_id) as trend_d,  \n"
            + "        (select str_d.note from funding_history str_d where event_time = 'DH4H1_STR_15M_CRYPTO' and str_d.gecko_id = str_h.gecko_id limit 1) as trend_15m, \n"
            + "        (select str_d.note from funding_history str_d where event_time = 'DH4H1_STR_05M_CRYPTO' and str_d.gecko_id = str_h.gecko_id limit 1) as trend_5m, \n"
            + "        str_h.note   as trend_h                                                           \n"
            + "     FROM funding_history str_h                                                            \n"
            + "     WHERE str_h.event_time = 'DH4H1_STR_H4_CRYPTO'                                        \n"
            + "  ) tmp                                                                                    \n"
            + "  WHERE (tmp.trend_d = 'Long') and (tmp.trend_d = tmp.trend_h)  and (tmp.trend_d = tmp.trend_15m)   \n"
            + "  ORDER BY tmp.symbol_or_epic                                                          \n";

    public static String sql_ForexHistoryResponse = " "
            + " SELECT DISTINCT ON (tmp.symbol_or_epic)                                                    \n"
            + "    tmp.geckoid_or_epic,                                                                 \n"
            + "    tmp.symbol_or_epic,                                                                   \n"
            + "    tmp.trend_d      as d,                                                               \n"
            + "    tmp.trend_h      as h,                                                               \n"
            + "    COALESCE(tmp.trend_15m,'') as m15,                                                   \n"
            + "    COALESCE(tmp.trend_5m, '') as m5,                                                    \n"
            + "    (select append.note from funding_history append where append.event_time = concat('1W1D_FX_', append.gecko_id) and append.gecko_id = tmp.geckoid_or_epic limit 1) as note        \n"
            + " FROM                                                                                    \n"
            + " (                                                                                       \n"
            + "    SELECT                                                                               \n"
            + "        str_h.gecko_id  as geckoid_or_epic,                                              \n"
            + "        str_h.symbol    as symbol_or_epic,                                               \n"
            + "        (select str_d.note from funding_history str_d where event_time = 'DH4H1_D_TREND_FX' and str_d.gecko_id = str_h.gecko_id limit 1) as trend_d,   \n"
            + "        (select str_d.note from funding_history str_d where event_time = 'DH4H1_STR_15M_FX' and str_d.gecko_id = str_h.gecko_id limit 1) as trend_15m,   \n"
            + "        (select str_d.note from funding_history str_d where event_time = 'DH4H1_STR_05M_FX' and str_d.gecko_id = str_h.gecko_id limit 1) as trend_5m,   \n"
            + "        str_h.note   as trend_h                                                          \n"
            + "    FROM funding_history str_h                                                           \n"
            + "    WHERE str_h.event_time = 'DH4H1_STR_H4_FX'                                           \n"
            + " ) tmp                                                                                   \n"
            // and (tmp.trend_d = tmp.trend_h)
            + " WHERE (tmp.trend_h is not null)                                                         \n"
            + "   AND tmp.trend_h = tmp.trend_h    \n"
            + " ORDER BY tmp.symbol_or_epic                                                             \n";

    public static String sql_OrdersProfitResponse = ""
            + " SELECT * from (                                                                             \n"
            + "    SELECT                                                                                   \n"
            + "      od.gecko_id,                                                                           \n"
            + "      od.symbol      as chatId,                                                              \n"
            + "      od.name        as userName,                                                            \n"
            + "      od.order_price,                                                                        \n"
            + "      ROUND(od.qty, 1) qty,                                                                  \n"
            + "      od.amount,                                                                             \n"
            + "      cur.price_at_binance,                                                                  \n"
            + "      (select target_percent from priority_coin po where po.gecko_id = od.gecko_id) target_percent, \n"
            + "      ROUND(((cur.price_at_binance - od.order_price)/od.order_price)*100, 1)  as tp_percent, \n"
            + "      ROUND( (cur.price_at_binance - od.order_price)*od.qty, 1)               as tp_amount,  \n"
            + "      od.low_price,                                                                          \n"
            + "      od.height_price,                                                                       \n"
            + "      (select note from priority_coin pc where pc.gecko_id = od.gecko_id) as target          \n"
            + "    FROM                                                                                     \n"
            + "        orders od,                                                                           \n"
            + "        binance_volumn_day cur                                                               \n"
            + "    WHERE                                                                                    \n"
            + "            cur.hh      = TO_CHAR(NOW(), 'HH24')                                             \n"
            + "        and od.gecko_id = cur.gecko_id                                                       \n"
            + " ) odr ORDER BY odr.tp_amount desc ";

    public static String sql_boll_2_body = ""
            + " (                                                                                           \n"
            + "     select                                                                                  \n"
            + "         tmp.gecko_id,                                                                       \n"
            + "         tmp.symbol,                                                                         \n"
            + "         tmp.name,                                                                           \n"
            + "         tmp.avg_price,                                                                      \n"
            + "         tmp.price_open_candle,                                                              \n"
            + "         tmp.price_close_candle,                                                             \n"
            + "         tmp.low_price,                                                                      \n"
            + "         tmp.hight_price,                                                                    \n"
            + "         tmp.price_can_buy,                                                                  \n"
            + "         tmp.price_can_sell,                                                                 \n"
            + "         (case when (avg_price <= ROUND((price_can_buy  + (ABS(price_close_candle - price_open_candle)/2)), 5) ) then true else false end) is_bottom_area ,    \n"
            + "         (case when (avg_price >= ROUND((price_can_sell - (ABS(price_close_candle - price_open_candle)/2)), 5) ) then true else false end) is_top_area         \n"
            + "     from                                                                                    \n"
            + "     (                                                                                       \n"
            + "         select                                                                              \n"
            + "             can.gecko_id,                                                                   \n"
            + "             can.symbol,                                                                     \n"
            + "             can.name,                                                                       \n"
            + "             min(tok.avg_price) avg_price,                                                   \n"
            + "             min(tok.price_open_candle) price_open_candle,                                   \n"
            + "             min(tok.price_close_candle) price_close_candle,                                 \n"
            + "             (SELECT COALESCE(low_price  , 0) FROM btc_volumn_day where gecko_id = can.gecko_id and hh in (select hh from btc_volumn_day where gecko_id = can.gecko_id order by low_price asc  limit 1))              low_price,     \n"
            + "             (SELECT COALESCE(hight_price, 0) FROM btc_volumn_day where gecko_id = can.gecko_id and hh in (select hh from btc_volumn_day where gecko_id = can.gecko_id order by low_price desc limit 1))              hight_price,   \n"
            + "             (SELECT ROUND(AVG(COALESCE(avg_price, 0)), 5) FROM btc_volumn_day where gecko_id = can.gecko_id and hh in (select hh from btc_volumn_day where gecko_id = can.gecko_id order by avg_price asc  limit 2)) price_can_buy, \n"
            + "             (SELECT ROUND(AVG(COALESCE(avg_price, 0)), 5) FROM btc_volumn_day where gecko_id = can.gecko_id and hh in (select hh from btc_volumn_day where gecko_id = can.gecko_id order by avg_price desc limit 1)) price_can_sell \n"
            + "         from                                                                                \n"
            + "             candidate_coin can,                                                             \n"
            + "             btc_volumn_day tok                                                              \n"
            + "         where 1=1                                                                           \n"
            + "         and can.gecko_id = tok.gecko_id                                                     \n"
            + "         and tok.hh = (case when EXTRACT(MINUTE FROM NOW()) < 3 then TO_CHAR(NOW() - interval '1 hours', 'HH24') else TO_CHAR(NOW(), 'HH24') end) \n"
            + "         group by can.gecko_id\n"
            + "     ) tmp                                                                                   \n"
            + " ) boll                                                                                      \n";

    public static List<BtcFutures> loadData(String symbol, String TIME, int LIMIT_DATA) {

        return loadData(symbol, TIME, LIMIT_DATA, "USDT");
    }

    public static List<BtcFutures> loadData(String symbol, String TIME, int LIMIT_DATA, String currency) {
        try {
            BigDecimal price_at_binance = Utils.getBinancePrice(symbol);

            String url = "https://api.binance.com/api/v3/klines?symbol=" + symbol.toUpperCase() + currency
                    + "&interval=" + TIME + "&limit=" + LIMIT_DATA;

            List<Object> list = Utils.getBinanceData(url, LIMIT_DATA);

            List<BtcFutures> list_entity = new ArrayList<BtcFutures>();
            int id = 0;

            for (int idx = LIMIT_DATA - 1; idx >= 0; idx--) {
                Object obj_usdt = list.get(idx);

                @SuppressWarnings("unchecked")
                List<Object> arr_usdt = (List<Object>) obj_usdt;
                if (CollectionUtils.isEmpty(arr_usdt) || arr_usdt.size() < 4) {
                    return list_entity;
                }

                // [
                // [
                // 1666843200000, 0
                // "20755.90000000", Open price 1
                // "20766.01000000", High price 2
                // "20747.86000000", Low price 3
                // "20755.25000000", Close price 4
                // "1109.22670000", trading qty 5
                // 1666846799999, 6
                // "23022631.35991350", trading volume 7
                // 37665, Number of trades 8
                // "553.36539000", Taker Qty 9
                // "11485577.89938500", Taker volume 10
                // "0" -> avg_price = 20,769
                // ]
                // ]

                if (arr_usdt.size() <= 10) {
                    break;
                }

                BigDecimal price_open_candle = Utils.getBigDecimal(arr_usdt.get(1));
                BigDecimal hight_price = Utils.getBigDecimal(arr_usdt.get(2));
                BigDecimal low_price = Utils.getBigDecimal(arr_usdt.get(3));
                BigDecimal price_close_candle = Utils.getBigDecimal(arr_usdt.get(4));

                BigDecimal trading_qty = Utils.getBigDecimal(arr_usdt.get(5));
                BigDecimal trading_volume = Utils.getBigDecimal(arr_usdt.get(7));

                BigDecimal taker_qty = Utils.getBigDecimal(arr_usdt.get(9));
                BigDecimal taker_volume = Utils.getBigDecimal(arr_usdt.get(10));

                String open_time = arr_usdt.get(0).toString();

                if (Objects.equals("0", open_time)) {
                    break;
                }

                BtcFutures day = new BtcFutures();

                String strid = String.valueOf(id);
                if (strid.length() < 2) {
                    strid = "0" + strid;
                }
                day.setId(symbol.toUpperCase() + "_" + TIME + "_" + strid);

                if (idx == LIMIT_DATA - 1) {
                    day.setCurrPrice(price_at_binance);
                } else {
                    day.setCurrPrice(BigDecimal.ZERO);
                }

                day.setLow_price(low_price);
                day.setHight_price(hight_price);
                day.setPrice_open_candle(price_open_candle);
                day.setPrice_close_candle(price_close_candle);

                day.setTrading_qty(trading_qty);
                day.setTrading_volume(trading_volume);

                day.setTaker_qty(taker_qty);
                day.setTaker_volume(taker_volume);

                BigDecimal candle_heigh = hight_price.subtract(low_price).abs();
                BigDecimal range = candle_heigh.divide(BigDecimal.valueOf(10), 10, RoundingMode.CEILING);

                day.setUptrend(false);
                if (price_open_candle.compareTo(price_close_candle) < 0) {
                    if ((price_open_candle.add(range)).compareTo(price_close_candle) < 0) {
                        day.setUptrend(true);
                    }
                }

                list_entity.add(day);

                id += 1;
            }

            return list_entity;
        } catch (

        Exception e) {
            e.printStackTrace();
        }

        return new ArrayList<BtcFutures>();
    }

    public static void initCapital() {
        String API = "G1fTHbEak0kDE5mg";
        HttpHeaders headers = new HttpHeaders();
        HttpEntity<String> request;
        RestTemplate restTemplate = new RestTemplate();

        // https://api-capital.backend-capital.com/api/v1/session/encryptionKey
        // headers.set("X-CAP-API-KEY", API);
        // HttpEntity<String> request = new HttpEntity<String>(headers);
        // ResponseEntity<String> encryption = restTemplate1.exchange(
        // "https://api-capital.backend-capital.com/api/v1/session/encryptionKey",
        // HttpMethod.GET, request,
        // String.class);
        // JSONObject encryption_body = new JSONObject(encryption.getBody());
        // String encryptionKey =
        // Utils.getStringValue(encryption_body.get("encryptionKey"));
        // String timeStamp = Utils.getStringValue(encryption_body.get("timeStamp"));

        // --------------------------------------------------------------

        // https://capital.com/api-request-examples
        // https://open-api.capital.com/#tag/Session
        headers = new HttpHeaders();
        headers.set("X-CAP-API-KEY", API);
        headers.set("Content-Type", "application/json");

        JSONObject personJsonObject = new JSONObject();
        personJsonObject.put("encryptedPassword", "false");
        personJsonObject.put("identifier", "khanhduyapt@gmail.com");
        personJsonObject.put("password", "Capital123$");

        request = new HttpEntity<String>(personJsonObject.toString(), headers);

        ResponseEntity<String> responseEntityStr = restTemplate
                .postForEntity("https://api-capital.backend-capital.com/api/v1/session", request, String.class);

        HttpHeaders res_header = responseEntityStr.getHeaders();
        Utils.CST = Utils.getStringValue(res_header.get("CST").get(0));
        Utils.X_SECURITY_TOKEN = Utils.getStringValue(res_header.get("X-SECURITY-TOKEN").get(0));

        // ------------------------------------------------------------------------------------
        // String nodeId = "hierarchy_v1.oil_markets_group";
        // String marketnavigation = "marketnavigation/" + nodeId;
        // String url_markets = "https://api-capital.backend-capital.com/api/v1/" +
        // marketnavigation;
        // headers = new HttpHeaders();
        // MediaType mediaType = MediaType.parseMediaType("text/plain");
        // headers.setContentType(mediaType);
        // headers.set("X-SECURITY-TOKEN", Utils.X_SECURITY_TOKEN);
        // headers.set("CST", Utils.CST);
        // request = new HttpEntity<String>(headers);
        // ResponseEntity<String> response = restTemplate.exchange(url_markets,
        // HttpMethod.GET, request, String.class);

    }

    // https://open-api.capital.com/#section/Authentication/How-to-start-new-session
    // https://open-api.capital.com/#tag/Markets-Info-greater-Prices
    // https://api-capital.backend-capital.com/api/v1/markets/{epic}
    public static List<BtcFutures> loadCapitalData(String epic, String TIME, int length) {
        List<BtcFutures> results = new ArrayList<BtcFutures>();
        try {
            HttpHeaders headers = new HttpHeaders();
            HttpEntity<String> request;
            RestTemplate restTemplate = new RestTemplate();

            // Possible values are MINUTE, MINUTE_5, MINUTE_15, MINUTE_30, HOUR, HOUR_4,
            // DAY, WEEK
            // The maximum number of the values in answer. Default = 10, max = 1000
            // Start date. Date format: YYYY-MM-DDTHH:MM:SS (e.g. 2022-04-01T01:01:00).
            // based on snapshotTimeUTC
            // End date. Date format: YYYY-MM-DDTHH:MM:SS (e.g. 2022-04-01T01:01:00).

            String url = "https://api-capital.backend-capital.com/api/v1/prices/" + epic + "?resolution=" + TIME
                    + "&max=" + length;// + "&from=" + time_fr + "&to=" + time_to;

            headers = new HttpHeaders();
            MediaType mediaType = MediaType.parseMediaType("text/plain");
            headers.setContentType(mediaType);
            headers.set("X-SECURITY-TOKEN", X_SECURITY_TOKEN);
            headers.set("CST", CST);
            request = new HttpEntity<String>(headers);

            ResponseEntity<String> response = restTemplate.exchange(url, HttpMethod.GET, request, String.class);
            JSONObject json = new JSONObject(response.getBody());
            JSONArray prices = (JSONArray) json.get("prices");

            if (!Objects.equals(null, prices)) {
                int id = 0;
                for (int index = prices.length() - 1; index >= 0; index--) {
                    JSONObject price = prices.getJSONObject(index);

                    BigDecimal low_price = Utils
                            .formatPrice(Utils.getBigDecimal(((JSONObject) price.get("lowPrice")).get("ask")), 5);
                    BigDecimal low_price_b = Utils
                            .formatPrice(Utils.getBigDecimal(((JSONObject) price.get("lowPrice")).get("bid")), 5);
                    low_price = low_price.add(low_price_b);
                    low_price = low_price.divide(BigDecimal.valueOf(2), 10, RoundingMode.CEILING);

                    // -------------------

                    BigDecimal hight_price = Utils
                            .formatPrice(Utils.getBigDecimal(((JSONObject) price.get("highPrice")).get("ask")), 5);
                    BigDecimal hight_price_b = Utils
                            .formatPrice(Utils.getBigDecimal(((JSONObject) price.get("highPrice")).get("bid")), 5);
                    hight_price = hight_price.add(hight_price_b);
                    hight_price = hight_price.divide(BigDecimal.valueOf(2), 10, RoundingMode.CEILING);
                    // -------------------

                    BigDecimal open_price = Utils
                            .formatPrice(Utils.getBigDecimal(((JSONObject) price.get("openPrice")).get("ask")), 5);
                    BigDecimal open_price_b = Utils
                            .formatPrice(Utils.getBigDecimal(((JSONObject) price.get("openPrice")).get("bid")), 5);
                    open_price = open_price.add(open_price_b);
                    open_price = open_price.divide(BigDecimal.valueOf(2), 10, RoundingMode.CEILING);

                    // -------------------

                    BigDecimal close_price = Utils
                            .formatPrice(Utils.getBigDecimal(((JSONObject) price.get("closePrice")).get("ask")), 5);
                    BigDecimal close_price_b = Utils
                            .formatPrice(Utils.getBigDecimal(((JSONObject) price.get("closePrice")).get("bid")), 5);
                    close_price = close_price.add(close_price_b);
                    close_price = close_price.divide(BigDecimal.valueOf(2), 10, RoundingMode.CEILING);

                    // String snapshotTime = Utils.getStringValue(price.get("snapshotTime"));

                    BtcFutures dto = new BtcFutures();
                    String strid = Utils.getStringValue(id);
                    if (strid.length() < 2) {
                        strid = "0" + strid;
                    }
                    strid = epic + getChartNameCapital_(TIME) + strid;
                    dto.setId(strid);
                    dto.setCurrPrice(close_price);
                    dto.setLow_price(low_price);
                    dto.setHight_price(hight_price);
                    dto.setPrice_open_candle(open_price);
                    dto.setPrice_close_candle(close_price);

                    results.add(dto);

                    // System.out.println(strid + ": " + snapshotTime);

                    id += 1;
                }
            }

        } catch (Exception e) {
            if (e.getMessage().contains("Connection timed out")) {
                Utils.logWritelnWithTime(epic + ": " + e.getMessage(), false);
                initCapital();
            }
            System.out.println(e.getMessage());
        }

        return results;
    }

    public static String getChartNameCapital_(String TIME) {
        // if (Objects.equals(TIME, CAPITAL_TIME_MINUTE)) {
        // return "_1m_";
        // }
        // if (Objects.equals(TIME, CAPITAL_TIME_MINUTE_5)) {
        // return "_5m_";
        // }
        if (Objects.equals(TIME, CAPITAL_TIME_MINUTE_15)) {
            return "_15m_";
        }
        // if (Objects.equals(TIME, CAPITAL_TIME_MINUTE_30)) {
        // return "_30m_";
        // }
        if (Objects.equals(TIME, CAPITAL_TIME_HOUR)) {
            return "_1h_";
        }
        if (Objects.equals(TIME, CAPITAL_TIME_HOUR_4)) {
            return "_4h_";
        }
        if (Objects.equals(TIME, CAPITAL_TIME_DAY)) {
            return "_1d_";
        }
        if (Objects.equals(TIME, CAPITAL_TIME_WEEK)) {
            return "_1w_";
        }

        return TIME;
    }

    public static String getChartNameCapital(String TIME) {
        // if (Objects.equals(TIME, CAPITAL_TIME_MINUTE)) {
        // return "(1m)";
        // }
        // if (Objects.equals(TIME, CAPITAL_TIME_MINUTE_5)) {
        // return "(5m)";
        // }
        if (Objects.equals(TIME, CAPITAL_TIME_MINUTE_15)) {
            return "(15m)";
        }
        // if (Objects.equals(TIME, CAPITAL_TIME_MINUTE_30)) {
        // return "(30m)";
        // }
        if (Objects.equals(TIME, CAPITAL_TIME_HOUR)) {
            return "(H1)";
        }
        if (Objects.equals(TIME, CAPITAL_TIME_HOUR_4)) {
            return "(H4)";
        }
        if (Objects.equals(TIME, CAPITAL_TIME_DAY)) {
            return "(D)";
        }
        if (Objects.equals(TIME, CAPITAL_TIME_WEEK)) {
            return "(W)";
        }

        return TIME;
    }

    public static String createMsgBalance(OrdersProfitResponse dto, String newline) {
        String result = String.format("[%s]", dto.getGecko_id()) + newline + "Price: "
                + dto.getPrice_at_binance().toString() + "$, "
                + (dto.getTp_amount().compareTo(BigDecimal.ZERO) > 0 ? "Profit: " : "Loss: ")
                + Utils.removeLastZero(dto.getTp_amount().toString()) + "$ (" + dto.getTp_percent() + "%)" + newline
                + "Bought: " + dto.getOrder_price().toString() + "$, " + "T: "
                + Utils.removeLastZero(dto.getAmount().toString()) + "$" + newline
                + createMsgLowHeight(dto.getPrice_at_binance(), dto.getLow_price(), dto.getHeight_price());

        if (isNotBlank(dto.getTarget()) && dto.getTarget().contains("~v/mc")) {
            result += newline + dto.getTarget().substring(0, dto.getTarget().indexOf("~v/mc"));
        }

        return result;
    }

    public static String createMsg(CandidateTokenCssResponse css) {
        return "BTC: " + css.getCurrent_price() + "$" + "%0A" + css.getLow_to_hight_price() + "%0A"
                + Utils.convertDateToString("MM-dd hh:mm", Calendar.getInstance().getTime());
    }

    public static String createMsgSimple(BigDecimal curr_price, BigDecimal low_price, BigDecimal hight_price) {
        return Utils.removeLastZero(curr_price.toString()) + "$\n"
                + createMsgLowHeight(curr_price, low_price, hight_price);
    }

    public static String createMsgLowHeight(BigDecimal curr_price, BigDecimal low_price, BigDecimal hight_price) {
        return "L:" + Utils.removeLastZero(low_price.toString()) + "(" + Utils.toPercent(low_price, curr_price, 1)
                + "%)" + "-H:" + Utils.removeLastZero(hight_price.toString()) + "("
                + Utils.toPercent(hight_price, curr_price, 1) + "%)" + "$";
    }

    public static String getDataType(PrepareOrders entity) {
        String result = "";

        switch (getStringValue(entity.getDataType())) {
        case PREPARE_ORDERS_DATA_TYPE_BOT:
            result = "(Bot)";
            break;
        case PREPARE_ORDERS_DATA_TYPE_BINANCE_VOL_UP:
            result = "(BinanceVol)";
            break;
        case PREPARE_ORDERS_DATA_TYPE_GECKO_VOL_UP:
            result = "(GeckoVol)";
            break;
        case PREPARE_ORDERS_DATA_TYPE_MIN14D:
            result = "(Min14d)";
            break;
        case PREPARE_ORDERS_DATA_TYPE_MAX14D:
            result = "(Max14d)";
            break;
        default:
            break;
        }

        return result;
    }

    public static boolean isUptrend(List<BtcFutures> list) {
        BtcFutures item00 = list.get(0);
        BtcFutures item99 = list.get(list.size() - 1);

        if (Utils.isAGreaterB(item00.getLow_price(), item99.getHight_price())) {
            return true;
        }

        if (item00.isUptrend() && Utils.isAGreaterB(item00.getPrice_open_candle(), item99.getPrice_close_candle())
                && Utils.isAGreaterB(item00.getPrice_open_candle(), item99.getPrice_open_candle())) {
            return true;
        }

        if (item00.isUptrend() && (Utils.isAGreaterB(item00.getPrice_open_candle(), item99.getPrice_close_candle())
                || Utils.isAGreaterB(item00.getPrice_open_candle(), item99.getPrice_open_candle()))) {
            return true;
        }

        return item00.isUptrend();
    }

    public static boolean isAGreaterB(BigDecimal a, BigDecimal b) {
        if (getBigDecimal(a).compareTo(getBigDecimal(b)) > 0) {
            return true;
        }
        return false;
    }

    public static List<Object> getBinanceData(String url, int limit) {
        try {
            RestTemplate restTemplate = new RestTemplate();
            Object[] result = restTemplate.getForObject(url, Object[].class);

            if (result.length < limit) {
                List<Object> list = new ArrayList<Object>();
                for (int idx = 0; idx < limit - result.length; idx++) {
                    List<Object> data = new ArrayList<Object>();
                    for (int i = 0; i < limit; i++) {
                        data.add(0);
                    }
                    list.add(data);
                }

                for (Object obj : result) {
                    list.add(obj);
                }

                return list;

            } else {
                return Arrays.asList(result);
            }
        } catch (Exception e) {
            List<Object> list = new ArrayList<Object>();
            for (int idx = 0; idx < limit; idx++) {
                List<Object> data = new ArrayList<Object>();
                for (int i = 0; i < limit; i++) {
                    data.add(0);
                }
                list.add(data);
            }

            return list;
        }

    }

    public static BigDecimal getBinancePrice(String symbol) {
        try {
            // /fapi/v1/ticker/price
            String url = "https://api.binance.com/api/v3/ticker/price?symbol=" + symbol + "USDT";
            RestTemplate restTemplate = new RestTemplate();
            Object result = restTemplate.getForObject(url, Object.class);

            return Utils.getBigDecimal(Utils.getLinkedHashMapValue(result, Arrays.asList("price")));
        } catch (Exception e) {
            return BigDecimal.ZERO;
        }

    }

    public static boolean isNotBlank(String value) {
        if (Objects.equals(null, value) || Objects.equals("", value)) {
            return false;
        }
        return true;
    }

    public static boolean isBlank(String value) {
        if (Objects.equals(null, value) || Objects.equals("", value)) {
            return true;
        }
        return false;
    }

    public static String appendSpace(String value, int length) {
        String result = value;
        int len = value.length();
        if (len < length) {
            for (int i = len; i < length; i++) {
                result += " ";
            }
        }
        return result;
    }

    public static BigDecimal getMidPrice(BigDecimal low_price, BigDecimal hight_price) {
        BigDecimal mid_price = (getBigDecimal(hight_price).add(getBigDecimal(low_price)));
        mid_price = mid_price.divide(BigDecimal.valueOf(2), 10, RoundingMode.CEILING);

        return mid_price;
    }

    public static Boolean isDangerPrice(BigDecimal curr_price, BigDecimal low_price, BigDecimal hight_price) {
        BigDecimal mid_price = getMidPrice(low_price, hight_price);

        BigDecimal danger_range = (hight_price.subtract(mid_price));
        danger_range = danger_range.divide(BigDecimal.valueOf(3), 10, RoundingMode.CEILING);

        BigDecimal danger_price = mid_price.subtract(danger_range);

        return (danger_price.compareTo(curr_price) > 0);
    }

    public static Boolean isVectorUp(BigDecimal vector) {
        return (vector.compareTo(BigDecimal.ZERO) >= 0);
    }

    public static String whenGoodPrice(BigDecimal curr_price, BigDecimal low_price, BigDecimal hight_price) {
        return (isGoodPriceLong(curr_price, low_price, hight_price) ? "*5*" : "");
    }

    public static boolean isCandidate(CandidateTokenCssResponse css) {

        if (css.getStar().toLowerCase().contains("uptrend")) {
            return true;
        }

        return false;
    }

    public static boolean isAllowSendMsgSetting() {
        String cty = "PC";
        String home = "DESKTOP-L4M1JU2";
        String hostname;
        try {
            hostname = InetAddress.getLocalHost().getHostName();
            if (Objects.equals(cty, hostname) || Objects.equals(home, hostname)) {
                return true;
            }
        } catch (UnknownHostException e) {
            e.printStackTrace();
        }

        if ((BscScanBinanceApplication.app_flag == const_app_flag_msg_on)
                || (BscScanBinanceApplication.app_flag == const_app_flag_all_and_msg)) {
            return true;
        }

        return false;
    }

    public static String getCryptoLink_Spot(String symbol) {
        return " https://vn.tradingview.com/chart/?symbol=BINANCE%3A" + symbol + "USDT";
    }

    public static String getCryptoLink_Future(String symbol) {
        return " https://vn.tradingview.com/chart/?symbol=BINANCE%3A" + symbol + "USDTPERP";
    }

    public static String getCapitalLink(String epic) {
        return " https://vn.tradingview.com/chart/?symbol=CAPITALCOM%3A" + epic;
    }

    public static String getForexLogFile() {
        String prefix = BscScanBinanceApplication.hostname.toLowerCase();
        if (prefix.length() > 3) {
            prefix = prefix.substring(0, 3);
        }

        String PATH = "crypto_forex_result/";
        String fileName = prefix + "_forex_result_" + getYyyyMmDdHH_ChangeDailyChart() + ".log";

        File directory = new File(PATH);
        if (!directory.exists()) {
            directory.mkdir();
        }
        return PATH + fileName;
    }

    public static String getCryptoLogFile() {
        String prefix = BscScanBinanceApplication.hostname.toLowerCase();
        if (prefix.length() > 3) {
            prefix = prefix.substring(0, 3);
        }

        String PATH = "crypto_forex_result/";
        String fileName = prefix + "_crypto_result_" + getYyyyMmDdHH_ChangeDailyChart() + ".log";

        File directory = new File(PATH);
        if (!directory.exists()) {
            directory.mkdir();
        }
        return PATH + fileName;
    }

    public static void writeBlogCrypto(String symbol, String long_short_content, boolean isFuturesCoin) {
        Utils.logWritelnWithTime(long_short_content, true);
        if (isFuturesCoin) {
            Utils.logWriteln(Utils.getCryptoLink_Future(symbol), false);
        } else {
            Utils.logWriteln(Utils.getCryptoLink_Spot(symbol), false);
        }
        logWriteln("_______________________________________________________________", true);
    }

    public static void logWritelnWithTime(String text, boolean isCrypto) {
        try {
            String logFilePath;
            if (isCrypto) {
                logFilePath = getCryptoLogFile();
            } else {
                logFilePath = getForexLogFile();
            }

            FileWriter fw = new FileWriter(logFilePath, true);
            fw.write(Utils.getTimeHHmm() + " " + text.replace(Utils.new_line_from_service, " ") + "\n");
            fw.close();
        } catch (IOException ioe) {
            System.err.println("IOException: " + ioe.getMessage());
        }
    }

    public static void logForexWriteln(String text, boolean isNewline) {
        try {
            FileWriter fw = new FileWriter(getForexLogFile(), true);
            fw.write(
                    (isNewline ? "\n" : "") + text.replace(Utils.new_line_from_service, " ") + (isNewline ? "\n" : ""));
            fw.close();
        } catch (IOException ioe) {
            System.err.println("IOException: " + ioe.getMessage());
        }
    }

    public static void logWriteln(String text, boolean isNewline) {
        try {
            FileWriter fw = new FileWriter(getCryptoLogFile(), true);
            fw.write(
                    (isNewline ? "\n" : "") + text.replace(Utils.new_line_from_service, " ") + (isNewline ? "\n" : ""));
            fw.close();
        } catch (IOException ioe) {
            System.err.println("IOException: " + ioe.getMessage());
        }
    }

    public static void writelnLogFooter_Forex() {
        try {
            FileWriter fw = new FileWriter(getForexLogFile(), true);
            fw.write(
                    "------------------------------------------------------------------------------------------------------------------------------------------------------------------\n");
            fw.close();
        } catch (IOException ioe) {
            System.err.println("IOException: " + ioe.getMessage());
        }
    }

    public static void writelnLogFooter() {
        try {
            FileWriter fw = new FileWriter(getCryptoLogFile(), true);
            fw.write(
                    "------------------------------------------------------------------------------------------------------------------------------------------------------------------\n");
            fw.close();
        } catch (IOException ioe) {
            System.err.println("IOException: " + ioe.getMessage());
        }
    }

    public static void sendToMyTelegram(String text) {
        String msg = text.replaceAll("↑", "^").replaceAll("↓", "v").replaceAll(" ", "");
        System.out.println();
        System.out.println(msg + " 💰 ");
        if (isAllowSendMsgSetting()) {
            sendToChatId(Utils.chatId_duydk, msg + " 💰 ");
        }
    }

    public static void sendToTelegram(String text) {
        String msg = text.replaceAll("↑", "^").replaceAll("↓", "v").replaceAll(" ", "");
        System.out.println(msg);

        if (isAllowSendMsgSetting()) {
            if (!isBusinessTime()) {
                // return;
            }

            sendToChatId(Utils.chatId_duydk, msg);
            sendToChatId(Utils.chatId_linkdk, msg);
        }
    }

    public static boolean isWeekend() {
        LocalDate today = LocalDate.now();
        DayOfWeek day = DayOfWeek.of(today.get(ChronoField.DAY_OF_WEEK));
        boolean value = day == DayOfWeek.SUNDAY || day == DayOfWeek.SATURDAY;
        return value;
    }

    public static boolean isNewsTime() {
        int hh = Utils.getIntValue(Utils.convertDateToString("HH", Calendar.getInstance().getTime()));
        if ((20 <= hh && hh <= 22)) {
            return true;
        }

        return false;
    }

    public static boolean isWorkingTime() {
        int hh = Utils.getIntValue(Utils.convertDateToString("HH", Calendar.getInstance().getTime()));
        if ((7 <= hh && hh <= 18)) {
            return true;
        }

        return false;
    }

    public static boolean isBusinessTime() {
        int hh = Utils.getIntValue(Utils.convertDateToString("HH", Calendar.getInstance().getTime()));
        if ((22 <= hh || hh <= 8)) {
            return false;
        }

        return true;
    }

    public static String getChatId(String userName) {
        if (Objects.equals(userName, chatUser_linkdk)) {
            return chatId_linkdk;
        }
        return chatId_duydk;
    }

    public static void sendToChatId(String chat_id, String text) {
        try {
            // Telegram token
            String apiToken = "5349894943:AAE_0-ZnbikN9m1aRoyCI2nkT2vgLnFBA-8";

            String urlSetWebhook = "https://api.telegram.org/bot%s/setWebhook";
            urlSetWebhook = String.format(urlSetWebhook, apiToken);

            String urlString = "https://api.telegram.org/bot%s/sendMessage?chat_id=%s&text=";
            urlString = String.format(urlString, apiToken, chat_id) + text;
            try {
                URL url = new URL(urlSetWebhook);
                URLConnection conn = url.openConnection();
                conn.getInputStream();

                URL url2 = new URL(urlString);
                URLConnection conn2 = url2.openConnection();
                conn2.getInputStream();

                // @SuppressWarnings("unused")
                // InputStream is = new BufferedInputStream(conn.getInputStream());
                // System.out.println(is);
            } catch (IOException e) {
                e.printStackTrace();
            }
        } catch (Exception e) {
            System.out.println("____________________sendToChatId.ERROR____________________");
            e.printStackTrace();
            System.exit(0);
        }
    }

    public static BigDecimal getBigDecimal(Object value) {
        if (Objects.equals(null, value)) {
            return BigDecimal.ZERO;
        }

        if (Objects.equals("", value.toString())) {
            return BigDecimal.ZERO;
        }

        BigDecimal ret = null;
        try {
            if (value != null) {
                if (value instanceof BigDecimal) {
                    ret = (BigDecimal) value;
                } else if (value instanceof String) {
                    ret = new BigDecimal((String) value);
                } else if (value instanceof BigInteger) {
                    ret = new BigDecimal((BigInteger) value);
                } else if (value instanceof Number) {
                    ret = new BigDecimal(((Number) value).doubleValue());
                } else {
                    throw new ClassCastException("Not possible to coerce [" + value + "] from class " + value.getClass()
                            + " into a BigDecimal.");
                }
            }
            return ret;
        } catch (Exception e) {
            return BigDecimal.ZERO;
        }

    }

    public static String toMillions(Object value) {
        BigDecimal val = getBigDecimal(value);
        val = val.divide(BigDecimal.valueOf(1000000), 2, RoundingMode.CEILING);

        return String.format("%,.0f", val) + "M$";
    }

    public static String removeLastZero(BigDecimal value) {
        return removeLastZero(Utils.getStringValue(value));
    }

    public static String getNextBidsOrAsksWall(BigDecimal price_at_binance, List<DepthResponse> bidsOrAsksList) {

        String next_price = Utils.removeLastZero(price_at_binance) + "(now)";

        BigDecimal last_wall = BigDecimal.ZERO;
        for (DepthResponse res : bidsOrAsksList) {
            if (Objects.equals("BTC", res.getSymbol())) {

                if (res.getVal_million_dolas().compareTo(BigDecimal.valueOf(2.9)) > 0) {
                    last_wall = res.getPrice();
                }
            }
        }

        if (last_wall.compareTo(price_at_binance) > 0) {
            next_price += " Short: " + removeLastZero(last_wall) + "(" + getPercentStr(last_wall, price_at_binance)
                    + ")";
        } else if (last_wall.compareTo(price_at_binance) < 0) {
            next_price += " Long: " + removeLastZero(last_wall) + "(" + getPercentStr(price_at_binance, last_wall)
                    + ")";
        }

        return next_price;
    }

    public static String removeLastZero(String value) {
        if ((value == null) || (Objects.equals("", value))) {
            return "";
        }

        BigDecimal val = getBigDecimalValue(value);
        if (val.compareTo(BigDecimal.valueOf(500)) > 0) {
            return String.format("%.0f", val);
        }

        if (Objects.equals("0", value.subSequence(value.length() - 1, value.length()))) {
            String str = value.substring(0, value.length() - 1);
            return removeLastZero(str);
        }

        if (value.indexOf(".") == value.length() - 1) {
            return value + "0";
        }

        return value;
    }

    public static String getYyyyMmDdHH_ChangeDailyChart() {
        Calendar calendar = Calendar.getInstance();

        int hh = Utils.getIntValue(Utils.convertDateToString("HH", calendar.getTime()));
        if (hh >= 0 && hh < 7) {
            calendar.add(Calendar.DAY_OF_MONTH, -1);
        }
        String result = Utils.convertDateToString("yyyy.MM.dd", calendar.getTime()) + "_07";

        return result;
    }

    public static String getMmDD_TimeHHmm() {
        return Utils.convertDateToString("(MMdd_HH:mm) ", Calendar.getInstance().getTime());
    }

    public static String getTimeHHmm() {
        return Utils.convertDateToString("(HH:mm) ", Calendar.getInstance().getTime());
    }

    public static String getToday_YyyyMMdd() {
        return Utils.convertDateToString("yyyy.MM.dd", Calendar.getInstance().getTime());
    }

    public static String getToday_MMdd() {
        return Utils.convertDateToString("MM.dd", Calendar.getInstance().getTime());
    }

    public static String getToday_dd() {
        return Utils.convertDateToString("dd", Calendar.getInstance().getTime());
    }

    public static String getDD(int add) {
        if (add == 0) {
            return " Today ";
        }

        Calendar calendar = Calendar.getInstance();
        calendar.add(Calendar.DATE, add);
        String dayOfWeek = calendar.getDisplayName(Calendar.DAY_OF_WEEK, Calendar.SHORT, Locale.US);
        String value = " (" + dayOfWeek + "." + Utils.convertDateToString("dd", calendar.getTime()) + ") ";

        return value;
    }

    public static String getDdFromToday(int dateadd) {
        Calendar calendar = Calendar.getInstance();
        calendar.add(Calendar.DAY_OF_MONTH, dateadd);
        return Utils.convertDateToString("dd", calendar.getTime());
    }

    public static String getCurrentYyyyMmDdHHByChart(List<BtcFutures> list) {
        String symbol = list.get(0).getId();
        String result = getCurrentYyyyMmDd_HH() + "_";

        if (symbol.contains("_4h_")) {
            return getCurrentYyyyMmDd_HH_Blog4h() + "_";
        }

        if (symbol.contains("_1d_")) {
            return getYyyyMmDdHH_ChangeDailyChart() + "_";
        }

        if (symbol.contains("_3m_")) {
            result += getCurrentMinute_Blog15minutes();
        }

        if (symbol.contains("_1m_")) {
            result += getCurrentMinute_Blog5minutes();
        }

        return result;
    }

    public static String getCurrentYyyyMmDd_HH() {
        return Utils.convertDateToString("yyyy.MM.dd_HH", Calendar.getInstance().getTime()) + "h";
    }

    public static String getCurrentYyyyMmDd_HH_Blog15m() {
        String result = getCurrentYyyyMmDd_HH() + "_" + getCurrentMinute_Blog15minutes();
        return result;
    }

    public static String getCurrentYyyyMmDd_HH_Blog2h() {
        String result = Utils.convertDateToString("yyyy.MM.dd_", Calendar.getInstance().getTime());
        int HH = Utils.getIntValue(Utils.convertDateToString("HH", Calendar.getInstance().getTime()));
        HH = HH / 2;
        result = result + HH;
        return result;
    }

    public static String getCurrentYyyyMmDd_HH_Blog4h() {
        String result = Utils.convertDateToString("yyyy.MM.dd_", Calendar.getInstance().getTime());
        int HH = Utils.getIntValue(Utils.convertDateToString("HH", Calendar.getInstance().getTime()));
        HH = HH / 4;
        result = result + HH;
        return result;
    }

    public static String getYYYYMMDD(int dateadd) {
        Calendar calendar = Calendar.getInstance();
        calendar.add(Calendar.DAY_OF_MONTH, dateadd);
        return Utils.convertDateToString("yyyyMMdd", calendar.getTime());
    }

    public static String getYYYYMMDD2(int hoursadd) {
        Calendar calendar = Calendar.getInstance();
        calendar.add(Calendar.HOUR_OF_DAY, hoursadd);
        return Utils.convertDateToString("yyyyMMdd", calendar.getTime());
    }

    public static String getYYYYMM() {
        Calendar calendar = Calendar.getInstance();
        return Utils.convertDateToString("yyyyMM", calendar.getTime());
    }

    public static String getMM() {
        Calendar calendar = Calendar.getInstance();
        return Utils.convertDateToString("MM", calendar.getTime());
    }

    public static String getHH(int add) {
        Calendar calendar = Calendar.getInstance();
        calendar.add(Calendar.HOUR_OF_DAY, add);
        return Utils.convertDateToString("HH", calendar.getTime());
    }

    public static Integer getHH24(int add) {
        Calendar calendar = Calendar.getInstance();
        calendar.add(Calendar.HOUR_OF_DAY, add);
        return calendar.get(Calendar.HOUR_OF_DAY);
    }

    public static Integer getCurrentHH() {
        int HH = Utils.getIntValue(Utils.convertDateToString("HH", Calendar.getInstance().getTime()));
        return HH;
    }

    public static Integer getCurrentMinute() {
        int mm = Utils.getIntValue(Utils.convertDateToString("mm", Calendar.getInstance().getTime()));
        return mm;
    }

    public static int getCurrentMinute_Blog3minutes() {
        int mm = getCurrentMinute();
        mm = mm / 3;
        return mm;
    }

    public static int getCurrentMinute_Blog5minutes() {
        int mm = getCurrentMinute();
        mm = mm / 5;
        return mm;
    }

    public static int getCurrentMinute_Blog15minutes() {
        int mm = getCurrentMinute();
        mm = mm / 15;
        return mm;
    }

    public static String getBlog10Minutes() {
        int mm = Utils.getIntValue(Utils.convertDateToString("mm", Calendar.getInstance().getTime()));
        return String.valueOf(mm).substring(0, 1);
    }

    public static Integer getCurrentSeconds() {
        int ss = Utils.getIntValue(Utils.convertDateToString("ss", Calendar.getInstance().getTime()));
        return ss;
    }

    public static Integer getIntValue(Object value) {
        try {
            if (Objects.equals(null, value)) {
                return 0;
            }

            return Integer.valueOf(value.toString().trim());
        } catch (Exception e) {
            return 0;
        }
    }

    public static String getStringValue(Object value) {
        if (Objects.equals(null, value)) {
            return "";
        }
        if (Objects.equals("", value.toString())) {
            return "";
        }

        return value.toString();
    }

    public static String lossPer1000(BigDecimal entry, BigDecimal take_porfit_price) {
        BigDecimal fee = BigDecimal.valueOf(2);

        BigDecimal loss = BigDecimal.valueOf(1000).multiply(entry.subtract(take_porfit_price))
                .divide(entry, 0, RoundingMode.CEILING).subtract(fee);

        return "1000$/" + Utils.removeLastZero(String.valueOf(loss)) + "$";
    }

    public static BigDecimal getPercentFromStringPercent(String value) {
        if (value.contains("(") && value.contains("%")) {
            String result = value.substring(value.indexOf("(") + 1, value.indexOf("%")).trim();
            return getBigDecimal(result);
        }
        return BigDecimal.valueOf(100);
    }

    public static String toPercent(BigDecimal target, BigDecimal current_price) {
        return toPercent(target, current_price, 1);
    }

    public static String toPercent(BigDecimal target, BigDecimal current_price, int scale) {
        if (Objects.equals("", getStringValue(current_price))) {
            return "0";
        }

        if (current_price.compareTo(BigDecimal.ZERO) == 0) {
            return "[dvz]";
        }
        BigDecimal percent = (target.subtract(current_price)).divide(current_price, 2 + scale, RoundingMode.CEILING)
                .multiply(BigDecimal.valueOf(100));

        return removeLastZero(percent.toString());
    }

    public static BigDecimal getPercent(BigDecimal value, BigDecimal entry) {
        if (Utils.getBigDecimal(entry).equals(BigDecimal.ZERO)) {
            return BigDecimal.ZERO;
        }

        BigDecimal percent = (value.subtract(entry)).divide(entry, 10, RoundingMode.CEILING)
                .multiply(BigDecimal.valueOf(100));

        return formatPrice(percent, 1);
    }

    public static String getPercentVol2Mc(String volume, String mc) {
        if (Utils.getBigDecimal(mc).equals(BigDecimal.ZERO)) {
            return "";
        }

        BigDecimal percent = (getBigDecimal(volume.replace(",", "")).multiply(BigDecimal.valueOf(1000000)))
                .divide(getBigDecimal(mc), 4, RoundingMode.CEILING).multiply(BigDecimal.valueOf(100));

        String mySL = "v/mc (" + removeLastZero(percent) + "%)";

        if (percent.compareTo(BigDecimal.valueOf(30)) < 0) {
            return "";
        }

        return mySL.replace("-", "");
    }

    public static String getPercentToEntry(BigDecimal curr_price, BigDecimal entry, boolean isLong) {
        String mySL = Utils.removeLastZero(entry) + "("
                + (curr_price.compareTo(entry) > 0 ? Utils.getPercentStr(curr_price, entry)
                        : Utils.getPercentStr(entry, curr_price))
                + ")";
        return mySL.replace("-", "");
    }

    public static String getPercentStr(BigDecimal value, BigDecimal entry) {

        return removeLastZero(getPercent(value, entry)) + "%";

    }

    public static BigDecimal getBigDecimalValue(String value) {
        try {
            if (Objects.equals(null, value)) {
                return BigDecimal.ZERO;
            }
            if (Objects.equals("", value.toString())) {
                return BigDecimal.ZERO;
            }

            return BigDecimal.valueOf(Double.valueOf(value.toString()));
        } catch (Exception e) {
            return BigDecimal.ZERO;
        }
    }

    public static String getTextCss(String value) {
        if (Objects.equals(null, value)) {
            return "";
        }

        if (value.contains("-")) {
            return "text-danger";
        } else {
            return "text-primary";
        }
    }

    public static BigDecimal formatPriceLike(BigDecimal value, BigDecimal des_value) {
        return formatPrice(value, getDecimalNumber(des_value));
    }

    public static BigDecimal formatPrice(BigDecimal value, int number) {
        @SuppressWarnings("resource")
        Formatter formatter = new Formatter();
        formatter.format("%." + String.valueOf(number) + "f", value);

        return BigDecimal.valueOf(Double.valueOf(formatter.toString()));
    }

    public static BigDecimal roundDefault(BigDecimal value) {
        BigDecimal entry = value;

        if (entry.compareTo(BigDecimal.valueOf(100)) > 0) {

            entry = formatPrice(entry, 1);
        } else if (entry.compareTo(BigDecimal.valueOf(1)) > 0) {

            entry = formatPrice(entry, 2);
        } else if (entry.compareTo(BigDecimal.valueOf(0.5)) > 0) {

            entry = formatPrice(entry, 3);
        } else {

            entry = formatPrice(entry, 5);
        }

        return entry;
    }

    public static int getDecimalNumber(BigDecimal value) {

        String val = removeLastZero(getStringValue(value));
        if (!val.contains(".")) {
            return 0;
        }
        int number = val.length() - val.indexOf(".") - 1;

        return number;
    }

    public static Date getDate(String unix_time) {
        String temp = unix_time.substring(0, unix_time.length() - 3);

        Instant instant = Instant.ofEpochSecond(Long.valueOf(temp));
        Date date = Date.from(instant);

        return date;
    }

    public static Object getLinkedHashMapValue(Object root, List<String> childs) {
        int index = 0;
        Object obj_key = root;

        for (String key : childs) {
            @SuppressWarnings("unchecked")
            LinkedHashMap<String, Object> linkedHashMap = (LinkedHashMap<String, Object>) obj_key;
            obj_key = linkedHashMap.get(key);
            index += 1;

            if (index == childs.size()) {
                return obj_key;
            }
        }

        return null;
    }

    public static String getMessage(HttpServletRequest request, LocaleResolver localeResolver, MessageSource messages,
            String key) {
        final Locale locale = localeResolver.resolveLocale(request);
        String message = messages.getMessage(key, null, locale);
        return message;
    }

    public static String getMessage2(MessageSource messages, String key, String lang) {
        String message = messages.getMessage(key, null, Locale.forLanguageTag(lang));
        return message;
    }

    public static final String generateCollectionString(List<?> list) {
        if (list == null || list.isEmpty())
            return "()";
        StringBuilder result = new StringBuilder();
        result.append("(");
        for (Iterator<?> it = list.iterator(); it.hasNext();) {
            Object ob = it.next();
            result.append("'");
            result.append(ob.toString());
            result.append("'");
            if (it.hasNext())
                result.append(" , ");
        }
        result.append(")");
        return result.toString();
    }

    public static final String generateCollectionStringLikeArray(List<?> list) {
        if (list == null || list.isEmpty())
            return "[]";
        StringBuilder result = new StringBuilder();
        result.append("[");
        for (Iterator<?> it = list.iterator(); it.hasNext();) {
            Object ob = it.next();
            result.append("'%");
            result.append(ob.toString());
            result.append("%'");
            if (it.hasNext())
                result.append(" , ");
        }
        result.append("]");
        return result.toString();
    }

    public static final String generateCollectionNumber(List<?> list) {
        if (list == null || list.isEmpty())
            return "()";
        StringBuilder result = new StringBuilder();
        result.append("(");
        for (Iterator<?> it = list.iterator(); it.hasNext();) {
            Object ob = it.next();
            result.append(ob.toString());
            if (it.hasNext())
                result.append(" , ");
        }
        result.append(")");
        return result.toString();
    }

    public static String convertDateToString(String pattern, Date date) {
        SimpleDateFormat sdf = new SimpleDateFormat(pattern);
        return sdf.format(date);
    }

    public static Date convertStringToDate(String pattern, String date) {
        try {
            return new SimpleDateFormat(pattern).parse(date);
        } catch (Exception e) {
            return null;
        }
    }

    public static String convertStringISOToString(String patternIn, String dateIso, String patternOut) {
        // IN :yyyy-MM-dd'T'HH:mm:ss.SSSXXX
        // OUT : yyyy-MM-dd
        try {
            DateFormat dateFormat = new SimpleDateFormat(patternIn);
            dateFormat.setTimeZone(TimeZone.getTimeZone("UTC"));
            Date date = dateFormat.parse(dateIso);
            DateFormat formatter = new SimpleDateFormat(patternOut);
            return formatter.format(date);
        } catch (Exception e) {
            return null;
        }
    }

    public static Timestamp convertStringToTimeStamp(String pattern, String date) {
        try {
            DateFormat df = new SimpleDateFormat(pattern);
            Date dates = df.parse(date);
            long time = dates.getTime();
            Timestamp ts = new Timestamp(time);
            return ts;
        } catch (Exception e) {
            return null;
        }
    }

    public static final String generateCollectionStringLikeArray(List<?> list, String columnName) {
        StringBuilder result = new StringBuilder();
        for (Iterator<?> it = list.iterator(); it.hasNext();) {
            Object ob = it.next();
            result.append(" LOWER(").append(columnName).append(")").append(" LIKE '%");
            result.append(ob.toString());
            result.append("%'");
            if (it.hasNext()) {
                result.append(" OR ");
            }
        }
        return result.toString();
    }

    public static final String generateCollectionStringToArray(List<?> list) {
        StringBuilder result = new StringBuilder();
        result.append("[");
        for (Iterator<?> it = list.iterator(); it.hasNext();) {
            Object ob = it.next();
            result.append("'%");
            result.append(ob.toString());
            result.append("%'");
            if (it.hasNext())
                result.append(" , ");
        }
        result.append("]");
        return result.toString();
    }

    public static BigDecimal getGoodPriceLong(BigDecimal low_price, BigDecimal hight_price) {
        BigDecimal range = (hight_price.subtract(low_price));

        range = range.divide(BigDecimal.valueOf(5), 10, RoundingMode.CEILING);

        BigDecimal good_price = low_price.add(range);

        return good_price;
    }

    public static BigDecimal getGoodPriceShort(BigDecimal low_price, BigDecimal hight_price) {
        BigDecimal range = (hight_price.subtract(low_price));

        range = range.divide(BigDecimal.valueOf(5), 10, RoundingMode.CEILING);

        BigDecimal good_price = hight_price.subtract(range);

        return good_price;
    }

    public static BigDecimal getStopLossForLong(BigDecimal low_price, BigDecimal open_candle) {
        if (getBigDecimal(low_price).equals(BigDecimal.ZERO)) {
            return BigDecimal.valueOf(1000000);
        }
        if (getBigDecimal(open_candle).equals(BigDecimal.ZERO)) {
            return BigDecimal.valueOf(1000000);
        }

        BigDecimal candle_beard_length = open_candle.subtract(low_price);
        candle_beard_length = candle_beard_length.divide(BigDecimal.valueOf(2), 10, RoundingMode.CEILING);

        BigDecimal stop_loss = low_price.subtract(candle_beard_length);
        return stop_loss;
    }

    public static BigDecimal getPriceAtMidCandle(BigDecimal open_candle, BigDecimal close_candle) {
        BigDecimal candle_beard_length = close_candle.subtract(open_candle);
        candle_beard_length = candle_beard_length.divide(BigDecimal.valueOf(2), 10, RoundingMode.CEILING);

        BigDecimal mid = open_candle.add(candle_beard_length);
        return mid;
    }

    public static BigDecimal getStopLossForShort(BigDecimal hight_price, BigDecimal close_candle) {
        if (getBigDecimal(hight_price).equals(BigDecimal.ZERO)) {
            return BigDecimal.valueOf(1000000);
        }
        if (getBigDecimal(close_candle).equals(BigDecimal.ZERO)) {
            return BigDecimal.valueOf(1000000);
        }

        BigDecimal candle_beard_length = hight_price.subtract(close_candle);
        candle_beard_length = candle_beard_length.divide(BigDecimal.valueOf(2), 10, RoundingMode.CEILING);

        BigDecimal stop_loss = hight_price.add(candle_beard_length);
        return stop_loss;
    }

    public static BigDecimal getGoodPriceLongByPercent(BigDecimal cur_price, BigDecimal low_price,
            BigDecimal open_candle, BigDecimal stop_loss_percent) {
        BigDecimal stop_loss = getStopLossForLong(low_price, open_candle);

        BigDecimal good_price = cur_price;
        while (true) {
            BigDecimal stop_loss_percent_curr = getPercent(good_price, stop_loss);
            if (stop_loss_percent_curr.compareTo(stop_loss_percent) < 0) {
                break;
            } else {
                good_price = good_price.subtract(BigDecimal.valueOf(10));
            }
        }

        return good_price;
    }

    public static BigDecimal getGoodPriceShortByPercent(BigDecimal cur_price, BigDecimal hight_price,
            BigDecimal close_candle, BigDecimal stop_loss_percent) {
        BigDecimal stop_loss = getStopLossForShort(hight_price, close_candle);

        BigDecimal good_price = cur_price;
        while (true) {
            BigDecimal stop_loss_percent_curr = getPercent(stop_loss, good_price);
            if (stop_loss_percent_curr.compareTo(stop_loss_percent) < 0) {
                break;
            } else {
                good_price = good_price.add(BigDecimal.valueOf(10));
            }
        }

        return good_price;
    }

    public static Boolean isInTheBeardOfPinBar(BtcFutures dto, BigDecimal cur_price) {
        BigDecimal max = dto.getPrice_open_candle().compareTo(dto.getPrice_close_candle()) > 0
                ? dto.getPrice_open_candle()
                : dto.getPrice_close_candle();

        if (cur_price.compareTo(max) < 0) {
            return true;
        }

        if (cur_price.compareTo(dto.getHight_price()) < 0) {
            return true;
        }

        return false;
    }

    public static Boolean isInTheBeardOfHamver(BtcFutures dto, BigDecimal cur_price) {
        BigDecimal max = dto.getPrice_open_candle().compareTo(dto.getPrice_close_candle()) > 0
                ? dto.getPrice_open_candle()
                : dto.getPrice_close_candle();

        if (cur_price.compareTo(max) > 0) {
            return true;
        }

        if (cur_price.compareTo(dto.getLow_price()) > 0) {
            return true;
        }

        return false;
    }

    public static Boolean isPinBar(BtcFutures dto) {
        if (dto.isUptrend()) {
            BigDecimal range_candle = getPercent(dto.getPrice_close_candle(), dto.getPrice_open_candle());
            BigDecimal range_beard = getPercent(dto.getPrice_open_candle(), dto.getLow_price());

            if (range_beard.compareTo(range_candle.multiply(BigDecimal.valueOf(3))) > 0) {
                return true;
            }
        } else {
            BigDecimal range_candle = getPercent(dto.getPrice_open_candle(), dto.getPrice_close_candle());
            BigDecimal range_beard = getPercent(dto.getPrice_close_candle(), dto.getLow_price());

            if (range_beard.compareTo(range_candle.multiply(BigDecimal.valueOf(3))) > 0) {
                return true;
            }
        }

        return false;
    }

    public static Boolean isHammer(BtcFutures dto) {
        if (dto.isUptrend()) {
            BigDecimal range_candle = getPercent(dto.getPrice_close_candle(), dto.getPrice_open_candle());
            BigDecimal range_beard = getPercent(dto.getHight_price(), dto.getPrice_close_candle());

            if (range_beard.compareTo(range_candle.multiply(BigDecimal.valueOf(1))) > 0) {
                return true;
            }
        } else {
            BigDecimal range_candle = getPercent(dto.getPrice_open_candle(), dto.getPrice_close_candle());
            BigDecimal range_beard = getPercent(dto.getHight_price(), dto.getPrice_open_candle());

            if (range_beard.compareTo(range_candle.multiply(BigDecimal.valueOf(1))) > 0) {
                return true;
            }
        }

        return false;
    }

    public static Boolean isPumpingCandle(List<BtcFutures> list_15m) {
        if (CollectionUtils.isEmpty(list_15m)) {
            return false;
        }

        if (!list_15m.get(0).isUptrend()) {
            return false;
        }

        int count_x4_vol = 0;
        BigDecimal max_vol = list_15m.get(0).getTrading_volume();

        for (BtcFutures dto : list_15m) {
            if (dto.getTrading_volume().multiply(BigDecimal.valueOf(3)).compareTo(max_vol) < 0) {
                count_x4_vol += 1;
            }

            if (dto.isZeroPercentCandle()) {
                count_x4_vol += 1;
            }
        }

        if (count_x4_vol > 4) {
            return true;
        }

        return false;
    }

    public static Boolean hasPumpingCandle(List<BtcFutures> list_15m) {
        if (CollectionUtils.isEmpty(list_15m)) {
            return false;
        }

        int count_x4_vol = 0;
        for (BtcFutures dto : list_15m) {
            if (dto.is15mPumpingCandle()) {
                count_x4_vol += 1;
            }
        }

        if (count_x4_vol > 0) {
            return true;
        }

        return false;
    }

    public static Boolean hasPumpCandle(List<BtcFutures> list_15m, boolean isLong) {
        if (CollectionUtils.isEmpty(list_15m)) {
            return false;
        }

        int count_x4_vol = 0;
        BigDecimal max_vol = list_15m.get(0).getTrading_volume();

        for (BtcFutures dto : list_15m) {
            if (dto.getTrading_volume().compareTo(max_vol) > 0) {
                if (isLong) {
                    if (dto.isUptrend()) {
                        max_vol = dto.getTrading_volume();
                    }
                } else {
                    max_vol = dto.getTrading_volume();
                }
            }
        }

        for (BtcFutures dto : list_15m) {
            if (dto.getTrading_volume().multiply(BigDecimal.valueOf(3)).compareTo(max_vol) < 0) {
                count_x4_vol += 1;
            }

            if (dto.isZeroPercentCandle()) {
                count_x4_vol += 1;
            }
        }

        if (count_x4_vol > 4) {
            return true;
        }

        return false;
    }

    public static boolean isAboveMALine(List<BtcFutures> list, int length, int ofCandleIndex) {
        BigDecimal ma = calcMA(list, length, ofCandleIndex);

        if ((list.get(ofCandleIndex).getPrice_close_candle().compareTo(ma) > 0)) {
            return true;
        }

        return false;
    }

    public static boolean isBelowMALine(List<BtcFutures> list, int length, int ofCandleIndex) {
        BigDecimal ma = calcMA(list, length, ofCandleIndex);

        if ((list.get(ofCandleIndex).getPrice_close_candle().compareTo(ma) < 0)) {
            return true;
        }

        return false;
    }

    public static int getSlowIndex(List<BtcFutures> list) {
        String symbol = list.get(0).getId().toLowerCase();
        if (symbol.contains("_4h_")) {
            return 50;
        }
        if (symbol.contains("_1d_")) {
            return 8;
        }
        if (symbol.contains("_1w_")) {
            return 8;
        }

        return 50;
    }

    @SuppressWarnings("unused")
    private static boolean isScapChart(List<BtcFutures> list) {
        String symbol = list.get(0).getId().toLowerCase();
        if (symbol.contains("_1h_")) {
            return true;
        }
        if (symbol.contains("_2h_")) {
            return false;
        }
        if (symbol.contains("_4h_")) {
            return false;
        }
        if (symbol.contains("_1d_")) {
            return false;
        }
        if (symbol.contains("_1w_")) {
            return false;
        }

        return true;
    }

    public static String getCurrentPrice(List<BtcFutures> list) {
        return Utils.appendSpace("(" + Utils.removeLastZero(list.get(0).getCurrPrice()) + ")", 12);
    }

    public static String getChartName(List<BtcFutures> list) {
        String result = "";

        try {
            if (CollectionUtils.isEmpty(list)) {
                return "";
            }

            String symbol = list.get(0).getId().toLowerCase();

            if (symbol.contains("_15m_")) {
                result = "(15m)";
            } else if (symbol.contains("_1h_")) {
                result = "(H1)";
            } else if (symbol.contains("_2h_")) {
                result = "(H2)";
            } else if (symbol.contains("_4h_")) {
                result = "(H4)";
            } else if (symbol.contains("_1d_")) {
                result = "(D1)";
            } else if (symbol.contains("_1w_")) {
                result = "(W)";
            } else {
                // symbol = symbol.replace("_00", "");
                // symbol = symbol.substring(symbol.indexOf("_"), symbol.length()).replace("_",
                // "");
                result = "(" + symbol.replace("_00", "") + ")";
            }
        } catch (Exception e) {
            return list.get(0).getId();
        }

        return Utils.appendSpace(result, 6);
    }

    public static List<BigDecimal> calcFiboTakeProfit(BigDecimal low_heigh, BigDecimal entry) {
        BigDecimal sub1_0 = entry.subtract(low_heigh);

        List<BigDecimal> result = new ArrayList<BigDecimal>();
        BigDecimal tp_3618 = low_heigh.add((sub1_0.multiply(BigDecimal.valueOf(3.618))));
        BigDecimal tp_4236 = low_heigh.add((sub1_0.multiply(BigDecimal.valueOf(4.236))));
        BigDecimal tp_6854 = low_heigh.add((sub1_0.multiply(BigDecimal.valueOf(6.854))));

        BigDecimal SL = low_heigh;
        BigDecimal entry2 = entry;

        SL = roundDefault(SL);
        entry2 = roundDefault(entry2);
        tp_3618 = roundDefault(tp_3618);
        tp_4236 = roundDefault(tp_4236);
        tp_6854 = roundDefault(tp_6854);

        result.add(SL); // 1
        result.add(entry2); // 1
        result.add(tp_3618); // 3.618
        result.add(tp_4236); // 4.236
        result.add(tp_6854); // 6.854

        return result;
    }

    public static String timingTarget(String chartName, int length) {
        if (length < 1) {
            return "";
        }
        Calendar calendar = Calendar.getInstance();
        int hours = getCurrentHH();

        if (chartName.contains("2h") || chartName.contains("h2")) {
            hours = hours / 2;
            hours = hours * 2;
            calendar.set(Calendar.HOUR_OF_DAY, hours - 1);
            calendar.add(Calendar.HOUR_OF_DAY, length * 2);
        } else if (chartName.contains("4h") || chartName.contains("h4")) {
            hours = hours / 4;
            hours = hours * 4;
            calendar.set(Calendar.HOUR_OF_DAY, hours - 1);
            calendar.add(Calendar.HOUR_OF_DAY, length * 4);
        }

        String dayOfWeek = calendar.getDisplayName(Calendar.DAY_OF_WEEK, Calendar.SHORT, Locale.US);
        String result = Utils.convertDateToString("HH", calendar.getTime()) + "h." + dayOfWeek
                + Utils.convertDateToString(".dd", calendar.getTime());

        return result;
    }

    public static String analysisVolume(List<BtcFutures> list) {
        String symbol = list.get(0).getId();
        if (!symbol.contains("_1d_")) {
            return "";
        }

        BigDecimal avg_qty = BigDecimal.ZERO;
        int length = list.size();
        if (length > 13) {
            length = 13;
        }
        int count = 0;
        for (BtcFutures dto : list) {
            if (count < length) {
                count += 1;
                avg_qty = avg_qty.add(dto.getTaker_volume());
            }
        }

        if (count > 0) {
            avg_qty = avg_qty.divide(BigDecimal.valueOf(count), 0, RoundingMode.CEILING);
        }
        BigDecimal tem_qty = avg_qty.multiply(BigDecimal.valueOf(1));
        BigDecimal cur_qty_0 = list.get(0).getTaker_volume();
        BigDecimal pre_qty_1 = list.get(1).getTaker_volume();
        BigDecimal pre_qty_2 = list.get(2).getTaker_volume();

        String result = "";
        if (cur_qty_0.compareTo(tem_qty) > 0) {
            result += getDD(0) + "x" + formatPrice(cur_qty_0.divide(avg_qty, 2, RoundingMode.CEILING), 1);
        }

        if (pre_qty_1.compareTo(tem_qty) > 0) {
            result += getDD(-1) + "x" + formatPrice(pre_qty_1.divide(avg_qty, 2, RoundingMode.CEILING), 1);
        }

        if (pre_qty_2.compareTo(tem_qty) > 0) {
            result += getDD(-2) + "x" + formatPrice(pre_qty_2.divide(avg_qty, 2, RoundingMode.CEILING), 1);
        }

        result = result.trim().replace(".0", "");

        if (isNotBlank(result)) {
            result = "volma{Qty " + result + "}volma";
        }

        return result;
    }

    public static String percentToMa(List<BtcFutures> list, BigDecimal curr_price) {
        BigDecimal ma7d = calcMA10d(list, 0);

        String percent = toPercent(ma7d, curr_price);

        String value = removeLastZero(formatPriceLike(ma7d, BigDecimal.valueOf(0.0001))) + "(" + percent + "%)";

        return value;
    }

    public static BigDecimal calcMA(List<BtcFutures> list, int length, int ofCandleIndex) {
        BigDecimal sum = BigDecimal.ZERO;

        int count = 0;
        for (int index = ofCandleIndex; index < length + ofCandleIndex; index++) {
            if (index < list.size()) {
                count += 1;
                BtcFutures dto = list.get(index);
                sum = sum.add(dto.getPrice_close_candle());
            }
        }

        if (count > 0) {
            sum = sum.divide(BigDecimal.valueOf(count), 10, RoundingMode.CEILING);
        }

        return sum;
    }

    public static BigDecimal calcMA10d(List<BtcFutures> list, int ofIndex) {
        BigDecimal sum = BigDecimal.ZERO;

        int count = 0;
        for (int index = ofIndex; index < 10 + ofIndex; index++) {
            if (index < list.size()) {
                count += 1;
                BtcFutures dto = list.get(index);
                sum = sum.add(dto.getPrice_close_candle());
            }
        }
        if (count > 0) {
            sum = sum.divide(BigDecimal.valueOf(count), 10, RoundingMode.CEILING);
        }

        return sum;
    }

    // if (Utils.rangeOfLowHeigh(list_5m).compareTo(BigDecimal.valueOf(0.5)) > 0) {

    public static BigDecimal rangeOfLowHeigh(List<BtcFutures> list) {
        List<BigDecimal> LowHeight = getLowHeightCandle(list);

        return getPercent(LowHeight.get(1), LowHeight.get(0));
    }

    public static boolean isDangerRange(List<BtcFutures> list) {
        BigDecimal ma3 = calcMA(list, 3, 0);

        List<BigDecimal> low_heigh = Utils.getLowHeightCandle(list);
        BigDecimal range = low_heigh.get(1).subtract(low_heigh.get(0));
        range = range.divide(BigDecimal.valueOf(4), 10, RoundingMode.CEILING);
        BigDecimal max_allow_long = low_heigh.get(1).subtract(range);
        if (ma3.compareTo(max_allow_long) > 0) {
            return true;
        }

        return false;
    }

    public static List<BigDecimal> getLowHeightCandle(List<BtcFutures> list) {
        List<BigDecimal> result = new ArrayList<BigDecimal>();

        BigDecimal min_low = BigDecimal.valueOf(1000000);
        BigDecimal max_Hig = BigDecimal.ZERO;

        for (BtcFutures dto : list) {
            if (min_low.compareTo(dto.getLow_price()) > 0) {
                min_low = dto.getLow_price();
            }

            if (max_Hig.compareTo(dto.getHight_price()) < 0) {
                max_Hig = dto.getHight_price();
            }
        }

        result.add(min_low);
        result.add(max_Hig);

        return result;
    }

    public static List<BigDecimal> getOpenCloseCandle(List<BtcFutures> list) {
        List<BigDecimal> result = new ArrayList<BigDecimal>();

        BigDecimal min_low = BigDecimal.valueOf(1000000);
        BigDecimal max_Hig = BigDecimal.ZERO;

        for (BtcFutures dto : list) {
            if (dto.isUptrend()) {
                if (min_low.compareTo(dto.getPrice_open_candle()) > 0) {
                    min_low = dto.getPrice_open_candle();
                }

                if (max_Hig.compareTo(dto.getPrice_open_candle()) < 0) {
                    max_Hig = dto.getPrice_open_candle();
                }
            } else {
                if (min_low.compareTo(dto.getPrice_close_candle()) > 0) {
                    min_low = dto.getPrice_close_candle();
                }

                if (max_Hig.compareTo(dto.getPrice_close_candle()) < 0) {
                    max_Hig = dto.getPrice_close_candle();
                }
            }

        }

        result.add(min_low);
        result.add(max_Hig);

        return result;
    }

    public static String getTypeLongOrShort(List<BtcFutures> list) {
        String result = "0:Sideway";

        BigDecimal curr_price = list.get(0).getCurrPrice();

        List<BigDecimal> low_heigh = getLowHeightCandle(list);

        BigDecimal price_long = getGoodPriceLong(low_heigh.get(0), low_heigh.get(1));
        BigDecimal price_short = getGoodPriceShort(low_heigh.get(0), low_heigh.get(1));

        if (curr_price.compareTo(price_long) < 0) {

            return "1:Long";

        } else if (curr_price.compareTo(price_short) > 0) {

            return "2:Short";

        }

        return result;
    }

    public static Boolean isGoodPrice4Posision(BigDecimal cur_price, BigDecimal lo_price, int percent_maxpain) {
        BigDecimal curr_price = Utils.getBigDecimal(cur_price);
        BigDecimal low_price = Utils.getBigDecimal(lo_price);

        BigDecimal sl = Utils.getPercent(curr_price, low_price);
        if (sl.compareTo(BigDecimal.valueOf(percent_maxpain)) > 0) {
            return false;
        }
        return true;
    }

    public static Boolean isGoodPriceLong(BigDecimal cur_price, BigDecimal lo_price, BigDecimal hi_price) {
        BigDecimal curr_price = Utils.getBigDecimal(cur_price);
        BigDecimal low_price = Utils.getBigDecimal(lo_price);
        BigDecimal hight_price = Utils.getBigDecimal(hi_price);

        BigDecimal sl = Utils.getPercent(curr_price, low_price);
        if (sl.compareTo(BigDecimal.valueOf(10)) > 0) {
            return false;
        }

        BigDecimal good_price = getGoodPriceLong(low_price, hight_price);

        if (curr_price.compareTo(good_price) < 0) {
            return true;
        }
        return false;
    }

    public static Boolean isGoodPriceShort(BigDecimal cur_price, BigDecimal lo_price, BigDecimal hi_price) {
        BigDecimal curr_price = Utils.getBigDecimal(cur_price);
        BigDecimal low_price = Utils.getBigDecimal(lo_price);
        BigDecimal hight_price = Utils.getBigDecimal(hi_price);

        BigDecimal sl = Utils.getPercent(hight_price, curr_price);
        if (sl.compareTo(BigDecimal.valueOf(10)) > 0) {
            return false;
        }

        BigDecimal range = (hight_price.subtract(low_price));
        range = range.divide(BigDecimal.valueOf(5), 10, RoundingMode.CEILING);

        BigDecimal mid_price = hight_price.subtract(range);

        if (curr_price.compareTo(mid_price) > 0) {
            return true;
        }

        return false;
    }

    public static BigDecimal getNextEntry(BtcFuturesResponse dto_1h) {
        BigDecimal entry0 = dto_1h.getOpen_price_half1().subtract(dto_1h.getOpen_price_half2());

        BigDecimal percent_angle = Utils.getPercent(dto_1h.getOpen_price_half2(), dto_1h.getOpen_price_half1()).abs();
        if (percent_angle.compareTo(BigDecimal.valueOf(2)) > 0) {
            return null;
        }
        entry0 = entry0.multiply(Utils.getBigDecimal(dto_1h.getId_half1()));
        int id_haft1 = Utils.getIntValue(dto_1h.getId_half1().replaceAll("BTC_1h_", ""));
        int id_haft2 = Utils.getIntValue(dto_1h.getId_half2().replaceAll("BTC_1h_", ""));
        entry0 = entry0.divide(BigDecimal.valueOf(id_haft2 - id_haft1), 0, RoundingMode.CEILING);
        entry0 = dto_1h.getOpen_price_half1().add(entry0);

        return entry0;
    }

    public static String checkTrend(BtcFuturesResponse dto) {
        BigDecimal percent_angle = Utils.getPercent(dto.getOpen_price_half1(), dto.getOpen_price_half2());

        // Uptrend
        if (percent_angle.compareTo(BigDecimal.valueOf(0.5)) > 0) {
            return "1:Uptrend";
        }

        // Downtrend
        if (percent_angle.compareTo(BigDecimal.valueOf(-0.5)) < 0) {
            return "2:Downtrend";
        }

        // Sideway
        return "3:Sideway";
    }

    public static String getMsgLong(String symbol, BigDecimal entry, BigDecimal low, BigDecimal open, BigDecimal hig) {

        BigDecimal stop_loss = Utils.getStopLossForLong(low, open);
        BigDecimal candle_height = hig.subtract(entry);
        BigDecimal mid_candle = candle_height.divide(BigDecimal.valueOf(2), 10, RoundingMode.CEILING);
        BigDecimal take_porfit_1 = entry.add(mid_candle);
        BigDecimal take_porfit_2 = hig;

        BigDecimal fee = BigDecimal.valueOf(2);
        BigDecimal loss = BigDecimal.valueOf(1000).multiply(stop_loss.subtract(entry))
                .divide(entry, 0, RoundingMode.CEILING).subtract(fee);
        BigDecimal tp1 = BigDecimal.valueOf(1000).multiply(take_porfit_1.subtract(entry))
                .divide(entry, 0, RoundingMode.CEILING).subtract(fee);
        BigDecimal tp2 = BigDecimal.valueOf(1000).multiply(take_porfit_2.subtract(entry))
                .divide(entry, 0, RoundingMode.CEILING).subtract(fee);

        String msg = "(Long) Scalping: " + symbol + Utils.new_line_from_service;

        msg += "E: " + Utils.removeLastZero(entry.toString()) + "$" + Utils.new_line_from_service;

        msg += "SL: " + Utils.removeLastZero(String.valueOf(stop_loss)) + "(" + Utils.toPercent(stop_loss, entry)
                + "%) 1000$/" + loss + "$";
        msg += Utils.new_line_from_service;

        msg += "L: " + Utils.removeLastZero(String.valueOf(low)) + "(" + Utils.toPercent(low, entry) + "%)";
        msg += Utils.new_line_from_service;

        msg += "TP1: " + Utils.removeLastZero(String.valueOf(take_porfit_1)) + "("
                + Utils.toPercent(take_porfit_1, entry) + "%) 1000$/" + tp1 + "$";
        msg += Utils.new_line_from_service;

        msg += "TP2: " + Utils.removeLastZero(String.valueOf(take_porfit_2)) + "("
                + Utils.toPercent(take_porfit_2, entry) + "%) 1000$/" + tp2 + "$";

        return msg;
    }

    public static String getMsgLowHeight(BigDecimal price_at_binance, BtcFuturesResponse dto) {
        String low_height = "";

        String btc_now = Utils.removeLastZero(String.valueOf(price_at_binance)) + " (now)"
                + Utils.new_line_from_service;

        BigDecimal SL_short = Utils.getStopLossForShort(dto.getHight_price_h(), dto.getClose_candle_h());

        low_height += "SL: " + Utils.removeLastZero(SL_short) + " (" + Utils.toPercent(SL_short, price_at_binance)
                + "%)" + Utils.new_line_from_service;

        low_height += "H: " + Utils.removeLastZero(dto.getHight_price_h()) + " ("
                + Utils.toPercent(dto.getHight_price_h(), price_at_binance) + "%)" + Utils.new_line_from_service;

        if (price_at_binance.compareTo(dto.getClose_candle_h()) > 0) {
            low_height += btc_now;
        }

        low_height += "C: " + Utils.removeLastZero(dto.getClose_candle_h()) + " ("
                + Utils.toPercent(dto.getClose_candle_h(), price_at_binance) + "%)" + Utils.new_line_from_service;

        if (price_at_binance.compareTo(dto.getClose_candle_h()) < 0
                && price_at_binance.compareTo(dto.getOpen_candle_h()) > 0) {
            low_height += btc_now;
        }

        low_height += "O: " + Utils.removeLastZero(dto.getOpen_candle_h()) + " ("
                + Utils.toPercent(dto.getOpen_candle_h(), price_at_binance) + "%)" + Utils.new_line_from_service;

        if (price_at_binance.compareTo(dto.getOpen_candle_h()) < 0) {
            low_height += btc_now;
        }

        low_height += "L: " + Utils.removeLastZero(dto.getLow_price_h()) + " ("
                + Utils.toPercent(dto.getLow_price_h(), price_at_binance) + "%)" + Utils.new_line_from_service;

        BigDecimal SL_long = Utils.getStopLossForLong(dto.getLow_price_h(), dto.getOpen_candle_h());

        low_height += "SL: " + Utils.removeLastZero(SL_long) + " (" + Utils.toPercent(SL_long, price_at_binance) + "%)";

        return low_height;
    }

    public static String getMsgLong(BigDecimal entry, BtcFuturesResponse dto) {
        String msg = "";

        BigDecimal stop_loss = Utils.getStopLossForLong(dto.getLow_price_h(), dto.getOpen_candle_h());

        BigDecimal candle_height = dto.getClose_candle_h().subtract(dto.getOpen_candle_h());
        BigDecimal mid_candle = candle_height.divide(BigDecimal.valueOf(2), 0, RoundingMode.CEILING);
        BigDecimal take_porfit_1 = dto.getOpen_candle_h().add(mid_candle);
        BigDecimal take_porfit_2 = dto.getHight_price_h().subtract(BigDecimal.valueOf(10));

        BigDecimal fee = BigDecimal.valueOf(2);
        BigDecimal loss = BigDecimal.valueOf(1000).multiply(stop_loss.subtract(entry))
                .divide(entry, 0, RoundingMode.CEILING).subtract(fee);
        BigDecimal tp1 = BigDecimal.valueOf(1000).multiply(take_porfit_1.subtract(entry))
                .divide(entry, 0, RoundingMode.CEILING).subtract(fee);
        BigDecimal tp2 = BigDecimal.valueOf(1000).multiply(take_porfit_2.subtract(entry))
                .divide(entry, 0, RoundingMode.CEILING).subtract(fee);

        msg += "E: " + Utils.removeLastZero(entry.toString()) + "$" + Utils.new_line_from_service;

        msg += "SL: " + Utils.removeLastZero(stop_loss) + "(" + Utils.toPercent(stop_loss, entry) + "%) 1000$/" + loss
                + "$";
        msg += Utils.new_line_from_service;

        msg += "L: " + Utils.removeLastZero(dto.getLow_price_h()) + "(" + Utils.toPercent(dto.getLow_price_h(), entry)
                + "%)";
        msg += Utils.new_line_from_service;

        msg += "TP1: " + Utils.removeLastZero(take_porfit_1) + "(" + Utils.toPercent(take_porfit_1, entry) + "%) 1000$/"
                + tp1 + "$";
        msg += Utils.new_line_from_service;

        msg += "TP2: " + Utils.removeLastZero(take_porfit_2) + "(" + Utils.toPercent(take_porfit_2, entry) + "%) 1000$/"
                + tp2 + "$";

        return msg;
    }

    public static FundingResponse loadFundingRate(String symbol) {
        FundingResponse dto = new FundingResponse();
        int limit = 4;
        BigDecimal high = BigDecimal.valueOf(-100);
        BigDecimal low = BigDecimal.valueOf(100);

        // https://www.binance.com/fapi/v1/marketKlines?interval=15m&limit=4&symbol=pBTCUSDT
        String url = "https://www.binance.com/fapi/v1/marketKlines?interval=15m&limit=" + limit + "&symbol=p" + symbol
                + "USDT";
        List<Object> funding_rate_objs = Utils.getBinanceData(url, limit);
        if (CollectionUtils.isEmpty(funding_rate_objs)) {
            dto.setHigh(high);
            dto.setLow(low);
            dto.setAvg_high(high);
            dto.setAvg_low(low);

            return dto;
        }

        BigDecimal total_high = BigDecimal.ZERO;
        BigDecimal total_low = BigDecimal.ZERO;
        for (int index = 0; index < funding_rate_objs.size(); index++) {
            Object obj = funding_rate_objs.get(index);

            @SuppressWarnings("unchecked")
            List<Object> arr_ = (List<Object>) obj;
            if (CollectionUtils.isEmpty(arr_) || arr_.size() < 4) {
                continue;
            }
            // BigDecimal open = Utils.getBigDecimal(arr_.get(1));
            BigDecimal tmp_high = Utils.getBigDecimal(arr_.get(2)).multiply(BigDecimal.valueOf(100));
            BigDecimal tmp_low = Utils.getBigDecimal(arr_.get(3)).multiply(BigDecimal.valueOf(100));
            // BigDecimal close = Utils.getBigDecimal(arr_.get(4));

            if (tmp_high.compareTo(high) > 0) {
                high = tmp_high;
            }

            if (tmp_low.compareTo(low) < 0) {
                low = tmp_low;
            }

            if (index < limit) {
                total_high = total_high.add(tmp_high);
                total_low = total_low.add(tmp_low);
            }
        }

        BigDecimal avg_high = total_high.divide(BigDecimal.valueOf(limit - 1), 10, RoundingMode.CEILING);
        BigDecimal avg_low = total_low.divide(BigDecimal.valueOf(limit - 1), 10, RoundingMode.CEILING);

        dto.setHigh(high);
        dto.setLow(low);
        dto.setAvg_high(avg_high);
        dto.setAvg_low(avg_low);

        return dto;
    }

    public static String getScapLong(List<BtcFutures> list_entry, List<BtcFutures> list_tp, int usd, boolean isLong) {
        try {
            BigDecimal curr_price = list_entry.get(0).getCurrPrice();
            List<BigDecimal> low_heigh_tp = getLowHeightCandle(list_tp);
            List<BigDecimal> low_heigh_sl = getLowHeightCandle(list_entry.subList(0, 15));
            int slow_index = getSlowIndex(list_entry);

            BigDecimal entry = curr_price;
            BigDecimal ma_slow = calcMA(list_entry, slow_index, 0);
            BigDecimal SL = BigDecimal.ZERO;
            BigDecimal TP = BigDecimal.ZERO;
            String type = "";
            if (isLong) {
                type = "(Long) ";
                SL = low_heigh_sl.get(0);
                SL = SL.multiply(BigDecimal.valueOf(0.9995));
                TP = low_heigh_tp.get(1);
            } else {
                type = "(Short) ";
                SL = low_heigh_sl.get(1);
                SL = SL.multiply(BigDecimal.valueOf(1.0005));
                TP = low_heigh_tp.get(0);
            }

            entry = roundDefault(entry);
            SL = roundDefault(SL);
            TP = roundDefault(TP);
            ma_slow = roundDefault(ma_slow);

            BigDecimal vol = BigDecimal.valueOf(usd).divide(entry.subtract(SL), 10, RoundingMode.CEILING);
            vol = formatPrice(vol.multiply(entry).abs(), 0);

            BigDecimal earn = TP.subtract(entry).abs().divide(entry, 10, RoundingMode.CEILING);
            earn = formatPrice(vol.multiply(earn), 1);

            String result = type + "SL" + getChartName(list_entry) + ": " + getPercentToEntry(entry, SL, false);
            result += ",E: " + removeLastZero(entry);
            result += ",TP: " + getPercentToEntry(entry, TP, false);
            result += ",Vol: " + removeLastZero(vol).replace(".0", "") + ":" + usd + ":" + removeLastZero(earn) + "$";

            if (earn.compareTo(BigDecimal.valueOf(usd / 2)) < 0) {
                // result += TREND_DANGER;
            }

            return result;

        } catch (Exception e) {
            return "";
        }
    }

    public static String getScapLongOrShort(List<BtcFutures> list_find_entry, List<BtcFutures> list_tp, int usd,
            boolean isLong) {
        try {
            List<BigDecimal> low_heigh_tp1 = getLowHeightCandle(list_tp);
            List<BigDecimal> low_heigh_sl = getLowHeightCandle(list_find_entry.subList(0, 15));

            // BigDecimal ma10 = calcMA(list_entry, 10, 0);
            BigDecimal SL = BigDecimal.ZERO;
            BigDecimal TP1 = BigDecimal.ZERO;
            String type = "";
            if (isLong) {
                type = "(Long)";
                // check long
                SL = low_heigh_sl.get(0);
                SL = SL.multiply(BigDecimal.valueOf(0.9995));
                TP1 = low_heigh_tp1.get(1);
            } else {
                // check short
                type = "(Short)";
                SL = low_heigh_sl.get(1);
                SL = SL.multiply(BigDecimal.valueOf(1.0005));
                TP1 = low_heigh_tp1.get(0);
            }

            BigDecimal curr_price = list_find_entry.get(0).getCurrPrice();
            BigDecimal entry = curr_price;

            entry = roundDefault(entry);
            SL = roundDefault(SL);
            TP1 = roundDefault(TP1);

            BigDecimal vol = BigDecimal.valueOf(usd).divide(entry.subtract(SL), 10, RoundingMode.CEILING);
            vol = formatPrice(vol.multiply(entry).abs(), 0);

            BigDecimal earn1 = TP1.subtract(entry).abs().divide(entry, 10, RoundingMode.CEILING);
            earn1 = formatPrice(vol.multiply(earn1), 1);

            String result = type;
            result += " SL" + getChartName(list_find_entry) + ": " + getPercentToEntry(entry, SL, false);
            result += ",E: " + removeLastZero(entry) + "$";
            result += ",TP: " + getPercentToEntry(entry, TP1, false);
            result += ",Vol: " + removeLastZero(vol).replace(".0", "") + ":" + usd + ":" + removeLastZero(earn1) + "$";

            if (earn1.compareTo(BigDecimal.valueOf(usd / 2)) < 0) {
                // result += TREND_DANGER;
            }

            return result;

        } catch (Exception e) {
            return "";
        }
    }

    public static String percentMa3to50(List<BtcFutures> list) {
        if (list.size() < 50) {
            return "";
        }
        int cur = 0;
        BigDecimal ma_fast_c = calcMA(list, MA_FAST, cur);
        int size = list.size();
        if (size > 50) {
            size = 50;
        }
        BigDecimal ma_size = calcMA(list, size, cur);
        String str_ma_size = "";
        String chartName = getChartName(list);
        String per = getPercentToEntry(ma_fast_c, ma_size, true);
        if (ma_fast_c.compareTo(ma_size) > 0) {
            str_ma_size += "Above_Ma" + size + "" + chartName + ":" + per;
        } else {
            str_ma_size += "Below_Ma" + size + "" + chartName + ":" + per;
        }

        return str_ma_size;
    }

    public static String calcVol(List<BtcFutures> list, boolean isLong) {
        BigDecimal entry = list.get(0).getCurrPrice();
        BigDecimal SL = BigDecimal.ZERO;
        BigDecimal SL_10percent = BigDecimal.ZERO;
        BigDecimal SL_LowHeigh = BigDecimal.ZERO;
        List<BigDecimal> low_heigh = getLowHeightCandle(list);
        if (isLong) {
            SL_LowHeigh = low_heigh.get(0);
            SL_10percent = entry.multiply(BigDecimal.valueOf(0.9));
            SL = (SL_LowHeigh.compareTo(SL_10percent) > 0) ? SL_10percent : SL_LowHeigh;
        } else {
            SL_LowHeigh = low_heigh.get(1);
            SL_10percent = entry.multiply(BigDecimal.valueOf(1.1));
            SL = (SL_LowHeigh.compareTo(SL_10percent) < 0) ? SL_10percent : SL_LowHeigh;
        }

        int usd = 10;
        BigDecimal vol = BigDecimal.valueOf(usd).divide(entry.subtract(SL), 10, RoundingMode.CEILING);
        vol = formatPrice(vol.multiply(entry).abs(), 0);

        String result = getChartName(list);
        result += " atl:" + getPercentToEntry(entry, low_heigh.get(0), true);
        result += ", ath:" + getPercentToEntry(entry, low_heigh.get(1), true);
        result += ", vol: " + removeLastZero(vol).replace(".0", "") + ":" + usd + "$";

        result = "Vol: " + removeLastZero(vol).replace(".0", "") + ":" + usd + "$";
        return result;
    }

    public static String getAtlAth(List<BtcFutures> list) {
        BigDecimal entry = list.get(0).getCurrPrice();
        List<BigDecimal> low_heigh = getLowHeightCandle(list);
        String result = "";
        result += Utils.appendSpace(" atl:" + getPercentToEntry(entry, low_heigh.get(0), true), 20);
        result += " ath:" + getPercentToEntry(entry, low_heigh.get(1), true);
        result += getChartName(list);

        return Utils.appendSpace(result, 46);
    }

    public static String calc_BUF_LO_HI_BUF(List<BtcFutures> list, String trend) {
        BigDecimal buf = BigDecimal.ZERO;
        BigDecimal ma10 = calcMA(list, 10, 1);
        BigDecimal ma20 = calcMA(list, 20, 1);
        BigDecimal entry = list.get(0).getCurrPrice();
        BigDecimal range = ma10.subtract(ma20).abs();

        List<BigDecimal> low_heigh_SL = getLowHeightCandle(list.subList(0, 10));
        List<BigDecimal> low_heigh = getLowHeightCandle(list);
        BigDecimal LO = low_heigh.get(0);
        BigDecimal HI = low_heigh.get(1);

        String result = "";
        if (trend.contains(TREND_LONG)) {
            buf = roundDefault(low_heigh_SL.get(0).subtract(range));
            result += "Buf:" + getPercentToEntry(LO, buf, true);
            result += ",Lo:" + getPercentToEntry(entry, LO, true);
            result += ",Hi:" + getPercentToEntry(entry, HI, true);
        } else {
            buf = roundDefault(low_heigh_SL.get(1).add(range));
            result += "Lo:" + getPercentToEntry(entry, LO, true);
            result += ",Hi:" + getPercentToEntry(entry, HI, true);
            result += ",Buf:" + getPercentToEntry(HI, buf, true);
        }
        result += getChartName(list);

        return result;
    }

    public static String analysisTakerVolume(List<BtcFutures> list_days, List<BtcFutures> list_h4) {
        String taker = "";
        String vol_h4 = Utils.analysisTakerVolume_sub(list_h4, 50);
        String vol_d1 = Utils.analysisTakerVolume_sub(list_days, 30);
        if (Utils.isNotBlank(vol_h4 + vol_d1)) {
            taker += "Taker:";
            taker += Utils.isNotBlank(vol_h4) ? " (H4)" + vol_h4 : "";
            taker += Utils.isNotBlank(vol_d1) ? " (D)" + vol_d1 : "";
        }

        return taker;
    }

    private static String analysisTakerVolume_sub(List<BtcFutures> list, int maSlowIndex) {
        if (list.size() < 5) {
            return "";
        }
        String result = "";
        int length = list.size() > maSlowIndex ? list.size() : maSlowIndex;
        BigDecimal taker_volume = BigDecimal.ZERO;
        for (int index = 0; index < length; index++) {
            if (index < list.size()) {
                BtcFutures dto = list.get(index);
                taker_volume = taker_volume.add(dto.getTaker_volume());
            }
        }
        BigDecimal ma50_taker_volume = taker_volume.divide(BigDecimal.valueOf(length), 10, RoundingMode.CEILING);

        BigDecimal ma3_taker_volume_1 = (list.get(1).getTaker_volume().add(list.get(2).getTaker_volume())
                .add(list.get(3).getTaker_volume()));
        ma3_taker_volume_1 = ma3_taker_volume_1.divide(BigDecimal.valueOf(3), 10, RoundingMode.CEILING);

        BigDecimal ma3_taker_volume_2 = (list.get(4).getTaker_volume().add(list.get(2).getTaker_volume())
                .add(list.get(3).getTaker_volume()));
        ma3_taker_volume_2 = ma3_taker_volume_2.divide(BigDecimal.valueOf(3), 10, RoundingMode.CEILING);

        if ((ma3_taker_volume_1.compareTo(ma50_taker_volume) > 0)
                && (ma50_taker_volume.compareTo(ma3_taker_volume_2) > 0)) {
            result += " 3Up" + maSlowIndex;
        }

        if (ma3_taker_volume_1.compareTo(ma50_taker_volume.multiply(BigDecimal.valueOf(1.1))) > 0) {
            result += " :" + getPercentStr(ma3_taker_volume_1, ma50_taker_volume);
        }

        return result.trim();
    }

    public static boolean isStopLong(List<BtcFutures> list) {
        BigDecimal ma3_1 = calcMA(list, MA_FAST, 1);
        BigDecimal ma50_1 = calcMA(list, 50, 1);
        if (ma3_1.compareTo(ma50_1) < 0) {
            return false;
        }
        BigDecimal ma3_2 = calcMA(list, MA_FAST, 2);
        BigDecimal maClose_1 = calcMA(list, 20, 1);
        if ((ma3_1.compareTo(maClose_1) < 0) && (maClose_1.compareTo(ma3_2) < 0)) {
            return true;
        }
        return false;
    }

    private static String checkXCutUpY(BigDecimal maX_1, BigDecimal maX_2, BigDecimal maY_1, BigDecimal maY_2) {
        if ((maX_1.compareTo(maX_2) > 0) && (maX_1.compareTo(maY_1) > 0) && (maY_2.compareTo(maX_2) > 0)) {
            return TREND_LONG;
        }

        return "";
    }

    public static String checkMaXCuttingUpY(List<BtcFutures> list, int maFast, int maSlow) {
        if (list.size() < maSlow) {
            return "";
        }

        int str = 1;
        int end = 5;
        BigDecimal ma3_1 = calcMA(list, maFast, str);
        BigDecimal ma3_2 = calcMA(list, maFast, end);

        BigDecimal ma50_1 = calcMA(list, maSlow, str);
        BigDecimal ma50_2 = calcMA(list, maSlow, end);

        if ((ma3_1.compareTo(ma3_2) > 0) && (ma3_1.compareTo(ma50_1) > 0) && (ma50_2.compareTo(ma3_2) > 0)) {
            return TREND_LONG;
        }

        return "";
    }

    private static String checkXCutDownY(BigDecimal maX_1, BigDecimal maX_2, BigDecimal maY_1, BigDecimal maY_2) {
        if ((maX_1.compareTo(maX_2) < 0) && (maX_1.compareTo(maY_1) < 0) && (maY_2.compareTo(maX_2) < 0)) {
            return TREND_SHORT;
        }
        return "";
    }

    public static String checkMaXCuttingDownY(List<BtcFutures> list, int maFast, int maSlow) {
        if (list.size() < maSlow) {
            return "";
        }

        int str = 1;
        int end = 5;
        BigDecimal ma3_1 = calcMA(list, maFast, str);
        BigDecimal ma3_2 = calcMA(list, maFast, end);

        BigDecimal ma50_1 = calcMA(list, maSlow, str);
        BigDecimal ma50_2 = calcMA(list, maSlow, end);

        if ((ma3_1.compareTo(ma3_2) < 0) && (ma3_1.compareTo(ma50_1) < 0) && (ma50_2.compareTo(ma3_2) < 0)) {
            return TREND_SHORT;
        }

        return "";
    }

    public static String checkTrendByMa3_10_20(List<BtcFutures> list) {
        Boolean isUptrendByMa3 = Utils.isUptrendByMaIndex(list, 3);
        Boolean isUptrendByMa10 = Utils.isUptrendByMaIndex(list, 10);
        Boolean isUptrendByMa20 = Utils.isUptrendByMaIndex(list, 20);

        if (isUptrendByMa3 && isUptrendByMa10 && isUptrendByMa20) {
            return TREND_LONG;
        }
        if (!isUptrendByMa3 && !isUptrendByMa10 && !isUptrendByMa20) {
            return TREND_SHORT;
        }

        return "";
    }

    public static String switchTrend(List<BtcFutures> list) {
        if (CollectionUtils.isEmpty(list)) {
            return "";
        }
        if (Utils.getStringValue(list.get(0).getCurrPrice()).contains("E")) {
            return "";
        }

        String result = "";
        String trend_main = checkTrendSideway(list, 0, 2);
        String trend_confirm = checkTrendSideway(list, 3, 8);

        if (trend_main.contains(Utils.TREND_LONG) && trend_main.contains(Utils.TREND_SHORT)) {
            return "";
        }

        if (trend_main.contains(Utils.TREND_LONG)) {
            result = Utils.TREND_LONG;
            if (trend_confirm.contains(Utils.TREND_SHORT)) {
                return "";
            }
        }

        if (trend_main.contains(Utils.TREND_SHORT)) {
            result = Utils.TREND_SHORT;
            if (trend_confirm.contains(Utils.TREND_LONG)) {
                return "";
            }
        }

        return result;
    }

    private static String checkTrendSideway(List<BtcFutures> list, int str, int end) {
        String s_m03x10 = "";

        BigDecimal ma3_1 = calcMA(list, 3, str);
        BigDecimal ma3_2 = calcMA(list, 3, end);

        String l_m10x20 = "";
        String s_m10x20 = "";
        int slow_index = 8;
        if (list.get(0).getId().contains("_15m_")) {
            slow_index = 20;
        } else if (list.get(0).getId().contains("_1h_")) {
            slow_index = 10;
        }

        if (slow_index >= list.size()) {
            slow_index = list.size() - 1;
        }

        BigDecimal maX_1 = calcMA(list, slow_index, str);
        BigDecimal maX_2 = calcMA(list, slow_index, end);

        if (list.get(0).getId().contains("_15m_")) {
            BigDecimal ma10_1 = calcMA(list, 10, str);
            BigDecimal ma10_2 = calcMA(list, 10, end);

            l_m10x20 = Utils.checkXCutUpY(ma10_1, ma10_2, maX_1, maX_2);
            s_m10x20 = Utils.checkXCutDownY(ma10_1, ma10_2, maX_1, maX_2);
        }

        String l_m03x10 = Utils.checkXCutUpY(ma3_1, ma3_2, maX_1, maX_2);
        if (!isUptrendByMaIndex(list, 10)) {
            l_m03x10 = "";
        }
        // ----------------------------------------
        s_m03x10 = Utils.checkXCutDownY(ma3_1, ma3_2, maX_1, maX_2);
        if (isUptrendByMaIndex(list, 10)) {
            s_m03x10 = "";
        }
        String trend = l_m03x10 + "_" + l_m10x20 + "_" + s_m03x10 + "_" + s_m10x20;

        return trend;
    }

    public static boolean checkClosePriceAndMa_StartFindLong(List<BtcFutures> list) {
        int cur = 1;
        String symbol = list.get(0).getId();
        BigDecimal ma;
        BigDecimal pre_close_price = list.get(1).getPrice_close_candle();

        if (symbol.contains("_1d_")) {
            ma = calcMA(list, MA_INDEX_D1_START_LONG, cur);
        } else if (symbol.contains("_4h_")) {
            ma = calcMA(list, MA_INDEX_H4_START_LONG, cur);
        } else {
            ma = calcMA(list, 50, cur);
        }

        if (pre_close_price.compareTo(ma) > 0) {
            return true;
        }

        return false;
    }

    public static boolean isUptrendByMaIndex(List<BtcFutures> list, int maIndex) {
        int end = 3;
        if (list.get(0).getId().contains("_1w_")) {
            end = 2;
        }
        BigDecimal ma_c = calcMA(list, maIndex, 0);
        BigDecimal ma_p = calcMA(list, maIndex, end);
        if (ma_c.compareTo(ma_p) > 0) {
            return true;
        }

        return false;
    }

    public static String getTrendPrifix(String trend) {
        String check = Objects.equals(trend, Utils.TREND_LONG) ? " 💹(" + CHAR_LONG_UP + ")"
                : "  📉 (" + CHAR_SHORT_DN + ")";

        return check;
    }

    public static String getTrendPrifix(String trend, int maFast, int maSlow) {
        String check = Objects.equals(trend, Utils.TREND_LONG) ? maFast + CHAR_LONG_UP + maSlow + " 💹"
                : maFast + CHAR_SHORT_DN + maSlow + " 📉";

        return "(" + check + " )";
    }
}
