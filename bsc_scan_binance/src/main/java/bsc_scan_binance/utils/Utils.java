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
import java.nio.file.attribute.FileTime;
import java.sql.Timestamp;
import java.text.DateFormat;
import java.text.SimpleDateFormat;
import java.time.DayOfWeek;
import java.time.Duration;
import java.time.Instant;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.LocalTime;
import java.time.ZoneId;
import java.time.format.DateTimeFormatter;
import java.time.temporal.ChronoField;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.Calendar;
import java.util.Collections;
import java.util.Date;
import java.util.Formatter;
import java.util.Hashtable;
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
import bsc_scan_binance.entity.Orders;
import bsc_scan_binance.response.BtcFuturesResponse;
import bsc_scan_binance.response.CandidateTokenCssResponse;
import bsc_scan_binance.response.DepthResponse;
import bsc_scan_binance.response.FundingResponse;
import bsc_scan_binance.response.MoneyAtRiskResponse;

//@Slf4j
public class Utils {
    public static final BigDecimal ACCOUNT = BigDecimal.valueOf(20000);
    public static final BigDecimal RISK_PERCENT = BigDecimal.valueOf(0.0025);

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

    public static final String TREND_LONG = "BUY";
    public static final String TREND_SHOT = "SELL";

    public static final String TEXT_EQUAL_TO_D1 = "Ed1";
    public static final String TEXT_EQUAL_TO_H4 = "Eh4";
    public static final String TEXT_5STAR = "(*5S*)";
    public static final String TEXT_DANGER = "(Danger)";
    public static final String TEXT_START_LONG = "Start:Long";
    public static final String TEXT_STOP_LONG = "Stop:Long";
    public static final String TEXT_MIN_DAY_AREA = "(Min_Day)";
    public static final String TEXT_MAX_DAY_AREA = "(Max_Day)";

    public static final String TEXT_SL_DAILY_CHART = "SL: Daily chart.";

    public static final String TEXT_SWITCH_TREND_BELOW_Ma_LONG = "(B_50)";
    public static final String TEXT_SWITCH_TREND_ABOVE_Ma_SHOT = "(S_50)";
    public static final String TEXT_SWITCH_TREND_Ma_3_5 = "(Ma.1.3)";

    public static final String TEXT_SWITCH_TREND_Ma_1_10 = "(Ma1_10)";
    public static final String TEXT_SWITCH_TREND_Ma_1_20 = "(Ma1_20)";
    public static final String TEXT_SWITCH_TREND_Ma_1_30 = "(Ma1_30)";
    public static final String TEXT_SWITCH_TREND_Ma_1_50 = "(Ma1_50)";

    public static final String TEXT_TREND_HEKEN_ = "Heken_";
    public static final String TEXT_TREND_HEKEN_LONG = TEXT_TREND_HEKEN_ + TREND_LONG;
    public static final String TEXT_TREND_HEKEN_SHORT = TEXT_TREND_HEKEN_ + TREND_SHOT;

    public static final String TEXT_CONNECTION_TIMED_OUT = "CONNECTION_TIMED_OUT";
    public static final String CONNECTION_TIMED_OUT_ID = "CONNECTION_TIMED_OUT_MINUTE_15";
    public static final String THE_TREND_NOT_REVERSED_YET = "The trend not reversed yet.";

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
    public static final String CAPITAL_TIME_MINUTE_5 = "MINUTE_5";
    public static final String CAPITAL_TIME_MINUTE_15 = "MINUTE_15";
    public static final String CAPITAL_TIME_HOUR = "HOUR";
    public static final String CAPITAL_TIME_HOUR_4 = "HOUR_4";
    public static final String CAPITAL_TIME_DAY = "DAY";
    public static final String CAPITAL_TIME_WEEK = "WEEK";

    public static final String CRYPTO_TIME_5m = "5m";
    public static final String CRYPTO_TIME_15m = "15m";
    public static final String CRYPTO_TIME_1H = "1h";
    public static final String CRYPTO_TIME_4H = "4h";
    public static final String CRYPTO_TIME_1D = "1d";
    public static final String CRYPTO_TIME_1w = "1w";

    public static final Integer MINUTES_OF_D = 240;// 600;
    public static final Integer MINUTES_OF_4H = 120;
    public static final Integer MINUTES_OF_1H = 60;
    public static final Integer MINUTES_OF_15M = 15;
    public static final Integer MINUTES_OF_5M = 5;

    public static final Integer MINUTES_RELOAD_CSV_DATA = 3;

    public static final List<String> currencies = Arrays.asList("USD", "AUD", "CAD", "CHF", "EUR", "GBP", "JPY", "NZD",
            "PLN", "SEK");

    // CapitalCom: US100, US500, J225, DE40, FR40, AU200, "GOLD", "SILVER",
    // FTMO______: NAS100, SP500, JPY225, GER30, FRA40, AUS200, "XAUUSD", "XAGUSD"
    // Main: "EURUSD", "USDJPY", "GBPUSD", "USDCHF", "AUDUSD", "USDCAD", "NZDUSD"

    public static final String EPICS_INDEXS = "_US30_SP500_GER30_GER40_UK100_";

    // "SP35", "HK50", "OIL_CRUDE", "NAS100", "AUS200", "JPY225",
    public static final List<String> EPICS_ONE_WAY = Arrays.asList("XAUUSD", "XAGUSD", "BTCUSD", "US30", "US100",
            "GER40", "UK100", "USOIL");

    public static final List<String> EPICS_FOREXS = Arrays.asList("EURAUD", "EURCAD", "EURCHF", "EURGBP", "EURJPY",
            "EURNZD", "EURUSD", "GBPAUD", "GBPCAD", "GBPCHF", "GBPJPY", "GBPNZD", "GBPUSD", "NZDCAD", "NZDCHF",
            "NZDUSD", "USDCAD", "USDCHF", "USDJPY", "CHFJPY", "CADJPY", "NZDJPY", "AUDJPY", "AUDUSD");

    // ALL Binance.com
    public static final List<String> COINS = Arrays.asList("1INCH", "AAVE", "ACA", "ACH", "ARB", "ADA", "ADX", "AERGO",
            "AGIX", "AGLD", "AKRO", "ALCX", "ALGO", "ALICE", "ALPACA", "ALPHA", "ALPINE", "AMB", "AMP", "ANKR", "ANT",
            "APE", "API3", "APT", "AR", "ARDR", "ARK", "ARPA", "ASR", "ASTR", "ATA", "ATM", "ATOM", "AUCTION", "AUDIO",
            "AUTO", "AVA", "AVAX", "AXS", "BADGER", "BAKE", "BAL", "BAND", "BAR", "BAT", "BCH", "BEL", "BETA", "BETH",
            "BICO", "BIFI", "BLZ", "BNB", "BNT", "BNX", "BOND", "BSW", "BTC", "BTS", "BURGER", "C98", "CAKE", "CELO",
            "CELR", "CFX", "CHESS", "CHR", "CHZ", "CITY", "CKB", "CLV", "COCOS", "COMP", "COS", "COTI", "CREAM", "CRV",
            "CTK", "CTSI", "CTXC", "CVP", "CVX", "DAR", "DASH", "DATA", "DCR", "DGB", "DIA", "DOCK", "DODO", "DOGE",
            "DOT", "DREP", "DUSK", "DYDX", "EGLD", "ELF", "ENJ", "ENS", "EOS", "EPX", "ERN", "ETC", "ETH", "FARM",
            "FET", "FIDA", "FIL", "FIO", "FIRO", "FIS", "FLM", "FLOW", "FLUX", "FOR", "FORTH", "FRONT", "FTM", "FTT",
            "FUN", "FXS", "GAL", "GALA", "GAS", "GFT", "GHST", "GLM", "GLMR", "GMT", "GMX", "GNS", "GRT", "GTC", "HARD",
            "HBAR", "HFT", "HIFI", "HIGH", "HIVE", "HOOK", "HOT", "ID", "ICX", "IDEX", "ILV", "IMX", "INJ", "IOST",
            "IOTA", "IOTX", "IRIS", "JASMY", "JOE", "JST", "JUV", "KAVA", "KDA", "KEY", "KLAY", "KMD", "KNC", "KP3R",
            "KSM", "LAZIO", "LEVER", "LINA", "LINK", "LIT", "LOKA", "LOOM", "LPT", "LQTY", "LRC", "LSK", "LTC", "LTO",
            "LUNA", "LUNC", "MAGIC", "MANA", "MASK", "MATIC", "MBOX", "MC", "MDT", "MDX", "MINA", "MKR", "MLN", "MOB",
            "MOVR", "MTL", "MULTI", "NEAR", "NEBL", "NEO", "NEXO", "NKN", "NMR", "NULS", "OCEAN", "OG", "OGN", "OMG",
            "ONE", "ONG", "ONT", "OOKI", "OP", "ORN", "OSMO", "OXT", "PEOPLE", "PERL", "PERP", "PHA", "PHB", "PLA",
            "PNT", "POLS", "POLYX", "POND", "PORTO", "POWR", "PROM", "PROS", "PSG", "PUNDIX", "PYR", "QI", "QKC", "QNT",
            "QTUM", "QUICK", "RDNT", "RARE", "RAY", "REEF", "REI", "REN", "REQ", "RIF", "RLC", "RNDR", "ROSE", "RPL",
            "RSR", "RUNE", "RVN", "SAND", "SANTOS", "SC", "SCRT", "SFP", "SHIB", "SKL", "SLP", "SNM", "SNT", "SNX",
            "SOL", "SPELL", "SRM", "SSV", "STEEM", "STG", "STMX", "STORJ", "STPT", "STRAX", "STX", "SUN", "SUPER",
            "SUSHI", "SXP", "SYN", "SYS", "THETA", "TKO", "TLM", "TOMO", "TORN", "TRB", "TROY", "TRU", "TRX", "TVK",
            "TWT", "UFT", "UNFI", "UNI", "UTK", "VGX", "VIB", "VIDT", "VITE", "VOXEL", "VTHO", "WAN", "WAVES", "WAXP",
            "WIN", "WING", "WNXM", "WOO", "WRX", "WTC", "XEC", "XLM", "XMR", "XNO", "XRP", "XTZ", "XVG", "XVS", "YFI",
            "YFII", "YGG", "ZEC", "ZEN", "ZIL", "ZRX");

