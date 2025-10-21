import { useEffect, useState, useCallback } from "react";
import { readContract } from "@wagmi/core";
import { multisigTimelockAbi } from "@/constants";
import type { Config, PublicClient } from "wagmi";

export type UiTx = {
  id: number;
  to: string;
  amount: number;
  confirmations: number;
  executed: boolean;
  timelock?: number;
};

export function useTransactions(
  config: Config | undefined,
  multisigAddress: `0x${string}` | undefined,
  publicClient: PublicClient | undefined
) {
  const [transactions, setTransactions] = useState<UiTx[]>([]);
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState<string | null>(null);

  // 🧠 Unique cache key (prevents overwriting across wallets/networks)
  const storageKey = multisigAddress
    ? `multisig-transactions-${multisigAddress}`
    : "multisig-transactions";

  const fetchTransactions = useCallback(async () => {
    if (!config || !multisigAddress || !publicClient) return;
    try {
      setLoading(true);
      setError(null);

      // 1️⃣ Get total count
      const txCount = (await readContract(config, {
        abi: multisigTimelockAbi,
        address: multisigAddress,
        functionName: "getTransactionCount",
      })) as bigint;

      const count = Number(txCount);
      if (count === 0) {
        setTransactions([]);
        localStorage.setItem(storageKey, JSON.stringify([]));
        return;
      }

      // 2️⃣ Fetch each transaction
      const txs: UiTx[] = [];
      for (let i = 0; i < count; i++) {
        const txData = (await readContract(config, {
          abi: multisigTimelockAbi,
          address: multisigAddress,
          functionName: "getTransaction",
          args: [BigInt(i)],
        })) as [string, bigint, string, bigint, bigint, boolean];

        const [to, value, _data, confirmations, proposedAt, executed] = txData;
        txs.push({
          id: i,
          to,
          amount: Number(value) / 1e18, // wei -> ETH
          confirmations: Number(confirmations),
          executed,
          timelock: Number(proposedAt),
        });
      }

      // 3️⃣ Reverse (newest first)
      const sortedTxs = txs.reverse();

      // 💾 Cache to localStorage
      localStorage.setItem(storageKey, JSON.stringify(sortedTxs));

      setTransactions(sortedTxs);
    } catch (err: any) {
      console.error("❌ useTransactions error:", err);
      setError(err?.message ?? "Failed to load transactions");
    } finally {
      setLoading(false);
    }
  }, [config, multisigAddress, publicClient, storageKey]);

  // ⚙️ Load cached transactions immediately on mount
  useEffect(() => {
    if (!multisigAddress) return;

    const cached = localStorage.getItem(storageKey);
    if (cached) {
      try {
        const parsed = JSON.parse(cached);
        if (Array.isArray(parsed)) {
          setTransactions(parsed);
        }
      } catch {
        localStorage.removeItem(storageKey); // invalid cache, clear it
      }
    }

    // Fetch fresh data in background
    fetchTransactions();
  }, [fetchTransactions, multisigAddress, storageKey]);

  // 🧹 Clear cache if multisig changes (optional safety)
  useEffect(() => {
    return () => {
      if (multisigAddress) {
        localStorage.removeItem(storageKey);
      }
    };
  }, [multisigAddress, storageKey]);

  return { transactions, loading, error, refetch: fetchTransactions };
}
