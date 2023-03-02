package bsc_scan_binance.service;

import java.util.List;

import bsc_scan_binance.response.CandidateTokenCssResponse;
import bsc_scan_binance.response.DepthResponse;
import bsc_scan_binance.response.EntryCssResponse;
import bsc_scan_binance.response.ForexHistoryResponse;

public interface BinanceService {

    List<CandidateTokenCssResponse> getList(Boolean isOrderByBynaceVolume);

    public void monitorBollingerBandwidth(Boolean isCallFormBot);

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

    public String initForexTrend(String EPIC, String CAPITAL_TIME_XXX);

    public String sendMsgKillLongShort(String gecko_id, String symbol);

    public String initCryptoTrend(String TIME, String gecko_id, String symbol);

    public boolean hasConnectTimeOutException();

    public void createReport();

    public List<String> getSummaryCurrencies(String SOURCE, String CAPITAL_TIME_XXX);

    public void scapForexTrend(String EPIC);

}