    public static final List<String> BINANCE_PRICE_BUSD_LIST = Arrays.asList("ART", "BNT", "PHT", "DGT", "DODO",
            "AERGO", "ARK", "BIDR", "CREAM", "GAS", "GFT", "GLM", "IDRT", "IQ", "KEY", "LOOM", "NEM", "PIVX", "PROM",
            "TORN", "QKC", "QLC", "SNM", "SNT", "UFT", "WABI", "IQ");

    public static final List<String> COINS_NEW_LISTING = Arrays.asList("RDNT", "AMB", "ARB", "ID", "LQTY", "SYN", "GNS",
            "RPL", "MAGIC", "HOOK", "HFT");

    // COINS_FUTURES
    public static final List<String> COINS_FUTURES = Arrays.asList("1INCH", "AAVE", "ACH", "ADA", "AGIX", "ALGO",
            "ALICE", "ALPHA", "AMB", "ANKR", "ANT", "APE", "API3", "APT", "AR", "ARB", "ARPA", "ASTR", "ATA", "ATOM",
            "AUDIO", "AVAX", "AXS", "BAKE", "BAL", "BAND", "BAT", "BCH", "BEL", "BLZ", "BNB", "BNT", "BNX", "BTC",
            "BTC", "C98", "CELO", "CELR", "CFX", "CHR", "CHZ", "CKB", "COCOS", "COMP", "COTI", "CRV", "CTK", "CTSI",
            "CVX", "DAR", "DASH", "DENT", "DGB", "DODO", "DOGE", "DOT", "DUSK", "DYDX", "EGLD", "ENJ", "ENS", "EOS",
            "ETC", "ETH", "FET", "FIL", "FLM", "FLOW", "FTM", "FXS", "GAL", "GALA", "GMT", "GMX", "GRT", "GTC", "HBAR",
            "HIGH", "HOOK", "HOT", "HFT", "ICP", "ICX", "ID", "IMX", "INJ", "IOST", "IOTA", "IOTX", "JASMY", "JOE",
            "KAVA", "KLAY", "KNC", "KSM", "LDO", "LEVER", "LINA", "LINK", "LIT", "LPT", "LQTY", "LRC", "LTC", "MAGIC",
            "MANA", "MASK", "MATIC", "MINA", "MKR", "MTL", "NEAR", "NEBL", "NEO", "NKN", "OCEAN", "OGN", "ONE", "ONT",
            "OP", "PEOPLE", "PERP", "PHB", "QNT", "QTUM", "RDNT", "REEF", "REN", "RLC", "RNDR", "ROSE", "RSR", "RUNE",
            "RVN", "SAND", "SFP", "SKL", "SNX", "SOL", "SPELL", "SSV", "STG", "STMX", "STORJ", "STX", "SUSHI", "SXP",
            "THETA", "TLM", "TOMO", "TRB", "TRU", "TRX", "UNFI", "UNI", "VET", "WAVES", "XEM", "XLM", "XMR", "XRP",
            "XTZ", "YFI", "ZEC", "ZEN", "ZIL", "ZRX", "WOO");

    public static String sql_CryptoHistoryResponse = " "
            + "   SELECT DISTINCT ON (tmp.symbol_or_epic)                                                 \n"
            + "     tmp.geckoid_or_epic,                                                                  \n"
            + "     tmp.symbol_or_epic,                                                                   \n"
            + "     tmp.trend_d      as d,                                                                \n"
            + "     tmp.trend_h      as h,                                                                \n"
            + "     COALESCE(tmp.trend_15m,'') as m15,                                                    \n"
            + "     COALESCE(tmp.trend_5m, '') as m5,                                                     \n"
            + "     (select append.note from funding_history append where append.event_time = concat('1W1D_FX_', append.gecko_id) and append.gecko_id = tmp.geckoid_or_epic) as note         \n"
            + "  FROM                                                                                     \n"
            + " (                                                                                         \n"
            + "     SELECT                                                                                \n"
            + "        str_h.gecko_id  as geckoid_or_epic,                                                \n"
            + "        str_h.symbol    as symbol_or_epic,                                                 \n"
            + "        (select str_d.note from funding_history str_d where event_time = 'DH4H1_D_TREND_CRYPTO' and str_d.gecko_id = str_h.gecko_id) as trend_d,  \n"
            + "        (select str_d.note from funding_history str_d where event_time = 'DH4H1_STR_15M_CRYPTO' and str_d.gecko_id = str_h.gecko_id limit 1) as trend_15m, \n"
            + "        (select str_d.note from funding_history str_d where event_time = 'DH4H1_STR_05M_CRYPTO' and str_d.gecko_id = str_h.gecko_id limit 1) as trend_5m, \n"
            + "        str_h.note   as trend_h                                                            \n"
            + "     FROM funding_history str_h                                                            \n"
            + "     WHERE str_h.event_time = 'DH4H1_STR_H4_CRYPTO'                                        \n"
            + "  ) tmp                                                                                    \n"
            + "  WHERE (tmp.trend_d = 'Long') and (tmp.trend_d = tmp.trend_h)  and (tmp.trend_d = tmp.trend_15m)   \n"
            + "  ORDER BY tmp.symbol_or_epic                                                              \n";

    public static String sql_ForexHistoryResponse = " "
            + " SELECT DISTINCT ON (tmp.symbol_or_epic)                                                 \n"
            + "    tmp.geckoid_or_epic,                                                                 \n"
            + "    tmp.symbol_or_epic,                                                                  \n"
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
        String currency = "USDT";
        if (BINANCE_PRICE_BUSD_LIST.contains(symbol)) {
            currency = "BUSD";
        }

        return loadData(symbol, TIME, LIMIT_DATA, currency);
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

                day.setUptrend(false);
                if (price_open_candle.compareTo(price_close_candle) < 0) {
                    day.setUptrend(true);
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
        try {

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

        } catch (Exception e) {
            String result = "initCapital: " + e.getMessage();
            Utils.logWritelnWithTime(result, false);

            throw e;
        }
    }

    // https://open-api.capital.com/#section/Authentication/How-to-start-new-session
    // https://open-api.capital.com/#tag/Markets-Info-greater-Prices
    // https://api-capital.backend-capital.com/api/v1/markets/{epic}

