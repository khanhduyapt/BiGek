package bsc_scan_binance.utils;

import java.io.File;
import java.io.FileWriter;
import java.io.IOException;
import java.math.BigDecimal;
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
import bsc_scan_binance.entity.DailyRange;
import bsc_scan_binance.entity.Mt5Macd;
import bsc_scan_binance.entity.Mt5MacdKey;
import bsc_scan_binance.entity.Mt5OpenTrade;
import bsc_scan_binance.entity.Mt5OpenTradeEntity;
import bsc_scan_binance.entity.Orders;
import bsc_scan_binance.entity.TakeProfit;
import bsc_scan_binance.response.CandidateTokenCssResponse;
import bsc_scan_binance.response.DepthResponse;
import bsc_scan_binance.response.FundingResponse;
import bsc_scan_binance.response.MoneyAtRiskResponse;

//@Slf4j
public class Utils {
    private static final BigDecimal ACCOUNT = BigDecimal.valueOf(200000);

    // A $1.2 Million Funded Trader With The5ers:
    // Cố gắng có mức lợi nhuận đệm là 2% trước khi tăng rủi ro.
    // Nếu cảm thấy lo lắng về mức rủi ro 0,20% hoặc 0,25%, thì chỉnh về mức 0,10
    // đến 0,15%

    // (50$)
    // private static final BigDecimal RISK_0_02_PERCENT =
    // ACCOUNT.multiply(BigDecimal.valueOf(0.00025));

    // (100$ / 1 Tp)
    // public static final BigDecimal RISK_0_05_PERCENT =
    // ACCOUNT.multiply(BigDecimal.valueOf(0.0005));

    // Trend W != D (200$ / 1trade)
    // public static final BigDecimal RISK_0_10_PERCENT =
    // ACCOUNT.multiply(BigDecimal.valueOf(0.001));

    // Trend W == D (500$ / 1trade)
    public static final BigDecimal RISK = ACCOUNT.multiply(BigDecimal.valueOf(0.0005));

    // public static final BigDecimal RISK_PER_TRADE = RISK_0_15_PERCENT;

    //// Step2: Khi tài khoản tăng trưởng 2% (500$ / 1trade)
    // public static final BigDecimal RISK_0_25_PERCENT =
    //// ACCOUNT.multiply(BigDecimal.valueOf(0.0025));

    public static final String chatId_duydk = "5099224587";
    public static final String chatUser_duydk = "tg25251325";

    public static final String chatId_linkdk = "816816414";
    public static final String chatUser_linkdk = "LokaDon";

    public static final String new_line_from_bot = "\n";
    public static final String new_line_from_service = "%0A";

    public static final String EVENT_ID_NO_DUPLICATES = "MSG_PER_HOUR";

    public static final int const_app_flag_msg_on = 1; // 1: msg_on; 2: msg_off; 3: web only; 4: all coin
    public static final int const_app_flag_Future_msg_off = 2;
    public static final int const_app_flag_webonly = 3;
    public static final int const_app_flag_all_coin = 4;
    public static final int const_app_flag_all_and_msg = 5;

    public static final String TREND_LONG = "BUY";
    public static final String TREND_SHOT = "SELL";
    public static final String TREND_UNSURE = "UNSURE";
    public static final String TREND_NULL = "TREND_NULL";

    public static final String TEXT_EQUAL_TO_D1 = "Ed1";
    public static final String TEXT_EQUAL_TO_H4 = "Eh4";
    public static final String TEXT_5STAR = "(*5S*)";
    public static final String TEXT_DANGER = "(Danger)";
    public static final String TEXT_START_LONG = "Start:Long";
    public static final String TEXT_STOP_LONG = "Stop:Long";
    public static final String TEXT_EQ_WDH12 = "wdh12";
    public static final String TEXT_PASS = "datyc";
    public static final String TEXT_NOTICE_ONLY = " notice_only";
    public static final String TEXT_WAITING_ = " waiting: ";

    public static final String TEXT_SL_DAILY_CHART = "SL: Daily chart.";

    // public static final String TEXT_SWITCH_TREND_LONG_BELOW_Ma = "(B.H4H2)";
    // public static final String TEXT_SWITCH_TREND_SHOT_ABOVE_Ma = "(S.H4H2)";

    public static final String TEXT_MUC = " ●";
    public static final String TEXT_STOP_TRADE = " ×";
    public static final String TEXT_WAIT = "Wait";
    public static final String TEXT_LIMIT = "_limit";
    public static final String TEXT_EXPERT_ADVISORING = "EA ";
    public static final String TEXT_EXPERT_ADVISOR_SPACE = "   ";

    public static final String NOCATION_ABOVE_MA50 = "AboveMa50";
    public static final String NOCATION_BELOW_MA50 = "BelowMa50";
    public static final String NOCATION_CUTTING_MA50 = "CuttingMa50";

    public static final String TEXT_SWITCH_TREND_Ma69 = "(Ma6.9)";
    public static final String TEXT_SWITCH_TREND_Ma10 = "(Ma10)";
    public static final String TEXT_SWITCH_TREND_Ma89 = "(Ma89)";
    public static final String TEXT_SWITCH_TREND_Ma_1vs20 = "(Ma1.20)";
    public static final String TEXT_SWITCH_TREND_Ma_1vs50 = "(Ma1.50)";
    public static final String TEXT_SWITCH_TREND_Ma_10vs20 = "(Ma10.20)";

    public static final String TEXT_XUHU_FLOWING = "_xuhu";
    public static final String TEXT_MACD_FLOWING = "_madi";
    public static final String TEXT_REV_MACD_FLOWING = "_rvmd";

    public static final String TEXT_PIVOT_FR = "pv_fr";
    public static final String TEXT_PIVOT_TO = "pv_to";

    public static final String TEXT_SEQ = "SEQ";
    public static final String TEXT_SWITCH_TREND_SEQ_10_20_50 = "(" + TEXT_SEQ + ")";

    public static final String TEXT_SWITCH_TREND_50 = "(~50~)";
    public static final String TEXT_SWITCH_TREND_HEIKEN = "(Heiken)";

    public static final String TEXT_TREND_HEKEN_ = "Heken_";
    public static final String TEXT_TREND_HEKEN_LONG = TEXT_TREND_HEKEN_ + TREND_LONG;
    public static final String TEXT_TREND_HEKEN_SHORT = TEXT_TREND_HEKEN_ + TREND_SHOT;

    public static final String TEXT_CONNECTION_TIMED_OUT = "CONNECTION_TIMED_OUT";
    public static final String CONNECTION_TIMED_OUT_ID = "CONNECTION_TIMED_OUT_MINUTE_15";
    public static final String THE_TREND_NOT_REVERSED_YET = "The trend not reversed yet.";

    public static final String CHAR_MONEY = "💰";
    public static final String CHAR_LONG_UP = "Up";
    public static final String CHAR_SHORT_DN = "Dn";

    public static final String CLOSED_TRADE = "CLOSED";

    public static final int MA_FAST = 6;
    public static final int MA_INDEX_H1_START_LONG = 50;
    public static final int MA_INDEX_H4_STOP_LONG = 10;
    public static final int MA_INDEX_H4_START_LONG = 50;
    public static final int MA_INDEX_D1_STOP_LONG = 8;
    public static final int MA_INDEX_D1_START_LONG = 8;
    public static final int MA_INDEX_CURRENCY = 10;

    public static String CST = "";
    public static String X_SECURITY_TOKEN = "";

    // Binance: Fixed
    public static final String CRYPTO_TIME_05 = "5m";
    public static final String CRYPTO_TIME_15 = "15m";
    public static final String CRYPTO_TIME_H1 = "1h";
    public static final String CRYPTO_TIME_H4 = "4h";
    public static final String CRYPTO_TIME_D1 = "1d";
    public static final String CRYPTO_TIME_D3 = "3d";
    public static final String CRYPTO_TIME_W1 = "1w";
    public static final String CRYPTO_TIME_MO = "1M";

    public static final String CAPITAL_TIME_03 = "MINUTE_03";
    private static final String CAPITAL_TIME_10 = "MINUTE_10";
    private static final String CAPITAL_TIME_12 = "MINUTE_12";
    public static final String CAPITAL_TIME_15 = "MINUTE_15";

    public static final String CAPITAL_TIME_H1 = "HOUR_01";
    public static final String CAPITAL_TIME_H4 = "HOUR_04";
    public static final String CAPITAL_TIME_D1 = "DAY";
    public static final String CAPITAL_TIME_W1 = "WEEK";
    public static final String CAPITAL_TIME_MO = "MONTH";

    public static final String PREFIX_03m = "_m03";
    // public static final String PREFIX_05m = "_m05";
    public static final String PREFIX_10m = "_m10";
    public static final String PREFIX_12m = "_m12";
    public static final String PREFIX_15m = "_m15";
    public static final String PREFIX_30m = "_m30";
    public static final String PREFIX_H01 = "_h01";
    public static final String PREFIX_H02 = "_h02";
    public static final String PREFIX_H04 = "_h04";
    public static final String PREFIX_H12 = "_h12";
    public static final String PREFIX_D01 = "_d01";
    public static final String PREFIX_W01 = "_d07";
    public static final String PREFIX_MO1 = "_d30";

    public static final String ENCRYPTED_03 = "_03p";
    // public static final String ENCRYPTED_05 = "_05p";
    public static final String ENCRYPTED_10 = "_10p";
    public static final String ENCRYPTED_12 = "_12p";
    public static final String ENCRYPTED_15 = "_15p";

    public static final String ENCRYPTED_H1 = "_mgi";
    public static final String ENCRYPTED_H4 = "_bng";
    public static final String ENCRYPTED_D1 = "_mng";
    public static final String ENCRYPTED_W1 = "_mtu";

    public static final Integer MINUTES_OF_6D = 8640;
    public static final Integer MINUTES_OF_3D = 4320;
    public static final Integer MINUTES_OF_1D = 1440;
    public static final Integer MINUTES_OF_6H = 360;
    public static final Integer MINUTES_OF_4H = 240;
    public static final Integer MINUTES_OF_2H = 120;
    public static final Integer MINUTES_OF_1H = 60;
    public static final Integer MINUTES_OF_30 = 30;
    public static final Integer MINUTES_OF_15 = 15;
    public static final Integer MINUTES_OF_05 = 5;

    public static final Integer MINUTES_RELOAD_CSV_DATA = 5;

    public static final List<String> COMPANIES = Arrays.asList("FTMO");

    // , "NEXT", "ALPHA", "THE5ERS", "MFF", "TFF", "CTI", "TOPTIER", "FTP", "SPT",
    // "ENG", "BFP", "E8F", "AUDA", "FTUK"
    // public static String MT5_COMPANY_NEXT = "608AB61EFF9C7B3585EC08B8CF6800E3";
    // // FundedNext

    // 5 quỹ PAYOUT tốt nhất hiện nay : FTMO / 5er / TFT / CTI / TFF
    public static String MT5_COMPANY_FTMO_PC = "65FD2FDEC48B475B974F37EDB7D542A5"; // FTMO (PC)
    public static String MT5_COMPANY_FTMO_DE = "49CDDEAA95A409ED22BD2287BB67CB9C"; // FTMO (DESTOP)

    // public static String MT5_COMPANY_5ERS = "10CE948A1DFC9A8C27E56E827008EBD4";
    // // The5ers (FivePercentOnline)
    // public static String MT5_COMPANY_MFF = "D0E8209F77C8CF37AD8BF550E51FF075"; //
    // My Forex Funds (Traders Global Group)
    // public static String MT5_COMPANY_ALPHA = "DA9FDBAE775DAE029270F1379F6A9F03";
    // // Alpha Capital Group Trustpilot: 4.6
    // public static String MT5_COMPANY_TFF = "TFF"; // True Forex Funds Trustpilot:
    // 4.7
    // public static String MT5_COMPANY_CTI = "CTI"; // City Traders Imperium
    // Trustpilot: 4.8
    // public static String MT5_COMPANY_TOPTIER = "TOPTIER"; // TopTier Trader
    // Trustpilot: 4.8
    // public static String MT5_COMPANY_FTP = "FTP"; // Funded Trading Plus
    // Trustpilot: 4.9
    // public static String MT5_COMPANY_SPT = "SPT"; //Smart Prop Trader Trustpilot:
    // 4.7
    // public static String MT5_COMPANY_ENG = "Engineer"; // Funded Engineer
    // Trustpilot: 4.8
    // public static String MT5_COMPANY_BFP = "BFP"; // Bespoke Funding Program
    // Trustpilot: 4.8
    // public static String MT5_COMPANY_E8F = "E8F"; // E8 Funding Trustpilot: 4.7
    // public static String MT5_COMPANY_AUDA = "AUDA"; //AudaCity Capital Management
    // Trustpilot: 4.7
    // public static String MT5_COMPANY_FTUK = "FTUK"; // FTUK Trustpilot: 4.7

    // Các quỹ cấm Trader Việt Nam:
    // MyFundedFX (MFFX): https://bit.ly/3lwhlEs
    // Bespoke Funding Program (BFP): https://bit.ly/43uTV34
    // Funded Engineer: https://bit.ly/44jb67S
    // Alpha Capital Group (ACG): https://bit.ly/3YrGn6h
    // Blue Guardian: https://bit.ly/3J5YyaR

    public static final String LINKED_NAME_2_USOIL = "_USOIL_USOUSD_";
    public static final String LINKED_NAME_2_US100 = "_NDX100_US100_NAS100_";
    public static final String LINKED_NAME_2_GER40 = "_GER40_GER30_";
    public static final String LINKED_NAME_2_EU50 = "_EU50_EUSTX50_";

    public static final List<String> currencies = Arrays.asList("USD", "AUD", "CAD", "CHF", "EUR", "GBP", "JPY", "NZD",
            "PLN", "SEK");

    public static final List<String> EPICS_METALS = Arrays.asList("DX", "XAUUSD", "XAGUSD", "USOIL", "BTCUSD");

    // , "ETHUSD", "ADAUSD", "DOGEUSD", "DOTUSD", "LTCUSD", "XRPUSD"
    public static final List<String> EPICS_CRYPTO_CFD = Arrays.asList("BTCUSD");

    // "AUS200", "EU50", "FRA40", "GER40", "SPN35", "UK100",
    public static final List<String> EPICS_INDEXS_CFD = Arrays.asList("US100", "US30", "BTCUSD");

    public static final List<String> EPICS_SCAP_15M_FX = Arrays.asList("EURUSD", "USDJPY", "GBPUSD", "USDCHF", "AUDUSD",
            "USDCAD", "NZDUSD", "XAUUSD", "USOIL", "US30");

    public static final List<String> EPICS_MAIN_FX = Arrays.asList("EURUSD", "USDJPY", "GBPUSD", "USDCHF", "EURGBP",
            "EURAUD", "AUDJPY", "USDCAD", "AUDUSD", "XAUUSD", "XAGUSD", "USOIL");

    public static final List<String> EPICS_FOREXS_ALL = Arrays.asList("AUDCAD", "AUDCHF", "AUDJPY", "AUDNZD", "AUDUSD",
            "CADJPY", "CHFJPY", "EURAUD", "EURCAD", "EURCHF", "EURGBP", "EURJPY", "EURNZD", "EURUSD", "GBPAUD",
            "GBPCAD", "GBPCHF", "GBPJPY", "GBPNZD", "GBPUSD", "NZDCAD", "NZDCHF", "NZDJPY", "NZDUSD", "USDCAD",
            "USDCHF", "USDJPY", "CADCHF");

    public static final List<String> EPICS_FOREXS_AUDx = Arrays.asList("AUDCAD", "AUDCHF", "AUDJPY", "AUDNZD",
            "AUDUSD");

    public static final List<String> EPICS_FOREXS_CADx = Arrays.asList("CADCHF", "CADJPY", "CHFJPY");

    public static final List<String> EPICS_FOREXS_EURx = Arrays.asList("EURAUD", "EURCAD", "EURCHF", "EURGBP", "EURJPY",
            "EURNZD", "EURUSD");

    public static final List<String> EPICS_FOREXS_GBPx = Arrays.asList("GBPAUD", "GBPCAD", "GBPCHF", "GBPJPY", "GBPNZD",
            "GBPUSD");

    public static final List<String> EPICS_FOREXS_NZDx = Arrays.asList("NZDCAD", "NZDCHF", "NZDJPY", "NZDUSD");

    public static final List<String> EPICS_FOREXS_USDx = Arrays.asList("USDCAD", "USDCHF", "USDJPY");

    // "16:30 - 23:00"
    // "AIRF", "LVMH", "PFE", "RACE", "VOWG_p", "BABA", "T", "V", "ZM"
    public static final List<String> EPICS_STOCKS = Arrays.asList("AAPL", "AMZN", "BAC", "BAYGn", "DBKGn", "GOOG",
            "META", "MSFT", "NFLX", "NVDA", "TSLA", "WMT");

    // "AIRF", "LVMH", "BAYGn", "VOWG_p", "DBKGn"
    public static final List<String> EPICS_STOCKS_EUR = Arrays.asList();

    public static final List<String> EPICS_STOCKS_USA = Arrays.asList("AAPL", "AMZN", "BAC", "BAYGn", "DBKGn", "GOOG",
            "META", "MSFT", "NFLX", "NVDA", "TSLA", "WMT");

    // ALL Binance.com
    public static final List<String> ALL_COINS_BINANCE = Arrays.asList("1INCH", "AAVE", "ACA", "ACH", "ARB", "ADA",
            "ADX", "AERGO", "AGIX", "AGLD", "AKRO", "ALCX", "ALGO", "ALICE", "ALPACA", "ALPHA", "ALPINE", "AMB", "AMP",
            "ANKR", "ANT", "APE", "API3", "APT", "AR", "ARDR", "ARK", "ARPA", "ASR", "ASTR", "ATA", "ATM", "ATOM",
            "AUCTION", "AUDIO", "AUTO", "AVA", "AVAX", "AXS", "BADGER", "BAKE", "BAL", "BAND", "BAR", "BAT", "BCH",
            "BEL", "BETA", "BETH", "BICO", "BIFI", "BLZ", "BNB", "BNT", "BNX", "BOND", "BSW", "BTC", "BTS", "BURGER",
            "C98", "CAKE", "CELO", "CELR", "CFX", "CHESS", "CHR", "CHZ", "CITY", "CKB", "CLV", "COMP", "COS", "COTI",
            "CREAM", "CRV", "CTK", "CTSI", "CTXC", "CVP", "CVX", "DAR", "DASH", "DATA", "DCR", "DGB", "DIA", "DOCK",
            "DODO", "DOGE", "DOT", "DREP", "DUSK", "DYDX", "EDU", "ELF", "ENJ", "ENS", "EOS", "EPX", "ERN", "ETC",
            "ETH", "FARM", "FET", "FIDA", "FIL", "FIO", "FIRO", "FIS", "FLM", "FLOW", "FLUX", "FOR", "FORTH", "FRONT",
            "FTM", "FTT", "FUN", "FXS", "GAL", "GALA", "GAS", "GFT", "GHST", "GLM", "GLMR", "GMT", "GMX", "GNS", "GRT",
            "GTC", "HARD", "HBAR", "HFT", "HIFI", "HIGH", "HIVE", "HOOK", "HOT", "ID", "ICX", "IDEX", "ILV", "IMX",
            "INJ", "IOST", "IOTA", "IOTX", "IRIS", "JASMY", "JOE", "JST", "JUV", "KAVA", "KDA", "KEY", "KLAY", "KMD",
            "KNC", "KP3R", "KSM", "LAZIO", "LEVER", "LINA", "LINK", "LIT", "LOKA", "LOOM", "LPT", "LQTY", "LRC", "LSK",
            "LTC", "LTO", "LUNA", "LUNC", "MAGIC", "MANA", "MASK", "MATIC", "MBOX", "MC", "MDT", "MDX", "MINA", "MKR",
            "MLN", "MOB", "MOVR", "MTL", "MULTI", "NEAR", "NEO", "NEXO", "NKN", "NMR", "NULS", "OCEAN", "OG", "OGN",
            "OMG", "ONE", "ONG", "ONT", "OOKI", "OP", "ORN", "OSMO", "OXT", "PEOPLE", "PERL", "PERP", "PHA", "PHB",
            "PLA", "PNT", "POLS", "POLYX", "POND", "PORTO", "POWR", "PROM", "PROS", "PSG", "PUNDIX", "PYR", "QI", "QKC",
            "QNT", "QTUM", "QUICK", "RDNT", "RARE", "RAY", "REEF", "REI", "REN", "REQ", "RIF", "RLC", "RNDR", "ROSE",
            "RPL", "RSR", "RUNE", "RVN", "SAND", "SANTOS", "SC", "SCRT", "SFP", "SHIB", "SKL", "SLP", "SNM", "SNT",
            "SNX", "SOL", "SPELL", "SRM", "SSV", "STEEM", "STG", "STMX", "STORJ", "STPT", "STRAX", "STX", "SUI", "SUN",
            "SUPER", "SUSHI", "SXP", "SYN", "SYS", "THETA", "TKO", "TLM", "TOMO", "TORN", "TRB", "TROY", "TRU", "TRX",
            "TVK", "TWT", "UFT", "UNFI", "UNI", "UTK", "VGX", "VIB", "VIDT", "VITE", "VOXEL", "VTHO", "WAN", "WAVES",
            "WAXP", "WIN", "WING", "WNXM", "WOO", "WRX", "WTC", "XEC", "XLM", "XMR", "XNO", "XRP", "XTZ", "XVG", "XVS",
            "YFI", "YFII", "YGG", "ZEC", "ZEN", "ZIL", "ZRX", "FLOKI", "COMBO", "MAV", "PENDLE", "ARKM", "WLD",
            "FDUSD");

