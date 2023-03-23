package bsc_scan_binance.repository;

import java.util.List;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import bsc_scan_binance.entity.Mt5DataCandle;
import bsc_scan_binance.entity.Mt5DataCandleKey;

@Repository
public interface Mt5DataCandleRepository
        extends JpaRepository<Mt5DataCandle, Mt5DataCandleKey> {

    List<Mt5DataCandle> findAllByIdEpicAndIdCandleOrderByIdCandleTimeDesc(String epic, String candle);

    List<Mt5DataCandle> findAllByCreateddateNot(String createddate);
}
