"use client";

import { useState } from "react";
import { X, AlertCircle, Info } from "lucide-react";

interface ProposeTransactionModalProps {
  isOpen: boolean;
  onClose: () => void;
  onPropose: (to: string, amount: string, data: string) => void;
}

export default function ProposeTransactionModal({
  isOpen,
  onClose,
  onPropose,
}: ProposeTransactionModalProps) {
  const [to, setTo] = useState("");
  const [amount, setAmount] = useState("");
  const [data, setData] = useState("0x");
  const [error, setError] = useState("");

  if (!isOpen) return null;

  const getTimelockInfo = (ethAmount: number) => {
    if (ethAmount < 1) return { delay: "No delay", color: "text-green-600" };
    if (ethAmount < 10) return { delay: "1 day", color: "text-yellow-600" };
    if (ethAmount < 100) return { delay: "2 days", color: "text-orange-600" };
    return { delay: "7 days", color: "text-red-600" };
  };

  const timelockInfo = amount ? getTimelockInfo(parseFloat(amount) || 0) : null;

  const handleSubmit = (e: React.FormEvent) => {
    e.preventDefault();

    // Basic validation
    if (!to || !amount) {
      setError("Please fill in all required fields");
      return;
    }

    if (!/^0x[a-fA-F0-9]{40}$/.test(to)) {
      setError("Invalid Ethereum address");
      return;
    }

    if (parseFloat(amount) <= 0) {
      setError("Amount must be greater than 0");
      return;
    }

    onPropose(to, amount, data);
    setTo("");
    setAmount("");
    setData("0x");
    setError("");
    onClose();
  };

  return (
    <div className="fixed inset-0 z-50 flex items-center justify-center p-4 bg-black bg-opacity-50 bg-white dark:bg-gray-800 text-gray-900 dark:text-white">
      <div className="bg-white rounded-lg shadow-xl max-w-md w-full max-h-[90vh] overflow-y-auto">
        {/* Header */}
        <div className="flex items-center justify-between p-6 border-b border-gray-200">
          <h2 className="text-xl font-bold text-gray-900">
            Propose Transaction
          </h2>
          <button
            onClick={onClose}
            className="p-1 hover:bg-gray-100 rounded-lg transition-colors"
          >
            <X className="h-5 w-5 text-gray-500" />
          </button>
        </div>

        {/* Form */}
        <form onSubmit={handleSubmit} className="p-6 space-y-4">
          {/* Recipient Address */}
          <div>
            <label className="block text-sm font-medium text-gray-700 mb-2">
              Recipient Address *
            </label>
            <input
              type="text"
              value={to}
              onChange={(e) => setTo(e.target.value)}
              placeholder="0x..."
              className="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-transparent outline-none"
            />
          </div>

          {/* Amount */}
          <div>
            <label className="block text-sm font-medium text-gray-700 mb-2">
              Amount (ETH) *
            </label>
            <input
              type="number"
              step="0.000001"
              value={amount}
              onChange={(e) => setAmount(e.target.value)}
              placeholder="0.0"
              className="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-transparent outline-none"
            />
          </div>

          {/* Timelock Info */}
          {timelockInfo && (
            <div className="p-4 bg-blue-50 rounded-lg border border-blue-200">
              <div className="flex items-start gap-2">
                <Info className="h-5 w-5 text-blue-600 mt-0.5" />
                <div>
                  <p className="text-sm font-medium text-blue-900">
                    Timelock Period
                  </p>
                  <p className={`text-sm ${timelockInfo.color} font-semibold`}>
                    {timelockInfo.delay}
                  </p>
                  <p className="text-xs text-blue-700 mt-1">
                    This transaction will require a {timelockInfo.delay} waiting
                    period after receiving 3 confirmations
                  </p>
                </div>
              </div>
            </div>
          )}

          {/* Call Data (Optional) */}
          <div>
            <label className="block text-sm font-medium text-gray-700 mb-2">
              Call Data (Optional)
            </label>
            <textarea
              value={data}
              onChange={(e) => setData(e.target.value)}
              placeholder="0x"
              rows={3}
              className="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-transparent outline-none font-mono text-sm"
            />
            <p className="text-xs text-gray-500 mt-1">
              Leave as "0x" for simple ETH transfers
            </p>
          </div>

          {/* Error Message */}
          {error && (
            <div className="p-4 bg-red-50 rounded-lg border border-red-200">
              <div className="flex items-start gap-2">
                <AlertCircle className="h-5 w-5 text-red-600 mt-0.5" />
                <p className="text-sm text-red-800">{error}</p>
              </div>
            </div>
          )}

          {/* Info Box */}
          <div className="p-4 bg-gray-50 rounded-lg border border-gray-200">
            <p className="text-xs text-gray-600">
              <strong>Note:</strong> This transaction will require 3 out of 5
              signers to confirm before execution.
            </p>
          </div>

          {/* Buttons */}
          <div className="flex gap-3 pt-2">
            <button
              type="button"
              onClick={onClose}
              className="flex-1 px-4 py-2 border border-gray-300 rounded-lg text-gray-700 font-medium hover:bg-gray-50 transition-colors"
            >
              Cancel
            </button>
            <button
              type="submit"
              className="flex-1 px-4 py-2 bg-blue-600 hover:bg-blue-700 text-white rounded-lg font-medium transition-colors"
            >
              Propose
            </button>
          </div>
        </form>
      </div>
    </div>
  );
}
