package bsc_scan_binance.repository;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import bsc_scan_binance.entity.Mt5Macd;
import bsc_scan_binance.entity.Mt5MacdKey;

@Repository
public interface Mt5MacdRepository extends JpaRepository<Mt5Macd, Mt5MacdKey> {

}
