package bsc_scan_binance.repository;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import bsc_scan_binance.entity.Mt5OpenTradeEntity;

@Repository
public interface Mt5OpenTradeRepository extends JpaRepository<Mt5OpenTradeEntity, String> {
}