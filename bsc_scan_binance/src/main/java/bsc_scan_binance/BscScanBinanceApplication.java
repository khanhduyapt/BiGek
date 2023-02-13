package bsc_scan_binance;

import java.io.File;
import java.net.InetAddress;
import java.time.Duration;
import java.time.LocalTime;
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
    public static String hostname = "_";
    public static ApplicationContext applicationContext;
    public static WandaBot wandaBot;
    public static TelegramBotsApi telegramBotsApi;

    public static void main(String[] args) {
        try {
            initForex_naming_dict();
            hostname = InetAddress.getLocalHost().getHostName();

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

            Utils.logWriteln("____________________Start " + Utils.getToday_YyyyMMdd() + Utils.getTimeHHmm()
                    + "____________________", true);

            Utils.logForexWriteln("____________________Start " + Utils.getToday_YyyyMMdd() + Utils.getTimeHHmm()
                    + "____________________", true);

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

            // --------------------Debug--------------------

            List<String> capital_list = Utils.EPICS_FOREX;
            // capital_list.addAll(Utils.EPICS_FOREX_SCAPS);
            // capital_list.addAll(Utils.EPICS_INDEXS);
            // capital_list.addAll(Utils.EPICS_FOREX_EUR);
            // capital_list.addAll(Utils.EPICS_FOREX_AUD);
            // capital_list.addAll(Utils.EPICS_FOREX_GBP);
            // capital_list.addAll(Utils.EPICS_FOREX_CAD);
            // capital_list.addAll(Utils.EPICS_FOREX_DOLLAR);
            // capital_list.addAll(Utils.EPICS_FOREX_OTHERS);

            if (app_flag != Utils.const_app_flag_webonly) {
                Utils.initCapital();
                List<CandidateCoin> token_list = gecko_service.getList(callFormBinance);
                int total = token_list.size();

                int round_count = 0;
                int index_forex = 0;
                int index_crypto = 0;
                int forex_size = capital_list.size();
                Date start_time = Calendar.getInstance().getTime();

                System.out.println();
                File log = new File(Utils.getCryptoLogFile());
                System.out.println(log.getAbsolutePath());
                log = new File(Utils.getForexLogFile());
                System.out.println(log.getAbsolutePath());
                System.out.println();

                while (index_crypto < total) {
                    CandidateCoin coin = token_list.get(index_crypto);

                    try {
                        checkBtcKillLongShort_15m(binance_service);

                        // ----------------------------------------------
                        if (isReloadAfter(1, "FOREX") && !Utils.isWeekend() && Utils.isBusinessTime()
                                && Utils.isAllowSendMsgSetting()) {
                            if (index_forex < forex_size) {
                                String EPIC = capital_list.get(index_forex);
                                String init = "";

                                if (isReloadAfter(Utils.MINUTES_OF_D, "INIT_FOREX_" + EPIC)) {
                                    String trend_d = binance_service.initForexTrend(EPIC, Utils.CAPITAL_TIME_DAY);
                                    if (Utils.isNotBlank(trend_d)) {
                                        wait(SLEEP_MINISECONDS);
                                        System.out.println(trend_d);
                                    }
                                }

                                if (isReloadAfter(Utils.MINUTES_OF_4H, "FOREX_CHART_H4_" + EPIC)) {
                                    init = binance_service.checkForex(EPIC, Utils.CAPITAL_TIME_HOUR_4);

                                    String msg = "(" + Utils.appendSpace(String.valueOf(index_forex + 1), 3) + "/"
                                            + Utils.appendSpace(String.valueOf(forex_size), 3) + ")"
                                            + Utils.getTimeHHmm() + Utils.appendSpace(EPIC, 10) + " " + init;

                                    wait(SLEEP_MINISECONDS);
                                    System.out.println(msg);
                                }

                                if (isReloadAfter(Utils.MINUTES_OF_1H, "FOREX_CHART_H1_" + EPIC)) {
                                    init = binance_service.checkForex(EPIC, Utils.CAPITAL_TIME_HOUR);

                                    String msg = "(" + Utils.appendSpace(String.valueOf(index_forex + 1), 3) + "/"
                                            + Utils.appendSpace(String.valueOf(forex_size), 3) + ")"
                                            + Utils.getTimeHHmm() + Utils.appendSpace(EPIC, 10) + " " + init;

                                    wait(SLEEP_MINISECONDS);
                                    System.out.println(msg);
                                }
                                index_forex += 1;
                            } else {
                                index_forex = 0;
                            }
                        }

                        // ----------------------------------------------
                        if ((round_count > 0) && Utils.isWorkingTime()) {
                            if (isReloadAfter(Utils.MINUTES_OF_4H, "COIN_GECKO_" + coin.getSymbol())) {
                                gecko_service.loadData(coin.getGeckoid());
                            }

                            if (isReloadAfter(Utils.MINUTES_OF_4H, "INIT_CRYPTO_" + coin.getGeckoid())) {
                                String init = binance_service.initCrypto(coin.getGeckoid(), coin.getSymbol());

                                String msg = "(" + Utils.appendSpace(String.valueOf(index_crypto + 1), 3) + "/"
                                        + Utils.appendSpace(String.valueOf(total), 3) + ")" + Utils.getTimeHHmm()
                                        + Utils.appendSpace(coin.getSymbol(), 10) + " " + init;

                                System.out.println(msg);
                            }

                            wait(SLEEP_MINISECONDS);
                        }
                        // ----------------------------------------------
                        if (isReloadAfter(Utils.MINUTES_OF_1H, "CRYPTO_CHART_H1_" + coin.getSymbol())) {
                            String init = binance_service.checkCrypto(Utils.CRYPTO_TIME_1h, coin.getGeckoid(),
                                    coin.getSymbol());

                            String msg = "(" + Utils.appendSpace(String.valueOf(index_crypto + 1), 3) + "/"
                                    + Utils.appendSpace(String.valueOf(total), 3) + ")" + Utils.getTimeHHmm()
                                    + Utils.appendSpace(coin.getSymbol(), 10) + " " + init;

                            System.out.println(msg);
                        }
                        // ----------------------------------------------

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

                        round_count += 1;
                        index_crypto = 0;
                    } else {
                        index_crypto += 1;
                    }
                }
            }
        } catch (Exception e) {
            initTelegramBotsApi();
            System.out.println("Duydk:" + e.getMessage());
            e.printStackTrace();
            System.exit(0);
        }
    }

    public static void initTelegramBotsApi() {
        System.out.println("____________________initTelegramBotsApi" + Utils.getTimeHHmm() + "____________________");
    }

    private static void checkBtcKillLongShort_15m(BinanceService binance_service) {
        if (isReloadAfter(Utils.MINUTES_OF_15M, "KILL_BTC")) {
            System.out.println(Utils.getTimeHHmm() + "checkKillLongShort BTC(15m)");
            binance_service.sendMsgKillLongShort("bitcoin", "BTC");
            wait(SLEEP_MINISECONDS);
        }

        if (isReloadAfter(Utils.MINUTES_OF_15M, "KILL_ETH")) {
            System.out.println(Utils.getTimeHHmm() + "checkKillLongShort ETH(15m)");
            binance_service.sendMsgKillLongShort("ethereum", "ETH");
            wait(SLEEP_MINISECONDS);
        }

        if (isReloadAfter(Utils.MINUTES_OF_15M, "KILL_BNB")) {
            System.out.println(Utils.getTimeHHmm() + "checkKillLongShort BNB(15m)");
            binance_service.sendMsgKillLongShort("binancecoin", "BNB");
            wait(SLEEP_MINISECONDS);
        }

        // ---------------------------------------------------------------------
        if (isReloadAfter(Utils.MINUTES_OF_15M, "CHART_15m_BTC")) {
            String trend = binance_service.checkCrypto(Utils.CRYPTO_TIME_15m, "bitcoin", "BTC");
            System.out.println(Utils.getTimeHHmm() + "check chart BTC(15m)" + trend);
            wait(SLEEP_MINISECONDS);
        }
        if (isReloadAfter(Utils.MINUTES_OF_1H, "CHART_1H_BTC")) {
            String trend = binance_service.checkCrypto(Utils.CRYPTO_TIME_1h, "bitcoin", "BTC");
            System.out.println(Utils.getTimeHHmm() + "check chart BTC(1h) " + trend);
            wait(SLEEP_MINISECONDS);
        }
        if (isReloadAfter(Utils.MINUTES_OF_4H, "CHART_4H_BTC")) {
            String trend = binance_service.checkCrypto(Utils.CRYPTO_TIME_4h, "bitcoin", "BTC");
            System.out.println(Utils.getTimeHHmm() + "check chart BTC(4h) " + trend);
            wait(SLEEP_MINISECONDS);
        }
        // ---------------------------------------------------------------------
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
