package bsc_scan_binance;

import java.io.File;
import java.net.InetAddress;
import java.time.Duration;
import java.time.LocalTime;
import java.util.ArrayList;
import java.util.Calendar;
import java.util.Date;
import java.util.Hashtable;
import java.util.List;
import java.util.Objects;
import java.util.concurrent.TimeUnit;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.context.ApplicationContext;
import org.telegram.telegrambots.meta.TelegramBotsApi;

import bsc_scan_binance.entity.Mt5OpenTrade;
import bsc_scan_binance.service.BinanceService;
import bsc_scan_binance.service.impl.WandaBot;
import bsc_scan_binance.utils.Utils;

@SpringBootApplication
public class BscScanBinanceApplication {
    public static int app_flag = Utils.const_app_flag_all_coin; // 1: msg_on; 2: msg_off; 3: web only; 4: all coin; 5:

    public static String callFormBinance = "";
    public static String TAKER_TOKENS = "_";
    public static int SLEEP_MINISECONDS = 1800; // Gecko=wait(6000);
    private static Hashtable<String, LocalTime> keys_dict = new Hashtable<String, LocalTime>();
    public static Hashtable<String, String> forex_naming_dict = new Hashtable<String, String>();
    public static Hashtable<String, String> linked_2_ftmo = new Hashtable<String, String>();
    public static Hashtable<String, String> dic_comment = new Hashtable<String, String>();
    public static Hashtable<String, Integer> watting_dict = new Hashtable<String, Integer>();
    public static String hostname = " ";
    public static ApplicationContext applicationContext;
    public static WandaBot wandaBot;
    public static TelegramBotsApi telegramBotsApi;
    public static String EPICS_OUTPUTED_LOG = "INIT";
    public static String EPICS_OUTPUT_MSG = "INIT";

    public static List<Mt5OpenTrade> mt5_open_trade_List = new ArrayList<Mt5OpenTrade>();
    public static Hashtable<String, Mt5OpenTrade> waitingM05list = new Hashtable<String, Mt5OpenTrade>();
    public static List<String> msg_open_trade_stocks = new ArrayList<String>();
    public static Hashtable<String, String> mt5_close_ticket_dict = new Hashtable<String, String>();