    // ------------------------------------------------------------------------
    // int lengh = 5;
    // if (Objects.equals(Utils.CAPITAL_TIME_DAY, CAPITAL_TIME_XXX)) {
    // lengh = 10;
    // }
    // if (Objects.equals(Utils.CAPITAL_TIME_HOUR_4, CAPITAL_TIME_XXX)) {
    // lengh = 10;
    // }
    // if (Objects.equals(Utils.CAPITAL_TIME_HOUR, CAPITAL_TIME_XXX)) {
    // lengh = 10;
    // }
    //// ----------------------------TREND------------------------
    // list = Utils.loadCapitalData(EPIC, CAPITAL_TIME_XXX, lengh);
    // if (CollectionUtils.isEmpty(list)) {
    // BscScanBinanceApplication.wait(BscScanBinanceApplication.SLEEP_MINISECONDS *
    // 5);
    //
    // Utils.initCapital();
    // list = Utils.loadCapitalData(EPIC, CAPITAL_TIME_XXX, lengh);
    //
    // if (CollectionUtils.isEmpty(list)) {
    // String result = "initForexTrend(" + EPIC + ") Size:" + list.size();
    // Utils.logWritelnDraft(result);
    //
    // Orders entity_time_out = new Orders(Utils.CONNECTION_TIMED_OUT_ID,
    // Utils.TEXT_CONNECTION_TIMED_OUT);
    // ordersRepository.save(entity_time_out);
    //
    // return new ArrayList<BtcFutures>();
    // }
    // }

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
                    dto.setUptrend(false);
                    if (open_price.compareTo(close_price) < 0) {
                        dto.setUptrend(true);
                    }

                    results.add(dto);

                    // System.out.println(strid + ": " + snapshotTime);

