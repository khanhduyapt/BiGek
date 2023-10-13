package bsc_scan_binance.service;

import java.util.List;

import bsc_scan_binance.response.CandidateTokenCssResponse;
import bsc_scan_binance.response.DepthResponse;
import bsc_scan_binance.response.EntryCssResponse;
import bsc_scan_binance.response.ForexHistoryResponse;

public interface BinanceService {

    List<CandidateTokenCssResponse> getList(Boolean isOrderByBynaceVolume);

    public void monitorProfit();

    public String loadPremarket();

    public String getTextDepthData();

    public List<List<DepthResponse>> getListDepthData(String symbol);

    public String loadPremarketSp500();

    public String getBtcBalancesOnExchanges();

    public List<EntryCssResponse> findAllScalpingToday();

    public String getLongShortIn48h(String symbol);

    public String wallToday();

    public String getBitfinexLongShortBtc();

    public void clearTrash();

    public String initCrypto(String gecko_id, String symbol);

    public List<ForexHistoryResponse> getForexSamePhaseList();

    public List<ForexHistoryResponse> getCryptoSamePhaseList();

    boolean isFutureCoin(String gecko_id);

    public String initForexTrend(String EPIC, String CAPITAL_TIME_XX);

    public String sendMsgKillLongShort(String symbol);

    public String initCryptoTrend(String symbol);

    public boolean hasConnectTimeOutException();

    public void createReport();

    public int controlMt5(List<String> CAPITAL_LIST);

    public void deleteConnectTimeOutException();

    public void saveMt5Data(String filename, Integer MINUTES_OF_XX);

    public void saveDailyPivotData();

    public void sendMsgPerHour_OnlyMe(String EVENT_ID, String msg_content);

    public void logMsgPerHour(String epic_id, String log, Integer MINUTES_OF_Xx);

    public void closeTrade_by_SL_TP();

    public void initTradeList();

    public void CloseTickets();

    public void get_total_loss_today();

}
