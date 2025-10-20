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
// import { useAccount, useContractWrite, useWaitForTransaction } from "wagmi";
import { parseEther } from "viem";
import ProposeTransactionModal from "./ui/ProposeTransactionModal";
import StatsCard from "./ui/StatsCard";
import TransactionCard from "./ui/TransactionCard";
import {
  useChainId,
  useBalance,
  useConfig,
  useAccount
} from "wagmi";
import { readContract } from '@wagmi/core';
import { chainsToMultisigTimelock, multisigTimelockAbi } from "@/constants";

// Main Dashboard
const Dashboard = () => {
  const [activeTab, setActiveTab] = useState("pending");
  // ✅ ONLY ONE state variable for the modal
  const [isModalOpen, setIsModalOpen] = useState(false);
  const config = useConfig();
  const chainId = useChainId();
  const { isConnected } = useAccount();

  // The Sepolia Contract Address
  const multisigTimelockSepoliaAddress = chainsToMultisigTimelock[chainId]["multisigtimelock"];

  // Mock data - replace with actual contract data
  const transactions = [
    {
      id: 1,
      to: "0x742d35Cc6634C0532925a3b844Bc9e7595f0bEb",
      amount: 0.5,
      confirmations: 2,
      executed: false,
      timelock: null,
    },
    {
      id: 2,
      to: "0x8626f6940E2eb28930eFb4CeF49B2d1F2C9C1199",
      amount: 5,
      confirmations: 3,
      executed: false,
      timelock: Date.now() + 86400000,
    },
    {
      id: 3,
      to: "0xdD2FD4581271e230360230F9337D5c0430Bf44C0",
      amount: 50,
      confirmations: 1,
      executed: false,
      timelock: Date.now() + 172800000,
    },
  ];

  // Reading the contract eth balance
  const {data: walletBalance} = useBalance({
    address: multisigTimelockSepoliaAddress as `0x${string}`,
  })

  // Function to handle the transaction proposal
  const handlePropose = async (to: string, amount: string, data: string) => {
    if (isConnected) {
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
    } catch (error) {
      console.error("Error proposing transaction:", error);
      alert("Failed to propose transaction. Check console for details.");
    }
  };

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
            value="3"
            color="orange"
          />
          <StatsCard
            icon={Send}
            label="Wallet Balance"
            value={walletBalance?.formatted ? `${walletBalance.formatted} ETH` : 'Loading...'}
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
          <button className="flex items-center gap-2 px-6 py-3 bg-white hover:bg-gray-50 text-gray-700 border border-gray-200 rounded-lg font-medium transition-colors shadow-sm cursor-not-allowed" disabled>
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

        {/* Transactions Grid */}
        <div className="grid grid-cols-1 lg:grid-cols-2 gap-6">
          {transactions.map((tx) => (
            <TransactionCard
              key={tx.id}
              tx={tx}
              onConfirm={(id) => console.log("Confirm", id)}
              onRevoke={(id) => console.log("Revoke", id)}
            />
          ))}
        </div>

        {/* Empty State */}
        {transactions.length === 0 && (
          <div className="text-center py-12">
            <Shield className="h-16 w-16 text-gray-300 mx-auto mb-4" />
            <h3 className="text-lg font-medium text-gray-900 mb-2">
              No transactions yet
            </h3>
            <p className="text-gray-600">
              Create your first transaction to get started
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
