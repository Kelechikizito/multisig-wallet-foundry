import { useEffect, useState, useCallback } from "react";
import {
  readContract,
  writeContract,
  waitForTransactionReceipt,
} from "@wagmi/core";
import type { Config } from "wagmi";
import { PublicClient } from "viem";
import { multisigTimelockAbi } from "@/constants";

export function useSigners(
  config: Config | undefined,
  multisigAddress: `0x${string}` | undefined,
  publicClient: PublicClient | undefined
) {
  const [signers, setSigners] = useState<string[]>([]); // List/Array of signer addresses
  const [loading, setLoading] = useState(false); // Loading state
  const [error, setError] = useState<string | null>(null); // Error state

  // Load from localStorage
  // When the page first loads, it checks the browser’s storage.
  // If it finds a saved list, it uses that right away.
  // This makes the UI faster and avoids a blank screen while waiting for blockchain data.
  useEffect(() => {
    const cached = localStorage.getItem("multisig_signers");
    if (cached) setSigners(JSON.parse(cached));
  }, []);

  // As long as the dependencies(config, multisigAddress, publicClient) don't change, fetchSigners remains the same function instance.
  const fetchSigners = useCallback(async () => {
    if (!config || !multisigAddress || !publicClient) return;

    try {
      setLoading(true);
      setError(null);

      const signerList = (await readContract(config, {
        abi: multisigTimelockAbi,
        address: multisigAddress,
        functionName: "getSigners",
      })) as `0x${string}`[];

      const valid = signerList.filter(
        (addr) => addr !== "0x0000000000000000000000000000000000000000"
      );

      setSigners(valid);
      localStorage.setItem("multisig_signers", JSON.stringify(valid));
    } catch (err: any) {
      console.error("❌ useSigners error:", err);
      setError(err?.message ?? "Failed to fetch signers");
    } finally {
      setLoading(false);
    }
  }, [config, multisigAddress, publicClient]);

  // Add signer
  const addSigner = useCallback(
    async (address: `0x${string}`) => {
      if (!config || !multisigAddress) return;
      try {
        setLoading(true);
        const txHash = await writeContract(config, {
          abi: multisigTimelockAbi,
          address: multisigAddress,
          functionName: "grantSigningRole",
          args: [address],
        });
        await waitForTransactionReceipt(config, { hash: txHash });
        await fetchSigners();
      } catch (err: any) {
        console.error("❌ addSigner error:", err);
        setError(err?.message ?? "Failed to add signer");
      } finally {
        setLoading(false);
      }
    },
    [config, multisigAddress, fetchSigners]
  );

  // Revoke signer
  const revokeSigner = useCallback(
    async (address: `0x${string}`) => {
      if (!config || !multisigAddress) return;
      try {
        setLoading(true);
        const txHash = await writeContract(config, {
          abi: multisigTimelockAbi,
          address: multisigAddress,
          functionName: "revokeSigningRole",
          args: [address],
        });
        await waitForTransactionReceipt(config, { hash: txHash });
        await fetchSigners();
      } catch (err: any) {
        console.error("❌ revokeSigner error:", err);
        setError(err?.message ?? "Failed to revoke signer");
      } finally {
        setLoading(false);
      }
    },
    [config, multisigAddress, fetchSigners]
  );

  useEffect(() => {
    fetchSigners();
  }, [fetchSigners]);

  return {
    signers,
    loading,
    error,
    refetch: fetchSigners,
    addSigner,
    revokeSigner,
  };
}
