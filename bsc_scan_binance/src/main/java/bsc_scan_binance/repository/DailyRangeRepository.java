package bsc_scan_binance.repository;

import java.util.List;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import bsc_scan_binance.entity.DailyRange;
import bsc_scan_binance.entity.DailyRangeKey;

@Repository
public interface DailyRangeRepository extends JpaRepository<DailyRange, DailyRangeKey> {

    @Query(value = "SELECT m.* FROM daily_range m WHERE yyyy_mm_dd = TO_CHAR(CURRENT_DATE, 'YYYY.MM.DD') ORDER BY symbol", nativeQuery = true)
    public List<DailyRangeKey> findAllToday();

    @Query(value = "SELECT m.* FROM daily_range m WHERE yyyy_mm_dd = TO_CHAR(CURRENT_DATE, 'YYYY.MM.DD') and symbol = :symbol", nativeQuery = true)
    public List<DailyRangeKey> findSymbolToday(@Param("symbol") String symbol);
}