package bsc_scan_binance.repository;

import java.util.List;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import bsc_scan_binance.entity.TakeProfit;

@Repository
public interface TakeProfitRepository extends JpaRepository<TakeProfit, Long> {
    List<TakeProfit> findAllBySymbolAndTradeTypeAndClosedDate(String symbol, String tradeType, String closedDate);
}