    public static void main(String[] args) {
        try {
            initForex_naming_dict();
            hostname = InetAddress.getLocalHost().getHostName().toUpperCase();
            if (hostname.length() > 2) {
                hostname = hostname.substring(0, 2);
            }

            System.out.println("Start "
                    + Utils.convertDateToString("yyyy-MM-dd HH:mm:ss", Calendar.getInstance().getTime()) + " ---->");

            if (!Objects.equals(null, args) && args.length > 0) {
                if (Utils.isNotBlank(args[0])) {
                    app_flag = Utils.getIntValue(args[0]);
                }
            }
            if (app_flag == 0) {
                app_flag = Utils.const_app_flag_all_coin;
            }

            // Debug36
            // String cty = "PC";
            // String home = "DESKTOP-L4M1JU2";
            // app_flag = Utils.const_app_flag_msg_on;
            // app_flag = Utils.const_app_flag_all_and_msg; // Debug
            app_flag = Utils.const_app_flag_all_coin;
            // app_flag = Utils.const_app_flag_Future_msg_off;

            System.out.println("app_flag:" + app_flag + " (1: msg_on; 2: msg_off; 3: web only; 4: all coin)");
            // --------------------Init--------------------
            applicationContext = SpringApplication.run(BscScanBinanceApplication.class, args);
            BinanceService binance_service = applicationContext.getBean(BinanceService.class);

            if (app_flag == Utils.const_app_flag_msg_on || app_flag == Utils.const_app_flag_all_and_msg) {
                // try {
                // wandaBot = applicationContext.getBean(WandaBot.class);
                // TelegramBotsApi telegramBotsApi = new
                // TelegramBotsApi(DefaultBotSession.class);
                // // https://github.com/PauloGaldo/telegram-bot
                // //
                // https://stackoverflow.com/questions/68059105/register-webhook-tg-bot-using-spring-boot
                // // telegramBotsApi.registerBot(bot, setWebhook);
                // telegramBotsApi.registerBot(wandaBot);
                // initTelegramBotsApi();
                //
                // binance_service.clearTrash();
                // } catch (TelegramApiException e) {
                // e.printStackTrace();
                // }
            }

            // ----------------------------------------
            binance_service.clearTrash();
            binance_service.createReport();
            binance_service.deleteConnectTimeOutException();
            // ----------------------------------------
            List<String> CAPITAL_LIST = new ArrayList<String>();
            CAPITAL_LIST.addAll(Utils.EPICS_METALS);
            CAPITAL_LIST.addAll(Utils.EPICS_CRYPTO_CFD);
            CAPITAL_LIST.addAll(Utils.EPICS_INDEXS_CFD);
            CAPITAL_LIST.addAll(Utils.EPICS_FOREXS_ALL);
            // CAPITAL_LIST.addAll(Utils.EPICS_STOCKS);

            if (app_flag != Utils.const_app_flag_webonly) {
                int index_crypto = 0;
                int round_crypto = 0;
                int total = Utils.ALL_COINS_BINANCE.size();
                Date start_time = Calendar.getInstance().getTime();

                File log = new File(Utils.getReportFilePath());
                System.out.println(log.getAbsolutePath());

                log = new File(Utils.getDraftLogFile());
                System.out.println(log.getAbsolutePath());

                System.out.println(Utils.getMt5DataFolder() + "HistoryToday.csv");
                System.out.println();

                String mt5_open_trade_file = Utils.getMt5DataFolder() + "OpenTrade.csv";
                Utils.delete_file(mt5_open_trade_file);

                binance_service.get_total_loss_today();

                while (index_crypto < total) {
                    try {
                        if (isReloadAfter(1, "MsgKillZone")) {
                            alertMsgKillZone(binance_service);
                        }

                        //if (Utils.isWeekday() && Utils.isAllowSendMsg())
                        {

                            if (isReloadAfter(Utils.MINUTES_RELOAD_CSV_DATA, "MT5_DATA")) {
                                binance_service.saveMt5Data("AureliusIronheart.csv", Utils.MINUTES_RELOAD_CSV_DATA);
                                binance_service.saveMt5Data("TimeBreaker.csv", Utils.MINUTES_RELOAD_CSV_DATA);
                                binance_service.saveDailyPivotData();

                                if (isReloadAfter(Utils.MINUTES_OF_1H, "MT5_DATA_STOCKS")) {
                                    binance_service.saveMt5Data("Stocks.csv", Utils.MINUTES_OF_1H);
                                }

                                for (String EPIC : CAPITAL_LIST) {
                                    if (Utils.EPICS_STOCKS.contains(EPIC)) {
                                        if (isReloadAfter(Utils.MINUTES_OF_30, "MT5_DATA_STOCKS_" + EPIC)) {
                                            //binance_service.initForexTrend(EPIC, Utils.CAPITAL_TIME_W1);
                                            //binance_service.initForexTrend(EPIC, Utils.CAPITAL_TIME_D1);
                                            //binance_service.initForexTrend(EPIC, Utils.CAPITAL_TIME_H4);
                                            binance_service.initForexTrend(EPIC, Utils.CAPITAL_TIME_H1);
                                            binance_service.initForexTrend(EPIC, Utils.CAPITAL_TIME_15);
                                        }
                                    } else {
                                        if (isReloadAfter(Utils.MINUTES_OF_15, "MT5_DATA_FOREX_" + EPIC)) {
                                            //binance_service.initForexTrend(EPIC, Utils.CAPITAL_TIME_W1);
                                            //binance_service.initForexTrend(EPIC, Utils.CAPITAL_TIME_D1);
                                            //binance_service.initForexTrend(EPIC, Utils.CAPITAL_TIME_H4);
                                        }

                                        binance_service.initForexTrend(EPIC, Utils.CAPITAL_TIME_H4);
                                        binance_service.initForexTrend(EPIC, Utils.CAPITAL_TIME_H1);
                                        binance_service.initForexTrend(EPIC, Utils.CAPITAL_TIME_15);
                                        binance_service.initForexTrend(EPIC, Utils.CAPITAL_TIME_03);
                                    }
                                }

                                binance_service.initTradeList();
                                control_Mt5(binance_service);
                                binance_service.monitorProfit();
                            }
                        }

                        if (isReloadAfter(Utils.MINUTES_RELOAD_CSV_DATA, "MT5_SL_TP")) {
                            binance_service.initTradeList();
                            binance_service.closeTrade_by_SL_TP();
                            binance_service.CloseTickets();
                        }

                        // ---------------------------------------------------------
                        if (isReloadAfter((Utils.MINUTES_OF_15), "INIT_CRYPTO")) {
                            binance_service.sendMsgKillLongShort("BTC");
                            binance_service.sendMsgKillLongShort("ETH");
                            binance_service.sendMsgKillLongShort("BNB");
                        }

                        // String SYMBOL = Utils.ALL_COINS_BINANCE.get(index_crypto).toUpperCase();
                        // if (isReloadAfter(getWattingTime(SYMBOL), "CHECK_CRYPTO_" + SYMBOL)) {
                        // String crypto_time = binance_service.initCryptoTrend(SYMBOL);
                        // setWattingTime(SYMBOL, crypto_time);
                        // }

                        // ---------------------------------------------------------
                        if (isReloadAfter(Utils.MINUTES_RELOAD_CSV_DATA, "CREATE_REPORT")) {
                            binance_service.createReport();
                        }

                        wait(SLEEP_MINISECONDS);
                    } catch (Exception e) {
                        e.printStackTrace();
                    }
                    if (Objects.equals(index_crypto, total - 1)) {
                        Date curr_time = Calendar.getInstance().getTime();
                        long diff = curr_time.getTime() - start_time.getTime();
                        start_time = Calendar.getInstance().getTime();

                        String msg = "round:" + round_crypto + ", reload: " + Utils.getMmDD_TimeHHmm() + ", spend:"
                                + TimeUnit.MILLISECONDS.toMinutes(diff) + " Minutes.";

                        round_crypto += 1;
                        index_crypto = 0;

                        if (round_crypto % 10 == 0) {
                            System.out.println(msg);
                        }
                    } else {
                        index_crypto += 1;
                    }
                }
            }
        } catch (

        Exception e) {
            initTelegramBotsApi();
            System.out.println("Duydk:" + e.getMessage());
            e.printStackTrace();
        }
    }

