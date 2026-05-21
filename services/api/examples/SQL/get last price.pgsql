 SELECT DISTINCT ON (p.asset_id)
 p.id,
          p.asset_id,
          a.symbol,
          a.address,
          p.price_usd,
          p.calculated_at
        FROM dex_prices p
          INNER JOIN assets a ON a.id = p.asset_id
          ORDER BY p.asset_id, p.calculated_at DESC;

        UPDATE dex_prices SET price_usd=1500 WHERE asset_id = 87769;