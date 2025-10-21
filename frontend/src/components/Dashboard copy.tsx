"use client";

import React, { useState } from "react";
import {
  Shield,
  Clock,
  Users,
  Send,
  CheckCircle,
  XCircle,
  AlertCircle,
} from "lucide-react";
import { parseEther } from "viem";
import ProposeTransactionModal from "./ui/ProposeTransactionModal";
import StatsCard from "./ui/StatsCard";
import TransactionCard from "./ui/TransactionCard";
import {
  useChainId,
  useBalance,
  useConfig,
  useAccount,
  usePublicClient,
} from "wagmi";
import { chainsToMultisigTimelock, multisigTimelockAbi } from "@/constants";
import { watchContractEvent } from "@wagmi/core";
// import { useTransactions } from "@/hooks/useTransactions";

// Main Dashboard
const Dashboard = () => {
  const [activeTab, setActiveTab] = useState("pending");
  const [isModalOpen, setIsModalOpen] = useState(false);

  // WAGMI & VIEM HOOKS
  const config = useConfig();
  const chainId = useChainId();
  const { isConnected } = useAccount();

  // The Sepolia Contract Address
  const multisigTimelockSepoliaAddress =
    chainsToMultisigTimelock[chainId]?.["multisigtimelock"];

  // // Custom hook to fetch transactions
  // const {
  //   transactions,
  //   isLoading,
  //   error,
  //   refetch,
  //   pendingCount,
  //   executedCount,
  // } = useTransactions(multisigTimelockSepoliaAddress);

  // Reading the contract eth balance
  const { data: walletBalance } = useBalance({
    address: multisigTimelockSepoliaAddress as `0x${string}`,
  });

  // Function to handle the transaction proposal
  const handlePropose = async (to: string, amount: string, data: string) => {
    if (!isConnected) {
      alert("Please connect your wallet first");
      return;
    }

    try {
      // Convert ETH amount to wei
      const valueInWei = parseEther(amount);

      // Call contract function
      proposeTransaction({
        args: [to as `0x${string}`, valueInWei, data as `0x${string}`],
      });

      console.log("Transaction proposed successfully!");
      refetch(); // Refresh transactions after proposing
    } catch (error) {
      console.error("Error proposing transaction:", error);
      alert("Failed to propose transaction. Check console for details.");
    }
  };

  // // Filter transactions based on active tab
  // const filteredTransactions = transactions.filter((tx) =>
  //   activeTab === "pending" ? !tx.executed : tx.executed
  // );

  // Transaction executed event listener
  const unwatch = watchContractEvent(config, {
    address: multisigTimelockSepoliaAddress as `0x${string}`,
    abi: multisigTimelockAbi,
    eventName: "TransactionExecuted",
    onLogs(logs) {
      console.log("New logs!", logs);
    },
  });

  unwatch();

  return (
    <div className="bg-gray-50 dark:bg-gray-900 min-h-screen">
      <main className="max-w-7xl mx-auto px-4 md:px-8 py-8">
        {/* Stats Grid */}
        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6 mb-8">
          <StatsCard
            icon={Shield}
            label="Total Signers"
            value="5"
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
            value={"0"}
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

        {/* Action Buttons */}
        <div className="flex gap-4 mb-6">
          <button
            onClick={() => setIsModalOpen(true)}
            disabled={!isConnected}
            className={`flex items-center gap-2 px-6 py-3 rounded-lg font-medium transition-colors shadow-sm ${
              isConnected
                ? "bg-blue-600 hover:bg-blue-700 text-white cursor-pointer"
                : "bg-gray-300 text-gray-500 cursor-not-allowed"
            }`}
          >
            <Send className="h-5 w-5" />
            Propose Transaction
          </button>
          <button
            className="flex items-center gap-2 px-6 py-3 bg-white hover:bg-gray-50 text-gray-700 border border-gray-200 rounded-lg font-medium transition-colors shadow-sm cursor-not-allowed"
            disabled
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
            Pending ({pendingCount})
          </button>
          <button
            onClick={() => setActiveTab("executed")}
            className={`px-4 py-2 font-medium transition-colors border-b-2 ${
              activeTab === "executed"
                ? "text-blue-600 border-blue-600"
                : "text-gray-600 border-transparent hover:text-gray-900"
            }`}
          >
            Executed ({executedCount})
          </button>
        </div>

        {/* Error State */}
        {error && (
          <div className="text-center py-12 text-red-600">
            <AlertCircle className="h-16 w-16 mx-auto mb-4" />
            <p>Error loading transactions: {error.message}</p>
          </div>
        )}

        {/* Loading State */}
        {isLoading && !error && (
          <div className="text-center py-12 ">
            <div className="animate-spin rounded-full h-12 w-12 border-b-2 border-blue-600 mx-auto mb-4"></div>
            <p className="text-gray-600">Loading transactions...</p>
          </div>
        )}

        {/* Transactions Grid */}
        {!isLoading && !error && (
          <div className="grid grid-cols-1 lg:grid-cols-2 gap-6">
            {filteredTransactions.map((tx) => (
              <TransactionCard
                key={tx.id}
                tx={tx}
                onConfirm={(id) => console.log("Confirm", id)} // Update with actual confirm logic
                onRevoke={(id) => console.log("Revoke", id)} // Update with actual revoke logic
              />
            ))}
          </div>
        )}

        {/* Empty State (tab-specific) */}
        {!isLoading && !error && filteredTransactions.length === 0 && (
          <div className="text-center py-12 dark:text-white">
            <Shield className="h-16 w-16 text-gray-300 mx-auto mb-4" />
            <h3 className="text-lg font-medium text-gray-900 mb-2 dark:text-white">
              No {activeTab} transactions yet
            </h3>
            <p className="text-gray-600">
              {activeTab === "pending"
                ? "Create your first transaction to get started"
                : "No executed transactions found"}
            </p>
          </div>
        )}
      </main>

      <ProposeTransactionModal
        isOpen={isModalOpen}
        onClose={() => setIsModalOpen(false)}
        onPropose={handlePropose}
      />
    </div>
  );
};

export default Dashboard;
