import { useEffect, useState, useCallback } from "react";
import { readContract } from "@wagmi/core";
import { multisigTimelockAbi } from "@/constants";
import type { Config } from "wagmi";
import { PublicClient } from "viem";

export type UiTx = {
  id: number;
  to: string;
  amount: number;
  confirmations: number;
  executed: boolean;
  timelock?: number; // stored in milliseconds
};

export function useTransactions(
  config: Config | undefined,
  multisigAddress: string | `0x${string}` | undefined,
  publicClient: PublicClient | undefined
) {
  const [transactions, setTransactions] = useState<UiTx[]>([]);
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState<string | null>(null);

  // 🧠 Unique cache key (per multisig)
  const storageKey = multisigAddress
    ? `multisig-transactions-${multisigAddress}`
    : "multisig-transactions";

  const fetchTransactions = useCallback(async () => {
    if (!config || !multisigAddress || !publicClient) return;

    try {
      setLoading(true);
      setError(null);

      // 1️⃣ Get transaction count
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
        const txData = await readContract(config, {
          abi: multisigTimelockAbi,
          address: multisigAddress,
          functionName: "getTransaction",
          args: [BigInt(i)],
        });

        console.log("📦 txData raw:", txData);

        const { to, value, confirmations, proposedAt, executed } = txData as any;

        // ✅ Convert proposedAt from seconds → milliseconds
        const proposedAtSec = proposedAt ? Number(proposedAt) : 0;
        const proposedAtMs =
          proposedAtSec > 0 ? proposedAtSec * 1000 : undefined;

        txs.push({
          id: i,
          to,
          amount: Number(value) / 1e18,
          confirmations: Number(confirmations),
          executed,
          timelock: proposedAtMs,
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

  // ⚙️ Load cached transactions first, then fetch fresh
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
        localStorage.removeItem(storageKey);
      }
    }

    // Fetch new data
    fetchTransactions();
  }, [fetchTransactions, multisigAddress, storageKey]);

  // 🧹 Optional: clear cache if multisig changes
  useEffect(() => {
    return () => {
      if (multisigAddress) {
        localStorage.removeItem(storageKey);
      }
    };
  }, [multisigAddress, storageKey]);

  return { transactions, loading, error, refetch: fetchTransactions };
}