    public static void control_Mt5(BinanceService binance_service) {
        mt5_open_trade_List = new ArrayList<Mt5OpenTrade>();
        waitingM05list = new Hashtable<String, Mt5OpenTrade>();
        msg_open_trade_stocks = new ArrayList<String>();
        try {
            String mt5_open_trade_file = Utils.getMt5DataFolder() + "OpenTrade.csv";
            File myScap = new File(mt5_open_trade_file);
            myScap.delete();
        } catch (Exception e) {
        }

        String pre_epics = EPICS_OUTPUT_MSG;
        // --------------------------------------------------------------------------
        File myScap = new File(Utils.getDraftLogFile());
        myScap.delete();
        EPICS_OUTPUTED_LOG = "";
        // --------------------------------------------------------------------------
        EPICS_OUTPUT_MSG = "";
        // --------------------------------------------------------------------------
        Utils.logWritelnDraft("");
        binance_service.controlMt5(Utils.EPICS_METALS);
        Utils.logWritelnDraft("...");

        binance_service.controlMt5(Utils.EPICS_INDEXS_CFD);
        Utils.logWritelnDraft("");

        binance_service.controlMt5(Utils.EPICS_FOREXS_AUDx);
        Utils.logWritelnDraft("");

        binance_service.controlMt5(Utils.EPICS_FOREXS_CADx);
        Utils.logWritelnDraft("");

        binance_service.controlMt5(Utils.EPICS_FOREXS_EURx);
        Utils.logWritelnDraft("");

        binance_service.controlMt5(Utils.EPICS_FOREXS_GBPx);
        Utils.logWritelnDraft("");

        binance_service.controlMt5(Utils.EPICS_FOREXS_NZDx);
        Utils.logWritelnDraft("");

        binance_service.controlMt5(Utils.EPICS_FOREXS_USDx);
        binance_service.controlMt5(Utils.EPICS_FOREXS_ALL);
        binance_service.controlMt5(Utils.EPICS_CRYPTO_CFD);
        Utils.logWritelnDraft("...");

        // --------------------------------------------------------------------------
        // Utils.logWritelnDraftFooter();
        // binance_service.controlMt5(Utils.EPICS_STOCKS_EUR);
        // Utils.logWritelnDraft("...");
        // binance_service.controlMt5(Utils.EPICS_STOCKS);
        // Utils.logWritelnDraftFooter();
        // --------------------------------------------------------------------------
        String cur_epics = EPICS_OUTPUT_MSG;
        String[] arr = cur_epics.split("_");
        String add_new = "";
        int count = 0;
        for (String epic : arr) {
            if (!pre_epics.contains(epic)) {
                count += 1;
                if (Utils.isNotBlank(add_new)) {
                    add_new += ",";
                }
                add_new += epic + "   ";
            }
        }
        if (Utils.isNotBlank(add_new)) {
            String msg = "(Forex30: " + count + "):   " + add_new;
            Utils.logWritelnDraft("");
            Utils.logWritelnDraft(msg);

            String EVENT_ID = "FX_M_30" + Utils.getCurrentYyyyMmDd_HH();
            binance_service.sendMsgPerHour_OnlyMe(EVENT_ID, msg);
        }
    }