    public static final List<String> COINS_NEW_LISTING = Arrays.asList("EDU", "RDNT", "AMB", "ARB", "ID", "LQTY", "SYN",
            "GNS", "RPL", "MAGIC", "HOOK", "HFT", "SUI", "FLOKI", "COMBO", "MAV", "PENDLE", "ARKM", "WLD", "FDUSD");

    public static final List<String> LIST_WAITING = Arrays.asList("APT", "APE", "ARB", "AUDIO", "BAND", "BSW", "C98",
            "CELO", "CELR", "CHESS", "CHZ", "CTK", "CTSI", "DAR", "DODO", "DOGE", "DYDX", "EDU", "EGLD", "ENJ", "EOS",
            "FIL", "FLM", "GNS", "GRT", "HOOK", "HFT", "ID", "IMX", "KAVA", "LEVER", "LIT", "LOKA", "LQTY", "MAGIC",
            "MASK", "MOB", "NEAR", "ONE", "OP", "PEOPLE", "PERL", "PHB", "ROSE", "RDNT", "RPL", "SXP", "SYN", "SUI",
            "WOO", "XVS", "PEPE");

    public static final List<String> BINANCE_PRICE_BUSD_LIST = Arrays.asList("ART", "BNT", "PHT", "DGT", "DODO",
            "AERGO", "ARK", "BIDR", "CREAM", "GAS", "GFT", "GLM", "IDRT", "IQ", "KEY", "LOOM", "NEM", "PIVX", "PROM",
            "TORN", "QKC", "QLC", "SNM", "SNT", "UFT", "WABI", "IQ", "PEPE");

    // COINS_FUTURES
    public static final List<String> COINS_FUTURES = Arrays.asList("1INCH", "AAVE", "ACH", "ADA", "AGIX", "ALGO",
            "ALICE", "ALPHA", "AMB", "ANKR", "ANT", "APE", "API3", "APT", "AR", "ARB", "ARPA", "ASTR", "ATA", "ATOM",
            "AUDIO", "AVAX", "AXS", "BAKE", "BAL", "BAND", "BAT", "BCH", "BEL", "BLZ", "BNB", "BNT", "BNX", "BTC",
            "BTC", "C98", "CELO", "CELR", "CFX", "CHR", "CHZ", "CKB", "COMP", "COTI", "CRV", "CTK", "CTSI", "CVX",
            "DAR", "DASH", "DENT", "DGB", "DODO", "DOGE", "DOT", "DUSK", "DYDX", "EDU", "EGLD", "ENJ", "ENS", "EOS",
            "ETC", "ETH", "FET", "FIL", "FLM", "FLOW", "FTM", "FXS", "GAL", "GALA", "GMT", "GMX", "GRT", "GTC", "HBAR",
            "HIGH", "HOOK", "HOT", "HFT", "ICP", "ICX", "ID", "IMX", "INJ", "IOST", "IOTA", "IOTX", "JASMY", "JOE",
            "KAVA", "KLAY", "KNC", "KSM", "LDO", "LEVER", "LINA", "LINK", "LIT", "LPT", "LQTY", "LRC", "LTC", "MAGIC",
            "MANA", "MASK", "MATIC", "MINA", "MKR", "MTL", "NEAR", "NEO", "NKN", "OCEAN", "OGN", "ONE", "ONT", "OP",
            "PEOPLE", "PERP", "PHB", "QNT", "QTUM", "RDNT", "REEF", "REN", "RLC", "RNDR", "ROSE", "RSR", "RUNE", "RVN",
            "SAND", "SFP", "SKL", "SNX", "SOL", "SPELL", "SSV", "STG", "STMX", "STORJ", "STX", "SUI", "SUSHI", "SXP",
            "THETA", "TLM", "TOMO", "TRB", "TRU", "TRX", "UNFI", "UNI", "VET", "WAVES", "XEM", "XLM", "XMR", "XRP",
            "XTZ", "YFI", "ZEC", "ZEN", "ZIL", "ZRX", "WOO", "RPL", "PEPE");

    public static BigDecimal get_amplitude_of_15_min_wave(String EPIC) {
        switch (EPIC.toUpperCase()) {
        case "DX":
            return BigDecimal.valueOf(40);

        case "AAPL":
            return BigDecimal.valueOf(4.85);

        case "ETHUSD":
            return BigDecimal.valueOf(40);

        case "ADAUSD":
            return BigDecimal.valueOf(1.385);

        case "DOTUSD":
            return BigDecimal.valueOf(0.135);

        case "LTCUSD":
            return BigDecimal.valueOf(4.45);

        case "XRPUSD":
            return BigDecimal.valueOf(2.55);

        case "AMZN":
            return BigDecimal.valueOf(4.5);

        case "AUDCAD":
            return BigDecimal.valueOf(0.00575);

        case "AUDCHF":
            return BigDecimal.valueOf(0.00338);

        case "AUDJPY":
            return BigDecimal.valueOf(0.6);

        case "AUDNZD":
            return BigDecimal.valueOf(0.0035);

        // case "AUDUSD":
        // return BigDecimal.valueOf();
        //
        // case "AUS200":
        // return BigDecimal.valueOf();
        //
        // case "BABA":
        // return BigDecimal.valueOf();
        //
        // case "BAC":
        // return BigDecimal.valueOf();
        //
        // case "BAYGN":
        // return BigDecimal.valueOf();
        //
        // case "BTCUSD":
        // return BigDecimal.valueOf();
        //
        // case "CADCHF":
        // return BigDecimal.valueOf();
        //
        // case "DBKGN":
        // return BigDecimal.valueOf();
        //
        // case "DOGEUSD":
        // return BigDecimal.valueOf();
        //
        // case "EU50":
        // return BigDecimal.valueOf(80);
        //
        // case "EURAUD":
        // return BigDecimal.valueOf();
        //
        // case "EURCAD":
        // return BigDecimal.valueOf();
        //
        // case "EURCHF":
        // return BigDecimal.valueOf();
        //
        // case "EURGBP":
        // return BigDecimal.valueOf();
        //
        // case "EURJPY":
        // return BigDecimal.valueOf();
        //
        // case "EURNZD":
        // return BigDecimal.valueOf();
        //
        // case "EURUSD":
        // return BigDecimal.valueOf();
        //
        // case "FRA40":
        // return BigDecimal.valueOf();
        //
        // case "GBPAUD":
        // return BigDecimal.valueOf();
        //
        // case "GBPCAD":
        // return BigDecimal.valueOf();
        //
        // case "GBPCHF":
        // return BigDecimal.valueOf();
        //
        // case "GBPJPY":
        // return BigDecimal.valueOf();
        //
        // case "GBPNZD":
        // return BigDecimal.valueOf();
        //
        // case "GBPUSD":
        // return BigDecimal.valueOf();
        //
        // case "GER40":
        // return BigDecimal.valueOf();
        //
        // case "GOOG":
        // return BigDecimal.valueOf();
        //
        // case "LVMH":
        // return BigDecimal.valueOf();
        //
        // case "META":
        // return BigDecimal.valueOf();
        //
        // case "MSFT":
        // return BigDecimal.valueOf();
        //
        // case "NVDA":
        // return BigDecimal.valueOf();
        //
        // case "NFLX":
        // return BigDecimal.valueOf();
        //
        // case "NATGAS":
        // return BigDecimal.valueOf();
        //
        // case "NZDCAD":
        // return BigDecimal.valueOf();
        //
        // case "NZDCHF":
        // return BigDecimal.valueOf();
        //
        // case "CADJPY":
        // return BigDecimal.valueOf(40);
        //
        // case "CHFJPY":
        // return BigDecimal.valueOf();
        //
        // case "NZDJPY":
        // return BigDecimal.valueOf();
        //
        // case "NZDUSD":
        // return BigDecimal.valueOf();
        //
        // case "USDCAD":
        // return BigDecimal.valueOf();
        //
        // case "USDJPY":
        // return BigDecimal.valueOf();
        //
        // case "USDCHF":
        // return BigDecimal.valueOf();
        //
        // case "PFE":
        // return BigDecimal.valueOf();
        //
        // case "RACE":
        // return BigDecimal.valueOf();
        //
        // case "TSLA":
        // return BigDecimal.valueOf();
        //
        // case "SPN35":
        // return BigDecimal.valueOf();
        //
        // case "AIRF":
        // return BigDecimal.valueOf();
        //
        // case "VOWG_P":
        // return BigDecimal.valueOf();
        //
        // case "WMT":
        // return BigDecimal.valueOf();
        //
        // case "T":
        // return BigDecimal.valueOf();
        //
        // case "V":
        // return BigDecimal.valueOf();
        //
        // case "ZM":
        // return BigDecimal.valueOf();
        //
        // case "UK100":
        // return BigDecimal.valueOf();
        //
        // case "US100":
        // return BigDecimal.valueOf();
        //
        // case "US30":
        // return BigDecimal.valueOf();
        //
        // case "USOIL":
        // return BigDecimal.valueOf();
        //
        // case "XAGUSD":
        // return BigDecimal.valueOf();
        //
        // case "XAUUSD":
        // return BigDecimal.valueOf();

        default:
            return BigDecimal.ZERO;
        }
    }

    public static BigDecimal get_standard_vol_per_100usd(String EPIC) {
        switch (EPIC.toUpperCase()) {
        case "DX":
            return BigDecimal.valueOf(1);

        case "AAPL":
            return BigDecimal.valueOf(45);

        case "ETHUSD":
            return BigDecimal.valueOf(5);

        case "ADAUSD":
            return BigDecimal.valueOf(150);

        case "DOTUSD":
            return BigDecimal.valueOf(150);

        case "LTCUSD":
            return BigDecimal.valueOf(50);

        case "XRPUSD":
            return BigDecimal.valueOf(60);

        case "AMZN":
            return BigDecimal.valueOf(30);

        case "AUDCAD":
            return BigDecimal.valueOf(0.25);

        case "AUDCHF":
            return BigDecimal.valueOf(0.25);

        case "AUDJPY":
            return BigDecimal.valueOf(0.2);

        case "AUDNZD":
            return BigDecimal.valueOf(0.35);

        case "AUDUSD":
            return BigDecimal.valueOf(0.2);

        case "AUS200":
            return BigDecimal.valueOf(2.0);

        case "BABA":
            return BigDecimal.valueOf(30);

        case "BAC":
            return BigDecimal.valueOf(60);

        case "BAYGN":
            return BigDecimal.valueOf(50);

        case "BTCUSD":
            return BigDecimal.valueOf(0.1);

        case "CADCHF":
            return BigDecimal.valueOf(0.25);

        case "DBKGN":
            return BigDecimal.valueOf(150);

        case "DOGEUSD":
            return BigDecimal.valueOf(25);

        case "EU50":
            return BigDecimal.valueOf(2.0);

        case "EURAUD":
            return BigDecimal.valueOf(0.15);

        case "EURCAD":
            return BigDecimal.valueOf(0.2);

        case "EURCHF":
            return BigDecimal.valueOf(0.25);

        case "EURGBP":
            return BigDecimal.valueOf(0.25);

        case "EURJPY":
            return BigDecimal.valueOf(0.15);

        case "EURNZD":
            return BigDecimal.valueOf(0.2);

        case "EURUSD":
            return BigDecimal.valueOf(0.15);

        case "FRA40":
            return BigDecimal.valueOf(1.0);

        case "GBPAUD":
            return BigDecimal.valueOf(0.2);

        case "GBPCAD":
            return BigDecimal.valueOf(0.15);

        case "GBPCHF":
            return BigDecimal.valueOf(0.15);

        case "GBPJPY":
            return BigDecimal.valueOf(0.15);

        case "GBPNZD":
            return BigDecimal.valueOf(0.15);

        case "GBPUSD":
            return BigDecimal.valueOf(0.15);

        case "GER40":
            return BigDecimal.valueOf(1);

        case "GOOG":
            return BigDecimal.valueOf(35);

        case "LVMH":
            return BigDecimal.valueOf(8);

        case "META":
            return BigDecimal.valueOf(15);

        case "MSFT":
            return BigDecimal.valueOf(15);

        case "NVDA":
            return BigDecimal.valueOf(8);

        case "NFLX":
            return BigDecimal.valueOf(10);

        case "NATGAS":
            return BigDecimal.valueOf(1);

        case "NZDCAD":
            return BigDecimal.valueOf(0.25);

        case "NZDCHF":
            return BigDecimal.valueOf(0.25);

        case "CADJPY":
            return BigDecimal.valueOf(0.15);

        case "CHFJPY":
            return BigDecimal.valueOf(0.15);

        case "NZDJPY":
            return BigDecimal.valueOf(0.2);

        case "NZDUSD":
            return BigDecimal.valueOf(0.2);

        case "USDCAD":
            return BigDecimal.valueOf(0.25);

        case "USDJPY":
            return BigDecimal.valueOf(0.15);

        case "USDCHF":
            return BigDecimal.valueOf(0.2);

        case "PFE":
            return BigDecimal.valueOf(100);

        case "RACE":
            return BigDecimal.valueOf(20);

        case "TSLA":
            return BigDecimal.valueOf(10);

        case "SPN35":
            return BigDecimal.valueOf(1);

        case "AIRF":
            return BigDecimal.valueOf(10);

        case "VOWG_P":
            return BigDecimal.valueOf(60);

        case "WMT":
            return BigDecimal.valueOf(80);

        case "T":
            return BigDecimal.valueOf(150);

        case "V":
            return BigDecimal.valueOf(40);

        case "ZM":
            return BigDecimal.valueOf(90);

        case "UK100":
            return BigDecimal.valueOf(1);

        case "US100":
            return BigDecimal.valueOf(0.5);

        case "US30":
            return BigDecimal.valueOf(0.35);

        case "USOIL":
            return BigDecimal.valueOf(0.5);

        case "XAGUSD":
            return BigDecimal.valueOf(0.05);

        case "XAUUSD":
            return BigDecimal.valueOf(0.1);

        default:
            return BigDecimal.ZERO;
        }
    }

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
                    strid = epic + getChartPrefix(TIME) + strid;
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

    public static String getChartPrefix(String CAPITAL_TIME_XX) {
        if (Objects.equals(CAPITAL_TIME_XX, CAPITAL_TIME_03)) {
            return PREFIX_03m;
        }
        // if (Objects.equals(CAPITAL_TIME_XX, CAPITAL_TIME_05)) {
        // return PREFIX_05m;
        // }
        if (Objects.equals(CAPITAL_TIME_XX, CAPITAL_TIME_10)) {
            return PREFIX_10m;
        }
        if (Objects.equals(CAPITAL_TIME_XX, CAPITAL_TIME_12)) {
            return PREFIX_12m;
        }
        if (Objects.equals(CAPITAL_TIME_XX, CAPITAL_TIME_15)) {
            return PREFIX_15m;
        }

        if (Objects.equals(CAPITAL_TIME_XX, CAPITAL_TIME_H1)) {
            return PREFIX_H01;
        }
        if (Objects.equals(CAPITAL_TIME_XX, CAPITAL_TIME_H4)) {
            return PREFIX_H04;
        }

        if (Objects.equals(CAPITAL_TIME_XX, CAPITAL_TIME_D1)) {
            return PREFIX_D01;
        }
        if (Objects.equals(CAPITAL_TIME_XX, CAPITAL_TIME_W1)) {
            return PREFIX_W01;
        }
        if (Objects.equals(CAPITAL_TIME_XX, CAPITAL_TIME_MO)) {
            return PREFIX_MO1;
        }

        return "";
    }

    public static String getEncryptedChartNameCapital(String TIME) {
        if (Objects.equals(TIME, CAPITAL_TIME_03) || TIME.contains(CAPITAL_TIME_03)) {
            return ENCRYPTED_03;
        }
        // if (Objects.equals(TIME, CAPITAL_TIME_05) || TIME.contains(CAPITAL_TIME_05))
        // {
        // return ENCRYPTED_05;
        // }
        if (Objects.equals(TIME, CAPITAL_TIME_10) || TIME.contains(CAPITAL_TIME_10)) {
            return ENCRYPTED_10;
        }
        if (Objects.equals(TIME, CAPITAL_TIME_12) || TIME.contains(CAPITAL_TIME_12)) {
            return ENCRYPTED_12;
        }
        if (Objects.equals(TIME, CAPITAL_TIME_15) || TIME.contains(CAPITAL_TIME_15)) {
            return ENCRYPTED_15;
        }

        if (Objects.equals(TIME, CAPITAL_TIME_H1) || TIME.contains(CAPITAL_TIME_H1)) {
            return ENCRYPTED_H1;
        }
        if (Objects.equals(TIME, CAPITAL_TIME_H4) || TIME.contains(CAPITAL_TIME_H4)) {
            return ENCRYPTED_H4;
        }

        if (Objects.equals(TIME, CAPITAL_TIME_D1) || TIME.contains(CAPITAL_TIME_D1)) {
            return ENCRYPTED_D1;
        }
        if (Objects.equals(TIME, CAPITAL_TIME_W1) || TIME.contains(CAPITAL_TIME_W1)) {
            return ENCRYPTED_W1;
        }

        return "";
    }

    public static String getDeEncryptedChartNameCapital(String encryptedChartName) {
        if (encryptedChartName.contains(ENCRYPTED_03)) {
            return CAPITAL_TIME_03;
        }
        // if (encryptedChartName.contains(ENCRYPTED_05)) {
        // return CAPITAL_TIME_05;
        // }
        if (encryptedChartName.contains(ENCRYPTED_10)) {
            return CAPITAL_TIME_10;
        }
        if (encryptedChartName.contains(ENCRYPTED_12)) {
            return CAPITAL_TIME_12;
        }
        if (encryptedChartName.contains(ENCRYPTED_15)) {
            return CAPITAL_TIME_15;
        }

        if (encryptedChartName.contains(ENCRYPTED_H1)) {
            return CAPITAL_TIME_H1;
        }
        if (encryptedChartName.contains(ENCRYPTED_H4)) {
            return CAPITAL_TIME_H4;
        }
        if (encryptedChartName.contains(ENCRYPTED_D1)) {
            return CAPITAL_TIME_D1;
        }
        if (encryptedChartName.contains(ENCRYPTED_W1)) {
            return CAPITAL_TIME_W1;
        }

        return "";
    }

    public static String getChartNameCapital(String TIME) {
        if (TIME.contains(CAPITAL_TIME_03) || TIME.contains(PREFIX_03m)) {
            return "(03)";
        }
        // if (TIME.contains(CAPITAL_TIME_05) || TIME.contains(PREFIX_05m)) {
        // return "(05)";
        // }
        if (TIME.contains(CAPITAL_TIME_10) || TIME.contains(PREFIX_10m)) {
            return "(10)";
        }
        if (TIME.contains(CAPITAL_TIME_12) || TIME.contains(PREFIX_12m)) {
            return "(12)";
        }
        if (TIME.contains(CAPITAL_TIME_15) || TIME.contains(PREFIX_15m)) {
            return "(15)";
        }

        if (TIME.contains(CAPITAL_TIME_H1) || TIME.contains(PREFIX_H01)) {
            return "(H1)";
        }
        if (TIME.contains(CAPITAL_TIME_H4) || TIME.contains(PREFIX_H04)) {
            return "(H4)";
        }
        if (TIME.contains(CAPITAL_TIME_D1) || TIME.contains(PREFIX_D01)) {
            return "(D1)";
        }
        if (TIME.contains(CAPITAL_TIME_W1) || TIME.contains(PREFIX_W01)) {
            return "(W1)";
        }
        if (TIME.contains(CAPITAL_TIME_MO) || TIME.contains(PREFIX_MO1)) {
            return "(MO)";
        }

        return "(  )";
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
        if (Objects.equals(null, value) || Objects.equals("", value.trim())) {
            return false;
        }
        return true;
    }

    public static boolean isBlank(String value) {
        if (Objects.equals(null, value) || Objects.equals("", value.trim())) {
            return true;
        }
        return false;
    }

