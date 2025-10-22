"use client";

import React, { useEffect, useState, useMemo } from "react";
import { Shield, Clock, Users, Send, CheckCircle } from "lucide-react";
import { parseEther } from "viem";
import ProposeTransactionModal from "./ui/ProposeTransactionModal";
import ManageSignersModal from "./ui/ManageSignersModal";
import StatsCard from "./ui/StatsCard";
import TransactionCard from "./ui/TransactionCard";
import {
  useChainId,
  useBalance,
  useConfig,
  useAccount,
  usePublicClient,
} from "wagmi";
import {
  readContract,
  writeContract,
  waitForTransactionReceipt,
} from "@wagmi/core";
import { chainsToMultisigTimelock, multisigTimelockAbi } from "@/constants";
import { useTransactions } from "@/hooks/useTransactions";
import { useSigners } from "@/hooks/useSigners";

type UiTx = {
  id: number;
  to: string;
  amount: number;
  confirmations: number;
  executed: boolean;
  timelock?: number | undefined;
};

const Dashboard: React.FC = () => {
  const [activeTab, setActiveTab] = useState<"pending" | "executed">("pending");
  const [isModalOpen, setIsModalOpen] = useState(false);
  const [isWriting, setIsWriting] = useState(false);
  const [showSignersModal, setShowSignersModal] = useState(false);

  // ownership state
  const [contractOwner, setContractOwner] = useState<string | null>(null);
  const [ownerLoading, setOwnerLoading] = useState(false);

  // Wagmi hooks
  const config = useConfig();
  const chainId = useChainId();
  const { address: connectedAddress, isConnected } = useAccount();
  const publicClient = usePublicClient();

  const multisigAddress = chainsToMultisigTimelock[chainId]?.multisigtimelock;

  const { data: walletBalance } = useBalance({
    address: multisigAddress as `0x${string}`,
  });

  const isOwner =
    isConnected &&
    contractOwner &&
    connectedAddress?.toLowerCase() === contractOwner.toLowerCase();

  const {
    transactions,
    loading: loadingTxs,
    refetch: refetchTransactions,
  } = useTransactions(config, multisigAddress, publicClient);
  const { signers, loading: signersLoading } = useSigners(
    config,
    multisigAddress,
    publicClient
  );

  // READ owner() from contract
  useEffect(() => {
    const loadOwner = async () => {
      if (!config || !multisigAddress || !publicClient) return;
      try {
        setOwnerLoading(true);
        const owner = (await readContract(config, {
          abi: multisigTimelockAbi,
          address: multisigAddress as `0x${string}`,
          functionName: "owner",
        })) as string;
        setContractOwner(owner);
      } catch (err) {
        console.error("Failed to read contract owner:", err);
        setContractOwner(null);
      } finally {
        setOwnerLoading(false);
      }
    };
    loadOwner();
  }, [config, multisigAddress, publicClient]);

  // ======== HANDLERS ========
  const handlePropose = async (to: string, amount: string, data: string) => {
    if (!isConnected) {
      alert("Please connect your wallet");
      return;
    }
    if (!isOwner) {
      alert("Only the contract owner may propose transactions");
      return;
    }
    if (!multisigAddress) {
      alert("Contract address not configured for this chain");
      return;
    }

    try {
      setIsWriting(true);
      const valueInWei = parseEther(amount);

      const tx = await writeContract(config, {
        abi: multisigTimelockAbi,
        address: multisigAddress as `0x${string}`,
        functionName: "proposeTransaction",
        args: [
          to as `0x${string}`,
          valueInWei,
          data && data.length > 0 ? (data as `0x${string}`) : "0x",
        ],
      });

      console.log("Propose tx submitted:", tx);
      const receipt = await waitForTransactionReceipt(config, { hash: tx });
      console.log("✅ Tx confirmed:", receipt);

      await refetchTransactions();
      alert("Proposal confirmed and transaction list updated!");
    } catch (err: any) {
      console.error("Propose error:", err);
      alert(err?.message ?? "Propose failed");
    } finally {
      setIsWriting(false);
      setIsModalOpen(false);
    }
  };

  const handleConfirm = async (txId: number) => {
    if (!isConnected) {
      alert("Please connect your wallet");
      return;
    }
    if (!multisigAddress) {
      alert("Contract address not configured for this chain");
      return;
    }

    try {
      setIsWriting(true);
      const txHash = await writeContract(config, {
        abi: multisigTimelockAbi,
        address: multisigAddress as `0x${string}`,
        functionName: "confirmTransaction",
        args: [BigInt(txId)],
      });
      console.log("Confirm tx submitted:", txHash);

      const receipt = await waitForTransactionReceipt(config, { hash: txHash });
      console.log("✅ Confirmed:", receipt);

      await refetchTransactions();
      alert("Transaction successfully confirmed!");
    } catch (err: any) {
      console.error("Confirm error:", err);
      alert(err?.message ?? "Confirm failed");
    } finally {
      setIsWriting(false);
    }
  };

  const handleRevoke = async (txId: number) => {
    if (!isConnected) {
      alert("Please connect your wallet");
      return;
    }
    if (!multisigAddress) {
      alert("Contract address not configured for this chain");
      return;
    }

    try {
      setIsWriting(true);
      const txHash = await writeContract(config, {
        abi: multisigTimelockAbi,
        address: multisigAddress as `0x${string}`,
        functionName: "revokeConfirmation",
        args: [BigInt(txId)],
      });
      console.log("Revoke tx submitted:", txHash);

      const receipt = await waitForTransactionReceipt(config, { hash: txHash });
      console.log("✅ Revoked:", receipt);

      await refetchTransactions();
      alert("Confirmation revoked successfully!");
    } catch (err: any) {
      console.error("Revoke error:", err);
      alert(err?.message ?? "Revoke failed");
    } finally {
      setIsWriting(false);
    }
  };

  const handleExecute = async (txId: number) => {
    if (!isConnected) {
      alert("Please connect your wallet");
      return;
    }
    if (!multisigAddress) {
      alert("Contract address not configured for this chain");
      return;
    }

    try {
      setIsWriting(true);
      const txHash = await writeContract(config, {
        abi: multisigTimelockAbi,
        address: multisigAddress as `0x${string}`,
        functionName: "executeTransaction",
        args: [BigInt(txId)],
      });

      console.log("Execute tx submitted:", txHash);

      const receipt = await waitForTransactionReceipt(config, { hash: txHash });
      console.log("✅ Execution mined:", receipt);

      await refetchTransactions();
      alert("Transaction executed successfully!");
      setActiveTab("executed");
    } catch (err: any) {
      console.error("Execute error:", err);
      alert(err?.message ?? "Execute failed");
    } finally {
      setIsWriting(false);
    }
  };

  const totalSigners = useMemo(() => signers?.length || 0, [signers]);

  // === Filter transactions ===
  const pendingTxs = transactions.filter((tx) => !tx.executed);
  const executedTxs = transactions.filter((tx) => tx.executed);
  const visibleTxs = activeTab === "pending" ? pendingTxs : executedTxs;

  return (
    <div className="bg-gray-50 dark:bg-gray-900 min-h-screen">
      <main className="max-w-7xl mx-auto px-4 md:px-8 py-8">
        {/* Stats Grid */}
        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6 mb-8">
          <StatsCard
            icon={Shield}
            label="Total Signers"
            value={signersLoading ? "..." : totalSigners}
            color="blue"
          />
          <StatsCard
            icon={CheckCircle}
            label="Required Confirmations"
            value="3"
            color="green"
          />
          <StatsCard
            icon={Clock}
            label="Pending Transactions"
            value={String(pendingTxs.length)}
            color="orange"
          />
          <StatsCard
            icon={Send}
            label="Wallet Balance"
            value={
              walletBalance?.formatted
                ? `${walletBalance.formatted} ETH`
                : "Loading..."
            }
            color="purple"
          />
        </div>

        {/* Actions */}
        <div className="flex gap-4 mb-6">
          <button
            onClick={() => setIsModalOpen(true)}
            disabled={!isConnected || !isOwner || ownerLoading || isWriting}
            className={`flex items-center gap-2 px-6 py-3 rounded-lg font-medium transition-colors shadow-sm ${
              isConnected && isOwner && !isWriting
                ? "bg-blue-600 hover:bg-blue-700 text-white cursor-pointer"
                : "bg-gray-300 text-gray-500 cursor-not-allowed"
            }`}
            title={
              !isConnected
                ? "Connect wallet"
                : ownerLoading
                ? "Checking owner..."
                : !isOwner
                ? "Only contract owner can propose"
                : "Propose Transaction"
            }
          >
            <Send className={`h-5 w-5 ${isWriting ? "animate-spin" : ""}`} />
            {isWriting ? "Processing..." : "Propose Transaction"}
          </button>

          <button
            onClick={() => setShowSignersModal(true)}
            disabled={!isConnected || !isOwner || ownerLoading || isWriting}
            className="flex items-center gap-2 px-6 py-3 bg-white hover:bg-gray-50 text-gray-700 border border-gray-200 rounded-lg font-medium transition-colors shadow-sm cursor-pointer"
          >
            <Users className="h-5 w-5" />
            Manage Signers
          </button>
        </div>

        {/* Tabs */}
        <div className="flex gap-4 mb-6 border-b border-gray-200">
          <button
            onClick={() => setActiveTab("pending")}
            className={`px-4 py-2 font-medium transition-colors border-b-2 ${
              activeTab === "pending"
                ? "text-blue-600 border-blue-600"
                : "text-gray-600 border-transparent hover:text-gray-900"
            }`}
          >
            Pending
          </button>
          <button
            onClick={() => setActiveTab("executed")}
            className={`px-4 py-2 font-medium transition-colors border-b-2 ${
              activeTab === "executed"
                ? "text-blue-600 border-blue-600"
                : "text-gray-600 border-transparent hover:text-gray-900"
            }`}
          >
            Executed
          </button>
        </div>

        {/* Transactions */}
        {loadingTxs ? (
          <p className="text-gray-500">Loading transactions...</p>
        ) : visibleTxs.length === 0 ? (
          <p className="text-gray-500">
            {activeTab === "pending"
              ? "No pending transactions."
              : "No executed transactions yet."}
          </p>
        ) : (
          <div className="grid grid-cols-1 lg:grid-cols-2 gap-6">
            {visibleTxs.map((tx) => (
              <TransactionCard
                key={tx.id}
                tx={tx}
                onConfirm={() => handleConfirm(tx.id)}
                onRevoke={() => handleRevoke(tx.id)}
                onExecute={() => handleExecute(tx.id)}
                isLoading={isWriting}
              />
            ))}
          </div>
        )}
      </main>

      <ProposeTransactionModal
        isOpen={isModalOpen}
        onClose={() => setIsModalOpen(false)}
        onPropose={handlePropose}
      />
      <ManageSignersModal
        open={showSignersModal}
        onClose={() => setShowSignersModal(false)}
        config={config}
        multisigAddress={multisigAddress as `0x${string}`}
        publicClient={publicClient}
      />
    </div>
  );
};

export default Dashboard;