    public static void alertMsgKillZone(BinanceService binance_service) {
        if (!Utils.isWeekday()) {
            return;
        }
        LocalTime kill_zone_ld = LocalTime.parse("13:45:00"); // to: 14:15
        LocalTime kill_zone_ny = LocalTime.parse("18:45:00"); // to: 19:15
        LocalTime cur_time = LocalTime.now();

        String EVENT_ID = "KILL_ZONE_" + Utils.getCurrentYyyyMmDd_HH_Blog15m();

        long elapsedMinutes_ld = Duration.between(kill_zone_ld, cur_time).toMinutes();
        if ((0 <= elapsedMinutes_ld) && (elapsedMinutes_ld <= 30) && isReloadAfter(60, "Start_London_Kill_Zone")) {
            binance_service.sendMsgPerHour_OnlyMe(EVENT_ID, "Start_London_Kill_Zone");
        }

        long elapsedMinutes_ny = Duration.between(kill_zone_ny, cur_time).toMinutes();
        if ((0 <= elapsedMinutes_ny) && (elapsedMinutes_ny <= 30) && isReloadAfter(60, "Start_NewYork_Kill_Zone")) {
            // binance_service.sendMsgPerHour_OnlyMe(EVENT_ID, "Start_NewYork_Kill_Zone");
        }

        // ---------------------------------------------------------------------------
        LocalTime close_Tokyo_Orders = LocalTime.parse("16:15:00"); // to: 15:45
        LocalTime close_London_Orders = LocalTime.parse("19:30:00"); // to: 23:45
        LocalTime close_NewYork_Orders = LocalTime.parse("22:30:00"); // to: 02:45

        long close_Tokyo = Duration.between(close_Tokyo_Orders, cur_time).toMinutes();
        if ((0 <= close_Tokyo) && (close_Tokyo <= 30) && isReloadAfter(15, "Close_Tokyo_Orders")) {
            binance_service.sendMsgPerHour_OnlyMe(EVENT_ID, "Close_Tokyo_Orders + (Đóng lệnh về đón con)");
        }

        long close_London = Duration.between(close_London_Orders, cur_time).toMinutes();
        if ((0 <= close_London) && (close_London <= 30) && isReloadAfter(60, "Close_London_Orders")) {
            // binance_service.sendMsgPerHour_OnlyMe(EVENT_ID, "Close_London_Orders");
        }

        long close_NewYork = Duration.between(close_NewYork_Orders, cur_time).toMinutes();
        if ((0 <= close_NewYork) && (close_NewYork <= 30) && isReloadAfter(60, "Close_NewYork_Orders")) {
            binance_service.sendMsgPerHour_OnlyMe(EVENT_ID, "close_NewYork_Orders");
        }
    }

