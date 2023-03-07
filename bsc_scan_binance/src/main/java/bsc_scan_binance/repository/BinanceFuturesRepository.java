package bsc_scan_binance.repository;

import java.util.List;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.stereotype.Repository;

import bsc_scan_binance.entity.BinanceFutures;

@Repository
public interface BinanceFuturesRepository extends JpaRepository<BinanceFutures, String> {
    @Query(value = "SELECT m.* FROM binance_futures m WHERE scalping_today", nativeQuery = true)
    public List<BinanceFutures> findAllByScalpingToday();

    public Boolean existsBySymbol(String symbol);
}