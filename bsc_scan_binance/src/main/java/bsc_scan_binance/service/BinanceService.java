package bsc_scan_binance.service;

import java.util.List;

import bsc_scan_binance.entity.Orders;
import bsc_scan_binance.response.CandidateTokenCssResponse;

public interface BinanceService {

    List<CandidateTokenCssResponse> getList(Boolean isOrderByBynaceVolume);

    public void loadData(String gecko_id, String symbol);

    public void loadDataVolumeHour(String gecko_id, String symbol);

    public void monitorProfit();

    public void monitorBollingerBandwidth(Boolean isCallFormBot);

    List<Orders> getOrderList();

    public String loadPremarket();
}
