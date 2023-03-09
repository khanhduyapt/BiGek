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

import bsc_scan_binance.entity.CandidateCoin;
import bsc_scan_binance.service.BinanceService;
import bsc_scan_binance.service.CoinGeckoService;
import bsc_scan_binance.service.impl.WandaBot;
import bsc_scan_binance.utils.Utils;

@SpringBootApplication
public class BscScanBinanceApplication {
    public static int app_flag = Utils.const_app_flag_all_coin; // 1: msg_on; 2: msg_off; 3: web only; 4: all coin; 5:

    public static String callFormBinance = "";
    public static String TAKER_TOKENS = "_";
    public static int SLEEP_MINISECONDS = 8000;
    private static Hashtable<String, LocalTime> keys_dict = new Hashtable<String, LocalTime>();
    public static Hashtable<String, String> forex_naming_dict = new Hashtable<String, String>();
    public static String hostname = " ";
    public static ApplicationContext applicationContext;
    public static WandaBot wandaBot;
    public static TelegramBotsApi telegramBotsApi;

    public static void main(String[] args) {
        try {
            initForex_naming_dict();
            hostname = InetAddress.getLocalHost().getHostName().toLowerCase();
            if (hostname.length() > 2) {
                hostname = hostname.substring(0, 2);
            }
            hostname += " ";

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
            CoinGeckoService gecko_service = applicationContext.getBean(CoinGeckoService.class);
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
                // System.exit(0);
                // }
            }

            // ----------------------------------------
            // binance_service.clearTrash();
            binance_service.createReport();
            // ----------------------------------------
            List<String> capital_list = new ArrayList<String>();
            capital_list.addAll(Utils.EPICS_SCAP);
            capital_list.addAll(Utils.EPICS_FOREXS);

            if (app_flag != Utils.const_app_flag_webonly) {
                List<CandidateCoin> token_list = gecko_service.getList(callFormBinance);
                int total = token_list.size();

                int round_crypto = 0;
                int index_crypto = 0;
                int forex_size = capital_list.size();
                Date start_time = Calendar.getInstance().getTime();
                Utils.writelnLogFooter_Forex();
                System.out.println();
                File log = new File(Utils.getCryptoLogFile());
                System.out.println(log.getAbsolutePath());
                log = new File(Utils.getForexLogFile());
                System.out.println(log.getAbsolutePath());
                log = new File(Utils.getDraftLogFile());
                Utils.logWritelnDraft("");
                System.out.println(log.getAbsolutePath());
                System.out.println();

                while (index_crypto < total) {
                    try {
                        checkKillLongShort(binance_service);

                        if (Utils.isBusinessTime_6h_to_17h()) {
                            if (isReloadAfter(Utils.MINUTES_OF_1H, "RE_CHECK_FOREX")) {
                                if (!Utils.isWeekend() && Utils.isAllowSendMsg()) {

                                    Utils.initCapital();
                                    for (int index = 0; index < forex_size; index++) {
                                        sleepWhenExceptionTimeOut(binance_service);
                                        String EPIC = capital_list.get(index);
                                        checkCapital(binance_service, EPIC);
                                    }

                                    binance_service.createReport();
                                }
                            }
                        }
                        // ---------------------------------------------------------
                        checkCrypto(binance_service);
                        // ---------------------------------------------------------

                        if (isReloadAfter((Utils.MINUTES_OF_15M), "CREATE_REPORT")) {
                            binance_service.createReport();
                        }

                        wait(SLEEP_MINISECONDS);
                    } catch (Exception e) {
                        e.printStackTrace();
                    }
                    if (Objects.equals(index_crypto, total - 1)) {
                        Utils.writelnLogFooter();
                        Date curr_time = Calendar.getInstance().getTime();
                        long diff = curr_time.getTime() - start_time.getTime();
                        start_time = Calendar.getInstance().getTime();

                        System.out.println("reload: " + Utils.getMmDD_TimeHHmm() + ", spend:"
                                + TimeUnit.MILLISECONDS.toMinutes(diff) + " Minutes.");

                        round_crypto += 1;
                        index_crypto = 0;

                        System.out.println("round:" + round_crypto);
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
            System.exit(0);
        }
    }

    public static void initTelegramBotsApi() {
        System.out.println("____________________initTelegramBotsApi" + Utils.getTimeHHmm() + "____________________");
    }

    public static void sleepWhenExceptionTimeOut(BinanceService binance_service) {
        if (binance_service.hasConnectTimeOutException()) {
            for (int loop = 1; loop < 15; loop++) {
                System.out.println("Connection timed out");
                wait(SLEEP_MINISECONDS * 5);
            }

            Utils.initCapital();
        }
    }

    public static void checkCapital(BinanceService binance_service, String EPIC) {
        String trend_d = binance_service.initForexTrend(EPIC, Utils.CAPITAL_TIME_DAY);
        if (Utils.isNotBlank(trend_d)) {
            wait(SLEEP_MINISECONDS * 3);
        }

        String trend_h4 = binance_service.initForexTrend(EPIC, Utils.CAPITAL_TIME_HOUR_4);
        if (Utils.isNotBlank(trend_h4)) {
            wait(SLEEP_MINISECONDS * 3);
        }

        String trend_h1 = "";
        if (Utils.EPICS_SCAP.contains(EPIC)) {
            trend_h1 = binance_service.initForexTrend(EPIC, Utils.CAPITAL_TIME_HOUR);
            if (Utils.isNotBlank(trend_h1)) {
                wait(SLEEP_MINISECONDS * 3);
            }
        }

        String init = "";
        init += "D1:" + Utils.appendSpace(trend_d, 6);
        init += "H4:" + Utils.appendSpace(trend_h4, 6);
        init += "H1:" + Utils.appendSpace(trend_h1, 6);

        System.out.println(Utils.getTimeHHmm() + Utils.appendSpace(EPIC, 15) + init);
    }

    private static void checkKillLongShort(BinanceService binance_service) {
        if (isReloadAfter(Utils.MINUTES_OF_15M, "KILL_BTC")) {
            System.out.println(Utils.getTimeHHmm() + "sendMsgKillLongShort BTC(15m)");
            if (Utils.isNotBlank(binance_service.sendMsgKillLongShort("bitcoin", "BTC"))) {
                wait(SLEEP_MINISECONDS);
            }
        }

        if (isReloadAfter(Utils.MINUTES_OF_15M, "KILL_ETH")) {
            System.out.println(Utils.getTimeHHmm() + "sendMsgKillLongShort ETH(15m)");
            if (Utils.isNotBlank(binance_service.sendMsgKillLongShort("ethereum", "ETH"))) {
                wait(SLEEP_MINISECONDS);
            }
        }

        if (isReloadAfter(Utils.MINUTES_OF_15M, "KILL_BNB")) {
            System.out.println(Utils.getTimeHHmm() + "sendMsgKillLongShort BNB(15m)");
            if (Utils.isNotBlank(binance_service.sendMsgKillLongShort("binancecoin", "BNB"))) {
                wait(SLEEP_MINISECONDS);
            }
        }
    }

    private static void checkCrypto(BinanceService binance_service) {
        // ----------------------------------------------
        int index_crypto = 0;
        int total = Utils.coins.size();
        for (String SYMBOL : Utils.coins) {
            index_crypto += 1;
            if (isReloadAfter(Utils.MINUTES_OF_4H, "RE_CHECK_CRYPTO_" + SYMBOL)) {
                String trend_d = binance_service.initCryptoTrend(Utils.CRYPTO_TIME_1D, SYMBOL);
                if (Utils.isNotBlank(trend_d)) {
                    wait(SLEEP_MINISECONDS);
                }

                String trend_h4 = "";
                // trend_h4 = binance_service.initCryptoTrend(Utils.CRYPTO_TIME_4H, SYMBOL);
                if (Utils.isNotBlank(trend_h4)) {
                    wait(SLEEP_MINISECONDS);
                }

                String trend_h1 = "";
                // trend_h1 = binance_service.initCryptoTrend(Utils.CRYPTO_TIME_1H, SYMBOL);
                if (Utils.isNotBlank(trend_h1)) {
                    wait(SLEEP_MINISECONDS);
                }

                String init = "";
                init += "D:" + Utils.appendSpace(trend_d, 6);
                init += "H4:" + Utils.appendSpace(trend_h4, 6);
                init += "H1:" + Utils.appendSpace(trend_h1, 6);

                String str_index = Utils.appendLeft(String.valueOf(index_crypto), 3) + "/"
                        + Utils.appendLeft(String.valueOf(total), 3) + "   ";
                System.out.println(Utils.getTimeHHmm() + str_index + Utils.appendSpace(SYMBOL, 10) + init);
            }

            // ----------------------------------------------
            // if ((round_count > 0) && Utils.isWorkingTime()) {
            // if (isReloadAfter(Utils.MINUTES_OF_4H, "COIN_GECKO_" + SYMBOL)) {
            // gecko_service.loadData(GECKOID);
            // }
            //
            // if (isReloadAfter(Utils.MINUTES_OF_4H, "INIT_CRYPTO_" + GECKOID)) {
            // binance_service.initCrypto(GECKOID, SYMBOL);
            // }
            //
            // wait(SLEEP_MINISECONDS);
            // }
            //
        }
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