    public static String appendSpace(BigDecimal value, int length) {
        String str_value = Utils.getStringValue(value);
        if (str_value.contains(".")) {
            str_value = removeLastZero(str_value);
        }

        return appendSpace(str_value, length);
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

    public static String appendLeft(int value, int length) {
        return appendLeft(getStringValue(value), length);
    }

    public static String appendLeft(BigDecimal value, int length) {
        return appendLeft(getStringValue(value), length);
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

    public static boolean isCandidate(CandidateTokenCssResponse css) {

        if (css.getStar().toLowerCase().contains("uptrend")) {
            return true;
        }

        return false;
    }

    public static boolean isPcCongTy() {
        String cty = "PC";
        String hostname;
        try {
            hostname = InetAddress.getLocalHost().getHostName();
            if (Objects.equals(cty, hostname)) {
                return true;
            }
        } catch (UnknownHostException e) {
            e.printStackTrace();
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

    public static boolean isKillZoneTime() {
        LocalTime kill_zone_tk = LocalTime.parse("05:45:00"); // to: 06:15
        LocalTime kill_zone_ld = LocalTime.parse("14:25:00"); // to: 14:15
        LocalTime kill_zone_ny = LocalTime.parse("18:45:00"); // to: 19:15
        LocalTime cur_time = LocalTime.now();

        long elapsedMinutes_tk = Duration.between(kill_zone_tk, cur_time).toMinutes();
        if ((0 <= elapsedMinutes_tk) && (elapsedMinutes_tk <= 150)) {
            return true;
        }

        long elapsedMinutes_ld = Duration.between(kill_zone_ld, cur_time).toMinutes();
        if ((0 <= elapsedMinutes_ld) && (elapsedMinutes_ld <= 150)) {
            return true;
        }

        long elapsedMinutes_ny = Duration.between(kill_zone_ny, cur_time).toMinutes();
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

        return " https://tradingview.com/chart/?symbol=BINANCE%3A" + symbol + currency + " ";
    }

    public static String getCryptoLink_Future(String symbol) {
        return " https://tradingview.com/chart/?symbol=BINANCE%3A" + symbol + "USDTPERP" + " ";
    }

    public static String getCapitalLink(String epic) {
        String EXCHANGE = "CAPITALCOM";

        if ("_USOIL_".contains(epic)) {
            EXCHANGE = "TVC";

        } else if ("_GER40_FRA40_UK100_US30_XAUUSD_AUS200_".contains(epic)) {
            EXCHANGE = "PEPPERSTONE";

        } else if (Objects.equals("DX.f", epic) || Objects.equals("DX", epic)) {
            epic = "DXY";

        } else if (epic.contains("NATGAS")) {
            epic = "NATGAS";
            EXCHANGE = "PEPPERSTONE";

        } else if (Objects.equals("SPN35", epic)) {
            epic = "SP35";

        } else if (Objects.equals("JP225", epic)) {
            epic = "JPN225";
            EXCHANGE = "PEPPERSTONE";

        } else if (Objects.equals("BAYGN", epic.toUpperCase())) {
            epic = "BAYN";
            EXCHANGE = "XETR";

        } else if (Objects.equals("AIRF", epic)) {
            epic = "AF";
            EXCHANGE = "EURONEXT";

        } else if (Objects.equals("DBKGN", epic.toUpperCase())) {
            epic = "DB";
            EXCHANGE = "NYSE";

        } else if (Objects.equals("T", epic.toUpperCase()) || Objects.equals("V", epic.toUpperCase())) {
            EXCHANGE = "NYSE";

        } else if (Objects.equals("VOWG_P", epic.toUpperCase())) {
            epic = "VOW";
            EXCHANGE = "XETR";

        } else if (Objects.equals("LVMH", epic)) {
            epic = "LVMHF";
            EXCHANGE = "OTC";

        } else if (Utils.EPICS_FOREXS_ALL.contains(epic) || "_BTCUSD_XAGUSD_EU50_".contains(epic)) {
            EXCHANGE = "FOREXCOM";
        }

        return " https://tradingview.com/chart/?symbol=" + EXCHANGE + "%3A" + epic + " ";
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

    public static String getReportFilePath() {
        String PATH = "crypto_forex_result/";
        String fileName = "Report.log"; // getToday_YyyyMMdd() +

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

    public static String getCompanyByFoder(String path) {
        // Arrays.asList("FTMO", "8CAP", "ALPHA", "THE5ERS", "MFF");
        String result = "FTMO";
        // if (path.contains(MT5_COMPANY_FTMO)) {
        // result = COMPANIES.get(0);
        // }
        // if (path.contains(MT5_COMPANY_NEXT)) {
        // result = COMPANIES.get(1);
        // }
        // if (path.contains(MT5_COMPANY_ALPHA)) {
        // result = COMPANIES.get(2);
        // }
        // if (path.contains(MT5_COMPANY_5ERS)) {
        // result = COMPANIES.get(3);
        // }
        // if (path.contains(MT5_COMPANY_MFF)) {
        // result = COMPANIES.get(4);
        // }
        result = Utils.appendSpace(result, 10);
        return result;
    }

    public static void delete_file(String path) {
        try {
            File myScap = new File(path);
            myScap.delete();
        } catch (Exception e) {
        }
    }

    public static String getMt5DataFolder() {
        String mt5_data_file = "";
        try {
            String pcname = InetAddress.getLocalHost().getHostName().toLowerCase();
            if (Objects.equals(pcname, "pc")) {
                // PC cong ty:
                mt5_data_file = "C:\\Users\\Admin\\AppData\\Roaming\\MetaQuotes\\Terminal\\" + MT5_COMPANY_FTMO_PC
                        + "\\MQL5\\Files\\Data\\";

            } else if (Objects.equals(pcname, "desktop-l4m1ju2")) {
                // Laptop
                mt5_data_file = "C:\\Users\\DellE5270\\AppData\\Roaming\\MetaQuotes\\Terminal\\" + MT5_COMPANY_FTMO_DE
                        + "\\MQL5\\Files\\Data\\";

            }
        } catch (UnknownHostException e) {
        }

        return mt5_data_file;
    }

    public static void logWritelnDraft(String text) {
        try {
            String prifix = BscScanBinanceApplication.hostname + " "; // Utils.getMmDD_TimeHHmm() +

            String logFilePath = getDraftLogFile();
            String msg = text.trim();
            if (Utils.isNotBlank(msg)) {
                if (Objects.equals(text, "...")) {

                    msg = Utils.appendSpace("", 363, "_");

                } else if (text.length() > 10 && isBlank(text.substring(0, 10))) {

                    msg = Utils.appendLeft("", prifix.length()) + text.replace(Utils.new_line_from_service, "  ");

                } else if (text.contains(">>>")) {

                    msg = Utils.appendLeft("", prifix.length(), ">") + text.replace(Utils.new_line_from_service, "  ");

                } else if ((text + "      ").substring(0, 5).contains("---")) {

                    msg = Utils.appendLeft("", prifix.length(), "-") + text.replace(Utils.new_line_from_service, "  ");

                } else {

                    msg = prifix + text.replace(Utils.new_line_from_service, "  ");
                }
            }

            FileWriter fw = new FileWriter(logFilePath, true);
            fw.write(msg + "\n");
            fw.close();
        } catch (IOException ioe) {
            System.err.println("IOException: " + ioe.getMessage());
        }
    }

    public static void logWritelnDraftFooter() {
        try {
            FileWriter fw = new FileWriter(getDraftLogFile(), true);
            fw.write(Utils.appendSpace("", 363, "_") + "\n");
            fw.close();
        } catch (IOException ioe) {
            System.err.println("IOException: " + ioe.getMessage());
        }
    }

    public static void logWritelnReport(String text) {
        try {
            String logFilePath = getReportFilePath();
            String msg = text.trim();

            if (Objects.equals(text, "...")) {
                msg = Utils.appendSpace("", 363, "_");
            } else {
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
            String logFilePath = getReportFilePath();

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
            FileWriter fw = new FileWriter(getReportFilePath(), true);
            fw.write(BscScanBinanceApplication.hostname + text.replace(Utils.new_line_from_service, " ")
                    + (isNewline ? "\n" : ""));
            fw.close();
        } catch (IOException ioe) {
            System.err.println("IOException: " + ioe.getMessage());
        }
    }

    public static void logWriteln(String text, boolean isNewline) {
        try {
            FileWriter fw = new FileWriter(getReportFilePath(), true);
            fw.write(BscScanBinanceApplication.hostname + text.replace(Utils.new_line_from_service, " ")
                    + (isNewline ? "\n" : ""));
            fw.close();
        } catch (IOException ioe) {
            System.err.println("IOException: " + ioe.getMessage());
        }
    }

    public static void writelnLogFooter_Forex() {
        try {
            FileWriter fw = new FileWriter(getReportFilePath(), true);
            fw.write(BscScanBinanceApplication.hostname + Utils.appendSpace("-", 151, "-") + "\n");
            fw.close();
        } catch (IOException ioe) {
            System.err.println("IOException: " + ioe.getMessage());
        }
    }

    public static void sendToMyTelegram(String text) {
        try {
            String msg = text.replaceAll("↑", "^").replaceAll("↓", "v").replaceAll(" ", "");
            System.out.println();
            System.out.println(msg.replace(Utils.new_line_from_service, "    ") + ". 💰 ");
            if (isAllowSendMsg()) {
                sendToChatId(Utils.chatId_duydk, msg + ". 💰 ");
            }
        } catch (Exception e) {
        }
    }

    public static void sendToTelegram(String text) {
        try {
            String msg = text.replaceAll("↑", "^").replaceAll("↓", "v").replaceAll(" ", "");
            System.out.println(msg);

            if (isAllowSendMsg()) {
                sendToChatId(Utils.chatId_duydk, msg);
                sendToChatId(Utils.chatId_linkdk, msg);
            }
        } catch (Exception e) {
        }
    }

    public static boolean is_open_trade_time_8_to_21() {
        int hh = Utils.getIntValue(Utils.convertDateToString("HH", Calendar.getInstance().getTime()));
        if (isWeekday() && ((8 <= hh) && (hh <= 21))) {
            return true;
        }

        return false;
    }

    public static boolean is_close_jpy_trade_at_3am(String EPIC) {
        if (!EPIC.contains("JPY")) {
            return false;
        }

        List<Integer> times = Arrays.asList(3);
        int hh = Utils.getIntValue(Utils.convertDateToString("HH", Calendar.getInstance().getTime()));

        if (times.contains(hh)) {
            return true;
        }

        return false;
    }

    public static boolean isCloseTradeWeekEnd() {
        DayOfWeek day = DayOfWeek.of(LocalDate.now().get(ChronoField.DAY_OF_WEEK));

        int hh = Utils.getIntValue(Utils.convertDateToString("HH", Calendar.getInstance().getTime()));

        // đêm thứ 4 phí qua đêm sẽ được X3 để bù cho 2 ngày cuối tuần.
        if ((day == DayOfWeek.WEDNESDAY) && (hh >= 16)) {
            return true;
        }
        if ((day == DayOfWeek.THURSDAY) && (hh <= 3)) {
            return true;
        }

        if ((day == DayOfWeek.FRIDAY) && (hh >= 16)) {
            return true;
        }
        if (day == DayOfWeek.SATURDAY) {
            return true;
        }

        return false;
    }

    public static boolean isWeekend() {
        LocalDate today = LocalDate.now();
        DayOfWeek day = DayOfWeek.of(today.get(ChronoField.DAY_OF_WEEK));
        if (day == DayOfWeek.FRIDAY) {
            int hh = Utils.getIntValue(Utils.convertDateToString("HH", Calendar.getInstance().getTime()));
            if (hh >= 22) {
                return true;
            }
        }

        boolean isWeekend = (day == DayOfWeek.SUNDAY) || (day == DayOfWeek.SATURDAY);

        return isWeekend;
    }

    public static boolean isWeekday() {
        LocalDate today = LocalDate.now();
        DayOfWeek day = DayOfWeek.of(today.get(ChronoField.DAY_OF_WEEK));
        boolean isWeekend = (day == DayOfWeek.SUNDAY) || (day == DayOfWeek.SATURDAY);
        boolean isWeekday = !isWeekend;

        if (day == DayOfWeek.SATURDAY) {
            int hh = Utils.getIntValue(Utils.convertDateToString("HH", Calendar.getInstance().getTime()));
            if (hh <= 3) {
                isWeekday = true;
            }
        }

        return isWeekday;
    }

    public static boolean isNewsTime() {
        boolean result = false;
        int hh = Utils.getIntValue(Utils.convertDateToString("HH", Calendar.getInstance().getTime()));
        if (20 == hh) {
            result = true;
        }

        result = false;

        return result;
    }

    public static boolean is_working_time() {
        int hh = Utils.getIntValue(Utils.convertDateToString("HH", Calendar.getInstance().getTime()));
        if ((5 < hh) || (hh < 23)) {
            return true;
        }

        return false;
    }

    // vào lệnh từ 06h~10h: lãi thì chốt hết từ 11h trở đi.
    // vào lệnh từ 13h~15h: lãi thì chốt từ 16h trở đi.
    // vào lệnh từ 18h~20h: lãi thì chốt từ 22h trở đi.
    public static boolean is_open_trade_time() {
        List<Integer> times = Arrays.asList(6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21);
        int hh = Utils.getIntValue(Utils.convertDateToString("HH", Calendar.getInstance().getTime()));
        if (times.contains(hh)) {
            return true;
        }

        return false;
    }

    public static boolean is_close_trade_time() {
        List<Integer> times = Arrays.asList(1, 2, 3);
        int hh = Utils.getIntValue(Utils.convertDateToString("HH", Calendar.getInstance().getTime()));
        if (times.contains(hh)) {
            return true;
        }

        return false;
    }

    // JPY AUD
    public static boolean allow_open_trade_at_tokyo_session() {
        List<Integer> times = Arrays.asList(7, 8, 9, 10, 11, 12);
        Integer hh = Utils.getIntValue(Utils.convertDateToString("HH", Calendar.getInstance().getTime()));
        if (times.contains(hh)) {
            return true;
        }

        return false;
    }

    public static boolean is_london_session() {
        List<Integer> times = Arrays.asList(15, 16, 17, 18);
        Integer hh = Utils.getIntValue(Utils.convertDateToString("HH", Calendar.getInstance().getTime()));
        if (times.contains(hh)) {
            return true;
        }

        return false;
    }

    public static boolean is_newyork_session() {
        List<Integer> times = Arrays.asList(21, 22, 23, 0, 1, 2);
        Integer hh = Utils.getIntValue(Utils.convertDateToString("HH", Calendar.getInstance().getTime()));
        if (isWeekday() && times.contains(hh)) {
            return true;
        }

        return false;
    }

    public static boolean is_loss_time() {
        List<Integer> times = Arrays.asList(13, 17);
        Integer hh = Utils.getIntValue(Utils.convertDateToString("HH", Calendar.getInstance().getTime()));
        if (times.contains(hh)) {
            return true;
        }

        return false;
    }

    // https://www.calculator.net/time-duration-calculator.html
    public static boolean isNewsAt_19_20_21h() {
        List<Integer> times = Arrays.asList(19, 20);

        Integer hh = Utils.getIntValue(Utils.convertDateToString("HH", Calendar.getInstance().getTime()));
        Integer mm = Utils.getIntValue(Utils.convertDateToString("mm", Calendar.getInstance().getTime()));

        if (times.contains(hh)) {
            return true;
        }

        if (Arrays.asList(19).contains(hh)) {
            // 19:15
            if ((10 < mm) || (mm < 20)) {
                return true;
            }

            // 19:30
            if ((25 < mm) || (mm < 35)) {
                return true;
            }
        }

        if (Arrays.asList(20).contains(hh)) {
            // 20:45
            if ((40 < mm) || (mm < 50)) {
                return true;
            }
        }

        if (Arrays.asList(20, 21).contains(hh)) {
            // 21:00 22:00
            if ((55 < mm) || (mm < 05)) {
                return true;
            }
        }

        return false;
    }

    public static boolean isOpenTradeTime_6h_to_1h() {
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
        if (BscScanBinanceApplication.hostname.contains("PC") && !text.contains("FTMO")) {
            // return;
        }

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
                ret = new BigDecimal(String.valueOf(value));
            }
            return ret;
        } catch (Exception e) {
            return BigDecimal.ZERO;
        }

    }

    public static LocalDateTime convertStrToTime(String server_time) {
        String pattern = "yyyy.MM.dd HH:mm:ss";
        DateTimeFormatter formatter = DateTimeFormatter.ofPattern(pattern);
        LocalDateTime pre_time = LocalDateTime.parse(server_time, formatter);

        return pre_time;
    }

    public static String get_duration_trade_time(Mt5OpenTradeEntity trade) {
        String time = "";

        if (Utils.isNotBlank(trade.getOpenTime())) {
            LocalDateTime open_time = Utils.convertStrToTime(trade.getOpenTime());
            LocalDateTime currServerTime = Utils.convertStrToTime(trade.getCurrServerTime());

            Duration duration = Duration.between(open_time, currServerTime);
            long elapsedMinutes = duration.toMinutes();

            int days = Integer.valueOf(String.valueOf(elapsedMinutes)) / 1440;
            int hours = Integer.valueOf(Integer.valueOf(String.valueOf(elapsedMinutes)) % 1440) / 60;
            int minutes = Integer.valueOf(String.valueOf(elapsedMinutes)) % 60;

            time = Utils.appendLeft(String.valueOf(minutes), 2, "0") + "m";
            time = Utils.appendLeft(String.valueOf(hours), 2, "0") + "h:" + time;

            if (days > 0) {
                time = Utils.appendLeft(String.valueOf(days), 2) + "d:" + time;
            } else {
                time = "    " + time;
            }
        }

        return time;
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

        if (!value.contains(".")) {
            return value;
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

    public static boolean is_must_close_avoid_overnight_fees_triple() {
        DayOfWeek day = DayOfWeek.of(LocalDate.now().get(ChronoField.DAY_OF_WEEK));
        int hh = Utils.getIntValue(Utils.convertDateToString("HH", Calendar.getInstance().getTime()));

        if ((day == DayOfWeek.WEDNESDAY) || (day == DayOfWeek.FRIDAY)) {
            if (hh > 20) {
                return true;
            }
        }
        if ((day == DayOfWeek.THURSDAY) || (day == DayOfWeek.SATURDAY)) {
            if (hh < 5) {
                return true;
            }
        }

        if ((22 < hh) && (hh < 3)) {
            return true;
        }

        return false;
    }

    public static String getTime_day24Hmm() {
        LocalDate today = LocalDate.now();
        DayOfWeek day = DayOfWeek.of(today.get(ChronoField.DAY_OF_WEEK));

        // Calendar calendar = Calendar.getInstance();
        // String name = calendar.getDisplayName(Calendar.DAY_OF_WEEK, Calendar.SHORT,
        // Locale.US);

        String name = "";
        if (day == DayOfWeek.MONDAY) {
            name = "t2";
        }
        if (day == DayOfWeek.THURSDAY) {
            name = "t3";
        }
        if (day == DayOfWeek.WEDNESDAY) {
            name = "t4";
        }
        if (day == DayOfWeek.THURSDAY) {
            name = "t5";
        }
        if (day == DayOfWeek.FRIDAY) {
            name = "t6";
        }
        if (day == DayOfWeek.SATURDAY) {
            name = "t7";
        }
        if (day == DayOfWeek.SUNDAY) {
            name = "cn";
        }

        String date = Utils.convertDateToString("dd", Calendar.getInstance().getTime());

        Calendar calendar = Calendar.getInstance();
        calendar.add(Calendar.HOUR, 6);
        String HHm0 = Utils.convertDateToString("HHmm", calendar.getTime());
        HHm0 = HHm0.subSequence(0, 3) + "0";

        return date + name + "_e" + HHm0;
    }

    public static String getYyyyMmDd_HHmmss() {
        return Utils.convertDateToString("yyyyMMdd_HHmmss", Calendar.getInstance().getTime());
    }

    public static Date getYyyyMmDd_HHmmss(String yyyyMMdd_HHmmss) {
        return convertStringToDate("yyyyMMdd_HHmmss", yyyyMMdd_HHmmss);
    }

    public static int getMinutes(String yyyyMMdd_HHmmss) {
        Date reversal_date_time = Utils.getYyyyMmDd_HHmmss(yyyyMMdd_HHmmss);
        Calendar previous = Calendar.getInstance();
        previous.setTime(reversal_date_time);

        Calendar now = Calendar.getInstance();
        long diff_minus = now.getTimeInMillis() - previous.getTimeInMillis();
        diff_minus = diff_minus / (60 * 1000);
        int diff_minus_int = Math.toIntExact(diff_minus);

        return diff_minus_int;
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

        if (id.contains(PREFIX_H04) || id.contains(CAPITAL_TIME_H4)) {
            return getCurrentYyyyMmDd_Blog4h() + "_";
        }

        if (id.contains(PREFIX_H01) || id.contains(CAPITAL_TIME_H1)) {
            return getCurrentYyyyMmDd_HH() + "_";
        }

        if (id.contains(PREFIX_D01) || id.contains(CAPITAL_TIME_D1)) {
            return getYyyyMmDdHH_ChangeDailyChart() + "_";
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

    public static String getYyyyMMdd() {
        Calendar calendar = Calendar.getInstance();
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

        BigDecimal body_hig = dto.getPrice_close_candle().subtract(dto.getPrice_open_candle()).abs()
                .multiply(BigDecimal.valueOf(1.5));

        BigDecimal up_bread = dto.getHight_price().subtract(dto.getPrice_close_candle().max(dto.getPrice_open_candle()))
                .abs();

        BigDecimal dn_bread = dto.getLow_price().subtract(dto.getPrice_close_candle().min(dto.getPrice_open_candle()))
                .abs();

        if ((up_bread.compareTo(body_hig) > 0) && (dn_bread.compareTo(body_hig) > 0)) {
            return true;
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

    public static String trend_by_above_below_ma(List<BtcFutures> list, int length) {
        if (CollectionUtils.isEmpty(list) || (list.size() < 1) || (list.size() < length)) {
            return "";
        }

        // Giá đóng cửa của cây nến trước đó.
        BigDecimal ma = calcMA(list, length, 1);
        BigDecimal price = list.get(0).getPrice_close_candle();
        if (length > 30) {
            price = calcMA(list, 9, 0);
        }

        if (price.compareTo(ma) > 0) {
            return TREND_LONG;
        }
        if (price.compareTo(ma) < 0) {
            return TREND_SHOT;
        }

        return "";
    }

    public static int getSlowIndex(List<BtcFutures> list) {
        String symbol = list.get(0).getId().toLowerCase();
        if (symbol.contains(PREFIX_H04)) {
            return 50;
        }
        if (symbol.contains(PREFIX_D01)) {
            return 8;
        }
        if (symbol.contains(PREFIX_W01)) {
            return 8;
        }

        return 50;
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
        if (CollectionUtils.isEmpty(list)) {
            return "";
        }

        String id = list.get(0).getId().toLowerCase();
        return getChartName(id);
    }

    public static String getChartName(String dto_id) {
        if (dto_id.contains(CAPITAL_TIME_03) || dto_id.contains(PREFIX_03m)) {
            return "(03)";
        }
        // if (dto_id.contains(CAPITAL_TIME_05) || dto_id.contains(PREFIX_05m)) {
        // return "(05)";
        // }
        if (dto_id.contains(CAPITAL_TIME_10) || dto_id.contains(PREFIX_10m)) {
            return "(10)";
        }
        if (dto_id.contains(CAPITAL_TIME_12) || dto_id.contains(PREFIX_12m)) {
            return "(12)";
        }
        if (dto_id.contains(CAPITAL_TIME_15) || dto_id.contains(PREFIX_15m)) {
            return "(15)";
        }
        if (dto_id.contains(CAPITAL_TIME_H1) || dto_id.contains(PREFIX_H01)) {
            return "(H1)";
        }
        if (dto_id.contains(CAPITAL_TIME_H4) || dto_id.contains(PREFIX_H04)) {
            return "(H4)";
        }
        if (dto_id.contains(CAPITAL_TIME_D1) || dto_id.contains(PREFIX_D01) || dto_id.contains("_1d")) {
            return "(D1)";
        }
        if (dto_id.contains(CAPITAL_TIME_W1) || dto_id.contains(PREFIX_W01)) {
            return "(W1)";
        }
        if (dto_id.contains(CAPITAL_TIME_MO) || dto_id.contains(PREFIX_MO1)) {
            return "(MO)";
        }

        return "(" + dto_id + ")";
    }

    public static List<BigDecimal> calc_sl1_tp2(Orders dto_sl, String find_trend) {
        List<BigDecimal> result = new ArrayList<BigDecimal>();
        if (Objects.isNull(dto_sl)) {
            result.add(BigDecimal.ZERO);
            result.add(BigDecimal.ZERO);
            return result;
        }

        BigDecimal sl = BigDecimal.ZERO;
        BigDecimal tp = BigDecimal.ZERO;

        BigDecimal amp = dto_sl.getAmplitude_avg_of_candles();
        // BigDecimal amp =
        // dto_sl.getAmplitude_avg_of_candles().multiply(BigDecimal.valueOf(1.5));

        if (Objects.equals(find_trend, Utils.TREND_LONG)) {
            sl = dto_sl.getCurrent_price().subtract(amp);
            tp = dto_sl.getCurrent_price().add(amp);
        }

        if (Objects.equals(find_trend, Utils.TREND_SHOT)) {
            sl = dto_sl.getCurrent_price().add(amp);
            tp = dto_sl.getCurrent_price().subtract(amp);
        }

        result.add(sl);
        result.add(tp);
        return result;
    }

    public static BigDecimal calc_tp_by_amplitude_of_candle(BigDecimal current_price,
            BigDecimal amplitude_avg_of_candles, String trend) {
        BigDecimal tp = BigDecimal.ZERO;
        if (Objects.equals(trend, Utils.TREND_LONG)) {
            tp = current_price.add(amplitude_avg_of_candles);
        }

        if (Objects.equals(trend, Utils.TREND_SHOT)) {
            tp = current_price.subtract(amplitude_avg_of_candles);
        }

        return tp;
    }

    // public static BigDecimal calc_tp_by_amplitude_of_d1(Orders dto_d1, String
    // trend) {
    // BigDecimal tp = BigDecimal.ZERO;
    //
    // if (Objects.equals(trend, Utils.TREND_LONG)) {
    // // tp = Giá thấp nhất của cây nến hiện tại + biên độ giao động avg của nến
    // ngày.
    // BigDecimal lowest_curr_d = dto_d1.getLowest_price_of_curr_candle();
    // tp = lowest_curr_d.add(dto_d1.getAmplitude_avg_of_candles());
    //
    // // TP nhỏ hơn Highest thì lấy Highest + biên độ 1/15 để đảm bảo validate.
    // if (tp.compareTo(dto_d1.getHighest_price_of_curr_candle()) < 0) {
    // tp =
    // dto_d1.getHighest_price_of_curr_candle().add(dto_d1.getAmplitude_1_part_15());
    // }
    // }
    //
    // if (Objects.equals(trend, Utils.TREND_SHOT)) {
    // // tp = Giá cao nhất của cây nến hiện tại - biên độ giao động avg của nến
    // ngày.
    // BigDecimal higest_curr_d = dto_d1.getHighest_price_of_curr_candle();
    // tp = higest_curr_d.subtract(dto_d1.getAmplitude_avg_of_candles());
    //
    // // TP lớn hơn Lowest thì lấy Lowest - biên độ 1/15 để đảm bảo validate.
    // if (tp.compareTo(dto_d1.getLowest_price_of_curr_candle()) > 0) {
    // tp =
    // dto_d1.getLowest_price_of_curr_candle().subtract(dto_d1.getAmplitude_1_part_15());
    // }
    // }
    //
    // return tp;
    // }

    public static BigDecimal calcFiboTP_1R(String trend, BigDecimal low_or_heigh, BigDecimal curr_price) {
        BigDecimal bread = curr_price.subtract(low_or_heigh);
        bread = bread.abs();

        BigDecimal bread_tp = (bread.multiply(BigDecimal.valueOf(1.168))); // 3.168
        // bread.multiply(BigDecimal.valueOf(4.236));
        // bread.multiply(BigDecimal.valueOf(6.854));

        BigDecimal tp_3168 = BigDecimal.ZERO;
        if (Objects.equals(trend, TREND_LONG)) {
            tp_3168 = curr_price.add(bread_tp);
        }
        if (Objects.equals(trend, TREND_SHOT)) {
            tp_3168 = curr_price.subtract(bread_tp);
        }

        return tp_3168;
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
        if (!symbol.contains("_01d")) {
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
                BigDecimal close = dto.getPrice_close_candle();

                sum = sum.add(close);
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

    public static String get_reverse_trade_trend(String TRADE_TREND) {
        String REVERSE_TRADE_TREND = TRADE_TREND.contains(Utils.TREND_LONG) ? Utils.TREND_SHOT : Utils.TREND_LONG;

        return REVERSE_TRADE_TREND;
    }

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

    public static List<BigDecimal> getBodyCandle(List<BtcFutures> list) {
        List<BigDecimal> result = new ArrayList<BigDecimal>();

        BigDecimal min = BigDecimal.valueOf(1000000);
        BigDecimal max = BigDecimal.ZERO;

        for (int index = 0; index < list.size(); index++) {
            BigDecimal ma = calcMA(list, 2, index);

            if (min.compareTo(ma) > 0) {
                min = ma;
            }

            if (max.compareTo(ma) < 0) {
                max = ma;
            }
        }

        result.add(min);
        result.add(max);

        return result;
    }

    //
    // private String getTrendArea(String EPIC, String CAPITAL_TIME_XX) {
    // List<BtcFutures> list = getCapitalData(EPIC, CAPITAL_TIME_XX);
    // if (!CollectionUtils.isEmpty(list)) {
    // BigDecimal str = BigDecimal.ZERO;
    // BigDecimal end = BigDecimal.ZERO;
    // BigDecimal price = BigDecimal.ZERO;
    // // ----------------------------------------------------------------------
    // List<BtcFutures> heiken_list = Utils.getHekenList(list);
    // List<BigDecimal> area = Utils.getBuySellArea(heiken_list);
    // str = area.get(0);
    // end = area.get(1);
    // price = heiken_list.get(0).getCurrPrice();
    //
    // if ((price.compareTo(str) <= 0)) {
    // return Utils.TREND_LONG;
    // }
    //
    // if ((price.compareTo(end) >= 0)) {
    // return Utils.TREND_SHOT;
    // }
    // }
    //
    // return "";
    // }

    public static String textBodyArea(List<BtcFutures> heiken_list) {
        List<BigDecimal> min_max_area = Utils.getBuySellArea(heiken_list);
        String result = "(Body: ";
        result += Utils.appendSpace(Utils.removeLastZero(formatPrice(min_max_area.get(0), 5)), 10);
        result += " ~ ";
        result += Utils.appendSpace(Utils.removeLastZero(formatPrice(min_max_area.get(1), 5)), 10);
        result += ")";
        return result;
    }

    public static String getAmplitudeTrend(String trend, String zone) {
        if (Objects.equals(trend, zone.trim())) {
            return trend;
        }

        if (zone.contains(TREND_LONG) && zone.contains(TREND_SHOT)) {
            return trend;
        }

        if (Objects.equals(TREND_LONG, zone.trim())) {
            return TREND_LONG;
        }

        if (Objects.equals(TREND_SHOT, zone.trim())) {
            return TREND_SHOT;
        }

        return trend;
    }

    public static String getBreadTrend(List<BtcFutures> heiken_list) {
        String trend = "";
        BigDecimal curr_price = heiken_list.get(0).getCurrPrice();
        List<BigDecimal> body = Utils.getBodyCandle(heiken_list);

        // BUY area
        if (curr_price.compareTo(body.get(0)) < 0) {
            trend = Utils.TREND_LONG;
        }

        // SELL area
        if (curr_price.compareTo(body.get(1)) > 0) {
            trend = Utils.TREND_SHOT;
        }

        return trend;
    }

    public static double count_heiken_candles(List<BtcFutures> heiken_list, String find_trend, int start_candle_no) {
        double count = 0;
        boolean is_uptrend_fin = find_trend.contains(Utils.TREND_LONG) ? true : false;

        for (int index = start_candle_no; index < heiken_list.size(); index++) {
            if (is_uptrend_fin == heiken_list.get(index).isUptrend()) {
                count += 1;
            } else {
                break;
            }
        }

        return count;
    }

    public static double count_position_of_candle1_vs_ma10(List<BtcFutures> list, String find_trend) {
        double count = 0;

        int size = 20;
        if (size > list.size()) {
            size = list.size();
        }

        boolean is_uptrend_ma9_1 = find_trend.contains(Utils.TREND_LONG) ? true : false;

        for (int index = 1; index < size; index++) {
            BigDecimal ma9_i = Utils.calcMA(list, 9, index);
            boolean is_uptrend_ma9_i = (list.get(index).getPrice_close_candle().compareTo(ma9_i) >= 0) ? true : false;

            if (is_uptrend_ma9_1 == is_uptrend_ma9_i) {
                count += 1;
            } else {
                break;
            }
        }

        return count;
    }

    public static String getZone(List<BtcFutures> heiken_list) {
        List<BigDecimal> buy_sel_area = Utils.getBuySellArea(heiken_list);

        BigDecimal curr_price = heiken_list.get(0).getCurrPrice();
        if (curr_price.compareTo(buy_sel_area.get(0)) < 0) {
            return Utils.TREND_LONG;
        }
        if (curr_price.compareTo(buy_sel_area.get(1)) > 0) {
            return Utils.TREND_SHOT;
        }

        return Utils.TREND_LONG + "_" + Utils.TREND_SHOT;
    }

    public static String getZoneH12(List<BtcFutures> heiken_list) {
        List<BigDecimal> LoHi = Utils.getLowHighCandle(heiken_list);
        BigDecimal high = LoHi.get(1).subtract(LoHi.get(0));
        BigDecimal quarter = high.divide(BigDecimal.valueOf(2), 10, RoundingMode.CEILING);

        BigDecimal buy_boundary = LoHi.get(0).add(quarter);
        BigDecimal sal_boundary = LoHi.get(1).subtract(quarter);

        BigDecimal curr_price = heiken_list.get(0).getCurrPrice();
        if (curr_price.compareTo(buy_boundary) < 0) {
            return Utils.TREND_LONG;
        }
        if (curr_price.compareTo(sal_boundary) > 0) {
            return Utils.TREND_SHOT;
        }

        return TREND_UNSURE;
    }

    public static BigDecimal calcMaxBread(List<BtcFutures> list) {
        BigDecimal max_bread = BigDecimal.ZERO;

        for (BtcFutures dto : list) {
            List<BtcFutures> sub_list = new ArrayList<BtcFutures>();
            sub_list.add(dto);

            List<BigDecimal> body = Utils.getBodyCandle(sub_list);
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

    public static BigDecimal calcAvgBread(List<BtcFutures> list) {
        int count = 0;
        BigDecimal total_bread = BigDecimal.ZERO;
        for (BtcFutures dto : list) {
            List<BtcFutures> sub_list = new ArrayList<BtcFutures>();
            sub_list.add(dto);

            List<BigDecimal> body = Utils.getBodyCandle(sub_list);
            List<BigDecimal> low_high = Utils.getLowHighCandle(sub_list);

            BigDecimal beard_buy = (body.get(0).subtract(low_high.get(0))).abs();
            BigDecimal bread_sell = (low_high.get(1).subtract(body.get(1))).abs();
            BigDecimal bread = (beard_buy.compareTo(bread_sell) > 0 ? beard_buy : bread_sell);
            count += 1;
            total_bread = total_bread.add(bread);
        }

        BigDecimal avg_bread = BigDecimal.ZERO;
        if (count > 0) {
            avg_bread = total_bread.divide(BigDecimal.valueOf(count), 10, RoundingMode.CEILING);
        }
        return avg_bread;
    }

    public static List<BigDecimal> getBuySellArea(List<BtcFutures> heiken_list) {
        List<BigDecimal> body = Utils.getLowHighCandle(heiken_list);
        BigDecimal high = body.get(1).subtract(body.get(0));

        BigDecimal quarter = high.divide(BigDecimal.valueOf(4), 10, RoundingMode.CEILING);

        BigDecimal buy_boundary = body.get(0).add(quarter);
        BigDecimal sal_boundary = body.get(1).subtract(quarter);

        List<BigDecimal> result = new ArrayList<BigDecimal>();
        result.add(buy_boundary);
        result.add(sal_boundary);

        return result;
    }

    public static List<BigDecimal> calc_amplitude_average_of_candles(List<BtcFutures> list) {
        BigDecimal min = BigDecimal.valueOf(1000000);
        BigDecimal max = BigDecimal.ZERO;
        BigDecimal total = BigDecimal.ZERO;

        for (BtcFutures dto : list) {
            BigDecimal high_candle = dto.getHight_price().subtract(dto.getLow_price());
            total = total.add(high_candle);

            if (min.compareTo(high_candle) > 0) {
                min = high_candle;
            }

            if (max.compareTo(high_candle) < 0) {
                max = high_candle;
            }
        }

        BigDecimal avg = total.divide(BigDecimal.valueOf(list.size()), 10, RoundingMode.CEILING);

        List<BigDecimal> amplitudies = new ArrayList<BigDecimal>();
        amplitudies.add(min);
        amplitudies.add(avg);
        amplitudies.add(max);

        return amplitudies;
    }

    public static String get_trend_by_amplitude_of_cur_candle(BtcFutures dto_xx, BigDecimal amplitude_of_d1_candle) {
        String result = TREND_LONG + "_" + TREND_SHOT;

        BigDecimal cur_price = dto_xx.getCurrPrice();
        BigDecimal two_thirds_of_the_pie = amplitude_of_d1_candle.multiply(BigDecimal.valueOf(0.66666));

        BigDecimal low = dto_xx.getLow_price();
        BigDecimal eoz_long = low.add(two_thirds_of_the_pie);

        if (cur_price.compareTo(eoz_long) > 0) {
            return TREND_SHOT;
        }

        BigDecimal hig = dto_xx.getHight_price();
        BigDecimal eoz_shot = hig.subtract(two_thirds_of_the_pie);
        if (cur_price.compareTo(eoz_shot) < 0) {
            return TREND_LONG;
        }

        return result;
    }

    public static List<BigDecimal> getLowHighCandle(List<BtcFutures> list) {
        BigDecimal min_low = BigDecimal.valueOf(1000000);
        BigDecimal max_hig = BigDecimal.ZERO;

        for (BtcFutures dto : list) {
            if (min_low.compareTo(dto.getLow_price()) > 0) {
                min_low = dto.getLow_price();
            }

            if (max_hig.compareTo(dto.getHight_price()) < 0) {
                max_hig = dto.getHight_price();
            }
        }
        List<BigDecimal> result = new ArrayList<BigDecimal>();
        result.add(min_low);
        result.add(max_hig);

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

    public static boolean is_increase_decrease_rhythmic(List<BtcFutures> heiken_list) {
        int size = heiken_list.size();
        if (size > 15) {
            size = 15;
        }

        boolean is_uptrend = isUptrendByMa(heiken_list, 1);

        BigDecimal total_high = BigDecimal.ZERO;
        BigDecimal max_high = BigDecimal.ZERO;
        for (int index = 0; index < size; index++) {
            BtcFutures dto = heiken_list.get(index);
            BigDecimal high = (dto.getHight_price().subtract(dto.getLow_price())).abs();

            total_high = total_high.add(high);
            if ((dto.isUptrend() == is_uptrend) && (index < 5) && (high.compareTo(max_high) > 0)) {
                max_high = high;
            }
        }

        BigDecimal avg_high = total_high.multiply(BigDecimal.valueOf(0.0666666));

        if (max_high.compareTo(avg_high.multiply(BigDecimal.valueOf(3))) > 0) {
            return false;
        }

        return true;
    }

    public static String getType(String trend) {
        if (trend.contains(Utils.TREND_LONG)) {
            return "B";
        }

        if (trend.contains(Utils.TREND_SHOT)) {
            return "S";
        }

        return " ";
    }

    public static String getType(String prefix, String trend, String find_trend) {
        if (trend.contains(Utils.TREND_LONG) && Objects.equals(Utils.TREND_LONG, find_trend)) {
            return prefix + "b";
        }

        if (trend.contains(Utils.TREND_SHOT) && Objects.equals(Utils.TREND_SHOT, find_trend)) {
            return prefix + "s";
        }

        return Utils.appendSpace("", prefix.length() + 1);
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

    public static String checkXCutUpY(BigDecimal maX_1, BigDecimal maX_2, BigDecimal maY_1, BigDecimal maY_2) {
        if ((maX_1.compareTo(maX_2) >= 0) && (maX_1.compareTo(maY_1) >= 0) && (maY_2.compareTo(maX_2) >= 0)) {
            return TREND_LONG;
        }

        return "";
    }

    public static String checkXCutDnY(BigDecimal maX_1, BigDecimal maX_2, BigDecimal maY_1, BigDecimal maY_2) {
        if ((maX_1.compareTo(maX_2) <= 0) && (maX_1.compareTo(maY_1) <= 0) && (maY_2.compareTo(maX_2) <= 0)) {
            return TREND_SHOT;
        }
        return "";
    }

    public static boolean isXCuttingY(BigDecimal candle_low, BigDecimal candle_hig, BigDecimal ma) {
        if ((candle_low.compareTo(ma) <= 0) && (ma.compareTo(candle_hig) <= 0)) {
            return true;
        }
        return false;
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

    public static String find_trend_by_ma50(List<BtcFutures> heiken_list) {
        String find_trend = "";
        if (heiken_list.size() > 30) {
            String sw_1 = switchTrendByMa1vs50(heiken_list);
            if (Utils.isNotBlank(sw_1) && (sw_1.contains(TREND_LONG) || sw_1.contains(TREND_SHOT))) {
                return sw_1;
            }

            find_trend = Utils.trend_by_above_below_ma(heiken_list, 50);
        }

        return find_trend;
    }

    public static boolean is_insite_lohi(List<BtcFutures> heiken_list, String heiken,
            BigDecimal amplitude_avg_of_candles, BigDecimal ma01_0, BigDecimal ma10_0, BigDecimal ma20_0,
            BigDecimal ma50_0) {

        List<BigDecimal> lohi = getLowHighCandle(heiken_list.subList(0, 1));
        BigDecimal low = lohi.get(0);
        BigDecimal hig = lohi.get(1);

        BigDecimal amp = amplitude_avg_of_candles.multiply(BigDecimal.valueOf(2));
        if (Objects.equals(heiken, TREND_LONG)) {
            low = low.subtract(amp);
        } else {
            hig = hig.add(amp);
        }

        boolean inside_lohi = true;
        inside_lohi &= (ma10_0.compareTo(low) >= 0) && (ma20_0.compareTo(low) >= 0) && (ma50_0.compareTo(low) >= 0);
        inside_lohi &= (hig.compareTo(ma10_0) >= 0) && (hig.compareTo(ma20_0) >= 0) && (hig.compareTo(ma50_0) >= 0);

        return inside_lohi;
    }

    public static String switch_trend_seq_10_20_50(List<BtcFutures> heiken_list, BigDecimal amp_avg, Mt5Macd macd) {
        String result = "";
        if (heiken_list.size() < 50) {
            return result;
        }

        String id = heiken_list.get(0).getId();
        if (id.contains(PREFIX_H01) && id.contains("GBPNZD")) {
            boolean debug = true;
        }

        // Cây nến hoàn hảo:
        // cond 1) C1 heiken cùng chiều;
        // cond 2) Ma10 || Ma20 || Ma50 phi cùng chiều;
        // cond 3) (LowC1 - Avg)&HigC1 chứa Ma50; (HigC1 + Avg)&LowC1 chứa Ma50;
        // cond 4) (trình tự ma10 -> ma20 -> ma50)
        // cond 5) macd_vs_zero cùng chiều
        // cond 6) macd_vs_signal cùng chiều

        int candle_index = 0;
        if (id.contains(PREFIX_03m) || id.contains(PREFIX_10m) || id.contains(PREFIX_15m) || id.contains(PREFIX_30m)) {
            candle_index = 1;
        }

        BigDecimal ma03 = calcMA(heiken_list, 3, candle_index);
        BigDecimal ma10 = calcMA(heiken_list, 10, candle_index);
        BigDecimal ma20 = calcMA(heiken_list, 20, candle_index);
        BigDecimal ma50 = calcMA(heiken_list, 50, candle_index);

        boolean heiken_cx_uptrend = heiken_list.get(candle_index).isUptrend();

        boolean is_uptrend_ma10 = Utils.isUptrendByMa(heiken_list, 10, candle_index, candle_index + 1);
        boolean is_uptrend_ma20 = Utils.isUptrendByMa(heiken_list, 20, candle_index, candle_index + 1);

        String cond_1_trend_heiken = heiken_cx_uptrend ? Utils.TREND_LONG : Utils.TREND_SHOT;
        // --------------------------------------------------------------------------------------
        String cond_2_trend_1020 = "cond2_" + Utils.TREND_UNSURE;
        if ((heiken_cx_uptrend == is_uptrend_ma10) && (heiken_cx_uptrend == is_uptrend_ma20)) {
            cond_2_trend_1020 = cond_1_trend_heiken;
        }
        // --------------------------------------------------------------------------------------
        BigDecimal low = ma03;
        BigDecimal hig = ma03;
        BtcFutures candle = heiken_list.get(candle_index);
        if (heiken_cx_uptrend) {
            low = candle.getLow_price().subtract(amp_avg);
            hig = candle.getHight_price();
        } else {
            low = candle.getLow_price();
            hig = candle.getHight_price().add(amp_avg);
        }
        boolean cond_3_inside_lohi = (low.compareTo(ma50) <= 0) && (ma50.compareTo(hig) <= 0);
        // --------------------------------------------------------------------------------------
        String cond4_trend_3_10_20_50 = "cond4_" + Utils.TREND_UNSURE;
        if ((ma03.compareTo(ma10) >= 0) && (ma03.compareTo(ma20) >= 0) && (ma03.compareTo(ma50) >= 0)) {
            cond4_trend_3_10_20_50 = Utils.TREND_LONG;
        }
        if ((ma03.compareTo(ma10) <= 0) && (ma03.compareTo(ma20) <= 0) && (ma03.compareTo(ma50) <= 0)) {
            cond4_trend_3_10_20_50 = Utils.TREND_SHOT;
        }
        // --------------------------------------------------------------------------------------
        if (Objects.equals(cond_1_trend_heiken, cond_2_trend_1020) && cond_3_inside_lohi
                && Objects.equals(cond_1_trend_heiken, cond4_trend_3_10_20_50)
                && Objects.equals(cond_1_trend_heiken, macd.getTrend_macd_vs_zero())
                && Objects.equals(cond_1_trend_heiken, macd.getTrend_macd_vs_signal())) {

            String chart_name = getChartName(heiken_list).trim();
            result = chart_name + TEXT_SWITCH_TREND_SEQ_10_20_50 + ":" + Utils.appendSpace(cond_1_trend_heiken, 4);
        }

        return result;
    }

    public static String switchTrendByMa6vs9(List<BtcFutures> heiken_list) {
        String trend = switchTrendBy_MaX_vs_MaY(heiken_list, 6, 9);
        if (trend.contains(Utils.TREND_LONG) || trend.contains(Utils.TREND_SHOT)) {
            String chart_name = getChartName(heiken_list).trim();
            String switch_trend = chart_name + TEXT_SWITCH_TREND_Ma69 + ":" + Utils.appendSpace(trend, 4);

            return switch_trend;
        }

        return "";
    }

    public static String switchTrendByMa10(List<BtcFutures> list) {
        BtcFutures candle = list.get(1);

        BigDecimal low_candle = candle.getPrice_open_candle().min(candle.getPrice_close_candle());

        BigDecimal hig_candle = candle.getPrice_open_candle().max(candle.getPrice_close_candle());

        for (int ma_no = 6; ma_no <= 10; ma_no++) {
            BigDecimal ma = Utils.calcMA(list, ma_no, 1);

            if ((low_candle.compareTo(ma) < 0) && (ma.compareTo(hig_candle) < 0)) {
                String trend_0 = candle.isUptrend() ? TREND_LONG : TREND_SHOT;
                String chart_name = getChartName(candle.getId()).trim();
                String switch_trend = chart_name + TEXT_SWITCH_TREND_Ma10 + ":" + Utils.appendSpace(trend_0, 4);

                return switch_trend;
            }
        }

        return "";
    }

    public static String switchTrendByMaXX(List<BtcFutures> list, int ma_xx) {
        BtcFutures candle = list.get(1);

        BigDecimal low_candle = candle.getLow_price();
        BigDecimal hig_candle = candle.getHight_price();

        BigDecimal ma = Utils.calcMA(list, ma_xx, 1);

        if ((low_candle.compareTo(ma) < 0) && (ma.compareTo(hig_candle) < 0)) {
            String trend = candle.isUptrend() ? TREND_LONG : TREND_SHOT;
            String chart_name = getChartName(candle.getId()).trim();

            String switch_trend = chart_name + TEXT_SWITCH_TREND_Ma10.replace("10", String.valueOf(ma_xx)) + ":"
                    + Utils.appendSpace(trend, 4);

            return switch_trend;
        }

        return "";
    }

    public static String switchTrendByMa1vs2025(List<BtcFutures> heiken_list) {
        String sw_1 = switchTrendByMa1(heiken_list, 1, 20, 25, TEXT_SWITCH_TREND_Ma_1vs20);
        String sw_0 = switchTrendByMa1(heiken_list, 0, 20, 25, TEXT_SWITCH_TREND_Ma_1vs20);

        if (Utils.isNotBlank(sw_1) && Utils.isNotBlank(sw_0)) {
            String trend_1 = sw_1.contains(TREND_LONG) ? TREND_LONG : TREND_SHOT;
            String trend_0 = sw_1.contains(TREND_LONG) ? TREND_LONG : TREND_SHOT;

            if (!Objects.equals(trend_1, trend_0)) {
                return sw_0;
            }
        }
        return sw_1;
    }

    public static String switchTrendByMa1vs50(List<BtcFutures> heiken_list) {
        String sw_1 = switchTrendByMa1(heiken_list, 1, 45, 50, TEXT_SWITCH_TREND_Ma_1vs20);
        String sw_0 = switchTrendByMa1(heiken_list, 0, 45, 50, TEXT_SWITCH_TREND_Ma_1vs20);

        if (Utils.isNotBlank(sw_1) && Utils.isNotBlank(sw_0)) {
            String trend_1 = sw_1.contains(TREND_LONG) ? TREND_LONG : TREND_SHOT;
            String trend_0 = sw_1.contains(TREND_LONG) ? TREND_LONG : TREND_SHOT;

            if (!Objects.equals(trend_1, trend_0)) {
                return sw_0;
            }
        }
        return sw_1;
    }

    public static String switchTrendByMa1(List<BtcFutures> heiken_list, int candle_no, int ma_form, int ma_to,
            String id_switch_trend) {
        String trend = "";

        BigDecimal ma1_0 = calcMA(heiken_list, 1, candle_no); // Đóng nến
        BigDecimal ma1_1 = calcMA(heiken_list, 1, candle_no + 1); // Đóng nến

        for (int ma_index = ma_form; ma_index <= ma_to; ma_index++) {

            BigDecimal maX_0 = calcMA(heiken_list, ma_index, candle_no);

            BigDecimal candle_low = heiken_list.get(candle_no).getLow_price();
            BigDecimal candle_hig = heiken_list.get(candle_no).getHight_price();

            BigDecimal maX_1 = calcMA(heiken_list, ma_index, candle_no + 1);

            String cutUp = Utils.checkXCutUpY(ma1_0, ma1_1, maX_0, maX_1);
            String cutDw = Utils.checkXCutDnY(ma1_0, ma1_1, maX_0, maX_1);

            if (Utils.isNotBlank(cutUp)) {
                trend += ma_index + ":" + cutUp + ";";
            }
            if (Utils.isNotBlank(cutDw)) {
                trend += ma_index + ":" + cutDw + ";";
            }
        }

        if (trend.contains(Utils.TREND_LONG) && trend.contains(Utils.TREND_SHOT)) {
            return "";
        }

        if (isBlank(trend.replace("_", ""))) {
            return "";
        }

        if (trend.contains(Utils.TREND_LONG) || trend.contains(Utils.TREND_SHOT)) {
            String chart_name = getChartName(heiken_list).trim();
            String switch_trend = chart_name + id_switch_trend + ":" + Utils.appendSpace(trend, 4);

            return switch_trend;
        }

        return "";
    }

    public static String switchTrendBy_MaX_vs_MaY(List<BtcFutures> heiken_list, int ma_x, int ma_y) {
        String trend = "_";

        BigDecimal ma1_0 = calcMA(heiken_list, ma_x, 0);
        BigDecimal ma1_2 = calcMA(heiken_list, ma_x, 2);

        BigDecimal maX_0 = calcMA(heiken_list, ma_y, 0);
        BigDecimal maX_2 = calcMA(heiken_list, ma_y, 2);

        String cutUp = Utils.checkXCutUpY(ma1_0, ma1_2, maX_0, maX_2);
        String cutDw = Utils.checkXCutDnY(ma1_0, ma1_2, maX_0, maX_2);

        if (Utils.isNotBlank(cutUp)) {
            trend += "ma" + ma_x + cutUp + "ma" + ma_y;
        }
        if (Utils.isNotBlank(cutDw)) {
            trend += "ma" + ma_x + cutDw + "ma" + ma_y;
        }

        if (trend.contains(Utils.TREND_LONG) && trend.contains(Utils.TREND_SHOT)) {
            return "";
        }

        if (isBlank(trend.replace("_", ""))) {
            return "";
        }

        if (trend.contains(Utils.TREND_LONG) || trend.contains(Utils.TREND_SHOT)) {
            if (trend.contains(Utils.TREND_LONG)) {
                trend = Utils.TREND_LONG;
            }
            if (trend.contains(Utils.TREND_SHOT)) {
                trend = Utils.TREND_SHOT;
            }

            return trend;
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

    public static String calculatePoints(String EPIC, BigDecimal amplitude_avg_of_candles) {
        int decimalPlaces = 5;
        if ("_CADCHF_".contains(EPIC)) {
            decimalPlaces = 5;
        }

        if (EPIC.contains("JPY") || EPIC.contains("XAU")) {
            decimalPlaces = 3;
        } else if (amplitude_avg_of_candles.compareTo(BigDecimal.valueOf(10)) > 0) {
            decimalPlaces = 2;
        } else if (amplitude_avg_of_candles.compareTo(BigDecimal.valueOf(1)) > 0) {
            decimalPlaces = 3;
        } else if (EPIC.contains("USOIL")) {
            decimalPlaces = 3;
        } else if (EPIC.contains("XAG") || EPIC.contains("XAU")) {
            decimalPlaces = 4;
        }

        BigDecimal point = formatPrice(amplitude_avg_of_candles, decimalPlaces)
                .multiply(BigDecimal.TEN.pow(decimalPlaces));

        return String.valueOf(point.intValue());
    }

    public static String switchTrendByMaXX(List<BtcFutures> list, int fastIndex, int slowIndex) {
        String result = switchTrendByMaXX_123(list, fastIndex, slowIndex, 1, 2);
        if (Utils.isNotBlank(result)) {
            return result;
        }

        return "";
    }

    public static BigDecimal getTakeProfitByAmp(DailyRange dailyRange, BigDecimal curr_price, String find_trend) {
        // if (Objects.equals(Utils.TREND_LONG, find_trend)) {
        // if (curr_price.compareTo(dailyRange.getResistance1()) < 0) {
        // return dailyRange.getResistance1();
        // }
        // if (curr_price.compareTo(dailyRange.getResistance2()) < 0) {
        // return dailyRange.getResistance2();
        // }
        // } else {
        // if (curr_price.compareTo(dailyRange.getSupport1()) > 0) {
        // return dailyRange.getSupport1();
        // }
        // if (curr_price.compareTo(dailyRange.getSupport2()) > 0) {
        // return dailyRange.getSupport2();
        // }
        // }
        return BigDecimal.ZERO;
    }

    public static String getTakeProfit123ByAmp(DailyRange dailyRange, BigDecimal curr_price, String find_trend) {
        String result = "TODO";
        // if (Objects.equals(Utils.TREND_LONG, find_trend)) {
        // result += " (r1):" + Utils.appendSpace(dailyRange.getResistance1(), 8);
        // result += " (r2):" + Utils.appendSpace(dailyRange.getResistance2(), 8);
        // } else {
        // result += " (s1):" + Utils.appendSpace(dailyRange.getSupport1(), 8);
        // result += " (s2):" + Utils.appendSpace(dailyRange.getSupport2(), 8);
        // }

        return result;
    }

    public static String switchTrendByMa13_XX(List<BtcFutures> heiken_list, int slowIndexXx) {
        if (CollectionUtils.isEmpty(heiken_list) || (heiken_list.size() < 50)) {
            return "";
        }
        if (Utils.getStringValue(heiken_list.get(0).getCurrPrice()).contains("E")) {
            return "";
        }

        String temp_long = "";
        String temp_shot = "";

        BigDecimal ma1_0 = calcMA(heiken_list, 1, 0);
        BigDecimal ma1_3 = calcMA(heiken_list, 1, 3);

        BigDecimal ma3_0 = calcMA(heiken_list, 3, 0);
        BigDecimal ma3_3 = calcMA(heiken_list, 3, 3);

        BigDecimal ma50_0 = calcMA(heiken_list, slowIndexXx, 0);
        BigDecimal ma50_3 = calcMA(heiken_list, slowIndexXx, 3);

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

        if (symbol.contains(PREFIX_D01)) {
            ma = calcMA(list, MA_INDEX_D1_START_LONG, cur);
        } else if (symbol.contains(PREFIX_H04)) {
            ma = calcMA(list, MA_INDEX_H4_START_LONG, cur);
        } else {
            ma = calcMA(list, 50, cur);
        }

        if (pre_close_price.compareTo(ma) > 0) {
            return true;
        }

        return false;
    }

    private static boolean isUptrendByMa(List<BtcFutures> list, int maIndex) {
        int str = 0;
        int end = 1;
        BigDecimal ma_c = calcMA(list, maIndex, str);
        BigDecimal ma_p = calcMA(list, maIndex, end);
        if (ma_c.compareTo(ma_p) > 0) {
            return true;
        }

        return false;
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
                : Objects.equals(trend, Utils.TREND_SHOT) ? "  📉 (" + CHAR_SHORT_DN + ")" : " ";

        return check;
    }

    public static String getTrendPrifix(String trend, int maFast, int maSlow) {
        String check = Objects.equals(trend, Utils.TREND_LONG) ? maFast + CHAR_LONG_UP + maSlow + " 💹"
                : Objects.equals(trend, Utils.TREND_SHOT) ? maFast + CHAR_SHORT_DN + maSlow + " 📉" : " ";

        return "(" + check + " )";
    }

    public static String getEpicFromId(String id) {
        String EPIC = id;
        String[] parts = EPIC.split("_");
        if (parts.length > 0) {
            EPIC = parts[0];
        }
        EPIC = EPIC.replace("_00", "");

        EPIC = EPIC.replace("_" + Utils.CAPITAL_TIME_W1, "");
        EPIC = EPIC.replace("_" + Utils.CAPITAL_TIME_D1, "");
        EPIC = EPIC.replace("_" + Utils.CAPITAL_TIME_H4, "");
        EPIC = EPIC.replace("_" + Utils.CAPITAL_TIME_H1, "");

        EPIC = EPIC.replace("_" + Utils.CAPITAL_TIME_03, "");
        // EPIC = EPIC.replace("_" + Utils.CAPITAL_TIME_05, "");
        EPIC = EPIC.replace("_" + Utils.CAPITAL_TIME_10, "");
        EPIC = EPIC.replace("_" + Utils.CAPITAL_TIME_12, "");
        EPIC = EPIC.replace("_" + Utils.CAPITAL_TIME_15, "");

        EPIC = EPIC.replace("_" + Utils.CRYPTO_TIME_05, "");
        EPIC = EPIC.replace("_" + Utils.CRYPTO_TIME_15, "");
        EPIC = EPIC.replace("_" + Utils.CRYPTO_TIME_H1, "");
        EPIC = EPIC.replace("_" + Utils.CRYPTO_TIME_H4, "");
        EPIC = EPIC.replace("_" + Utils.CRYPTO_TIME_D1, "");
        EPIC = EPIC.replace("_" + Utils.CRYPTO_TIME_W1, "");
        EPIC = EPIC.replace("_" + Utils.CRYPTO_TIME_MO, "");

        // EPIC = EPIC.replace(Utils.PREFIX_05m, "");
        EPIC = EPIC.replace(Utils.PREFIX_03m, "");
        EPIC = EPIC.replace(Utils.PREFIX_10m, "");
        EPIC = EPIC.replace(Utils.PREFIX_12m, "");
        EPIC = EPIC.replace(Utils.PREFIX_15m, "");
        EPIC = EPIC.replace(Utils.PREFIX_30m, "");
        EPIC = EPIC.replace(Utils.PREFIX_H01, "");
        EPIC = EPIC.replace(Utils.PREFIX_H02, "");
        EPIC = EPIC.replace(Utils.PREFIX_H04, "");
        EPIC = EPIC.replace(Utils.PREFIX_H12, "");
        EPIC = EPIC.replace(Utils.PREFIX_D01, "");
        EPIC = EPIC.replace(Utils.PREFIX_W01, "");
        EPIC = EPIC.replace(Utils.PREFIX_MO1, "");

        EPIC = EPIC.replace("_01d", "");
        EPIC = EPIC.replace("CRYPTO_", "");

        EPIC = EPIC.replace("_", "");

        return EPIC.toUpperCase();
    }

    public static int get_hoding_time(String comment) {
        int hoding_time = Utils.MINUTES_OF_1D;

        int candle_no = 1;
        boolean is_h1_trading = comment.contains(Utils.ENCRYPTED_H1);
        if (is_h1_trading) {
            hoding_time = Utils.MINUTES_OF_6H;

            int startIndex = comment.indexOf("_c") + 2;
            int endIndex = comment.indexOf(Utils.ENCRYPTED_H1);
            if (startIndex != -1 && endIndex != -1) {
                String numberString = comment.substring(startIndex, endIndex);
                candle_no = Utils.getIntValue(numberString);
            }

            if (candle_no > 0) {
                hoding_time = Utils.MINUTES_OF_6H + Utils.MINUTES_OF_1H - (candle_no * Utils.MINUTES_OF_1H);
            }
        }

        return hoding_time;
    }

    public static int capitalTimeToWaitingMimutes(String CAPITAL_TIME_XX) {
        switch (CAPITAL_TIME_XX) {

        case CAPITAL_TIME_03:
        case CAPITAL_TIME_10:
        case CAPITAL_TIME_12:
        case CAPITAL_TIME_15:
            return MINUTES_OF_1H;

        case CAPITAL_TIME_H1:
            return MINUTES_OF_4H;

        case CAPITAL_TIME_H4:
            return MINUTES_OF_4H;

        default:
            return MINUTES_OF_4H;
        }
    }

    public static String createOpenTradeMsg(Mt5OpenTrade dto, String prefix) {
        boolean is_scapping = false;
        if (dto.getComment().contains(Utils.ENCRYPTED_15)) {
            is_scapping = true;
        }

        String msg = "";
        if (!is_scapping) {
            msg += Utils.appendSpace("", 10) + getTimeHHmm();
        }
        msg += prefix;
        msg += Utils.appendSpace("(" + Utils.appendSpace(dto.getOrder_type().toUpperCase(), 4, "_") + ")", 15);
        msg += Utils.appendSpace(dto.getEpic(), 10) + new_line_from_service + " ";
        msg += " ,Standard:"
                + Utils.appendLeft(Utils.removeLastZero(Utils.get_standard_vol_per_100usd(dto.getEpic())), 6)
                + "(lot)    ";
        msg += Utils.appendSpace(dto.getComment(), 30);
        // msg += " ,SL: " + Utils.appendLeft(Utils.removeLastZero(dto.getStop_loss()),
        // 10) + " ";
        // msg += " ,TP: " +
        // Utils.appendLeft(Utils.removeLastZero(dto.getTake_profit1()), 10) + " ";
        msg += " ,Vol: " + Utils.appendLeft(Utils.getStringValue(dto.getLots()), 6) + "(lot)   ";

        return msg.replace(TEXT_NOTICE_ONLY, "");
    }

    public static String createCloseTradeMsg(Mt5OpenTradeEntity trade, String prefix, String reason) {
        String msg = Utils.appendSpace("", 10) + "(CloseMsg)   " + prefix;
        msg += Utils.appendSpace("(" + Utils.appendSpace(trade.getType(), 4, "_") + ")", 15);
        msg += Utils.appendSpace(trade.getSymbol(), 10) + new_line_from_service + " ";
        msg += Utils.appendSpace(reason + " " + Utils.get_duration_trade_time(trade), 30);

        msg += Utils.appendSpace(Utils.getCapitalLink(trade.getSymbol()), 62);
        msg += Utils.appendSpace(trade.getComment(), 35);

        return msg;
    }

    private static List<BtcFutures> calcHeikenLine(List<BtcFutures> list) {
        List<BtcFutures> heiken_list = new ArrayList<BtcFutures>();
        if (list.size() < 2) {
            return heiken_list;
        }
        BigDecimal currPrice = list.get(0).getCurrPrice();

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
                BtcFutures dto_pre = heiken_list.get(heken_index - 1);
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

            BtcFutures heiken = new BtcFutures(dto.getId(), currPrice, low, hig, ope, clo, BigDecimal.ZERO,
                    BigDecimal.ZERO, BigDecimal.ZERO, BigDecimal.ZERO, uptrend);

            heiken_list.add(heiken);
            heken_index += 1;
        }
        Collections.reverse(heiken_list);

        return heiken_list;
    }

    public static BigDecimal getSL(String EPIC, List<BtcFutures> heiken_list, String find_trend) {
        BigDecimal SL = BigDecimal.ZERO;
        int length = heiken_list.size() - 1;
        if (length > 10) {
            length = 10;
        }

        if (EPICS_FOREXS_ALL.contains(EPIC)) {
            int index = 1;
            for (index = 1; index < heiken_list.size(); index++) {
                BtcFutures dto = heiken_list.get(index);
                String trend = dto.isUptrend() ? TREND_LONG : TREND_SHOT;
                if (!Objects.equals(trend, find_trend)) {
                    break;
                }
            }
            if (index < (heiken_list.size() / 2)) {
                length = index + 3;
            }
        }
        if (length < 10) {
            length = 10;
        }

        BigDecimal bread = Utils.calcAvgBread(heiken_list.subList(1, length));
        bread = bread.multiply(BigDecimal.valueOf(0.5));

        List<BigDecimal> lohi = Utils.getLowHighCandle(heiken_list.subList(1, length));
        if (Objects.equals(find_trend, Utils.TREND_LONG)) {
            SL = lohi.get(0).subtract(bread);
        } else if (Objects.equals(find_trend, Utils.TREND_SHOT)) {
            SL = lohi.get(1).add(bread);
        }

        return SL;
    }

    public static List<BtcFutures> getHeikenList(List<BtcFutures> list) {
        if (CollectionUtils.isEmpty(list)) {
            return new ArrayList<BtcFutures>();
        }

        List<BtcFutures> list1 = calcHeikenLine(list);
        return list1;
    }

    public static boolean isSameTrendByHekenAshi_Ma1_6(List<BtcFutures> list) {
        List<BtcFutures> heiken_list = getHeikenList(list);
        if (CollectionUtils.isEmpty(heiken_list)) {
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

    public static boolean is_long_legged_doji_candle(BtcFutures candle) {
        BigDecimal bread_hig = candle.getHight_price();
        BigDecimal bread_low = candle.getLow_price();
        BigDecimal body = candle.getPrice_open_candle().subtract(candle.getPrice_close_candle()).abs();
        BigDecimal body_x2 = body.multiply(BigDecimal.valueOf(2));

        if (candle.isUptrend()) {
            bread_hig = bread_hig.subtract(candle.getPrice_close_candle());
            bread_low = candle.getPrice_open_candle().subtract(bread_low);
        } else {
            bread_hig = bread_hig.subtract(candle.getPrice_open_candle());
            bread_low = candle.getPrice_close_candle().subtract(bread_low);
        }

        if ((bread_hig.compareTo(body_x2) > 0) && (bread_low.compareTo(body_x2) > 0)) {
            return true;
        }

        return false;
    }

    public static boolean isTradingAgainstTrend(String EPIC, String trend, List<Mt5OpenTrade> open_trade_list) {
        String EPIC_ACTION = (EPIC + "_" + trend).toUpperCase();

        for (Mt5OpenTrade trade : open_trade_list) {
            String TRADE_EPIC = trade.getEpic().toUpperCase();
            String TRADE_TREND = trade.getOrder_type().toUpperCase().contains(Utils.TREND_LONG) ? Utils.TREND_LONG
                    : trade.getOrder_type().toUpperCase().contains(Utils.TREND_SHOT) ? Utils.TREND_SHOT : "    ";

            if (EPIC_ACTION.contains(TRADE_EPIC) && !EPIC_ACTION.contains(TRADE_TREND)) {
                return true;
            }
        }

        return false;
    }

    public static String switchTrendByHeiken(List<BtcFutures> heiken_list) {
        String switch_trend = "";

        boolean heiken_1_uptrend = heiken_list.get(1).isUptrend();
        boolean heiken_2_uptrend = heiken_list.get(2).isUptrend();

        if (heiken_1_uptrend != heiken_2_uptrend) {
            String chart_name = getChartName(heiken_list.get(0).getId());
            String trend = heiken_1_uptrend ? TREND_LONG : TREND_SHOT;
            switch_trend = chart_name + TEXT_SWITCH_TREND_HEIKEN + ":" + Utils.appendSpace(trend, 4);
        }

        return switch_trend;
    }

    public static String getTrendByLineChart(List<BtcFutures> list) {
        return isUptrendByMa(list, 1) ? TREND_LONG : TREND_SHOT;
    }

    public static String getTrend_C1_ByLineChart(List<BtcFutures> list) {
        return isUptrendByMa(list, 1) ? TREND_LONG : TREND_SHOT;
    }

    public static String getTrendByHekenAshiList(List<BtcFutures> heiken_list, List<BtcFutures> list) {
        String heiken_0 = getTrendByHekenAshiList(heiken_list, 0);
        String heiken_1 = getTrendByHekenAshiList(heiken_list, 1);
        String candle_0 = list.get(0).isUptrend() ? Utils.TREND_LONG : Utils.TREND_SHOT;

        if (Objects.equals(heiken_0, candle_0) && Objects.equals(heiken_0, heiken_1)) {
            return heiken_1;
        }

        return getChartName(heiken_list.get(0).getId()) + "_Heiken_" + TREND_UNSURE;
    }

    public static String getTrendByHekenAshiList(List<BtcFutures> heiken_list, int candle_no) {
        if (CollectionUtils.isEmpty(heiken_list) || (heiken_list.size() < candle_no)) {
            return "";
        }

        String result = heiken_list.get(candle_no).isUptrend() ? Utils.TREND_LONG : Utils.TREND_SHOT;

        return result;
    }

    public static String getTypeOfEpic(String EPIC) {
        String type = "";

        if (Utils.EPICS_MAIN_FX.contains(EPIC)) {
            type = "mFx";
        }
        if (Utils.EPICS_INDEXS_CFD.contains(EPIC)) {
            type = "iDx";
        }
        if (Utils.EPICS_METALS.contains(EPIC)) {
            type = "xAu";
        }
        if (Utils.EPICS_CRYPTO_CFD.contains(EPIC)) {
            type = "bIt";
        }
        if (Utils.EPICS_STOCKS_USA.contains(EPIC)) {
            type = "uSa";
        }
        if (Utils.EPICS_STOCKS_EUR.contains(EPIC)) {
            type = "eUr";
        }
        if (Utils.EPICS_FOREXS_ALL.contains(EPIC)) {
            type = "fOx";
        }
        type = appendSpace(type, 5);

        return type;
    }

    public static String createLineForex_Header(Orders dto_entry, Orders dto_sl, String append) {
        if (Objects.isNull(dto_entry) || Objects.isNull(dto_sl)) {
            return "";
        }
        String EPIC = getEpicFromId(dto_entry.getId());
        String chart_name = getChartName(dto_entry.getId());

        String header = "";
        header += Utils.appendSpace(append, 8);
        header += chart_name + ":" + Utils.appendSpace(dto_entry.getTrend_by_heiken(), 8);
        header += Utils.appendSpace(EPIC, 12) + getTypeOfEpic(EPIC);
        header += Utils.appendSpace(Utils.getCapitalLink(EPIC), 68);

        return header;
    }

    public static String createLineCrypto(Orders entity, String symbol, String type) {
        String chart = entity.getId().replace("CRYPTO_" + symbol, "").replace("_", "").toUpperCase();

        String tmp_msg = type + Utils.appendSpace(chart, 8) + Utils.appendSpace(entity.getTrend_by_heiken(), 10)
                + Utils.appendSpace(symbol, 10);

        String price = Utils.appendSpace(Utils.removeLastZero(entity.getCurrent_price()), 10);
        String url = Utils.appendSpace(Utils.getCryptoLink_Spot(symbol), 70) + price
                + Utils.appendSpace(entity.getSwitch_trend(), 60);

        return tmp_msg + url;
    }

    public static List<BigDecimal> get_SL_TP_by_amp(DailyRange dailyRange, BigDecimal curr_price, String find_trend) {
        BigDecimal stop_loss = BigDecimal.ZERO;
        BigDecimal take_profit = BigDecimal.ZERO;
        BigDecimal amp_w = dailyRange.getAvg_amp_week();

        if (Objects.equals(find_trend, Utils.TREND_LONG)) {
            stop_loss = curr_price.subtract(amp_w);
            take_profit = curr_price.add(amp_w).add(amp_w);
        }

        if (Objects.equals(find_trend, Utils.TREND_SHOT)) {
            stop_loss = curr_price.add(amp_w);
            take_profit = curr_price.subtract(amp_w).subtract(amp_w);
        }

        List<BigDecimal> list = new ArrayList<BigDecimal>();
        list.add(stop_loss);
        list.add(take_profit);

        return list;
    }

    public static List<BigDecimal> get_amp_fr_to(BigDecimal init_price, BigDecimal amp_w, BigDecimal curr_price) {
        List<BigDecimal> list = new ArrayList<BigDecimal>();

        BigDecimal high = init_price.subtract(curr_price).abs();
        int count = high.divide(amp_w, 10, RoundingMode.CEILING).intValue() + 5;
        boolean is_count_up = init_price.compareTo(curr_price) < 0;

        BigDecimal amp_fr = BigDecimal.ZERO;
        BigDecimal amp_to = BigDecimal.ZERO;

        for (int idx = 0; idx < count; idx++) {
            if (is_count_up) {
                amp_fr = init_price.add(amp_w.multiply(BigDecimal.valueOf(idx)));
                amp_to = init_price.add(amp_w.multiply(BigDecimal.valueOf(idx + 1)));
            } else {
                amp_fr = init_price.subtract(amp_w.multiply(BigDecimal.valueOf(idx + 1)));
                amp_to = init_price.subtract(amp_w.multiply(BigDecimal.valueOf(idx)));
            }

            if ((amp_fr.compareTo(curr_price) <= 0) && (curr_price.compareTo(amp_to) <= 0)) {

                break;
            }
        }

        list.add(amp_fr);
        list.add(amp_to);

        return list;
    }

    public static String contact_with_pivot(DailyRange dailyRange) {
        if (Objects.isNull(dailyRange)) {
            return "";
        }

        BigDecimal wast = dailyRange.getAvg_amp_week().multiply(BigDecimal.valueOf(0.1));

        if ((dailyRange.getAmp_fr().subtract(wast).compareTo(dailyRange.getCurr_price()) < 0)
                && (dailyRange.getCurr_price().compareTo(dailyRange.getAmp_fr().add(wast)) < 0)) {

            return TEXT_PIVOT_FR;
        }

        if ((dailyRange.getAmp_to().subtract(wast).compareTo(dailyRange.getCurr_price()) < 0)
                && (dailyRange.getCurr_price().compareTo(dailyRange.getAmp_to().add(wast)) < 0)) {

            return TEXT_PIVOT_TO;
        }

        return "";
    }

    public static Mt5OpenTrade calc_Lot_En_SL_TP(String EPIC, String find_trend, Orders dto_h4, String append,
            boolean isTradeNow, String CAPITAL_TIME_XX, DailyRange dailyRange, int total_trade) {

        if (Utils.isBlank(find_trend)) {
            return null;
        }
        BigDecimal curr_price = dto_h4.getCurrent_price();
        BigDecimal entry_1 = BigDecimal.ZERO;
        BigDecimal entry_2 = BigDecimal.ZERO;
        BigDecimal entry_3 = BigDecimal.ZERO;

        List<BigDecimal> sl_tp = Utils.get_SL_TP_by_amp(dailyRange, curr_price, find_trend);
        BigDecimal stop_loss = sl_tp.get(0);
        BigDecimal take_profit = sl_tp.get(1);

        BigDecimal sl_calc = BigDecimal.ZERO;
        if (Objects.equals(find_trend, Utils.TREND_LONG)) {
            sl_calc = dto_h4.getSl_long();
        }
        if (Objects.equals(find_trend, Utils.TREND_SHOT)) {
            sl_calc = dto_h4.getSl_shot();
        }

        MoneyAtRiskResponse calc_vol = new MoneyAtRiskResponse(EPIC, RISK, curr_price, sl_calc, take_profit);

        BigDecimal volume = calc_vol.calcLot();
        String type = Objects.equals(find_trend, Utils.TREND_LONG) ? "_b" : "_s";

        // take_profit = BigDecimal.ZERO;
        Mt5OpenTrade dto = new Mt5OpenTrade();

        dto.setEpic(EPIC);
        dto.setOrder_type(find_trend.toLowerCase() + (isTradeNow ? "" : TEXT_LIMIT));
        dto.setCur_price(curr_price);
        dto.setLots(volume);
        dto.setEntry1(entry_1);
        dto.setStop_loss(stop_loss);
        dto.setTake_profit1(take_profit);
        dto.setComment(create_trade_comment(EPIC, CAPITAL_TIME_XX, type + append));
        dto.setEntry2(entry_2);
        dto.setEntry3(entry_3);
        dto.setTake_profit2(take_profit);
        dto.setTake_profit3(take_profit);
        dto.setTotal_trade(total_trade);

        return dto;
    }

    public static String create_trade_comment(String EPIC, String CAPITAL_TIME_XX, String append) {
        String comment = BscScanBinanceApplication.hostname + getTime_day24Hmm()
                + append.trim().replace(Utils.TEXT_PASS, "") + getEncryptedChartNameCapital(CAPITAL_TIME_XX);

        return comment.toLowerCase();
    }

    public static String calc_BUF_LO_HI_BUF_Forex(BigDecimal risk, boolean onlyWait, String find_switch_trend,
            String EPIC, BigDecimal curr_price, DailyRange dailyRange) {
        String result = "";

        BigDecimal amp = dailyRange.getAvg_amp_week();
        BigDecimal low = curr_price.subtract(amp);
        BigDecimal hig = curr_price.add(amp);

        String str_long = calc_BUF_Long_Forex(onlyWait, risk, EPIC, curr_price, curr_price, low, hig, "", "");
        String str_shot = calc_BUF_Shot_Forex(onlyWait, risk, EPIC, curr_price, curr_price, hig, low, "", "");

        if (Objects.equals(find_switch_trend, Utils.TREND_LONG)) {
            result += str_long;
        } else if (Objects.equals(find_switch_trend, Utils.TREND_SHOT)) {
            result += str_shot;
        } else {
            result += Utils.appendSpace("", 20);
        }

        return result;
    }

    public static String getTimeframeTrading(String trend_d1, String trend_h4, String trend_h1, String note_d1,
            String note_h4, String note_h1) {

        if (note_h4.contains(trend_d1) || Objects.equals(trend_d1, trend_h4) || Objects.equals(trend_h4, trend_h1)) {
            return Utils.CAPITAL_TIME_H4;
        }
        if (note_h1.contains(trend_d1) || Objects.equals(trend_d1, trend_h1)) {
            return Utils.CAPITAL_TIME_H1;
        }
        if (note_d1.contains(trend_d1)) {
            return Utils.CAPITAL_TIME_D1;
        }
        return Utils.CAPITAL_TIME_H1;
    }

    public static String getTrendPrefix(String chart_name, String note, String append) {
        String type = " ";
        if (note.contains(TREND_LONG)) {
            type = chart_name + "~B" + append;
        } else if (note.contains(TREND_SHOT)) {
            type = chart_name + "~S" + append;
        } else {
            type = appendSpace("", chart_name.length()) + "  " + appendSpace("", append.length());
        }

        return type;
    }

    public static boolean is_price_still_be_trade(Orders dto_xx, BigDecimal amplitude_week, String find_trend) {
        BigDecimal current_price = dto_xx.getCurrent_price();

        if (Objects.equals(find_trend, Utils.TREND_LONG)) {
            BigDecimal tp_price = current_price.add(amplitude_week);

            // Còn biên độ trung bình để đạt TP.
            if (tp_price.compareTo(dto_xx.getBody_hig_50_candle()) < 0) {
                return true;
            }

        }

        if (Objects.equals(find_trend, Utils.TREND_SHOT)) {
            BigDecimal tp_price = current_price.subtract(amplitude_week);

            // Còn biên độ trung bình để đạt TP.
            if (tp_price.compareTo(dto_xx.getBody_low_50_candle()) > 0) {
                return true;
            }
        }

        return false;
    }

    public static String get_cutting_real_time(String find_trend, Orders dto_03, BigDecimal dto_d1_ma_xx,
            String prefix_D1Ma10) {
        String cutting = "";
        if (Objects.equals(Utils.TREND_LONG, find_trend)) {
            String temp = "";

            temp = Utils.checkXCutUpY(dto_03.getClose_candle_1(), dto_03.getClose_candle_2(), dto_d1_ma_xx,
                    dto_d1_ma_xx);

            if (Utils.isNotBlank(temp)) {
                cutting += " " + getChartNameCapital(dto_03.getId()) + "vs" + prefix_D1Ma10 + ":"
                        + Utils.appendSpace(temp, 5);
            }
        }

        if (Objects.equals(Utils.TREND_SHOT, find_trend)) {
            String temp = "";

            temp = Utils.checkXCutDnY(dto_03.getClose_candle_1(), dto_03.getClose_candle_2(), dto_d1_ma_xx,
                    dto_d1_ma_xx);

            if (Utils.isNotBlank(temp)) {
                cutting += " " + getChartNameCapital(dto_03.getId()) + "vs" + prefix_D1Ma10 + ":"
                        + Utils.appendSpace(temp, 5);
            }
        }

        return cutting;
    }

    public static String switch_trend_real_time_by_trend_d1(String EPIC, Orders dto_d1, Orders dto_h4, Orders dto_h1,
            Orders dto_15, Orders dto_10, Orders dto_05, Orders dto_03) {

        String trend_d1 = dto_d1.getTrend_by_heiken();
        String trend_h4 = dto_h4.getTrend_by_heiken();
        String trend_h1 = dto_h1.getTrend_by_heiken();

        if (!(Objects.equals(trend_d1, dto_15.getTrend_by_heiken())
                || Objects.equals(trend_d1, dto_10.getTrend_by_heiken())
                || Objects.equals(trend_d1, dto_05.getTrend_by_heiken()))) {
            return "";
        }

        String cutting = "";
        boolean switch_trend_real_time = false;

        if (Objects.equals(Utils.TREND_LONG, trend_d1)) {
            String temp = "";

            if (Objects.equals(trend_d1, trend_h1)) {
                temp = Utils.checkXCutUpY(dto_03.getClose_candle_1(), dto_03.getClose_candle_2(), dto_d1.getMa9(),
                        dto_d1.getMa9());
                if (Utils.isNotBlank(temp)) {
                    cutting += " 03vsD1Ma10:" + Utils.appendSpace(temp, 5);
                }

                temp = Utils.checkXCutUpY(dto_05.getClose_candle_1(), dto_05.getClose_candle_2(), dto_d1.getMa9(),
                        dto_d1.getMa9());
                if (Utils.isNotBlank(temp))
                    cutting += " 05vsD1Ma10:" + Utils.appendSpace(temp, 5);

                temp = Utils.checkXCutUpY(dto_10.getClose_candle_1(), dto_10.getClose_candle_2(), dto_d1.getMa9(),
                        dto_d1.getMa9());
                if (Utils.isNotBlank(temp))
                    cutting += " 10vsD1Ma10:" + Utils.appendSpace(temp, 5);

                temp = Utils.checkXCutUpY(dto_15.getClose_candle_1(), dto_15.getClose_candle_2(), dto_d1.getMa9(),
                        dto_d1.getMa9());
                if (Utils.isNotBlank(temp))
                    cutting += " 15vsD1Ma10:" + Utils.appendSpace(temp, 5);
            }

            // ------------------------------------------------------------------------------
            if (Objects.equals(trend_d1, trend_h4) && Objects.equals(trend_d1, trend_h1)) {

                // temp = Utils.checkXCutUpY(dto_03.getClose_candle_1(),
                // dto_03.getClose_candle_2(), dto_h4.getMa50(),
                // dto_h4.getMa50());
                // if (Utils.isNotBlank(temp))
                // cutting += " 03vsH4Ma50:" + Utils.appendSpace(temp, 5);
                //
                // temp = Utils.checkXCutUpY(dto_05.getClose_candle_1(),
                // dto_05.getClose_candle_2(), dto_h4.getMa50(),
                // dto_h4.getMa50());
                // if (Utils.isNotBlank(temp))
                // cutting += " 05vsH4Ma50:" + Utils.appendSpace(temp, 5);
                //
                // temp = Utils.checkXCutUpY(dto_10.getClose_candle_1(),
                // dto_10.getClose_candle_2(), dto_h4.getMa50(),
                // dto_h4.getMa50());
                // if (Utils.isNotBlank(temp))
                // cutting += " 10vsH4Ma50:" + Utils.appendSpace(temp, 5);
                //
                // temp = Utils.checkXCutUpY(dto_15.getClose_candle_1(),
                // dto_15.getClose_candle_2(), dto_h4.getMa50(),
                // dto_h4.getMa50());
                // if (Utils.isNotBlank(temp))
                // cutting += " 15vsH4Ma50:" + Utils.appendSpace(temp, 5);

                // ------------------------------------------------------------------------------

                // temp = Utils.checkXCutUpY(dto_03.getClose_candle_1(),
                // dto_03.getClose_candle_2(), dto_h4.getMa20(),
                // dto_h4.getMa20());
                // if (Utils.isNotBlank(temp))
                // cutting += " 03vsH4Ma20:" + Utils.appendSpace(temp, 5);
                //
                // temp = Utils.checkXCutUpY(dto_05.getClose_candle_1(),
                // dto_05.getClose_candle_2(), dto_h4.getMa20(),
                // dto_h4.getMa20());
                // if (Utils.isNotBlank(temp))
                // cutting += " 05vsH4Ma20:" + Utils.appendSpace(temp, 5);
                //
                // temp = Utils.checkXCutUpY(dto_10.getClose_candle_1(),
                // dto_10.getClose_candle_2(), dto_h4.getMa20(),
                // dto_h4.getMa20());
                // if (Utils.isNotBlank(temp))
                // cutting += " 10vsH4Ma20:" + Utils.appendSpace(temp, 5);
                //
                // temp = Utils.checkXCutUpY(dto_15.getClose_candle_1(),
                // dto_15.getClose_candle_2(), dto_h4.getMa20(),
                // dto_h4.getMa20());
                // if (Utils.isNotBlank(temp))
                // cutting += " 15vsH4Ma20:" + Utils.appendSpace(temp, 5);
            }
            // ------------------------------------------------------------------------------
            /*
             * if (Objects.equals(trend_d1, dto_d1.getTrend_by_ma_9()) ||
             * Objects.equals(trend_d1, dto_d1.getTrend_by_heiken_1())) {
             *
             * if (Objects.equals(Utils.TREND_LONG, trend_h4) && Objects.equals(trend_h4,
             * trend_h1)) { temp = Utils.checkXCutUpY(dto_03.getClose_candle_1(),
             * dto_03.getClose_candle_2(), dto_h4.getMa9(), dto_h4.getMa9()); if
             * (Utils.isNotBlank(temp)) cutting += " 03vsH4Ma10:" + Utils.appendSpace(temp,
             * 5);
             *
             * temp = Utils.checkXCutUpY(dto_05.getClose_candle_1(),
             * dto_05.getClose_candle_2(), dto_h4.getMa9(), dto_h4.getMa9()); if
             * (Utils.isNotBlank(temp)) cutting += " 05vsH4Ma10:" + Utils.appendSpace(temp,
             * 5);
             *
             * temp = Utils.checkXCutUpY(dto_10.getClose_candle_1(),
             * dto_10.getClose_candle_2(), dto_h4.getMa9(), dto_h4.getMa9()); if
             * (Utils.isNotBlank(temp)) cutting += " 10vsH4Ma10:" + Utils.appendSpace(temp,
             * 5);
             *
             * temp = Utils.checkXCutUpY(dto_15.getClose_candle_1(),
             * dto_15.getClose_candle_2(), dto_h4.getMa9(), dto_h4.getMa9()); if
             * (Utils.isNotBlank(temp)) cutting += " 15vsH4Ma10:" + Utils.appendSpace(temp,
             * 5); }
             *
             * //
             * -----------------------------------------------------------------------------
             * - if (Objects.equals(trend_d1, trend_h1) && Objects.equals(trend_d1,
             * trend_h4) && Objects.equals(trend_d1, dto_h4.getTrend_by_heiken_1()) &&
             * Objects.equals(trend_d1, dto_h4.getTrend_by_ma_9())) {
             *
             * temp = Utils.checkXCutUpY(dto_03.getClose_candle_1(),
             * dto_03.getClose_candle_2(), dto_h1.getMa50(), dto_h1.getMa50()); if
             * (Utils.isNotBlank(temp)) cutting += " 03vsH1Ma20:" + Utils.appendSpace(temp,
             * 5);
             *
             * temp = Utils.checkXCutUpY(dto_05.getClose_candle_1(),
             * dto_05.getClose_candle_2(), dto_h1.getMa50(), dto_h1.getMa50()); if
             * (Utils.isNotBlank(temp)) cutting += " 05vsH1Ma20:" + Utils.appendSpace(temp,
             * 5);
             *
             * temp = Utils.checkXCutUpY(dto_10.getClose_candle_1(),
             * dto_10.getClose_candle_2(), dto_h1.getMa50(), dto_h1.getMa50()); if
             * (Utils.isNotBlank(temp)) cutting += " 10vsH1Ma20:" + Utils.appendSpace(temp,
             * 5);
             *
             * temp = Utils.checkXCutUpY(dto_15.getClose_candle_1(),
             * dto_15.getClose_candle_2(), dto_h1.getMa50(), dto_h1.getMa50()); if
             * (Utils.isNotBlank(temp)) cutting += " 15vsH1Ma20:" + Utils.appendSpace(temp,
             * 5); } }
             */
            if (cutting.contains(Utils.TREND_LONG) && !cutting.contains(Utils.TREND_SHOT)) {
                switch_trend_real_time = true;
            }
        }

        // --------------------------------------------------------------------------------------------
        // --------------------------------------------------------------------------------------------
        // --------------------------------------------------------------------------------------------

        if (Objects.equals(Utils.TREND_SHOT, trend_d1)) {
            String temp = "";

            if (Objects.equals(trend_d1, trend_h1)) {
                temp = Utils.checkXCutDnY(dto_03.getClose_candle_1(), dto_03.getClose_candle_2(), dto_d1.getMa9(),
                        dto_d1.getMa9());
                if (Utils.isNotBlank(temp))
                    cutting += " 03vsD1Ma10:" + Utils.appendSpace(temp, 5);

                temp = Utils.checkXCutDnY(dto_05.getClose_candle_1(), dto_05.getClose_candle_2(), dto_d1.getMa9(),
                        dto_d1.getMa9());
                if (Utils.isNotBlank(temp))
                    cutting += " 05vsD1Ma10:" + Utils.appendSpace(temp, 5);

                temp = Utils.checkXCutDnY(dto_10.getClose_candle_1(), dto_10.getClose_candle_2(), dto_d1.getMa9(),
                        dto_d1.getMa9());
                if (Utils.isNotBlank(temp))
                    cutting += " 10vsD1Ma10:" + Utils.appendSpace(temp, 5);

                temp = Utils.checkXCutDnY(dto_15.getClose_candle_1(), dto_15.getClose_candle_2(), dto_d1.getMa9(),
                        dto_d1.getMa9());
                if (Utils.isNotBlank(temp))
                    cutting += " 15vsD1Ma10:" + Utils.appendSpace(temp, 5);
            }

            // ------------------------------------------------------------------------------
            if (Objects.equals(trend_d1, trend_h4) && Objects.equals(trend_d1, trend_h1)) {
                // temp = Utils.checkXCutDnY(dto_03.getClose_candle_1(),
                // dto_03.getClose_candle_2(), dto_h4.getMa50(),
                // dto_h4.getMa50());
                // if (Utils.isNotBlank(temp))
                // cutting += " 03vsH4Ma50:" + Utils.appendSpace(temp, 5);
                //
                // temp = Utils.checkXCutDnY(dto_05.getClose_candle_1(),
                // dto_05.getClose_candle_2(), dto_h4.getMa50(),
                // dto_h4.getMa50());
                // if (Utils.isNotBlank(temp))
                // cutting += " 05vsH4Ma50:" + Utils.appendSpace(temp, 5);
                //
                // temp = Utils.checkXCutDnY(dto_10.getClose_candle_1(),
                // dto_10.getClose_candle_2(), dto_h4.getMa50(),
                // dto_h4.getMa50());
                // if (Utils.isNotBlank(temp))
                // cutting += " 10vsH4Ma50:" + Utils.appendSpace(temp, 5);
                //
                // temp = Utils.checkXCutDnY(dto_15.getClose_candle_1(),
                // dto_15.getClose_candle_2(), dto_h4.getMa50(),
                // dto_h4.getMa50());
                // if (Utils.isNotBlank(temp))
                // cutting += " 15vsH4Ma50:" + Utils.appendSpace(temp, 5);
                // ------------------------------------------------------------------------------

                // temp = Utils.checkXCutDnY(dto_03.getClose_candle_1(),
                // dto_03.getClose_candle_2(), dto_h4.getMa20(),
                // dto_h4.getMa20());
                // if (Utils.isNotBlank(temp))
                // cutting += " 03vsH4Ma20:" + Utils.appendSpace(temp, 5);
                //
                // temp = Utils.checkXCutDnY(dto_05.getClose_candle_1(),
                // dto_05.getClose_candle_2(), dto_h4.getMa20(),
                // dto_h4.getMa20());
                // if (Utils.isNotBlank(temp))
                // cutting += " 05vsH4Ma20:" + Utils.appendSpace(temp, 5);
                //
                // temp = Utils.checkXCutDnY(dto_10.getClose_candle_1(),
                // dto_10.getClose_candle_2(), dto_h4.getMa20(),
                // dto_h4.getMa20());
                // if (Utils.isNotBlank(temp))
                // cutting += " 10vsH4Ma20:" + Utils.appendSpace(temp, 5);
                //
                // temp = Utils.checkXCutDnY(dto_15.getClose_candle_1(),
                // dto_15.getClose_candle_2(), dto_h4.getMa20(),
                // dto_h4.getMa20());
                // if (Utils.isNotBlank(temp))
                // cutting += " 15vsH4Ma20:" + Utils.appendSpace(temp, 5);
            }

            // ------------------------------------------------------------------------------
            /*
             * if (Objects.equals(trend_d1, dto_d1.getTrend_by_ma_9()) ||
             * Objects.equals(trend_d1, dto_d1.getTrend_by_heiken_1())) {
             *
             * if (Objects.equals(Utils.TREND_SHOT, trend_h4) && Objects.equals(trend_h4,
             * trend_h1)) { temp = Utils.checkXCutDnY(dto_03.getClose_candle_1(),
             * dto_03.getClose_candle_2(), dto_h4.getMa9(), dto_h4.getMa9()); if
             * (Utils.isNotBlank(temp)) cutting += " 03vsH4Ma10:" + Utils.appendSpace(temp,
             * 5);
             *
             * temp = Utils.checkXCutDnY(dto_05.getClose_candle_1(),
             * dto_05.getClose_candle_2(), dto_h4.getMa9(), dto_h4.getMa9()); if
             * (Utils.isNotBlank(temp)) cutting += " 05vsH4Ma10:" + Utils.appendSpace(temp,
             * 5);
             *
             * temp = Utils.checkXCutDnY(dto_10.getClose_candle_1(),
             * dto_10.getClose_candle_2(), dto_h4.getMa9(), dto_h4.getMa9()); if
             * (Utils.isNotBlank(temp)) cutting += " 10vsH4Ma10:" + Utils.appendSpace(temp,
             * 5);
             *
             * temp = Utils.checkXCutDnY(dto_15.getClose_candle_1(),
             * dto_15.getClose_candle_2(), dto_h4.getMa9(), dto_h4.getMa9()); if
             * (Utils.isNotBlank(temp)) cutting += " 15vsH4Ma10:" + Utils.appendSpace(temp,
             * 5); }
             *
             * //
             * -----------------------------------------------------------------------------
             * -
             *
             * if (Objects.equals(trend_d1, trend_h1) && Objects.equals(trend_d1, trend_h4)
             * && Objects.equals(trend_d1, dto_h4.getTrend_by_heiken_1()) &&
             * Objects.equals(trend_d1, dto_h4.getTrend_by_ma_9())) {
             *
             * temp = Utils.checkXCutDnY(dto_03.getClose_candle_1(),
             * dto_03.getClose_candle_2(), dto_h1.getMa50(), dto_h1.getMa50()); if
             * (Utils.isNotBlank(temp)) cutting += " 03vsH1Ma20:" + Utils.appendSpace(temp,
             * 5);
             *
             * temp = Utils.checkXCutDnY(dto_05.getClose_candle_1(),
             * dto_05.getClose_candle_2(), dto_h1.getMa50(), dto_h1.getMa50()); if
             * (Utils.isNotBlank(temp)) cutting += " 05vsH1Ma20:" + Utils.appendSpace(temp,
             * 5);
             *
             * temp = Utils.checkXCutDnY(dto_10.getClose_candle_1(),
             * dto_10.getClose_candle_2(), dto_h1.getMa50(), dto_h1.getMa50()); if
             * (Utils.isNotBlank(temp)) cutting += " 10vsH1Ma20:" + Utils.appendSpace(temp,
             * 5);
             *
             * temp = Utils.checkXCutDnY(dto_15.getClose_candle_1(),
             * dto_15.getClose_candle_2(), dto_h1.getMa50(), dto_h1.getMa50()); if
             * (Utils.isNotBlank(temp)) cutting += " 15vsH1Ma20:" + Utils.appendSpace(temp,
             * 5); } }
             */
            if (cutting.contains(Utils.TREND_SHOT) && !cutting.contains(Utils.TREND_LONG)) {
                switch_trend_real_time = true;
            }
        }

        if (switch_trend_real_time)

        {
            String append = "";
            if (cutting.contains("D1Ma10")) {
                append += "24_10";
            } else if (cutting.contains("H4Ma50")) {
                append += "04_50";
            } else if (cutting.contains("H4Ma20")) {
                append += "04_20";
            } else if (cutting.contains("H4Ma10")) {
                append += "04_10";
            } else if (cutting.contains("H1Ma20")) {
                append += "01_20";
            }

            Utils.logWritelnDraft(Utils.appendSpace(EPIC, 10) + Utils.appendSpace(trend_d1, 10)
                    + Utils.appendSpace(get_standard_vol_per_100usd(EPIC), 10) + Utils.appendSpace(append, 10)
                    + Utils.appendSpace(Utils.getCapitalLink(EPIC), 62) + cutting);

            return append;
        }

        return "";
    }

    public static String get_seq(Orders dto_h1, Orders dto_15, Orders dto_10, Orders dto_05, Orders dto_03) {
        String seq = "{";
        boolean has_seq = false;
        boolean has_seq_h1 = false;
        boolean has_seq_minus = false;
        String trend_h1 = dto_h1.getTrend_by_heiken();

        if (dto_h1.getSwitch_trend().contains(Utils.TEXT_SEQ)
                && dto_15.getSwitch_trend().contains(dto_15.getTrend_by_heiken())
                && dto_h1.getSwitch_trend().contains(trend_h1)) {
            has_seq = true;
            has_seq_h1 = true;
            seq += "h1" + getType(trend_h1);
        } else {
            seq += "   ";
        }
        seq += " ";

        if (dto_15.getTrend_by_seq_ma().contains(Utils.TEXT_SEQ) && dto_15.getTrend_by_seq_ma().contains(trend_h1)
                && dto_15.getTrend_by_seq_ma().contains(dto_15.getTrend_by_ma_9())) {
            has_seq = true;
            has_seq_minus = true;
            seq += "15" + getType(dto_15.getTrend_by_ma_9());
        } else {
            seq += "   ";
        }

        if (dto_10.getTrend_by_seq_ma().contains(Utils.TEXT_SEQ) && dto_10.getTrend_by_seq_ma().contains(trend_h1)
                && dto_10.getTrend_by_seq_ma().contains(dto_10.getTrend_by_ma_9())) {
            has_seq = true;
            has_seq_minus = true;
            seq += "10" + getType(dto_10.getTrend_by_ma_9());
        } else {
            seq += "   ";
        }

        if (dto_05.getTrend_by_seq_ma().contains(Utils.TEXT_SEQ) && dto_05.getTrend_by_seq_ma().contains(trend_h1)
                && dto_05.getTrend_by_seq_ma().contains(dto_05.getTrend_by_ma_9())) {
            has_seq = true;
            has_seq_minus = true;
            seq += "05" + getType(dto_05.getTrend_by_ma_9());
        } else {
            seq += "   ";
        }

        if (dto_03.getTrend_by_seq_ma().contains(Utils.TEXT_SEQ) && dto_03.getTrend_by_seq_ma().contains(trend_h1)
                && dto_03.getTrend_by_seq_ma().contains(dto_03.getTrend_by_ma_9())) {
            has_seq = true;
            has_seq_minus = true;
            seq += "03" + getType(dto_03.getTrend_by_ma_9());
        } else {
            seq += "   ";
        }
        seq += "}";

        if (!has_seq) {
            seq = "{" + appendSpace("", seq.length() - 2) + "}";
        } else {
            if (!has_seq_h1 && has_seq_minus) {
                seq = seq.replace("{   ", "{" + getType(trend_h1) + "  ");
            }
        }

        return " " + seq.trim() + "   ";
    }

    public static boolean is_better_price(String trend_6_10_20, BigDecimal curr_price, List<TakeProfit> his_list,
            DailyRange dailyRange) {

        if (CollectionUtils.isEmpty(his_list)) {
            return false;
        }

        boolean result = true;

        for (TakeProfit ido : his_list) {
            BigDecimal before_price = ido.getOpenPrice();

            if (Objects.equals(trend_6_10_20, Utils.TREND_LONG)) {
                // Tồn tại trade nào giá nhỏ hơn thì chưa phải giá tốt nhất.
                if (curr_price.compareTo(before_price) > 0) {
                    result = false;
                }
            }

            if (Objects.equals(trend_6_10_20, Utils.TREND_SHOT)) {
                // Tồn tại trade nào giá lớn hơn thì chưa phải giá tốt nhất.
                if (curr_price.compareTo(before_price) < 0) {
                    result = false;
                }
            }
        }

        return result;
    }

    public static String trend_possion_when_price_touches_BB_D1(DailyRange dailyRange, BigDecimal curr_price) {
        String trend = "";

        BigDecimal h41_upper = dailyRange.getUpper_d1();
        BigDecimal h41_lower = dailyRange.getLower_d1();

        if (curr_price.compareTo(h41_lower) < 0) {
            trend = Utils.TREND_LONG;
        }

        if (curr_price.compareTo(h41_upper) > 0) {
            trend = Utils.TREND_SHOT;
        }

        return trend;
    }

    public static String find_trend_by_ma3_6_9(Orders dto_xx) {
        if (Objects.equals(Utils.TREND_LONG, dto_xx.getTrend_by_ma_6())
                && Objects.equals(Utils.TREND_LONG, dto_xx.getTrend_by_ma_9())
                && (dto_xx.getMa3().compareTo(dto_xx.getMa9()) > 0)
                && (dto_xx.getMa3().compareTo(dto_xx.getMa6()) > 0)) {
            return Utils.TREND_LONG;
        }
        if (Objects.equals(Utils.TREND_LONG, dto_xx.getTrend_by_ma_6())
                && Objects.equals(Utils.TREND_LONG, dto_xx.getTrend_by_ma_9())
                && Objects.equals(Utils.TREND_LONG, dto_xx.getTrend_by_ma_20())
                && Objects.equals(Utils.TREND_LONG, dto_xx.getTrend_by_heiken())) {
            return Utils.TREND_LONG;
        }
        // ---------------------------------------------------------------
        if (Objects.equals(Utils.TREND_SHOT, dto_xx.getTrend_by_ma_6())
                && Objects.equals(Utils.TREND_SHOT, dto_xx.getTrend_by_ma_9())
                && (dto_xx.getMa3().compareTo(dto_xx.getMa9()) < 0)
                && (dto_xx.getMa3().compareTo(dto_xx.getMa6()) < 0)) {
            return Utils.TREND_SHOT;
        }
        if (Objects.equals(Utils.TREND_SHOT, dto_xx.getTrend_by_ma_6())
                && Objects.equals(Utils.TREND_SHOT, dto_xx.getTrend_by_ma_9())
                && Objects.equals(Utils.TREND_SHOT, dto_xx.getTrend_by_ma_20())
                && Objects.equals(Utils.TREND_SHOT, dto_xx.getTrend_by_heiken())) {
            return Utils.TREND_SHOT;
        }
        // ---------------------------------------------------------------
        return Utils.TREND_UNSURE + "_" + dto_xx.getId();
    }

    public static boolean is_best_price(Orders dto_05, String find_trend, BigDecimal curr_price) {
        boolean is_best_prirce = false;
        if (Objects.equals(Utils.TREND_LONG, find_trend)) {
            if (curr_price.compareTo(dto_05.getBody_low_50_candle()) < 0) {
                is_best_prirce = true;
            }
        }
        if (Objects.equals(Utils.TREND_SHOT, find_trend)) {
            if (curr_price.compareTo(dto_05.getBody_hig_50_candle()) > 0) {
                is_best_prirce = true;
            }
        }
        return is_best_prirce;
    }

    public static List<BigDecimal> get_price_ampw_lotsize(String EPIC) {
        BigDecimal i_top_price = BigDecimal.ZERO;
        BigDecimal amp_w = BigDecimal.ZERO;
        BigDecimal lot_size_per_500usd = BigDecimal.ZERO;

        if (Objects.equals(EPIC, "BTCUSD")) {
            i_top_price = BigDecimal.valueOf(36285);
            amp_w = BigDecimal.valueOf(1060.00);
            lot_size_per_500usd = BigDecimal.valueOf(0.45);
        }
        if (Objects.equals(EPIC, "DX")) {
            i_top_price = BigDecimal.valueOf(106.8);
            amp_w = BigDecimal.valueOf(0.69500);
            lot_size_per_500usd = BigDecimal.valueOf(7.00);
        }
        if (Objects.equals(EPIC, "USOIL")) {
            i_top_price = BigDecimal.valueOf(99.85);
            amp_w = BigDecimal.valueOf(2.50000);
            lot_size_per_500usd = BigDecimal.valueOf(1.75);
        }
        if (Objects.equals(EPIC, "XAGUSD")) {
            i_top_price = BigDecimal.valueOf(28.380);
            amp_w = BigDecimal.valueOf(0.63500);
            lot_size_per_500usd = BigDecimal.valueOf(0.15);
        }
        if (Objects.equals(EPIC, "XAUUSD")) {
            i_top_price = BigDecimal.valueOf(2088);
            amp_w = BigDecimal.valueOf(22.9500);
            lot_size_per_500usd = BigDecimal.valueOf(0.20);
        }

        if (Objects.equals(EPIC, "US100")) {
            i_top_price = BigDecimal.valueOf(15920);
            amp_w = BigDecimal.valueOf(271.500);
            lot_size_per_500usd = BigDecimal.valueOf(1.75);
        }
        if (Objects.equals(EPIC, "US30")) {
            i_top_price = BigDecimal.valueOf(35700);
            amp_w = BigDecimal.valueOf(388.350);
            lot_size_per_500usd = BigDecimal.valueOf(1.00);
        }

        if (Objects.equals(EPIC, "AUDJPY")) {
            i_top_price = BigDecimal.valueOf(98.6500);
            amp_w = BigDecimal.valueOf(1.07795);
            lot_size_per_500usd = BigDecimal.valueOf(0.65);
        }
        if (Objects.equals(EPIC, "AUDUSD")) {
            i_top_price = BigDecimal.valueOf(0.72000);
            amp_w = BigDecimal.valueOf(0.00765);
            lot_size_per_500usd = BigDecimal.valueOf(0.65);
        }
        if (Objects.equals(EPIC, "EURAUD")) {
            i_top_price = BigDecimal.valueOf(1.73000);
            amp_w = BigDecimal.valueOf(0.01375);
            lot_size_per_500usd = BigDecimal.valueOf(0.50);
        }
        if (Objects.equals(EPIC, "EURGBP")) {
            i_top_price = BigDecimal.valueOf(0.88585);
            amp_w = BigDecimal.valueOf(0.00455);
            lot_size_per_500usd = BigDecimal.valueOf(0.90);
        }
        if (Objects.equals(EPIC, "EURUSD")) {
            i_top_price = BigDecimal.valueOf(1.12500);
            amp_w = BigDecimal.valueOf(0.00790);
            lot_size_per_500usd = BigDecimal.valueOf(0.60);
        }
        if (Objects.equals(EPIC, "GBPUSD")) {
            i_top_price = BigDecimal.valueOf(1.31365);
            amp_w = BigDecimal.valueOf(0.01085);
            lot_size_per_500usd = BigDecimal.valueOf(0.45);
        }
        if (Objects.equals(EPIC, "USDCAD")) {
            i_top_price = BigDecimal.valueOf(1.40775);
            amp_w = BigDecimal.valueOf(0.00795);
            lot_size_per_500usd = BigDecimal.valueOf(0.85);
        }
        if (Objects.equals(EPIC, "USDCHF")) {
            i_top_price = BigDecimal.valueOf(0.94235);
            amp_w = BigDecimal.valueOf(0.00715);
            lot_size_per_500usd = BigDecimal.valueOf(0.60);
        }
        if (Objects.equals(EPIC, "USDJPY")) {
            i_top_price = BigDecimal.valueOf(154.395);
            amp_w = BigDecimal.valueOf(1.29500);
            lot_size_per_500usd = BigDecimal.valueOf(0.50);
        }

        if (Objects.equals(EPIC, "CADCHF")) {
            i_top_price = BigDecimal.valueOf(0.70200);
            amp_w = BigDecimal.valueOf(0.00500);
            lot_size_per_500usd = BigDecimal.valueOf(0.90);
        }
        if (Objects.equals(EPIC, "CADJPY")) {
            i_top_price = BigDecimal.valueOf(112.000);
            amp_w = BigDecimal.valueOf(1.00000);
            lot_size_per_500usd = BigDecimal.valueOf(0.65);
        }
        if (Objects.equals(EPIC, "CHFJPY")) {
            i_top_price = BigDecimal.valueOf(169.320);
            amp_w = BigDecimal.valueOf(1.41000);
            lot_size_per_500usd = BigDecimal.valueOf(0.45);
        }
        if (Objects.equals(EPIC, "EURJPY")) {
            i_top_price = BigDecimal.valueOf(162.065);
            amp_w = BigDecimal.valueOf(1.39000);
            lot_size_per_500usd = BigDecimal.valueOf(0.45);
        }
        if (Objects.equals(EPIC, "GBPJPY")) {
            i_top_price = BigDecimal.valueOf(188.115);
            amp_w = BigDecimal.valueOf(1.61500);
            lot_size_per_500usd = BigDecimal.valueOf(0.45);
        }
        if (Objects.equals(EPIC, "NZDJPY")) {
            i_top_price = BigDecimal.valueOf(90.7000);
            amp_w = BigDecimal.valueOf(0.90000);
            lot_size_per_500usd = BigDecimal.valueOf(0.70);
        }

        if (Objects.equals(EPIC, "EURCAD")) {
            i_top_price = BigDecimal.valueOf(1.51938);
            amp_w = BigDecimal.valueOf(0.00945);
            lot_size_per_500usd = BigDecimal.valueOf(0.70);
        }
        if (Objects.equals(EPIC, "EURCHF")) {
            i_top_price = BigDecimal.valueOf(1.01016);
            amp_w = BigDecimal.valueOf(0.00455);
            lot_size_per_500usd = BigDecimal.valueOf(1.00);
        }
        if (Objects.equals(EPIC, "EURNZD")) {
            i_top_price = BigDecimal.valueOf(1.89388);
            amp_w = BigDecimal.valueOf(0.01585);
            lot_size_per_500usd = BigDecimal.valueOf(0.50);
        }
        if (Objects.equals(EPIC, "GBPAUD")) {
            i_top_price = BigDecimal.valueOf(2.02830);
            amp_w = BigDecimal.valueOf(0.01605);
            lot_size_per_500usd = BigDecimal.valueOf(0.45);
        }
        if (Objects.equals(EPIC, "GBPCAD")) {
            i_top_price = BigDecimal.valueOf(1.75620);
            amp_w = BigDecimal.valueOf(0.01210);
            lot_size_per_500usd = BigDecimal.valueOf(0.55);
        }
        if (Objects.equals(EPIC, "GBPCHF")) {
            i_top_price = BigDecimal.valueOf(1.16955);
            amp_w = BigDecimal.valueOf(0.00685);
            lot_size_per_500usd = BigDecimal.valueOf(0.65);
        }
        if (Objects.equals(EPIC, "GBPNZD")) {
            i_top_price = BigDecimal.valueOf(2.18685);
            amp_w = BigDecimal.valueOf(0.01705);
            lot_size_per_500usd = BigDecimal.valueOf(0.45);
        }

        if (Objects.equals(EPIC, "AUDCAD")) {
            i_top_price = BigDecimal.valueOf(0.94763);
            amp_w = BigDecimal.valueOf(0.00735);
            lot_size_per_500usd = BigDecimal.valueOf(0.90);
        }
        if (Objects.equals(EPIC, "AUDCHF")) {
            i_top_price = BigDecimal.valueOf(0.65518);
            amp_w = BigDecimal.valueOf(0.00545);
            lot_size_per_500usd = BigDecimal.valueOf(0.85);
        }
        if (Objects.equals(EPIC, "AUDNZD")) {
            i_top_price = BigDecimal.valueOf(1.11568);
            amp_w = BigDecimal.valueOf(0.00595);
            lot_size_per_500usd = BigDecimal.valueOf(1.25);
        }
        if (Objects.equals(EPIC, "NZDCAD")) {
            i_top_price = BigDecimal.valueOf(0.87860);
            amp_w = BigDecimal.valueOf(0.00725);
            lot_size_per_500usd = BigDecimal.valueOf(0.90);
        }
        if (Objects.equals(EPIC, "NZDCHF")) {
            i_top_price = BigDecimal.valueOf(0.58565);
            amp_w = BigDecimal.valueOf(0.00515);
            lot_size_per_500usd = BigDecimal.valueOf(0.90);
        }
        if (Objects.equals(EPIC, "NZDUSD")) {
            i_top_price = BigDecimal.valueOf(0.65315);
            amp_w = BigDecimal.valueOf(0.00670);
            lot_size_per_500usd = BigDecimal.valueOf(0.70);
        }

        List<BigDecimal> result = new ArrayList<BigDecimal>();
        result.add(i_top_price);
        result.add(amp_w);
        result.add(lot_size_per_500usd);

        return result;
    }

    public static String find_trend_by_15m(Orders dto_15, Orders dto_12, Orders dto_10, Orders dto_03) {
        String trend_15 = dto_15.getTrend_by_ma_6();

        if (Objects.equals(trend_15, dto_15.getTrend_by_ma_6()) && Objects.equals(trend_15, dto_15.getTrend_by_ma_9())

                && Objects.equals(trend_15, dto_12.getTrend_by_ma_6())
                && Objects.equals(trend_15, dto_12.getTrend_by_ma_9())

                && Objects.equals(trend_15, dto_10.getTrend_by_ma_6())
                && Objects.equals(trend_15, dto_10.getTrend_by_ma_9())
                && (Objects.equals(trend_15, dto_10.getTrend_by_ma_20())
                        || Objects.equals(trend_15, dto_10.getTrend_by_seq_ma()))

                && Objects.equals(trend_15, dto_03.getTrend_by_ma_6())
                && Objects.equals(trend_15, dto_03.getTrend_by_ma_9())
                && (Objects.equals(trend_15, dto_03.getTrend_by_ma_20())
                        || Objects.equals(trend_15, dto_03.getTrend_by_seq_ma()))

        ) {
            return trend_15;
        }

        return "";
    }

    public static boolean is_trend_trend_15m_eq(String find_trend, Orders dto_15, Orders dto_10, Orders dto_05,
            Orders dto_03) {

        return Objects.equals(find_trend, dto_15.getTrend_by_heiken())
                && Objects.equals(find_trend, dto_10.getTrend_by_heiken())
                && Objects.equals(find_trend, dto_05.getTrend_by_heiken())
                && Objects.equals(find_trend, dto_03.getTrend_by_heiken());
    }

    public static String get_seq_minus(String find_trend, Orders dto_15, Orders dto_10, Orders dto_05) {
        String seq_m1x = "";
        seq_m1x += dto_15.getSwitch_trend();
        seq_m1x += dto_15.getTrend_by_seq_ma();
        seq_m1x += dto_10.getSwitch_trend();
        seq_m1x += dto_10.getTrend_by_seq_ma();
        seq_m1x += dto_05.getSwitch_trend();
        seq_m1x += dto_05.getTrend_by_seq_ma();

        boolean allow_trade = seq_m1x.contains(Utils.TEXT_SEQ) && seq_m1x.contains(find_trend)
                && Objects.equals(find_trend, dto_15.getTrend_by_heiken())
                && Objects.equals(find_trend, dto_10.getTrend_by_heiken())
                && Objects.equals(find_trend, dto_05.getTrend_by_heiken());

        if (allow_trade) {
            if ((dto_15.getSwitch_trend() + dto_15.getTrend_by_seq_ma()).contains(Utils.TEXT_SEQ)) {
                return getEncryptedChartNameCapital(dto_15.getId());// Utils.ENCRYPTED_15;
            }

            if ((dto_10.getSwitch_trend() + dto_10.getTrend_by_seq_ma()).contains(Utils.TEXT_SEQ)) {
                return getEncryptedChartNameCapital(dto_10.getId());// Utils.ENCRYPTED_10;
            }

            if ((dto_05.getSwitch_trend() + dto_05.getTrend_by_seq_ma()).contains(Utils.TEXT_SEQ)) {
                return getEncryptedChartNameCapital(dto_05.getId());// Utils.ENCRYPTED_05;
            }
        }

        return "";
    }

    public static String get_seq_chart(Orders dto_xx, String find_trend) {
        String result = "";

        if (Objects.equals(dto_xx.getTrend_by_heiken(), find_trend)) {
            String type = "_" + Utils.getType(dto_xx.getTrend_by_heiken()) + "_";

            boolean is_h4 = false;
            String chart_name = getChartName(dto_xx.getId()).toLowerCase().replace("(", "").replace(")", "").trim();
            if (chart_name.contains("h4") || chart_name.contains("d1")) {
                is_h4 = true;
            }
            if (chart_name.contains("h1") && dto_xx.getSwitch_trend().contains(TEXT_SWITCH_TREND_Ma_1vs20)) {
                is_h4 = true;
            }

            if (dto_xx.getSwitch_trend().contains(Utils.TEXT_SEQ)) {
                result = chart_name + type + "sq";
            } else if (is_h4 && Utils.isNotBlank(find_trend) && dto_xx.getSwitch_trend().contains(find_trend)) {
                if (dto_xx.getSwitch_trend().contains(Utils.TEXT_SEQ)) {
                    result = chart_name + type + "sq";
                } else if (dto_xx.getSwitch_trend().contains("(Ma")) {
                    result = chart_name + type + "ma";
                } else if (dto_xx.getSwitch_trend().contains("Heiken")) {
                    result = chart_name + type + "hk";
                } else {
                    result = chart_name + type + "..";
                }
            }
        }

        return Utils.appendSpace(result, 8);
    }

    public static void get_trend_by_macd(List<BtcFutures> list) {
    }

    public static String calc_BUF_Long_Forex(boolean onlyWait, BigDecimal risk_x1, String EPIC, BigDecimal cur_price,
            BigDecimal en_long, BigDecimal sl_long, BigDecimal tp_long, String chartEntry, String chartSL) {
        // BigDecimal risk_x5 = risk_x1.divide(BigDecimal.valueOf(5), 10,
        // RoundingMode.CEILING);

        MoneyAtRiskResponse money_x1_now = new MoneyAtRiskResponse(EPIC, risk_x1, cur_price, sl_long, tp_long);
        // MoneyAtRiskResponse money_x5_now = new MoneyAtRiskResponse(EPIC, risk_x5,
        // cur_price, sl_long, tp_long);

        String temp = "";
        // temp += chartSL + "(Buy ) SL" +
        // Utils.appendLeft(removeLastZero(formatPrice(sl_long, 5)), 10);
        // temp += Utils.appendLeft(removeLastZero(money_x5_now.calcLot()), 8) +
        // "(lot)";
        // temp += "/" + appendLeft(removeLastZero(risk_x5).replace(".0", ""), 4) + "$";
        // // 500$

        temp += Utils.appendLeft(getStringValue(money_x1_now.calcLot()), 8) + "(lot)";
        temp += "/" + appendLeft(removeLastZero(risk_x1).replace(".0", ""), 3) + "$";
        // temp += " E" + Utils.appendLeft(removeLastZero(formatPrice(en_long, 5)), 10);
        String result = Utils.appendSpace(temp, 20);
        return result;
    }

    public static String calc_BUF_Shot_Forex(boolean onlyWait, BigDecimal risk_x1, String EPIC, BigDecimal cur_price,
            BigDecimal en_shot, BigDecimal sl_shot, BigDecimal tp_shot, String chartEntry, String chartSL) {
        // BigDecimal risk_x5 = risk_x1.divide(BigDecimal.valueOf(5), 10,
        // RoundingMode.CEILING);

        MoneyAtRiskResponse money_x1_now = new MoneyAtRiskResponse(EPIC, risk_x1, cur_price, sl_shot, tp_shot);
        // MoneyAtRiskResponse money_x5_now = new MoneyAtRiskResponse(EPIC, risk_x5,
        // cur_price, sl_shot, tp_shot);

        String temp = "";
        // temp += chartSL + "(Sell) SL" +
        // Utils.appendLeft(removeLastZero(formatPrice(sl_shot, 5)), 10);
        // temp += Utils.appendLeft(getStringValue(money_x5_now.calcLot()), 8) +
        // "(lot)";
        // temp += "/" + appendLeft(removeLastZero(risk_x5).replace(".0", ""), 4) + "$";

        temp += Utils.appendLeft(getStringValue(money_x1_now.calcLot()), 8) + "(lot)";
        temp += "/" + appendLeft(removeLastZero(risk_x1).replace(".0", ""), 3) + "$";
        // temp += " E" + Utils.appendLeft(removeLastZero(formatPrice(en_shot, 5)), 10);

        String result = Utils.appendSpace(temp, 20);
        return result;
    }

    public static Mt5Macd MACDCalculator(List<BtcFutures> list, String EPIC, String time_frame) {
        ArrayList<Double> prices = new ArrayList<Double>();

        for (int i = list.size() - 1; i >= 0; i--) {
            BtcFutures dto = list.get(i);

            prices.add(dto.getPrice_close_candle().doubleValue());
        }

        int shortTermPeriod = 3; // EMA short term period
        int longTermPeriod = 6; // EMA long term period
        int signalPeriod = 9; // Signal period

        double[] macds = calculateMACD(prices, shortTermPeriod, longTermPeriod);
        double[] signals = calculateMACDSignal(macds, signalPeriod);

        double macd = macds[macds.length - 1];
        double signal = signals[signals.length - 1];

        double pre_macd = macds[macds.length - 2];
        String pre_macd_vs_zero = "";
        if (pre_macd > 0)
            pre_macd_vs_zero = Utils.TREND_LONG;
        else
            pre_macd_vs_zero = Utils.TREND_SHOT;

        String cur_macd_trend = "";
        if (macds[macds.length - 2] < macds[macds.length - 1])
            cur_macd_trend = Utils.TREND_LONG;
        else
            cur_macd_trend = Utils.TREND_SHOT;

        String trend_macd_vs_signal = "";
        if (macd > signal)
            trend_macd_vs_signal = Utils.TREND_LONG;
        else
            trend_macd_vs_signal = Utils.TREND_SHOT;

        String trend_macd_vs_zero = "";
        if (macd > 0)
            trend_macd_vs_zero = Utils.TREND_LONG;
        else
            trend_macd_vs_zero = Utils.TREND_SHOT;

        double close_price_of_n1_candle = 0;

        int step = 0;
        int count_cur_macd_wave = 0;
        int count_pre_macd_wave = 0;

        for (int index = macds.length - 1; index > 0; index--) {
            double temp_macd = macds[index];

            if (macd > 0) {
                if ((temp_macd > 0) && (step < 2)) {
                    step = 1;

                    count_cur_macd_wave += 1;
                    close_price_of_n1_candle = prices.get(index);
                } else if (temp_macd < 0) {
                    step = 2;

                    count_pre_macd_wave += 1;
                } else {
                    break;
                }
            } else if (macd < 0) {
                if ((temp_macd < 0) && (step < 2)) {
                    step = 1;

                    count_cur_macd_wave += 1;
                    close_price_of_n1_candle = prices.get(index);
                } else if (temp_macd > 0) {
                    step = 2;

                    count_pre_macd_wave += 1;
                } else {
                    break;
                }
            }
        }

        Mt5MacdKey id = new Mt5MacdKey(EPIC, time_frame);

        Mt5Macd mt5_macd = new Mt5Macd(id, Utils.formatPrice(BigDecimal.valueOf(macd), 5),
                Double.valueOf(count_pre_macd_wave), pre_macd_vs_zero, cur_macd_trend, trend_macd_vs_signal,
                trend_macd_vs_zero, count_cur_macd_wave, BigDecimal.valueOf(close_price_of_n1_candle));

        return mt5_macd;
    }

    private static double[] calculateMACD(ArrayList<Double> prices, int shortTermPeriod, int longTermPeriod) {
        double[] emaShort = calculateEMA(prices, shortTermPeriod);
        double[] emaLong = calculateEMA(prices, longTermPeriod);

        double[] macd = new double[prices.size()];
        for (int i = 0; i < prices.size(); i++) {
            macd[i] = emaShort[i] - emaLong[i];
        }

        return macd;
    }

    private static double[] calculateMACDSignal(double[] macd, int signalPeriod) {
        double[] signalLine = calculateSMA(macd, signalPeriod);
        return signalLine;
    }

    private static double[] calculateEMA(ArrayList<Double> prices, int period) {
        double[] ema = new double[prices.size()];

        double smoothingFactor = 2.0 / (period + 1);

        // Tính EMA ban đầu bằng giá trị đầu tiên
        ema[0] = prices.get(0);

        for (int i = 1; i < prices.size(); i++) {
            double currentPrice = prices.get(i);
            double previousEMA = ema[i - 1];
            ema[i] = (currentPrice - previousEMA) * smoothingFactor + previousEMA;
        }

        return ema;
    }

    private static double[] calculateSMA(double[] prices, int period) {
        double[] sma = new double[prices.length];

        for (int i = period - 1; i < prices.length; i++) {
            double sum = 0;
            for (int j = i; j > i - period; j--) {
                sum += prices[j];
            }
            sma[i] = sum / period;
        }

        return sma;
    }

}

//// vào: H4 nến heiken đầu tiên đóng nến theo ma9;
// String h4_heiken = dto_h4.getTrend_by_heiken();
// boolean is_able_tp_h4 = Utils.is_price_still_be_trade(dto_d1,
//// dailyRange.getAvg_amp_week(), h4_heiken);
// boolean h4_allow_trade = ((macd_h4.getCount_cur_macd_wave() <= 2)
// || (dto_h4.getCount_position_of_heiken_candle1() <= 2)
// || (dto_h4.getCount_position_of_candle1_vs_ma10() <= 1)
// || ((macd_h4.getCount_cur_macd_wave() <= 5) &&
//// (macd_h1.getCount_cur_macd_wave() <= 2)
// && Objects.equals(h4_heiken, macd_h1.getTrend_macd_vs_zero())
// && Objects.equals(h4_heiken, macd_h1.getTrend_macd_vs_signal())))
//
// && (Objects.equals(h4_heiken, dto_d1.getTrend_by_ma_6())
// || Objects.equals(h4_heiken, dto_d1.getTrend_by_ma_9())
// || Objects.equals(h4_heiken, dto_d1.getTrend_by_heiken())
// || Objects.equals(h4_heiken, macd_d1.getCur_macd_trend())
// || Objects.equals(h4_heiken, macd_d1.getTrend_macd_vs_zero()))
//
// && Objects.equals(h4_heiken, macd_h4.getTrend_macd_vs_zero())
// && Objects.equals(h4_heiken, macd_h4.getTrend_macd_vs_signal())
// && Objects.equals(h4_heiken, dto_h4.getTrend_by_ma_9())
// && Objects.equals(h4_heiken, dto_h4.getTrend_by_heiken())
//
// && Objects.equals(h4_heiken, dto_h1.getTrend_by_heiken())
// && Objects.equals(h4_heiken, dto_15.getTrend_by_heiken())
// && Objects.equals(h4_heiken, dto_05.getTrend_by_heiken());
//
// if (is_able_tp_h4 && h4_allow_trade) {
//
// close_reverse_trade(EPIC, h4_heiken);
//
// if (!is_opening_trade(EPIC, h4_heiken)) {
//
// List<TakeProfit> his_list_folow_d369 = takeProfitRepository
// .findAllBySymbolAndTradeTypeAndOpenDate(EPIC, h4_heiken,
//// Utils.getYyyyMMdd());
//
// int c_count = 0;
// String type = "";
// if (macd_h4.getCount_cur_macd_wave() <= 2) {
// type = "mc";
// c_count = macd_h4.getCount_cur_macd_wave();
// } else if (dto_h4.getCount_position_of_candle1_vs_ma10() <= 1) {
// type = "ma";
// c_count = dto_h4.getCount_position_of_candle1_vs_ma10().intValue();
// } else {
// type = "he";
// c_count = dto_h4.getCount_position_of_heiken_candle1().intValue();
// }
//
// String note = "_c" + c_count + Utils.ENCRYPTED_H4 + type;
//
// if (CollectionUtils.isEmpty(his_list_folow_d369) &&
//// Utils.is_open_trade_time()) {
// note += Utils.TEXT_PASS;
// } else {
// note += Utils.TEXT_NOTICE_ONLY;
// }
//
// trade = Utils.calc_Lot_En_SL_TP(EPIC, h4_heiken, dto_h4, note, true, "",
//// dailyRange, 1);
//
// String key = EPIC + Utils.ENCRYPTED_H4;
// BscScanBinanceApplication.mt5_open_trade_List.add(trade);
// BscScanBinanceApplication.dic_comment.put(key, trade.getComment());
// }
// }