    public static void initTelegramBotsApi() {
        System.out.println("____________________initTelegramBotsApi" + Utils.getTimeHHmm() + "____________________");
    }

    public static Integer getWattingTime(String SYMBOL) {
        Integer time = Utils.MINUTES_OF_05;
        if (watting_dict.containsKey(SYMBOL)) {
            time = watting_dict.get(SYMBOL);
        }

        return time;
    }

    public static void setWattingTime(String SYMBOL, String CRYPTO_TIME_xx) {
        Integer time = Utils.MINUTES_OF_15;
        switch (CRYPTO_TIME_xx) {
        case Utils.CRYPTO_TIME_05:
            time = Utils.MINUTES_OF_15;
            break;
        case Utils.CRYPTO_TIME_15:
            time = Utils.MINUTES_OF_15;
            break;
        case Utils.CRYPTO_TIME_H1:
            time = Utils.MINUTES_OF_1H;
            break;
        case Utils.CRYPTO_TIME_H4:
        case Utils.CRYPTO_TIME_D1:
        case Utils.CRYPTO_TIME_W1:
            time = Utils.MINUTES_OF_4H;
            break;
        default:
            time = Utils.MINUTES_OF_1H;
            break;
        }
        watting_dict.put(SYMBOL, time);
    }

    public static boolean isReloadAfter(long minutes, String geckoid_or_epic) {
        LocalTime cur_time = LocalTime.now();
        String key = Utils.getStringValue(geckoid_or_epic);

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

    private static void initForex_naming_dict() {
        linked_2_ftmo.put(Utils.LINKED_NAME_2_USOIL, "USOIL");
        linked_2_ftmo.put(Utils.LINKED_NAME_2_US100, "US100");
        linked_2_ftmo.put(Utils.LINKED_NAME_2_GER40, "GER40");
        linked_2_ftmo.put(Utils.LINKED_NAME_2_EU50, "EU50");

        forex_naming_dict.put("DXY", "US Dollar Index");
        forex_naming_dict.put("OIL_CRUDE", "US Crude Oil");
        forex_naming_dict.put("US100", "US Tech 100 (Nasdaq)");
        forex_naming_dict.put("US30", "US Wall Street 30 (USA 30, Dow Jones)");
        forex_naming_dict.put("US500", "US 500 (S&P)");
        forex_naming_dict.put("DE40", "Germany 40 (Europe, Dax)");
        forex_naming_dict.put("NIFTY50", "India 50");
        forex_naming_dict.put("HK50", "Hong Kong 50");
        forex_naming_dict.put("UK100", "UK 100");
        forex_naming_dict.put("VIX", "VIX Volatility Index");
        forex_naming_dict.put("FR40", "France 40 (France)");
        forex_naming_dict.put("RTY", "US Russell 2000");
        forex_naming_dict.put("J225", "Japan 225");
        forex_naming_dict.put("DXY", "US Dollar Index");
        forex_naming_dict.put("AU200", "Australia 200");
        forex_naming_dict.put("IT40", "Italy 40");
        forex_naming_dict.put("SG25", "Singapore 25");

        forex_naming_dict.put("AUDCAD", "Australian Dollar / Canadian Dollar");
        forex_naming_dict.put("AUDCHF", "Australian Dollar / Swiss Franc");
        forex_naming_dict.put("AUDCNH", "Australian Dollar / Chinese Yuan");
        forex_naming_dict.put("AUDHKD", "Australian Dollar / Hong Kong Dollar");
        forex_naming_dict.put("AUDJPY", "Australian Dollar / Japanese Yen");
        forex_naming_dict.put("AUDMXN", "Australian Dollar / Mexican Peso");
        forex_naming_dict.put("AUDNZD", "Australian Dollar / New Zealand Dollar");
        forex_naming_dict.put("AUDPLN", "Australian Dollar / Polish Zloty");
        forex_naming_dict.put("AUDSGD", "Australian Dollar / Singapore Dollar");
        forex_naming_dict.put("AUDUSD", "Australian Dollar / US Dollar");
        forex_naming_dict.put("AUDZAR", "Australian Dollar / Rand");
        forex_naming_dict.put("CADCHF", "Canadian dollar / Swiss Franc");
        forex_naming_dict.put("CADCNH", "Canadian Dollar / Chinese yuan");
        forex_naming_dict.put("CADHKD", "Canadian Dollar / Hong Kong Dollar");
        forex_naming_dict.put("CADJPY", "Canadian dollar / Japanese Yen");
        forex_naming_dict.put("CADMXN", "Canadian Dollar / Mexican Peso");
        forex_naming_dict.put("CADNOK", "Canadian dollar / Norwegian Krone");
        forex_naming_dict.put("CADPLN", "Canadian dollar / Polish Zloty");
        forex_naming_dict.put("CADSGD", "Canadian Dollar / Singapore Dollar");
        forex_naming_dict.put("CADTRY", "Canadian Dollar / Turkish Lira");
        forex_naming_dict.put("CADZAR", "Canadian Dollar / Rand");
        forex_naming_dict.put("CHFCNH", "Swiss Franc / Chinese yuan");
        forex_naming_dict.put("CHFCZK", "Swiss Franc / Czech Koruna");
        forex_naming_dict.put("CHFDKK", "Swiss Franc / Danish Krone");
        forex_naming_dict.put("CHFHKD", "Swiss Franc / Hong Kong Dollar");
        forex_naming_dict.put("CHFJPY", "Swiss Franc / Japanese Yen");
        forex_naming_dict.put("CHFMXN", "Swiss Franc / Mexican Peso");
        forex_naming_dict.put("CHFNOK", "Swiss Franc / Norwegian Krone");
        forex_naming_dict.put("CHFPLN", "Swiss Franc / Polish Zloty");
        forex_naming_dict.put("CHFSEK", "Swiss Franc / Swedish Krona");
        forex_naming_dict.put("CHFSGD", "Swiss Franc / Singapore Dollar");
        forex_naming_dict.put("CHFTRY", "Swiss Franc / Turkish Lira");
        forex_naming_dict.put("CHFZAR", "Swiss Franc / Rand");
        forex_naming_dict.put("CNHHKD", "Chinese yuan / Hong Kong Dollar");
        forex_naming_dict.put("CNHJPY", "Chinese Yuan / Japanese Yen");
        forex_naming_dict.put("DKKJPY", "Danish Krone / Yen");
        forex_naming_dict.put("EURAUD", "Euro / Australian Dollar");
        forex_naming_dict.put("EURCAD", "Euro / Canadian dollar");
        forex_naming_dict.put("EURCHF", "Euro / Swiss Franc");
        forex_naming_dict.put("EURCZK", "Euro / Czech Koruna");
        forex_naming_dict.put("EURDKK", "Euro / Danish Krone");
        forex_naming_dict.put("EURGBP", "Euro / British Pound");
        forex_naming_dict.put("EURILS", "Euro / New Israeli Sheqel");
        forex_naming_dict.put("EURJPY", "Euro / Japanese Yen");
        forex_naming_dict.put("EURMXN", "Euro / Mexican Peso");
        forex_naming_dict.put("EURNZD", "Euro / New Zealand Dollar");
        forex_naming_dict.put("EURPLN", "Euro / Polish Zloty");
        forex_naming_dict.put("EURRON", "Euro / Romanian Leu");
        forex_naming_dict.put("EURSGD", "Euro / Singapore Dollar");
        forex_naming_dict.put("EURUSD", "Euro / US Dollar");
        forex_naming_dict.put("GBPAUD", "British Pound / Australian Dollar");
        forex_naming_dict.put("GBPCAD", "British Pound / Canadian dollar");
        forex_naming_dict.put("GBPCHF", "British Pound / Swiss Franc");
        forex_naming_dict.put("GBPCNH", "Pound Sterling / Chinese yuan");
        forex_naming_dict.put("GBPCZK", "British Pound / Czech Koruna");
        forex_naming_dict.put("GBPDKK", "British Pound / Danish Krone");
        forex_naming_dict.put("GBPHKD", "British Pound / Hong Kong Dollar");
        forex_naming_dict.put("GBPHUF", "British Pound / Hungarian Forint");
        forex_naming_dict.put("GBPJPY", "British Pound / Japanese Yen");
        forex_naming_dict.put("GBPMXN", "British Pound / Mexican Peso");
        forex_naming_dict.put("GBPNOK", "British Pound / Norwegian Krone");
        forex_naming_dict.put("GBPNZD", "British Pound / New Zealand Dollar");
        forex_naming_dict.put("GBPPLN", "British Pound / Polish Zloty");
        forex_naming_dict.put("GBPSEK", "British Pound / Swedish Krona");
        forex_naming_dict.put("GBPSGD", "British Pound / Singapore Dollar");
        forex_naming_dict.put("GBPTRY", "British Pound / Turkish lira");
        forex_naming_dict.put("GBPUSD", "British Pound / US Dollar");
        forex_naming_dict.put("GBPZAR", "British Pound / South African Rand");
        forex_naming_dict.put("HKDMXN", "Hong Kong Dollar / Mexican Peso");
        forex_naming_dict.put("HKDTRY", "Hong Kong Dollar / Turkish Lira");
        forex_naming_dict.put("NOKSEK", "Norwegian Krone / Swedish Krona");
        forex_naming_dict.put("NOKTRY", "Norwegian Krone / Turkish Lira");
        forex_naming_dict.put("NZDCAD", "New Zealand Dollar / Canadian dollar");
        forex_naming_dict.put("NZDCHF", "New Zealand Dollar / Swiss Franc");
        forex_naming_dict.put("NZDCNH", "New Zealand Dollar / Chinese yuan");
        forex_naming_dict.put("NZDHKD", "New Zealand Dollar / Hong Kong Dollar");
        forex_naming_dict.put("NZDJPY", "New Zealand Dollar / Japanese Yen");
        forex_naming_dict.put("NZDMXN", "New Zealand Dollar / Mexican Peso");
        forex_naming_dict.put("NZDPLN", "New Zealand Dollar / Zloty");
        forex_naming_dict.put("NZDSEK", "New Zealand Dollar / Swedish Krona");
        forex_naming_dict.put("NZDSGD", "New Zealand Dollar / Singapore Dollar");
        forex_naming_dict.put("NZDTRY", "New Zealand Dollar / Turkish Lira");
        forex_naming_dict.put("NZDUSD", "New Zealand Dollar / US Dollar");
        forex_naming_dict.put("PLNSEK", "Zloty / Swedish Krona");
        forex_naming_dict.put("PLNTRY", "Zloty / Turkish Lira");
        forex_naming_dict.put("SEKMXN", "Swedish Krona / Mexican Peso");
        forex_naming_dict.put("SEKTRY", "Swedish Krona / Turkish Lira");
        forex_naming_dict.put("SGDHKD", "Singapore Dollar / Hong Kong Dollar");
        forex_naming_dict.put("SGDMXN", "Singapore Dollar / Mexican Peso");
        forex_naming_dict.put("TRYJPY", "Turkish Lira / Japanese Yen");
        forex_naming_dict.put("USDCAD", "US Dollar / Canadian dollar");
        forex_naming_dict.put("USDCHF", "US Dollar / Swiss Franc");
        forex_naming_dict.put("USDCNH", "US Dollar / Chinese Yuan");
        forex_naming_dict.put("USDCZK", "US Dollar / Czech Koruna");
        forex_naming_dict.put("USDDKK", "US Dollar / Danish Krone");
        forex_naming_dict.put("USDHKD", "US Dollar / Hong Kong Dollar");
        forex_naming_dict.put("USDILS", "US Dollar / Israeli New Shekel");
        forex_naming_dict.put("USDJPY", "US Dollar / Japanese Yen");
        forex_naming_dict.put("USDRON", "US Dollar / Romanian Leu");
        forex_naming_dict.put("USDTRY", "US Dollar / Turkish Lira");
    }

    public static void wait(int sleep_ms) {
        try {
            java.lang.Thread.sleep(sleep_ms);
        } catch (InterruptedException ex) {
            java.lang.Thread.currentThread().interrupt();
        }
    }

}