                    id += 1;
                }
            }

        } catch (Exception e) {
            System.out.println(e.getMessage());
            if (e.getMessage().contains("Connection timed out")) {
                Utils.logWritelnWithTime(epic + ": " + e.getMessage(), false);
                initCapital();
            } else {
                String result = "loadCapitalData: " + e.getMessage();
                Utils.logWritelnWithTime(result, false);

                throw e;
            }
        }

        return results;
    }

    public static String getChartNameCapital_(String TIME) {

        if (Objects.equals(TIME, CAPITAL_TIME_MINUTE_5)) {
            return "_5m_";
        }
        if (Objects.equals(TIME, CAPITAL_TIME_MINUTE_15)) {
            return "_15m_";
        }
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
        if (Objects.equals(TIME, CAPITAL_TIME_MINUTE_5)) {
            return "(03) ";
        }
        if (Objects.equals(TIME, CAPITAL_TIME_MINUTE_15)) {
            return "(15) ";
        }
        if (Objects.equals(TIME, CAPITAL_TIME_HOUR)) {
            return "(H1) ";
        }
        if (Objects.equals(TIME, CAPITAL_TIME_HOUR_4)) {
            return "(H4) ";
        }
        if (Objects.equals(TIME, CAPITAL_TIME_DAY)) {
            return "(D1) ";
        }
        if (Objects.equals(TIME, CAPITAL_TIME_WEEK)) {
            return "(W1) ";
        }

        return TIME;
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

    public static String appendSpace(String value, int length, String charactor) {
        String result = value;
        int len = value.length();
        if (len < length) {
            for (int i = len; i < length; i++) {
                result += charactor;
            }
        }
        return result;
    }

    public static String appendLeftAndRight(String value, int length, String charactor) {
        String result = value;
        for (int i = 0; i < length; i++) {
            result = charactor + result;
        }
        for (int i = 0; i < length; i++) {
            result += charactor;
        }

        return result;
    }

    public static String appendLeft(String value, int length, String charactor) {
        int len = value.length();
        if (len < length) {
            String result = value;
            len = result.length();

            for (int i = len; i < length; i++) {
                result = charactor + result;
            }

            return result;
        }

        return value;
    }

    public static String appendLeft(String value, int length) {
        String result = value;
        int len = value.length();
        if (len < length) {
            for (int i = len; i < length; i++) {
                result = " " + result;
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

    public static boolean isAllowSendMsg() {
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

    // https://www.calculator.net/time-duration-calculator.html
    public static boolean isTimeToHuntM15() {
        LocalTime time_tokyo = LocalTime.parse("07:00:00"); // to: 14:30
        LocalTime time_london = LocalTime.parse("15:00:00"); // to: 19:30
        LocalTime time_newyork = LocalTime.parse("20:00:00"); // to: 22:30

        LocalTime cur_time = LocalTime.now();

        long elapsedMinutes_tk = Duration.between(time_tokyo, cur_time).toMinutes();
        if ((0 <= elapsedMinutes_tk) && (elapsedMinutes_tk <= 450)) {
            return true;
        }

        long elapsedMinutes_ld = Duration.between(time_london, cur_time).toMinutes();
        if ((0 <= elapsedMinutes_ld) && (elapsedMinutes_ld <= 270)) {
            return true;
        }

        long elapsedMinutes_ny = Duration.between(time_newyork, cur_time).toMinutes();
        if ((0 <= elapsedMinutes_ny) && (elapsedMinutes_ny <= 150)) {
            return true;
        }

        return false;
    }

    public static String getCryptoLink_Spot(String symbol) {
        String currency = "USDT";
        if (BINANCE_PRICE_BUSD_LIST.contains(symbol)) {
            currency = "BUSD";
        }

        return " https://vn.tradingview.com/chart/?symbol=BINANCE%3A" + symbol + currency + " ";
    }

    public static String getCryptoLink_Future(String symbol) {
        return " https://vn.tradingview.com/chart/?symbol=BINANCE%3A" + symbol + "USDTPERP" + " ";
    }

    public static String getCapitalLink(String epic) {
        // FTMO______: NAS100, SP500, JPY225, GER30, FRA40, AUS200, "XAUUSD", "XAGUSD"
        // CapitalCom: US100, US500, J225, DE40, FR40, AU200, "GOLD", "SILVER",

        Hashtable<String, String> forex_naming_dict = new Hashtable<String, String>();
        forex_naming_dict.put("NAS100", "US100");
        forex_naming_dict.put("SP500", "US500");
        forex_naming_dict.put("JPY225", "J225");
        forex_naming_dict.put("JPN225", "J225");
        forex_naming_dict.put("GER30", "DE40");
        forex_naming_dict.put("GER40", "DE40");
        forex_naming_dict.put("DAX40", "DE40");
        forex_naming_dict.put("FRA40", "FR40");
        forex_naming_dict.put("AUS200", "AU200");
        forex_naming_dict.put("XAUUSD", "GOLD");
        forex_naming_dict.put("XAGUSD", "SILVER");
        forex_naming_dict.put("USOIL", "OIL_CRUDE");

        if (forex_naming_dict.containsKey(epic)) {
            String epic2 = forex_naming_dict.get(epic);
            return "https://vn.tradingview.com/chart/?symbol=CAPITALCOM%3A" + epic2 + " ";
        } else {
            return "https://vn.tradingview.com/chart/?symbol=CAPITALCOM%3A" + epic + " ";
        }
    }

    public static String getDraftLogFile() {
        String PATH = "crypto_forex_result/";
        String fileName = "_draft.log";

        File directory = new File(PATH);
        if (!directory.exists()) {
            directory.mkdir();
        }
        return PATH + fileName;
    }

    public static String getForexLogFile() {
        String PATH = "crypto_forex_result/";
        String fileName = "Report.log"; // getToday_YyyyMMdd() +

        File directory = new File(PATH);
        if (!directory.exists()) {
            directory.mkdir();
        }
        return PATH + fileName;
    }

    public static String getCryptoLogFile() {
        return getDraftLogFile();

        // String PATH = "crypto_forex_result/";
        // String fileName = getToday_YyyyMMdd() + "_Crypto.log";
        //
        // File directory = new File(PATH);
        // if (!directory.exists()) {
        // directory.mkdir();
        // }
        // return PATH + fileName;
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

    public static void logWritelnDraft(String text) {
        try {
            String logFilePath = getDraftLogFile();
            String msg = text.trim();
            if (Utils.isNotBlank(msg)) {
                msg = BscScanBinanceApplication.hostname + Utils.getMmDD_TimeHHmm() + " "
                        + text.replace(Utils.new_line_from_service, " ");
            }

            FileWriter fw = new FileWriter(logFilePath, true);
            fw.write(msg + "\n");
            fw.close();
        } catch (IOException ioe) {
            System.err.println("IOException: " + ioe.getMessage());
        }
    }

    public static void logWritelnReport(String text) {
        try {
            String logFilePath = getForexLogFile();
            String msg = text.trim();
            if (Utils.isNotBlank(msg)) {
                msg = BscScanBinanceApplication.hostname + Utils.getTimeHHmm() + " "
                        + text.replace(Utils.new_line_from_service, " ");
            }

            FileWriter fw = new FileWriter(logFilePath, true);
            fw.write(msg + "\n");
            fw.close();
        } catch (IOException ioe) {
            System.err.println("IOException: " + ioe.getMessage());
        }
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
            fw.write(BscScanBinanceApplication.hostname + Utils.getTimeHHmm() + " "
                    + text.replace(Utils.new_line_from_service, " ") + "\n");
            fw.close();
        } catch (IOException ioe) {
            System.err.println("IOException: " + ioe.getMessage());
        }
    }

    public static void logForexWriteln(String text, boolean isNewline) {
        try {
            FileWriter fw = new FileWriter(getForexLogFile(), true);
            fw.write(BscScanBinanceApplication.hostname + text.replace(Utils.new_line_from_service, " ")
                    + (isNewline ? "\n" : ""));
            fw.close();
        } catch (IOException ioe) {
            System.err.println("IOException: " + ioe.getMessage());
        }
    }

    public static void logWriteln(String text, boolean isNewline) {
        try {
            FileWriter fw = new FileWriter(getCryptoLogFile(), true);
            fw.write(BscScanBinanceApplication.hostname + text.replace(Utils.new_line_from_service, " ")
                    + (isNewline ? "\n" : ""));
            fw.close();
        } catch (IOException ioe) {
            System.err.println("IOException: " + ioe.getMessage());
        }
    }

    public static void writelnLogFooter_Forex() {
        try {
            FileWriter fw = new FileWriter(getForexLogFile(), true);
            fw.write(BscScanBinanceApplication.hostname + Utils.appendSpace("-", 151, "-") + "\n");
            fw.close();
        } catch (IOException ioe) {
            System.err.println("IOException: " + ioe.getMessage());
        }
    }

    public static void writelnLogFooter() {
        try {
            FileWriter fw = new FileWriter(getCryptoLogFile(), true);
            fw.write(BscScanBinanceApplication.hostname + Utils.appendSpace("", 151, "-") + "\n");
            fw.close();
        } catch (IOException ioe) {
            System.err.println("IOException: " + ioe.getMessage());
        }
    }

    public static void sendToMyTelegram(String text) {
        String msg = text.replaceAll("↑", "^").replaceAll("↓", "v").replaceAll(" ", "");
        System.out.println();
        System.out.println(msg + " 💰 ");
        if (isAllowSendMsg()) {
            sendToChatId(Utils.chatId_duydk, msg + " 💰 ");
        }
    }

    public static void sendToTelegram(String text) {
        String msg = text.replaceAll("↑", "^").replaceAll("↓", "v").replaceAll(" ", "");
        System.out.println(msg);

        if (isAllowSendMsg()) {
            if (!isBusinessTime_6h_to_22h()) {
                // return;
            }

            sendToChatId(Utils.chatId_duydk, msg);
            sendToChatId(Utils.chatId_linkdk, msg);
        }
    }

    public static boolean isWeekday() {
        LocalDate today = LocalDate.now();
        DayOfWeek day = DayOfWeek.of(today.get(ChronoField.DAY_OF_WEEK));
        boolean value = day == DayOfWeek.SUNDAY || day == DayOfWeek.SATURDAY;
        value = !value;

        return value;
    }

    public static boolean isNewsTime() {
        boolean result = false;
        int hh = Utils.getIntValue(Utils.convertDateToString("HH", Calendar.getInstance().getTime()));
        if (20 == hh) {
            result = true;
        }

        result = false;

        return false;
    }

    public static boolean isWorkingTime() {
        int hh = Utils.getIntValue(Utils.convertDateToString("HH", Calendar.getInstance().getTime()));
        if ((7 <= hh && hh <= 18)) {
            return true;
        }

        return false;
    }

    public static boolean isTokyoSession() {
        List<Integer> times = Arrays.asList(6, 7, 8, 9, 10, 11, 12, 13, 14);
        Integer hh = Utils.getIntValue(Utils.convertDateToString("HH", Calendar.getInstance().getTime()));
        if (times.contains(hh)) {
            return true;
        }

        return false;
    }

    public static boolean isLondonAndNewYorkSession() {
        List<Integer> times = Arrays.asList(14, 15, 16, 17, 18, 19, 20, 21, 22, 23);
        Integer hh = Utils.getIntValue(Utils.convertDateToString("HH", Calendar.getInstance().getTime()));
        if (times.contains(hh)) {
            return true;
        }

        return false;
    }

    public static boolean isBusinessTime_6h_to_22h() {
        // Sang 6-8h, Trua: 1h-3h, Chieu 5h-6h, toi 8h-9h: la khung gio gia ro rang
        // nhat, sau khung gio nay gia moi chay.
        List<Integer> times = Arrays.asList(6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22);
        Integer hh = Utils.getIntValue(Utils.convertDateToString("HH", Calendar.getInstance().getTime()));
        if (times.contains(hh)) {
            return true;
        }

        return false;
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
        String result = Utils.convertDateToString("yyyy.MM.dd", calendar.getTime()) + "_05";

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

    public static String getCurrentYyyyMmDdHHByChart(String id) {
        String result = getCurrentYyyyMmDd_HH_Blog15m() + "_";

        if (id.contains("_4h_") || id.contains("HOUR_4")) {
            return getCurrentYyyyMmDd_Blog4h() + "_";
        }

        if (id.contains("_1h_") || id.contains("HOUR")) {
            return getCurrentYyyyMmDd_HH() + "_";
        }

        if (id.contains("_1d_") || id.contains("DAY")) {
            return getYyyyMmDdHH_ChangeDailyChart() + "_";
        }

        if (id.contains("_15_") || id.contains("MINUTE_15")) {
            return getCurrentYyyyMmDd_HH_Blog15m() + "_";
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

    public static String getCurrentYyyyMmDd_HH_Blog30m() {
        int mm = getCurrentMinute();
        mm = mm / 30;
        String result = getCurrentYyyyMmDd_HH() + "_" + String.valueOf(mm);
        return result;
    }

    public static String getCurrentYyyyMmDd_Blog2h() {
        String result = Utils.convertDateToString("yyyy.MM.dd_", Calendar.getInstance().getTime());
        int HH = Utils.getIntValue(Utils.convertDateToString("HH", Calendar.getInstance().getTime()));
        HH = HH / 2;
        result = result + HH;
        return result;
    }

    public static String getCurrentYyyyMmDd_Blog4h() {
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

    public static String formatDateTime(FileTime fileTime) {
        LocalDateTime localDateTime = fileTime.toInstant().atZone(ZoneId.systemDefault()).toLocalDateTime();

        DateTimeFormatter DATE_FORMATTER = DateTimeFormatter.ofPattern("MM/dd/yyyy HH:mm");

        return localDateTime.format(DATE_FORMATTER);
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
        String mySL = Utils.appendLeft(Utils.removeLastZero(roundDefault(entry)), 6) + "("
                + (curr_price.compareTo(entry) > 0 ? Utils.getPercentStr(curr_price, entry)
                        : Utils.getPercentStr(entry, curr_price))
                + ")";
        return mySL.replace("-", "");
    }

    public static String getPercentStr(BigDecimal value, BigDecimal entry) {

        return appendLeft(removeLastZero(getPercent(value, entry)), 5) + "%";

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

    public static boolean isAboveMALine(List<BtcFutures> list, int length) {
        if (CollectionUtils.isEmpty(list)) {
            Utils.logWritelnDraft("(isAboveMALine)list Empty");
        }
        if (list.size() < length) {
            Utils.logWritelnDraft(
                    "(isAboveMALine) " + list.get(0).getId() + " list.size()<" + length + ")" + list.size());
        }

        BigDecimal ma = calcMA(list, length, 0);
        BigDecimal price = list.get(0).getPrice_close_candle();

        if ((price.compareTo(ma) > 0)) {
            return true;
        }

        return false;
    }

    public static boolean isBelowMALine(List<BtcFutures> list, int length) {
        if (CollectionUtils.isEmpty(list)) {
            Utils.logWritelnDraft("(isBelowMALine)list Empty");
        }
        if (list.size() < length) {
            Utils.logWritelnDraft(
                    "(isBelowMALine) " + list.get(0).getId() + " list.size()<" + length + ")" + list.size());
        }

        BigDecimal ma = calcMA(list, length, 0);
        BigDecimal price = list.get(0).getPrice_close_candle();

        if ((price.compareTo(ma) < 0)) {
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

    public static String getChartNameAndEpic(String id) {
        String result = id;
        String[] arr = id.split("_");
        if (arr.length == 3) {
            List<BtcFutures> list = new ArrayList<BtcFutures>();
            BtcFutures dto = new BtcFutures();
            dto.setId(id);
            list.add(dto);
            result = getChartName(list) + appendSpace(arr[0], 10);
        }
        return result;
    }

    public static String getChartName(List<BtcFutures> list) {
        String result = "";

        try {
            if (CollectionUtils.isEmpty(list)) {
                return "";
            }

            String symbol = list.get(0).getId().toLowerCase();

            if (symbol.contains("_15m_")) {
                result = "(15) ";
            } else if (symbol.contains("_30m_")) {
                result = "(30) ";
            } else if (symbol.contains("_1h_")) {
                result = "(H1) ";
            } else if (symbol.contains("_2h_")) {
                result = "(H2) ";
            } else if (symbol.contains("_4h_")) {
                result = "(H4) ";
            } else if (symbol.contains("_1d_")) {
                result = "(D1) ";
            } else if (symbol.contains("_1w_")) {
                result = "(W1) ";
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

    public static String getChartName(Orders dto) {
        String result = "";

        try {
            if (Objects.isNull(dto)) {
                return "";
            }

            String symbol = dto.getId().toUpperCase();

            if (symbol.contains(CAPITAL_TIME_MINUTE_5)) {
                result = "(03) ";
            } else if (symbol.contains(CAPITAL_TIME_MINUTE_15)) {
                result = "(15) ";
            } else if (symbol.contains(CAPITAL_TIME_HOUR_4)) {
                result = "(H4) ";
            } else if (symbol.contains(CAPITAL_TIME_HOUR)) {
                result = "(H1) ";
            } else if (symbol.contains(CAPITAL_TIME_DAY)) {
                result = "(D1) ";
            } else if (symbol.contains(CAPITAL_TIME_WEEK)) {
                result = "(W1) ";

            } else {
                // symbol = symbol.replace("_00", "");
                // symbol = symbol.substring(symbol.indexOf("_"), symbol.length()).replace("_",
                // "");
                result = "(" + symbol + ")";
            }
        } catch (Exception e) {
            return "";
        }

        return result;
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
        List<BigDecimal> LowHeight = getLowHighCandle(list);

        return getPercent(LowHeight.get(1), LowHeight.get(0));
    }

    public static boolean isDangerRange(List<BtcFutures> list) {
        BigDecimal ma3 = calcMA(list, 3, 0);

        List<BigDecimal> low_heigh = Utils.getLowHighCandle(list);
        BigDecimal range = low_heigh.get(1).subtract(low_heigh.get(0));
        range = range.divide(BigDecimal.valueOf(4), 10, RoundingMode.CEILING);
        BigDecimal max_allow_long = low_heigh.get(1).subtract(range);
        if (ma3.compareTo(max_allow_long) > 0) {
            return true;
        }

        return false;
    }

    public static List<BigDecimal> getLowHighCandle(List<BtcFutures> list) {
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

    public static BigDecimal calcMaxCandleHigh(List<BtcFutures> list) {
        BigDecimal max_high = BigDecimal.ZERO;

        for (BtcFutures dto : list) {
            BigDecimal high = (dto.getHight_price().subtract(dto.getLow_price())).abs();
            if (max_high.compareTo(high) < 0) {
                max_high = high;
            }
        }

        return max_high;
    }

    public static BigDecimal calcMaxBread(List<BtcFutures> list) {
        BigDecimal max_bread = BigDecimal.ZERO;

        for (BtcFutures dto : list) {
            List<BtcFutures> sub_list = new ArrayList<BtcFutures>();
            sub_list.add(dto);

            List<BigDecimal> body = Utils.getOpenCloseCandle(sub_list);
            List<BigDecimal> low_high = Utils.getLowHighCandle(sub_list);

            BigDecimal beard_buy = (body.get(0).subtract(low_high.get(0))).abs();
            BigDecimal bread_sell = (low_high.get(1).subtract(body.get(1))).abs();
            BigDecimal bread = (beard_buy.compareTo(bread_sell) > 0 ? beard_buy : bread_sell);

            if (max_bread.compareTo(bread) < 0) {
                max_bread = bread;
            }
        }

        return max_bread;
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
                    max_Hig = dto.getPrice_close_candle();
                }
            } else {
                if (min_low.compareTo(dto.getPrice_close_candle()) > 0) {
                    min_low = dto.getPrice_close_candle();
                }

                if (max_Hig.compareTo(dto.getPrice_close_candle()) < 0) {
                    max_Hig = dto.getPrice_open_candle();
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

        List<BigDecimal> low_heigh = getLowHighCandle(list);

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
            List<BigDecimal> low_heigh_tp = getLowHighCandle(list_tp);
            List<BigDecimal> low_heigh_sl = getLowHighCandle(list_entry.subList(0, 15));
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
            List<BigDecimal> low_heigh_tp1 = getLowHighCandle(list_tp);
            List<BigDecimal> low_heigh_sl = getLowHighCandle(list_find_entry.subList(0, 15));

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
        List<BigDecimal> low_heigh = getLowHighCandle(list);
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
        List<BigDecimal> low_heigh = getLowHighCandle(list);
        String result = "";
        result += Utils.appendSpace(" atl:" + getPercentToEntry(entry, low_heigh.get(0), true), 20);
        result += " ath:" + getPercentToEntry(entry, low_heigh.get(1), true);
        result += getChartName(list);

        return Utils.appendSpace(result, 46);
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
        if ((maX_1.compareTo(maX_2) >= 0) && (maX_1.compareTo(maY_1) >= 0) && (maY_2.compareTo(maX_2) >= 0)) {
            return TREND_LONG;
        }

        return "";
    }

    private static String checkXCutDnY(BigDecimal maX_1, BigDecimal maX_2, BigDecimal maY_1, BigDecimal maY_2) {
        if ((maX_1.compareTo(maX_2) <= 0) && (maX_1.compareTo(maY_1) <= 0) && (maY_2.compareTo(maX_2) <= 0)) {
            return TREND_SHOT;
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
            return TREND_SHOT;
        }

        return "";
    }

    public static String stopTrendByMa50(List<BtcFutures> list) {
        if (CollectionUtils.isEmpty(list)) {
            Utils.logWritelnDraft("(stopTrendByMa50)list Empty");
            return "";
        }
        if (list.size() < 30) {
            Utils.logWritelnDraft("(stopTrendByMa50)list.size()<50)" + list.size());
        }
        BigDecimal ma3_0 = calcMA(list, 3, 0);
        BigDecimal ma3_3 = calcMA(list, 3, 3);

        BigDecimal ma6_0 = calcMA(list, 6, 0);
        BigDecimal ma6_3 = calcMA(list, 6, 3);

        BigDecimal ma8_0 = calcMA(list, 8, 0);
        BigDecimal ma8_3 = calcMA(list, 8, 3);

        BigDecimal ma5x_0 = calcMA(list, 50, 0);

        String stop_long = "";
        if (ma6_0.compareTo(ma5x_0) > 0) {
            stop_long += Utils.checkXCutDnY(ma3_0, ma3_3, ma8_0, ma8_3) + "_";
            stop_long += Utils.checkXCutDnY(ma6_0, ma6_3, ma8_0, ma8_3) + "_";
        }
        if (stop_long.contains(TREND_SHOT)) {
            return "STOP:" + TREND_LONG;
        }

        String stop_short = "";
        if (ma6_0.compareTo(ma5x_0) < 0) {
            stop_short += Utils.checkXCutUpY(ma3_0, ma3_3, ma8_0, ma8_3) + "_";
            stop_short += Utils.checkXCutUpY(ma6_0, ma6_3, ma8_0, ma8_3) + "_";
        }
        if (stop_short.contains(TREND_LONG)) {
            return "STOP:" + TREND_SHOT;
        }

        return "";
    }

    public static String switchTrendByMa5_8(List<BtcFutures> list) {
        String temp_long = "";
        String temp_shot = "";

        BigDecimal ma3_0 = calcMA(list, 3, 0);
        BigDecimal ma3_3 = calcMA(list, 3, 3);
        BigDecimal ma6_0 = calcMA(list, 6, 0);
        BigDecimal ma6_3 = calcMA(list, 6, 3);
        temp_long += Utils.checkXCutUpY(ma3_0, ma3_3, ma6_0, ma6_3) + "_";
        temp_shot += Utils.checkXCutDnY(ma3_0, ma3_3, ma6_0, ma6_3) + "_";

        BigDecimal ma5_0 = calcMA(list, 5, 0);
        BigDecimal ma5_3 = calcMA(list, 5, 3);
        BigDecimal ma8_0 = calcMA(list, 8, 0);
        BigDecimal ma8_3 = calcMA(list, 8, 3);

        temp_long += Utils.checkXCutUpY(ma5_0, ma5_3, ma8_0, ma8_3) + "_";
        temp_shot += Utils.checkXCutDnY(ma5_0, ma5_3, ma8_0, ma8_3) + "_";

        String trend = "";
        trend += "_" + temp_long + "_";
        trend += "_____";
        trend += "_" + temp_shot + "_";

        if (trend.contains(Utils.TREND_LONG) && trend.contains(Utils.TREND_SHOT)) {
            return "";
        }

        if (isBlank(trend.replace("_", ""))) {
            return "";
        }

        if (trend.contains(Utils.TREND_LONG)) {
            return Utils.TREND_LONG;
        }

        if (trend.contains(Utils.TREND_SHOT)) {
            return Utils.TREND_SHOT;
        }

        return "";
    }

    public static String switchTrendByMaXX_123(List<BtcFutures> list, int fastIndex, int slowIndex, int start,
            int end) {
        if (CollectionUtils.isEmpty(list)) {
            Utils.logWritelnDraft("(switchTrendByMaXX)list Empty");
            return "";
        }

        if (list.size() < slowIndex) {
            Utils.logWritelnDraft("(switchTrendByMaXX)list list.size() < slowIndex " + list.get(0).getId());
            return "";
        }

        if (Utils.getStringValue(list.get(0).getCurrPrice()).contains("E")) {
            return "";
        }

        String temp_long = "";
        String temp_shot = "";

        BigDecimal ma3_0 = calcMA(list, fastIndex, start);
        BigDecimal ma3_3 = calcMA(list, fastIndex, end);

        BigDecimal ma5x_0 = calcMA(list, slowIndex, start);
        BigDecimal ma5x_3 = calcMA(list, slowIndex, end);

        temp_long += Utils.checkXCutUpY(ma3_0, ma3_3, ma5x_0, ma5x_3) + "_";
        temp_shot += Utils.checkXCutDnY(ma3_0, ma3_3, ma5x_0, ma5x_3) + "_";

        String trend = "";
        trend += "_" + temp_long + "_";
        trend += "_____";
        trend += "_" + temp_shot + "_";

        if (trend.contains(Utils.TREND_LONG) && trend.contains(Utils.TREND_SHOT)) {
            return "";
        }

        if (isBlank(trend.replace("_", ""))) {
            return "";
        }

        if (trend.contains(Utils.TREND_LONG)) {
            if ((ma3_0.compareTo(ma3_3) > 0) && (ma5x_0.compareTo(ma5x_3) > 0)) {
                return Utils.TREND_LONG;
            }
        }

        if (trend.contains(Utils.TREND_SHOT)) {
            if ((ma3_0.compareTo(ma3_3) < 0) && (ma5x_0.compareTo(ma5x_3) < 0)) {
                return Utils.TREND_SHOT;
            }
        }

        return "";
    }

    public static String switchTrendByMaXX(List<BtcFutures> list, int fastIndex, int slowIndex) {
        return switchTrendByMaXX_123(list, fastIndex, slowIndex, 0, 3);
    }

    public static String switchTrendByMa13_XX(List<BtcFutures> heken_list, int slowIndexXx) {
        if (CollectionUtils.isEmpty(heken_list) || (heken_list.size() < 50)) {
            return "";
        }
        if (Utils.getStringValue(heken_list.get(0).getCurrPrice()).contains("E")) {
            return "";
        }

        String temp_long = "";
        String temp_shot = "";

        BigDecimal ma1_0 = calcMA(heken_list, 1, 0);
        BigDecimal ma1_3 = calcMA(heken_list, 1, 3);

        BigDecimal ma3_0 = calcMA(heken_list, 3, 0);
        BigDecimal ma3_3 = calcMA(heken_list, 3, 3);

        BigDecimal ma50_0 = calcMA(heken_list, slowIndexXx, 0);
        BigDecimal ma50_3 = calcMA(heken_list, slowIndexXx, 3);

        temp_long += Utils.checkXCutUpY(ma3_0, ma3_3, ma50_0, ma50_3) + "_";
        temp_shot += Utils.checkXCutDnY(ma3_0, ma3_3, ma50_0, ma50_3) + "_";

        temp_long += Utils.checkXCutUpY(ma1_0, ma1_3, ma50_0, ma50_3) + "_";
        temp_shot += Utils.checkXCutDnY(ma1_0, ma1_3, ma50_0, ma50_3) + "_";

        String trend = "";
        trend += "_" + temp_long + "_";
        trend += "_____";
        trend += "_" + temp_shot + "_";

        if (trend.contains(Utils.TREND_LONG) && trend.contains(Utils.TREND_SHOT)) {
            return "";
        }

        if (isBlank(trend.replace("_", ""))) {
            return "";
        }

        String result = "";
        if (trend.contains(Utils.TREND_LONG)) {
            result = Utils.TREND_LONG;
        }

        if (trend.contains(Utils.TREND_SHOT)) {
            result = Utils.TREND_SHOT;
        }

        return result;
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

    public static String getTrendByMaXx(List<BtcFutures> list, int maIndex) {
        return isUptrendByMa(list, maIndex, 1, 2) ? TREND_LONG : TREND_SHOT;
    }

    public static boolean isUptrendByMa(List<BtcFutures> list, int maIndex, int str, int end) {
        BigDecimal ma_c = calcMA(list, maIndex, str);
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

    public static String getEpicFromId(String id) {
        String EPIC = id;
        EPIC = EPIC.replace("_" + Utils.CAPITAL_TIME_WEEK, "");
        EPIC = EPIC.replace("_" + Utils.CAPITAL_TIME_DAY, "");
        EPIC = EPIC.replace("_" + Utils.CAPITAL_TIME_HOUR_4, "");
        EPIC = EPIC.replace("_" + Utils.CAPITAL_TIME_HOUR, "");
        EPIC = EPIC.replace("_" + Utils.CAPITAL_TIME_MINUTE_15, "");
        EPIC = EPIC.replace("_" + Utils.CAPITAL_TIME_MINUTE_5, "");
        EPIC = EPIC.replace("_", "");

        return EPIC;
    }

    public static String createLineForex_Body(Orders dto_entry, Orders dto_sl, String find_trend) {
        String log = "";
        if (Objects.nonNull(dto_entry) && Objects.nonNull(dto_sl)) {
            String EPIC = getEpicFromId(dto_entry.getId());

            String buffer = Utils.appendSpace("", 14);
            buffer += Utils.calc_BUF_LO_HI_BUF_Forex(false, find_trend, EPIC, dto_entry, dto_sl);
            log = buffer;
        }

        return log;
    }

    public static List<BtcFutures> getHekenList(List<BtcFutures> list) {
        List<BtcFutures> heken_list = new ArrayList<BtcFutures>();
        if (list.size() < 2) {
            return heken_list;
        }

        int heken_index = 0;
        for (int index = list.size() - 1; index >= 0; index--) {
            BtcFutures dto = list.get(index);

            // https://admiralmarkets.sc/vn/education/articles/forex-indicators/what-is-heiken-ashi
            BigDecimal ope = BigDecimal.ZERO; // (giá mở cửa của nến trước đó + giá đóng cửa của nến trước đó)/2
            if (index == list.size() - 1) {
                ope = list.get(list.size() - 1).getPrice_open_candle()
                        .add(list.get(list.size() - 1).getPrice_close_candle());
                ope = ope.divide(BigDecimal.valueOf(2), 10, RoundingMode.CEILING);
            } else {
                BtcFutures dto_pre = heken_list.get(heken_index - 1);
                ope = dto_pre.getPrice_open_candle().add(dto_pre.getPrice_close_candle());
                ope = ope.divide(BigDecimal.valueOf(2), 10, RoundingMode.CEILING);
            }

            BigDecimal clo = BigDecimal.ZERO; // (giá mở cửa + giá đỉnh + giá đáy + giá đóng cửa)/4
            clo = dto.getPrice_open_candle().add(dto.getPrice_close_candle()).add(dto.getHight_price())
                    .add(dto.getLow_price());
            clo = clo.divide(BigDecimal.valueOf(4), 10, RoundingMode.CEILING);

            BigDecimal hig = dto.getHight_price(); // max (giá đỉnh, giá mở, giá đóng);
            hig = (hig.compareTo(dto.getPrice_open_candle()) < 0) ? dto.getPrice_open_candle() : hig;
            hig = (hig.compareTo(dto.getPrice_close_candle()) < 0) ? dto.getPrice_close_candle() : hig;

            BigDecimal low = dto.getLow_price(); // min (giá đáy, giá mở, giá đóng)
            low = (low.compareTo(dto.getPrice_open_candle()) > 0) ? dto.getPrice_open_candle() : low;
            low = (low.compareTo(dto.getPrice_close_candle()) > 0) ? dto.getPrice_close_candle() : low;

            boolean uptrend = (ope.compareTo(clo) < 0) ? true : false;

            BtcFutures heken = new BtcFutures(dto.getId(), dto.getCurrPrice(), low, hig, ope, clo, BigDecimal.ZERO,
                    BigDecimal.ZERO, BigDecimal.ZERO, BigDecimal.ZERO, uptrend);

            heken_list.add(heken);
            heken_index += 1;
        }
        Collections.reverse(heken_list);

        return heken_list;
    }

    public static boolean isSameTrendByHekenAshi_Ma1_6(List<BtcFutures> list) {
        List<BtcFutures> heken_list = getHekenList(list);
        if (CollectionUtils.isEmpty(heken_list)) {
            return false;
        }

        BigDecimal ma1_1 = calcMA(list, 1, 0);
        BigDecimal ma1_2 = calcMA(list, 1, 1);

        BigDecimal ma2_1 = calcMA(list, 2, 0);
        BigDecimal ma2_2 = calcMA(list, 2, 1);

        BigDecimal ma3_1 = calcMA(list, 3, 0);
        BigDecimal ma3_2 = calcMA(list, 3, 1);

        BigDecimal ma4_1 = calcMA(list, 4, 0);
        BigDecimal ma4_2 = calcMA(list, 4, 1);

        BigDecimal ma5_1 = calcMA(list, 5, 0);
        BigDecimal ma5_2 = calcMA(list, 5, 1);

        BigDecimal ma6_1 = calcMA(list, 6, 0);
        BigDecimal ma6_2 = calcMA(list, 6, 1);

        if ((ma1_1.compareTo(ma1_2) >= 0) && (ma2_1.compareTo(ma2_2) >= 0) && (ma3_1.compareTo(ma3_2) >= 0)
                && (ma4_1.compareTo(ma4_2) >= 0) && (ma5_1.compareTo(ma5_2) >= 0) && (ma6_1.compareTo(ma6_2) >= 0)) {

            if ((ma1_1.compareTo(ma2_1) >= 0) && (ma2_1.compareTo(ma3_1) >= 0) && (ma3_1.compareTo(ma4_1) >= 0)
                    && (ma4_1.compareTo(ma5_1) >= 0) && (ma5_1.compareTo(ma6_1) >= 0)) {

                return true;
            }
        }

        if ((ma1_1.compareTo(ma1_2) <= 0) && (ma2_1.compareTo(ma2_2) <= 0) && (ma3_1.compareTo(ma3_2) <= 0)
                && (ma4_1.compareTo(ma4_2) <= 0) && (ma5_1.compareTo(ma5_2) <= 0) && (ma6_1.compareTo(ma6_2) <= 0)) {

            if ((ma1_1.compareTo(ma2_1) <= 0) && (ma2_1.compareTo(ma3_1) <= 0) && (ma3_1.compareTo(ma4_1) <= 0)
                    && (ma4_1.compareTo(ma5_1) <= 0) && (ma5_1.compareTo(ma6_1) <= 0)) {

                return true;
            }
        }
        return false;
    }

    public static String switchTrendByHeken01(List<BtcFutures> heken_list) {
        if (heken_list.get(0).isUptrend() && heken_list.get(1).isDown()) {
            return TREND_LONG;
        }
        if (heken_list.get(0).isDown() && heken_list.get(1).isUptrend()) {
            return TREND_SHOT;
        }

        if (heken_list.get(0).isUptrend() && heken_list.get(1).isUptrend() && heken_list.get(3).isDown()) {
            return TREND_LONG;
        }
        if (heken_list.get(0).isDown() && heken_list.get(1).isDown() && heken_list.get(3).isUptrend()) {
            return TREND_SHOT;
        }

        String id = heken_list.get(0).getId();
        if (id.contains("_15") || id.contains("MINUTE_15")) {

            if (heken_list.get(0).isUptrend() && heken_list.get(1).isUptrend() && heken_list.get(3).isUptrend()
                    && heken_list.get(4).isDown()) {
                return TREND_LONG;
            }
            if (heken_list.get(0).isDown() && heken_list.get(1).isDown() && heken_list.get(3).isDown()
                    && heken_list.get(4).isUptrend()) {
                return TREND_SHOT;
            }

        }

        return "";
    }

    public static String switchTrendByHekenAshi_135(List<BtcFutures> heken_list) {
        if (CollectionUtils.isEmpty(heken_list)) {
            return "";
        }

        String switch_trend = switchTrendByHeken01(heken_list);
        if (isNotBlank(switch_trend)) {
            return switch_trend;
        }

        BigDecimal ma1_0 = calcMA(heken_list, 1, 0);
        BigDecimal ma1_1 = calcMA(heken_list, 1, 1);
        BigDecimal ma1_2 = calcMA(heken_list, 1, 2);
        if ((ma1_0.compareTo(ma1_1) >= 0) && (ma1_2.compareTo(ma1_1) >= 0)) {
            return TREND_LONG;
        }
        if ((ma1_0.compareTo(ma1_1) <= 0) && (ma1_2.compareTo(ma1_1) >= 0)) {
            return TREND_SHOT;
        }

        return "";
    }

    public static String getTrendByHekenAshiList(List<BtcFutures> heken_list) {
        if (CollectionUtils.isEmpty(heken_list)) {
            return "";
        }

        // String trend_0 = heken_list.get(0).isUptrend() ? TREND_LONG : TREND_SHOT;
        // String trend_1 = isUptrendByMa(heken_list, 3, 0, 1) ? TREND_LONG :
        // TREND_SHOT;
        //
        // if (Objects.equals(trend_0, trend_1)) {
        // return trend_0;
        // }
        // String trend_2 = isUptrendByMa(heken_list, 6, 0, 1) ? TREND_LONG :
        // TREND_SHOT;

        BigDecimal ma6 = Utils.calcMA(heken_list, 6, 1);
        BigDecimal close_price = heken_list.get(1).getPrice_close_candle();
        String trend = (close_price.compareTo(ma6) > 0) ? Utils.TREND_LONG : Utils.TREND_SHOT;

        return trend;
    }

    public static String createLineForex_Header(Orders dto_entry, Orders dto_sl, String trend_d1) {
        if (Objects.isNull(dto_entry) || Objects.isNull(dto_sl)) {
            return "";
        }
        String EPIC = getEpicFromId(dto_entry.getId());
        String chart_h4 = getChartName(dto_entry);

        // String insert_time = Utils.getStringValue(dto_entry.getInsertTime());
        // LocalDateTime pre_time = LocalDateTime.parse(insert_time);
        // String time = pre_time.format(DateTimeFormatter.ofPattern("HH:mm"));

        String header = "";// time + " ";
        header += Utils.appendSpace(trend_d1, 8);
        header += chart_h4 + ":" + Utils.appendSpace(dto_entry.getTrend(), 8);
        header += Utils.appendSpace(EPIC, 12);
        header += Utils.appendSpace(Utils.getCapitalLink(EPIC), 68);

        return header;
    }

    public static String createLineCrypto(Orders entity, String symbol, String type) {
        int LENGTH = 280;
        String chart = entity.getId().replace("CRYPTO_" + symbol, "").replace("_", "").toUpperCase();

        String sl = "   (Entry:";
        if (Objects.equals(Utils.TREND_LONG, entity.getTrend())) {
            sl += Utils.appendLeft(Utils.removeLastZero(entity.getStr_body_price()), 10);
            sl += "   SL:" + Utils.appendLeft(Utils.removeLastZero(entity.getLow_price()), 10);
        } else {
            sl += Utils.appendLeft(Utils.removeLastZero(entity.getEnd_body_price()), 10);
            sl += "   SL:" + Utils.appendLeft(Utils.removeLastZero(entity.getHigh_price()), 10);
        }
        sl += ")  ";

        String tmp_msg = type + Utils.appendSpace(chart, 8) + Utils.appendSpace(entity.getTrend(), 8)
                + Utils.appendSpace(symbol, 10);

        tmp_msg += Utils.appendLeft(Utils.removeLastZero(entity.getCurrent_price()), 8) + sl;
        String url = Utils.appendSpace(Utils.getCryptoLink_Spot(symbol), 70);

        tmp_msg = Utils.appendSpace(Utils.appendSpace(tmp_msg, 35) + url + entity.getNote(), LENGTH - 12);

        return tmp_msg;
    }

    public static String calc_BUF_LO_HI_BUF_Forex(boolean is15m, String trend, String EPIC, Orders dto_entry,
            Orders dto_sl) {
        String result = "";
        BigDecimal risk = ACCOUNT.multiply(RISK_PERCENT);

        if (dto_entry.getId().contains("_MINUTE_")) {
            // risk = risk.divide(BigDecimal.valueOf(3), 3, RoundingMode.CEILING);
        }
        if (dto_entry.getId().contains(CAPITAL_TIME_HOUR) && !dto_entry.getId().contains(CAPITAL_TIME_HOUR_4)) {
            // risk = risk.divide(BigDecimal.valueOf(2), 3, RoundingMode.CEILING);
        }
        risk = formatPrice(risk, 0);

        BigDecimal sl_long = Utils.getBigDecimal(dto_sl.getLow_price());
        BigDecimal sl_shot = Utils.getBigDecimal(dto_sl.getHigh_price());

        BigDecimal en_long = Utils.getBigDecimal(dto_entry.getStr_body_price());
        BigDecimal en_shot = Utils.getBigDecimal(dto_entry.getEnd_body_price());

        BigDecimal tp_long = Utils.getBigDecimal(dto_entry.getEnd_body_price());
        BigDecimal tp_shot = Utils.getBigDecimal(dto_entry.getStr_body_price());

        String str_long = calc_BUF_Long_Forex(risk, EPIC, dto_entry.getCurrent_price(), en_long, sl_long, tp_long);
        String str_shot = calc_BUF_Shot_Forex(risk, EPIC, dto_entry.getCurrent_price(), en_shot, sl_shot, tp_shot);

        if (Objects.equals(trend, Utils.TREND_LONG)) {
            result += str_long;
        } else if (Objects.equals(trend, Utils.TREND_SHOT)) {
            result += str_shot;
        } else {
            result += str_long;
            result = appendSpace(result, 65) + "   ";
            result += str_shot;
            result = Utils.appendSpace(result, 135);
        }

        return Utils.getChartName(dto_entry) + ":" + result;
    }

    public static String calc_BUF_Long_Forex(BigDecimal risk, String EPIC, BigDecimal cur_price, BigDecimal en_long,
            BigDecimal sl_long, BigDecimal tp_long) {

        BigDecimal entry_calc = en_long.add(tp_long);
        entry_calc = entry_calc.divide(BigDecimal.valueOf(2), 10, RoundingMode.CEILING);

        MoneyAtRiskResponse money_now = new MoneyAtRiskResponse(EPIC, risk, cur_price, sl_long, tp_long);
        MoneyAtRiskResponse money_long = new MoneyAtRiskResponse(EPIC, risk, en_long, sl_long, tp_long);

        String temp = "";
        temp += " E:" + Utils.appendLeft(removeLastZero(formatPrice(en_long, 5)) + " ", 10);
        temp += " SL: " + Utils.appendLeft(removeLastZero(formatPrice(sl_long, 5)), 8);

        temp += Utils.appendLeft(removeLastZero(money_long.calcLot()), 8) + "(lot)";
        temp += "/" + appendLeft(removeLastZero(risk).replace(".0", ""), 4) + "$";

        BigDecimal risk_x5 = risk.multiply(BigDecimal.valueOf(5));

        MoneyAtRiskResponse money_x5 = new MoneyAtRiskResponse(EPIC, risk_x5, en_long, sl_long, tp_long);
        MoneyAtRiskResponse money_x5_now = new MoneyAtRiskResponse(EPIC, risk_x5, cur_price, sl_long, tp_long);

        temp += " ";
        temp += Utils.appendLeft(removeLastZero(money_x5.calcLot()), 8) + "(lot)";
        temp += "/" + appendLeft(removeLastZero(risk_x5).replace(".0", ""), 4) + "$";

        temp += "     Now(" + Utils.appendLeft(removeLastZero(money_now.calcLot()), 5) + "(lot)";
        temp += "/" + appendLeft(removeLastZero(risk).replace(".0", ""), 4) + "$";
        temp += Utils.appendLeft(removeLastZero(money_x5_now.calcLot()), 8) + "(lot)";
        temp += "/" + appendLeft(removeLastZero(risk_x5).replace(".0", ""), 4) + "$";
        temp += ") ";

        String result = Utils.appendSpace("(BUY )" + temp, 38);
        return result;
    }

    public static String calc_BUF_Shot_Forex(BigDecimal risk, String EPIC, BigDecimal cur_price, BigDecimal en_shot,
            BigDecimal sl_shot, BigDecimal tp_shot) {

        BigDecimal entry_calc = en_shot.add(tp_shot);
        entry_calc = entry_calc.divide(BigDecimal.valueOf(2), 10, RoundingMode.CEILING);

        MoneyAtRiskResponse money_now = new MoneyAtRiskResponse(EPIC, risk, cur_price, sl_shot, tp_shot);
        MoneyAtRiskResponse money_short = new MoneyAtRiskResponse(EPIC, risk, en_shot, sl_shot, tp_shot);

        String temp = "";
        temp += " E:" + Utils.appendLeft(removeLastZero(formatPrice(en_shot, 5)) + " ", 10);
        temp += " SL: " + Utils.appendLeft(removeLastZero(formatPrice(sl_shot, 5)), 8);
        temp += Utils.appendLeft(removeLastZero(money_short.calcLot()), 8) + "(lot)";
        temp += "/" + appendLeft(removeLastZero(risk).replace(".0", ""), 4) + "$";

        BigDecimal risk_x5 = risk.multiply(BigDecimal.valueOf(5));
        MoneyAtRiskResponse money_x5 = new MoneyAtRiskResponse(EPIC, risk_x5, en_shot, sl_shot, tp_shot);
        MoneyAtRiskResponse money_x5_now = new MoneyAtRiskResponse(EPIC, risk_x5, cur_price, sl_shot, tp_shot);

        temp += " ";
        temp += Utils.appendLeft(removeLastZero(money_x5.calcLot()), 8) + "(lot)";
        temp += "/" + appendLeft(removeLastZero(risk_x5).replace(".0", ""), 4) + "$";

        temp += "     Now(" + Utils.appendLeft(removeLastZero(money_now.calcLot()), 5) + "(lot)";
        temp += "/" + appendLeft(removeLastZero(risk).replace(".0", ""), 4) + "$";
        temp += Utils.appendLeft(removeLastZero(money_x5_now.calcLot()), 8) + "(lot)";
        temp += "/" + appendLeft(removeLastZero(risk_x5).replace(".0", ""), 4) + "$";
        temp += ") ";

        String result = Utils.appendSpace("(SELL)" + temp, 38);
        return result;
    }
}
